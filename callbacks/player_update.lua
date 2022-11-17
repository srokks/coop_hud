--  MC_POST_PLAYER_UPDATE -- responsible for update of player
-- triggers streak text on item pickup based on QueuedItem
-- adds items to collectibles based on QueuedItem
coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, entPlayer)
	local player = coopHUD.Player.getByEntityIndex(entPlayer.Index)
	if player then
		player:update()
		--
		local item_queue = player.entPlayer.QueuedItem
		if item_queue and item_queue.Item and item_queue.Item ~= nil and player.temp_item == nil then
			-- enters only if isaac is holding item in queue and temp item is nil
			---@type ItemConfigItem
			player.temp_item = item_queue.Item -- saves as temp item
			--__ Triggers streak
			coopHUD.Streak(false, coopHUD.Streak.ITEM, coopHUD.langAPI.getItemName(player.temp_item),
			               coopHUD.langAPI.getItemDesc(player.temp_item),
			               true, player.font_color)
		elseif not player.entPlayer:IsHoldingItem() and player.temp_item then
			player:addItem()
		end
	end
end)