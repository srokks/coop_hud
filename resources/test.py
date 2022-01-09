import xmltodict
with open('stringtable.sta','r') as f:
    str_xml = f.read()

b = xmltodict.parse(str_xml)
category = b['stringtable']['category'][1]  # items
for el in category.keys():

print(category['key'][0]['@name'],category['key'][0]['string'])
