local anim_path = "gfx/ui/ui_crafting.anm2"
---@class coopHUD.BoC
---@field Item fun(id:number):coopHUD.BoC.Item
---@type coopHUD.BoC
coopHUD.BoC = {}
coopHUD.BoC.__index = coopHUD.BoC
---@class coopHUD.BoC.Item
coopHUD.BoC.Item = {}
coopHUD.BoC.Item.__index = coopHUD.BoC.Item
setmetatable(coopHUD.BoC.Item, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@private
function coopHUD.BoC.Item.new(id)
	local self = setmetatable({}, coopHUD.BoC.Item)
	self.id = id
	if self.id == nil then
		return nil
	end
	self.value = self.getItemValue(self.id)
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
		["10.1"]    = { 1 }, -- Red heart
		["10.2"]    = { 1 }, -- half heart
		["10.3"]    = { 2 }, -- soul heart
		["10.4"]    = { 4 }, -- eternal heart
		["10.5"]    = { 1, 1 }, -- double heart
		["10.6"]    = { 3 }, -- black heart
		["10.7"]    = { 5 }, -- gold heart
		["10.8"]    = { 2 }, -- half soul heart
		["10.9"]    = { 1 }, -- scared red heart
		["10.10"]   = { 2, 1 }, -- blended heart
		["10.11"]   = { 6 }, -- Bone heart
		["10.12"]   = { 7 }, -- Rotten heart
		["20.1"]    = { 8 }, -- Penny
		["20.2"]    = { 9 }, -- Nickel
		["20.3"]    = { 10 }, -- Dime
		["20.4"]    = { 8, 8 }, -- Double penny
		["20.5"]    = { 11 }, -- Lucky Penny
		["20.6"]    = { 9 }, -- Sticky Nickel
		["20.7"]    = { 26 }, -- Golden Penny
		["30.1"]    = { 12 }, -- Key
		["30.2"]    = { 13 }, -- golden Key
		["30.3"]    = { 12, 12 }, -- Key Ring
		["30.4"]    = { 14 }, -- charged Key
		["40.1"]    = { 15 }, -- bomb
		["40.2"]    = { 15, 15 }, -- double bomb
		["40.4"]    = { 16 }, -- golden bomb
		["40.7"]    = { 17 }, -- giga bomb
		["42.0"]    = { 29 }, -- poop nugget
		["42.1"]    = { 29 }, -- big poop nugget
		["70.14"]   = { 27 }, -- golden pill
		["70.2062"] = { 27 }, -- golden horse pill
		["90.1"]    = { 19 }, -- Lil Battery
		["90.2"]    = { 18 }, -- Micro Battery
		["90.3"]    = { 20 }, -- Mega Battery
		["90.4"]    = { 28 }, -- Golden Battery
		["300.49"]  = { 24 }, -- Dice shard
		["300.50"]  = { 21 }, -- Emergency Contact
		["300.78"]  = { 25 }, -- Cracked key
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
			return { 23 }
		else
			-- cards
			return { 21 }
		end
	elseif Variant == 70 then
		-- pills
		if SubType == 0 then
			-- player:GetPill() returned 0
			return nil
		else
			return { 22 }
		end
	end
	return nil
end
function coopHUD.BoC.Item.getItemValue(id)
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
	return pickupValues[id]
end
function coopHUD.BoC.Item.getSprite(self)
	local sprite = Sprite()
	sprite:Load(anim_path, true)
	sprite:SetFrame('Idle', self.id)
	return sprite
end
--- Renders item sprite in desired position
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@param dim boolean defines if dim sprite
---@return Vector offset where render next sprite
function coopHUD.BoC.Item:render(pos, mirrored, scale, down_anchor, dim)
	local temp_pos = Vector(pos.X + 4, pos.Y + 4)
	local off = Vector(0, 0)
	local pivot = Vector(10, 10)
	if mirrored then
	end
	if down_anchor then
		temp_pos.Y = temp_pos.Y - 10
		pivot.Y = pivot.Y * -1
	end
	if self.sprite then
		off = off + pivot
		self.sprite:Render(temp_pos)
	end
	return off
end
--- Renders Bag of Crafting - items + result in desired position
---@param player coopHUD.Player position where render sprite
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param down_anchor boolean change anchor to down corner
---@return Vector offset where render next sprite
function coopHUD.BoC:render(player, pos, mirrored, down_anchor)
	local init_pos = Vector(pos.X, pos.Y + 2)
	if down_anchor then
		init_pos.Y = init_pos.Y - 22
	end
	if mirrored then
		init_pos.X = init_pos.X - 76
	end
	-- renders items
	local temp_pos = Vector(init_pos.X, init_pos.Y)
	for i = 1, 8 do
		if player.bag_of_crafting[i] ~= nil then
			local off = player.bag_of_crafting[i]:render(temp_pos) -- renders BoC.Item
			temp_pos.X = temp_pos.X + off.X
		else
			local off = coopHUD.BoC.EmptyItem:render(temp_pos) -- renders empty item spot
			temp_pos.X = temp_pos.X + off.X
		end
		if i == 4 then
			temp_pos = Vector(init_pos.X, init_pos.Y + 10)
		end
	end
	-- renders result box
	--TODO: dim when no result item
	temp_pos = Vector(init_pos.X + 60, init_pos.Y + 6)
	coopHUD.BoC.Result:render(temp_pos)
	if player.crafting_result ~= nil then
		temp_pos = Vector(init_pos.X + 48, init_pos.Y - 6)
		if mirrored then
			temp_pos.X = temp_pos.X + 32
		end
		if down_anchor then
			temp_pos.Y = temp_pos.Y + 32
		end
		if #player.bag_of_crafting == 8 then
			if Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND > 0 then
				coopHUD.BoC.Unknown:render(temp_pos, mirrored, Vector(1, 1), down_anchor)
			else
				player.crafting_result:render(temp_pos, mirrored, Vector(1, 1), down_anchor)
			end
		end
	end
end
-- empty item (dot) sprite object
coopHUD.BoC.EmptyItem = coopHUD.BoC.Item(0)
-- result item frame sprite object
coopHUD.BoC.Result = coopHUD.BoC.Item(0)
coopHUD.BoC.Result.sprite:SetFrame("Result", 0)
coopHUD.BoC.Unknown = coopHUD.Item({ entPlayer = false }, -1, 1)
coopHUD.BoC.Unknown.sprite:ReplaceSpritesheet(0, "gfx/items/collectibles/questionmark.png") -- item
coopHUD.BoC.Unknown.sprite:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png") -- border
coopHUD.BoC.Unknown.sprite:ReplaceSpritesheet(2, "gfx/items/collectibles/questionmark.png") -- shadow
coopHUD.BoC.Unknown.sprite:LoadGraphics()
--- handles Bag od crafting update
--- CONNECTED TO: MC_POST_PICKUP_UPDATE
function coopHUD.BoC.update(player)
	local player_bag = player.bag_of_crafting
	if #player_bag == 8 then
		local result = coopHUD.BoC.calculate(player)
		player.crafting_result = coopHUD.Item(player, -1, result)
	else
		player.crafting_result = coopHUD.Item(player, -1, 0)
	end
end
--- handles Bag of Crafting recipe calculation
--- it unpack bag of crafting to components table for calculate
---@param player coopHUD.Player
---@return number item id
function coopHUD.BoC.calculate(player)
	local bag = {}
	for _, k in pairs(player.bag_of_crafting) do
		table.insert(bag, k.id)
	end
	local components = { table.unpack(bag) }
	local id_a, id_b = coopHUD.BoC.calculateBagOfCrafting(components)
	if coopHUD.isCollectibleUnlockedAnyPool(id_a) then
		return id_a
	else
		return id_b
	end
end
-- BAG CALCULATION FUNCTIONS
-- adopted functions from External Item Descriptions mod by Wolfsauge - https://steamcommunity.com/sharedfiles/filedetails/?id=836319872
local xml_data = include('helpers.xml_data.lua')
--

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

local componentShifts = {
	{ 0x00000001, 0x00000005, 0x00000010 },
	{ 0x00000001, 0x00000005, 0x00000013 },
	{ 0x00000001, 0x00000009, 0x0000001D },
	{ 0x00000001, 0x0000000B, 0x00000006 },
	{ 0x00000001, 0x0000000B, 0x00000010 },
	{ 0x00000001, 0x00000013, 0x00000003 },
	{ 0x00000001, 0x00000015, 0x00000014 },
	{ 0x00000001, 0x0000001B, 0x0000001B },
	{ 0x00000002, 0x00000005, 0x0000000F },
	{ 0x00000002, 0x00000005, 0x00000015 },
	{ 0x00000002, 0x00000007, 0x00000007 },
	{ 0x00000002, 0x00000007, 0x00000009 },
	{ 0x00000002, 0x00000007, 0x00000019 },
	{ 0x00000002, 0x00000009, 0x0000000F },
	{ 0x00000002, 0x0000000F, 0x00000011 },
	{ 0x00000002, 0x0000000F, 0x00000019 },
	{ 0x00000002, 0x00000015, 0x00000009 },
	{ 0x00000003, 0x00000001, 0x0000000E },
	{ 0x00000003, 0x00000003, 0x0000001A },
	{ 0x00000003, 0x00000003, 0x0000001C },
	{ 0x00000003, 0x00000003, 0x0000001D },
	{ 0x00000003, 0x00000005, 0x00000014 },
	{ 0x00000003, 0x00000005, 0x00000016 },
	{ 0x00000003, 0x00000005, 0x00000019 },
	{ 0x00000003, 0x00000007, 0x0000001D },
	{ 0x00000003, 0x0000000D, 0x00000007 },
	{ 0x00000003, 0x00000017, 0x00000019 },
	{ 0x00000003, 0x00000019, 0x00000018 },
	{ 0x00000003, 0x0000001B, 0x0000000B },
	{ 0x00000004, 0x00000003, 0x00000011 },
	{ 0x00000004, 0x00000003, 0x0000001B },
	{ 0x00000004, 0x00000005, 0x0000000F },
	{ 0x00000005, 0x00000003, 0x00000015 },
	{ 0x00000005, 0x00000007, 0x00000016 },
	{ 0x00000005, 0x00000009, 0x00000007 },
	{ 0x00000005, 0x00000009, 0x0000001C },
	{ 0x00000005, 0x00000009, 0x0000001F },
	{ 0x00000005, 0x0000000D, 0x00000006 },
	{ 0x00000005, 0x0000000F, 0x00000011 },
	{ 0x00000005, 0x00000011, 0x0000000D },
	{ 0x00000005, 0x00000015, 0x0000000C },
	{ 0x00000005, 0x0000001B, 0x00000008 },
	{ 0x00000005, 0x0000001B, 0x00000015 },
	{ 0x00000005, 0x0000001B, 0x00000019 },
	{ 0x00000005, 0x0000001B, 0x0000001C },
	{ 0x00000006, 0x00000001, 0x0000000B },
	{ 0x00000006, 0x00000003, 0x00000011 },
	{ 0x00000006, 0x00000011, 0x00000009 },
	{ 0x00000006, 0x00000015, 0x00000007 },
	{ 0x00000006, 0x00000015, 0x0000000D },
	{ 0x00000007, 0x00000001, 0x00000009 },
	{ 0x00000007, 0x00000001, 0x00000012 },
	{ 0x00000007, 0x00000001, 0x00000019 },
	{ 0x00000007, 0x0000000D, 0x00000019 },
	{ 0x00000007, 0x00000011, 0x00000015 },
	{ 0x00000007, 0x00000019, 0x0000000C },
	{ 0x00000007, 0x00000019, 0x00000014 },
	{ 0x00000008, 0x00000007, 0x00000017 },
	{ 0x00000008, 0x00000009, 0x00000017 },
	{ 0x00000009, 0x00000005, 0x0000000E },
	{ 0x00000009, 0x00000005, 0x00000019 },
	{ 0x00000009, 0x0000000B, 0x00000013 },
	{ 0x00000009, 0x00000015, 0x00000010 },
	{ 0x0000000A, 0x00000009, 0x00000015 },
	{ 0x0000000A, 0x00000009, 0x00000019 },
	{ 0x0000000B, 0x00000007, 0x0000000C },
	{ 0x0000000B, 0x00000007, 0x00000010 },
	{ 0x0000000B, 0x00000011, 0x0000000D },
	{ 0x0000000B, 0x00000015, 0x0000000D },
	{ 0x0000000C, 0x00000009, 0x00000017 },
	{ 0x0000000D, 0x00000003, 0x00000011 },
	{ 0x0000000D, 0x00000003, 0x0000001B },
	{ 0x0000000D, 0x00000005, 0x00000013 },
	{ 0x0000000D, 0x00000011, 0x0000000F },
	{ 0x0000000E, 0x00000001, 0x0000000F },
	{ 0x0000000E, 0x0000000D, 0x0000000F },
	{ 0x0000000F, 0x00000001, 0x0000001D },
	{ 0x00000011, 0x0000000F, 0x00000014 },
	{ 0x00000011, 0x0000000F, 0x00000017 },
	{ 0x00000011, 0x0000000F, 0x0000001A }
}

local customRNGSeed = 0x77777770
local customRNGShift = { 0, 0, 0 }

-- Use local RNG functions to possibly reduce processing time a little bit
local function RNGNext()
	local num = customRNGSeed
	num = num ~ ((num >> customRNGShift[1]) & 4294967295)
	num = num ~ ((num << customRNGShift[2]) & 4294967295)
	num = num ~ ((num >> customRNGShift[3]) & 4294967295)
	customRNGSeed = num >> 0;
	return customRNGSeed;
end

local function nextFloat()
	local multi = 2.3283061589829401E-10;
	return RNGNext() * multi;
end

-- The icon each item pool will use in the No Recipes display
local poolToIcon = { [0] = "{{TreasureRoom}}", [1] = "{{Shop}}", [2] = "{{BossRoom}}", [3] = "{{DevilRoom}}", [4] = "{{AngelRoom}}",
                     [5] = "{{SecretRoom}}", [7] = "{{PoopRoomIcon}}", [8] = "{{GoldenChestRoomIcon}}", [9] = "{{RedChestRoomIcon}}", [12] = "{{CursedRoom}}", [26] = "{{Planetarium}}" }
--
-- local copies of our XML data in case it's slightly faster
local CraftingMaxItemID = xml_data.XMLMaxItemID
local CraftingFixedRecipes = xml_data.XMLRecipes
local CraftingItemPools = xml_data.XMLItemPools

local CraftingItemQualities = {}

--These are recipes that have already been calculated, plus the contents of recipes.xml
local calculatedRecipes = {}
--Backup recipes in case of potential achievement lock
local lockedRecipes = {}
--If the seed changes, the above two tables will be wiped
local lastSeedUsed = Game():GetSeeds():GetStartSeed()
coopHUD.lastSeedUsed = Game():GetSeeds():GetStartSeed()
--
function coopHUD.BoC.calculateBagOfCrafting(componentsTable)
	-- Refresh seed on differ
	local curSeed = Game():GetSeeds():GetStartSeed()
	if lastSeedUsed ~= curSeed then
		lastSeedUsed = curSeed
	end
	-- ingredients must be sorted by ID for the RNG shifting to be accurate, so make a local copy
	local components = { table.unpack(componentsTable) }
	table.sort(components)
	local componentsAsString = table.concat(components, ",")
	-- Check the fixed recipes
	local fixedRecipeResult = nil
	local cacheResult = CraftingFixedRecipes[componentsAsString]
	if cacheResult ~= nil then
		if coopHUD.isCollectibleUnlockedAnyPool(cacheResult) then
			return cacheResult, cacheResult
		else
			fixedRecipeResult = cacheResult
		end
	end
	-- Check the recipes already calculated for this seed
	cacheResult = calculatedRecipes[componentsAsString]
	local lockedResult = lockedRecipes[componentsAsString]
	if cacheResult ~= nil then
		return cacheResult, lockedResult
	end

	-- Count up the ingredients, and shift the RNG based on the components in the bag
	customRNGSeed = lastSeedUsed
	local compTotalWeight = 0
	local compCounts = {}
	for i = 1, #componentShifts do
		compCounts[i] = 0
	end
	for _, compId in ipairs(components) do
		compCounts[compId + 1] = compCounts[compId + 1] + 1
		compTotalWeight = compTotalWeight + pickupValues[compId + 1]
		customRNGShift = componentShifts[compId + 1]
		RNGNext()
	end
	customRNGShift = componentShifts[7]

	local poolWeights = {
		{ idx = 0, weight = 1 },
		{ idx = 1, weight = 2 },
		{ idx = 2, weight = 2 },
		{ idx = 3, weight = compCounts[4] * 10 },
		{ idx = 4, weight = compCounts[5] * 10 },
		{ idx = 5, weight = compCounts[7] * 5 },
		{ idx = 7, weight = compCounts[30] * 10 },
		{ idx = 8, weight = compCounts[6] * 10 },
		{ idx = 9, weight = compCounts[26] * 10 },
		{ idx = 12, weight = compCounts[8] * 10 },
	}
	if compCounts[9] + compCounts[2] + compCounts[13] + compCounts[16] == 0 then
		table.insert(poolWeights, { idx = 26, weight = compCounts[24] * 10 })
	end

	local totalWeight = 0
	local itemWeights = {}
	for i = 1, CraftingMaxItemID do
		itemWeights[i] = 0
	end
	for _, poolWeight in ipairs(poolWeights) do
		if poolWeight.weight > 0 then
			local qualityMin = 0
			local qualityMax = 1
			local n = compTotalWeight
			-- Devil, Angel, and Secret Room Pools have a 5 point penalty
			if (poolWeight.idx >= 3) and (poolWeight.idx <= 5) then
				n = n - 5
			end
			if n > 34 then
				qualityMin = 4
				qualityMax = 4
			elseif n > 26 then
				qualityMin = 3
				qualityMax = 4
			elseif n > 22 then
				qualityMin = 2
				qualityMax = 4
			elseif n > 18 then
				qualityMin = 2
				qualityMax = 3
			elseif n > 14 then
				qualityMin = 1
				qualityMax = 2
			elseif n > 8 then
				qualityMin = 0
				qualityMax = 2
			end
			local pool = CraftingItemPools[poolWeight.idx + 1]

			for _, item in ipairs(pool) do
				local quality = CraftingItemQualities[item[1]]
				if quality >= qualityMin and quality <= qualityMax then
					local w = item[2] * poolWeight.weight
					itemWeights[item[1]] = itemWeights[item[1]] + w
					totalWeight = totalWeight + w
				end
			end
		end
	end
	--unsure if this emergency Breakfast would ever occur, without massively modified item pools at least, but it's in the game's code
	if totalWeight <= 0 then
		return 25, 25
	end
	--When the first crafting result is an achievement locked item, this process gets repeated a second time to choose a new result
	--That 2nd pick could also be achievement locked but we're ignoring that...
	local firstOption = fixedRecipeResult
	while true do
		local t = nextFloat() -- random number between 0 and 1
		local target = t * totalWeight -- number between 0 and total weight of possible results
		for k, v in ipairs(itemWeights) do
			target = target - v
			if target < 0 then
				if firstOption and k ~= firstOption then
					calculatedRecipes[componentsAsString] = firstOption
					lockedRecipes[componentsAsString] = k
					return firstOption, k
				else
					--Don't do the 2nd pass if this item is definitely unlocked
					if coopHUD.isCollectibleUnlockedAnyPool(k) then
						calculatedRecipes[componentsAsString] = k
						lockedRecipes[componentsAsString] = k
						return k, k
					else
						firstOption = k
						break
					end
				end
			end
		end
	end
end
--
local moddedCrafting = false
function coopHUD.BoC:GameStartCrafting()
	for i = 1, xml_data.XMLMaxItemID do
		local item = Isaac.GetItemConfig():GetCollectible(i)
		if item ~= nil then
			CraftingItemQualities[item.ID] = item.Quality
		end
	end
	if not coopHUD.PlayersHaveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) then
		if Isaac.GetItemConfig():GetCollectible(xml_data.XMLMaxItemID + 1) ~= nil then
			-- Items past max ID detected
			CraftingMaxItemID = xml_data.XMLMaxItemID -- XMLMaxItemID is never modified
			-- Add new item qualities
			local coll = Isaac.GetItemConfig():GetCollectible(CraftingMaxItemID + 1)
			while coll ~= nil do
				CraftingMaxItemID = CraftingMaxItemID + 1
				CraftingItemQualities[coll.ID] = coll.Quality
				coll = Isaac.GetItemConfig():GetCollectible(CraftingMaxItemID + 1)
			end
			local itemPool = Game():GetItemPool()
			-- Add new items to the crafting item pools, assuming Weight 1.0
			for poolNum, _ in pairs(poolToIcon) do
				for i = 1, xml_data.XMLMaxItemID do itemPool:AddRoomBlacklist(i) end
				local collID = itemPool:GetCollectible(poolNum, false, 1, 25)
				local attempts = CraftingMaxItemID
				while collID ~= 25 and collID ~= 642 and collID > 0 and attempts > 0 do
					attempts = attempts - 1
					table.insert(CraftingItemPools[poolNum + 1], { collID, 1.0 })
					itemPool:AddRoomBlacklist(collID)
					collID = itemPool:GetCollectible(poolNum, false, 1, 25)
				end
				itemPool:ResetRoomBlacklist()
			end
			moddedCrafting = true
		end
	end
end