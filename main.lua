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
function coopHUD.getActiveItemSprite(player,slot)
    local Anim = "gfx/ui/item.anm2"
    local overlay = ''
    local activeitem = player:GetActiveItem(slot)
    if activeitem == 0 then return false end
    local thissprite = Sprite() -- replaced
    thissprite:Load(Anim,true)
    local itemsprite = Isaac.GetItemConfig():GetCollectible(activeitem).GfxFileName
    --Jar's check and sets item_sprite
    if activeitem == 290 then -- the jar
        itemsprite = "gfx/characters/costumes/costume_rebirth_90_thejar.png"
    elseif activeitem == 434 then -- jar of flies
        itemsprite = "gfx/characters/costumes/costume_434_jarofflies.png"
    elseif activeitem == 685 then -- jar of wisp
        itemsprite = "gfx/ui/hud_jarofwisps.png"
    elseif activeitem == 720 then -- everything jar
        itemsprite = "gfx/ui/hud_everythingjar.png"
    end
    -- TODO:Book of Virtuoses sprite set
    --if activeitem == 584 then
    --  itemsprite = "gfx/characters/costumes/costume_434_jarofflies.png"
    --end
    -- Urn of Souls - sprite set
    if activeitem == 640 then
        itemsprite = "gfx/ui/hud_urnofsouls.png"
    end
    thissprite:ReplaceSpritesheet(0, itemsprite)
    thissprite:ReplaceSpritesheet(1, itemsprite)
    thissprite:ReplaceSpritesheet(2, itemsprite)
    thissprite:ReplaceSpritesheet(3, itemsprite)
    thissprite:ReplaceSpritesheet(4, itemsprite)
    thissprite:ReplaceSpritesheet(5, itemsprite)
    thissprite:LoadGraphics() -- sets item overlay according to charges
    -- Sets overlay/charges state frame --
    local itemcharge = Isaac.GetItemConfig():GetCollectible(activeitem).MaxCharges -- gets max charges
    if itemcharge == 0 then -- checks id item has any charges
        thissprite:SetFrame("Idle", 0 ) -- set frame to unloaded
    elseif player:NeedsCharge(slot) == false or player:GetActiveCharge(slot) >= itemcharge then
        -- checks if item dont needs charges or item is overloaded
        thissprite:SetFrame("Idle", 1) -- set frame to loaded
    else
        thissprite:SetFrame("Idle", 0) -- set frame to unloaded
    end
    --The Jar/Jar of Flies - charges check
    if activeitem == 290 or activeitem == 434 then --
        local frame = 0
        if activeitem == 290 then frame = math.ceil(player:GetJarHearts()/2) end -- gets no of hearts in jar
        if activeitem == 434 then frame = player:GetJarFlies() end --gets no of flies in jar of flies
        thissprite:SetFrame("Jar", frame)
    end
    -- Everything Jar - charges set
    if activeitem == 720  then
        fi_charge = player:GetActiveCharge()
        thissprite:SetFrame("EverythingJar", fi_charge +1)
    end
    -- TODO: Jar of Wisp
    --if activeitem == 685 then
    --    --TODO: anim frames
    --    --TODO: get charges
    --end
    -- TODO:Urn of soul
    if activeitem == 640 then
        fi_charge = 0
        print(player:GetJarFlies())
        --      --TODO: get charge of urn
        thissprite:SetFrame("SoulUrn", fi_charge) -- sets frame
    end

    return thissprite
end
function coopHUD.getItemChargeSprite(player,slot) -- Gets charge of item from  player, slot
    --TODO: Bethany charge bar
    Anim = "gfx/ui/activechargebar.anm2"
    local activeitem = player:GetActiveItem(slot)
    if activeitem == 0 then return false end
    local itemcharge = Isaac.GetItemConfig():GetCollectible(activeitem).MaxCharges
    if itemcharge == 0 then return false end
    local thissprite = Sprite()
    thissprite:Load(Anim,true)
    local charges = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
    local step = math.floor((charges/(itemcharge*2))*46)
    thissprite:SetFrame("ChargeBar", step)
    if (itemcharge > 1 and itemcharge < 5) or itemcharge == 6 or itemcharge == 12 then
        thissprite:PlayOverlay("BarOverlay" .. itemcharge, true)
    else
        thissprite:PlayOverlay("BarOverlay1", true)
    end
    return thissprite
end
function coopHUD.getTrinketSprite(player, trinket_pos)
    Anim = "gfx/ui/item.anm2"
    local trinketid = player:GetTrinket(trinket_pos)
    if trinketid == 0 then return false end
    local thissprite = Sprite()
    thissprite:Load(Anim,true)
    local itemsprite = Isaac.GetItemConfig():GetTrinket(trinketid).GfxFileName
    thissprite:ReplaceSpritesheet(0, itemsprite)
    thissprite:ReplaceSpritesheet(5, itemsprite)
    thissprite:LoadGraphics()
    thissprite:SetFrame("Idle", 0)
    return thissprite
end
function coopHUD.getPocketID(player,slot)
    local pocket_id = 0
    local pocket_type = 0 -- 0 - none, 1 - card, 2 - pill, 3 - item
    if player:GetCard(slot) > 0 then
        pocket_id = player:GetCard(slot)
        pocket_type = 1
    elseif player:GetPill(slot) > 0 then
        pocket_id = player:GetPill(slot)
        pocket_type = 2
    else
        if slot == 1 then
            if coopHUD.getPocketID(player,0)[2] ~= 3 then
                pocket_id = player:GetActiveItem(2)
                pocket_type = 3
            end
        elseif slot == 2 then
            if coopHUD.getPocketID(player,0)[2] ~= 3 and coopHUD.getPocketID(player,1)[2] ~= 3 then
                pocket_id = player:GetActiveItem(2)
                pocket_type = 3
            end
        else
            pocket_id = player:GetActiveItem(2)
            pocket_type = 3
        end
    end
    return {pocket_id,pocket_type}
end
function coopHUD.getPocketItemSprite(player,slot)
    -- cards/runes/
    local pocket_sprite = Sprite()
    local anim = ''
    local pocket = coopHUD.getPocketID(player,slot)
    local pocket_type = pocket[2]
    local pocket_id = pocket[1]
    if pocket_type == 1 then -- Card
        anim = "gfx/ui/hud_card_coop.anm2"
        pocket_sprite:Load(anim,true)
        pocket_sprite:SetFrame("CardFronts", pocket_id) -- sets card frame
    elseif pocket_type == 2 then -- Pill
        if pocket_id > 2048 then pocket_id = pocket_id - 2048 end -- check if its horse pill and change id to normal
        anim = "gfx/ui/hud_pills_coop.anm2"
        pocket_sprite:Load(anim,true)
        pocket_sprite:SetFrame("Pills", pocket_id) --sets frame to pills with correct id
        return pocket_sprite
    elseif pocket_type == 3 then
        pocket_sprite = coopHUD.getActiveItemSprite(player,2)
    else
        pocket_sprite = false
    end
    return pocket_sprite
end
function coopHUD.getMainPocketDesc(player)
    desc = 'Error'
    if player:GetPill(0) < 1 and player:GetCard(0) < 1 then
        if player:GetActiveItem(2) > 0 then
            desc = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(2)).Name
        elseif player:GetActiveItem(3) > 0 then
            desc = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(3)).Name
        else
            return false
        end
        if desc ~= "Error" then desc = desc .. "  " end
    end
    if player:GetCard(0) > 0 then
        desc = Isaac.GetItemConfig():GetCard(player:GetCard(0)).Name .. " "
        if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) then
            desc = Isaac.GetItemConfig():GetCard(player:GetCard(0)).Description .. " "
        end

    elseif player:GetPill(0) > 0 then
        desc = "???" .. " "
        local itempool = Game():GetItemPool()
        if itempool:IsPillIdentified (player:GetPill(0)) then
            local pilleffect = itempool:GetPillEffect(player:GetPill(0))
            desc = Isaac.GetItemConfig():GetPillEffect(pilleffect).Name .. " "
        end
    end
    return desc
end
function coopHUD.getHeartType(player,heart_pos)
    ---- Modified function from HUD_API from NeatPotato mod
    local player_type = player:GetPlayerType()
    local heart_type = 'None'
    local eternal = false
    local golden = false
    local remain_souls = 0
    if player_type == 10 or player_type == 31 then
        --TODO: Lost custom heart
        heart_type = 'None'
    elseif Game():GetLevel():GetCurses() == 8 then -- checks curse of the uknown
        if heart_pos == 0 and not player:IsSubPlayer() then
            heart_type = 'CurseHeart'
            return heart_type,overlay
        end
    else
        eternal = false
        golden = false
        local total_hearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts())/2)
        local empty_hearts = math.floor((player:GetMaxHearts()-player:GetHearts())/2)
        if empty_hearts < 0 then empty_hearts = 0 end
        if player:GetGoldenHearts() > 0 and (heart_pos >= total_hearts - (player:GetGoldenHearts()+empty_hearts)) then   ---(total_hearts - (player:GetGoldenHearts()+empty_hearts)))
            golden = true
        end
        if player:GetMaxHearts()/2 > heart_pos then -- red heart type
            if player_type == 14 or player_type == 33 then -- Keeper
                golden = false
                if player:GetHearts()-(heart_pos*2) > 1 then
                    heart_type = "CoinHeartFull"
                elseif player:GetHearts()-(heart_pos*2) == 1 then
                    heart_type = "CoinHeartHalf"
                else
                    heart_type = "CoinEmpty"
                end
            else -- Normal red hearts
                if player_type == 21 then --TODO:Tainted maggy pulse heart
                    if player:GetHearts()-(heart_pos*2) > 1 then
                        heart_type = "RedHeartFullMaggy"
                    elseif player:GetHearts()-(heart_pos*2) == 1 then
                        heart_type = "RedHeartHalf"
                    else
                        heart_type = "EmptyHeart"
                        golden = false
                    end
                else
                    if player:GetHearts()-(heart_pos*2) > 1 then
                        heart_type = "RedHeartFull"
                    elseif player:GetHearts()-(heart_pos*2) == 1 then
                        heart_type = "RedHeartHalf"
                    else
                        heart_type = "EmptyHeart"
                    end
                end


            end
            if player:GetEternalHearts() > 0 and heart_pos+1 == player:GetMaxHearts()/2 and player:GetHearts()-(heart_pos*2) < 3  then
                eternal = true
            end
        elseif player:GetSoulHearts() > 0 or player:GetBoneHearts() > 0 then -- checks
            local red_offset = heart_pos-(player:GetMaxHearts()/2)
            if math.ceil(player:GetSoulHearts()/2) + player:GetBoneHearts() <= red_offset then
                heart_type = "None"
            else
                local prev_red = 0
                if player:IsBoneHeart(red_offset) then

                    if red_offset > 0 then
                        for i = 0, red_offset do
                            if player:IsBoneHeart(i) == false then
                                prev_red = prev_red + 2
                            end
                        end
                    end
                    -- HUDAPI
                    local overloader_reds = player:GetHearts()+prev_red-(heart_pos*2) --overloaded reds heart in red cointainers
                    if overloader_reds > 1 then
                        heart_type = "BoneHeartFull"
                    elseif overloader_reds == 1 then
                        heart_type = "BoneHeartHalf"
                    else
                        heart_type = "BoneHeartEmpty"
                    end
                    -- HUDAPI
                    if player:GetEternalHearts() > 0 and player:GetHearts() > player:GetMaxHearts() and player:GetHearts()-(heart_pos*2) > 0 and player:GetHearts()-(heart_pos*2) < 3 then
                        eternal = true
                    end
                else
                    local prev_bones = 0
                    if red_offset > 0 then
                        for i = 0, red_offset do
                            if player:IsBoneHeart(i) then
                                prev_bones = prev_bones + 1
                            end
                        end
                    end
                    local black_hearts = (red_offset*2 + 1)-(2*prev_bones)
                    local remain_souls = player:GetSoulHearts() + (2*prev_bones) - (red_offset*2)
                    if player:IsBlackHeart(black_hearts) then
                        if remain_souls > 1 then
                            heart_type = "BlackHeartFull"
                        else
                            heart_type = "BlackHeartHalf"
                        end
                    else
                        if remain_souls > 1 then
                            heart_type = "BlueHeartFull"
                        else
                            heart_type = "BlueHeartHalf"
                        end
                    end
                    --eternal heart overlay
                    if player:GetEternalHearts() > 0 and heart_pos == 0 then
                        eternal = true
                    end
                end
            end
        end
        if REPENTANCE and player:GetRottenHearts() > 0 then
            local nonrottenreds = player:GetHearts()/2 - player:GetRottenHearts()
            if  heart_type == "RedHeartFull" then
                if heart_pos >= nonrottenreds then
                    heart_type = "RottenHeartFull"
                end
                --elseif heart_type == "RedHeartHalf" then -- unnecesary no half rotten exsist in vanila REPENTANCE
                --    heart_type = "RottenHalfHart"
            elseif heart_type == "BoneHeartFull" then
                local overloader_reds = player:GetHearts()+remain_souls-(heart_pos*2)
                if overloader_reds - player:GetRottenHearts()*2 <= 0 then
                    heart_type = "RottenBoneHeartFull"
                end
                --elseif heart_type == "BoneHeartHalf" then -- unnecesary no half rotten exsist in vanila REPENTANCE
                --        heart_type = "RottenBoneHeartHalf"
            end
        end
        if eternal and golden then
            overlay = "Gold&Eternal"
        elseif eternal then
            overlay = "WhiteHeartOverlay"
        elseif golden then
            overlay = "GoldHeartOverlay"
        else
            overlay = 'None'
        end
        --TODO: proper overlay set
    end
    return heart_type,overlay
end
function coopHUD.getHeartSprite(heart_type,overlay)
    if heart_type ~= 'None' then
        local Anim = "gfx/ui/ui_hearts.anm2"
        local sprite = Sprite()
        sprite:Load(Anim,true)
        sprite:SetFrame(heart_type, 0)
        if overlay ~= 'None'  then
            sprite:SetOverlayFrame (overlay, 0 )
        end
        return sprite
    else
        return False
    end
end
function coopHUD.getHeartSpriteTable(player)
    local max_health_cap = 12
    local heart_type,overlay = ''
    local heart_sprites = {}
    for counter=0,12,1 do
        heart_type,overlay = coopHUD.getHeartType(player,counter)
        heart_sprites[counter] = coopHUD.getHeartSprite(heart_type,overlay)
    end
    return heart_sprites
end
function coopHUD.getHeartTypeTable(player)
    local max_health_cap = 12
    local heart_type,overlay = ''
    local heart_types = {}
    for counter=0,12,1 do
        heart_type,overlay = coopHUD.getHeartType(player,counter)
        heart_types[counter] = {
            heart_type = heart_type,
            overlay = overlay,
        }
    end
    return heart_types
end
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

