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
	ModConfigMenu.AddSetting(mod_name, "Settings", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.onRender
		end,
		Default = coopHUD.onRender,
		
		Display = function()
			local onOff = "Disabled"
			if coopHUD.onRender then
				onOff = "Enabled"
			end
			
			return "show coopHUD: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.onRender = currentBool
		end,
		Info = function()
			local TotalText = "Turn on/off coopHUD"
			return TotalText
		end
	})
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
			local TotalText
			if coopHUD.options.force_small_hud then
				TotalText = "Small HUD will be used forced in 2 player mode"
			else
				TotalText = "Normal HUD will be used in 2 player mode"
			end
			return TotalText
		end
	})
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
end