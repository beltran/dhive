import glob
import configparser
import os
import jinja2
import shutil
import xml.etree.ElementTree as ET
from xml.dom import minidom
import io

ROOT_DIR = "dhive"
CONFIG_FILE = "vars.config"
OUTPUT_DIRECTORY = "build"
GLOBAL_SECION = "global"
CONFIG_DIRECTORY = os.path.join(OUTPUT_DIRECTORY, "containers/base/conf")


def populate_configuration(config):
    # Write extra hive properties
    if "hive" in config:
        hive_file_name = os.path.join(CONFIG_DIRECTORY, "hive-site.xml")
        for name, value in config["hive"].items():
            write_property(hive_file_name, name, value)

    # Write extra tez properties
    if "tez" in config:
        tez_file_name = os.path.join(CONFIG_DIRECTORY, "tez-site.xml")
        for name, value in config["tez"].items():
            write_property(tez_file_name, name, value)


def write_property(file_name, name, value):
    tree = ET.parse(file_name)
    root = tree.getroot()

    property_node = ET.Element("property")
    name_node = ET.SubElement(property_node, "name")
    value_node = ET.SubElement(property_node, "value")
    name_node.text = name
    value_node.text = value

    root.append(property_node)

    stream = io.StringIO()
    tree.write(stream, encoding="unicode")
    reparsed = minidom.parseString(stream.getvalue().replace("\n", "").replace(" ", ""))
    pretty_xml_as_string = reparsed.toprettyxml(indent="    ", newl="\n")

    # Remove the file because we may not be able to write
    # due to permissions
    os.remove(file_name)
    with open(file_name, 'w') as output:
        output.write(pretty_xml_as_string)


def generate_build(config):
    shutil.rmtree(OUTPUT_DIRECTORY, ignore_errors=True)
    os.makedirs(OUTPUT_DIRECTORY)

    template_loader = jinja2.FileSystemLoader(searchpath="./")
    template_env = jinja2.Environment(loader=template_loader)

    for source_file in glob.iglob(ROOT_DIR + '/**', recursive=True):

        if source_file == ROOT_DIR + '/':
            continue

        dest_file = os.path.join(OUTPUT_DIRECTORY, source_file[len(ROOT_DIR) + 1:])

        if os.path.isdir(source_file):
            os.mkdir(dest_file)
            continue

        template = template_env.get_template(source_file)
        rendered = template.render(**config[GLOBAL_SECION])

        with open(dest_file, "w") as dest:
            dest.write(rendered)


def set_permissions():
    for source_file in glob.iglob(OUTPUT_DIRECTORY + '/**', recursive=True):
        if os.path.isdir(source_file):
            continue

        # rx permission if it's a bash file r otherwise
        if source_file.endswith(".sh"):
            os.chmod(source_file, 0o555)
        else:
            os.chmod(source_file, 0o444)


def main():
    config = parse_config()
    generate_build(config)
    populate_configuration(config)
    set_permissions()


def parse_config():
    config = configparser.ConfigParser()
    config.read(CONFIG_FILE)
    return config


if __name__ == "__main__":
    main()
