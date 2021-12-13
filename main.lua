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
local anchors = {
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
            first_active_charge = coopHUD.getItemChargeSprite(temp_player,0),
            second_active = coopHUD.getActiveItemSprite(temp_player,1),
            second_active_charge = coopHUD.getItemChargeSprite(temp_player,1),
            first_trinket = coopHUD.getTrinketSprite(temp_player,0),
            second_trinket = coopHUD.getTrinketSprite(temp_player,1),
            first_pocket = coopHUD.getPocketItemSprite(temp_player,0),
            first_pocket_charge = coopHUD.getItemChargeSprite(temp_player,2),
            second_pocket = coopHUD.getPocketItemSprite(temp_player,1),
            third_pocket = coopHUD.getPocketItemSprite(temp_player,2),
            hearts = coopHUD.getHeartSpriteTable(temp_player),
            sub_hearts = nil
        },
    }
    if player_table.type == 18 or player_table.type == 36 then -- Bethany/T.Bethany check
        if player_table.type == 18 then
            player_table.bethany_charge = temp_player:GetSoulCharge()
        else
            player_table.bethany_charge = temp_player:GetBloodCharge()
        end
    end
    if  player_table.type == 16 or player_table.type == 17 then -- Forgotten/Soul check
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



-- Update
local forceUpdateActives = false
function coopHUD.updatePockets(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    -- TODO: refresh pocket items on use
    if coopHUD.players[player_no].first_pocket ~= coopHUD.getPocketID(temp_player,0) then
        coopHUD.players[player_no].first_pocket = coopHUD.getPocketID(temp_player,0)
        coopHUD.players[player_no].sprites.first_pocket = coopHUD.getPocketItemSprite(temp_player,0)
    end
    if coopHUD.players[player_no].second_pocket ~= coopHUD.getPocketID(temp_player,1) then
        coopHUD.players[player_no].second_pocket = coopHUD.getPocketID(temp_player,1)
        coopHUD.players[player_no].sprites.second_pocket = coopHUD.getPocketItemSprite(temp_player,1)
    end
    if coopHUD.players[player_no].third_pocket ~= coopHUD.getPocketID(temp_player,2) then
        coopHUD.players[player_no].third_pocket = coopHUD.getPocketID(temp_player,2)
        coopHUD.players[player_no].sprites.third_pocket = coopHUD.getPocketItemSprite(temp_player,2)
    end
    if coopHUD.players[player_no].pocket_desc ~= coopHUD.getMainPocketDesc(temp_player) then
        coopHUD.players[player_no].pocket_desc = coopHUD.getMainPocketDesc(temp_player)
    end
    if coopHUD.players[player_no].first_pocket_charge ~= temp_player:GetActiveCharge(2) or forceUpdateActives then
        coopHUD.players[player_no].first_pocket_charge = temp_player:GetActiveCharge(2)
        coopHUD.players[player_no].sprites.first_pocket_charge = coopHUD.getItemChargeSprite(temp_player,2)
        coopHUD.players[player_no].first_pocket = coopHUD.getPocketID(temp_player,0)
        coopHUD.players[player_no].sprites.first_pocket = coopHUD.getPocketItemSprite(temp_player,0)
    end
end
function coopHUD.updateActives(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    if coopHUD.players[player_no].first_active ~= temp_player:GetActiveItem(0)  then
        coopHUD.players[player_no].first_active = temp_player:GetActiveItem(0)
        coopHUD.players[player_no].second_active = temp_player:GetActiveItem(1)
        coopHUD.players[player_no].sprites.first_active = coopHUD.getActiveItemSprite(temp_player,0)
        coopHUD.players[player_no].sprites.first_active_charge = coopHUD.getItemChargeSprite(temp_player,0)
        coopHUD.players[player_no].sprites.second_active = coopHUD.getActiveItemSprite(temp_player,1)
        coopHUD.players[player_no].sprites.second_active_charge = coopHUD.getItemChargeSprite(temp_player,1)
    end
    --print(coopHUD.players[player_no].first_active_charge , temp_player:GetActiveCharge(0))
    if coopHUD.players[player_no].first_active_charge ~= temp_player:GetActiveCharge(0) or forceUpdateActives then
        coopHUD.players[player_no].first_active_charge = temp_player:GetActiveCharge(0)
        coopHUD.players[player_no].sprites.first_active = coopHUD.getActiveItemSprite(temp_player,0)
        coopHUD.players[player_no].sprites.first_active_charge = coopHUD.getItemChargeSprite(temp_player,0)
    end
end
function coopHUD.updateTrinkets(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    if coopHUD.players[player_no].first_trinket ~= temp_player:GetTrinket(0) then
        coopHUD.players[player_no].first_trinket = temp_player:GetTrinket(0)
        coopHUD.players[player_no].sprites.first_trinket = coopHUD.getTrinketSprite(temp_player,0)
    end
    if coopHUD.players[player_no].second_trinket ~= temp_player:GetTrinket(1) then
        coopHUD.players[player_no].second_trinket = temp_player:GetTrinket(1)
        coopHUD.players[player_no].sprites.second_trinket = coopHUD.getTrinketSprite(temp_player,1)
    end
end
function coopHUD.updateHearts(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    local max_health_cap = 12
    local sub_player = nil
    local temp_total_hearts = math.ceil((temp_player:GetEffectiveMaxHearts() + temp_player:GetSoulHearts())/2)
    if coopHUD.players[player_no].total_hearts ~= temp_total_hearts then
        coopHUD.players[player_no].total_hearts = temp_total_hearts
    end
    if coopHUD.players[player_no].has_sub then
        sub_player = temp_player:GetSubPlayer()
        max_health_cap = 6
    end
    for i=max_health_cap,0,-1 do
        local heart_type,overlay = coopHUD.getHeartType(temp_player,i)
        if (coopHUD.players[player_no].heart_types[i].heart_type ~= heart_type) or
                (coopHUD.players[player_no].heart_types[i].overlay ~= overlay)then
            coopHUD.players[player_no].heart_types[i].heart_type = heart_type
            coopHUD.players[player_no].heart_types[i].overlay = overlay
            coopHUD.players[player_no].sprites.hearts[i] = coopHUD.getHeartSprite(heart_type,overlay)
        end
    end
    if coopHUD.players[player_no].has_sub then
        for i=max_health_cap,0,-1 do
            local test_type = coopHUD.getHeartType(sub_player,i)
            if coopHUD.players[player_no].sub_heart_types[i].heart_type ~= test_type then
                print('zmiana serduszek')
                local heart_type,overlay = coopHUD.getHeartType(sub_player,i)
                coopHUD.players[player_no].sub_heart_types[i].heart_type = heart_type
                coopHUD.players[player_no].sub_heart_types[i].overlay = overlay
                coopHUD.players[player_no].sprites.sub_hearts[i] = coopHUD.getHeartSprite(heart_type,overlay)
            end
        end

    end
end
function coopHUD.updateAnchors()
    if top_left ~= ScreenHelper.GetScreenTopLeft() then
        anchors.top_left = ScreenHelper.GetScreenTopLeft()
    end
    if bot_left ~= ScreenHelper.GetScreenBottomLeft() then
        anchors.bot_left = ScreenHelper.GetScreenBottomLeft()
    end
    if top_right ~= ScreenHelper.GetScreenTopRight() then
        anchors. top_right = Vector(coopHUD.getMinimapOffset().X,ScreenHelper.GetScreenTopRight().Y)
    end
    if bot_right ~= ScreenHelper.GetScreenBottomRight() then
        anchors.bot_right = ScreenHelper.GetScreenBottomRight()
    end
end
function coopHUD.updateExtraLives(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    if coopHUD.players[player_no].extra_lives ~= temp_player:GetExtraLives() then
        coopHUD.players[player_no].extra_lives = temp_player:GetExtraLives()
        has_guppy = temp_player:HasCollectible(212)
    end
end
function coopHUD.updateBethanyCharge(player_no)
    if coopHUD.players[player_no].type == 36 then
        local temp_player = Isaac.GetPlayer(player_no)
        if coopHUD.players[player_no].bethany_charge ~= temp_player:GetBloodCharge() then
            coopHUD.players[player_no].bethany_charge = temp_player:GetBloodCharge()
        end
    end
    if coopHUD.players[player_no].type == 18 then
        local temp_player = Isaac.GetPlayer(player_no)
        if coopHUD.players[player_no].bethany_charge ~= temp_player:GetSoulCharge() then
            coopHUD.players[player_no].bethany_charge = temp_player:GetSoulCharge()
        end
    end
end
function coopHUD.forceUpdateActives()
    forceUpdateActives = true
end
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM, coopHUD.forceUpdateActives)
--
function coopHUD.renderPlayer(player_no)
    local active_item_off = Vector(0,0)
    --Define anchor
    local anchor
    local active_vector = Vector(0,0)
    local mirrored = false

    if coopHUD.players_config[player_no].snap_side == 'left' then -- Sets vectors for left side
        anchor_top = anchors.top_left
        active_vector.X = active_vector.X +16
        second_item_x_off = 8
        vector_modifier = 12
        active_off = 48
    elseif coopHUD.players_config[player_no].snap_side == 'right' then -- Sets vectors for left side
        anchor_top = anchors.top_right
        mirrored = true
        second_item_x_off = -12
        active_vector.X = active_vector.X -4
        vector_modifier = 0
        modifier = -1
        active_off = -36
    end

    ----Render active item
    if coopHUD.players[player_no].sprites.first_active or coopHUD.players[player_no].sprites.second_active then
        active_item_off = Vector(active_item_off.X + active_off ,active_item_off.Y+44)
        if coopHUD.players[player_no].sprites.second_active then
            coopHUD.players[player_no].sprites.second_active.Scale = Vector(0.5,0.5)
            coopHUD.players[player_no].sprites.second_active.Scale = Vector(0.5,0.5)
            coopHUD.players[player_no].sprites.second_active:Render(Vector(anchor_top.X + second_item_x_off ,anchor_top.Y + 8  ), vector_zero, vector_zero)
        end
        if coopHUD.players[player_no].sprites.second_active_charge then -- Second item charge render -- UGLY - can turn on
            coopHUD.players[player_no].sprites.second_active_charge.Scale = Vector(0.5,0.5)
            coopHUD.players[player_no].sprites.second_active_charge:Render(Vector(anchor_top.X +second_item_x_off+8,anchor_top.Y +8), vector_zero, vector_zero)
        end
        if coopHUD.players[player_no].sprites.first_active then
            -- First item charge render
            coopHUD.players[player_no].sprites.first_active:Render(Vector(anchor_top.X+active_vector.X,anchor_top.Y+16),VECTOR_ZERO,VECTOR_ZERO)
        end
        if coopHUD.players[player_no].sprites.first_active_charge then
            -- First item render
            coopHUD.players[player_no].sprites.first_active_charge:Render(Vector(anchor_top.X+active_vector.X+20,anchor_top.Y+16), VECTOR_ZERO, VECTOR_ZERO)
        end
    else
        active_item_off.X = active_item_off.X + vector_modifier
        active_item_off.Y = active_item_off.Y + 44
    end
    ----Render hearts
    local hearts_span
    if coopHUD.players[player_no].total_hearts >= 6 then
        hearts_span = 7
    else
        hearts_span = coopHUD.players[player_no].total_hearts % 6
    end
    local n = 2 -- No. of rows
    local m = math.floor(12/n)
    -- Sub character hearts render
    if coopHUD.players[player_no].has_sub then -- Sub player heart render
        counter = 0
        pos.Y = anchor.Y + 22
        local temp_heart_space = 12 -- sets px space between hearts
        for row=0,n-1,1 do
            for col=0,m-1,1 do
                if coopHUD.players[player_no].sprites.sub_hearts[counter] then
                    coopHUD.players[player_no].sprites.sub_hearts[counter].Scale = Vector(1,1)
                    coopHUD.players[player_no].sprites.sub_hearts[counter].Color =Color(1, 1, 1, 0.5, 0, 0, 0)
                    temp_pos = Vector(pos.X + (temp_heart_space * col),pos.Y + (temp_heart_space * row))
                    coopHUD.players[player_no].sprites.sub_hearts[counter]:Render(temp_pos,VECTOR_ZERO,VECTOR_ZERO)
                end
                counter = counter + 1
            end
        end
    end
    -- Main character hearts render
    local counter = 0
    local heart_space = 12  -- sets px space between hearts
    if mirrored then
        pos = Vector(anchor_top.X+active_item_off.X - (8*hearts_span),anchor_top.Y+12)
    else
        pos = Vector(anchor_top.X+active_item_off.X,anchor_top.Y+12)
    end

    for row=0,n-1,1 do
        for col=0,m-1,1 do
            if coopHUD.players[player_no].sprites.hearts[counter] then
                temp_pos = Vector(pos.X + (heart_space * col),pos.Y + (heart_space * row))
                coopHUD.players[player_no].sprites.hearts[counter]:Render(temp_pos,VECTOR_ZERO,VECTOR_ZERO)
            end
            counter = counter + 1
        end
    end
     --Extra Lives Render
    if mirrored then
        pos = Vector(anchor_top.X+active_item_off.X - (8*(hearts_span))-12,anchor_top.Y+4)
    else
        pos = Vector(anchor_top.X+active_item_off.X+ (8*(hearts_span+3)),anchor_top.Y+4)
    end
    if coopHUD.players[player_no].extra_lives ~= 0 then
        local f = Font()
        f:Load("font/pftempestasevencondensed.fnt")
        local text
        if coopHUD.players[player_no].has_guppy then
            text = string.format('x%d?',coopHUD.players[player_no].extra_lives)
            pos.X = pos.X - 6
        else
            text =  string.format('x%d',coopHUD.players[player_no].extra_lives)
        end

        f:DrawString (text,pos.X,pos.Y,KColor(1,1,1,1),0,true)
    end

    ---- POCKETS RENDER
    local down_vector = Vector(0,0)
    if coopHUD.players_config[player_no].snap_side == 'left' then -- Sets vectors for left side
        anchor = anchors.bot_left
        down_vector.X = down_vector.X +16
        pocket_off = 20
        alternate_pockets_off = 8
    elseif coopHUD.players_config[player_no].snap_side == 'right' then -- Sets vectors for left side
        anchor = anchors.bot_right
        down_vector.X = down_vector.X -24
        pocket_off = -52
        alternate_pockets_off = -8
    end
    local charge_off = 18
    ------third pocket
    scale = Vector(0.5,0.5)
    if coopHUD.players[player_no].sprites.third_pocket then
        coopHUD.players[player_no].sprites.third_pocket.Scale = Vector(0.7,0.7)
        coopHUD.players[player_no].sprites.third_pocket:Render(Vector(anchor.X+alternate_pockets_off,anchor.Y-56), vector_zero, vector_zero)
    end
    -- Second pocket
    if coopHUD.players[player_no].sprites.second_pocket then
        coopHUD.players[player_no].sprites.second_pocket.Scale = Vector(0.7,0.7)
        coopHUD.players[player_no].sprites.second_pocket:Render(Vector(anchor.X+alternate_pockets_off,anchor.Y-40), vector_zero, vector_zero)
    end
    -- Main pocket
    if coopHUD.players[player_no].sprites.first_pocket then
        coopHUD.players[player_no].sprites.first_pocket:Render(Vector(anchor.X+down_vector.X,anchor.Y-16), VECTOR_ZERO, VECTOR_ZERO)
        -- Main pocket charge
        if coopHUD.players[player_no].sprites.first_pocket:GetDefaultAnimation() == 'Idle' then -- checks if item is not pill of card
            if coopHUD.players[player_no].sprites.first_pocket_charge then
                coopHUD.players[player_no].sprites.first_pocket_charge:Render(Vector(anchor.X+down_vector.X + charge_off,anchor.Y-16), vector_zero, vector_zero)
            end
        end
        local f = Font()
        f:Load("font/pftempestasevencondensed.fnt")
        local color = KColor(1,1,1,1) -- TODO: sets according to player color
        if coopHUD.players[player_no].pocket_desc then
            local text = coopHUD.players[player_no].pocket_desc
            if string.len(text) > 12 and mirrored then
                text = string.format("%.12s...",text) end
            f:DrawString (text,anchor.X+down_vector.X+ pocket_off,anchor.Y-16,color,0,true) end
    end
    if coopHUD.players[player_no].bethany_charge ~= nil then
        pos =Vector(anchor_top.X+6,anchor_top.Y + active_item_off.Y)
        local beth_sprite = Sprite()
        if coopHUD.players[player_no].type == 18 then
            beth_sprite = coopHUD.getHeartSprite('BlueHeartFull','None')
        else
            beth_sprite = coopHUD.getHeartSprite('RedHeartFull','None')
        end
        beth_sprite.Scale = Vector(0.6,0.6)
        beth_sprite:Render(Vector(pos.X,pos.Y),VaECTOR_ZERO,VECTOR_ZERO)
        local f = Font()
        local bethany_charge = string.format('x%d',coopHUD.players[player_no].bethany_charge)
        f:Load("font/luaminioutlined.fnt")
        f:DrawString (bethany_charge,pos.X+6,pos.Y-9,KColor(1,1,1,1),0,true)
        active_item_off.Y = active_item_off.Y + 16
    end
    -- TRINKET RENDER
    if coopHUD.players[player_no].sprites.first_trinket then
        if coopHUD.players[player_no].sprites.second_trinket then
            if mirrored then pos = Vector(pos.X-8,pos.Y-8) end
            coopHUD.players[player_no].sprites.first_trinket.Scale = Vector(0.7,0.7)
            pos = Vector(anchor_top.X+12,anchor_top.Y+active_item_off.Y)
        else
            pos = Vector(anchor_top.X+12,anchor_top.Y+active_item_off.Y)
        end
        coopHUD.players[player_no].sprites.first_trinket:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
    end
    if coopHUD.players[player_no].sprites.second_trinket then
        pos = Vector(pos.X+8,pos.Y+8)
        coopHUD.players[player_no].sprites.second_trinket.Scale = Vector(0.7,0.7)
        coopHUD.players[player_no].sprites.second_trinket:Render(pos,vector_zero,vector_zero)
    end
end
function coopHUD.renderItems()
    anchor = Vector(ScreenHelper.GetScreenSize().X/2,ScreenHelper.GetScreenBottomLeft().Y-16)
    local pos = Vector(anchor.X - 12,anchor.Y)
    local Anim = "gfx/ui/hudpickups.anm2"
    local coin_no,bomb_no,key_no = 0

    --,key_sprite

    local f = Font()
    f:Load("font/luaminioutlined.fnt")

    local color = KColor(1,1,1,1)
    local player = Isaac.GetPlayer(0)
    local coin_sprite= Sprite()
    local has_deep_pockets = false
    coin_no = Isaac.GetPlayer(0):GetNumCoins()
    pos.X = pos.X - 24
    coin_sprite:Load(Anim,true)
    coin_sprite:SetFrame('Idle', 0)
    coin_no = string.format("%.2i", coin_no)
    if coopHUD.checkDeepPockets() then
        pos.X = pos.X - 4
        coin_no = string.format("%.3i", coin_no) end
    coin_sprite:Render(pos,VECTOR_ZERO,VECTOR_ZERO)


    f:DrawString(coin_no,pos.X+16,pos.Y,color,0,true)

    --
    local pos = Vector(anchor.X - 12,anchor.Y)
    local bomb_sprite = Sprite()
    bomb_sprite:Load(Anim,true)
    bomb_sprite:SetFrame('Idle',2)
    if player:HasGoldenBomb()  then bomb_sprite:SetFrame('Idle',6) end
    bomb_sprite:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
    bomb_no = player:GetNumBombs()
    bomb_no = string.format("%.2i", bomb_no)
    f:DrawString(bomb_no,pos.X+16,pos.Y,color,0,true)
    --
    pos.X = pos.X + 24
    local key_sprite = Sprite()
    key_sprite:Load(Anim,true)
    key_sprite:SetFrame('Idle',1)
    if player:HasGoldenKey()  then key_sprite:SetFrame('Idle',3 ) end
    key_sprite:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
    key_no = player:GetNumKeys()
    key_no = string.format("%.2i", key_no)
    f:DrawString(key_no,pos.X+16,pos.Y,color,0,true)
end
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

function  coopHUD.render()
    if issomeonejoining == false then
        Game():GetHUD():SetVisible(false)
    else
        onRender = false
        Game():GetHUD():SetVisible(true)
    end
    if onRender  then
        -- Function is triggered by callback 2 times per second
        -- Check/update user item with longer span - checking with call back cause lag

        counter = counter+1
        if counter == 6 then
            coopHUD.updateAnchors()
            for i=0,players_no,1 do
                coopHUD.updateActives(i)
                coopHUD.updateTrinkets(i)
                coopHUD.updatePockets(i)
                coopHUD.updateHearts(i)
                coopHUD.updateExtraLives(i)
                counter = 0
            end
        end
        for i=0,players_no,1 do
            coopHUD.renderPlayer(i)
        end

        coopHUD.renderItems()
    end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)

