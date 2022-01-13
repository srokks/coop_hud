function coopHUD.renderActive(player,pos,mirrored)
    local active_pivot = Vector(0,0) -- first item pivot
    local sec_pivot = Vector(0,0) -- second item pivot
    local charge_offset = Vector(0,0)
    local offset = Vector(0,0)
    local temp_pos = Vector(0,0)
    local final_offset = Vector(0,0)
    if mirrored then
        active_pivot = Vector(-32,16)
        sec_pivot = Vector(-24,8)
        offset = Vector(-32,32)
        charge_offset = Vector(-12,0)
    else
        active_pivot = Vector(16,16)
        sec_pivot = Vector(8,8)
        offset = Vector(32,32)
        charge_offset = Vector(32,0)
    end
    -- Second active render
    if player.sprites.second_active then
        temp_pos = Vector(pos.X + sec_pivot.X,pos.Y + sec_pivot.Y)
        player.sprites.second_active.Scale = Vector(0.5,0.5)
        player.sprites.second_active:Render(temp_pos)
    end
    -- Second active render
    if player.sprites.first_active then
        temp_pos = Vector(pos.X + charge_offset.X,pos.Y)
        charge_offset = coopHUD.renderChargeBar(player.sprites.first_active_charge,temp_pos,mirrored)
        temp_pos = Vector(pos.X + active_pivot.X ,pos.Y+active_pivot.Y)
        player.sprites.first_active:Render(temp_pos)
        final_offset = Vector(offset.X+charge_offset.X,offset.Y)
    end
    return final_offset
end
function coopHUD.renderChargeBar(sprites,pos,mirrored)
    local offset = Vector(0,0)
    local pivot = Vector(0,0)
    local final_offset = Vector(0,0)
    if mirrored then
        pivot = Vector(8,16)
        offset = Vector(-12,16)
    else
        pivot = Vector(8,16)
        offset = Vector(12,16)
    end
    local temp_pos = Vector(pos.X + pivot.X,pos.Y + pivot.Y) -- Sets pivot for anim frame
    if  sprites then
        if sprites.charge then
            sprites.charge:RenderLayer(0,temp_pos)  -- renders background
            final_offset = offset
        end
        if sprites.beth_charge then
            sprites.beth_charge:RenderLayer(1,temp_pos) -- renders bethany charge
        end
        if sprites.charge then
            sprites.charge:RenderLayer(1,temp_pos)
            sprites.charge:RenderLayer(2,temp_pos)
        end
        if sprites.overlay then
            sprites.overlay:Render(temp_pos)
        end
    end
    return final_offset
end
function coopHUD.renderHearts(player,pos,mirrored)
    local temp_pos
    local final_offset = Vector(0,0)
    if player.total_hearts >= 6 then -- Determines how many columns will be
        hearts_span = 6
    else
        hearts_span = player.total_hearts % 6
    end
    local n = 2 -- No. of rows in
    if player.max_health_cap > 12 then
        n = 3 -- No of rows in case of increased health cap - Maggy+Birthright
    end
    local m = math.floor(player.max_health_cap/n) -- No of columns in health grid
    if mirrored then
        temp_pos = Vector(pos.X-12*(hearts_span),pos.Y+8)
        final_offset = Vector(-12*(hearts_span)-6,8*n)
        if Game():GetLevel():GetCurses() == 8 then
            temp_pos = Vector(pos.X-12,pos.Y+8)
            final_offset = Vector(-16,16)
        end
    else
        temp_pos = Vector(pos.X+8,pos.Y+8)
        final_offset = Vector(12*(hearts_span)+4,8) -- sets returning offset
        if Game():GetLevel():GetCurses() == 8 then final_offset = Vector(16,16) end
    end
    local n = 2 -- No. of rows in
    if player.max_health_cap > 12 then
        n = 3 -- No of rows in case of increased health cap - Maggy+Birthright
    end
    local m = math.floor(player.max_health_cap/n) -- No of columns in health grid
    -- Sub character hearts render
    counter = 0
    if player.has_sub then -- Sub player heart render
        for row=0,n-1,1 do
            for col=0,m-1,1 do
                if player.sprites.sub_hearts[counter] then
                    player.sprites.sub_hearts[counter].Scale = Vector(1,1)
                    player.sprites.sub_hearts[counter].Color =Color(1, 1, 1, 0.5, 0, 0, 0)
                    heart_pos = Vector(temp_pos.X + 12 * col,temp_pos.Y+10)
                    player.sprites.sub_hearts[counter]:Render(heart_pos)
                end
                counter = counter + 1
            end
        end
    end
    -- Main character hearts render
    counter = 0
    local heart_space = Vector(12,9)  -- sets px space between hearts
    for row=0,n-1,1 do
        for col=0,m-1,1 do
            if player.sprites.hearts[counter] then
                local t_maggy_hearts = 1
                -- Changes max non dissapearing hearst if player  has_birthright
                if player.has_birthright then t_maggy_hearts = 2 end
                if player.type == PlayerType.PLAYER_MAGDALENA_B and counter > t_maggy_hearts
                        and player.heart_types[counter].heart_type ~= 'EmptyHeart' then
                    -- According to main ticker changes alpha color of sprite this way animate item
                    -- Probably not sufficient way but when I'll learn better animation I fix it
                    local sprite_alpha = coopHUD.counter/60
                    if sprite_alpha > 0.4 then
                        local col = Color(1,1,1,sprite_alpha)
                        player.sprites.hearts[counter].Color = col
                    end
                end
                heart_pos = Vector(temp_pos.X + 12*col,temp_pos.Y+10*row)
                player.sprites.hearts[counter]:Render(heart_pos)
            end
            counter = counter + 1
        end
    end
    return final_offset
end
function coopHUD.renderExtraLives(player,pos,mirrored)
    local temp_pos = Vector(0,0)
    local lives_pivot = Vector(0,0)
    local offset = Vector(0,0)
    local final_offset = Vector(0,0)
    if player.extra_lives ~= 0 then
        local f = Font()
        f:Load("font/pftempestasevencondensed.fnt")
        local text
        if player.has_guppy then
            temp_pos = 1
            text = string.format('x%d?',player.extra_lives)
        else
            text =  string.format('x%d',player.extra_lives)
        end
        if mirrored then -- mirrored
            offset = Vector(string.len(text)*-8,0)
            lives_pivot = Vector(string.len(text)*-8,4)
        else -- normal
            offset = Vector(string.len(text)*6,0)
            lives_pivot = Vector(2,4)
        end
        f:DrawString (text,pos.X+lives_pivot.X,pos.Y+lives_pivot.Y,KColor(1,1,1,1),0,true)
        final_offset = offset
    end
    return final_offset
end
function coopHUD.renderPockets(player,pos,mirrored)
    local temp_pos = Vector(0,0)
    local main_pocket_pivot = Vector(0,0)
    local charge_pivot = Vector(0,0)
    local sec_po_pivot = Vector(0,0)
    local trd_po_pivot = Vector(0,0)
    local desc_pivot = Vector(0,0)
    local offset = Vector(0,0)
    local final_offset = Vector(0,0)
    local f = Font()
    f:Load("font/pftempestasevencondensed.fnt")
    local color = KColor(1,1,1,1) -- TODO: sets according to player color
    if mirrored then
        main_pocket_pivot = Vector(-16,-16)
        charge_pivot = Vector(-16,-28)
        sec_po_pivot = Vector(-48,-18)
        trd_po_pivot = Vector(-60,-18)
        desc_pivot = Vector(-38,-16)
        offset = Vector(0,-32)
    else
        main_pocket_pivot = Vector(16,-16)
        charge_pivot = Vector(28,-28)
        sec_po_pivot = Vector(52,-18)
        trd_po_pivot = Vector(64,-18)
        desc_pivot = Vector(48,-16)
        offset = Vector(0,-32)
    end
    ------third pocket
    if player.sprites.third_pocket then
        temp_pos = Vector(pos.X+trd_po_pivot.X,pos.Y+trd_po_pivot.Y)
        player.sprites.third_pocket.Scale = Vector(0.5,0.5) -- sets scale
        player.sprites.third_pocket.Color = Color(1,1,1,0.5) -- sets sprite alpha
        player.sprites.third_pocket:Render(temp_pos)
    end
    -- Second pocket
    if player.sprites.second_pocket then
        temp_pos = Vector(pos.X+sec_po_pivot.X,pos.Y+sec_po_pivot.Y)
        player.sprites.second_pocket.Scale = Vector(0.5,0.5) -- sets scale
        player.sprites.second_pocket.Color = Color(1,1,1,0.5) -- sets sprite alpha
        player.sprites.second_pocket:Render(temp_pos)
    end
    -- Main pocket
    if player.sprites.first_pocket then
        local charge_offset = Vector(0,0)
        final_offset = offset
        -- Main pocket charge
        if player.sprites.first_pocket:GetDefaultAnimation() == 'Idle' then -- checks if item is not pill of card
            if player.sprites.first_pocket_charge.charge then
                temp_pos = Vector(pos.X+charge_pivot.X,pos.Y+charge_pivot.Y)
                charge_offset = coopHUD.renderChargeBar(player.sprites.first_pocket_charge,temp_pos,mirrored)
            end
        end
        if mirrored then main_pocket_pivot.X = main_pocket_pivot.X + charge_offset.X end
        temp_pos = Vector(pos.X+main_pocket_pivot.X,pos.Y+main_pocket_pivot.Y)
        player.sprites.first_pocket:Render(temp_pos)
        -- Description
        if player.pocket_desc then
            temp_pos = Vector(pos.X+desc_pivot.X,pos.Y+desc_pivot.Y)
            if  mirrored then temp_pos.X = temp_pos.X - string.len(player.pocket_desc)*6
            end
            local text = player.pocket_desc
            --if string.len(text) > 12 and mirrored then
            --    text = string.format("%.12s...",text) end
            f:DrawString (text,temp_pos.X,temp_pos.Y,color,0,true) end
    end
    return final_offset
end
function coopHUD.renderTrinkets(player,pos,mirrored)
    local temp_pos = Vector(0,0)
    local trinket_pivot = Vector(0,0)
    local sec_tr_pivot = Vector(0,0)
    local off = Vector(0,-24)
    if mirrored then
        trinket_pivot  = Vector(-12,-12)
        sec_tr_pivot = Vector(-32,-12)
    else
        trinket_pivot = Vector(12,-12)
        sec_tr_pivot = Vector(32,-12)
    end
    if player.sprites.first_trinket then
        if player.sprites.second_trinket then
            temp_pos = Vector(pos.X + sec_tr_pivot.X,pos.Y + sec_tr_pivot.Y)
            player.sprites.second_trinket.Scale = Vector(0.7,0.7)
            player.sprites.second_trinket:Render(temp_pos)
        end
        temp_pos = Vector(pos.X + trinket_pivot.X,pos.Y + trinket_pivot.Y)
        player.sprites.first_trinket.Scale = Vector(0.7,0.7)
        player.sprites.first_trinket:Render(temp_pos)
    end
    return off
end
function coopHUD.renderBethanyCharge(player,pos,mirrored)
    if player.bethany_charge ~= nil then
        local temp_pos = Vector(0,0)
        local spr_pivot = Vector(0,0)
        local text_pivot = Vector(0,0)
        local f = Font()
        local bethany_charge = string.format('x%d',player.bethany_charge)
        if mirrored then
            spr_pivot = Vector(-7,8)
            text_pivot = Vector(-10 + string.len(bethany_charge)*-6,-1)
        else
            spr_pivot = Vector(5,8)
            text_pivot = Vector(10,-2)
        end
        local beth_sprite = Sprite()
        if player.type == PlayerType.PLAYER_BETHANY then -- Sets sprite frame according to player type
            beth_sprite = coopHUD.getHeartSprite('BlueHeartFull','None')
        else
            beth_sprite = coopHUD.getHeartSprite('RedHeartFull','None')
        end
        beth_sprite.Scale = Vector(0.6,0.6)
        beth_sprite:Render(Vector(pos.X+spr_pivot.X,pos.Y+spr_pivot.Y))
        f:Load("font/luaminioutlined.fnt")
        f:DrawString (bethany_charge,pos.X+text_pivot.X,pos.Y+text_pivot.Y,KColor(1,1,1,1),0,true)
    end
end
function coopHUD.renderBagOfCrafting(player,pos,mirrored)
end
function coopHUD.renderPoopSpells(player,pos,mirrored)
    local main_offset = Vector(0,0)
    local pos_multi = 0
    local first_off = Vector(0,0)
    if mirrored then
        pos_multi = -10
        main_offset = Vector(-16,16)
        first_off = Vector(-16,16)
    else
        pos_multi = 10
        main_offset = Vector(16,16)
        first_off = Vector(16,16)
    end
    for i=0,PoopSpellType.SPELL_QUEUE_SIZE-1,1 do
        temp_pos = Vector(pos.X+main_offset.X+i*pos_multi,pos.Y+main_offset.Y)
        if i == 0 then temp_pos = Vector(pos.X+first_off.X,pos.Y+first_off.Y) end
        player.sprites.poops[i]:Render(temp_pos)
    end
end
function coopHUD.renderPlayerInfo(player,pos,mirrored)

end
function coopHUD.renderPlayer(player_no)
end
function coopHUD.renderItems()
    -- TODO: Planetarium chances render
    -- TODO: Angel/Devil room chances
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
coopHUD.counter = 60
function  coopHUD.render()
    onRender = true
    --if issomeonejoining == false then
    --    Game():GetHUD():SetVisible(false)
    --else
    --    onRender = false
    --    Game():GetHUD():SetVisible(true)
    --end
    if onRender  then
        -- Function is triggered by callback 2 times per second
        -- Check/update user item with longer span - checking with call back cause lag

        coopHUD.counter = coopHUD.counter-1
        if coopHUD.counter%15 == 0 then
            coopHUD.updateAnchors()
            for i=0,players_no,1 do
                coopHUD.updateActives(i)
                coopHUD.updateTrinkets(i)
                coopHUD.updatePockets(i)
                coopHUD.updateHearts(i)
                coopHUD.updateExtraLives(i)
                coopHUD.updateBethanyCharge(i)
                coopHUD.updateCollectible(i)
                coopHUD.updatePoopMana(i)
            end
        end
        if  coopHUD.counter == 0 then
            coopHUD.counter = 60
        end
        for i=0,players_no,1 do
            coopHUD.renderPlayer(i)
        end
        coopHUD.renderItems()
    end
end

function coopHUD.renderPlayer2(player_no)
    local pos = Vector(0,0)
    local mirrored = false
    -- <Locals inits>
    local active_off = Vector(0,0)
    local hearts_off = Vector(0,0)
    local exl_liv_off = Vector(0,0)
    local down_pos = Vector(0,Isaac.GetScreenHeight())
    local pocket_off = Vector(0,0)
    local trinket_off = Vector(0,0)
    local extra_charge_off = Vector(0,0)
    -- <First  top line render> --
    active_off = coopHUD.renderActive(coopHUD.players[player_no],pos,mirrored)
    hearts_off = coopHUD.renderHearts(coopHUD.players[player_no],Vector(pos.X+active_off.X,pos.Y),mirrored)
    exl_liv_off = coopHUD.renderExtraLives(coopHUD.players[player_no],Vector(pos.X+active_off.X+hearts_off.X,pos.Y),mirrored)
    -- </First  top line render> --
    -- <Second  top line render> --
    --TODO: renderPlayerInfo: render head of current character and name <P1 .. P4>
     coopHUD.renderBethanyCharge(coopHUD.players[player_no],Vector(pos.X,pos.Y + math.max(active_off.Y,hearts_off.Y)),mirrored)
    -- </Second  top line render> --
    -- <Down  line>
    pocket_off = coopHUD.renderPockets(coopHUD.players[player_no],down_pos,mirrored)
    trinket_off = coopHUD.renderTrinkets(coopHUD.players[player_no],Vector(down_pos.X,down_pos.Y+pocket_off.Y),mirrored)
    --coopHUD.renderPockets(coopHUD.players[player_no],Vector(down_pos.X,down_pos.Y+pocket_off.Y+trinket_off.Y),mirrored) -- DEBUG: test offsets
    --- MIRRORED
    local pos = Vector(Isaac.GetScreenWidth(),0)
    local mirrored = true
    -- <Locals inits>
    local active_off = Vector(0,0)
    local hearts_off = Vector(0,0)
    local exl_liv_off = Vector(0,0)
    local down_pos = Vector(Isaac.GetScreenWidth(),Isaac.GetScreenHeight())
    local pocket_off = Vector(0,0)
    local trinket_off = Vector(0,0)
    -- <First  top line render> --
    active_off = coopHUD.renderActive(coopHUD.players[player_no],pos,mirrored)
    hearts_off = coopHUD.renderHearts(coopHUD.players[player_no],Vector(pos.X+active_off.X,pos.Y),mirrored)
    exl_liv_off = coopHUD.renderExtraLives(coopHUD.players[player_no],Vector(pos.X+active_off.X+hearts_off.X,pos.Y),mirrored)
    -- </First  top line render> --
    -- <Second  top line render> --
    --TODO: renderPlayerInfo: render head of current character and name <P1 .. P4>
     coopHUD.renderBethanyCharge(coopHUD.players[player_no],Vector(pos.X,pos.Y + math.max(active_off.Y,hearts_off.Y)),mirrored)
    -- </Second  top line render> --
    -- <Down  line>
    pocket_off = coopHUD.renderPockets(coopHUD.players[player_no],down_pos,mirrored)
    trinket_off = coopHUD.renderTrinkets(coopHUD.players[player_no],Vector(down_pos.X,down_pos.Y+pocket_off.Y),mirrored)
    --coopHUD.renderPockets(coopHUD.players[player_no],Vector(down_pos.X,down_pos.Y+pocket_off.Y+trinket_off.Y),mirrored) -- DEBUG: test offsets
end