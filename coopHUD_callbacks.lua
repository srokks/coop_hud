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
		if coopHUD:HasData() then
			local save = json.decode(coopHUD:LoadData())
			if coopHUD.VERSION == save.version then
				coopHUD.angel_seen = save.run.angel_seen
				-- Loads player data from save
				for player_no, player_save in pairs(save.run.players) do
					--` load collectibles
					--for _, item_id in pairs(player_save.collectibles) do
					--	local item = Isaac.GetItemConfig():GetCollectible(item_id)
					--	--coopHUD.add_collectible(tonumber(player_no), item)
					--end
					-- load gulped_trinket
					for _, trinket_id in pairs(player_save.gulped_trinkets) do
						local temp_trinket = Isaac.GetItemConfig():GetTrinket(trinket_id)
						table.insert(coopHUD.players[tonumber(player_no)].gulped_trinkets,
						             { id = temp_trinket.ID, sprite = coopHUD.getTrinketSpriteByID(temp_trinket.ID) })
					end
					-- load bag of crafting
					for _, item_id in pairs(player_save.bag_of_crafting) do
						table.insert(coopHUD.players[tonumber(player_no)].bag_of_crafting,
						             { value = coopHUD.getItemValue(item_id), id = item_id, sprite = coopHUD.getCraftingItemSprite(item_id) })
					end
					-- load hold spell current load
					if player_save.hold_spell ~= nil then
						coopHUD.players[tonumber(player_no)].hold_spell = player_save.hold_spell
					end
					coopHUD.signals.on_pockets_update = tonumber(player_no)
				end
				--
			end
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
	if (#coopHUD.players + coopHUD.essau_no ) ~= Game():GetNumPlayers()  then
		coopHUD.players = {}  -- resets players table
		coopHUD.essau_no = 0  -- resets essau no before full init of players
		for i = 0, Game():GetNumPlayers() - 1, 1 do
			local player_type = Isaac.GetPlayer(i):GetPlayerType()
			if player_type ~= PlayerType.PLAYER_THESOUL_B and player_type ~= PlayerType.PLAYER_ESAU then
				-- skips iteration when non first character
				coopHUD.players[i+1 - coopHUD.essau_no] = coopHUD.Player(i)
			else
				coopHUD.essau_no = coopHUD.essau_no + 1
			end
		end
		if coopHUD.signals.is_joining then coopHUD.signals.is_joining = false end
	end
end
--_____ INPUTS
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
			coopHUD.text = coopHUD.text - 1
				end
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_INPUT_ACTION, coopHUD.on_join_signal)
-- __________ On active item/pocket activate
function coopHUD.on_activate(_, type, RNG, EntityPlayer, UseFlags, used_slot, CustomVarData)
	local player_index = coopHUD.getPlayerNumByControllerIndex(EntityPlayer.ControllerIndex)
	EntityPlayer:FlushQueueItem()
	if used_slot <2 then
		coopHUD.players[player_index]:on_signal('on_active_update')
	end
	if used_slot >=2 then
		coopHUD.players[player_index]:on_signal('on_pocket_update')
	end
	if type == CollectibleType.COLLECTIBLE_HOLD then
		-- Hold on use change sprite
		--TODO:Poops: define hold charge sprite
	elseif type == CollectibleType.COLLECTIBLE_SMELTER then
		-- Check if used Smelter or trinket been smelted (bu Gulp Pill or Marbles)
		--TODO:Collectibles: add gulped trinket to collectibles table
		coopHUD.players[player_index].signals.on_trinket_update = true -- update trinkets
	elseif type == CollectibleType.COLLECTIBLE_D4 then
		-- Refresh collectibles - order them in alphabetical order
		--TODO:Collectibles: reroll collectibles logic
		--coopHUD.players[player_index].collectibles = {}
		--for i = 1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
		--	if Isaac.GetPlayer(coopHUD.players[player_index].game_index):HasCollectible(i) then
		--		local item = Isaac.GetItemConfig():GetCollectible(i)
		--		if item.Type ~= ItemType.ITEM_ACTIVE then
		--			coopHUD.add_collectible(player_index, item)
		--		end
		--	end
		--end
	end
	coopHUD.players[player_index].signals.on_heart_update = true -- update hearts
end
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM, coopHUD.on_activate)
-- _____ On card use
function coopHUD.on_card_use(_, effect_no, ent_player)
	--Triggers pocket update signal
	local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
	coopHUD.players[player_index]:on_signal('on_pocket_update')
end
coopHUD:AddCallback(ModCallbacks.MC_USE_CARD, coopHUD.on_card_use)
-- _____ On pill use
function coopHUD.on_pill_use(_, effect_no, ent_player)
	local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
	-- Triggers pocket update signal
	coopHUD.players[player_index]:on_signal('on_pocket_update')
	coopHUD.players[player_index]:on_signal('on_heart_update')
	-- Triggers streak text on pill use
	local pill_sys_name = Isaac.GetItemConfig():GetPillEffect(effect_no).Name -- gets pill sys name
	pill_sys_name = string.sub(pill_sys_name, 2) --  get rid of # on front of
	if langAPI ~= nil then
		-- if langAPI loaded
		pill_sys_name = langAPI.getPocketName(pill_sys_name) -- get name from api in set language
		coopHUD.Streak.trigger(false, coopHUD.Streak.ITEM, pill_sys_name) -- triggers streak
	end
end
coopHUD:AddCallback(ModCallbacks.MC_USE_PILL, coopHUD.on_pill_use)
-- __________ On damage
function coopHUD.on_damage(_, entity)
	local ent_player = entity:ToPlayer() -- parse entity to player entity
	local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex) -- gets player index
	coopHUD.players[player_index]:on_signal('on_heart_update') -- triggers heart update for player
end
coopHUD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, coopHUD.on_damage, EntityType.ENTITY_PLAYER)
-- __________ On item pickup
function coopHUD.on_item_pickup(_, ent_player, ent_collider, Low)
	-- Checks if player entity collides with item
	if ent_collider then
		local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
		if ent_collider.Type == EntityType.ENTITY_PICKUP then
			-- checks if collide with item
			if ent_collider.Variant == PickupVariant.PICKUP_HEART then
				-- check if collides with heart
				coopHUD.players[player_index]:on_signal('on_heart_update')
			elseif ent_collider.Variant == PickupVariant.PICKUP_LIL_BATTERY then
				coopHUD.players[player_index]:on_signal('on_active_update')-- triggers active updates
				coopHUD.players[player_index]:on_signal('on_pocket_update') -- triggers pockets updates
			elseif ent_collider.Variant == PickupVariant.PICKUP_TAROTCARD and not ent_player:ToPlayer():IsHoldingItem() then
				if langAPI then
					-- triggers streak on card pickup
					local name = Isaac.GetItemConfig():GetCard(ent_collider.SubType).Name
					name = string.sub(name, 2) --  get rid of # on front of
					name = langAPI.getPocketName(name)
					--
					local desc = Isaac.GetItemConfig():GetCard(ent_collider.SubType).Description
					desc = string.sub(desc, 2) --  get rid of # on front of
					desc = langAPI.getPocketName(desc)
					coopHUD.Streak.trigger(false, coopHUD.Streak.ITEM, name, desc)
				end
				coopHUD.players[player_index]:on_signal('on_pocket_update') -- triggers pocket update by signal
			elseif ent_collider.Variant == PickupVariant.PICKUP_PILL then
				coopHUD.players[player_index]:on_signal('on_pocket_update') -- triggers pocket update by signal
			elseif ent_collider.Variant == PickupVariant.PICKUP_POOP then
				--TODO:on poop update
			end
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, coopHUD.on_item_pickup)
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
-- __________ Force update on new floor/room
--- Function force updates all table. Triggers on new room/floor
coopHUD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	coopHUD.Streak.trigger(false, coopHUD.Streak.FLOOR)
end)
-- _____ Post item pickup
-- Modified  Version of POST_ITEM_PICKUP from pedroff_1 - https://steamcommunity.com/sharedfiles/filedetails/?id=2577953432&searchtext=callback
function PostItemPickup (_, player)
	local item_queue = player.QueuedItem
	if item_queue and item_queue.Item then
		local list = PostItemPickupFunctions
		if list[item_queue.Item.ID] then
			for i, v in pairs(list[item_queue.Item.ID]) do
				v(_, player)
			end
		end
		list = PostItemPickupFunctions[-1]
		if list then
			for i, v in pairs(list) do
				v(_, player, item_queue.Item.ID)
			end
		end
		player:FlushQueueItem()
		--____ Flashes triggers streak text with picked up name
		if langAPI then
			local streak_main_line = langAPI.getItemName(string.sub(item_queue.Item.Name, 2))
			local streak_sec_line = langAPI.getItemName(string.sub(item_queue.Item.Description, 2))
			coopHUD.Streak.trigger(false, coopHUD.Streak.ITEM, streak_main_line, streak_sec_line, true)
		end
		--_____ Updates actives of player
		local player_index = coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)
		if item_queue.Item.Type == ItemType.ITEM_ACTIVE then
			coopHUD.players[player_index].signals.on_active_update = true
		elseif item_queue.Item.Type == ItemType.ITEM_TRINKET then
			coopHUD.players[player_index].signals.on_trinket_update = true
		else
			--coopHUD.add_collectible(player_index, item_queue.Item)
		end
		coopHUD.players[player_index].signals.on_heart_update = true
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostItemPickup)
local addCallbackOld = Isaac.AddCallback
ModCallbacks.MC_POST_ITEM_PICKUP = 271
PostItemPickupFunctions = PostItemPickupFunctions or {}
function addCallbackNew(mod, callback, func, arg1, arg2, arg3, arg4)
	if callback == ModCallbacks.MC_POST_ITEM_PICKUP then
		arg1 = arg1 or -1
		PostItemPickupFunctions[arg1] = PostItemPickupFunctions[arg1] or {}
		PostItemPickupFunctions[arg1][tostring(func)] = func
	else
		addCallbackOld(mod, callback, func, arg1, arg2, arg3, arg4)
	end
end
Isaac.AddCallback = addCallbackNew
---- End of standalone module
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
		if Input.IsActionTriggered(ButtonAction.ACTION_DROP, controller_index) then
			coopHUD.players[player_index]:on_signal('on_drop_activate')
		end

	end
	-- MAP BUTTON
	local pressTime = 0.5
	if mapPressed then
		btn_held = btn_held + 1 / 60
		if btn_held > pressTime then
			coopHUD.signals.map = mapPressed
			coopHUD.Streak.trigger(true, coopHUD.Streak.FLOOR)
			coopHUD.players[mapPressed].signals.map_btn = true
		end
	else
		coopHUD.signals.map = false
		btn_held = 0
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.inputs_signals)
function coopHUD.render()
	coopHUD.updateAnchors()
	if #coopHUD.players > 4 then
		-- prevents to render if more than 4 players for now
		coopHUD.options.onRender = false
	end
	-- _____ Main render function
	local paused = Game():IsPaused()
	for i = 1, #coopHUD.players do
		if coopHUD.players[i] then
			coopHUD.players[i]:update()
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