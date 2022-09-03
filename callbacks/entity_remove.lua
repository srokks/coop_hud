coopHUD.floor_custom_items = {}
---@param entity Entity
function coopHUD.entRemove(_, entity)
	if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
		if entity.SubType == CollectibleType.COLLECTIBLE_PLACEBO or
				entity.SubType == CollectibleType.COLLECTIBLE_BLANK_CARD or
				entity.SubType == CollectibleType.COLLECTIBLE_CLEAR_RUNE or
				entity.SubType == CollectibleType.COLLECTIBLE_D_INFINITY then
			local item_var_data = coopHUD.Item:get_custom_charge_and_reset(entity.SubType)
			if item_var_data then
				table.insert(coopHUD.floor_custom_items,item_var_data)
			end
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, coopHUD.entRemove, EntityType.ENTITY_PICKUP)