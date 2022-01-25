function coopHUD.renderActive(player,pos,mirrored,scale,down_anchor)
    local active_pivot = Vector(0,0) -- first item pivot
    local sec_pivot = Vector(0,0) -- second item pivot
    local charge_offset = Vector(0,0)
    local offset = Vector(0,0)
    local temp_pos = Vector(0,0)
    local final_offset = Vector(0,0)
    -- Scale set
    local sprite_scale = scale
    if sprite_scale == nil then sprite_scale = Vector(1,1) end
    --
    if mirrored then
        active_pivot.X = -28*sprite_scale.X
        sec_pivot.X = -16*sprite_scale.X
        offset.X = -32*sprite_scale.X
        charge_offset.X = -12*sprite_scale.X
    else
        active_pivot.X = 16*sprite_scale.X
        sec_pivot.X = 8
        offset.X = 32*sprite_scale.X
        charge_offset.X = 32*sprite_scale.X
    end
    --
    if down_anchor then
        active_pivot.Y = -16
        sec_pivot.Y = -24
        offset.Y = -32*sprite_scale.Y
        charge_offset.Y = -32
    else
        active_pivot.Y = 16
        sec_pivot.Y = 8
        offset.Y = 32*sprite_scale.Y
        charge_offset.Y = 0
    end
    -- Second active render
    if player.sprites.second_active then
        temp_pos = Vector(pos.X + sec_pivot.X,pos.Y + sec_pivot.Y)
        player.sprites.second_active.Scale = Vector(0.5,0.5)
        player.sprites.second_active:Render(temp_pos)
    end
    -- Second active render
    if player.sprites.first_active then
        temp_pos = Vector(pos.X + charge_offset.X,pos.Y+charge_offset.Y)
        charge_offset = coopHUD.renderChargeBar(player.sprites.first_active_charge,temp_pos,mirrored,sprite_scale)
        temp_pos = Vector(pos.X + active_pivot.X,pos.Y+active_pivot.Y)
        player.sprites.first_active.Scale = sprite_scale
        player.sprites.first_active:Render(temp_pos)
        final_offset = Vector(offset.X+charge_offset.X,offset.Y)
    end
    return final_offset
end
function coopHUD.renderChargeBar(sprites,pos,mirrored,scale)
    local offset = Vector(0,0)
    local pivot = Vector(0,0)
    local final_offset = Vector(0,0)
    local sprite_scale = scale
    if sprite_scale == nil then sprite_scale = Vector(1,1) end
    if mirrored then
        pivot = Vector(8*sprite_scale.X,16)
        offset = Vector(-12*sprite_scale.X,16)
    else
        pivot = Vector(8*sprite_scale.X,16)
        offset = Vector(12*sprite_scale.X,16)
    end
    local temp_pos = Vector(pos.X + pivot.X,pos.Y + pivot.Y) -- Sets pivot for anim frame
    if  sprites then
        if sprites.charge then
            sprites.charge.Scale = sprite_scale
            sprites.charge:RenderLayer(0,temp_pos)  -- renders background
        end
        if sprites.beth_charge then
            sprites.beth_charge.Scale = sprite_scale
            sprites.beth_charge:RenderLayer(1,temp_pos) -- renders bethany charge
        end
        if sprites.charge then
            sprites.charge:RenderLayer(1,temp_pos)
            sprites.charge:RenderLayer(2,temp_pos)
        end
        if sprites.overlay then
            sprites.overlay.Scale = sprite_scale
            sprites.overlay:Render(temp_pos)
        end
        final_offset = offset
    end
    return final_offset
end
function coopHUD.renderHearts(player,pos,mirrored,scale,down_anchor)
    local temp_pos = Vector(0,0)
    local final_offset = Vector(0,0)
    --
    local sprite_scale = scale
    if sprite_scale == nil then sprite_scale = Vector(1,1) end -- sets def sprite_scale
    --
    local heart_space = Vector(12*sprite_scale.X,10*sprite_scale.Y)  -- sets px space between hearts
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
        temp_pos.X = pos.X - heart_space.X * hearts_span -- sets anchor pos for all hearts
        final_offset.X = (-12*(hearts_span)*sprite_scale.X)-4 -- sets returning offset
        if Game():GetLevel():GetCurses() == 8 then -- checks Curse of unknown
            temp_pos = Vector(pos.X-12,pos.Y+8)
            final_offset = Vector(-16,16)
        end
    else
        temp_pos.X = pos.X+8
        final_offset.X = (12*(hearts_span)*sprite_scale.X)+4 -- sets returning offset
        if Game():GetLevel():GetCurses() == 8 then final_offset = Vector(16,16) end -- checks Curse of unknown
    end
    --
    if down_anchor then
        temp_pos.Y = pos.Y + -8 * math.ceil(player.total_hearts/6)
        final_offset.Y = (-8 * math.ceil(player.total_hearts/6))-6
    else
        temp_pos.Y = pos.Y + 8
        final_offset.Y = (8 * math.ceil(player.total_hearts/6)) + 6
    end
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
    for row=0,n-1,1 do
        for col=0,m-1,1 do
            if player.sprites.hearts[counter] then
                local t_maggy_hearts = 1
                -- Changes max non disappearing hearst if player  has_birthright
                if player.has_birthright then t_maggy_hearts = 2 end
                if player.type == PlayerType.PLAYER_MAGDALENA_B and counter > t_maggy_hearts
                        and player.heart_types[counter].heart_type ~= 'EmptyHeart' then
                    -- According to main ticker changes alpha color of sprite this way animate item
                    -- Probably not sufficient way but when I'll learn better animation I'll fix it
                    local sprite_alpha = coopHUD.TICKER/60
                    if sprite_alpha > 0.4 then
                        local col = Color(1,1,1,sprite_alpha)
                        player.sprites.hearts[counter].Color = col
                    end
                end
                heart_pos = Vector(temp_pos.X + heart_space.X*col,temp_pos.Y+heart_space.Y*row)
                player.sprites.hearts[counter].Scale = sprite_scale
                player.sprites.hearts[counter]:Render(heart_pos)
            end
            counter = counter + 1
        end
    end
    return final_offset
end
function coopHUD.renderExtraLives(player,pos,mirrored,scale,down_anchor)
    local final_offset = Vector(0,0)
    
    if player.extra_lives ~= 0 then
        local temp_pos = Vector(0,0)
        local lives_pivot = Vector(0,0)
        local offset = Vector(0,0)
        --
        local sprite_scale = scale
        if sprite_scale == nil then sprite_scale = Vector(1,1) end -- sets def sprite_scale
        --
        local f = Font()
        f:Load("font/pftempestasevencondensed.fnt")
        local text
        --
        if player.has_guppy then
            temp_pos = 1
            text = string.format('x%d?',player.extra_lives)
        else
            text =  string.format('x%d',player.extra_lives)
        end
        if mirrored then -- mirrored
            offset.X = string.len(text)*-8
            lives_pivot.X = string.len(text)*(-8*sprite_scale.X)
        else -- normal
            offset.X = string.len(text)*6
            lives_pivot.X = 2
        end
        if down_anchor then
            offset.Y =  -16
            lives_pivot.Y = -16
        else
            offset.Y = 12
            lives_pivot.Y = 2
        end
        f:DrawStringScaled(text,pos.X+lives_pivot.X,pos.Y+lives_pivot.Y,sprite_scale.X,sprite_scale.Y,KColor(1,1,1,1),0,true)
        final_offset = offset
    end
    return final_offset
end
function coopHUD.renderPockets(player,pos,mirrored,scale,down_anchor)
    local final_offset = Vector(0,0)
    -- Main pocket
    if player.sprites.first_pocket then
        local temp_pos = Vector(0,0) -- temp pos for sprites
        local main_pocket_pivot = Vector(0,0)
        local charge_pivot = Vector(0,0)
        local charge_offset = Vector(0,0)
        local desc_pivot = Vector(0,0)
        local sec_po_pivot = Vector(0,0)
        local trd_po_pivot = Vector(0,0)
        local offset = Vector(0,0)
        local f = Font()
        f:Load("font/pftempestasevencondensed.fnt")
        local color = KColor(1,1,1,1) -- TODO: sets according to player color
        --
        local sprite_scale = scale
        if sprite_scale == nil then sprite_scale = Vector(1,1) end -- sets def sprite_scale
        --
        if mirrored then
            main_pocket_pivot.X = -16 * sprite_scale.X
            charge_pivot.X = - 12 * sprite_scale.X
            sec_po_pivot.X = -32 * sprite_scale.X
            trd_po_pivot.X = -48 * sprite_scale.X
        else
            main_pocket_pivot.X = 16 * sprite_scale.X
            charge_pivot.X = 28 * sprite_scale.X
            desc_pivot.X = 32 * sprite_scale.X
            sec_po_pivot.X = 32 * sprite_scale.X
            trd_po_pivot.X = 48 * sprite_scale.X
        end
        --
        if down_anchor then -- defines if anchor for rendering is in in left down corner
            main_pocket_pivot.Y = -16
            charge_pivot.Y = -28
            desc_pivot.Y = -16
            sec_po_pivot.Y = -24
            trd_po_pivot.Y = -24
        else -- or in right
            main_pocket_pivot.Y = 16
            charge_pivot.Y = 0
            desc_pivot.Y = 16
            sec_po_pivot.Y = 12
            trd_po_pivot.Y = 12
        end
        final_offset = offset
        -- Main pocket charge
        if player.sprites.first_pocket:GetDefaultAnimation() == 'Idle' then -- checks if item is not pill of card
            if player.sprites.first_pocket_charge then
                temp_pos = Vector(pos.X+charge_pivot.X,pos.Y+charge_pivot.Y)
                charge_offset = coopHUD.renderChargeBar(player.sprites.first_pocket_charge,temp_pos,mirrored,scale)
            end
        end
        temp_pos = Vector(pos.X+main_pocket_pivot.X,pos.Y+main_pocket_pivot.Y)
        if mirrored then temp_pos.X = temp_pos.X + charge_offset.X end
        player.sprites.first_pocket.Scale = sprite_scale
        player.sprites.first_pocket:Render(temp_pos)
        -- Description
        if player.pocket_desc then
            temp_pos = Vector(pos.X+charge_offset.X+desc_pivot.X,pos.Y+desc_pivot.Y)
            if  mirrored then temp_pos.X = temp_pos.X - (28*sprite_scale.X) - string.len(player.pocket_desc)*(5*sprite_scale.X) end
            local text = player.pocket_desc
            f:DrawStringScaled (text,temp_pos.X,temp_pos.Y,sprite_scale.X,sprite_scale.Y,color,0,true)
        end
        ------third pocket
        if player.sprites.third_pocket then
            temp_pos = Vector(pos.X+trd_po_pivot.X + charge_offset.X,pos.Y+trd_po_pivot.Y)
            player.sprites.third_pocket.Scale = Vector(0.7*sprite_scale.X,0.7 * sprite_scale.Y) -- sets scale
            player.sprites.third_pocket.Color = Color(1,1,1,0.5) -- sets sprite alpha
            player.sprites.third_pocket:Render(temp_pos)
        end
        -- Second pocket
        if player.sprites.second_pocket then
            temp_pos = Vector(pos.X+sec_po_pivot.X+charge_offset.X,pos.Y+sec_po_pivot.Y)
            player.sprites.second_pocket.Scale = Vector(0.7*sprite_scale.X,0.7 * sprite_scale.Y)  -- sets scale
            player.sprites.second_pocket.Color = Color(1,1,1,0.5) -- sets sprite alpha
            player.sprites.second_pocket:Render(temp_pos)
        end
    end
    return final_offset
end
function coopHUD.renderTrinkets(player,pos,mirrored,scale,down_anchor)
    local off = Vector(0,0)
    if player.sprites.first_trinket then
        local temp_pos = Vector(0,0)
        local trinket_pivot = Vector(0,0)
        local sec_tr_pivot = Vector(0,0)
        --
        local sprite_scale = scale
        if sprite_scale == nil then sprite_scale = Vector(1,1) end -- sets def sprite_scale
        --
        if mirrored then
            trinket_pivot.X = -13 * sprite_scale.X
            sec_tr_pivot.X = -12 * sprite_scale.X
            off.X = -24 * sprite_scale.X
        else
            trinket_pivot.X = 12 * sprite_scale.X
            sec_tr_pivot.X = 12 * sprite_scale.X
            off.X = 24 * sprite_scale.X
        end
        if down_anchor then
            trinket_pivot.Y = -16 * sprite_scale.X
            sec_tr_pivot.Y = -32 * sprite_scale.X
        else
            trinket_pivot.Y = 8 * sprite_scale.X
            sec_tr_pivot.Y = 28 * sprite_scale.X
        end
        if player.sprites.second_trinket then
            temp_pos = Vector(pos.X + sec_tr_pivot.X,pos.Y + sec_tr_pivot.Y)
            player.sprites.second_trinket.Scale = Vector(0.7*sprite_scale.X,0.7*sprite_scale.Y)
            player.sprites.second_trinket:Render(temp_pos)
        end
        temp_pos = Vector(pos.X + trinket_pivot.X,pos.Y + trinket_pivot.Y)
        player.sprites.first_trinket.Scale = Vector(0.7*sprite_scale.X,0.7*sprite_scale.Y)
        player.sprites.first_trinket:Render(temp_pos)
    end
    return off
end
function coopHUD.renderBethanyCharge(player,pos,mirrored,scale,down_anchor)
    local final_offset = Vector(0,0)
    if player.bethany_charge ~= nil then
        local spr_pivot = Vector(0,0)
        local text_pivot = Vector(0,0)
        local f = Font()
        local bethany_charge = string.format('x%d',player.bethany_charge)
        -- Scale set
        local sprite_scale = scale
        if sprite_scale == nil then sprite_scale = Vector(1,1) end
        --
        if mirrored then
            spr_pivot.X = -8
            text_pivot.X = -12 + string.len(bethany_charge)*-6
        else
            spr_pivot.X = 4
            text_pivot.X = 10
        end
        if down_anchor then
            spr_pivot.Y = 0
            text_pivot.Y = -10
            final_offset.Y = -8
        else
            spr_pivot.Y = 8
            text_pivot.Y = -2
            final_offset.Y = 8
        end
        local beth_sprite = Sprite()
        if player.type == PlayerType.PLAYER_BETHANY then -- Sets sprite frame according to player type
            beth_sprite = coopHUD.getHeartSprite('BlueHeartFull','None')
        else
            beth_sprite = coopHUD.getHeartSprite('RedHeartFull','None')
        end
        beth_sprite.Scale = Vector(0.7,0.7)
        beth_sprite:Render(Vector(pos.X+spr_pivot.X,pos.Y+spr_pivot.Y))
        f:Load("font/luaminioutlined.fnt")
        f:DrawString (bethany_charge,pos.X+text_pivot.X,pos.Y+text_pivot.Y,KColor(1,1,1,1),0,true)
    end
    return final_offset
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
    if  player.sprites.poops~= nil then
        for i=0,PoopSpellType.SPELL_QUEUE_SIZE-1,1 do
            temp_pos = Vector(pos.X+main_offset.X+i*pos_multi,pos.Y+main_offset.Y)
            if i == 0 then temp_pos = Vector(pos.X+first_off.X,pos.Y+first_off.Y) end
            player.sprites.poops[i]:Render(temp_pos)
        end
    end

end
function coopHUD.renderPlayerInfo(player,pos,mirrored)

end
function coopHUD.renderPlayer(player_no)
    --
    local anchor_top = coopHUD.anchors[coopHUD.players_config[player_no].anchor_top]
    local anchor_bot = coopHUD.anchors[coopHUD.players_config[player_no].anchor_bot]
    local mirrored = coopHUD.players_config[player_no].mirrored
    -- <Locals inits>
    local active_off = Vector(0,0)
    local hearts_off = Vector(0,0)
    local exl_liv_off = Vector(0,0)
    local pocket_off = Vector(0,0)
    local trinket_off = Vector(0,0)
    local extra_charge_off = Vector(0,0)
    -- <First  top line render> --
    active_off = coopHUD.renderActive(coopHUD.players[player_no], anchor_top,mirrored,false)
    hearts_off = coopHUD.renderHearts(coopHUD.players[player_no],Vector(anchor_top.X+active_off.X, anchor_top.Y),mirrored,false)
    exl_liv_off = coopHUD.renderExtraLives(coopHUD.players[player_no],Vector(anchor_top.X+active_off.X+hearts_off.X, anchor_top.Y),mirrored,false)
    -- </First  top line render> --
    -- <Second  top line render> --
    --TODO: renderPlayerInfo: render head of current character and name <P1 .. P4>
    extra_charge_off = coopHUD.renderBethanyCharge(coopHUD.players[player_no],Vector(anchor_top.X, anchor_top.Y + math.max(active_off.Y,hearts_off.Y)),mirrored)
    --coopHUD.renderPoopSpells(coopHUD.players[player_no],Vector(pos.X,pos.Y + math.max(active_off.Y,hearts_off.Y)),mirrored)
    -- </Second  top line render> --
    -- <Down  line>
    pocket_off = coopHUD.renderPockets(coopHUD.players[player_no], anchor_bot,mirrored,nil,true)
    trinket_off = coopHUD.renderTrinkets(coopHUD.players[player_no],Vector(anchor_bot.X, anchor_bot.Y+pocket_off.Y),mirrored,true)
    --coopHUD.renderPockets(coopHUD.players[player_no],Vector(down_pos.X,down_pos.Y+pocket_off.Y+trinket_off.Y),mirrored) -- DEBUG: test offsets
end
function coopHUD.renderPlayerSmall(player_no)
    local anchor = coopHUD.anchors[coopHUD.players_config.small[player_no].anchor]
    local mirrored = coopHUD.players_config.small[player_no].mirrored
    local scale = coopHUD.players_config.small[player_no].scale
    local down_anchor = coopHUD.players_config.small[player_no].down_anchor
    --
    --player_no = 0 --DEBUG: all anchor pos test
    -- <Locals inits>
    local active_off = Vector(0,0)
    local hearts_off = Vector(0,0)
    local exl_liv_off = Vector(0,0)
    local pocket_off = Vector(0,0)
    local trinket_off = Vector(0,0)
    local extra_charge_off = Vector(0,0)
    -- <First  top line render> --
    active_off = coopHUD.renderActive(coopHUD.players[player_no], anchor,
                                      mirrored,scale,down_anchor)
    hearts_off = coopHUD.renderHearts(coopHUD.players[player_no],Vector(anchor.X+active_off.X, anchor.Y),
                                      mirrored,scale,down_anchor)
    exl_liv_off = coopHUD.renderExtraLives(coopHUD.players[player_no],
                                           Vector(anchor.X+active_off.X+hearts_off.X, anchor.Y),
                                           mirrored,scale,down_anchor)
    extra_charge_off = coopHUD.renderBethanyCharge(coopHUD.players[player_no],
                                                   Vector(anchor.X+active_off.X+hearts_off.X, anchor.Y+exl_liv_off.Y),
                                                   mirrored,scale,down_anchor)
    -- <Second  top line render> --
    local first_line_offset = Vector(0,0)
    if down_anchor then
        first_line_offset.Y = math.min(active_off.Y,hearts_off.Y,(exl_liv_off.Y+extra_charge_off.Y))
    else
        first_line_offset.Y = math.max(active_off.Y,hearts_off.Y,exl_liv_off.Y+extra_charge_off.Y)
    end
    trinket_off = coopHUD.renderTrinkets(coopHUD.players[player_no],
                                         Vector(anchor.X,anchor.Y+first_line_offset.Y),
                                         mirrored,scale,down_anchor)
    pockets_off = coopHUD.renderPockets(coopHUD.players[player_no],
                                        Vector(anchor.X+trinket_off.X,anchor.Y+first_line_offset.Y),
                                        mirrored,scale,down_anchor)
    -- </Second  top line render> --
end
function coopHUD.renderItems()
    -- TODO: Planetarium chances render
    -- TODO: Angel/Devil room chances
    -- TODO: GigaBomb integration
    -- TODO: T.??? PoopSpell integration
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
coopHUD.onRender = true
coopHUD.is_joining = false
function  coopHUD.render()
    --if coopHUD.players_config.players_no > 2 then onRender = false end -- prevents to render if more than 2 players
    if coopHUD.TICKER  == 60 then coopHUD.TICKER = 0 end
    coopHUD.TICKER = coopHUD.TICKER + 1
    if coopHUD.onRender then
         for i=0,coopHUD.players_config.players_no,1 do
            --coopHUD.renderPlayer(i)
        end
        for i = 0,3,1 do
            coopHUD.renderPlayerSmall(i)
        end
        
        
        --DEBUG: tests of all anchors
        --print(coopHUD.renderHearts(coopHUD.players[0],coopHUD.anchors.top_left,false,scl,false),
        --coopHUD.renderHearts(coopHUD.players[0],coopHUD.anchors.bot_left,false,scl,true),
        --coopHUD.renderHearts(coopHUD.players[0],coopHUD.anchors.top_right,true,scl,false),
        --coopHUD.renderHearts(coopHUD.players[0],coopHUD.anchors.bot_right,true,scl,true))
        coopHUD.renderItems()
    end
end
function coopHUD.is_joining()
    for i=0,coopHUD.players_config.players_no+1,1 do
        if Input.IsActionTriggered(ButtonAction.ACTION_JOINMULTIPLAYER, i) then
            coopHUD.is_joining = true
            coopHUD.onRender=false
            Game():GetHUD():SetVisible(true)
        end
        if Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, i) and coopHUD.is_joining then
            coopHUD.is_joining =false
            coopHUD.onRender=true
            Game():GetHUD():SetVisible(false)
        end
    end
end
function coopHUD.init_player()
    if coopHUD.is_joining then
        coopHUD.players_config.players_no = Game():GetNumPlayers()
        coopHUD.init()
        coopHUD.onRender=true
        Game():GetHUD():SetVisible(false)
    end
end
function coopHUD.on_start(_,cont)
    -- init tables
    coopHUD.init()
    print('CoopHUD loaded')
    if  Game():GetHUD():IsVisible() then Game():GetHUD():SetVisible(false) end
    if cont then -- game is continuing
        -- read from save`
    end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)
coopHUD:AddCallback(ModCallbacks.MC_INPUT_ACTION, coopHUD.is_joining)
coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, coopHUD.init_player)
coopHUD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, coopHUD.on_start)
