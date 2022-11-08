if REPENTANCE then
    require("helpers.filepathhelper")
else
    require("helpers.filepathhelper")
    dofile("helpers.filepathhelper")
end

---@class modded_cards_data
---@field path string
---@field animName string

local function GetMaxCardID()
    local id = Card.NUM_CARDS - 1
    local step = 16
    while step > 0 do
        if Isaac.GetItemConfig():GetCard(id + step) ~= nil then
            id = id + step
        else
            step = step // 2
        end
    end
    return id
end
--[[ -- Prevention from deleting previously loaded card info on manual mod reload
oldCards = nil
if coopHUD and coopHUD.modded_cards ~= nil then
    ---@type modded_cards_data[]
    oldCards = coopHUD.modded_cards
end
--]]
--- RegisterMod function overload, to generate cards info for displaying in HUD

local LastModName = "unknown mod"
local LastModRoot = ""
local LastCard = Card.NUM_CARDS

local registerModOld = Isaac.RegisterMod
local function registerModNew(ref, modName, apiVersion)
    local registeredCorrectly, returned = pcall(registerModOld, ref, modName, apiVersion)

    if registeredCorrectly then
        if string.match(modName, "Coop HUD") then
            if oldCards ~= nil then
                Isaac.DebugString('[coopHUD]:restore')
                ref.modded_cards = oldCards
            else
                ref.modded_cards = {}
            end
            return returned
        end
        local MaxCard = GetMaxCardID()
        LastModName = modName
        LastModRoot = tostring(ref.path)
        local imported_item = 0
        if LastCard <= MaxCard then
            for i = LastCard, MaxCard do
                ---@type ItemConfigItem
                local item = Isaac.GetItemConfig():GetCard(i)
                coopHUD.modded_cards[item.ID] = { path = ref.path .. "content/gfx/ui_cardfronts.anm2", animName = item.HudAnim }
                imported_item = imported_item + 1
            end
            LastCard = MaxCard + 1
            if imported_item > 0 then
                Isaac.DebugString('[coopHUD]:imported ' .. imported_item .. ' modded cards from ' .. tostring(modName))
            end
        end

        return returned
    else
        error(returned, 2)
    end
end
Isaac.RegisterMod = registerModNew

