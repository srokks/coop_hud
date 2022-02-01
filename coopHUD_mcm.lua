local json = require("json")
if coopHUD:HasData() then
    local save = json.decode(coopHUD:LoadData())
    coopHUD.options = save.options
end
function coopHUD.save_options()
    local save =  {}
    save.options = coopHUD.options
    coopHUD:SaveData(json.encode(save))
end
coopHUD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT,coopHUD.save_options)
if ModConfigMenu then
	local mod_name = "Coop HUD"
	--= Used to reset the config, remove on retail.
	local categoryToChange = ModConfigMenu.GetCategoryIDByName(mod_name)
	if categoryToChange then
		ModConfigMenu.MenuData[categoryToChange] = {}
		ModConfigMenu.MenuData[categoryToChange].Name = tostring(mod_name)
		ModConfigMenu.MenuData[categoryToChange].Subcategories = {}
	end
	ModConfigMenu.UpdateCategory(mod_name, {
		Info = {
			"coopHUD Settings.",
		}
	})
	ModConfigMenu.AddTitle(mod_name, "Settings", "General")
	-- SHOW HUD
	ModConfigMenu.AddSetting(mod_name, "Settings", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.onRender
		end,
		Default = coopHUD.options.onRender,
		
		Display = function()
			local onOff = "Disabled"
			if coopHUD.options.onRender then
				onOff = "Enabled"
			end
			
			return "show coopHUD: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.onRender = currentBool
		end,
		Info = function()
			local TotalText = "Turn on/off coopHUD. Toggled by 'H' on keyboard"
			return TotalText
		end
	})
	-- Force small
	ModConfigMenu.AddSetting(mod_name, "Settings", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.force_small_hud
		end,
		Default = coopHUD.options.force_small_hud,
		
		Display = function()
			local onOff = "Off"
			if coopHUD.options.force_small_hud then
				onOff = "On"
			end
			
			return "Force small hud: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.force_small_hud = currentBool
		end,
		Info = function()
			return 'Force small (compacted) player HUD in < 2 players'
		end
	})
	-- PLAYERS NAME/HEAD
	ModConfigMenu.AddSetting(mod_name, "Settings", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.render_player_info
		end,
		Default = coopHUD.options.force_small_hud,
		
		Display = function()
			local onOff = "Off"
			if coopHUD.options.render_player_info then
				onOff = "On"
			end
			
			return "Render HUD player indicators: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.render_player_info = currentBool
		end,
		Info = function()
			local TotalText
			if coopHUD.options.render_player_info then
				TotalText = "Player head/name will be rendered in HUD"
			else
				TotalText = "No player indicator Vanilla like"
			end
			return TotalText
		end
	})
	-- Timer always on setting
	ModConfigMenu.AddSetting(mod_name, "Settings", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.timer_always_on
		end,
		Default = coopHUD.options.timer_always_on,
		
		Display = function()
			local onOff = "Off"
			if coopHUD.options.timer_always_on then
				onOff = "On"
			end
			
			return "Timer always on: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.timer_always_on = currentBool
		end,
		Info = function()
			return "Timer toggle. Accesible by pressing 'T' on keyboard"
		end
	})
end
-- Overrides External item description mod setting to better fit with HUD
if EID then
	if EID.UserConfig.YPosition < 80 then EID.UserConfig.YPosition = 80 end
end
-- Overrides Enhanced Boss Bars  mod setting to better fit with HUD
if HPBars then
	if HPBars.UserConfig.ScreenPadding < 24 then  HPBars.UserConfig.ScreenPadding = 24 end
end
-- Overrides MinimapAPI  mod setting to show on coopHUD
if MinimapAPI then
	if not MinimapAPI.Config.DisplayOnNoHUD  then  MinimapAPI.Config.DisplayOnNoHUD = true end
	if MinimapAPI:GetConfig('ShowLevelFlags') then
		MinimapAPI.Config.ShowLevelFlags = false
	end
end
