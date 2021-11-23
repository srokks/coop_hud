coopHUD = RegisterMod("Coop HUD", 1)
local json = require("json")

local MinimapAPI = require("scripts.minimapapi")
local SHExists, ScreenHelper = pcall(require, "scripts.screenhelper")
--
local renderPlayer = {}
local VECTOR_ZERO = Vector(0,0)
local player = 0
function renderPlayer.getActiveItemSprite(player,slot)
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
function renderPlayer.getItemChargeSprite(player,slot) -- Gets charge of item from  player, slot
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
function renderPlayer.getTrinketSprite(player, trinket_pos)
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
function renderPlayer.getPocketItemSprite(player,slot)
    -- cards/runes/

    local pocketcheck = player:GetCard(slot)
    local thissprite = Sprite()

    if pocketcheck ~= 0 then
        Anim = "gfx/ui/hud_card_coop.anm2"
        thissprite:Load(Anim,true)
        thissprite:SetFrame("CardFronts", pocketcheck) -- sets card frame

        return thissprite
    else
        pocketcheck = player:GetPill(slot) -- checks if player has pill
        if pocketcheck ~= 0 then
            if pocketcheck > 2048 then pocketcheck = pocketcheck - 2048 end -- check if its horse pill and change id to normal
            Anim = "gfx/ui/hud_pills_coop.anm2"
            thissprite:Load(Anim,true)
            thissprite:SetFrame("Pills", pocketcheck) --sets frame to pills with correct id
            return thissprite
        else
            if player:GetActiveItem(2) > 0 or player:GetActiveItem(3) > 0 then
                pocketitem = true -- do wyjebania
                if player:GetActiveItem(2) > 0 then
                    thissprite = renderPlayer.getActiveItemSprite(player,2)
                else
                    thissprite = renderPlayer.getActiveItemSprite(player,3)
                end
                return thissprite
            else
                return false
            end
        end
    end
end
function renderPlayer.getMainPocketDesc(player)
    desc = 'Error'
    if player:GetPill(0) < 1 and player:GetCard(0) < 1 then
        if REPENTANCE == false then return false end
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
function renderPlayer.renderActiveItem(player,anchor)
    local scale = Vector(1,1)
    local pos = Vector(anchor.X,anchor.Y)
    -- Second active item - render

    local first_active = renderPlayer.getActiveItemSprite(player,0)
    local second_active = renderPlayer.getActiveItemSprite(player,1)
    if first_active or second_active then
        if second_active then
            second_active.Scale = Vector(0.7,0.7)
            second_active:Render(Vector(pos.X - 7,pos.Y - 7), vector_zero, vector_zero)
        end
        -- Second active item - charges - render
        local se_charge = renderPlayer.getItemChargeSprite(player,1)
        if se_charge then
            se_charge.Scale = Vector(0.5,0.5)
            se_charge:Render(Vector(pos.X - 15,pos.Y - 9), vector_zero, vector_zero)
        end
        -- First active item - render
        if first_active then
            first_active:Render(pos, VECTOR_ZERO, VECTOR_ZERO)
        end
        -- First active item - charges - render
        pos.X = pos.X + 17
        local fi_charge = renderPlayer.getItemChargeSprite(player,0)
        if fi_charge then
            fi_charge:Render(pos, VECTOR_ZERO, VECTOR_ZERO)
        end
    end
    return pos
end
function renderPlayer.renderTrinkets(player,anchor)
    local scale = Vector(0.5,0.5)
    local tri1 = renderPlayer.getTrinketSprite(player,0)
    local tri2 = renderPlayer.getTrinketSprite(player,1)
    local pos = Vector(anchor.X,anchor.Y+20)
    if tri1 then
        if tri2 then -- if has trinket 2
            pos.Y = pos.Y  -- left corner pos
        else -- else
            pos.Y = pos.Y + 6 -- center pos
            scale = Vector(0.7,0.7) -- makes trinket bigger
        end
        tri1.Scale = scale
        tri1:Render(pos,vector_zero,vector_zero)
        pos.X = pos.X + 8
    end
    if tri2 then
        pos.Y = pos.Y + 8

        tri2.Scale = scale
        tri2:Render(pos,vector_zero,vector_zero) end
    return pos
end
function renderPlayer.renderPockets(player,anchor,desc_up)
    if desc_up == nil then desc_up = false end
    local scale = Vector(0.7,0.7)
    local pos = Vector(anchor.X+8,anchor.Y)
    local main_pocket = renderPlayer.getPocketItemSprite(player,0)
    local second_pocket = renderPlayer.getPocketItemSprite(player,1)
    local third_pocket = renderPlayer.getPocketItemSprite(player,2 )
    ----second_pocket charges
    if third_pocket then
        if third_pocket:GetDefaultAnimation() == 'Idle' then
            scale = Vector(0.3,0.3 )
            local pocket_charge  = renderPlayer.getItemChargeSprite(player,2)
            if pocket_charge then
                if main_pocket:GetDefaultAnimation() ~= 'Idle' and third_pocket :GetDefaultAnimation() ~= 'Idle' then
                    pocket_charge.Scale = scale
                    pocket_charge:Render(Vector(pos.X+42,pos.Y+2), vector_zero, vector_zero)
                end
            end
            pos.X = pos.X -5
        end
    end
    ------third pocket
    scale = Vector(0.5,0.5)
    if third_pocket then
        if third_pocket:GetDefaultAnimation() ~= 'Idle' then
            third_pocket.Scale = scale
            third_pocket:Render(Vector(pos.X+40,pos.Y), vector_zero, vector_zero)
        else
            if main_pocket:GetDefaultAnimation() ~= 'Idle' and second_pocket :GetDefaultAnimation() ~= 'Idle' then
                second_pocket.Scale = scale
                second_pocket:Render(Vector(pos.X+40,pos.Y), vector_zero, vector_zero)
            end
        end
    end
    ----second_pocket charges
    scale = Vector(0.5,0.5)
    if second_pocket then
        if second_pocket:GetDefaultAnimation() == 'Idle' then
            scale = Vector(0.3,0.3 )
            local pocket_charge  = renderPlayer.getItemChargeSprite(player,2)
            if pocket_charge then
                if main_pocket:GetDefaultAnimation() ~= 'Idle' or second_pocket:GetDefaultAnimation() ~= 'Idle' then
                    pocket_charge.Scale = scale
                    pocket_charge:Render(Vector(pos.X+34,pos.Y+2), vector_zero, vector_zero)


                end
            end
            pos.X = pos.X -5
        end
    end
    ----second_pocket
    scale = Vector(0.5,0.5)
    if second_pocket then
        if main_pocket:GetDefaultAnimation() ~= 'Idle' or third_pocket:GetDefaultAnimation() ~= 'Idle' then
            second_pocket.Scale = scale
            second_pocket:Render(Vector(pos.X+32,pos.Y), vector_zero, vector_zero)
        end
    end
    ----main_pocket
    if main_pocket then
        scale = Vector(0.7,0.7)
        main_pocket.Scale = scale
        main_pocket:Render(Vector(pos.X + 16,pos.Y), VECTOR_ZERO, VECTOR_ZERO)
    end
    ---- main_pocket charge
    if main_pocket then
        if main_pocket:GetDefaultAnimation() == 'Idle' then
            --x = init_x + 28--pozycja wyjściowa
            --y = init_y + 24
            scale = Vector(0.5,0.5)
            local pocket_charge  = renderPlayer.getItemChargeSprite(player,2)
            if pocket_charge then
                pocket_charge.Scale = scale
                pocket_charge:Render(Vector(pos.X+26,pos.Y+2), vector_zero, vector_zero)
            end
            pos.X = pos.X -5
        end
    end
    ---- main_pocket_desc
    --x = init_x + 16--pozycja wyjściowa
    --y = init_y + 24 --poz wyściowa

    local main_pocket_desc = ""
    if desc_up then
        pos = Vector(anchor.X+8,anchor.Y-20)
    else
        pos = Vector(anchor.X+8,anchor.Y+4)
    end
    main_pocket_desc = renderPlayer.getMainPocketDesc(player)
    local f = Font()
    f:Load("font/luaminioutlined.fnt")
    local color = KColor(1,0.2,0.2,0.7) -- TODO: sets according to player color
        if main_pocket_desc then
            f:DrawString (main_pocket_desc,pos.X,pos.Y ,color,0,true) end
end



function renderPlayer.checkDeepPockets()
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
function renderPlayer.getHeartSprite(heart_type,overlay)
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
function renderPlayer.getHeartType(player,heart_pos)
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
        heart_type = 'CurseHeart'
        return heart_type,overlay
    else
        eternal = false
        golden = false
        local total_hearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts())/2)
        local empty_hearts = math.floor((player:GetMaxHearts()-player:GetHearts())/2)
        if empty_hearts < 0 then empty_hearts = 0 end
        if player:GetGoldenHearts() > 0 and (heart_pos-(total_hearts - (player:GetGoldenHearts()+empty_hearts))) == 0 then
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
function renderPlayer.renderHearts(player_arr,anchor,opacity)
    -- Hearts - render
    -- TODO: pulsing Tainted Maggy hearts
    local player = player_arr
    local player_total_health = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts())/2)
    local sub_player
    local player_type = player:GetPlayerType()
    local max_health_cap = 12
    local n = 3
    local heart_num = 0
    local opacity = 1.0
    local pos = Vector(anchor.X+10,anchor.Y-10)
    local skipped_heart = 0
    local has_sub = false --
    if player_type == 18 or player_type == 36 then -- Bethany - Tainted Bethany check
        print('Bethany')
        --print('GetSoulCharge',player:GetSoulCharge(),':GetBloodCharge()',player:GetBloodCharge())
        -- TODO: Bethany charge ind - render right of hearts
    elseif player:GetPlayerType() == 19 then -- Jacob/Essau check
        has_sub = true
        n = 2
        sub_player = player:GetOtherTwin()
    elseif player:GetPlayerType() == 16 or player:GetPlayerType() == 17 then  -- ' - Forgotten/Soul render
        max_health_cap = 6
        n = 2
        has_sub = true
        last_row = 0
        sub_player = player:GetSubPlayer()
        opacity = 0.5
    end
    --max_health_cap = 12
    local m = math.floor(max_health_cap/n)
    local counter = 0
    for row=0,n-1,1 do
        for col=0,m-1,1 do
            heart_type,overlay = ''
            heart_type,overlay = renderPlayer.getHeartType(player,counter)
            heart_sprite = renderPlayer.getHeartSprite(heart_type,overlay)
            if heart_sprite then
                temp_pos = Vector(pos.X + (11 * col),pos.Y + (11 * row))
                heart_sprite:Render(temp_pos,VECTOR_ZERO,VECTOR_ZERO)
            end
            counter = counter + 1
        end
    end
    if has_sub then

        pos.Y = pos.Y + (11 * (math.ceil(player_total_health/m))) -- row below first char hearts
        counter = 0
        local color = Color(1, 1, 1, opacity, 0, 0, 0) -- sets color with opacity
        for row=0,n-1,1 do
            for col=0,m-1,1 do
                heart_type,overlay = ''
                heart_type,overlay = renderPlayer.getHeartType(sub_player,counter)
                heart_sprite = renderPlayer.getHeartSprite(heart_type,overlay)
                if heart_sprite then
                    temp_pos = Vector(pos.X + (11 * col),pos.Y + (11 * row))
                    heart_sprite.Color = color
                    heart_sprite:Render(temp_pos,VECTOR_ZERO,VECTOR_ZERO)
                end
                counter = counter + 1
            end
        end
    end -- Sub player render heart
end
function renderPlayer.renderItems(anchor)
    local pos = Vector(anchor.X,anchor.Y)
    local Anim = "gfx/ui/hudpickups.anm2"
    local coin_no,bomb_no,key_no = 0

    --,key_sprite

    local f = Font()
    f:Load("font/luaminioutlined.fnt")
    local color = KColor(1,1,1,1)
    local player = Isaac.GetPlayer(0)
    local coin_sprite= Sprite()
    local has_deep_pockets = false
    coin_sprite:Load(Anim,true)
    coin_sprite:SetFrame('Idle', 0)
    coin_sprite:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
    coin_no = Isaac.GetPlayer(0):GetNumCoins()
    coin_no = string.format("%.2i", coin_no)
    if renderPlayer.checkDeepPockets() then
        pos.X = pos.X - 2
        coin_no = string.format("%.3i", coin_no) end
    f:DrawString(coin_no,pos.X+16,pos.Y,color,0,true)


    pos.Y = pos.Y + 12

    local bomb_sprite = Sprite()
    bomb_sprite:Load(Anim,true)
    bomb_sprite:SetFrame('Idle',2)
    if player:HasGoldenBomb()  then bomb_sprite:SetFrame('Idle',6) end
    bomb_sprite:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
    bomb_no = player:GetNumBombs()
    bomb_no = string.format("%.2i", bomb_no)
    f:DrawString(bomb_no,pos.X+16,pos.Y,color,0,true)

    pos.Y = pos.Y + 12
    local key_sprite = Sprite()
    key_sprite:Load(Anim,true)
    key_sprite:SetFrame('Idle',1)
    if player:HasGoldenKey()  then key_sprite:SetFrame('Idle',3 ) end
    key_sprite:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
    key_no = player:GetNumKeys()
    key_no = string.format("%.2i", key_no)
    f:DrawString(key_no,pos.X+16,pos.Y,color,0,true)
end
function renderPlayer.render(player_num,anchor,trinket_up,mirrored)
    local player = Isaac.GetPlayer(player_num)
    if trinket_up == nil then trinket_up = false end
    if mirrored == nil then mirrored = false end
    if mirrored then
        -- TODO:
        local active_off = renderPlayer.renderActiveItem(player,anchor)
        renderPlayer.renderHearts(player,Vector(active_off.X,anchor.Y))
    else
        local active_off = renderPlayer.renderActiveItem(player,anchor)
        renderPlayer.renderHearts(player,Vector(active_off.X,anchor.Y))
    end

    if trinket_up then
        local trinket_off = renderPlayer.renderTrinkets(player,Vector(anchor.X,anchor.Y - 50) )
        renderPlayer.renderPockets(player,Vector(trinket_off.X,anchor.Y-24),true)
    else
        local trinket_off = renderPlayer.renderTrinkets(player,anchor)
        renderPlayer.renderPockets(player,Vector(trinket_off.X,trinket_off.Y))
    end



    ---- DEBUG: Heart overlay test
    --a = renderPlayer.getHeartSprite('RedHeartFull','WhiteHeartOverlay')
    --a:SetOverlayFrame('WhiteHeartOverlay', 0)
    --a:SetOverlayFrame('GoldHeartOverlay', 0)
    --a:Render(Vector(100,100),VECTOR_ZERO,VECTOR_ZERO)

end

-- OPTIONS
hud_on = true
--START GAME
function coopHUD.start_game(continued)
    if continued then

    else

    end
    print('Coop HUD loaded')
end
coopHUD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED,coopHUD.start_game())

--MCM
local MCM = nil
if ModConfigMenu then -- checks if
    MCM = require("scripts.modconfig")
end

--if coopHUD:HasData() then -- Loads data from file
--    options_data = json.decode(coopHUD:LoadData())
--end
--MCM.UpdateCategory("Coop HUD", {
--    Info = "Settings for Coop HUD mod"
--})
--MCM.AddText("Coop HUD", "Turn on:")
--MCM.AddSetting("Coop HUD", {
--    Type = MCM.OptionType.BOOLEAN,
--    CurrentSetting = function()
--        return hud_on
--    end,
--    Display = function()
--        return hud_on
--    end,
--    OnChange = function(value)
--        if hud_on then hud_on = false
--        else
--            hud_on = true
--        end
--    end,
--    Info = {
--        "Turn on/off hud"
--    }
--})

player={}
local function getMinimapOffset()
    local min = Vector(999,999)
    for _,room in ipairs(MinimapAPI:GetLevel()) do
        if room:GetDisplayFlags() > 0 then
            if room.Position.X < min.X then min = room.Position end
        end
    end

    return MinimapAPI:GetRoomAtPosition(min).RenderOffset

end
getMinimapOffset()
--MinimapAPI.Debug.RandomMap()
function coopHUD:saveoptions()
    local options = {'kupa','sex'}
    coopHUD:SaveData(json.encode(ask))
end
coopHUD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT,coopHUD.saveoptions)
--local renderPlayer = require('renderPlayer') -- TODO: split files
--MAIN MOD
function coopHUD.render()
    if hud_on then
        local ScreenSize = (Isaac.WorldToScreen(Vector(320, 280)) - Game():GetRoom():GetRenderScrollOffset() - Game().ScreenShakeOffset) * 2
        Game():GetHUD():SetVisible(false)
        renderPlayer.render(0,Vector(20,20),false,false)
        -- renderPlayer.render(player_num,anchor,trinket_up,mirrored)
        -- p1 - pos (20, 20)- left up corner
        -- P2 - pos (20, ScreenSize.Y-15) - left down corner

        renderPlayer.render(1,Vector(100,100),false,true)
        --renderPlayer.render(1,Vector(ScreenSize.X-20,20),false,true)
        --renderPlayer.render(1,Vector(100,100),true)
        local screen_size = ScreenHelper.GetScreenTopRight()
        offsetVec = Vector(screen_size.X - MinimapAPI:GetConfig("PositionX"), screen_size.Y + MinimapAPI:GetConfig("PositionY"))
        print(offsetVec)
    else
        Game():GetHUD():SetVisible(true)
        print(MinimapAPI:IsPositionFree(position,roomshape))
    end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)
