if ModConfigMenu then
	local mod_name = "Coop HUD"
	--= Used to reset the config, remove on retail.
	--local categoryToChange = ModConfigMenu.GetCategoryIDByName(mod_name)
	--if categoryToChange then
	--	ModConfigMenu.MenuData[categoryToChange] = {}
	--	ModConfigMenu.MenuData[categoryToChange].Name = tostring(mod_name)
	--	ModConfigMenu.MenuData[categoryToChange].Subcategories = {}
	--end
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
				onOff = "True"
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
			local onOff = "off"
			if coopHUD.options.force_small_hud then
				onOff = "On"
			end
			
			return "show coopHUD: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.force_small_hud = currentBool
		end,
		Info = function()
			local TotalText
			if coopHUD.options.force_small_hud then
				TotalText = "Small HUD will be used in when < 2 players"
			else
				TotalText = "Normal HUD will be used in when < 2 players"
			end
			return TotalText
		end
	})
end