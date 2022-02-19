--- Renders active items from  player table
---@param player
---@param pos Vector(x,y)
---@param mirrored boolean
---@param scale Vector(x,y)
---@param down_anchor boolean
---@return Vector(x,y)
function coopHUD.renderActive(player,pos,mirrored,scale,down_anchor)
    local active_pivot = Vector(0,0) -- first item pivot
    local sec_pivot = Vector(0,0) -- second item pivot
    local charge_offset = Vector(0,0)
    local offset = Vector(0,0)
    local temp_pos = Vector(0,0)
    local final_offset = Vector(0,0)
    -- Scale set
    local sprite_scale = scale
    if scale == nil then sprite_scale = Vector(1,1) end
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
        if player.is_twin or player.has_twin then
            -- Jacob/Essau sprite dims logic
            local color = Color(1,1,1,1)
            -- Triggers when drop button pressed
            if Input.IsActionPressed(ButtonAction.ACTION_DROP,player.controller_index) then
                color = Color(0.3,0.3,0.3,1)
                color:SetColorize(0,0,0,0)
            else
                color = Color(1,1,1,1)
                color:SetColorize(0,0,0,0)
            end
        end
        if player.has_twin then
            -- Sets first active color when triggered
            -- main player
            player.sprites.second_active.Color = color
            -- twin
            if player.twin.sprites.second_active then
                player.twin.sprites.second_active.Color = color
            end
        end
        temp_pos = Vector(pos.X + sec_pivot.X,pos.Y + sec_pivot.Y)
        player.sprites.second_active.Scale = Vector(0.5,0.5)
        player.sprites.second_active:Render(temp_pos)
    end
    -- Second active render
    if player.sprites.first_active then
        if player.has_twin then
            -- Jacob/Essau sprite dims logic
            local color = Color(1,1,1,1)
            -- Triggers when drop button pressed
            if Input.IsActionPressed(ButtonAction.ACTION_DROP,player.controller_index) then
                color = Color(0.3,0.3,0.3,1) -- Dims sprite color
                color:SetColorize(0,0,0,0)
            else
                color = Color(1,1,1,1) -- Restore normal color
                color:SetColorize(0,0,0,0)
            end
            -- Sets sprite  color when triggered
            player.sprites.first_active.Color = color
            if player.twin.sprites.first_active then
                player.twin.sprites.first_active.Color = color
            end
        end
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
                    --TODO: animate pulsing hearts
                    local sprite_alpha = 1
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
            offset.Y = 24
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
        local color = Color(0.3,0.3,0.3,1) -- dims by default
        local font_color = KColor(1,1,1,1)
        -- Jacob/Essau sprite dims logic
        if player.is_twin or player.has_twin then
            -- Triggers when drop button pressed
            if Input.IsActionPressed(ButtonAction.ACTION_DROP,player.controller_index) then
                color = Color(1,1,1,1)  -- normalize sprite on button
                color:SetColorize(0,0,0,0)
                font_color = KColor(1,1,1,1)
            else
                color = Color(0.3,0.3,0.3,1) -- return to dim state
                color:SetColorize(0,0,0,0)
                font_color = KColor(0.3,0.3,0.3,1) -- return to dim state
            end
        end
        if player.has_twin then
            -- Sets first active color when triggered
            -- main player
            player.sprites.first_pocket.Color = color
            if player.twin.sprites.first_pocket then
                player.twin.sprites.first_pocket.Color = color
            end
            --
        end
        player.sprites.first_pocket:Render(temp_pos)
        -- Description
        if player.pocket_desc then
            local text = player.pocket_desc.name
            if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.controller_index) and
                    player.pocket_desc.desc then
                text = player.pocket_desc.desc
            end
            temp_pos = Vector(pos.X+charge_offset.X+desc_pivot.X,pos.Y+desc_pivot.Y)
            if  mirrored then temp_pos.X = temp_pos.X - (28*sprite_scale.X) - string.len(text)*(5*sprite_scale.X) end
            f:DrawStringScaled (text,temp_pos.X,temp_pos.Y,sprite_scale.X,sprite_scale.Y,font_color,0,true)
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
            trinket_pivot.Y = -16 * sprite_scale.Y
            sec_tr_pivot.Y = -48 * sprite_scale.Y
            off.Y = -32 * sprite_scale.Y
        else
            trinket_pivot.Y = 16  * sprite_scale.Y
            sec_tr_pivot.Y = 40 * sprite_scale.Y
            off.Y = 24 * sprite_scale.Y
        end
        if player.sprites.second_trinket then
            temp_pos = Vector(pos.X + sec_tr_pivot.X,pos.Y + sec_tr_pivot.Y)
            player.sprites.second_trinket.Scale = Vector(1*sprite_scale.X,1*sprite_scale.Y)
            player.sprites.second_trinket:Render(temp_pos)
            off.Y = off.Y * 2
        end
        temp_pos = Vector(pos.X + trinket_pivot.X,pos.Y + trinket_pivot.Y)
        player.sprites.first_trinket.Scale = Vector(1*sprite_scale.X,1*sprite_scale.Y)
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
            spr_pivot.Y = -4
            text_pivot.Y = -14
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
function coopHUD.renderPlayerInfo(player,pos,mirrored,scale,down_anchor)
    local final_offset = Vector(0,0)
    if player.sprites.player_head ~= nil and coopHUD.options.render_player_info then
        local head_pivot = Vector(0,0)
        local name_pivot = Vector(0,0)
        local offset = Vector(0,0)
        local sprite_scale = scale
        if sprite_scale == nil then sprite_scale = Vector(1,1) end
        if mirrored then
            head_pivot.X = head_pivot.X - 16 * sprite_scale.X
            name_pivot.X = name_pivot.X - 20 * sprite_scale.X
            offset.X = -22 * sprite_scale.X
        else
            head_pivot.X = head_pivot.X + 16 * sprite_scale.X
            name_pivot.X = name_pivot.X + 12 * sprite_scale.X
            offset.X = 24 * sprite_scale.X
        end
        if down_anchor then
            head_pivot.Y = head_pivot.Y - 20 * sprite_scale.Y
            name_pivot.Y = name_pivot.Y - 16 * sprite_scale.Y
            offset.Y = -32 * sprite_scale.Y
        else
            head_pivot.Y = head_pivot.Y + 16 * sprite_scale.Y
            name_pivot.Y = name_pivot.Y + 20 * sprite_scale.Y
            offset.Y = 32 * sprite_scale.Y
        end
        player.sprites.player_head.Scale = sprite_scale
        player.sprites.player_head:Render(Vector(pos.X+head_pivot.X,pos.Y+head_pivot.Y))
        local f = Font()
        f:Load("font/luaminioutlined.fnt")
        f:DrawStringScaled(player.name,
                           pos.X+name_pivot.X,pos.Y+name_pivot.Y,
                           sprite_scale.X,sprite_scale.Y,
                           KColor(1,1,1,1),0,true)
        final_offset = offset
    end
    
    return final_offset
end
function coopHUD.renderPlayer(player_no)
    --
    local essau_no = coopHUD.essau_no
    local anchor_top = coopHUD.anchors[coopHUD.players_config[player_no].anchor_top]
    local anchor_bot = coopHUD.anchors[coopHUD.players_config[player_no].anchor_bot]
    local mirrored = coopHUD.players_config[player_no].mirrored
    -- <Locals inits>
    local info_off = Vector(0, 0)
    local active_off = Vector(0,0)
    local hearts_off = Vector(0,0)
    local exl_liv_off = Vector(0,0)
    local pocket_off = Vector(0,0)
    local trinket_off = Vector(0,0)
    local extra_charge_off = Vector(0,0)
    -- <First  top line render> --
    info_off = coopHUD.renderPlayerInfo(coopHUD.players[player_no],
                                        anchor_top, mirrored, Vector(0.9,0.9), false)
    active_off = coopHUD.renderActive(coopHUD.players[player_no],
                                      Vector(anchor_top.X+info_off.X,anchor_top.Y),
                                      mirrored,nil,false)
    hearts_off = coopHUD.renderHearts(coopHUD.players[player_no],
                                      Vector(anchor_top.X+info_off.X+active_off.X, anchor_top.Y),
                                      mirrored,nil,false)
    exl_liv_off = coopHUD.renderExtraLives(coopHUD.players[player_no],
                                           Vector(anchor_top.X+info_off.X+active_off.X+hearts_off.X, anchor_top.Y),
                                           mirrored,nil,false)
    -- </First  top line render> --
    -- <Second  top line render> --
    extra_charge_off = coopHUD.renderBethanyCharge(coopHUD.players[player_no],
                                                   Vector(anchor_top.X, anchor_top.Y +
                                                           math.max(active_off.Y,hearts_off.Y,info_off.Y)),
                                                   mirrored,nil,false)
    --coopHUD.renderPoopSpells(coopHUD.players[player_no],
    --                         Vector(anchor_top.X, anchor_top.Y + math.max(active_off.Y,hearts_off.Y)),
    --                         mirrored)
    --coopHUD.renderPoopSpells(coopHUD.players[player_no],Vector(pos.X,pos.Y + math.max(active_off.Y,hearts_off.Y)),mirrored)
    -- </Second  top line render> --
    -- <Down  line>
    trinket_off = coopHUD.renderTrinkets(coopHUD.players[player_no],
                                         anchor_bot,
                                         mirrored,nil,true)
    pocket_off = coopHUD.renderPockets(coopHUD.players[player_no],
                                       Vector(anchor_bot.X+trinket_off.X,anchor_bot.Y),
                                       mirrored,nil,true)
    -- </Down line>
    -- Renders stats
    if coopHUD.options.stats.show then
        coopHUD.renderStatsIcons(Vector(anchor_bot.X,72),mirrored)
        coopHUD.renderStats(coopHUD.players[player_no],Vector(anchor_bot.X,72),mirrored)
        coopHUD.renderStatChange(coopHUD.players[player_no],Vector(anchor_bot.X,72),mirrored)
        if coopHUD.players[player_no].has_twin then
            if #coopHUD.players == 0 then -- just to double sure that will not mess up
                local twin_anchor_bot = coopHUD.anchors[coopHUD.players_config[player_no+1].anchor_bot]
                coopHUD.renderStatsIcons(Vector(twin_anchor_bot.X,72),true)
                coopHUD.renderStats(coopHUD.players[player_no],Vector(twin_anchor_bot.X,72),true)
                coopHUD.renderStatChange(coopHUD.players[player_no],Vector(twin_anchor_bot.X,72),true)
            end
        end
    end
    -- Renders twin
    if coopHUD.players[player_no].has_twin then
        -- SPECIAL VERSION OF BIG HUD FOR SIGNLEPLAYER JACCOB/ESSAU
        local twin_anchor_top = coopHUD.anchors[coopHUD.players_config[player_no+1].anchor_top]
        local twin_anchor_bot = coopHUD.anchors[coopHUD.players_config[player_no+1].anchor_bot]
        local twin_mirrored = true
        -- <Locals inits>
        local twin_info_off = Vector(0, 0)
        local twin_active_off = Vector(0,0)
        local twin_hearts_off = Vector(0,0)
        local twin_exl_liv_off = Vector(0,0)
        local twin_pocket_off = Vector(0,0)
        local twin_trinket_off = Vector(0,0)
        local twin_extra_charge_off = Vector(0,0)
        -- <First  top twin line render> --
        -- No essau head sprite
--[[        twin_info_off = coopHUD.renderPlayerInfo(coopHUD.players[player_no].twin,
                                                 twin_anchor_top, mirrored, Vector(0.9,0.9), false)]]
        twin_active_off = coopHUD.renderActive(coopHUD.players[player_no].twin,
                                               Vector(twin_anchor_top.X+twin_info_off.X,twin_anchor_top.Y),
                                               twin_mirrored,nil,false)
        twin_hearts_off = coopHUD.renderHearts(coopHUD.players[player_no].twin,
                                               Vector(twin_anchor_top.X+twin_info_off.X+twin_active_off.X, twin_anchor_top.Y),
                                               twin_mirrored,nil,false)
        twin_exl_liv_off = coopHUD.renderExtraLives(coopHUD.players[player_no].twin,
                                                    Vector(twin_anchor_top.X+twin_info_off.X+twin_active_off.X+twin_hearts_off.X,
                                                           twin_anchor_top.Y),
                                                    twin_mirrored,nil,false)
        -- <First  top twin line render> --
        twin_trinket_off = coopHUD.renderTrinkets(coopHUD.players[player_no].twin,
                                                  twin_anchor_bot,
                                                  twin_mirrored,nil,true)
        twin_pocket_off = coopHUD.renderPockets(coopHUD.players[player_no].twin,
                                                Vector(twin_anchor_bot.X+twin_trinket_off.X,twin_anchor_bot.Y),
                                                twin_mirrored,nil,true)
    end
end
function coopHUD.renderPlayerSmall(player_no)
    local anchor = coopHUD.anchors[coopHUD.players_config.small[player_no].anchor]
    local mirrored = coopHUD.players_config.small[player_no].mirrored
    local scale = coopHUD.players_config.small.scale
    local down_anchor = coopHUD.players_config.small[player_no].down_anchor
    --
    --player_no = 0 --DEBUG: all anchor pos test
    -- <Locals inits>
    local info_off = Vector(0,0)
    local active_off = Vector(0,0)
    local hearts_off = Vector(0,0)
    local exl_liv_off = Vector(0,0)
    local pocket_off = Vector(0,0)
    local trinket_off = Vector(0,0)
    local extra_charge_off = Vector(0,0)
    -- <First  top line render> --
    info_off = coopHUD.renderPlayerInfo(coopHUD.players[player_no],
                                        anchor, mirrored, Vector(0.7,0.7), down_anchor)
    active_off = coopHUD.renderActive(coopHUD.players[player_no],
                                      Vector(anchor.X+info_off.X,anchor.Y),
                                      mirrored,scale,down_anchor)
    hearts_off = coopHUD.renderHearts(coopHUD.players[player_no],
                                      Vector(anchor.X+info_off.X+active_off.X, anchor.Y),
                                      mirrored,scale,down_anchor)
    exl_liv_off = coopHUD.renderExtraLives(coopHUD.players[player_no],
                                           Vector(anchor.X+info_off.X+active_off.X+hearts_off.X, anchor.Y),
                                           mirrored,scale,down_anchor)
    extra_charge_off = coopHUD.renderBethanyCharge(coopHUD.players[player_no],
                                                   Vector(anchor.X+info_off.X+active_off.X+hearts_off.X, anchor.Y+exl_liv_off.Y),
                                                   mirrored,scale,down_anchor)
    -- <Second  top line render> --
    local first_line_offset = Vector(0,0)
    if down_anchor then
        first_line_offset.Y = math.min(info_off.Y,active_off.Y,hearts_off.Y,(exl_liv_off.Y+extra_charge_off.Y))
    else
        first_line_offset.Y = math.max(info_off.Y,active_off.Y,hearts_off.Y,exl_liv_off.Y+extra_charge_off.Y)
    end
    trinket_off = coopHUD.renderTrinkets(coopHUD.players[player_no],
                                         Vector(anchor.X,anchor.Y+first_line_offset.Y),
                                         mirrored,scale,down_anchor)
    pockets_off = coopHUD.renderPockets(coopHUD.players[player_no],
                                        Vector(anchor.X+trinket_off.X,anchor.Y+first_line_offset.Y),
                                        mirrored,scale,down_anchor)
    local sec_line_offset = Vector(0,0)
    if down_anchor then
        sec_line_offset.Y = math.min(trinket_off.Y,pocket_off.Y)
    else
        sec_line_offset.Y = math.max(trinket_off.Y,pocket_off.Y)
    end
    -- </Second  top line render> --
    -- Renders stats
    if coopHUD.options.stats.show then
        -- Renders stat icons
        local stat_anchor = coopHUD.anchors[coopHUD.players_config.small[player_no].stat_anchor]
        if player_no == 0 or player_no == 1 then
            stat_anchor.Y = 72
            coopHUD.renderStatsIcons(stat_anchor,mirrored)
        else
            stat_anchor.Y = 78
        end
        coopHUD.renderStats(coopHUD.players[player_no],stat_anchor,mirrored)
        coopHUD.renderStatChange(coopHUD.players[player_no],stat_anchor,mirrored)
    end
    -- Renders twin
    if coopHUD.players[player_no].has_twin then
        --
        local twin_anchor = Vector(anchor.X,
                                   anchor.Y+first_line_offset.Y+sec_line_offset.Y)
        -- <Locals inits>
        local twin_info_off = Vector(0,0)
        local twin_active_off = Vector(0,0)
        local twin_hearts_off = Vector(0,0)
        local twin_exl_liv_off = Vector(0,0)
        local twin_pocket_off = Vector(0,0)
        local twin_trinket_off = Vector(0,0)
        local twin_extra_charge_off = Vector(0,0)
        --
        twin_active_off = coopHUD.renderActive(coopHUD.players[player_no].twin,
                                               Vector(twin_anchor.X,twin_anchor.Y),
                                               mirrored,scale,down_anchor)
        twin_hearts_off = coopHUD.renderHearts(coopHUD.players[player_no].twin,
                                               Vector(twin_anchor.X+twin_info_off.X+twin_active_off.X, twin_anchor.Y),
                                               mirrored,scale,down_anchor)
        twin_exl_liv_off = coopHUD.renderExtraLives(coopHUD.players[player_no].twin,
                                                    Vector(twin_anchor.X+twin_info_off.X+twin_active_off.X+twin_hearts_off.X,
                                                           twin_anchor.Y),
                                                    mirrored,scale,down_anchor)
        --
        
        local twin_first_line_offset = Vector(0,0)
        if down_anchor then
            twin_first_line_offset.Y =  math.min(twin_active_off.Y,twin_hearts_off.Y,
                                                (twin_exl_liv_off.Y+extra_charge_off.Y))
        else
            twin_first_line_offset.Y =  math.max(twin_active_off.Y,twin_hearts_off.Y,
                                                (twin_exl_liv_off.Y+twin_extra_charge_off.Y))
        end
        twin_trinket_off = coopHUD.renderTrinkets(coopHUD.players[player_no].twin,
                                             Vector(twin_anchor.X,twin_anchor.Y+twin_first_line_offset.Y),
                                             mirrored,scale,down_anchor)
        twin_pocket_off = coopHUD.renderPockets(coopHUD.players[player_no].twin,
                                                 Vector(twin_anchor.X + twin_trinket_off.X,
                                                        twin_anchor.Y + twin_first_line_offset.Y),
                                                 mirrored,scale,down_anchor)
    end
end
function coopHUD.renderItems()
    local color = KColor(1,1,1,1)
    -- TODO: Planetarium chances render
    -- TODO: Angel/Devil room chances
    local anchor = Vector(Isaac.GetScreenWidth()/2-64,Isaac.GetScreenHeight()-16) -- middle of screen
    local text = ''
    --
    local pos = Vector(anchor.X+4,anchor.Y)
    coopHUD.HUD_table.sprites.coin_sprite:Render(pos)
    --coopHUD.HUD_table.sprites.coin_sprite:Render(Vector(pos.X+8,pos.Y))
    text = string.format("%.2i", coopHUD.HUD_table.coin_no)
    if coopHUD.checkDeepPockets() then
        text = string.format("%.3i", coopHUD.HUD_table.coin_no) end
    local test = coopHUD.HUD_table.sprites.item_font:GetStringWidth(text)
    pos.X = pos.X+4+test
    coopHUD.HUD_table.sprites.item_font:DrawString(text,pos.X,pos.Y,color,0,false)
    ------
    pos = Vector(pos.X + 4 + test,pos.Y)
    coopHUD.HUD_table.sprites.bomb_sprite:Render(pos)
    text = string.format("%.2i", coopHUD.HUD_table.bomb_no)
    coopHUD.HUD_table.sprites.item_font:DrawString(text,pos.X+16,pos.Y,color,0,true)
    --------
    pos = Vector(pos.X + 16 + test,pos.Y)
    coopHUD.HUD_table.sprites.key_sprite:Render(pos)
    text = string.format("%.2i", coopHUD.HUD_table.key_no)
    coopHUD.HUD_table.sprites.item_font:DrawString(text,pos.X+16,pos.Y,color,0,true)
    ------ TIMER RENDER
    -- Code from TBoI Api by wofsauge
    local curTime = Game():GetFrameCount()
    local msecs= curTime%30 * (10/3) -- turns the millisecond value range from [0 to 30] to [0 to 100]
    local secs= math.floor(curTime/30)%60
    local mins= math.floor(curTime/30/60)%60
    local hours= math.floor(curTime/30/60/60)%60
    --
    time_string = string.format('Time: %.2i:%.2i:%.2i',hours,mins,secs) -- formats
    local f_col = KColor(0.5,0.5,0.5,0) -- Default font color font color with 0.5 alpha
    if coopHUD.options.timer_always_on then f_col.Alpha = 0.5 end
    --
    local level_name = Game():GetLevel():GetName()
    local curse_name = Game():GetLevel():GetCurseName()
    --
    if curse_name == '' then curse_name = nil end
    if coopHUD.signals.map then -- Catches if map button is pressed
        f_col.Alpha = 1
        if coopHUD.HUD_table.floor_info:IsFinished() then
            coopHUD.HUD_table.streak_sec_color = KColor(0, 0, 0, 1, 0, 0, 0)
            coopHUD.HUD_table.floor_info:Play("Text",true)
        end
    end
    -- Renders prompt on map button pressed
    coopHUD.renderStreak(coopHUD.HUD_table.floor_info,level_name,curse_name,
                         Vector((coopHUD.anchors.bot_right.X/2)-208, coopHUD.anchors.bot_left.Y-96),
                         coopHUD.signals.map)
    -- TIMER STRING DRAW
    coopHUD.HUD_table.sprites.timer_font:DrawString(time_string,
                                                    coopHUD.anchors.bot_right.X/2,0,
                                                    f_col,1,true)
    ---
    if coopHUD.streak_main_line ~= nil then -- Triggers animation if global string not nil
        if coopHUD.HUD_table.streak:IsFinished() then
            coopHUD.HUD_table.streak:Play('Text',true)
        end
    end
    -- Renders prompt on start
    if not Game():IsPaused() and secs > 0 then -- Prevents showing too early on start
        coopHUD.renderStreak(coopHUD.HUD_table.streak,coopHUD.streak_main_line,coopHUD.streak_sec_line,
                             Vector((coopHUD.anchors.bot_right.X/2)-208, 30),
                             false)
    end
    if coopHUD.HUD_table.streak:IsFinished() then -- Resets string(trigger)
        coopHUD.streak_main_line = nil
        coopHUD.streak_sec_line = nil
        coopHUD.HUD_table.streak_sec_line_font = coopHUD.getHUDSprites().streak_sec_line_font
    end
end
-------
function coopHUD.renderStreak(sprite, first_line, second_line, pos, signal)
    --[[ Function renders streak text on a based sprite/based position
    sprite: prepared loaded streak sprite object
    first_line: main line to be rendered - name of floor/used pill
    second_line: second line - nam of course
    pos: base anchor for sprite for left-top corner - it's anchoring there - accepts Vector
    signal: when true animation starts and stops to show all if false only show prompt
    ]]
    local main_font = Font()
    main_font:Load("font/upheaval.fnt")
    local sec_font = coopHUD.HUD_table.streak_sec_line_font
    local first_line_pos = Vector(pos.X, pos.Y+4+main_font:GetBaselineHeight())
    local cur_frame = sprite:GetFrame()
    if cur_frame > 33 and signal then
    else
        sprite:Update()
    end
    -- sets pos of text to animate it according to sprite frame
    if cur_frame < 5  then
        first_line_pos.X = pos.X + 4 * cur_frame
    end
    if cur_frame >= 5 and cur_frame <= 60 then
        first_line_pos.X = pos.X + 208
    end
    if cur_frame > 60 then
        first_line_pos.X = pos.X + 208 + 10 * cur_frame
    end
    if not sprite:IsFinished('Text') and sprite:IsPlaying('Text') then -- Renders only when animation
        if first_line then
            sprite:RenderLayer(0,Vector(pos.X+208,pos.Y+30))
            main_font:DrawString(first_line, first_line_pos.X, first_line_pos.Y, KColor(1, 1, 1, 1, 0, 0, 0), 1, true)
        end
        if second_line and sec_font then
            sprite:RenderLayer(1,Vector(pos.X+208,pos.Y+30))
            sec_font:DrawString(second_line, first_line_pos.X, first_line_pos.Y+30, coopHUD.HUD_table.streak_sec_color, 1, true)
        end
    end
end
-- _____ INPUTS
local btn_held = 0
function coopHUD.on_input(_,ent,hook,btn)
    -- Handler for turning timer on of on key
    if Input.IsButtonTriggered(Keyboard.KEY_T,0)  then
        if coopHUD.options.timer_always_on then
            coopHUD.options.timer_always_on = false
        else
            coopHUD.options.timer_always_on = true
        end
    end
    -- _____ Joining new players logic
    for i=0,8,1 do
        if Input.IsActionTriggered(ButtonAction.ACTION_JOINMULTIPLAYER,i) and not coopHUD.signals.is_joining and
                coopHUD.players[coopHUD.getPlayerNumByControllerIndex(i)] == nil and
                Game():IsGreedMode() == false and Game():GetRoom():IsFirstVisit() == true and
                Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE1_1 and
                Game():GetLevel():GetCurrentRoomIndex() == Game():GetLevel():GetStartingRoomIndex()
                and not string.match(Game():GetLevel():GetName(), "Downpour")
                and not string.match(Game():GetLevel():GetName(), "Dross") then
            coopHUD.options.onRender = false
            coopHUD.signals.is_joining = true
        end
        if Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK,i) and  coopHUD.signals.is_joining then
            coopHUD.signals.is_joining = false
            coopHUD.options.onRender = true
        end
        if Input.IsActionTriggered(6,i) and coopHUD.signals.on_item_update then
            coopHUD.test_str = true
        end
    end
    -- MAP BUTTON
    local mapPressed = false
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        local player_index = coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)
        if Input.IsActionTriggered(ButtonAction.ACTION_DROP, player.ControllerIndex) then
            coopHUD.updateHearts(player_index)
            coopHUD.updatePlayerType(player_index)
            coopHUD.updatePockets(player_index)
        end
        mapPressed = mapPressed or Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex)
    end
    if mapPressed then
        btn_held = btn_held + 1
        if btn_held > 1200 then
            coopHUD.signals.map = true
        end
    else
        coopHUD.signals.map = false
        btn_held = 0
    end
    end
coopHUD:AddCallback(ModCallbacks.MC_INPUT_ACTION, coopHUD.on_input)
-- _____ On pill use
function coopHUD.on_pill_use(_,effect_no,ent_player)
    -- Triggers streak text on pill use
    if coopHUD.HUD_table.streak:IsFinished() then
        local pill_sys_name = Isaac.GetItemConfig():GetPillEffect(effect_no).Name
        pill_sys_name = string.sub(pill_sys_name,2) --  get rid of # on front of
        if langAPI ~= nil then
            coopHUD.streak_main_line = langAPI.getPocketName(pill_sys_name)
        end
    end
    local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
    -- Triggers pocket update signal
    coopHUD.signals.on_pockets_update = player_index
    -- Updates trinkets if Gulp used
    if effect_no == PillEffect.PILLEFFECT_GULP then
        coopHUD.signals.on_trinket_update = player_index
    end
    coopHUD.signals.on_heart_update = player_index
end
coopHUD:AddCallback(ModCallbacks.MC_USE_PILL, coopHUD.on_pill_use)
-- _____ On card use
function coopHUD.on_card_use(_,effect_no,ent_player)
    --Triggers pocket update signal
    coopHUD.signals.on_pockets_update = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
end
coopHUD:AddCallback(ModCallbacks.MC_USE_CARD, coopHUD.on_card_use)
-- _____ Triggers STREAK when on new level
coopHUD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function(self)
    coopHUD.streak_main_line = Game():GetLevel():GetName()
    coopHUD.streak_sec_line = Game():GetLevel():GetCurseName()
    if coopHUD.streak_sec_line == '' then coopHUD.streak_sec_line = nil end
end)
-- ______
function coopHUD.getPlayerNumByControllerIndex(controller_index)
    -- Function returns player number searching coopHUD.player table for matching controller index
    local final_index = -1
    for i,p in pairs(coopHUD.players) do
        if p.controller_index == controller_index then
            final_index = i
        end
    end
    return final_index
end
-- _____ RENDER
function  coopHUD.render()
    -- DEBUG: handler to quick turn on/off hud on pressing 'H' on keyboard
    if Input.IsButtonTriggered(Keyboard.KEY_H,0)  then
        if coopHUD.options.onRender then
            coopHUD.options.onRender = false
        else
            coopHUD.options.onRender = true
        end
    end
    if #coopHUD.players > 4 then -- prevents to render if more than 4 players for now
        coopHUD.options.onRender = false
        Game():GetHUD():SetVisible(true)
    end
    -- _____ Main render function
    local paused = Game():IsPaused()
    if coopHUD.options.onRender and not paused then -- Renders HUD if game not paused and option turned on
        Game():GetHUD():SetVisible(false) -- sets off vanilla hud
        -- RENDER LOGIC
        coopHUD.renderItems()
        for i,p in pairs(coopHUD.players) do
            -- Logic of <2 players - big hud
            if #coopHUD.players<2 and not coopHUD.options.force_small_hud then
                -- Renders Hud when  Jacob and Essau in game
                if coopHUD.essau_no > 0 then
                    -- TODO:
                    if #coopHUD.players == 0 then
                        -- Renders special version of big hud for singleplayer
                        coopHUD.renderPlayer(i)
                        -- TODO: render singleplayer jacob/essau
                    else
                        -- Renders small hud when jacob/esaau present and no players>0
                        coopHUD.renderPlayerSmall(i)
                    end
                else
                    coopHUD.renderPlayer(i)
                end
                
            else
                coopHUD.renderPlayerSmall(i)
            end
        end
    elseif paused and coopHUD.options.onRender then -- Prevents from rendering anything on pause
        Game():GetHUD():SetVisible(false)
    else
        Game():GetHUD():SetVisible(true) -- Turns on vanilla HUD
    end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)
-- __________ On start
function coopHUD.on_start(_,cont)
    coopHUD.players = {}
    if cont then
        -- Logic when game is continued
        --[[coopHUD.essau_no = 0 -- resets Essau counter before player init
        if coopHUD.players[0] == nil then coopHUD.on_player_init() end]]
        coopHUD.essau_no = 0 -- resets Essau counter before player init
        if coopHUD.players[0] == nil then
            coopHUD.signals.is_joining = true
            coopHUD.on_player_init()
        end
    else
        -- Logic when started new game/ restart thought dbg console
        
        coopHUD.essau_no = 0 -- resets Essau counter before player init
        if coopHUD.players[0] == nil then
            coopHUD.signals.is_joining = true
            coopHUD.on_player_init()
        end
    end
    coopHUD.initHudTables()
    coopHUD.updateItems()
end
coopHUD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, coopHUD.on_start)
-- __________ On player init
function coopHUD.on_player_init()
    
    if coopHUD.signals.is_joining then
        coopHUD.essau_no = 0
        for i=0,Game():GetNumPlayers()-1,1 do
            local temp_player_table = coopHUD.initPlayer(i)
            if temp_player_table  then
                coopHUD.players[i-coopHUD.essau_no] = temp_player_table
                if coopHUD.players[i-coopHUD.essau_no].has_twin then
                    local temp_twin = Isaac.GetPlayer(i):GetOtherTwin()
                    coopHUD.players[i-coopHUD.essau_no].twin = coopHUD.initPlayer(i,temp_twin) -- inits
                    coopHUD.players[i-coopHUD.essau_no].twin.is_twin = true -- inits
                    coopHUD.essau_no = coopHUD.essau_no + 1
                end
            end
        end
    end
    --
    coopHUD.updateControllerIndex()
    coopHUD.signals.is_joining = false
    coopHUD.options.onRender = true
    
end
coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, coopHUD.on_player_init,0)
-- __________ On active item/pocket activate
function coopHUD.on_activate(_,type,RNG, EntityPlayer, UseFlags, used_slot, CustomVarData)
    local player_index = coopHUD.getPlayerNumByControllerIndex(EntityPlayer.ControllerIndex)
    -- Hold on use change sprite
    if type == CollectibleType.COLLECTIBLE_HOLD and coopHUD.players[player_index].poop_mana > 0 then
        if coopHUD.players[player_index].hold_spell == nil  then
            coopHUD.players[player_index].hold_spell = EntityPlayer:GetPoopSpell(0)
            coopHUD.updatePockets(player_index)
        else
            coopHUD.players[player_index].hold_spell = nil
        end
        coopHUD.updatePoopMana(player_index)
    end
    -- Check if used Smelter
    if type == CollectibleType.COLLECTIBLE_SMELTER then
        coopHUD.signals.on_trinket_update = player_index -- update trinkets on smelt
    end
    if coopHUD.players[player_index].type == PlayerType.PLAYER_BETHANY or
            coopHUD.players[player_index].type == PlayerType.PLAYER_BETHANY_B then
        coopHUD.signals.on_bethany_update = player_index
    end
    -- Update actives
    coopHUD.signals.on_active_update = player_index
    coopHUD.signals.on_pockets_update = player_index
    coopHUD.signals.on_heart_update = player_index
    print(type)
end
coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM, coopHUD.on_activate)
-- __________ On item pickup
function coopHUD.on_item_pickup(_, ent_player, ent_collider, Low)
    -- Checks if player entity collides with item
    if ent_collider then
        local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex)
        if ent_collider.Type == EntityType.ENTITY_PICKUP then -- checks if collide with item
            if ent_collider.Variant == PickupVariant.PICKUP_HEART then -- check if collides with heart
                coopHUD.signals.on_heart_update = player_index
            elseif ent_collider.Variant == PickupVariant.PICKUP_COIN or -- check if collides with coin
                    ent_collider.Variant == PickupVariant.PICKUP_KEY or -- or with key
                    ent_collider.Variant == PickupVariant.PICKUP_BOMB then -- or with bomb
                coopHUD.signals.on_item_update = true -- triggers item update by signal
            elseif ent_collider.Variant == PickupVariant.PICKUP_LIL_BATTERY then
                coopHUD.signals.on_active_update = player_index -- triggers active updates
                coopHUD.signals.on_pockets_update = player_index -- triggers pockets updates
            elseif ent_collider.Variant == PickupVariant.PICKUP_TAROTCARD then
                coopHUD.signals.on_pockets_update = player_index -- triggers pocket update by signal
            elseif ent_collider.Variant == PickupVariant.PICKUP_PILL then
                coopHUD.signals.on_pockets_update = player_index -- triggers pocket update by signal
            end
        end
        if ent_collider.Type == EntityType.ENTITY_SLOT then -- checks if collide with slot machine
            coopHUD.signals.on_item_update = true -- triggers item update
        end
    end
end
coopHUD:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, coopHUD.on_item_pickup)
-- __________ On damage
function coopHUD.on_damage(_,entity)
    local ent_player = entity:ToPlayer() -- parse entity to player entity
    local player_index = coopHUD.getPlayerNumByControllerIndex(ent_player.ControllerIndex) -- gets player index
    coopHUD.signals.on_heart_update = player_index -- triggers heart update for player
    if ent_player:HasCollectible(CollectibleType.COLLECTIBLE_MARBLES) then -- in case of marbles (can gulp trinket)
        coopHUD.signals.on_trinket_update = player_index -- update trinkets
    end
end
coopHUD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, coopHUD.on_damage, EntityType.ENTITY_PLAYER)
-- __________ On room clear
function  coopHUD.on_room_clear()
    -- Iterates through tables
    for i,_ in pairs(coopHUD.players) do
        coopHUD.updateActives(i) -- updates actives
        coopHUD.updatePockets(i) -- updates pockets
    end
end
coopHUD:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, coopHUD.on_room_clear)
-- __________ Force update on new floor/room
--- Function force updates all table. Triggers on new room/floor
function coopHUD.force_update_all()
    for i,_ in pairs(coopHUD.players) do
        coopHUD.updateActives(i)
        coopHUD.updateHearts(i)
        coopHUD.updatePockets(i)
        coopHUD.updateTrinkets(i)
        coopHUD.updateExtraLives(i)
        coopHUD.updateBethanyCharge(i)
        coopHUD.updatePoopMana(i)
    end
    coopHUD.updateControllerIndex()
end
coopHUD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, coopHUD.force_update_all)
coopHUD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, coopHUD.force_update_all)
-- __________
-- _____
---renderStatsIcons
---Renders stats icons in given position Vector(x:int,y:int).
---Anchors group of sprites by left top corner
---@param pos Vector()
---@param mirrored boolean If true renders mirrored
function coopHUD.renderStatsIcons(pos,mirrored)
    --TODO: mirrored
    local off = Vector(12,0)
    local temp_pos = Vector(pos.X,pos.Y)
    if mirrored then
        temp_pos.X = temp_pos.X - 16
    end
    -- Move speed
    coopHUD.HUD_table.stats.speed:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Tear delay
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    coopHUD.HUD_table.stats.tears_delay:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Damage
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    coopHUD.HUD_table.stats.damage:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Range
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    coopHUD.HUD_table.stats.range:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Shoot speed
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    coopHUD.HUD_table.stats.shot_speed:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Luck
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    coopHUD.HUD_table.stats.luck:Render(Vector(temp_pos.X,temp_pos.Y))
end
-- _____
---renderStats
--- Renders only decimal stats for given player.
---Renders also stat changes using renderStatChange
---@param player table coopHUD.players[n].stats
---@param pos Vector()
---@param mirrored boolean If true renders mirrored
---@param color KColor()
function coopHUD.renderStats(player,pos,mirrored)
    local temp_pos = Vector(pos.X,pos.Y)
    local f = coopHUD.HUD_table.stats.font
    if mirrored then
        temp_pos.X = temp_pos.X - 50
    end
    --
    local font_color = KColor(1,1,1,0.5) -- holds font colors
    -- Changes stats font color for player according to color setting
    if coopHUD.options.stats.colorful then
        font_color.Red = coopHUD.players_config.small[coopHUD.getPlayerNumByControllerIndex(player.controller_index)].color.R
        font_color.Green = coopHUD.players_config.small[coopHUD.getPlayerNumByControllerIndex(player.controller_index)].color.G
        font_color.Blue = coopHUD.players_config.small[coopHUD.getPlayerNumByControllerIndex(player.controller_index)].color.B
    else
        font_color = KColor(1,1,1,0.5) -- default color
    end
    -- Highlights stat when player holds map button
    if Input.IsActionPressed(ButtonAction.ACTION_MAP,player.controller_index) then
        font_color.Alpha = 1
    end
    -- Move speed
    f:DrawString(string.format("%.2f",player.stats.speed[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    -- Tear delay
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.tears_delay[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    -- Damage
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.damage[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    -- Range
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.range[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    -- Shoot speed
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.shot_speed[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    -- Luck
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.luck[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
end
-- _____
coopHUD.stat_counter = 0
local drawing = false
---renderStatChange
---Renders stat change
---@param player table coopHUD.players[n].stats
---@param pos Vector()
function coopHUD.renderStatChange(player,pos,mirrored)
    local f = coopHUD.HUD_table.stats.font
    local temp_pos = Vector(pos.X,pos.Y)
    if mirrored then
        temp_pos.X = temp_pos.X - 95
    end
    -- Move speed
    if player.stats.speed[2] ~= 0 then
        local dif = coopHUD.getStatChangeAttrib(player.stats.speed[2])
        f:DrawString(dif.str,temp_pos.X+36,temp_pos.Y,dif.color,0,true)
        drawing = true
    end
    -- Tear delay
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    if player.stats.tears_delay[2] ~= 0 then
        local dif = coopHUD.getStatChangeAttrib(player.stats.tears_delay[2])
        f:DrawString(dif.str,temp_pos.X+36,temp_pos.Y,dif.color,0,true)
        drawing = true
    end
    -- Damage
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    if player.stats.damage[2] ~= 0 then
        local dif = coopHUD.getStatChangeAttrib(player.stats.damage[2])
        f:DrawString(dif.str,temp_pos.X+36,temp_pos.Y,dif.color,0,true)
        drawing = true
    end
    -- Range
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    if player.stats.range[2] ~= 0 then
        local dif = coopHUD.getStatChangeAttrib(player.stats.range[2])
        f:DrawString(dif.str,temp_pos.X+36,temp_pos.Y,dif.color,0,true)
        drawing = true
    end
    -- Shoot speed
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    if player.stats.shot_speed[2] ~= 0 then
        local dif = coopHUD.getStatChangeAttrib(player.stats.shot_speed[2])
        f:DrawString(dif.str,temp_pos.X+36,temp_pos.Y,dif.color,0,true)
        drawing = true
    end
    -- Luck
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    if player.stats.luck[2] ~= 0 then
        local dif = coopHUD.getStatChangeAttrib(player.stats.luck[2])
        f:DrawString(dif.str,temp_pos.X+36,temp_pos.Y,dif.color,0,true)
        drawing = true
    end
    if drawing then
        coopHUD.stat_counter  = coopHUD.stat_counter + 1
        if coopHUD.stat_counter  > 200 then
            player.stats.speed[2] = 0
            player.stats.tears_delay[2] = 0
            player.stats.damage[2] = 0
            player.stats.range[2] = 0
            player.stats.shot_speed[2] = 0
            player.stats.luck[2] = 0
            drawing = false
        end
    else
        coopHUD.stat_counter  = 0
        drawing = false
    end
    
end
-- _____
---getStatChangeAttrib
---Returns table of change int attribs. Defines color and prefix +/-
---@param stat string
---@return table {str = stat_dif_string, color = stat_dif_color}
function coopHUD.getStatChangeAttrib(stat)
    local dif_string = ''
    dif_string = string.format('%.2f',stat)
    local dif_color = KColor(1,1,1,1)
    if stat > 0 then
        dif_color = KColor(0,1,0,0.7)
        dif_string = '+'..dif_string
    else
        dif_color = KColor(1,0,0,0.7)
    end
    return {str = dif_string,color=dif_color}
end
-- _____