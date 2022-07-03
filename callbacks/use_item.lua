-- CollectibleType.COLLECTIBLE_SMELTER
-- connect to MC_PRE_USE_ITEM to handle gulping trinkets even when they are currently in entityPlayer.Queue
coopHUD:AddCallback(ModCallbacks.MC_PRE_USE_ITEM,
                    function(_, collectible_type, rng, entPlayer, use_flags, slot, var_data)
	                    -- gets coopHUD.Player by entity Index
	                    local player = coopHUD.Player.getByEntityIndex(entPlayer.Index)
	                    if player then
		                    -- checks if player currently holding trinket over head
		                    if player.entPlayer.QueuedItem.Item and player.entPlayer.QueuedItem.Item:IsTrinket() then
			                    table.insert(player.gulped_trinkets,
			                                 coopHUD.Trinket(nil, -1,
			                                                 player.entPlayer.QueuedItem.Item.ID))
		                    end
		                    -- checks if player has first trinket
		                    if player.first_trinket.id > 0 then
			                    -- add to collectibles table
			                    table.insert(player.gulped_trinkets,
			                                 coopHUD.Trinket(nil, -1, player.first_trinket.id))
			                    -- checks if player has first secont trinket
			                    if player.second_trinket.id > 0 then
				                    -- add to collectibles table
				                    table.insert(player.gulped_trinkets,
				                                 coopHUD.Trinket(nil, -1,
				                                                 player.second_trinket.id))
			                    end
		                    end
	                    end
                    end, CollectibleType.COLLECTIBLE_SMELTER)
-- CollectibleType.COLLECTIBLE_D4
-- connect to MC_USE_ITEM to handle roll of collectibles
-- Isaac uses use signal of D4 to roll in Dice Room and other occasions
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM,
                    function(_, collectible_type, rng, entPlayer, use_flags, slot, var_data)
	                    local player = coopHUD.Player.getByEntityIndex(entPlayer.Index)
	                    if player then
		                    player.collectibles = {} -- resets players collectible table
		                    for i = 1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
			                    -- check if player has collectible
			                    if player.entPlayer:HasCollectible(i) then
				                    -- skips active items
				                    if Isaac.GetItemConfig():GetCollectible(i).Type ~= ItemType.ITEM_ACTIVE then
					                    table.insert(player.collectibles,
					                                 coopHUD.Item(player, -1, i))
				                    end
			                    end
		                    end
	                    end
                    end, CollectibleType.COLLECTIBLE_D4)
-- CollectibleType.COLLECTIBLE_JAR_OF_WISPS
-- connect to MC_USE_ITEM to handle jar of wisp since no possibility to get var var_data
-- on use will increase global jar_of_wisp use variable
-- FIXME: no charges for multiples jar of wisp instances in one run
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM,
                    function(_, collectible_type, rng, entPlayer, use_flags, slot, var_data)
	                    local player_index = coopHUD.Player.getIndexByControllerIndex(entPlayer.ControllerIndex)
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
	                    local player_index = coopHUD.Player.getIndexByControllerIndex(entPlayer.ControllerIndex)
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
---CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING
---connect to MC_USE_ITEM to handle bag of crafting reset when crafted item playing as no T.Cain
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM,
                    function(_, collectible_type, rng, entPlayer, use_flags, slot, var_data)
	                    local player_index = coopHUD.Player.getIndexByControllerIndex(entPlayer.ControllerIndex)
	                    if entPlayer:GetPlayerType() ~= PlayerType.PLAYER_CAIN_B then
		                    if #coopHUD.players[player_index].bag_of_crafting == 8 then
			                    coopHUD.players[player_index].bag_of_crafting = {}
		                    end
	                    end
                    end, CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING)