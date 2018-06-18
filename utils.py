import xml.etree.ElementTree as ET
from xml.dom import minidom
import io
import os


def remove_property_if_exits(file_name, name):
    tree = ET.parse(file_name)
    root = tree.getroot()

    to_remove = None
    for property in root:
        for child in property:
            if child.tag == "name" and child.text == name:
                to_remove = property

        if to_remove:
            break

    if to_remove:
        root.remove(to_remove)
    _write_tree(tree, file_name)


def write_property(file_name, name, value):
    if not value:
        return

    tree = ET.parse(file_name)
    root = tree.getroot()

    property_node = ET.Element("property")
    name_node = ET.SubElement(property_node, "name")
    value_node = ET.SubElement(property_node, "value")
    name_node.text = name
    value_node.text = value

    root.append(property_node)
    _write_tree(tree, file_name)


def _write_tree(tree, file_name):
    stream = io.StringIO()
    tree.write(stream, encoding="unicode")
    reparsed = minidom.parseString(stream.getvalue().replace("\n", "").replace(" ", ""))
    pretty_xml_as_string = reparsed.toprettyxml(indent="    ", newl="\n")

    # Remove the file because we may not be able to write
    # due to permissions
    os.remove(file_name)
    with open(file_name, 'w') as output:
        output.write(pretty_xml_as_string)
