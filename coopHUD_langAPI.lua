coopHUD.langAPI = {}
include("coopHUD_langAPI_tables.lua")
coopHUD.langAPI.lang_index = 0
function coopHUD.langAPI.setLangIndex()
    local lang_codes = {en=0,jp=2,es=4,de=5,ru,kr=11,zh=13}
    coopHUD.langAPI.lang_index = tonumber(coopHUD.langAPI.table.languages[lang_codes[Options.Language]].index)
end
coopHUD.langAPI.setLangIndex()
function coopHUD.langAPI.getItemName(code_name)
    return coopHUD.langAPI.table.category.Items[code_name][coopHUD.langAPI.lang_index]
end
function coopHUD.langAPI.getPocketName(code_name)
    return coopHUD.langAPI.table.category.PocketItems[code_name][coopHUD.langAPI.lang_index]
end