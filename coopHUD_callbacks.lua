-- __________ On start
function coopHUD.on_start(_, cont)
	--Resets tables
	coopHUD.players = {}
	coopHUD.essau_no = 0 -- resets essau_no
	coopHUD.on_player_init() -- inits players
	--
	coopHUD.angel_seen = false -- resets angel seen state on restart
	coopHUD.jar_of_wisp_charge = false -- resets wisp charge  on restart
	if cont then
		local json = require("json")
		-- Logic when game is continued
		local save = json.decode(coopHUD:LoadData())
		if coopHUD.VERSION == save.version then
			coopHUD.essau_no = save.run.essau_no
			coopHUD.angel_seen = save.run.angel_seen
			--TODO: jar of wisp charge load from save
			-- Loads player data from save
			for player_no, player_save in pairs(save.run.players) do
				--` load collectibles
				for _, item_id in pairs(player_save.collectibles) do
					local type, id = item_id[1], item_id[2]
					if type == PickupVariant.PICKUP_COLLECTIBLE then
						table.insert(coopHUD.players[player_no].collectibles,
						             coopHUD.Item(coopHUD.players[player_no], -1, id))
					elseif type == PickupVariant.PICKUP_TRINKET then
						table.insert(coopHUD.players[player_no].collectibles,
						             coopHUD.Trinket(coopHUD.players[player_no], -1, id))
					end
				end
				--load gulped_trinkets and un roll able
				for _, item_id in pairs(player_save.gulped_trinkets) do
					local type, id = item_id[1], item_id[2]
					if type == PickupVariant.PICKUP_COLLECTIBLE then
						table.insert(coopHUD.players[player_no].gulped_trinkets,
						             coopHUD.Item(coopHUD.players[player_no], -1, id))
					elseif type == PickupVariant.PICKUP_TRINKET then
						table.insert(coopHUD.players[player_no].gulped_trinkets,
						             coopHUD.Trinket(coopHUD.players[player_no].entPlayer, -1, id))
					end
				end
				coopHUD.players[player_no].hold_spell = player_save.hold_spell
			end
			--
		end
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
	-- reloads hud icons for golden keys/bombs etc.
	coopHUD.HUD.coins = coopHUD.RunInfo(coopHUD.RunInfo.COIN)
	coopHUD.HUD.bombs = coopHUD.RunInfo(coopHUD.RunInfo.BOMB)
	coopHUD.HUD.keys = coopHUD.RunInfo(coopHUD.RunInfo.KEY)
end)
--  MC_POST_PLAYER_UPDATE -- responsible for update of player
-- triggers streak text on item pickup based on QueuedItem
-- adds items to collectibles based on QueuedItem
coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, entPlayer)
	local player_index = coopHUD.getPlayerNumByControllerIndex(entPlayer.ControllerIndex)
	if player_index >= 0 and coopHUD.players[player_index] then
		coopHUD.players[player_index]:update()
		-- triggers essau update
		if coopHUD.players[player_index].essau then coopHUD.players[player_index].essau:update() end
		-- triggers sub player hearts update
		if coopHUD.players[player_index].sub_hearts then coopHUD.players[player_index].sub_hearts:update() end
		-- triggers poops update
		if coopHUD.players[player_index].poops then coopHUD.players[player_index].poops:update() end
		--
		local item_queue = coopHUD.players[player_index].entPlayer.QueuedItem
		if item_queue and item_queue.Item and item_queue.Item ~= nil and coopHUD.players[player_index].temp_item == nil then
			-- enters only if isaac is holding item in queue and temp item in table
			coopHUD.players[player_index].temp_item = item_queue.Item -- saves as temp item
			--____ Flashes triggers streak text with picked up name
			local streak_main_line = item_queue.Item.Name
			local streak_sec_line = item_queue.Item.Description
			if coopHUD.langAPI then
				-- checks if langAPI loaded
				if string.sub(streak_main_line, 0, 1) == "#" then
					-- if begins with # get name from api
					streak_main_line = coopHUD.langAPI.getItemName(string.sub(streak_main_line, 2))
				end
				if string.sub(streak_sec_line, 0, 1) == "#" then
					-- if begins with # get desc from api
					streak_sec_line = coopHUD.langAPI.getItemName(string.sub(streak_sec_line, 2))
				end
			end
			-- triggers streak on item pickup
			coopHUD.Streak(false, coopHUD.Streak.ITEM, streak_main_line, streak_sec_line, true,
			               coopHUD.players[player_index].font_color)
			--
			if coopHUD.players[player_index].temp_item.Type == ItemType.ITEM_ACTIVE then
			elseif coopHUD.players[player_index].temp_item.Type == ItemType.ITEM_TRINKET then
			else
				-- triggers only for passive items and familiars
				-- holds non roll able items and adds it to gulped_trinkets
				local non_roll = {[CollectibleType.COLLECTIBLE_KEY_PIECE_1] = true,
				                  [CollectibleType.COLLECTIBLE_KEY_PIECE_2] = true,
				                  [CollectibleType.COLLECTIBLE_MISSING_NO] = true,
				                  [CollectibleType.COLLECTIBLE_POLAROID] = true,
				                  [CollectibleType.COLLECTIBLE_NEGATIVE] = true,
				                  [CollectibleType.COLLECTIBLE_DAMOCLES] = true,
				                  [CollectibleType.COLLECTIBLE_KNIFE_PIECE_1] = true,
				                  [CollectibleType.COLLECTIBLE_KNIFE_PIECE_2] = true,
				                  [CollectibleType.COLLECTIBLE_DOGMA] = true,
				                  [CollectibleType.COLLECTIBLE_DADS_NOTE] = true,
				                  [CollectibleType.COLLECTIBLE_BIRTHRIGHT] = true, }
				if non_roll[coopHUD.players[player_index].temp_item.ID] then
					table.insert(coopHUD.players[player_index].gulped_trinkets,
					             coopHUD.Item(coopHUD.players[player_index], -1,
					                          coopHUD.players[player_index].temp_item.ID))
				else
					if coopHUD.players[player_index].entPlayer:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
						local max_collectibles = 8
						if coopHUD.players[player_index].entPlayer:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
							max_collectibles = 12
						end
						if #coopHUD.players[player_index].collectibles == max_collectibles then
							coopHUD.players[player_index].collectibles[1] = coopHUD.Item(coopHUD.players[player_index],
							                                                             -1,
							                                                             coopHUD.players[player_index].temp_item.ID)
						else
							table.insert(coopHUD.players[player_index].collectibles,
							             coopHUD.Item(coopHUD.players[player_index], -1,
							                          coopHUD.players[player_index].temp_item.ID)) -- add picked up item to collectibles
						end
					else
						-- normal characters add collectible
						table.insert(coopHUD.players[player_index].collectibles,
						             coopHUD.Item(coopHUD.players[player_index], -1,
						                          coopHUD.players[player_index].temp_item.ID)) -- add picked up item to collectibles

					end
				end
			end
		end
		if not coopHUD.players[player_index].entPlayer:IsHoldingItem() and coopHUD.players[player_index].temp_item then
			coopHUD.players[player_index].temp_item = nil -- resets temp item
		end
	end
end)
-- MC_USE_PILL
-- triggers streak with pill name on use
coopHUD:AddCallback(ModCallbacks.MC_USE_PILL, function(_, effect_no, entPlayer)
	local player_index = coopHUD.getPlayerNumByControllerIndex(entPlayer.ControllerIndex)
	if player_index >= 0 and coopHUD.players[player_index] then
		local pill_sys_name = Isaac.GetItemConfig():GetPillEffect(effect_no).Name
		pill_sys_name = string.sub(pill_sys_name, 2) --  get rid of # on front of
		coopHUD.Streak(false, coopHUD.Streak.ITEM, coopHUD.langAPI.getPocketName(pill_sys_name), nil, true,
		               coopHUD.players[player_index].font_color)
	end
end)
-- CollectibleType.COLLECTIBLE_SMELTER
-- connect to MC_PRE_USE_ITEM to handle gulping trinkets even when they are currently in entityPlayer.Queue
coopHUD:AddCallback(ModCallbacks.MC_PRE_USE_ITEM,
                    function(_, collectible_type, rng, entPlayer, use_flags, slot, var_data)
	                    -- checks if player currently holding trinket over head
	                    local player_index = coopHUD.getPlayerNumByControllerIndex(entPlayer.ControllerIndex)
	                    if player_index >= 0 and coopHUD.players[player_index] then
		                    if coopHUD.players[player_index].entPlayer.QueuedItem.Item and coopHUD.players[player_index].entPlayer.QueuedItem.Item:IsTrinket() then
			                    table.insert(coopHUD.players[player_index].gulped_trinkets,
			                                 coopHUD.Trinket(nil, -1,
			                                                 coopHUD.players[player_index].entPlayer.QueuedItem.Item.ID))
		                    end
		                    -- checks if player has first trinket
		                    if coopHUD.players[player_index].first_trinket.id > 0 then
			                    -- add to collectibles table
			                    table.insert(coopHUD.players[player_index].gulped_trinkets,
			                                 coopHUD.Trinket(nil, -1, coopHUD.players[player_index].first_trinket.id))
			                    -- checks if player has first secont trinket
			                    if coopHUD.players[player_index].second_trinket.id > 0 then
				                    -- add to collectibles table
				                    table.insert(coopHUD.players[player_index].gulped_trinkets,
				                                 coopHUD.Trinket(nil, -1,
				                                                 coopHUD.players[player_index].second_trinket.id))
			                    end
		                    end
	                    end
                    end, CollectibleType.COLLECTIBLE_SMELTER)
-- CollectibleType.COLLECTIBLE_D4
-- connect to MC_USE_ITEM to handle roll of collectibles
-- Isaac uses use signal of D4 to roll in Dice Room and other occasions
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM,
                    function(_, collectible_type, rng, entPlayer, use_flags, slot, var_data)
	                    local player_index = coopHUD.getPlayerNumByControllerIndex(entPlayer.ControllerIndex)
	                    if player_index >= 0 and coopHUD.players[player_index] then
		                    coopHUD.players[player_index].collectibles = {} -- resets players collectible table
		                    for i = 1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
			                    -- check if player has collectible
			                    if coopHUD.players[player_index].entPlayer:HasCollectible(i) then
				                    -- skips active items
				                    if Isaac.GetItemConfig():GetCollectible(i).Type ~= ItemType.ITEM_ACTIVE then
					                    local non_roll = {[CollectibleType.COLLECTIBLE_KEY_PIECE_1] = true,
					                                      [CollectibleType.COLLECTIBLE_KEY_PIECE_2] = true,
					                                      [CollectibleType.COLLECTIBLE_MISSING_NO] = true,
					                                      [CollectibleType.COLLECTIBLE_POLAROID] = true,
					                                      [CollectibleType.COLLECTIBLE_NEGATIVE] = true,
					                                      [CollectibleType.COLLECTIBLE_DAMOCLES] = true,
					                                      [CollectibleType.COLLECTIBLE_KNIFE_PIECE_1] = true,
					                                      [CollectibleType.COLLECTIBLE_KNIFE_PIECE_2] = true,
					                                      [CollectibleType.COLLECTIBLE_DOGMA] = true,
					                                      [CollectibleType.COLLECTIBLE_DADS_NOTE] = true,
					                                      [CollectibleType.COLLECTIBLE_BIRTHRIGHT] = true, }
					                    if not non_roll then
						                    table.insert(coopHUD.players[player_index].collectibles,
						                                 coopHUD.Item(coopHUD.players[player_index], -1, i))
					                    end
				                    end
			                    end
		                    end
		                    -- adds saved trinkets on top of collectibles table
		                    --[[for i = 1, #trinkets do
			                    table.insert(coopHUD.players[player_index].collectibles, trinkets[i])
		                    end]]
	                    end
                    end, CollectibleType.COLLECTIBLE_D4)
-- CollectibleType.COLLECTIBLE_JAR_OF_WISPS
-- connect to MC_USE_ITEM to handle jar of wisp since no possibility to get var var_data
-- on use will increase global jar_of_wisp use variable
-- FIXME: no charges for multiples jar of wisp instances in one run
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM,
                    function(_, collectible_type, rng, entPlayer, use_flags, slot, var_data)
	                    local player_index = coopHUD.getPlayerNumByControllerIndex(entPlayer.ControllerIndex)
	                    if player_index >= 0 and coopHUD.players[player_index] then
		                    if coopHUD.jar_of_wisp_charge < 11 then
			                    -- max charge 12
			                    coopHUD.jar_of_wisp_charge = coopHUD.jar_of_wisp_charge + 1 --increase charge
		                    end
	                    end

                    end, CollectibleType.COLLECTIBLE_JAR_OF_WISPS)
--CollectibleType.COLLECTIBLE_HOLD
--connect to MC_USE_ITEM to handle hold current spell, cannot get from Isaac API
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM,
                    function(_, collectible_type, rng, entPlayer, use_flags, slot, var_data)
	                    local player_index = coopHUD.getPlayerNumByControllerIndex(entPlayer.ControllerIndex)
	                    if player_index >= 0 and coopHUD.players[player_index]
			                    and (coopHUD.players[player_index].poops.poop_mana > 0) then
		                    if coopHUD.players[player_index].hold_spell == 0 then
			                    coopHUD.players[player_index].hold_spell = coopHUD.players[player_index].poops.poops[0].spell_type
		                    else
			                    coopHUD.players[player_index].hold_spell = 0
		                    end
	                    end
	                    if coopHUD.players[player_index].poops.poop_mana == 0 then
		                    -- resets frame if no mana
		                    coopHUD.players[player_index].hold_spell = 0
	                    end
	                    coopHUD.players[player_index].first_pocket:update()
                    end, CollectibleType.COLLECTIBLE_HOLD)
-- Bag of crafting
-- _____ Modified EID Wolsauge bag of crafting functions
-- Debug:changed pickupsOnInit to global:fixme: chage to local
pickupsOnInit = {} -- holds all items in rooms whick can be collected by bag of crafting
---Function triggered when bag of crafting collecting beam is initiated
---connected to ModCallbacks.MC_POST_KNIFE_INIT
---it collect all pickup entities to maintain BoC collection
coopHUD:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, function(_, entity)
	if entity.Variant ~= 4 then
		-- prevention from false init
		return
	end
	pickupsOnInit = {} --resets pickup entity table
	for _, e in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, -1, -1, false, false)) do
		-- pass all pickup entities
		if e:GetSprite():GetAnimation() ~= "Collect" then
			-- checks is not in collect state
			if coopHUD.getCraftingItemId(e.Variant, e.SubType)  ~= nil then
				table.insert(pickupsOnInit,e)  -- adds it to pickupsOnInit table
			end
		end
	end
end, 4)
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
		-- DROP ACTION
		if Input.IsActionTriggered(ButtonAction.ACTION_DROP, controller_index) then
			if coopHUD.players[player_index].entPlayer:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
				if coopHUD.players[player_index].collectibles ~= nil then
					local collectibles = {}
					for i = 2, #coopHUD.players[player_index].collectibles do
						table.insert(collectibles, coopHUD.players[player_index].collectibles[i])
					end
					table.insert(collectibles, coopHUD.players[player_index].collectibles[1])
					coopHUD.players[player_index].collectibles = collectibles
				end
			end
		end
	end
	-- MAP BUTTON
	local pressTime = 0.5
	if mapPressed then
		btn_held = btn_held + 1 / 60
		if btn_held > pressTime then
			coopHUD.signals.map = mapPressed
			coopHUD.Streak(true, coopHUD.Streak.FLOOR)
			if btn_held > 1.5 then
				if coopHUD.options.show_my_stuff then
					coopHUD.Collectibles(coopHUD.players[coopHUD.signals.map])
				end
			end
			coopHUD.players[mapPressed].signals.map_btn = true
		end
	else
		if coopHUD.signals.map then
			coopHUD.players[coopHUD.signals.map].signals.map_btn = false
		end
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
				if Game():GetHUD():IsVisible() then
					Game():GetHUD():SetVisible(false)
				end
				coopHUD.players[i]:render()
				coopHUD.HUD.render()
			end
			if not coopHUD.options.onRender or coopHUD.signals.is_joining then
				if not Game():GetHUD():IsVisible() then
					Game():GetHUD():SetVisible(true)
				end
			end
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)