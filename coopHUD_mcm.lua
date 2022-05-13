local json = require("json")
if coopHUD:HasData() then
	local save = json.decode(coopHUD:LoadData())
	coopHUD.players_config.small[0] = save.players_config.small['0']
	coopHUD.players_config.small[1] = save.players_config.small['1']
	coopHUD.players_config.small[2] = save.players_config.small['2']
	coopHUD.players_config.small[3] = save.players_config.small['3']
	coopHUD.options = save.options
end
function coopHUD.save_options()
	local save = {}
	save.version = coopHUD.VERSION
	save.options = coopHUD.options
	save.players_config = coopHUD.players_config
	--
	save.run = {
		['essau_no'] = coopHUD.essau_no,
		['angel_seen'] = coopHUD.angel_seen,
	}
	--
	if coopHUD.jar_of_wisp_charge and coopHUD.jar_of_wisp_charge > 0 then
		save.run['jar_of_wisp_use'] = coopHUD.jar_of_wisp_charge
	end
	--
	local players = {}
	for i = 1, #coopHUD.players do
		-- saves player collectibles
		local collectibles = {}
		if coopHUD.players[i] then
			for j = 1, #coopHUD.players[i].collectibles do
				table.insert(collectibles,
				             {coopHUD.players[i].collectibles[j].type, coopHUD.players[i].collectibles[j].id})
			end
			local gulped_trinkets = {}
			for j = 1, #coopHUD.players[i].gulped_trinkets do
				table.insert(gulped_trinkets,
				             {coopHUD.players[i].gulped_trinkets[j].type, coopHUD.players[i].gulped_trinkets[j].id})
			end
			players[i] = {collectibles = collectibles,
			              gulped_trinkets = gulped_trinkets,
			              hold_spell = coopHUD.players[i].hold_spell}
		end
		-- save player bag of crafting
		--[[local bag_of_crafting = {}
		if coopHUD.players[i].bag_of_crafting ~= nil then
			for j = 1, #coopHUD.players[i].bag_of_crafting do
				table.insert(bag_of_crafting, coopHUD.players[i].bag_of_crafting[j].id)
			end
		end]]
		--
	end
	save.run.players = players
	coopHUD:SaveData(json.encode(save))
	--coopHUD.players = {}
end
coopHUD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
	coopHUD.save_options()
	coopHUD.players = {}
end)
if ModConfigMenu then
	local mod_name = "Coop HUD"
	--= DEBUG: Used to reset the config, remove on retail.
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
	-- show my stuff page
	ModConfigMenu.AddSetting(mod_name, "General", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.show_my_stuff
		end,
		Default = coopHUD.options.show_my_stuff,

		Display = function()
			local onOff = "Off"
			if coopHUD.options.show_my_stuff then
				onOff = "On"
			end

			return "Show my stuff page: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.show_my_stuff = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return 'Shows player items on long map button push'
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
	-- Show player name
	ModConfigMenu.AddSetting(mod_name, "General", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.show_player_names
		end,
		Default = coopHUD.options.show_player_names,

		Display = function()
			local onOff = "Off"
			if coopHUD.options.show_player_names then
				onOff = "On"
			end

			return "Show player name: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.show_player_names = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Show  name under player"
		end
	})
	-- h trigger
	ModConfigMenu.AddSetting(mod_name, "General", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.h_trigger
		end,
		Default = coopHUD.options.h_trigger,

		Display = function()
			local onOff = "Off"
			if coopHUD.options.h_trigger then
				onOff = "On"
			end

			return "'h' trigger: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.h_trigger = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Toggle 'h' trigger for show HUD"
		end
	})
	-- __ Stats
	ModConfigMenu.AddTitle(mod_name, 'Stats', 'Stats')
	-- stats.show
	ModConfigMenu.AddSetting(mod_name, "Stats", {
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
	ModConfigMenu.AddSetting(mod_name, "Stats", {
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
	-- Deals
	ModConfigMenu.AddTitle(mod_name, 'Stats', 'Deals')
	-- show deals
	ModConfigMenu.AddSetting(mod_name, "Stats", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.deals.show
		end,
		Default = coopHUD.options.deals.show,

		Display = function()
			local onOff = "Off"
			if coopHUD.options.deals.show then
				onOff = "On"
			end

			return "Show deals chance: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.deals.show = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Shows deal chances"
		end
	})
	-- deals position
	ModConfigMenu.AddSetting(mod_name, "Stats", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.deals.vanilla_position
		end,
		Default = coopHUD.options.deals.vanilla_position,

		Display = function()
			local onOff = "coopHUD"
			if coopHUD.options.deals.vanilla_position then
				onOff = "Vanilla"
			end

			return "Deals position: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.deals.vanilla_position = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Deals chance position"
		end
	})
	-- show planetarium
	ModConfigMenu.AddSetting(mod_name, "Stats", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.deals.show_planetarium
		end,
		Default = coopHUD.options.deals.show_planetarium,
		Display = function()
			local onOff = "Off"
			if coopHUD.options.deals.show_planetarium then
				onOff = "On"
			end
			return "Show planetarium chance: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.deals.show_planetarium = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Show planetarium chances"
		end
	})
	-- hide deals in battle
	ModConfigMenu.AddSetting(mod_name, "Stats", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.deals.hide_in_battle
		end,
		Default = coopHUD.options.deals.hide_in_battle,
		Display = function()
			local onOff = "Off"
			if coopHUD.options.deals.hide_in_battle then
				onOff = "On"
			end
			return "Hide chance in battle: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.deals.hide_in_battle = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Hide chances while in battle"
		end
	})
	-- __ Players
	ModConfigMenu.AddTitle(mod_name, "Colors", 'General')
	-- .player_info_color
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

			return "Colorful HUD: " .. onOff
		end,
		OnChange = function(currentBool)
			coopHUD.options.player_info_color = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Player info/stats will be colorfull"
		end
	})
	-- colorful players
	ModConfigMenu.AddSetting(mod_name, "Colors", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.options.colorful_players
		end,
		Default = coopHUD.options.colorful_players,

		Display = function()
			local onOff = "Off"
			if coopHUD.options.colorful_players then
				onOff = "On"
			end

			return "Colorful players: " .. onOff
		end,
		OnChange = function(currentBool)
			if not currentBool then coopHUD.options.color_player_names = false end
			coopHUD.options.colorful_players = currentBool
			coopHUD.save_options()
		end,
		Info = function()
			return "Colors players sprites"
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
	ModConfigMenu.AddTitle(mod_name, "Positions", 'Big HUD  positions:')
	ModConfigMenu.AddSetting(mod_name, "Positions", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.players_config.small[0].anchor_top == 'top_left'
		end,
		Display = function()
			local anchor_string = ""
			if coopHUD.players_config.small[0].anchor_top == 'top_left' then
				anchor_string = "left side"
			else
				anchor_string = "right side"
			end
			return "Player 1: " .. anchor_string
		end,
		OnChange = function(currentBool)
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
		Info = function()
			return "Sets player position on big hud"
		end
	})
	ModConfigMenu.AddSetting(mod_name, "Positions", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
		CurrentSetting = function()
			return coopHUD.players_config.small[1].anchor_top == 'top_right'
		end,
		Display = function()
			local anchor_string = ""
			if coopHUD.players_config.small[1].anchor_top == 'top_left' then
				anchor_string = "left side"
			else
				anchor_string = "right side"
			end
			return "Player 2: " .. anchor_string
		end,
		OnChange = function(currentBool)
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
		Info = function()
			return "Sets player position on big hud"
		end
	})
	-- TODO: uptade other anchors on change
	-- DEBUG: until finished only for debuging
	--[[ModConfigMenu.AddTitle(mod_name, "Positions", 'Small HUD positions')
	ModConfigMenu.AddSetting(mod_name, "Positions", {
		Type = ModConfigMenu.OptionType.NUMBER,
		CurrentSetting = function()
			return coopHUD.anchors[coopHUD.players_config.small[0].anchor .. '_id']
		end,
		Minimum = 0,
		Maximum = 3,
		Display = function()
			return "Player 1: " .. coopHUD.anchors[coopHUD.players_config.small[0].anchor .. '_name']
		end,
		OnChange = function(currentNum)
			coopHUD.players_config.small[0].anchor = coopHUD.players_config.default[currentNum].anchor
			coopHUD.players_config.small[0].mirrored = coopHUD.players_config.default[currentNum].mirrored
			coopHUD.players_config.small[0].down_anchor = coopHUD.players_config.default[currentNum].down_anchor
			coopHUD.save_options()
		end,
		Info = function()
			return "Sets player position on small hud"
		end
	})]]
end
-- Overrides External item description mod setting to better fit with HUD
if EID then
	if EID.UserConfig.YPosition < 80 then EID.UserConfig.YPosition = 80 end
	if EID.UserConfig.TextboxWidth < 150 then EID.UserConfig.TextboxWidth = 150 end
	if EID.UserConfig.LineHeight > 9 then EID.UserConfig.LineHeight = 9 end
end
-- Overrides Enhanced Boss Bars  mod setting to better fit with HUD
if HPBars and HPBars.UserConfig then
	if HPBars.UserConfig.ScreenPadding <= 33 then HPBars.UserConfig.ScreenPadding = 33 end
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
