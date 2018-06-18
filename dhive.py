import glob
import configparser
import os
import jinja2
import shutil
import yaml
import argparse

from utils import remove_property_if_exits, write_property

ROOT_DIR = "dhive"
GLOBAL_SECTION = "global"


class Generator(object):
    def __init__(self, config_file, output_dir):
        self.config_file = config_file
        self.output_dir = output_dir
        self.CONFIG_DIRECTORY = os.path.join(self.output_dir, "containers/base/conf")
        self.MODULE_DIRECTORY = os.path.join(self.output_dir, "services")
        self.DOCKER_COMPOSE_FILE = os.path.join(self.output_dir, "docker-compose.yml")

    def populate_configuration(self, config):
        self._populate_configuration_module(config, "core")
        self._populate_configuration_module(config, "hdfs")
        self._populate_configuration_module(config, "yarn")
        self._populate_configuration_module(config, "tez")
        self._populate_configuration_module(config, "hive")

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

    template = \
    """
    version: "2"
    services:
    
    networks:
      default:
        external:
          name: com
    
    volumes:
      server-keytab:
    """

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
                compose_template["services"][container_name] = module_yaml[container_name]

        output = yaml.dump(compose_template, default_flow_style=False)

        with open(self.DOCKER_COMPOSE_FILE, "w") as f:
            f.write(output)

    def generate(self):
        config = self.parse_config()
        self.generate_build(config)
        self.populate_configuration(config)
        self.generate_docker_compose(config)
        self.set_permissions()

    def parse_config(self):
        config = configparser.ConfigParser()
        config.optionxform = str
        config.read(self.config_file)
        return config


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate deployment files')

    if "CONFIG_FILE" in os.environ and os.environ["CONFIG_FILE"]:
        default_config = os.environ["CONFIG_FILE"]
    else:
        default_config = "vars.config"

    parser.add_argument('--config-file', type=str, default=default_config, help="config file")
    parser.add_argument('--output-dir', type=str, default="build", help="directory where the files are generated")
    args = parser.parse_args()

    Generator(args.config_file, args.output_dir).generate()
