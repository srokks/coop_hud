local json = require("json")
if coopHUD:HasData() then
	local save = json.decode(coopHUD:LoadData())
	if coopHUD.VERSION == save.version then
		coopHUD.players_config[0] = save.players_config['0']
		coopHUD.players_config[1] = save.players_config['1']
		coopHUD.players_config.small[0] = save.players_config.small['0']
		coopHUD.players_config.small[1] = save.players_config.small['1']
		coopHUD.players_config.small[2] = save.players_config.small['2']
		coopHUD.players_config.small[3] = save.players_config.small['3']
		coopHUD.options = save.options
	end
end
function coopHUD.save_options()
	local save = {}
	save.version = coopHUD.VERSION
	save.options = coopHUD.options
	save.players_config = coopHUD.players_config
	coopHUD:SaveData(json.encode(save))
end
coopHUD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, coopHUD.save_options)
if ModConfigMenu then
	local mod_name = "Coop HUD"
	--= Used to reset the config, remove on retail.
	local categoryToChange = ModConfigMenu.GetCategoryIDByName(mod_name)
	if categoryToChange then
		ModConfigMenu.MenuData[categoryToChange] = {}
		ModConfigMenu.MenuData[categoryToChange].Name = tostring(mod_name)
		ModConfigMenu.MenuData[categoryToChange].Subcategories = {}
	end
	--/
	ModConfigMenu.UpdateCategory(mod_name, {
		Info = {
			"coopHUD Settings.",
		}
	})
	--xw
	ModConfigMenu.AddSpace(mod_name, "Info")
	ModConfigMenu.AddText(mod_name, "Info", mod_name)
	ModConfigMenu.AddSpace(mod_name, "Info")
	ModConfigMenu.AddText(mod_name, "Info", "Version " .. coopHUD.VERSION)
	ModConfigMenu.AddSpace(mod_name, "Info")
	ModConfigMenu.AddText(mod_name, "Info", "created by Srokks")
	ModConfigMenu.AddTitle(mod_name, "General", "General")
	-- SHOW HUD
	ModConfigMenu.AddSetting(mod_name, "General", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.onRender
		end,
		Default = coopHUD.options.onRender,

		Display = function()
			local onOff = "off"
			if coopHUD.options.onRender then
				onOff = "on"
			end

			return "Show coopHUD: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.onRender = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			local TotalText = "Turn on/off coopHUD. Toggled by 'H' on keyboard"
			return TotalText
		end
	})
	-- Force small
	ModConfigMenu.AddSetting(mod_name, "General", {
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
			coopHUD.save_options()
		end,
		Info = function()
			return 'Force small (compacted) player HUD in < 2 players'
		end
	})
	-- PLAYERS NAME/HEAD
	ModConfigMenu.AddSetting(mod_name, "General", {
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
			coopHUD.save_options()
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
	ModConfigMenu.AddSetting(mod_name, "General", {
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
			coopHUD.save_options()
		end,
		Info = function()
			return "Timer toggle. Accesible by pressing 'T' on keyboard"
		end
	})
	-- __ Stats
	ModConfigMenu.AddTitle(mod_name, 'General', 'Stats')
	-- stats.show
	ModConfigMenu.AddSetting(mod_name, "General", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.stats.show
		end,
		Default = coopHUD.options.stats.show,

		Display = function()
			local onOff = "Off"
			if coopHUD.options.stats.show then
				onOff = "On"
			end

			return "Show stats: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.stats.show = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Shows stats like Vanilla FoundHud"
		end
	})
	-- stats.hide_in_battle
	ModConfigMenu.AddSetting(mod_name, "General", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.stats.hide_in_battle
		end,
		Default = coopHUD.options.stats.hide_in_battle,

		Display = function()
			local onOff = "Off"
			if coopHUD.options.stats.hide_in_battle then
				onOff = "On"
			end

			return "Hide on battle: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.stats.hide_in_battle = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Hides stats while in battle"
		end
	})

	-- __ Players
	ModConfigMenu.AddTitle(mod_name, "Colors", 'General')
	-- stats.colorful
	ModConfigMenu.AddSetting(mod_name, "Colors", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.stats.colorful
		end,
		Default = coopHUD.options.stats.colorful,

		Display = function()
			local onOff = "Off"
			if coopHUD.options.stats.colorful then
				onOff = "On"
			end

			return "Colorful stats: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.stats.colorful = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Colors stats according to player color"
		end
	})
	-- stats.colorful
	ModConfigMenu.AddSetting(mod_name, "Colors", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.player_info_color
		end,
		Default = coopHUD.options.player_info_color,

		Display = function()
			local onOff = "Off"
			if coopHUD.options.player_info_color then
				onOff = "On"
			end

			return "Colorful names: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.player_info_color = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Colors player pocket name/desc and name"
		end
	})
	-- player config - players colors
	ModConfigMenu.AddTitle(mod_name, "Colors", 'Player colors')
	for i = 0, 3 do
		ModConfigMenu.AddSetting(mod_name, "Colors", {
			Type = ModConfigMenu.OptionType.NUMBER,
			CurrentSetting = function()
				return coopHUD.players_config.small[i].color
			end,
			Minimum = 1,
			Maximum = #coopHUD.colors,
			Display = function()
				return "Player " .. tostring(i + 1) .. ": " .. coopHUD.colors[coopHUD.players_config.small[i].color].name
			end,
			OnChange = function(currentNum)
				coopHUD.players_config.small[i].color = currentNum
				coopHUD.save_options()
			end,
			Info = "Change player color color"
		})
	end
	--
	ModConfigMenu.AddTitle(mod_name, "Positions", '2 players HUD')
	ModConfigMenu.AddSetting(mod_name, "Positions", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.players_config[0].anchor_top == 'top_left'
		end,
		Display = function()
			local pos = "right"
			if coopHUD.players_config[0].anchor_top == 'top_left' then
				pos = "left"
			end
			return "Player 1 anchor: " .. pos
		end,
		OnChange = function(currentBool)
			if currentBool then
				coopHUD.players_config[0].anchor_top = 'top_left'
				coopHUD.players_config[0].anchor_bot = 'bot_left'
				coopHUD.players_config[0].mirrored = false
				coopHUD.players_config[1].anchor_top = 'top_right'
				coopHUD.players_config[1].anchor_bot = 'bot_right'
				coopHUD.players_config[1].mirrored = true
			else
				coopHUD.players_config[0].anchor_top = 'top_right'
				coopHUD.players_config[0].anchor_bot = 'bot_right'
				coopHUD.players_config[0].mirrored = true
				coopHUD.players_config[1].anchor_top = 'top_left'
				coopHUD.players_config[1].anchor_bot = 'bot_left'
				coopHUD.players_config[1].mirrored = false
			end
			coopHUD.save_options()
		end,
		Info = function()
			return "Change side where renders HUD on big mode"
		end
	})
	ModConfigMenu.AddSetting(mod_name, "Positions", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.players_config[1].anchor_top == 'top_left'
		end,
		Display = function()
			local pos = "right"
			if coopHUD.players_config[1].anchor_top == 'top_left' then
				pos = "left"
			end
			return "Player 2 anchor: " .. pos
		end,
		OnChange = function(currentBool)
			if currentBool then
				coopHUD.players_config[0].anchor_top = 'top_right'
				coopHUD.players_config[0].anchor_bot = 'bot_right'
				coopHUD.players_config[0].mirrored = true
				coopHUD.players_config[1].anchor_top = 'top_left'
				coopHUD.players_config[1].anchor_bot = 'bot_left'
				coopHUD.players_config[1].mirrored = false
			else
				coopHUD.players_config[0].anchor_top = 'top_left'
				coopHUD.players_config[0].anchor_bot = 'bot_left'
				coopHUD.players_config[0].mirrored = false
				coopHUD.players_config[1].anchor_top = 'top_right'
				coopHUD.players_config[1].anchor_bot = 'bot_right'
				coopHUD.players_config[1].mirrored = true
			end
			coopHUD.save_options()
		end,
		Info = function()
			return "Change side where renders HUD on big mode"
		end
	})
end
-- Overrides External item description mod setting to better fit with HUD
if EID then
	if EID.UserConfig.YPosition < 80 then EID.UserConfig.YPosition = 80 end
end
-- Overrides Enhanced Boss Bars  mod setting to better fit with HUD
if HPBars and HPBars.UserConfig then
	if HPBars.UserConfig.ScreenPadding < 24 then HPBars.UserConfig.ScreenPadding = 24 end
end
-- Overrides MinimapAPI  mod setting to show on coopHUD
if MinimapAPI then
	if not MinimapAPI.Config.DisplayOnNoHUD then MinimapAPI.Config.DisplayOnNoHUD = true end
	if MinimapAPI:GetConfig('ShowLevelFlags') then
		MinimapAPI.Config.ShowLevelFlags = false
	end
	if MinimapAPI:GetConfig('DisplayOnNoHUD') then
		MinimapAPI.Config.DisplayOnNoHUD = true
	end
end
