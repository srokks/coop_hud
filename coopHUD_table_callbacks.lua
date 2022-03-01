-- __________ On start
function coopHUD.on_start(_, cont)
	coopHUD.players = {}
	if cont then
		-- Logic when game is continued
		--[[coopHUD.essau_no = 0 -- resets Essau counter before player init
		if coopHUD.players[0] == nil then coopHUD.on_player_init() end]]
		coopHUD.essau_no = 0 -- resets Essau counter before player init
		if coopHUD.players[0] == nil then
			coopHUD.signals.is_joining = true
			coopHUD.on_player_init()
		end
		--
		--
		if coopHUD:HasData() then
			local save = json.decode(coopHUD:LoadData())
			if coopHUD.VERSION == save.version then
				coopHUD.angel_seen = save.run.angel_seen
			end
end
	else
		-- Logic when started new game/ restart thought dbg console

		coopHUD.essau_no = 0 -- resets Essau counter before player init
		if coopHUD.players[0] == nil then
			coopHUD.signals.is_joining = true
			coopHUD.on_player_init()
		end
	end
	-- TODO: load angel_seen from save if game continued
	coopHUD.angel_seen = nil -- resets angel seen state on restart
	coopHUD.initHudTables()
	coopHUD.updateItems()
end
coopHUD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, coopHUD.on_start)
-- __________ On player init
function coopHUD.on_player_init()
	if coopHUD.signals.is_joining then
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
	end
	--
	coopHUD.updateControllerIndex()
	coopHUD.signals.is_joining = false
	coopHUD.options.onRender = true
end
coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, coopHUD.on_player_init, 0)
-- __________ On active item/pocket activate
function coopHUD.on_activate(_, type, RNG, EntityPlayer, UseFlags, used_slot, CustomVarData)
	local player_index = coopHUD.getPlayerNumByControllerIndex(EntityPlayer.ControllerIndex)
	-- Hold on use change sprite
	if type == CollectibleType.COLLECTIBLE_HOLD and coopHUD.players[player_index].poop_mana > 0 then
		if coopHUD.players[player_index].hold_spell == nil then
			coopHUD.players[player_index].hold_spell = EntityPlayer:GetPoopSpell(0)
			coopHUD.updatePockets(player_index)
		else
			coopHUD.players[player_index].hold_spell = nil
		end
		coopHUD.updatePoopMana(player_index)
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
				Game():GetLevel():GetCurrentRoomIndex() == Game():GetLevel():GetStartingRoomIndex()
				and not string.match(Game():GetLevel():GetName(), "Downpour")
				and not string.match(Game():GetLevel():GetName(), "Dross") then
			coopHUD.options.onRender = false
			coopHUD.signals.is_joining = true
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
			coopHUD.updateHearts(player_index)
			coopHUD.updatePlayerType(player_index)
			coopHUD.updateActives(player_index)
			coopHUD.updatePockets(player_index)
			coopHUD.updateTrinkets(player_index)
		end
		if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
			coopHUD.updatePockets(player_index)
			coopHUD.updateTrinkets(player_index)
		end
		mapPressed = mapPressed or Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex)
	end
	if mapPressed then
		btn_held = btn_held + 1
		if btn_held > 1200 then
			coopHUD.signals.map = true
		end
	else
		coopHUD.signals.map = false
		btn_held = 0
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