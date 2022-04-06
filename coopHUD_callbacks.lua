-- __________ On start
function coopHUD.on_start(_, cont)
	coopHUD.players = {}
	if cont then
		local json = require("json")
		-- Logic when game is continued
		if coopHUD.players[0] == nil then
			coopHUD.on_player_init()
		end
		--
		local save = json.decode(coopHUD:LoadData())
		if coopHUD.VERSION == save.version then
			coopHUD.angel_seen = save.run.angel_seen
			-- Loads player data from save
			for player_no, player_save in pairs(save.run.players) do
				--` load collectibles
				for _, item_id in pairs(player_save.collectibles) do
					local type, id = item_id[1], item_id[2]
					if type == PickupVariant.PICKUP_COLLECTIBLE then
						table.insert(coopHUD.players[player_no].collectibles, coopHUD.Item(nil, -1, id))
					elseif type == PickupVariant.PICKUP_TRINKET then
						table.insert(coopHUD.players[player_no].collectibles, coopHUD.Trinket(nil, -1, id))
					end
				end
			end
			--
		end
	else
		-- Logic when started new game/ restart thought dbg console
		coopHUD.on_player_init()
		--
		coopHUD.angel_seen = false -- resets angel seen state on restart
	end
	coopHUD.HUD.init()
end
coopHUD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, coopHUD.on_start)
function coopHUD.on_player_init()
	if (#coopHUD.players + coopHUD.essau_no) ~= Game():GetNumPlayers() then
		coopHUD.players = {}  -- resets players table
		coopHUD.essau_no = 0  -- resets essau no before full init of players
		for i = 0, Game():GetNumPlayers() - 1, 1 do
			local player_type = Isaac.GetPlayer(i):GetPlayerType()
			if player_type ~= PlayerType.PLAYER_THESOUL_B and player_type ~= PlayerType.PLAYER_ESAU then
				-- skips iteration when non first character
				coopHUD.players[i + 1 - coopHUD.essau_no] = coopHUD.Player(i)
				if coopHUD.players[i + 1 - coopHUD.essau_no] then
					--coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, coopHUD.players[i + 1 - coopHUD.essau_no].update)
				end
			else
				coopHUD.essau_no = coopHUD.essau_no + 1
			end
		end
		if coopHUD.signals.is_joining then coopHUD.signals.is_joining = false end
	end
end
--_____ INPUTS ACTION_JOINMULTIPLAYER
function coopHUD.on_join_signal()
	-- ACTION_JOINMULTIPLAYER
	if not Game():IsPaused() then
		for i = 0, 8 do
			if Input.IsActionTriggered(ButtonAction.ACTION_JOINMULTIPLAYER, i)
					and coopHUD.getPlayerNumByControllerIndex(i) < 0 -- checks if player is already in tables
					and not coopHUD.signals.is_joining
					and Game():GetRoom():IsFirstVisit() == true -- you can join into coop only on first floor of game
					and Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE1_1 -- on first level
					and Game():GetLevel():GetCurrentRoomIndex() == Game():GetLevel():GetStartingRoomIndex() then
				--
				coopHUD.signals.is_joining = true
			end
			-- Catches back button when on
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, i) and coopHUD.signals.is_joining then
				coopHUD.signals.is_joining = false
			end
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_INPUT_ACTION, coopHUD.on_join_signal)
-- _____ On battle signal
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, function(self)
	-- on battle signal
	-- if option turned on checks signals
	local r = Game():GetLevel():GetCurrentRoom()
	if not r:IsClear() then
		-- check if room ready
		coopHUD.signals.on_battle = true
	else
		coopHUD.signals.on_battle = false -- reset signal
	end
end)
-- __________ New floor streak trigger
coopHUD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	coopHUD.Streak(false, coopHUD.Streak.FLOOR)
end)
-- INPUT TRIGGERS
local btn_held = 0
function coopHUD.inputs_signals()
	-- Trigger for turning on/off coop hud on `H` key
	if Input.IsButtonTriggered(Keyboard.KEY_H, 0) then
		if coopHUD.options.onRender then
			coopHUD.options.onRender = false
		else
			coopHUD.options.onRender = true
		end
	end
	-- Trigger for turning on/off timer on `T` key
	if Input.IsButtonTriggered(Keyboard.KEY_T, 0) then
		if coopHUD.options.timer_always_on then
			coopHUD.options.timer_always_on = false
		else
			coopHUD.options.timer_always_on = true
		end
	end
	local mapPressed = false
	for i = 0, Game():GetNumPlayers() - 1 do
		local controller_index = Isaac.GetPlayer(i).ControllerIndex
		local player_index = coopHUD.getPlayerNumByControllerIndex(controller_index)
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, controller_index) then
			mapPressed = player_index
		end
	end
	-- MAP BUTTON
	local pressTime = 0.5
	if mapPressed then
		btn_held = btn_held + 1 / 60
		if btn_held > pressTime then
			coopHUD.signals.map = mapPressed
			coopHUD.Streak(true, coopHUD.Streak.FLOOR)
			if btn_held > 0.9 then
				coopHUD.Collectibles(coopHUD.players[coopHUD.signals.map])
			end
			coopHUD.players[mapPressed].signals.map_btn = true
		end
	else
		coopHUD.signals.map = false
		btn_held = 0
	end
end
-- MAIN RENDER
function coopHUD.render()
	coopHUD.updateAnchors()
	coopHUD.inputs_signals()
	if #coopHUD.players > 4 then
		-- prevents to render if more than 4 players for now
		coopHUD.options.onRender = false
	end
	-- _____ Main render function
	local paused = Game():IsPaused()
	for i = 1, #coopHUD.players do
		if coopHUD.players[i] then
			coopHUD.on_player_init()
			--if paused then coopHUD.options.onRender = false end
			--if coopHUD.options.onRender and not paused and not coopHUD.signals.is_joining then
			--print(coopHUD.options.onRender and not paused)
			if coopHUD.options.onRender and not paused and not coopHUD.signals.is_joining then
				if Game():GetHUD():IsVisible() then Game():GetHUD():SetVisible(false) end
				coopHUD.players[i]:render()
				coopHUD.HUD.render()
			end
			if not coopHUD.options.onRender or coopHUD.signals.is_joining then
				if not Game():GetHUD():IsVisible() then Game():GetHUD():SetVisible(true) end
			end
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)