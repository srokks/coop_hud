function coopHUD.getActiveItemSprite(player,slot)
    local Anim = "gfx/ui/item.anm2"
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
    -- TODO:Book of Virtuoses sprite set
    --if activeitem == 584 then
    --  itemsprite = "gfx/characters/costumes/costume_434_jarofflies.png"
    --end
    -- Urn of Souls - sprite set
    if active_item == 640 then
        item_sprite = "gfx/ui/hud_urnofsouls.png"
    end
    this_sprite:ReplaceSpritesheet(0, item_sprite)
    this_sprite:ReplaceSpritesheet(1, item_sprite)
    this_sprite:ReplaceSpritesheet(2, item_sprite)
    this_sprite:ReplaceSpritesheet(3, item_sprite)
    this_sprite:ReplaceSpritesheet(4, item_sprite)
    this_sprite:ReplaceSpritesheet(5, item_sprite)
    if player:HasCollectible(584) and active_item ~= 584 then
        item_sprite = 'gfx/ui/hud_bookofvirtues.png'
        this_sprite:ReplaceSpritesheet(6, item_sprite)
    end
    this_sprite:LoadGraphics() -- sets item overlay according to charges
    -- Sets overlay/charges state frame --
    local itemcharge = Isaac.GetItemConfig():GetCollectible(active_item).MaxCharges -- gets max charges
    if itemcharge == 0 then -- checks id item has any charges
        this_sprite:SetFrame("Idle", 0 ) -- set frame to unloaded
    elseif player:NeedsCharge(slot) == false or player:GetActiveCharge(slot) >= itemcharge then
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
    -- TODO: Jar of Wisp
    --if activeitem == 685 then
    --    --TODO: anim frames
    --    --TODO: get charges
    --end
    -- TODO:Urn of soul
    if active_item == 640 then
        fi_charge = 0
        print(player:GetJarFlies())
        --      --TODO: get charge of urn
        this_sprite:SetFrame("SoulUrn", fi_charge) -- sets frame
    end

    return this_sprite
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