--- BAG COLLECT LOGIC ---
-- _____ Modified EID Wolsauge bag of crafting functions
local pickups_collected = {} -- table of collected pickup indexes, TODO:reset each room
local pickups_just_touched = {} -- flags of pickups a player/pickup-collector has touched, so the bag doesn't think it collected it
coopHUD:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider, _)
	if collider.Type == EntityType.ENTITY_PLAYER or collider.Type == EntityType.ENTITY_FAMILIAR or
			collider.Type == EntityType.ENTITY_BUMBINO or collider.Type == EntityType.ENTITY_ULTRA_GREED then
		pickups_just_touched[pickup.Index] = true
	end
end)
---ModCallbacks.MC_PRE_ENTITY_SPAWN --
local last_bag = nil --holds last used bag of crafting, this is set by removed bag entity (beam) and by triggering to open a bag
---watches when bag of crafting collecting beam appears and sets last bag local variable to player index in coopHUD.players
coopHUD:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, _, Variant, SubType, _, _, Spawner, _)
	if Variant == 4 and SubType == 4 then
		pill_card_pressed = false -- resets signal for creating item if pressed attack buttton
		pill_held = 0
		last_bag = coopHUD.Player.getIndexByControllerIndex(Spawner:ToPlayer().ControllerIndex)
	end
end)
---ModCallbacks.MC_POST_ENTITY_REMOVE
---watches when Bag of Crafting collecting beam ent is removed and resets las bag value
coopHUD:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, bag)
	if bag.Variant == 4 and bag.SubType == 4 and last_bag ~= nil then
		last_bag = nil
	end
end)
---ModCallbacks.MC_POST_PICKUP_UPDATE - bag of crafting collecting logic
---function runs over all entities in room, check if them are in collect state and add to player bag
---uses local last_bag variable as player index
coopHUD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function()
	for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, -1, -1, false, false)) do
		if pickup:GetSprite():GetAnimation() == "Collect" and not pickups_collected[pickup.Index] then
			if last_bag then
				-- prevents from load when bag is not in use
				pickups_collected[pickup.Index] = true
				if not pickups_just_touched[pickup.Index] then
					-- gets table of crafting items for BoC use
					local craftingIDs = coopHUD.BoC.Item.getCraftingItemId(pickup)
					if craftingIDs ~= nil then
						for _, item_id in ipairs(craftingIDs) do
							-- checks if bag is full
							if #coopHUD.players[last_bag].bag_of_crafting >= 8 then
								table.remove(coopHUD.players[last_bag].bag_of_crafting, 1)
							end
							-- inserts ito bag and BoC.Item
							table.insert(coopHUD.players[last_bag].bag_of_crafting, coopHUD.BoC.Item(item_id))
							coopHUD.BoC.update(coopHUD.players[last_bag])
						end
					end
				end
			end
		end
		pickups_just_touched[pickup.Index] = nil -- resets touched room pickups
	end
end)