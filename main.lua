coopHUD = RegisterMod("Coop HUD", 1)
local SHExists, ScreenHelper = pcall(require, "scripts.screenhelper")
local game_table = {
    coins_no = 0;
    bomb_no = 0;
    keys_no = 0;
    angel_chance = 0;
    devil_chance = 0;
    planetarium_chance = 0;
}
local onRender = true
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
        extra_lives = string.format('x%d', temp_player:GetExtraLives()),
        bethany_charge = 0, -- inits charge for Bethany
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
function coopHUD.renderPlayer(player_no)
    local offset = Vector(0,0)
    anchor = top_left_anchor
    ----Render active item
    if coopHUD.players[player_no].sprites.first_active or coopHUD.players[player_no].sprites.second_active then
        offset = Vector(offset.X + 49,offset.Y+48)
        if coopHUD.players[player_no].sprites.second_active then
            coopHUD.players[player_no].sprites.second_active.Scale = Vector(0.5,0.5)
            coopHUD.players[player_no].sprites.second_active.Scale = Vector(0.5,0.5)
            coopHUD.players[player_no].sprites.second_active:Render(Vector(anchor.X + 8 ,anchor.Y + 8 ), vector_zero, vector_zero)
        end
        if coopHUD.players[player_no].sprites.second_active_charge then -- Second item charge render -- UGLY - can turn on
            coopHUD.players[player_no].sprites.second_active_charge.Scale = Vector(0.5,0.5)
            coopHUD.players[player_no].sprites.second_active_charge:Render(Vector(anchor.X +2,anchor.Y +8), vector_zero, vector_zero)
        end
        if coopHUD.players[player_no].sprites.first_active then
            coopHUD.players[player_no].sprites.first_active:Render(Vector(anchor.X + 19,anchor.Y+16),VECTOR_ZERO,VECTOR_ZERO)
        end
        if coopHUD.players[player_no].sprites.first_active_charge then
            coopHUD.players[player_no].sprites.first_active_charge:Render(Vector(anchor.X + 37,anchor.Y+17), VECTOR_ZERO, VECTOR_ZERO)
        end
    else offset.X = offset.X + 12
    end
    ----Render hearts
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
    pos = Vector(anchor.X+offset.X,anchor.Y+12)
    for row=0,n-1,1 do
        for col=0,m-1,1 do
            if coopHUD.players[player_no].sprites.hearts[counter] then
                temp_pos = Vector(pos.X + (heart_space * col),pos.Y + (heart_space * row))
                coopHUD.players[player_no].sprites.hearts[counter]:Render(temp_pos,VECTOR_ZERO,VECTOR_ZERO)
            end
            counter = counter + 1
        end
    end
    -- Extra Lives Render
    local hearts_span
    if coopHUD.players[player_no].total_hearts >= 6 then
        hearts_span = 6
    else
        hearts_span = coopHUD.players[player_no].total_hearts % 6
    end
    pos = Vector(anchor.X+offset.X+(12*hearts_span),anchor.Y+4)
    if coopHUD.players[player_no].extra_lives ~= 'x0' then
        local f = Font()
        f:Load("font/pftempestasevencondensed.fnt")
        f:DrawString (coopHUD.players[player_no].extra_lives,pos.X,pos.Y,KColor(1,1,1,1),0,true)
    end
    ---- POCKETS RENDER
    local down_anchor = bottom_left_anchor
    ------third pocket
    scale = Vector(0.5,0.5)
    if coopHUD.players[player_no].sprites.third_pocket then
        coopHUD.players[player_no].sprites.third_pocket.Scale = Vector(0.5,0.5)
        coopHUD.players[player_no].sprites.third_pocket:Render(Vector(down_anchor.X+8,down_anchor.Y-42), vector_zero, vector_zero)
    end
    -- Second pocket
    if coopHUD.players[player_no].sprites.second_pocket then
        coopHUD.players[player_no].sprites.second_pocket.Scale = Vector(0.5,0.5)
        coopHUD.players[player_no].sprites.second_pocket:Render(Vector(down_anchor.X+8,down_anchor.Y-32), vector_zero, vector_zero)
    end
    -- Main pocket
    if coopHUD.players[player_no].sprites.first_pocket then
        coopHUD.players[player_no].sprites.first_pocket:Render(Vector(down_anchor.X+16,down_anchor.Y-16), VECTOR_ZERO, VECTOR_ZERO)
        ---- Main pocket charge
        if coopHUD.players[player_no].sprites.first_pocket:GetDefaultAnimation() == 'Idle' then -- checks if item is not pill of card
            if coopHUD.players[player_no].sprites.first_pocket_charge then
                coopHUD.players[player_no].sprites.first_pocket_charge:Render(Vector(down_anchor.X+34,down_anchor.Y-14), vector_zero, vector_zero)
            end
        end
        local f = Font()
        f:Load("font/pftempestasevencondensed.fnt")
        local color = KColor(1,1,1,1) -- TODO: sets according to player color
        if coopHUD.players[player_no].pocket_desc then
            f:DrawString (coopHUD.players[player_no].pocket_desc,down_anchor.X+44,down_anchor.Y-24,color,0,true) end
    end
    --- TRINKET RENDER

    --if coopHUD.players[player_no].sprites.first_trinket then
    --    if coopHUD.players[player_no].sprites.second_trinket then
    --        pos = Vector(trinket_anchor.X+16,trinket_anchor.Y-32)
    --    else
    --        pos = Vector(trinket_anchor.X+18,trinket_anchor.Y-20)
    --    end
    --    coopHUD.players[player_no].sprites.first_trinket:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
    --end
    --if coopHUD.players[player_no].sprites.second_trinket then
    --    pos = Vector(trinket_anchor.X+40,trinket_anchor.Y-16)
    --    coopHUD.players[player_no].sprites.second_trinket:Render(pos,vector_zero,vector_zero)
    --end
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
local players_no = 0
coopHUD.players = {}
counter = 0
function coopHUD.init()
    players_no = Game():GetNumPlayers()-1
    for i=0,players_no,1 do
        coopHUD.updatePlayer(i)
        print('Initiated ',i,'Player')
    end
end
coopHUD.init()
debug_player = Isaac.GetPlayer(0)
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
function coopHUD.test()
    forceUpdateActives = true
end
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM, coopHUD.test)
local forceUpdateActives = false
function coopHUD.updateActives(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    if coopHUD.players[player_no].first_active ~= temp_player:GetActiveItem(0)  then
        print('ssss')
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
    local temp_player = Isaac.GetPlayer(0)
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
local counter = 0
function  coopHUD.render()
    if onRender then
        -- Function is triggered by callback 2 times per second
        -- Check/update user item with longer span - checking with call back cause lag
        if counter == 6 then
            coopHUD.updateActives(0)
            coopHUD.updateTrinkets(0)
            coopHUD.updatePockets(0)
            coopHUD.updateHearts(0)
            counter = 0
        end
        counter = counter+1
        coopHUD.renderPlayer(0)
        coopHUD.renderItems()
    end

end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)
Game():GetHUD():SetVisible(false)
