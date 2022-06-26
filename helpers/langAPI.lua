local langAPI = {}
langAPI.table = include('helpers.langAPI_tables.lua')
langAPI.lang_index = 0
function langAPI.setLangIndex()
	local lang_codes = { en = 0, jp = 2, es = 4, de = 5, ru, kr = 11, zh = 13 }
	langAPI.lang_index = tonumber(langAPI.table.languages[lang_codes[Options.Language]].index)
end
langAPI.setLangIndex()
function langAPI.getItemName(code_name)
	return langAPI.table.category.Items[code_name][langAPI.lang_index]
end
function langAPI.getPocketName(code_name)
	return langAPI.table.category.PocketItems[code_name][langAPI.lang_index]
end
return langAPI