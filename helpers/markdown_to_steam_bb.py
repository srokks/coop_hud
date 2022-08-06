import re

indent_str = ' ' * 4


def markdown_to_steam_bb(md_string: str):
    new_file = []
    prev_line = ''
    indent = 0
    lines_table = md_string.splitlines()
    for no, line in enumerate(lines_table):
        cur_line = parse_line(line)
        next_line = None
        if cur_line is not None:
            if is_list_element(cur_line):
                # print(cur_line)
                pass
            # open list if cur is list el and prev was not
            if is_list_element(cur_line) and not is_list_element(prev_line):
                add_line(new_file, '[list]\n', indent)
                indent += 1
            # close list if cur is not lis but prev was
            if not is_list_element(cur_line) and is_list_element(prev_line):
                indent -= 1
                add_line(new_file, '[/list]', indent)
            if no + 1 < len(lines_table):  # sets next line
                next_line = parse_line(lines_table[no + 1])
            # if cur_line and prev_line are lists element
            if is_list_element(cur_line) and is_list_element(prev_line):
                if get_indent(prev_line) < get_indent(cur_line):
                    add_line(new_file, '[list]\n', indent)
                    indent += 1
                elif get_indent(prev_line) > get_indent(cur_line):
                    indent -= 1
                    add_line(new_file, '[/list]\n', indent)
            prev_line = cur_line
            cur_line = cur_line.lstrip()
            if cur_line:  # prevents from passing empty lines
                add_line(new_file, cur_line, indent)
            if no == len(lines_table) - 1 and indent > 0:
                indent -= 1
                add_line(new_file, '[/list]', indent)
    return ''.join(new_file)


def add_line(new_file, cur_line, indent):
    if cur_line[-1] != '\n':
        cur_line = cur_line + '\n'
    new_file.append(indent * indent_str + cur_line)


def get_indent(line: str):
    return len(line) - len(line.lstrip())


def is_list_element(line):
    return re.match(r'^.*\[\*].*$', line)


def parse_line(line):
    temp_line = line
    if temp_line == '\n':
        return None
    # [url=][/url]
    temp_line = re.sub(r'\[([^]]*)]\(([^)]*)\)', r' [url=\2]\1[/url] ', temp_line)
    # Headers
    temp_line = re.sub(r'^# (.*)', r'[h1]\1[/h1]', temp_line)
    temp_line = re.sub(r'^## (.*)', r'[h2]\1[/h2]', temp_line)
    temp_line = re.sub(r'^### (.*)', r'[h3]\1[/h3]', temp_line)
    # bold
    temp_line = re.sub(r'\*\*(.*)\*\*', r'[b]\1[/b]', temp_line)
    # underline
    temp_line = re.sub(r'<u>(.*)</u>', r'[u]\1[/u]', temp_line)
    # italic
    temp_line = re.sub(r' _(.*)_ ', r'[i]\1[/i]', temp_line)
    # strike
    temp_line = re.sub(r'~~(.*)~~', r'[strike]\1[/strike]', temp_line)
    # bottom line
    temp_line = re.sub(r'_{3}$', r'[hr][/hr]', temp_line)
    # list element
    temp_line = re.sub(r'^(.*)\*(.*)', r'\1[*]\2', temp_line)
    return temp_line
