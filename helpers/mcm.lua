function coopHUD.add_mcm_entries()
	if ModConfigMenu then
		local mod_name = "Coop HUD"
		--[[ = DEBUG: Used to reset the config, remove on retail.
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
        --]]
		ModConfigMenu.AddSpace(mod_name, "Info")
		ModConfigMenu.AddText(mod_name, "Info", mod_name)
		ModConfigMenu.AddSpace(mod_name, "Info")
		ModConfigMenu.AddText(mod_name, "Info", "Version " .. coopHUD.VERSION)
		ModConfigMenu.AddSpace(mod_name, "Info")
		ModConfigMenu.AddText(mod_name, "Info", "created by Srokks")
		ModConfigMenu.AddTitle(mod_name, "General", "General")
		-- SHOW HUD
		ModConfigMenu.AddSetting(mod_name, "General", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.onRender
			end,
			Default        = coopHUD.options.onRender,

			Display        = function()
				local onOff = "off"
				if coopHUD.options.onRender then
					onOff = "on"
				end

				return "Show coopHUD: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.onRender = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				local TotalText = "Turn on/off coopHUD. Toggled by 'H' on keyboard"
				return TotalText
			end
		})
		-- h trigger key
		local hotkeyToString = InputHelper.KeyboardToString
		ModConfigMenu.AddSetting(mod_name, "General", {
			Type           = ModConfigMenu.OptionType.KEYBIND_KEYBOARD,
			CurrentSetting = function()
				return coopHUD.options.h_trigger_key
			end,
			Display        = function()
				local key = "None"
				if (hotkeyToString[coopHUD.options.h_trigger_key]) then
					key = hotkeyToString[coopHUD.options.h_trigger_key]
				end
				return 'Toggle HUD' .. ": " .. key
			end,
			OnChange       = function(currentNum)
				coopHUD.options.h_trigger_key = currentNum or -1
				coopHUD.save_options()
			end,
			PopupGfx       = ModConfigMenu.PopupGfx.WIDE_SMALL,
			PopupWidth     = 280,
			Popup          = function()
				local currentValue = coopHUD.options.h_trigger_key
				local keepSettingString = ""
				if currentValue > -1 then
					local currentSettingString = hotkeyToString[currentValue]
					keepSettingString = "This setting is currently set to \"" .. currentSettingString .. "\".$newlinePress this button to keep it unchanged.$newline$newline"
				end
				return "Press a button on your keyboard to change this setting.$newline$newline" .. keepSettingString .. "Press ESC to go back and clear this setting."
			end,
			Info           = function()
				return "Press this key to toggle coopHUD"
			end
		})
		-- Force small
		ModConfigMenu.AddSetting(mod_name, "General", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.force_small_hud
			end,
			Default        = coopHUD.options.force_small_hud,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.force_small_hud then
					onOff = "On"
				end

				return "Force small hud: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.force_small_hud = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return 'Force small (compacted) player HUD in < 2 players'
			end
		})
		-- Timer always on setting
		ModConfigMenu.AddSetting(mod_name, "General", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.timer_always_on
			end,
			Default        = coopHUD.options.timer_always_on,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.timer_always_on then
					onOff = "On"
				end

				return "Timer always on: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.timer_always_on = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Timer toggle. Accesible by pressing 'T' on keyboard"
			end
		})
		-- Timer trigger key
		ModConfigMenu.AddSetting(mod_name, "General", {
			Type           = ModConfigMenu.OptionType.KEYBIND_KEYBOARD,
			CurrentSetting = function()
				return coopHUD.options.timer_trigger
			end,
			Display        = function()
				local key = "None"
				if (hotkeyToString[coopHUD.options.timer_trigger]) then
					key = hotkeyToString[coopHUD.options.timer_trigger]
				end
				return 'Toggle timer key' .. ": " .. key
			end,
			OnChange       = function(currentNum)
				coopHUD.options.timer_trigger = currentNum or -1
				coopHUD.save_options()
			end,
			PopupGfx       = ModConfigMenu.PopupGfx.WIDE_SMALL,
			PopupWidth     = 280,
			Popup          = function()
				local currentValue = coopHUD.options.timer_trigger
				local keepSettingString = ""
				if currentValue > -1 then
					local currentSettingString = hotkeyToString[currentValue]
					keepSettingString = "This setting is currently set to \"" .. currentSettingString .. "\".$newlinePress this button to keep it unchanged.$newline$newline"
				end
				return "Press a button on your keyboard to change this setting.$newline$newline" .. keepSettingString .. "Press ESC to go back and clear this setting."
			end,
			Info           = function()
				return "Press this key to toggle coopHUD"
			end
		})
		-- Show RunInfos
		ModConfigMenu.AddSetting(mod_name, "General", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.show_run_info
			end,
			Default        = coopHUD.options.show_run_info,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.show_run_info then
					onOff = "On"
				end

				return "Show run info: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.show_run_info = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Show run info such as achievement lock/destination (only with timer)"
			end
		})
		-- Show player name
		ModConfigMenu.AddSetting(mod_name, "General", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.show_player_names
			end,
			Default        = coopHUD.options.show_player_names,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.show_player_names then
					onOff = "On"
				end

				return "Show player name: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.show_player_names = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Show  name under player"
			end
		})
		-- SCALING
		ModConfigMenu.AddSetting(mod_name, "General", {
			Type           = ModConfigMenu.OptionType.NUMBER,
			CurrentSetting = function()
				return coopHUD.options.hud_scale
			end,
			Default        = coopHUD.options.hud_scale,
			Minimum        = 0.1,
			Maximum        = 1.50,
			ModifyBy       = 0.05,
			Display        = function()
				return "HUD scaling: " .. coopHUD.options.hud_scale * 100 .. "%"
			end,
			OnChange       = function(currentNum)
				coopHUD.options.hud_scale = currentNum
				coopHUD.save_options()
			end,
			Info           = function()
				return "Set custom HUD scaling"
			end
		})
		-- __ Stats
		ModConfigMenu.AddTitle(mod_name, 'Stats', 'Stats')
		-- stats.show
		ModConfigMenu.AddSetting(mod_name, "Stats", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.stats.show
			end,
			Default        = coopHUD.options.stats.show,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.stats.show then
					onOff = "On"
				end

				return "Show stats: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.stats.show = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Shows stats like Vanilla FoundHud"
			end
		})
		-- stats.hide_in_battle
		ModConfigMenu.AddSetting(mod_name, "Stats", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.stats.hide_in_battle
			end,
			Default        = coopHUD.options.stats.hide_in_battle,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.stats.hide_in_battle then
					onOff = "On"
				end

				return "Hide on battle: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.stats.hide_in_battle = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Hides stats while in battle"
			end
		})
		-- stats.force show
		ModConfigMenu.AddSetting(mod_name, "Stats", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.stats.force_show
			end,
			Default        = coopHUD.options.stats.force_show,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.stats.force_show then
					onOff = "On"
				end

				return "Force show: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.stats.force_show = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Force to show stats on map button when battle"
			end
		})
		-- Deals
		ModConfigMenu.AddTitle(mod_name, 'Stats', 'Deals')
		-- show deals
		ModConfigMenu.AddSetting(mod_name, "Stats", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.deals.show
			end,
			Default        = coopHUD.options.deals.show,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.deals.show then
					onOff = "On"
				end

				return "Show deals chance: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.deals.show = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Shows deal chances"
			end
		})
		-- deals position
		ModConfigMenu.AddSetting(mod_name, "Stats", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.deals.vanilla_position
			end,
			Default        = coopHUD.options.deals.vanilla_position,

			Display        = function()
				local onOff = "coopHUD"
				if coopHUD.options.deals.vanilla_position then
					onOff = "Vanilla"
				end

				return "Deals position: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.deals.vanilla_position = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Deals chance position"
			end
		})
		-- show planetarium
		ModConfigMenu.AddSetting(mod_name, "Stats", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.deals.show_planetarium
			end,
			Default        = coopHUD.options.deals.show_planetarium,
			Display        = function()
				local onOff = "Off"
				if coopHUD.options.deals.show_planetarium then
					onOff = "On"
				end
				return "Show planetarium chance: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.deals.show_planetarium = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Show planetarium chances"
			end
		})
		-- hide deals in battle
		ModConfigMenu.AddSetting(mod_name, "Stats", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.deals.hide_in_battle
			end,
			Default        = coopHUD.options.deals.hide_in_battle,
			Display        = function()
				local onOff = "Off"
				if coopHUD.options.deals.hide_in_battle then
					onOff = "On"
				end
				return "Hide chance in battle: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.deals.hide_in_battle = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Hide chances while in battle"
			end
		})
		-- __ ExtraHUD(items)
		ModConfigMenu.AddTitle(mod_name, 'ExtraHUD', 'General')
		-- show extra hud
		ModConfigMenu.AddSetting(mod_name, "ExtraHUD", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.extra_hud
			end,
			Default        = coopHUD.options.extra_hud,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.extra_hud then
					onOff = "On"
				end

				return "Extra HUD: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.extra_hud = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return 'Show collected collectibles. While in co-op hold MAP button'
			end
		})
		-- reload collectibles
		ModConfigMenu.AddSetting(mod_name, "ExtraHUD", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function() return true end,
			Default        = coopHUD.options.extra_hud,

			Display        = function() return "---> Refresh collectibles <---" end,
			OnChange       = function(currentBool)
				coopHUD.Player.refresh_all_collectibles()
			end,
			Info           = { "Press this to refresh all players collectibles" }
		})
		-- hide extra hud in battle
		ModConfigMenu.AddSetting(mod_name, "ExtraHUD", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.extra_hud_hide_on_battle
			end,
			Default        = coopHUD.options.extra_hud_hide_on_battle,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.extra_hud_hide_on_battle then
					onOff = "On"
				end

				return "Hide on battle: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.extra_hud_hide_on_battle = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Hides collectibles while in battle"
			end
		})
		-- PLAYERS NAME/HEAD
		ModConfigMenu.AddSetting(mod_name, "ExtraHUD", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.render_player_info
			end,
			Default        = coopHUD.options.force_small_hud,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.render_player_info then
					onOff = "On"
				end

				return "Render HUD player indicators: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.render_player_info = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				local TotalText
				if coopHUD.options.render_player_info then
					TotalText = "There will be character indicator and player name in hud"
				else
					TotalText = "No player indicator Vanilla like"
				end
				return TotalText
			end
		})
		-- __ Players
		ModConfigMenu.AddTitle(mod_name, "Colors", 'General')
		-- .player_info_color
		ModConfigMenu.AddSetting(mod_name, "Colors", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.player_info_color
			end,
			Default        = coopHUD.options.player_info_color,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.player_info_color then
					onOff = "On"
				end

				return "Colorful HUD: " .. onOff
			end,
			OnChange       = function(currentBool)
				coopHUD.options.player_info_color = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Player info/stats will be colorfull"
			end
		})
		-- colorful players
		ModConfigMenu.AddSetting(mod_name, "Colors", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.colorful_players
			end,
			Default        = coopHUD.options.colorful_players,

			Display        = function()
				local onOff = "Off"
				if coopHUD.options.colorful_players then
					onOff = "On"
				end

				return "Colorful players: " .. onOff
			end,
			OnChange       = function(currentBool)
				if not currentBool then
					coopHUD.options.color_player_names = false
				end
				coopHUD.options.colorful_players = currentBool
				coopHUD.save_options()
			end,
			Info           = function()
				return "Colors players modules"
			end
		})
		-- colorful stuff page
		--[[ModConfigMenu.AddSetting(mod_name, "Colors", {
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.options.colorful_stuff_page
			end,
			Default = coopHUD.options.colorful_stuff_page,

			Display = function()
				local onOff = "Off"
				if coopHUD.options.colorful_stuff_page then
					onOff = "On"
				end

				return "Colorful stuff page: " .. onOff
			end,
			OnChange = function(currentBool)
				coopHUD.options.colorful_stuff_page = currentBool
				coopHUD.save_options()
			end,
			Info = function()
				return "Colors stuff page"
			end
		})]]
		-- player config - players colors
		ModConfigMenu.AddTitle(mod_name, "Colors", 'Player colors')
		for i = 0, 3 do
			ModConfigMenu.AddSetting(mod_name, "Colors", {
				Type           = ModConfigMenu.OptionType.NUMBER,
				CurrentSetting = function()
					return coopHUD.players_config.small[i].color
				end,
				Minimum        = 1,
				Maximum        = #coopHUD.colors,
				Display        = function()
					return "Player " .. tostring(i + 1) .. ": " .. coopHUD.colors[coopHUD.players_config.small[i].color].name
				end,
				OnChange       = function(currentNum)
					coopHUD.players_config.small[i].color = currentNum
					coopHUD.save_options()
				end,
				Info           = "Change player color color"
			})
		end
		--
		ModConfigMenu.AddTitle(mod_name, "Positions", 'Big HUD  positions:')
		ModConfigMenu.AddSetting(mod_name, "Positions", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.players_config.small[0].anchor_top == 'top_left'
			end,
			Display        = function()
				local anchor_string = ""
				if coopHUD.players_config.small[0].anchor_top == 'top_left' then
					anchor_string = "left side"
				else
					anchor_string = "right side"
				end
				return "Player 1: " .. anchor_string
			end,
			OnChange       = function(currentBool)
				if currentBool then
					coopHUD.players_config.small[0].anchor_top = coopHUD.players_config.default[0].anchor_top
					coopHUD.players_config.small[0].anchor_bot = coopHUD.players_config.default[0].anchor_bot
					coopHUD.players_config.small[0].mirrored_big = coopHUD.players_config.default[0].mirrored_big
					--
					coopHUD.players_config.small[1].anchor_top = coopHUD.players_config.default[1].anchor_top
					coopHUD.players_config.small[1].anchor_bot = coopHUD.players_config.default[1].anchor_bot
					coopHUD.players_config.small[1].mirrored_big = coopHUD.players_config.default[1].mirrored_big
				else
					coopHUD.players_config.small[0].anchor_top = coopHUD.players_config.default[1].anchor_top
					coopHUD.players_config.small[0].anchor_bot = coopHUD.players_config.default[1].anchor_bot
					coopHUD.players_config.small[0].mirrored_big = coopHUD.players_config.default[1].mirrored_big
					--
					coopHUD.players_config.small[1].anchor_top = coopHUD.players_config.default[0].anchor_top
					coopHUD.players_config.small[1].anchor_bot = coopHUD.players_config.default[0].anchor_bot
					coopHUD.players_config.small[1].mirrored_big = coopHUD.players_config.default[0].mirrored_big
				end
				coopHUD.save_options()
			end,
			Info           = function()
				return "Sets player position on big hud"
			end
		})
		ModConfigMenu.AddSetting(mod_name, "Positions", {
			Type           = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return coopHUD.players_config.small[1].anchor_top == 'top_right'
			end,
			Display        = function()
				local anchor_string = ""
				if coopHUD.players_config.small[1].anchor_top == 'top_left' then
					anchor_string = "left side"
				else
					anchor_string = "right side"
				end
				return "Player 2: " .. anchor_string
			end,
			OnChange       = function(currentBool)
				if currentBool then
					coopHUD.players_config.small[0].anchor_top = coopHUD.players_config.default[0].anchor_top
					coopHUD.players_config.small[0].anchor_bot = coopHUD.players_config.default[0].anchor_bot
					coopHUD.players_config.small[0].mirrored_big = coopHUD.players_config.default[0].mirrored_big
					--
					coopHUD.players_config.small[1].anchor_top = coopHUD.players_config.default[1].anchor_top
					coopHUD.players_config.small[1].anchor_bot = coopHUD.players_config.default[1].anchor_bot
					coopHUD.players_config.small[1].mirrored_big = coopHUD.players_config.default[1].mirrored_big
				else
					coopHUD.players_config.small[0].anchor_top = coopHUD.players_config.default[1].anchor_top
					coopHUD.players_config.small[0].anchor_bot = coopHUD.players_config.default[1].anchor_bot
					coopHUD.players_config.small[0].mirrored_big = coopHUD.players_config.default[1].mirrored_big
					--
					coopHUD.players_config.small[1].anchor_top = coopHUD.players_config.default[0].anchor_top
					coopHUD.players_config.small[1].anchor_bot = coopHUD.players_config.default[0].anchor_bot
					coopHUD.players_config.small[1].mirrored_big = coopHUD.players_config.default[0].mirrored_big
				end
				coopHUD.save_options()
			end,
			Info           = function()
				return "Sets player position on big hud"
			end
		})
		-- TODO:COOP-61 small hud customizable positions https://coophud.atlassian.net/browse/COOP-61
		-- DEBUG: until finished only for debuging
		--[[ModConfigMenu.AddTitle(mod_name, "Positions", 'Small HUD positions')
		ModConfigMenu.AddSetting(mod_name, "Positions", {
			Type           = ModConfigMenu.OptionType.NUMBER,
			CurrentSetting = function()
				return coopHUD.anchors[coopHUD.players_config.small[0].anchor .. '_id']
			end,
			Minimum        = 0,
			Maximum        = 3,
			Display        = function()
				return "Player 1: " .. coopHUD.anchors[coopHUD.players_config.small[0].anchor .. '_name']
			end,
			OnChange       = function(currentNum)
				coopHUD.players_config.small[0].anchor = coopHUD.players_config.default[currentNum].anchor
				coopHUD.players_config.small[0].mirrored = coopHUD.players_config.default[currentNum].mirrored
				coopHUD.players_config.small[0].down_anchor = coopHUD.players_config.default[currentNum].down_anchor
				coopHUD.save_options()
			end,
			Info           = function()
				return "Sets player position on small hud"
			end
		})
		--]]
	end
end
