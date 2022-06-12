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
        ["10.1"] = { 1 }, -- Red heart
        ["10.2"] = { 1 }, -- half heart
        ["10.3"] = { 2 }, -- soul heart
        ["10.4"] = { 4 }, -- eternal heart
        ["10.5"] = { 1, 1 }, -- double heart
        ["10.6"] = { 3 }, -- black heart
        ["10.7"] = { 5 }, -- gold heart
        ["10.8"] = { 2 }, -- half soul heart
        ["10.9"] = { 1 }, -- scared red heart
        ["10.10"] = { 2, 1 }, -- blended heart
        ["10.11"] = { 6 }, -- Bone heart
        ["10.12"] = { 7 }, -- Rotten heart
        ["20.1"] = { 8 }, -- Penny
        ["20.2"] = { 9 }, -- Nickel
        ["20.3"] = { 10 }, -- Dime
        ["20.4"] = { 8, 8 }, -- Double penny
        ["20.5"] = { 11 }, -- Lucky Penny
        ["20.6"] = { 9 }, -- Sticky Nickel
        ["20.7"] = { 26 }, -- Golden Penny
        ["30.1"] = { 12 }, -- Key
        ["30.2"] = { 13 }, -- golden Key
        ["30.3"] = { 12, 12 }, -- Key Ring
        ["30.4"] = { 14 }, -- charged Key
        ["40.1"] = { 15 }, -- bomb
        ["40.2"] = { 15, 15 }, -- double bomb
        ["40.4"] = { 16 }, -- golden bomb
        ["40.7"] = { 17 }, -- giga bomb
        ["42.0"] = { 29 }, -- poop nugget
        ["42.1"] = { 29 }, -- big poop nugget
        ["70.14"] = { 27 }, -- golden pill
        ["70.2062"] = { 27 }, -- golden horse pill
        ["90.1"] = { 19 }, -- Lil Battery
        ["90.2"] = { 18 }, -- Micro Battery
        ["90.3"] = { 20 }, -- Mega Battery
        ["90.4"] = { 28 }, -- Golden Battery
        ["300.49"] = { 24 }, -- Dice shard
        ["300.50"] = { 21 }, -- Emergency Contact
        ["300.78"] = { 25 }, -- Cracked key
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
            if Game():GetLevel():GetCurses() >= LevelCurse.CURSE_OF_BLIND then
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
coopHUD.BoC.Unknown = coopHUD.Item({entPlayer=false},-1,1)
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
coopHUD.EID = include('helpers.BoC_helpers.lua') -- imports needed function from External Item Description by Wolfsauge
--- handles Bag of Crafting recipe calculation
--- mod itself imports prepared External Item Descriptions by Wolfsauge functions an use it to calculate result
---@param player coopHUD.Player
---@return number item id
function coopHUD.BoC.calculate(player)
    local bag = {}
    for _, k in pairs(player.bag_of_crafting) do
        table.insert(bag, k.id)
    end
    local components = { table.unpack(bag) }
    local result = 0
    local id_a, id_b = coopHUD.EID:calculateBagOfCrafting(components)
    if coopHUD.EID:isCollectibleUnlockedAnyPool(id_a) then
        return id_a
    else
        return id_b
    end
end
