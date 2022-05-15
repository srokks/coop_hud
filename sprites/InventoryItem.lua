coopHUD.InventoryItem = {}
coopHUD.InventoryItem.__index = coopHUD.InventoryItem
setmetatable(coopHUD.InventoryItem, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.InventoryItem.new(entity)
	local self = setmetatable({}, coopHUD.InventoryItem)
	--self.variant = entity.Variant
	--self.sub_type = entity.SubType
	print(entity)
end

---coopHUD.getCraftingItemId
---@param Variant Entity.Variant
---@param Variant Entity.SubType
---@return table with ids of BoC components
function coopHUD.InventoryItem.getCraftingItemId()
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
		["30.3"] = {12, 12}, -- Key Ring
		["30.4"] = {14}, -- charged Key
		["40.1"] = {15}, -- bomb
		["40.2"] = {15, 15}, -- double bomb
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
	local entry = pickupIDLookup[Variant .. "." .. SubType]
	if entry ~= nil then
		return entry
	elseif Variant == 300 then
		if SubType == 0 then
			-- player:GetCard() returned 0
			return nil
		elseif SubType > 80 or (SubType >= 32 and SubType <= 41) or SubType == 55 then
			-- runes
			return {23}
		else
			-- cards
			return {21}
		end
	elseif Variant == 70 then
		-- pills
		if SubType == 0 then
			-- player:GetPill() returned 0
			return nil
		else
			return {22}
		end
	end
	return nil
end