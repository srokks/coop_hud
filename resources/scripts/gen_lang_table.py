def parse_lang_file():

    with open('stringtable.sta', 'r') as f:
        str_xml = f.read()
    import xmltodict
    lang_tree = xmltodict.parse(str_xml)['stringtable']
    return lang_tree


def parse_to_table():
    lang_tree = parse_lang_file()
    lang_table = {}
    for e in lang_tree:
        temp_a = e
        lang_table.update({e: {}})
    for key, val in lang_tree['info'].items():
        lang_table['info'].update({key: val})
    for a in lang_tree['languages']['language']:
        lang_table['languages'].update({int(a['@id']): a})
    for cat in lang_tree['category']:
        cat_name = cat['@name']
        lang_table['category'].update({cat_name: {}})
        for el in cat['key']:
            lang_table['category'][cat_name].update({el['@name']: el['string']})
    return lang_table


def genLuaTableFile():
    lang_table = parse_to_table()

    with open('langAPI_tables.lua', 'w') as f:
        f.write('--[[\n')
        f.write('Script parse stringtable.sta xml file from Isaac latest update to lua table used by langAPI mod\n')
        f.write('Created by Srokks -  https://github.com/srokks\n')
        f.write('--]]\n')
        f.write('langAPI.table = {\n')

        for main_cat in lang_table:
            if main_cat == 'info':
                f.write('\tinfo = {\n')
                for k, v in lang_table['info'].items():
                    f.write('\t\t')
                    f.write(k[1:] + ' = "' + v + '",\n')
                f.write('\t},\n')
            if main_cat == 'languages':
                f.write('\tlanguages = {\n')
                for k, v in lang_table['languages'].items():
                    f.write('\t\t')
                    f.write('[' + str(k) + '] = {\n')
                    nn = ['\t\t\t' + kk[1:] + ' = "' + vv + '",\n' for kk, vv in v.items()]
                    f.writelines(nn)
                    f.write('\t\t')
                    f.write('},\n')
                f.write('\t},\n')
            if main_cat == 'category':
                f.write('\tcategory = {\n')
                for k, v in lang_table['category'].items():
                    f.write('\t\t')
                    f.write(k + ' = {\n')
                    for n in v.keys():
                        f.write('\t\t\t')
                        if n[0].isdecimal():  # cheks for names with first digit and adds _ before
                            f.write('_')
                        if '?' in n:  # prevents ? in lua table key
                            f.write(n.replace('?','') + ' = {')
                        else:
                            f.write(n + ' = {')
                        for el in v[n]:
                            if el is not None:
                                if '"' in el:
                                    el = el.replace('"','')
                                f.write('"' + el +'",')
                        f.write('},\n')
                    f.write('\t\t')
                    f.write('},\n')
                f.write('\t},\n')
        f.write('}')


if __name__ == '__main__':
    genLuaTableFile()
