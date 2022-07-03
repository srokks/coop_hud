--  MC_POST_PLAYER_UPDATE -- responsible for update of player
-- triggers streak text on item pickup based on QueuedItem
-- adds items to collectibles based on QueuedItem
coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, entPlayer)
	local player = coopHUD.Player.getByEntityIndex(entPlayer.Index)
	if player then
		player:update()
		-- triggers sub player hearts update
		if player.sub_hearts then
			player.sub_hearts:update()
		end
		-- triggers poops update
		if player.poops then
			player.poops:update()
		end
		--
		local item_queue = player.entPlayer.QueuedItem
		if item_queue and item_queue.Item and item_queue.Item ~= nil and player.temp_item == nil then
			-- enters only if isaac is holding item in queue and temp item in table
			player.temp_item = item_queue.Item -- saves as temp item
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
			               player.font_color)
			--
			if player.temp_item.Type == ItemType.ITEM_ACTIVE then
			elseif player.temp_item.Type == ItemType.ITEM_TRINKET then
			else
				-- triggers only for passive items and familiars
				-- holds non roll able items and adds it to gulped_trinkets
				local non_roll = { [CollectibleType.COLLECTIBLE_KEY_PIECE_1]   = true,
				                   [CollectibleType.COLLECTIBLE_KEY_PIECE_2]   = true,
				                   [CollectibleType.COLLECTIBLE_MISSING_NO]    = true,
				                   [CollectibleType.COLLECTIBLE_POLAROID]      = true,
				                   [CollectibleType.COLLECTIBLE_NEGATIVE]      = true,
				                   [CollectibleType.COLLECTIBLE_DAMOCLES]      = true,
				                   [CollectibleType.COLLECTIBLE_KNIFE_PIECE_1] = true,
				                   [CollectibleType.COLLECTIBLE_KNIFE_PIECE_2] = true,
				                   [CollectibleType.COLLECTIBLE_DOGMA]         = true,
				                   [CollectibleType.COLLECTIBLE_DADS_NOTE]     = true,
				                   [CollectibleType.COLLECTIBLE_BIRTHRIGHT]    = true, }
				if non_roll[player.temp_item.ID] then
					table.insert(player.gulped_trinkets,
					             coopHUD.Item(player, -1,
					                          player.temp_item.ID))
				else
					if player.entPlayer:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
						local max_collectibles = 8
						if player.entPlayer:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
							max_collectibles = 12
						end
						if #player.collectibles == max_collectibles then
							player.collectibles[1] = coopHUD.Item(player,
							                                      -1,
							                                      player.temp_item.ID)
						else
							table.insert(player.collectibles,
							             coopHUD.Item(player, -1,
							                          player.temp_item.ID)) -- add picked up item to collectibles
						end
					else
						-- normal characters add collectible
						table.insert(player.collectibles,
						             coopHUD.Item(player, -1,
						                          player.temp_item.ID)) -- add picked up item to collectibles
					end
				end
			end
		end
		if not player.entPlayer:IsHoldingItem() and player.temp_item then
			player.temp_item = nil -- resets temp item
		end
	end
end)