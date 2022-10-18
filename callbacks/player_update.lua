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
			-- enters only if isaac is holding item in queue and temp item is nil
			player.temp_item = item_queue.Item -- saves as temp item
			--__ Triggers streak
			coopHUD.Streak(false, coopHUD.Streak.ITEM, coopHUD.langAPI.getItemNameByID(player.temp_item.ID),
			               coopHUD.langAPI.getItemDescByID(player.temp_item.ID),
			               true, player.font_color)
		elseif not player.entPlayer:IsHoldingItem() and player.temp_item then
			player:addItem()
		end
	end
end)