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
		coopHUD.players = {}
		-- Logic when started new game/ restart thought dbg console
		coopHUD.essau_no = 0 -- resets Essau counter before player init
		coopHUD.signals.is_joining = false
		--end
		coopHUD.angel_seen = false -- resets angel seen state on restart
	end
	--coopHUD.initHudTables()
	--coopHUD.updateItems()
end
coopHUD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, coopHUD.on_start)
function coopHUD.on_player_init(_, ent)
	-- ___ inits coopHUD.tables if table nil or if more players
	if coopHUD.players[0] == nil or ((#coopHUD.players + coopHUD.essau_no) ~= Game():GetNumPlayers() - 1) then
		coopHUD.essau_no = 0
		for i = 0, Game():GetNumPlayers() - 1, 1 do
			local temp_player_table = coopHUD.Player(i)
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
-- _____ INPUTS
local btn_held = 0
function coopHUD.on_input()
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
			coopHUD.players[player_index].signals.on_drop_activate = true
		end
		if Input.IsActionTriggered(ButtonAction.ACTION_BOMB, player.ControllerIndex) then
			--coopHUD.updateItems()
			coopHUD.signals.on_poop_update = player_index
		end
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
			mapPressed = player_index
		end
	end
	if not coopHUD.signals.on_battle then
		if mapPressed then
			btn_held = btn_held + 1
			if btn_held > 25 then
				coopHUD.signals.map = mapPressed
			end
		else
			coopHUD.signals.map = false
			btn_held = 0
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.on_input)
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
	-- Triggers streak text on pill use
	local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
	-- Triggers pocket update signal
	coopHUD.players[player_index]:on_signal('on_pocket_update')
	--coopHUD.signals.on_heart_update = player_index
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
				coopHUD.signals.on_heart_update = player_index
			elseif ent_collider.Variant == PickupVariant.PICKUP_COIN or -- check if collides with coin
					ent_collider.Variant == PickupVariant.PICKUP_KEY or -- or with key
					ent_collider.Variant == PickupVariant.PICKUP_BOMB then
				-- or with bomb
				coopHUD.signals.on_item_update = true -- triggers item update by signal
			elseif ent_collider.Variant == PickupVariant.PICKUP_LIL_BATTERY then
				coopHUD.players[player_index]:on_signal('on_active_update')-- triggers active updates
				coopHUD.players[player_index]:on_signal('on_pocket_update') -- triggers pockets updates
			elseif ent_collider.Variant == PickupVariant.PICKUP_TAROTCARD then
				coopHUD.players[player_index]:on_signal('on_pocket_update') -- triggers pocket update by signal
			elseif ent_collider.Variant == PickupVariant.PICKUP_PILL then
				coopHUD.players[player_index]:on_signal('on_pocket_update') -- triggers pocket update by signal
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
		--if langAPI then
		--	coopHUD.HUD_table.streak:ReplaceSpritesheet(1, "/gfx/ui/blank.png")
		--	coopHUD.HUD_table.streak:LoadGraphics()
		--	coopHUD.streak_main_line = langAPI.getItemName(string.sub(item_queue.Item.Name, 2))
		--	coopHUD.streak_sec_line = langAPI.getItemName(string.sub(item_queue.Item.Description, 2))
		--	coopHUD.HUD_table.streak_sec_color = KColor(1, 1, 1, 1)
		--	coopHUD.HUD_table.streak_sec_line_font:Load("font/pftempestasevencondensed.fnt")
		--end
		--_____ Updates actives of player
		local player_index = coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)
		if item_queue.Item.Type == ItemType.ITEM_ACTIVE then
			coopHUD.players[player_index].signals.on_active_update = true
		elseif item_queue.Item.Type == ItemType.ITEM_TRINKET then
			coopHUD.players[player_index].signals.on_trinket_update = true
		else
			--coopHUD.add_collectible(player_index, item_queue.Item)
		end
		--coopHUD.updateExtraLives(player_index) -- triggers extra lives update
		--coopHUD.updateItems() -- triggers update items when picked up item - Shops
		--coopHUD.updateHearts(player_index) -- triggers update hearts if item picked up - Devil deals
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