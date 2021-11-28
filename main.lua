coopHUD = RegisterMod("Coop HUD", 1)
local json = require("json")
local MinimapAPI = require("scripts.minimapapi")
local SHExists, ScreenHelper = pcall(require, "scripts.screenhelper")
anchor_top_left = ScreenHelper.GetScreenTopLeft()
anchor_bottom_left = ScreenHelper.GetScreenBottomLeft()
anchor_top_right = ScreenHelper.GetScreenTopRight()
anchor_bottom_right = ScreenHelper.GetScreenBottomRight()
anchor_middle_bottom = ScreenHelper.GetScreenCenter()
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
function coopHUD.getPocketItemSprite(player,slot)
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
                    thissprite = coopHUD.getActiveItemSprite(player,2)
                else
                    thissprite = coopHUD.getActiveItemSprite(player,3)
                end
                return thissprite
            else
                return false
            end
        end
    end
end
function coopHUD.getMainPocketDesc(player)
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
function coopHUD.renderActiveItems(player_table)
    local anchor = player_table.anchor
    local offset = Vector(0,0)
    local off = Vector(0,0)
    player_table.first_active:Render(Vector(100,100),VECTOR_ZERO,VECTOR_ZERO)
    if anchor.X == anchor_top_left.X and anchor.Y == anchor_top_left.Y then
        pos = Vector(anchor.X + 20,anchor.Y+16)
        off.X = 12
        off.Y = 36
    elseif anchor.X == anchor_bottom_left.X and anchor.Y == anchor_bottom_left.Y  then
        pos = Vector(anchor.X + 20,anchor.Y-16)
        off.X = 12
        off.Y = -42
    elseif anchor.X == anchor_top_right.X and anchor.Y == anchor_top_right.Y then
        pos = Vector(coopHUD.getMinimapOffset().X,anchor.Y+16)
        off.X = 12
        off.Y = 36
    elseif anchor.X == anchor_bottom_right.X and anchor.Y == anchor_bottom_right.Y then
        pos = Vector(anchor.X - 24,anchor.Y-16)
        off.X = -12
        off.Y = -42
    end

    if player_table.first_active or player_table.second_active then
        if anchor.X == anchor_top_left.X and anchor.Y == anchor_top_left.Y then
            off.X = 48
        elseif anchor.X == anchor_bottom_left.X and anchor.Y == anchor_bottom_left.Y  then
            off.X = 48
        elseif anchor.X == anchor_top_right.X and anchor.Y == anchor_top_right.Y then
            off.X = - 20
        elseif anchor.X == anchor_bottom_right.X and anchor.Y == anchor_bottom_right.Y then
            off.X = -48
        end
        if player_table.second_active then -- First item charge render
            player_table.second_active.Scale = Vector(0.5,0.5)
            player_table.second_active:Render(Vector(pos.X - 16,pos.Y - 8), vector_zero, vector_zero)
        end
        if player_table.se_charge then -- Second item charge render -- UGLY - can turn on
            --player_table.se_charge.Scale = Vector(0.5,0.5)
            --player_table.se_charge:Render(Vector(pos.X - 15,pos.Y - 9), vector_zero, vector_zero)
        end
        if player_table.first_active then
            player_table.first_active:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
        end
        pos.X = pos.X + 17
        if player_table.fi_charge then
            player_table.fi_charge:Render(pos, VECTOR_ZERO, VECTOR_ZERO)
        end
    end
    offset.X = offset.X + off.X
    offset.Y = offset.Y + off.Y
    return offset
end
function coopHUD.renderTrinkets(player_table)
    local mirrored = false
    local anchor = Vector(player_table.anchor.X,player_table.anchor.Y)
    local off = 0
    print(anchor,"active off:",player_table.active_item_offset)
     -- TODO: first line offset
    local trinket_offset = Vector(0,0)
    local scale = Vector(0.5,0.5)
    if anchor.X == anchor_top_left.X and anchor.Y == anchor_top_left.Y then
        pos = Vector(anchor.X+12,anchor.Y+ 8 +player_table.active_item_offset.Y)
        off = 24
    elseif anchor.X == anchor_bottom_left.X and anchor.Y == anchor_bottom_left.Y  then
        pos = Vector(anchor.X + 12,anchor.Y - 10 + player_table.active_item_offset.Y)
        off = -20
    elseif anchor.X == anchor_top_right.X and anchor.Y == anchor_top_right.Y then
        pos = Vector(coopHUD.getMinimapOffset().X+12,anchor.Y+ 8 +player_table.active_item_offset.Y)
        anchor.Y  = anchor.Y + player_table.active_item_offset.Y
        mirrored = true
        off = 24
    elseif anchor.X == anchor_bottom_right.X and anchor.Y == anchor_bottom_right.Y then
        pos = Vector(anchor.X - 12,anchor.Y - 10 + player_table.active_item_offset.Y)
        mirrored = true
        off = -20
    end
    if player_table.first_trinket then
        if player_table.second_trinket then
            if mirrored then pos = Vector(pos.X-16,pos.Y) end-- if has trinket 2
        else
            pos = Vector(pos.X,pos.Y)
            scale = Vector(0.7,0.7) -- makes trinket bigger
        end
        player_table.first_trinket.Scale = scale
        player_table.first_trinket:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
        pos = Vector(pos.X+16,pos.Y)
        trinket_offset.Y = trinket_offset.Y + off
    end
    if player_table.second_trinket then
        player_table.second_trinket.Scale = scale
        player_table.second_trinket:Render(pos,vector_zero,vector_zero)
    end
    return trinket_offset
end
function coopHUD.renderPockets(player_table)
    local scale = Vector(1,1)
    local anchor = player_table.anchor
    local off = 0
    local desc_off = Vector(0,0)
    anchor.Y = anchor.Y + player_table.sec_row_offset.Y
    if anchor.X == anchor_top_left.X and anchor.Y == anchor_top_left.Y then
        pos = Vector(anchor.X + 12 ,anchor.Y + 12 )
        off = 16
        desc_off = Vector(2,4)
    elseif anchor == anchor_bottom_left then
        pos = Vector(anchor.X+12,anchor.Y-12)
        off = 16
        desc_off = Vector(2,4)
    elseif anchor == anchor_top_right then
        pos = Vector(coopHUD.getMinimapOffset().X+8,anchor.Y+12)
        off = -16
        desc_off = Vector(-50,0)
        if string.len(desc) > 12 then
            player_table.main_pocket_desc = string.format("%.9s...",player_table.main_pocket_desc)
        end
    elseif anchor == anchor_bottom_right then
        pos = Vector(anchor.X-16,anchor.Y-12)
        desc_off = Vector(-50,4)
        if string.len(desc) > 12 then
            player_table.main_pocket_desc = string.format("%.9s...",player_table.main_pocket_desc)
        end
    end
    ------third pocket
    scale = Vector(0.5,0.5)
    if player_table.third_pocket then
        if player_table.third_pocket:GetDefaultAnimation() ~= 'Idle' then
            player_table.third_pocket.Scale = scale
            player_table.third_pocket:Render(Vector(pos.X + (2 * off),pos.Y), vector_zero, vector_zero)
        else
            if player_table.main_pocket:GetDefaultAnimation() ~= 'Idle' and player_table.second_pocket :GetDefaultAnimation() ~= 'Idle' then
                player_table.second_pocket.Scale = scale
                player_table.second_pocket:Render(Vector(pos.X+(2 * off),pos.Y), vector_zero, vector_zero)
            end
        end
    end
    ----second_pocket
    scale = Vector(0.5,0.5)
    if player_table.second_pocket then
        if player_table.main_pocket:GetDefaultAnimation() ~= 'Idle' or player_table.third_pocket:GetDefaultAnimation() ~= 'Idle' then
            player_table.second_pocket.Scale = scale
            player_table.second_pocket:Render(Vector(pos.X+off,pos.Y ), vector_zero, vector_zero)
        end
        if player_table.second_pocket:GetDefaultAnimation() == 'Idle' then
            scale = Vector(0.3,0.3 )
            --local pocket_charge  = renderPlayer.getItemChargeSprite(player,2)
            --if pocket_charge then
            --    if main_pocket:GetDefaultAnimation() ~= 'Idle' or second_pocket:GetDefaultAnimation() ~= 'Idle' then
            --        pocket_charge.Scale = scale
            --        pocket_charge:Render(Vector(pos.X+34,pos.Y+2), vector_zero, vector_zero)
            --
            --
            --    end
            --end
        end
    end
    -- Main pocket
    if player_table.main_pocket then
        scale = Vector(0.7,0.7)
        player_table.main_pocket.Scale = scale
        player_table.main_pocket:Render(pos, VECTOR_ZERO, VECTOR_ZERO)
        ---- main_pocket charge
        if player_table.main_pocket:GetDefaultAnimation() == 'Idle' then
            scale = Vector(0.5,0.5)
            if player_table.pocket_charge then
                player_table.pocket_charge.Scale = scale
                player_table.pocket_charge:Render(Vector(pos.X+12,pos.Y+2), vector_zero, vector_zero)
            end
        end
        local f = Font()
        f:Load("font/luaminioutlined.fnt")
        local color = player_table.f_color -- TODO: sets according to player color
        if player_table.main_pocket_desc then
            f:DrawString (player_table.main_pocket_desc,pos.X+desc_off.X,pos.Y+desc_off.Y ,color,0,true) end
    end


end
function coopHUD.renderHearts(player_table)
    local max_health_cap = 12
    local n = 3 -- No. of rows
    local m = math.floor(max_health_cap/n)  -- No.
    local anchor = player_table.anchor
    local mirrored = false
    local offset = Vector(0,0)
    local off = Vector(0,0)
    local col_count = player_table.player_total_health % m
    if player_table.player_total_health > 3 then
        col_count = 4
    end
    if anchor.X == anchor_top_left.X and anchor.Y == anchor_top_left.Y then
        pos = Vector(anchor.X + player_table.active_item_offset.X ,anchor.Y+8)
        offset.X = offset.X + (8 * col_count)
        off.Y = 0
    elseif anchor.X == anchor_bottom_left.X and anchor.Y == anchor_bottom_left.Y  then
        pos = Vector(anchor.X+ player_table.active_item_offset.X,anchor.Y - 32)
        offset.X = offset.X + (8 * col_count)
        off.Y = 0
    elseif anchor.X == anchor_top_right.X and anchor.Y == anchor_top_right.Y then
        pos = Vector(coopHUD.getMinimapOffset().X + player_table.active_item_offset.X,anchor.Y+8)
        offset.X = offset.X - (8 * col_count)
        off.Y = 0
        pos.X = pos.X - (8 * col_count)
    elseif anchor.X == anchor_bottom_right.X and anchor.Y == anchor_bottom_right.Y then
        pos = Vector(anchor.X +player_table.active_item_offset.X ,anchor.Y - 32)
        offset.X = offset.X - (8 * col_count)
        off.Y = 0
        pos.X = pos.X - (8 * col_count)
    end
    local counter = 0
    local heart_space = 11
    for row=0,n-1,1 do
        for col=0,m-1,1 do

            if player_table.hearts[counter] then
                if player_table.is_sub then
                    player_table.hearts[counter].Scale = Vector(0.7,0.7)
                    player_table.hearts[counter].Color =Color(1, 1, 1, 0.5, 0, 0, 0)
                end
                temp_pos = Vector(pos.X + (heart_space * col),pos.Y + (heart_space * row))
                player_table.hearts[counter]:Render(temp_pos,VECTOR_ZERO,VECTOR_ZERO)
            end
            counter = counter + 1
        end
    end
    if player_table.has_sub then -- Sub player heart render
        counter = 0
        local temp_heart_space = 8
        if anchor.Y == anchor_top_left.Y then
            pos.Y = anchor.Y + 26
        elseif anchor.Y == anchor_bottom_right.Y then
            pos.Y = anchor.Y - 12
        end

        for row=0,n-1,1 do
            for col=0,m-1,1 do
                if player_table.sub_hearts[counter] then
                    player_table.sub_hearts[counter].Scale = Vector(0.7,0.7)
                    player_table.sub_hearts[counter].Color =Color(1, 1, 1, 0.5, 0, 0, 0)
                    temp_pos = Vector(pos.X + (temp_heart_space * col),pos.Y + (temp_heart_space * row))
                    player_table.sub_hearts[counter]:Render(temp_pos,VECTOR_ZERO,VECTOR_ZERO)
                end
                counter = counter + 1
            end
        end
    end
    offset.X = offset.X + player_table.active_item_offset.X
    return offset
end
function coopHUD.getPlayer(player,player_no)
    -- TODO: Course of uknown heart render
    local sub
    local char = {
        name = nil,
        type = nil,
        f_color = nil,
        player_total_health = 0,
        anchor = Vector(0,0),
        first_active = nil,
        second_active = nil,
        fi_charge = nil,
        se_charge = nil,
        second_trinket = nil,
        main_pocket = nil,
        pocket_charge = nil,
        second_pocket = nil,
        third_pocket = nil,
        main_pocket_desc = nil,
        hearts = nil,
        extra_lives = nil,
        extra_lives = nil,
        has_sub = false,
        is_sub = false,
        active_item_offset = Vector(0,0),
        hearts_offset = Vector(0,0),
        sub_hearts = nil,
        sec_row_offset = Vector(0,0)

    }
    char.name = coopHUD.players_config[player_no].name -- Gets name from config
    char.type = player:GetPlayerType()
    char.f_color = coopHUD.players_config[player_no].f_color -- Gets font color from config
    char.player_total_health = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts())/2)
    char.anchor = coopHUD.players_config[player_no].anchor
    char.first_active = coopHUD.getActiveItemSprite(player,0)
    char.second_active = coopHUD.getActiveItemSprite(player,1)
    char.fi_charge = coopHUD.getItemChargeSprite(player,0)
    char.se_charge = coopHUD.getItemChargeSprite(player,1)
    char.first_trinket = coopHUD.getTrinketSprite(player,0)
    char.second_trinket = coopHUD.getTrinketSprite(player,1)
    char.main_pocket = coopHUD.getPocketItemSprite(player,0)
    char.pocket_charge = coopHUD.getItemChargeSprite(player,2)
    char.second_pocket = coopHUD.getPocketItemSprite(player,1)
    char.third_pocket = coopHUD.getPocketItemSprite(player,2)
    char.main_pocket_desc = coopHUD.getMainPocketDesc(player)
    char.hearts = coopHUD.getHeartSpriteTable(player)
    char.extra_lives = player:GetExtraLives()
    char.extra_lives = string.format('x%d',char.extra_lives )
    char.first_row_offset = nil
    if player:HasCollectible(212) then  char.extra_lives = string.format('%s?',char.extra_lives) end
    if char.type == 18 or char.type == 36 then -- Bethany/T.Bethany check
        if char.type == 18 then
            char.bethany_charge = player:GetSoulCharge()
        else
            char.bethany_charge = player:GetBloodCharge()
        end
    end
    if  player:GetPlayerType() == 16 or player:GetPlayerType() == 17 then -- Forgotten/Soul check
        char.has_sub = true
        local sub = player:GetSubPlayer()
        char.sub_hearts = coopHUD.getHeartSpriteTable(sub)
    end
    if player:GetPlayerType() == 19 then -- Jacob/Essau check
        --TODO: Jacob/Essau: make player_num+1-> render second in oposite corner/ restrict only when 1
        --players.has_sub = true
    end
    return char
end
function coopHUD.renderExtraLives(player_table)
    -- TODO:
    local anchor = player_table.anchor
    if anchor.X == anchor_top_left.X and anchor.Y == anchor_top_left.Y then
        pos = Vector(anchor.X+12,anchor.Y+2)
    elseif anchor.X == anchor_bottom_left.X and anchor.Y == anchor_bottom_left.Y  then
        pos = Vector(anchor.X+12,anchor.Y-20)
    elseif anchor.X == anchor_top_right.X and anchor.Y == anchor_top_right.Y then
        pos = Vector(coopHUD.getMinimapOffset().X-24,anchor.Y+2)
    elseif anchor.X == anchor_bottom_right.X and anchor.Y == anchor_bottom_right.Y then
        pos = Vector(anchor.X-24,anchor.Y-24)
    end
    if player_table.extra_lives ~= 'x0' then
        local f = Font()
        f:Load("font/luaminioutlined.fnt")
        f:DrawString (player_table.extra_lives,pos.X+player_table.hearts_offset.X,pos.Y,player_table.f_color,0,true)
    end
end
function coopHUD.renderBethanyCharge(player_table)
    -- TODO:
    local anchor = player_table.anchor
    if anchor.X == anchor_top_left.X and anchor.Y == anchor_top_left.Y then
        pos = Vector(anchor.X+14,anchor.Y+2)
    elseif anchor.X == anchor_bottom_left.X and anchor.Y == anchor_bottom_left.Y  then
        pos = Vector(anchor.X+16,anchor.Y-2)
    elseif anchor.X == anchor_top_right.X and anchor.Y == anchor_top_right.Y then
        pos = Vector(coopHUD.getMinimapOffset().X-26,anchor.Y+2)
    elseif anchor.X == anchor_bottom_right.X and anchor.Y == anchor_bottom_right.Y then
        pos = Vector(anchor.X-24,anchor.Y-2)
    end
    local heart_sprite = Sprite()
    if player_table.type == 18 then
        heart_sprite = coopHUD.getHeartSprite('BlueHeartFull','None')
    else
        heart_sprite = coopHUD.getHeartSprite('RedHeartFull','None')
    end
    heart_sprite.Scale = Vector(0.6,0.6)
    heart_sprite:Render(Vector(pos.X+player_table.hearts_offset.X,pos.Y),VECTOR_ZERO,VECTOR_ZERO)
    local f = Font()
    local bethany_charge = string.format('x%d',player_table.bethany_charge)
    f:Load("font/luaminioutlined.fnt")
    f:DrawString (bethany_charge,pos.X+player_table.hearts_offset.X+6,pos.Y-9,player_table.f_color,0,true)
end
function coopHUD.renderPlayer(player_num)
    --print(player_num,coopHUD.players_table[player_num].first_active)
    --coopHUD.players_table[player_num].first_active:Render(Vector(100,100),VECTOR_ZERO,VECTOR_ZERO)
    coopHUD.players_table[player_num].active_item_offset = coopHUD.renderActiveItems(coopHUD.players_table[player_num])
    ---
    coopHUD.players_table[player_num].hearts_offset = coopHUD.renderHearts(coopHUD.players_table[player_num])
    coopHUD.renderExtraLives(coopHUD.players_table[player_num])
    if coopHUD.players_table[player_num].type == 18 or coopHUD.players_table[player_num].type == 36 then
        coopHUD.renderBethanyCharge(coopHUD.players_table[player_num])
    end
    coopHUD.players_table[player_num].sec_row_offset = coopHUD.renderTrinkets(coopHUD.players_table[player_num])  --DEBUG
    --coopHUD.renderPockets(coopHUD.players_table[player_num])  --DEBUG

    --local pos = anchor
    --pos.Y = pos.Y + trinket_offset.Y
    --print(trinket_offset)
    --players.pocket_charge:Render(Vector(100,100),VECTOR_ZERO,VECTOR_ZERO)
end
function coopHUD.checkDeepPockets()
    local deep_check = false
    local player_no = Game():GetNumPlayers()-1
    for i=1,player_no,1 do
        local deep = Isaac.GetPlayer(i):HasCollectible(416)
        if  deep  then
            deep_check = true
        end
    end
    return deep_check
end
function coopHUD.renderItems(anchor)
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
render_coop_hud = true
force_on_sp = false
--player_config =  {}
--player_config[0].color = Color(1,1,1,1)
--player_config[0].anchor = Vector(0,0)
local MCM = require("scripts.modconfig")
MCM.AddSpace("COOP HUD", "HUD")
MCM.AddSetting("COOP HUD", "HUD", {
    Type = MCM.OptionType.BOOLEAN,
    CurrentSetting = function()
        return force_on_sp
    end,
    Display = function()
        if force_on_sp == true then
            return "Force on SP: On"
        else
            return "Force on SP: Off"
        end
    end,
    OnChange = function(value)
        render_coop_hud = value
    end,
    Info = {
        "Force to render COOP HUD on singleplayer run"
    }
})


coopHUD.players_config =  {}
coopHUD.players_config[1] ={
    name = 'P1',
    anchor = ScreenHelper.GetScreenTopLeft(),
    f_color = KColor(1,0.2,0.2,1)
}
coopHUD.players_config[2] ={
    name = 'P2',
    anchor = ScreenHelper.GetScreenTopRight(),
    f_color = KColor(1,0.2,0.2,1)
}
coopHUD.players_config[3] ={
    name = 'P3',
    anchor = ScreenHelper.GetScreenBottomLeft(),
    f_color = KColor(1,0.2,0.2,1)
}
coopHUD.players_config[4] ={
    name = 'P4',
    anchor = ScreenHelper.GetScreenBottomRight(),
    f_color = KColor(1,0.2,0.2,1)
}


coopHUD.players_table = {}
function coopHUD:player_joined()
     players_no = Game():GetNumPlayers()
    if players_no > 0 then
        render_coop_hud = true
    end
    for i = 1,2,1 do
        local player_obj = Isaac.GetPlayer(0)
        coopHUD.players_table[i] = coopHUD.getPlayer(player_obj,i)
    end
end

function coopHUD.render()
    if render_coop_hud then
        for i = 1,2,1 do
            local player_obj = Isaac.GetPlayer(0)
            coopHUD.players_table[i] = coopHUD.getPlayer(player_obj,i)
        end
        anchor_top_left = ScreenHelper.GetScreenTopLeft()
        anchor_bottom_left = ScreenHelper.GetScreenBottomLeft()
        anchor_top_right = ScreenHelper.GetScreenTopRight()
        anchor_bottom_right = ScreenHelper.GetScreenBottomRight()
        anchor_middle_bottom = ScreenHelper.GetScreenCenter()
        for i=1,2,1 do
            --print(coopHUD.players_table.name)
            coopHUD.renderPlayer(i)
        end
        Game():GetHUD():SetVisible(false)
    else
        Game():GetHUD():SetVisible(true)
    end


    --for i = 0,2,1 do
    --    coopHUD.renderPlayer(i)
    --end

    --if render_coop_hud then



    --coopHUD.renderPlayer(0,anchor_top_left)
    --coopHUD.renderPlayer(0,anchor_bottom_left)
    --coopHUD.renderPlayer(0,anchor_top_right)
    --coopHUD.renderPlayer(0,anchor_bottom_right)


    coopHUD.renderItems(Vector(ScreenHelper.GetScreenSize().X/2,ScreenHelper.GetScreenBottomLeft().Y-16))
    --Game():GetHUD():SetVisible(false)
    --else
    --    Game():GetHUD():SetVisible(true)
    --end
    --
    --
end

coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, coopHUD.player_joined)
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)