import glob
import os
import jinja2
import yaml
import argparse
import shutil
import configparser

from utils import remove_property_if_exits, write_property

ROOT_DIR = "dhive"
GLOBAL_SECTION = "global"


class Generator(object):
    def __init__(self, config_file, ports_file, output_dir, namespace):
        self.config_file = config_file
        self.ports_file = ports_file
        self.output_dir = output_dir
        self.namespace = namespace
        self.CONTAINER_BASE = os.path.join(self.output_dir, "containers/base")
        self.CONFIG_DIRECTORY = os.path.join(self.CONTAINER_BASE, "conf")
        self.MODULE_DIRECTORY = os.path.join(self.output_dir, "services")
        self.DOCKER_COMPOSE_FILE = os.path.join(self.output_dir, "docker-compose.yml")
        self.DOCKERFILE = os.path.join(self.CONTAINER_BASE, "Dockerfile")
        self.DOCKER_SCRIPTS = os.path.join(self.CONTAINER_BASE, "docker_scripts")
        with open(self.ports_file) as f:
            self.ports_yaml = yaml.safe_load(f)

        self.template = \
"""
version: "2"
services:

networks:
  default:
    external:
      name: {0}com

volumes:
  {0}server-keytab:
""".format(self.namespace)

    def populate_configuration(self, config):
        self._populate_configuration_module(config, "core")
        self._populate_configuration_module(config, "hdfs")
        self._populate_configuration_module(config, "yarn")
        self._populate_configuration_module(config, "tez")
        self._populate_configuration_module(config, "hive")
        self._populate_configuration_module(config, "hivemetastore")

    def generate_external_module(self, config, service):
        for name, value in config.items(service):
            if name == "assure":
                for file in value.split("\n"):
                    if file:
                        head, tail = os.path.split(file)
                        shutil.copyfile(file, os.path.join(self.CONTAINER_BASE, tail))
            elif name == "docker":
                with open(self.DOCKERFILE, "a") as f:
                    f.write("\n")
                    f.write(value)

            elif name == "run":
                file_to_run = service + ".sh"
                with open(self.DOCKERFILE):
                    with open(self.DOCKERFILE, "a") as f:
                        f.write("\nCOPY docker_scripts/{} /\n".format(file_to_run))

                with open(os.path.join(self.DOCKER_SCRIPTS, file_to_run), "w") as f:

                    f.write(value.replace("\\t", "    ").lstrip("\n"))
                    f.write("\n\n")

            # TODO this is appending at the end and it should append it before that
            elif name == "kerberos":
                for user in value.split("\n"):
                    if user:
                        with open(os.path.join(self.DOCKER_SCRIPTS, "start-kdc.sh"), "a") as f:
                            f.write("\n/usr/sbin/kadmin.local -q \"ktadd -k "
                                    "/var/keytabs/hdfs.keytab {}/{}.example.com\"\n".format(user, service))

        # Add a restart file
        with open(os.path.join(self.output_dir, "restart-{}.sh".format(service)), "w") as f:
            f.write("#!/bin/bash -x\n")
            f.write("DOCKER_COMPOSE_PATH={}\n".format(self.output_dir))
            f.write("DHIVE_CONFIG_FILE={} make generate assure-all\n".format(self.config_file))
            f.write("docker rm -f {}.example || true\n".format(service))
            f.write("docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml build " + service + "\n")

            last_part = "--name {0}.example --detach --entrypoint /{0}.sh --rm {0}\n".format(service)
            f.write("docker-compose -f ${DOCKER_COMPOSE_PATH}/docker-compose.yml run " + last_part)

        # Add a yml in services
        yml_dir = os.path.join(self.output_dir, "services")
        with open(os.path.join(yml_dir, "{}.yml".format(service)), "w") as f:
            f.write(
"""
{0}:
  container_name: {0}.example
  hostname: {0}.example.com
  user: hdfs
  entrypoint: /{0}.sh
  build:
    context: ./containers/base
    args:
      - http_proxy
      - https_proxy
  volumes:
    - server-keytab:/var/keytabs
""".format(service))

        # Enable retrieving logs
        scripts_dir = os.path.join(self.output_dir, "scripts")
        # TODO

    def _populate_configuration_module(self, config, service):
        if service in config:
            file_name = os.path.join(self.CONFIG_DIRECTORY, service + "-site.xml")
            for name, value in config.items(service):
                remove_property_if_exits(file_name, name)
                write_property(file_name, name, value)

    def generate_build(self, config):
        shutil.rmtree(self.output_dir, ignore_errors=True)
        os.makedirs(self.output_dir)

        template_loader = jinja2.FileSystemLoader(searchpath="./")
        template_env = jinja2.Environment(loader=template_loader)

        for source_file in glob.iglob(ROOT_DIR + '/**', recursive=True):

            if source_file == ROOT_DIR + '/':
                continue

            dest_file = os.path.join(self.output_dir, source_file[len(ROOT_DIR) + 1:])

            if os.path.isdir(source_file):
                os.mkdir(dest_file)
                continue

            template = template_env.get_template(source_file)
            rendered = template.render(**config[GLOBAL_SECTION])

            with open(dest_file, "w") as dest:
                dest.write(rendered)

    def set_permissions(self):
        for source_file in glob.iglob(self.output_dir + '/**', recursive=True):
            if os.path.isdir(source_file):
                continue

            # rx permission if it's a bash file r otherwise
            if source_file.endswith(".sh"):
                os.chmod(source_file, 0o555)
            else:
                os.chmod(source_file, 0o444)

    def generate_docker_compose(self, config):
        compose_template = yaml.load(self.template)

        compose_template["services"] = {}

        for module in config["services"]["services"].split(","):
            module_file = os.path.join(self.MODULE_DIRECTORY, module + ".yml")
            if not os.path.exists(module_file):
                raise Exception("The file {0}.yml should exist under "
                                "dhive/services for a module named {0}".format(module))

            with open(module_file) as f:
                module_yaml = yaml.safe_load(f)

            # There can be serveral containers in each module
            for container_name in module_yaml:
                module_yaml[container_name]["container_name"] = self.namespace \
                                                                + module_yaml[container_name]["container_name"]

                if "volumes" in module_yaml[container_name]:
                    volumes = []
                    for volume in module_yaml[container_name]["volumes"]:
                        if volume.startswith("server-keytab"):
                            volumes.append(self.namespace + volume)
                        else:
                            volumes.append(volume)
                    module_yaml[container_name]["volumes"] = volumes

                if "depends_on" in module_yaml[container_name]:
                    depends_on = []
                    for depend in module_yaml[container_name]["depends_on"]:
                        depends_on.append(self.namespace + depend)
                    module_yaml[container_name]["depends_on"] = depends_on

                if "links" in module_yaml[container_name]:
                    links = []
                    for link in module_yaml[container_name]["links"]:
                        links.append(self.namespace + link)
                    module_yaml[container_name]["links"] = links

                if container_name in self.ports_yaml:
                    ports = self.ports_yaml[container_name]
                    module_yaml[container_name]["ports"] = []
                    for port in ports:
                        if port not in module_yaml[container_name]["ports"]:
                            module_yaml[container_name]["ports"].append(port)

                module_yaml[container_name]["hostname"] = self.namespace + container_name + ".example." + self.namespace + "com"

                compose_template["services"][self.namespace + container_name] = module_yaml[container_name]

        output = yaml.dump(compose_template, default_flow_style=False)

        with open(self.DOCKER_COMPOSE_FILE, "w") as f:
            f.write(output)

    def generate_external_modules(self, config):
        for service in config:
            if not self._is_standard_module(service):
                self.generate_external_module(config, service)

    def replace_hostnames(self):
        if self.namespace:
            with open(self.DOCKER_COMPOSE_FILE, "r") as f:
                output_dockerfile = yaml.safe_load(f)

            for service in output_dockerfile["services"]:
                original_service = service.replace(self.namespace, "")
                self.replace_single_hostname(original_service)

    def replace_single_hostname(self, service):
        replace = service + ".example.com"
        replacement = self.namespace + service + ".example." + self.namespace + "com"
        for dname, dirs, files in os.walk(self.output_dir):
            for fname in files:
                fpath = os.path.join(dname, fname)
                with open(fpath) as f:
                    s = f.read()
                s = s.replace(replace, replacement)
                with open(fpath, "w") as f:
                    f.write(s)

    def setup_kerberos(self):
        if self.namespace:
            path = os.path.join(self.output_dir, "containers/base/docker_scripts/common.sh")
            with open(path) as f:
                s = f.read()

            replace = "#!/usr/bin/env bash"
            replacement = """#!/usr/bin/env bash


sudo sed -i -e 's/kerberos.example.com/{0}kerberos.example.{0}com/' /etc/krb5.conf
sudo sed -i -e 's/example.com/example.{0}com/' /etc/krb5.conf
""".format(self.namespace)
            s = s.replace(replace, replacement)
            with open(path, "w") as f:
                f.write(s)

    def generate(self):
        config = self.parse_config()
        self.generate_build(config)
        self.populate_configuration(config)
        self.generate_external_modules(config)
        self.generate_docker_compose(config)
        self.replace_hostnames()
        self.setup_kerberos()
        self.set_permissions()

    def parse_config(self):
        config = configparser.ConfigParser(interpolation=configparser.ExtendedInterpolation())
        config.optionxform = str
        config.read(self.config_file)
        return config

    def _is_standard_module(self, name):
        return not name.startswith("external_")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate deployment files')

    if "DHIVE_CONFIG_FILE" in os.environ and os.environ["DHIVE_CONFIG_FILE"]:
        default_config = os.environ["DHIVE_CONFIG_FILE"]
    else:
        default_config = "config/vars.cfg"

    if "PORT_CONFIG_FILE" in os.environ and os.environ["PORT_CONFIG_FILE"]:
        default_config_port = os.environ["PORT_CONFIG_FILE"]
    else:
        default_config_port = "config/ports.yml"

    parser.add_argument('--config-file', type=str, default=default_config, help="config file")
    parser.add_argument('--port-file', type=str, default=default_config_port, help="ports file")
    parser.add_argument('--output-dir', type=str, default="build", help="directory where the files are generated")
    parser.add_argument('--namespace', type=str, default="", help="prefix to append to all the names")
    args = parser.parse_args()

    Generator(args.config_file, args.port_file, args.output_dir, args.namespace).generate()
