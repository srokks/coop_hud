function coopHUD.getActiveItemSprite(player,slot)
    -- Todo: change name of item animaton file
    local Anim = "gfx/ui/tit.anm2"
    local overlay = ''
    local active_item = player:GetActiveItem(slot)
    if active_item == 0 then return false end
    local this_sprite = Sprite() -- replaced
    this_sprite:Load(Anim,true)
    local item_sprite = Isaac.GetItemConfig():GetCollectible(active_item).GfxFileName
    --Jar's check and sets item_sprite
    if active_item == 290 then -- the jar
        item_sprite = "gfx/characters/costumes/costume_rebirth_90_thejar.png"
    elseif active_item == 434 then -- jar of flies
        item_sprite = "gfx/characters/costumes/costume_434_jarofflies.png"
    elseif active_item == 685 then -- jar of wisp
        item_sprite = "gfx/ui/hud_jarofwisps.png"
    elseif active_item == 720 then -- everything jar
        item_sprite = "gfx/ui/hud_everythingjar.png"
    end
    -- Urn of Souls - sprite set
    if active_item == 640 then
        item_sprite = "gfx/ui/hud_urnofsouls.png"
    end
    this_sprite:ReplaceSpritesheet(0, item_sprite) -- item
    this_sprite:ReplaceSpritesheet(1, item_sprite) -- border
    this_sprite:ReplaceSpritesheet(2, item_sprite) -- shadow

    -- Sets overlay/charges state frame --
    local item_charge = Isaac.GetItemConfig():GetCollectible(active_item).MaxCharges -- gets max charges
    if item_charge == 0 then -- checks id item has any charges
        this_sprite:SetFrame("Idle", 0 ) -- set frame to unloaded
    elseif player:NeedsCharge(slot) == false or player:GetActiveCharge(slot) >= item_charge then
        -- checks if item dont needs charges or item is overloaded
        this_sprite:SetFrame("Idle", 1) -- set frame to loaded
    else
        this_sprite:SetFrame("Idle", 0) -- set frame to unloaded
    end
    --The Jar/Jar of Flies - charges check
    if active_item == 290 or active_item == 434 then --
        local frame = 0
        if active_item == 290 then frame = math.ceil(player:GetJarHearts()/2) end -- gets no of hearts in jar
        if active_item == 434 then frame = player:GetJarFlies() end --gets no of flies in jar of flies
        this_sprite:SetFrame("Jar", frame)
    end
    -- Everything Jar - charges set
    if active_item == 720  then
        fi_charge = player:GetActiveCharge()
        this_sprite:SetFrame("EverythingJar", fi_charge +1)
    end
     --TODO: Jar of Wisp
    if active_item == 685 then
        --print(coopHUD.jar_of_wisp_charge,'test')
        if coopHUD.jar_of_wisp_charge > 12 then
            coopHUD.jar_of_wisp_charge = 12
        end
        this_sprite:SetFrame('WispJar',coopHUD.jar_of_wisp_charge)
    end
    -- TODO:Urn of soul
    if active_item == 640 then
        fi_charge = 0
        print(player:GetJarFlies())
        --      --TODO: get charge of urn
        this_sprite:SetFrame("SoulUrn", fi_charge) -- sets frame
    end
    if player:HasCollectible(584)  or player:HasCollectible(619) then
        -- checks if player has virtuoses or bithright
        if player:HasCollectible(584) and active_item ~= 584 then -- sets virtuoses sprite
            item_sprite = 'gfx/ui/hud_bookofvirtues.png'
            this_sprite:ReplaceSpritesheet(3, item_sprite)
            this_sprite:ReplaceSpritesheet(4, item_sprite)

        end
        if player:GetPlayerType() == 3 and player:HasCollectible(619)  then -- if judas and has birthrignt
            if player:HasCollectible(584) and active_item ~= 584 then
                 item_sprite = 'gfx/ui/hud_bookofvirtueswithbelial.png' -- sets virt/belial sprite
                this_sprite:ReplaceSpritesheet(3, item_sprite)
                this_sprite:ReplaceSpritesheet(4, item_sprite)
            else
                 item_sprite = 'gfx/ui/hud_bookofbelial.png' -- sets belial sprite
                this_sprite:ReplaceSpritesheet(3, item_sprite)
                this_sprite:ReplaceSpritesheet(4, item_sprite)
            end
        end
    end
    this_sprite:LoadGraphics()

    return this_sprite
end
function coopHUD.getChargeSprites(player,slot) -- Gets charge of item from  player, slot
    local sprites = {
        beth_charge = Sprite(),
        charge = Sprite(),
        overlay = Sprite(),
    }
    local anim = "gfx/ui/activechargebar_coop.anm2"
    local active_item = player:GetActiveItem(slot)
    if active_item == 0 then return false end
    local item_charge = Isaac.GetItemConfig():GetCollectible(active_item).MaxCharges
    if item_charge == 0 then return false end
    -- Normal and battery charge
    local charges = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
    local step = math.floor((charges/(item_charge *2))*46)
    sprites.charge:Load(anim,true)
    sprites.charge:SetFrame('ChargeBar',step)
    -- Overlay sprite
    sprites.overlay:Load(anim,true)
    if (item_charge > 1 and item_charge < 5) or item_charge == 6 or item_charge == 12 then
        sprites.overlay:SetFrame("BarOverlay" .. item_charge, 0)
    else
        sprites.overlay:SetFrame("BarOverlay1", 0)
    end
    -- Bethany charge
    local player_type = player:GetPlayerType()
    if player_type == 18 or player_type == 36 then
        local beth_charge
        local color = Color(1,1,1,1,0,0,0)
        if  player_type == 18 then
            beth_charge = player:GetEffectiveSoulCharge()
            color:SetColorize(0.8,0.9,1.8,1)
        elseif player_type == 36 then
            beth_charge = player:GetEffectiveBloodCharge()
            color:SetColorize(1,0.2,0.2,1)
        end
        sprites.beth_charge:Load(anim,true)
        sprites.beth_charge.Color = color
        step = step +  math.floor((beth_charge/(item_charge *2))*46) + 1
        sprites.beth_charge:SetFrame('ChargeBar',step)
    else
        sprites.beth_charge = false
    end
    return sprites
end
function coopHUD.getTrinketSprite(player, trinket_pos)
    -- Todo: change name of item animaton file
    Anim = "gfx/ui/tit.anm2"
    local trinket_id = player:GetTrinket(trinket_pos)
    if trinket_id == 0 then return false end
    local sprite = Sprite()
    sprite:Load(Anim,true)
    local item_sprite = Isaac.GetItemConfig():GetTrinket(trinket_id).GfxFileName
    sprite:ReplaceSpritesheet(0, item_sprite) -- item layer
    sprite:ReplaceSpritesheet(2, item_sprite) -- shadow layer
    sprite:LoadGraphics()
    sprite:SetFrame("Idle", 0)
    return sprite
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
        local item_pool = Game():GetItemPool()
        if item_pool:IsPillIdentified (player:GetPill(0)) then
            local pill_effect = item_pool:GetPillEffect(player:GetPill(0))
            desc = Isaac.GetItemConfig():GetPillEffect(pill_effect).Name .. " "
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