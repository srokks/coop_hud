from markdown_to_steam_bb import markdown_to_steam_bb
import xml.etree.ElementTree as ElementTree
from bs4 import BeautifulSoup


def prepare_clean_xml_tree():
    root = ElementTree.Element('metadata')

    name = ElementTree.Element('name')
    name.text = 'NAME PLACEHOLDER'
    root.append(name)

    directory = ElementTree.Element('directory')
    directory.text = 'DIR_PLACEHOLDER'
    root.append(directory)

    _id = ElementTree.Element('id')
    _id.text = ' '
    root.append(_id)

    description = ElementTree.Element('description')
    description.text = 'DESC_PLACEHOLDER'
    root.append(description)

    version = ElementTree.Element('version')
    version.text = 'VERSION_PLACEHOLDER'
    root.append(version)

    visibility = ElementTree.Element('visibility')
    visibility.text = 'VERSION_PLACEHOLDER'
    root.append(visibility)

    tree = ElementTree.ElementTree(root)
    return tree


def get_mod_info_dict(debug=False):
    def get_name():
        with open('../coopHUD_globals.lua') as f:
            version_line = f.readlines(1)[0]
        if 'coopHUD.VERSION' in version_line:
            version_line = version_line.split('=')[1]
            version_line = version_line.replace("'", '')  # removes '
            _version, _code = version_line.split('-')
            return _version.lstrip(' '), _code[:-1]
        else:
            print('WRONG coopHUD_globals.lua structure')
            print('Version line should be fist!')
            return '', ''

    def get_description():
        with open('../readme.md') as f:
            markdown_string = f.read()
            soup = BeautifulSoup(markdown_string, 'html.parser')
            markdown_string = soup.find("div", {"id": "description"}).text
        steam_string = markdown_to_steam_bb(markdown_string)
        steam_string = '\n' + '\n'.join([' ' * 8 + line for line in steam_string.splitlines()])
        return steam_string

    def get_change_log():
        with open('../readme.md') as f:
            markdown_string = f.read()
            soup = BeautifulSoup(markdown_string, 'html.parser')
            markdown_string = soup.find("div", {"id": "new-features"}).text
        new_features_str = markdown_to_steam_bb(markdown_string)
        new_features_str = '\n' + '\n'.join([' ' * 8 + line for line in new_features_str.splitlines()])
        return new_features_str

    version, code = get_name()
    mod_id = '' if debug else '2731267631'
    mod_info_dict = {
        'name': f'coopHUD *{code}*',
        'id': mod_id,
        'directory': 'coop_hud' if debug else f'coop_hud_{mod_id}',
        'description': get_description() + '\n' + get_change_log(),
        'version': version,
        'visibility': 'Private' if debug else 'Public',
        'tags': ['Lua', 'Tweaks', 'Graphics']
    }
    return mod_info_dict


def update_xml_file(xml_path, debug=False):
    xml_tree = prepare_clean_xml_tree()
    mod_info = get_mod_info_dict(debug)
    root = xml_tree.getroot()
    for el in root:
        if mod_info.get(el.tag):
            el.text = mod_info.get(el.tag)
    for tag in mod_info.get('tags'):
        tag_el = ElementTree.Element('tag')
        tag_el.attrib = {'id': tag}
        root.append(tag_el)
    ElementTree.indent(xml_tree, ' ' * 4)
    xml_tree.write(xml_path, method='xml', xml_declaration=True, encoding='UTF-8')
    print(f'{xml_path} updated successfully!')


if __name__ == '__main__':
    update_xml_file('../metadata.xml', False)
