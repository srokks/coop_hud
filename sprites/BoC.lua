coopHUD.BoC = {}
coopHUD.BoC.__index = coopHUD.BoC
coopHUD.BoC.Item = {}
coopHUD.BoC.Item.__index = coopHUD.BoC.Item
setmetatable(coopHUD.BoC.Item, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.BoC.Item.new(id)
	local self = setmetatable({}, coopHUD.BoC.Item)
	self.id = id
	if self.id == nil then return nil end
	self.value = self.getItemValue(self)
	self.sprite = self.getSprite(self)
	return self
end
---coopHUD.getCraftingItemId
---@param Variant Entity.Variant
---@param Variant Entity.SubType
---@return table with ids of BoC components
function coopHUD.BoC.Item.getCraftingItemId(entity)
	local Variant = entity.Variant
	local SubType = entity.SubType
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
function coopHUD.BoC.Item.getItemValue(self)
	local pickupValues = {
		0x00000000, -- 0 None
		-- Hearts
		0x00000001, -- 1 Red Heart
		0x00000004, -- 2 Soul Heart
		0x00000005, -- 3 Black Heart
		0x00000005, -- 4 Eternal Heart
		0x00000005, -- 5 Gold Heart
		0x00000005, -- 6 Bone Heart
		0x00000001, -- 7 Rotten Heart
		-- Pennies
		0x00000001, -- 8 Penny
		0x00000003, -- 9 Nickel
		0x00000005, -- 10 Dime
		0x00000008, -- 11 Lucky Penny
		-- Keys
		0x00000002, -- 12 Key
		0x00000007, -- 13 Golden Key
		0x00000005, -- 14 Charged Key
		-- Bombs
		0x00000002, -- 15 Bomb
		0x00000007, -- 16 Golden Bomb
		0x0000000a, -- 17 Giga Bomb
		-- Batteries
		0x00000002, -- 18 Micro Battery
		0x00000004, -- 19 Lil' Battery
		0x00000008, -- 20 Mega Battery
		-- Usables
		0x00000002, -- 21 Card
		0x00000002, -- 22 Pill
		0x00000004, -- 23 Rune
		0x00000004, -- 24 Dice Shard
		0x00000002, -- 25 Cracked Key
		-- Added in Update
		0x00000007, -- 26 Golden Penny
		0x00000007, -- 27 Golden Pill
		0x00000007, -- 28 Golden Battery
		0x00000000, -- 29 Tainted ??? Poop

		0x00000001,
	}
	return pickupValues[self.id]
end