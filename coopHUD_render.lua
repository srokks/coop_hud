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
    -- Bethany charge render
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