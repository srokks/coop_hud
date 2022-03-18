-- __________ On start
function coopHUD.on_start(_, cont)
	coopHUD.players = {}
	if cont then
		local json = require("json")
		-- Logic when game is continued
		coopHUD.essau_no = 0 -- resets Essau counter before player init
		if coopHUD.players[0] == nil then
			coopHUD.on_player_init()
		end
		--
		if coopHUD:HasData() then
			local save = json.decode(coopHUD:LoadData())
			if coopHUD.VERSION == save.version then
				coopHUD.angel_seen = save.run.angel_seen
				-- Loads player data from save
				for player_no,player_save in pairs(save.run.players) do
					-- load collectibles
					for _,item_id in pairs(player_save.collectibles) do
						local item = Isaac.GetItemConfig():GetCollectible(item_id)
						coopHUD.add_collectible(tonumber(player_no),item)
					end
					--
				end
				--
			end
		end
	else
		coopHUD.players = {}
		-- Logic when started new game/ restart thought dbg console
		coopHUD.essau_no = 0 -- resets Essau counter before player init
		coopHUD.signals.is_joining = false
		--end
		coopHUD.angel_seen = false -- resets angel seen state on restart
	end
	coopHUD.initHudTables()
	coopHUD.updateItems()
end
coopHUD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, coopHUD.on_start)
-- __________ On player init
function coopHUD.on_player_init(_,ent)
	-- ___ inits coopHUD.tables if table nil or if more players
	if coopHUD.players[0] == nil or ( (#coopHUD.players  + coopHUD.essau_no ) ~= Game():GetNumPlayers() - 1)  then
		coopHUD.essau_no = 0
		for i = 0, Game():GetNumPlayers() - 1, 1 do
			local temp_player_table = coopHUD.initPlayer(i)
			if temp_player_table then
				coopHUD.players[i - coopHUD.essau_no] = temp_player_table
				if coopHUD.players[i - coopHUD.essau_no].has_twin then
					local temp_twin = Isaac.GetPlayer(i):GetOtherTwin()
					coopHUD.players[i - coopHUD.essau_no].twin = coopHUD.initPlayer(i, temp_twin) -- inits
					coopHUD.players[i - coopHUD.essau_no].twin.is_twin = true -- inits
					coopHUD.essau_no = coopHUD.essau_no + 1
				end
			end
		end
		coopHUD.signals.is_joining = false
		coopHUD.options.onRender = true
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, coopHUD.on_player_init)

-- __________ On active item/pocket activate
function coopHUD.on_activate(_, type, RNG, EntityPlayer, UseFlags, used_slot, CustomVarData)
	local player_index = coopHUD.getPlayerNumByControllerIndex(EntityPlayer.ControllerIndex)
	-- Hold on use change sprite
	if type == CollectibleType.COLLECTIBLE_HOLD and coopHUD.players[player_index].poop_mana >= 0 then
		if coopHUD.players[player_index].hold_spell == nil then
			coopHUD.players[player_index].hold_spell = coopHUD.players[player_index].poops[0]
			coopHUD.updatePockets(player_index)
		else
			coopHUD.players[player_index].hold_spell = nil
		end
		coopHUD.signals.on_poop_update = player_index
	end
	-- Check if used Smelter
	if type == CollectibleType.COLLECTIBLE_SMELTER then
		coopHUD.signals.on_trinket_update = player_index -- update trinkets on smelt
	end
	if coopHUD.players[player_index].type == PlayerType.PLAYER_BETHANY or
			coopHUD.players[player_index].type == PlayerType.PLAYER_BETHANY_B then
		coopHUD.signals.on_bethany_update = player_index
	end
	-- Update actives
	coopHUD.signals.on_active_update = player_index
	coopHUD.signals.on_pockets_update = player_index
	coopHUD.signals.on_heart_update = player_index
end
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM, coopHUD.on_activate)
-- __________ On item pickup
function coopHUD.on_item_pickup(_, ent_player, ent_collider, Low)
	-- Checks if player entity collides with item
	if ent_collider then
		local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
		if ent_collider.Type == EntityType.ENTITY_PICKUP then
			-- checks if collide with item
			if ent_collider.Variant == PickupVariant.PICKUP_HEART then
				-- check if collides with heart
				coopHUD.signals.on_heart_update = player_index
			elseif ent_collider.Variant == PickupVariant.PICKUP_COIN or -- check if collides with coin
					ent_collider.Variant == PickupVariant.PICKUP_KEY or -- or with key
					ent_collider.Variant == PickupVariant.PICKUP_BOMB then
				-- or with bomb
				coopHUD.signals.on_item_update = true -- triggers item update by signal
			elseif ent_collider.Variant == PickupVariant.PICKUP_LIL_BATTERY then
				coopHUD.signals.on_active_update = player_index -- triggers active updates
				coopHUD.signals.on_pockets_update = player_index -- triggers pockets updates
			elseif ent_collider.Variant == PickupVariant.PICKUP_TAROTCARD then
				coopHUD.signals.on_pockets_update = player_index -- triggers pocket update by signal
			elseif ent_collider.Variant == PickupVariant.PICKUP_PILL then
				coopHUD.signals.on_pockets_update = player_index -- triggers pocket update by signal
			elseif ent_collider.Variant == PickupVariant.PICKUP_POOP then
				coopHUD.signals.on_poop_update = player_index
			end
		end
		if ent_collider.Type == EntityType.ENTITY_SLOT then
			-- checks if collide with slot machine
			coopHUD.signals.on_item_update = true -- triggers item update
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, coopHUD.on_item_pickup)
-- __________ On damage
function coopHUD.on_damage(_, entity)
	local ent_player = entity:ToPlayer() -- parse entity to player entity
	local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex) -- gets player index
	coopHUD.signals.on_heart_update = player_index -- triggers heart update for player
	if ent_player:HasCollectible(CollectibleType.COLLECTIBLE_MARBLES) then
		-- in case of marbles (can gulp trinket)
		coopHUD.signals.on_trinket_update = player_index -- update trinkets
	end
end
coopHUD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, coopHUD.on_damage, EntityType.ENTITY_PLAYER)
-- __________ On room clear
function coopHUD.on_room_clear()
	-- Iterates through tables
	for i, _ in pairs(coopHUD.players) do
		coopHUD.updateActives(i) -- updates actives
		coopHUD.updatePockets(i) -- updates pockets
	end
end
coopHUD:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, coopHUD.on_room_clear)
-- __________ Force update on new floor/room
--- Function force updates all table. Triggers on new room/floor
function coopHUD.force_update_all()
	for i, _ in pairs(coopHUD.players) do
		coopHUD.updateActives(i)
		coopHUD.updateHearts(i)
		coopHUD.updatePockets(i)
		coopHUD.updateTrinkets(i)
		coopHUD.updateExtraLives(i)
		coopHUD.updateBethanyCharge(i)
		coopHUD.updatePoopMana(i)
	end
	coopHUD.updateControllerIndex()
end
coopHUD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, coopHUD.force_update_all)
coopHUD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, coopHUD.force_update_all)
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
-- _____
-- _____ INPUTS
local btn_held = 0
function coopHUD.on_input(_, ent, hook, btn)
	-- Handler for turning timer on of on key
	if Input.IsButtonTriggered(Keyboard.KEY_T, 0) then
		if coopHUD.options.timer_always_on then
			coopHUD.options.timer_always_on = false
		else
			coopHUD.options.timer_always_on = true
		end
	end
	-- _____ Joining new players logic
	for i = 0, 8, 1 do
		if Input.IsActionTriggered(ButtonAction.ACTION_JOINMULTIPLAYER, i) and not coopHUD.signals.is_joining and
				coopHUD.players[coopHUD.getPlayerNumByControllerIndex(i)] == nil
				and Game():GetRoom():IsFirstVisit() == true and
				Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE1_1 and
				Game():GetLevel():GetCurrentRoomIndex() == Game():GetLevel():GetStartingRoomIndex() then
			coopHUD.options.onRender = false
			coopHUD.signals.is_joining = true
			coopHUD.on_player_init()
		end
		if Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, i) and coopHUD.signals.is_joining then
			coopHUD.signals.is_joining = false
			coopHUD.options.onRender = true
		end
		if Input.IsActionTriggered(6, i) and coopHUD.signals.on_item_update then
			coopHUD.test_str = true
		end
	end
	-- MAP BUTTON
	local mapPressed = false
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local player_index = coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)
		if Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then
			coopHUD.signals.on_drop_triggered = player_index
		end
		if Input.IsActionTriggered(ButtonAction.ACTION_BOMB, player.ControllerIndex) then
			coopHUD.updateItems()
		end
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
			mapPressed = player_index
		end
	end
	if not coopHUD.signals.on_battle then
		if mapPressed then
			btn_held = btn_held + 1
			if btn_held > 1200 then
				coopHUD.signals.map = mapPressed
			end
		else
			coopHUD.signals.map = false
			btn_held = 0
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_INPUT_ACTION, coopHUD.on_input)
-- _____ On pill use
function coopHUD.on_pill_use(_, effect_no, ent_player)
	-- Triggers streak text on pill use
	if coopHUD.HUD_table.streak:IsFinished() then
		local pill_sys_name = Isaac.GetItemConfig():GetPillEffect(effect_no).Name
		pill_sys_name = string.sub(pill_sys_name, 2) --  get rid of # on front of
		if langAPI ~= nil then
			coopHUD.streak_main_line = langAPI.getPocketName(pill_sys_name)
		end
	end
	local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
	-- Triggers pocket update signal
	coopHUD.signals.on_pockets_update = player_index
	-- Updates trinkets if Gulp used
	if effect_no == PillEffect.PILLEFFECT_GULP then
		coopHUD.signals.on_trinket_update = player_index
	end
	coopHUD.signals.on_heart_update = player_index
end
coopHUD:AddCallback(ModCallbacks.MC_USE_PILL, coopHUD.on_pill_use)
-- _____ On card use
function coopHUD.on_card_use(_, effect_no, ent_player)
	--Triggers pocket update signal
	coopHUD.signals.on_pockets_update = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
end
coopHUD:AddCallback(ModCallbacks.MC_USE_CARD, coopHUD.on_card_use)
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
			coopHUD.HUD_table.streak:ReplaceSpritesheet(1, "/gfx/ui/blank.png")
			coopHUD.HUD_table.streak:LoadGraphics()
			coopHUD.streak_main_line = langAPI.getItemName(string.sub(item_queue.Item.Name, 2))
			coopHUD.streak_sec_line = langAPI.getItemName(string.sub(item_queue.Item.Description, 2))
			coopHUD.HUD_table.streak_sec_color = KColor(1, 1, 1, 1)
			coopHUD.HUD_table.streak_sec_line_font:Load("font/pftempestasevencondensed.fnt")
		end
		--_____ Updates actives of player
		local player_index = coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)
		if item_queue.Item.Type == ItemType.ITEM_ACTIVE then
			coopHUD.updateActives(player_index)
		elseif item_queue.Item.Type == ItemType.ITEM_TRINKET then
			coopHUD.updateTrinkets(player_index)
		else
			coopHUD.add_collectible(player_index,item_queue.Item)
		end
		coopHUD.updateExtraLives(player_index) -- triggers extra lives update
		coopHUD.updateItems() -- triggers update items when picked up item - Shops
		coopHUD.updateHearts(player_index) -- triggers update hearts if item picked up - Devil deals
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
-- _____ BAG OF CRAFTING callbacks
-- Bag of crafting
-- _____ Modified EID Wolsauge bag of crafting functions
local pickupsOnInit = {} -- holds all items in rooms whick can be collected by bag of crafting
-- __ collects all items in room when
coopHUD:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, function(_, entity)
	if entity.Variant ~= 4 then
		return
	end
	pickupsOnInit = {}
	for _,e in ipairs (Isaac.FindByType(EntityType.ENTITY_PICKUP, -1, -1, false, false)) do
		if e:GetSprite():GetAnimation() ~= "Collect" then
			table.insert(pickupsOnInit, e)
		end
	end
end, 4)
--
local pickupValues = {
	0x00000000, -- 0 None
	-- Hearts
	0x00000001, -- 1 Red Heart
	0x00000004, -- 2 Soul Heart
	0x00000005, -- 3 Black Heart
	0x00000005, -- 4 Eternal Heart
	0x00000005, -- 5 Gold Heart
	0x00000005, -- 6 Bone Heart
	0x00000001, -- 7 Rotten Heart
	-- Pennies
	0x00000001, -- 8 Penny
	0x00000003, -- 9 Nickel
	0x00000005, -- 10 Dime
	0x00000008, -- 11 Lucky Penny
	-- Keys
	0x00000002, -- 12 Key
	0x00000007, -- 13 Golden Key
	0x00000005, -- 14 Charged Key
	-- Bombs
	0x00000002, -- 15 Bomb
	0x00000007, -- 16 Golden Bomb
	0x0000000a, -- 17 Giga Bomb
	-- Batteries
	0x00000002, -- 18 Micro Battery
	0x00000004, -- 19 Lil' Battery
	0x00000008, -- 20 Mega Battery
	-- Usables
	0x00000002, -- 21 Card
	0x00000002, -- 22 Pill
	0x00000004, -- 23 Rune
	0x00000004, -- 24 Dice Shard
	0x00000002, -- 25 Cracked Key
	-- Added in Update
	0x00000007, -- 26 Golden Penny
	0x00000007, -- 27 Golden Pill
	0x00000007, -- 28 Golden Battery
	0x00000000, -- 29 Tainted ??? Poop

	0x00000001,
}
local pickupIDLookup = {
	["10.1"] = {1}, -- Red heart
	["10.2"] = {1}, -- half heart
	["10.3"] = {2}, -- soul heart
	["10.4"] = {4}, -- eternal heart
	["10.5"] = {1, 1}, -- double heart
	["10.6"] = {3}, -- black heart
	["10.7"] = {5}, -- gold heart
	["10.8"] = {2}, -- half soul heart
	["10.9"] = {1}, -- scared red heart
	["10.10"] = {2, 1}, -- blended heart
	["10.11"] = {6}, -- Bone heart
	["10.12"] = {7}, -- Rotten heart
	["20.1"] = {8}, -- Penny
	["20.2"] = {9}, -- Nickel
	["20.3"] = {10}, -- Dime
	["20.4"] = {8, 8}, -- Double penny
	["20.5"] = {11}, -- Lucky Penny
	["20.6"] = {9}, -- Sticky Nickel
	["20.7"] = {26}, -- Golden Penny
	["30.1"] = {12}, -- Key
	["30.2"] = {13}, -- golden Key
	["30.3"] = {12,12}, -- Key Ring
	["30.4"] = {14}, -- charged Key
	["40.1"] = {15}, -- bomb
	["40.2"] = {15,15}, -- double bomb
	["40.4"] = {16}, -- golden bomb
	["40.7"] = {17}, -- giga bomb
	["42.0"] = {29}, -- poop nugget
	["42.1"] = {29}, -- big poop nugget
	["70.14"] = {27}, -- golden pill
	["70.2062"] = {27}, -- golden horse pill
	["90.1"] = {19}, -- Lil Battery
	["90.2"] = {18}, -- Micro Battery
	["90.3"] = {20}, -- Mega Battery
	["90.4"] = {28}, -- Golden Battery
	["300.49"] = {24}, -- Dice shard
	["300.50"] = {21}, -- Emergency Contact
	["300.78"] = {25}, -- Cracked key
}
-- __ When bag of crafting entity destroyed add to parent.player.bag of crafting inventory new item
coopHUD:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, bag)
	if bag.Variant ~= 4 or bag.SubType ~= 4 then
		return
	end

	table.sort(pickupsOnInit, function (a,b)
		return
		a:GetSprite():GetFrame() > b:GetSprite():GetFrame() or
				(a:GetSprite():GetFrame() == b:GetSprite():GetFrame() and a.Index < b.Index)
	end)
	for _,e in ipairs (pickupsOnInit) do
		if e:GetSprite():GetAnimation() == "Collect" then
			local player_index = coopHUD.getPlayerNumByControllerIndex(bag:GetLastParent():ToPlayer().ControllerIndex)
			local player_bag = coopHUD.players[player_index].bag_of_crafting
			for _,item_id in pairs(pickupIDLookup[e.Variant..'.'..e.SubType]) do
				if #player_bag >= 8 then -- if bag is full
					local new_bag = {}
					for i=2,#player_bag do
						table.insert(new_bag, player_bag[i])
					end
					coopHUD.players[player_index].bag_of_crafting = new_bag
				end
				table.insert(coopHUD.players[player_index].bag_of_crafting,{value = pickupValues[item_id],id=item_id})
			end
		end
	end
end, EntityType.ENTITY_KNIFE)
-- _____