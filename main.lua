coopHUD = RegisterMod("Coop HUD", 1)
local SHExists, ScreenHelper = pcall(require, "scripts.screenhelper")
function coopHUD.getMinimapOffset()
    -- Modified function from minimap_api by Wolfsauge
    local minimap_offset = ScreenHelper.GetScreenTopRight()
    local screen_size = ScreenHelper.GetScreenTopRight()
    local is_large = MinimapAPI:IsLarge()
    if not is_large and MinimapAPI:GetConfig("DisplayMode") == 2 then -- BOUNDED MAP
        minimap_offset = Vector(screen_size.X - MinimapAPI:GetConfig("MapFrameWidth") - MinimapAPI:GetConfig("PositionX") - 24,2)
    elseif not is_large and MinimapAPI:GetConfig("DisplayMode") == 4 then -- NO MAP
        minimap_offset = Vector(screen_size.X - 24,2)
    else -- LARGE
        local minx = screen_size.X
        for i,v in ipairs(MinimapAPI:GetLevel()) do
            if v ~= nil then
                if v:GetDisplayFlags() > 0 then
                    minx = math.min(minx, v.RenderOffset.X)
                end
            end

        end
        minimap_offset = Vector(minx-24,2) -- Small
    end
    --if MinimapAPI:GetConfig('ShowLevelFlags') then
    --    minimap_offset.X = minimap_offset.X - 16
    --end
    if MinimapAPI:GetConfig("Disable") or MinimapAPI.Disable then minimap_offset = Vector(screen_size.X - 24,2)  end
    local r = MinimapAPI:GetCurrentRoom()
    if MinimapAPI:GetConfig("HideInCombat") == 2 then
        if not r:IsClear() and r:GetType() == RoomType.ROOM_BOSS then
            minimap_offset = Vector(screen_size.X - 24,2)
        end
    elseif MinimapAPI:GetConfig("HideInCombat") == 3 then
        if not r:IsClear() then
            minimap_offset = Vector(screen_size.X - 24,2)
        end
    end
    return minimap_offset
end
-- OPTIONS SKETCH
local onRender = true
coopHUD.anchors = {
    top_left = ScreenHelper.GetScreenTopLeft(),
    bot_left = ScreenHelper.GetScreenBottomLeft(),
    top_right = Vector(coopHUD.getMinimapOffset().X,ScreenHelper.GetScreenTopRight().Y),
    bot_right = ScreenHelper.GetScreenBottomRight(),
}
coopHUD.players_config = {}
coopHUD.players_config[0] = {
    snap_side = 'left',-- left/right or off if > 2 players
    main_anchor, --
}
coopHUD.players_config[1] = {
    snap_side = 'right',-- left/right or off if > 2 players
    main_anchor, --
}
---
include("coopHUD_sprites.lua")
include("coopHUD_player_table_updates.lua")
include("coopHUD_render.lua")
---
function coopHUD.checkDeepPockets()
    local deep_check = false
    local player_no = Game():GetNumPlayers()-1
    for i=0,player_no,1 do
        local deep = Isaac.GetPlayer(i):HasCollectible(416)
        if  deep  then
            deep_check = true
        end
    end
    return deep_check
end
function coopHUD:player_joined()
    coopHUD.init()
    issomeonejoining = false
    onRender = true
end
coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, coopHUD.player_joined)
function coopHUD.updatePlayer(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    local player_table = {}
    player_table = {
        --
        first_active = temp_player:GetActiveItem(0),
        first_active_charge = temp_player:GetActiveCharge(0),
        second_active = temp_player:GetActiveItem(1),
        second_active_charge = temp_player:GetActiveCharge(1),
        first_trinket = temp_player:GetTrinket(0),
        second_trinket = temp_player:GetTrinket(1),
        first_pocket = coopHUD.getPocketID(temp_player,0),
        first_pocket_charge = temp_player:GetActiveCharge(2),
        second_pocket = coopHUD.getPocketID(temp_player,1),
        third_pocket = coopHUD.getPocketID(temp_player,2),
        pocket_desc = coopHUD.getMainPocketDesc(temp_player),
        extra_lives = temp_player:GetExtraLives(),
        has_guppy = temp_player:HasCollectible(212),
        bethany_charge = nil, -- inits charge for Bethany
        heart_types = coopHUD.getHeartTypeTable(temp_player),
        sub_heart_types = {},
        total_hearts = math.ceil((temp_player:GetEffectiveMaxHearts() + temp_player:GetSoulHearts())/2),
        ---
        type = temp_player:GetPlayerType(),
        ---
        has_sub = false,
        ---
        sprites = {
            first_active = coopHUD.getActiveItemSprite(temp_player,0),
            first_active_charge = coopHUD.getChargeSprites(temp_player,0),
            first_active_bethany_charge = nil,
            second_active = coopHUD.getActiveItemSprite(temp_player,1),
            second_active_charge = coopHUD.getChargeSprites(temp_player,1),
            first_trinket = coopHUD.getTrinketSprite(temp_player,0),
            second_trinket = coopHUD.getTrinketSprite(temp_player,1),
            first_pocket = coopHUD.getPocketItemSprite(temp_player,0),
            first_pocket_charge = coopHUD.getChargeSprites(temp_player,2),
            second_pocket = coopHUD.getPocketItemSprite(temp_player,1),
            third_pocket = coopHUD.getPocketItemSprite(temp_player,2),
            hearts = coopHUD.getHeartSpriteTable(temp_player),
            sub_hearts = nil
        },
    }
    -- Bethany/T.Bethany check
    if player_table.type == 18 or player_table.type == 36 then
        if player_table.type == 18 then
            player_table.bethany_charge = temp_player:GetSoulCharge()
        else
            player_table.bethany_charge = temp_player:GetBloodCharge()
        end
    end
    -- Forgotten/Soul check
    if  player_table.type == 16 or player_table.type == 17 then
        player_table.has_sub = true
        local sub = temp_player:GetSubPlayer()
        player_table.sprites.sub_hearts = coopHUD.getHeartSpriteTable(sub)
        player_table.sub_heart_types = coopHUD.getHeartTypeTable(sub)
    end
    if player_table.type == 19 then -- Jacob/Essau check
        --TODO: Jacob/Essau: make player_num+1-> render second in oposite corner/ restrict only when 1
        --players.has_sub = true
    end
    coopHUD.players[player_no] = player_table
end
local vector_zero = Vector(0,0)
local top_left_anchor = ScreenHelper.GetScreenTopLeft()
local bottom_left_anchor = ScreenHelper.GetScreenBottomLeft()
--
local players_no = 0
coopHUD.players = {}
-- init
function coopHUD.init()
    players_no = Game():GetNumPlayers()-1
    for i=0,players_no,1 do
        coopHUD.updatePlayer(i)
        print('Initiated ',i,'Player')
    end
end
coopHUD.init()
coopHUD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM , coopHUD.init); -- Updates all players info on entering new flor
local counter = 0
-- This callback turns the vanilla HUD back on when someone tries to join the game. -- @Function from mp stat display
issomeonejoining = false
function coopHUD:charselect()
    for i = 0,players_no+1,1 do
        if Input.IsActionTriggered(19, i) == true then
            onRender = false
            issomeonejoining = true
        end
        if Input.IsActionTriggered(15, i) == true then
            print('selected')
            onRender = true
            issomeonejoining = false
        end
    end
end
coopHUD:AddCallback(ModCallbacks.MC_INPUT_ACTION,    coopHUD.charselect)


coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)

