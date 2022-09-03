---@class langAPI used for getting items names and descriptions after introducing new language system by devs with no API functions

---@type langAPI
local langAPI = {}
---@private
langAPI.table = include('helpers.langAPI_tables.lua')
---@private
langAPI.lang_index = 0
---Sets language index for lang tables -  based on setting
---@private
function langAPI.setLangIndex()
	local lang_codes = { en = 0, jp = 2, es = 4, de = 5, ru = 10, kr = 11, zh = 13 }
	langAPI.lang_index = tonumber(langAPI.table.languages[lang_codes[Options.Language]].index)
end
langAPI.setLangIndex()
---Returns pocket name/description based on code name
---@param code_name string
---@return string
function langAPI.getItemName(code_name)
	return langAPI.table.category.Items[code_name][langAPI.lang_index]
end
---Returns item name based on given code id
---@param id number
---@return string
function langAPI.getItemNameByID(id)
	local name = Isaac.GetItemConfig():GetCollectible(id).Name
	name = string.sub(name, 2) --  get rid of # on front of
	return langAPI.table.category.Items[name][langAPI.lang_index]
end
---Returns pocket name/description based on code name
---@param code_name string
---@return string
function langAPI.getPocketName(code_name)
	return langAPI.table.category.PocketItems[code_name][langAPI.lang_index]
end
return langAPI