---@class langAPI used for getting items names and descriptions after introducing new language system by devs with no API functions
---@field lang_index number in game index of language, takes setting from game options
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
---Returns item description based on given code id
---@param id number
---@return string
function langAPI.getItemDescByID(id)
	local desc = Isaac.GetItemConfig():GetCollectible(id).Description
	desc = string.sub(desc, 2) --  get rid of # on front of
	return langAPI.table.category.Items[desc][langAPI.lang_index]
end
---Returns pocket name/description based on code name
---@private
---@param code_name string
---@return string
function langAPI.getPocketName(code_name)
	return langAPI.table.category.PocketItems[code_name][langAPI.lang_index]
end
---Returns card name based on card id
---@param id
---@return string
function langAPI.getCardNameByID(id)
	local card = Isaac.GetItemConfig():GetCard(id)
	local name, subs = string.gsub(card.Name, "#", "")
	if subs > 0 then
		return langAPI.getPocketName(name)
	else
		return name
	end
end
---Returns card desc based on card id
---@param id number
---@return string
function langAPI.getCardDescByID(id)
	local card = Isaac.GetItemConfig():GetCard(id)
	local name, subs = string.gsub(card.Description, "#", "")
	if subs > 0 then
		return langAPI.getPocketName(name)
	else
		return name
	end
end
---Returns pill name based on card id
---@param pill_effect number
---@return string
function langAPI.getPillNameByEffect(pill_effect)
	local pillEffect = Isaac.GetItemConfig():GetPillEffect(pill_effect)
	local name, subs = string.gsub(pillEffect.Name, "#", "")
	if subs > 0 then
		return langAPI.getPocketName(name)
	else
		return name
	end
end
---Returns code name of transformation. Except flight(cannot get from stringtable.sta, no hardcoded)
---@private
---@param player_form number PlayerForm
---@return string code name of transformation for fiven player from
function langAPI.getTransformationCodename(player_form)
	local player_form_to_codename = {
		[PlayerForm.PLAYERFORM_GUPPY]             = "TRANSFORMATION_GUPPY",
		[PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES] = "TRANSFORMATION_BEELZEBUB",
		[PlayerForm.PLAYERFORM_MUSHROOM]          = "TRANSFORMATION_FUN_GUY",
		[PlayerForm.PLAYERFORM_ANGEL]             = "TRANSFORMATION_SERAPHIM",
		[PlayerForm.PLAYERFORM_BOB]               = "TRANSFORMATION_BOB",
		[PlayerForm.PLAYERFORM_DRUGS]             = "TRANSFORMATION_SPUN",
		[PlayerForm.PLAYERFORM_MOM]               = "TRANSFORMATION_YES_MOTHER",
		[PlayerForm.PLAYERFORM_BABY]              = "TRANSFORMATION_CONJOINED",
		[PlayerForm.PLAYERFORM_EVIL_ANGEL]        = "TRANSFORMATION_LEVIATHAN",
		[PlayerForm.PLAYERFORM_POOP]              = "TRANSFORMATION_OH_CRAP",
		[PlayerForm.PLAYERFORM_BOOK_WORM]         = "TRANSFORMATION_BOOK_WORM",
		[PlayerForm.PLAYERFORM_ADULTHOOD]         = "TRANSFORMATION_ADULT",
		[PlayerForm.PLAYERFORM_SPIDERBABY]        = "TRANSFORMATION_SPIDER_BABY",
		[PlayerForm.PLAYERFORM_STOMPY]            = "TRANSFORMATION_STOMPY",
		[PlayerForm.PLAYERFORM_FLIGHT]            = "Flight!" --FIXME:COOP-147: no flight in string tables
	}
	return player_form_to_codename[player_form]
end
---Returns transformation string in proper language
function langAPI.getTransformationString(player_form)
	local code_name = coopHUD.langAPI.getTransformationCodename(player_form)
	if code_name == nil then
		Isaac.DebugString('langAPI:ERROR: nil on PLAYERFORM:' .. tostring(player_form))
		return 'coopHUD:Error-more in debug log'
	else
		if code_name.find(code_name, 'TRANSFORMATION') then
			return langAPI.table.category.Default[code_name][langAPI.lang_index]
		else
			return code_name
		end
	end
end
return langAPI