local SHExists, ScreenHelper = pcall(require, "scripts.screenhelper")
coopHUD.jar_of_wisp_charge = nil -- Global value of jar_of_wisp_charge
-- _____
function coopHUD.initPlayer(player_no,ent_player)
    -- Gets player no according to coopHUD tables
    -- If essau == true function return Essau table else nil
    local temp_player = Isaac.GetPlayer(player_no)
    if ent_player ~= nil then temp_player = ent_player end
    local player_table = {}
    player_table = {
        --- INFO
        type = temp_player:GetPlayerType(),
        controller_index = temp_player.ControllerIndex,
        game_index = player_no,
        -- ITEMS
        -- Actives
        first_active = temp_player:GetActiveItem(0),
        first_active_charge = temp_player:GetActiveCharge(0),
        second_active = temp_player:GetActiveItem(1),
        second_active_charge = temp_player:GetActiveCharge(1),
        -- Trinkets
        first_trinket = temp_player:GetTrinket(0),
        second_trinket = temp_player:GetTrinket(1),
        -- Pockets
        first_pocket = coopHUD.getPocketID(temp_player,0),
        first_pocket_charge = temp_player:GetActiveCharge(2),
        second_pocket = coopHUD.getPocketID(temp_player,1),
        third_pocket = coopHUD.getPocketID(temp_player,2),
        pocket_desc = coopHUD.getMainPocketDesc(temp_player),
        -- Collectibles
        collectibles = {},
        -- Hearts
        heart_types = coopHUD.getHeartTypeTable(temp_player),
        total_hearts = math.ceil((temp_player:GetEffectiveMaxHearts() + temp_player:GetSoulHearts())/2),
        max_health_cap = 12,
        extra_lives = temp_player:GetExtraLives(),
        -- Sub player
        has_sub = false, -- Determines if player has sub as Forgotten/Soul
        has_twin = false, -- Determines if player has twin as Jacob/Essau
        sub_heart_types = {},
        twin = {},
        -- Stats
        -- Charges
        bethany_charge = nil, -- inits charge for Bethany
        wisp_jar_use = 0, -- holds info about used jar of wisp
        --- T ??? - specifics
        poop_mana = 0, -- current mana (int)
        max_poop_mana = 0, -- max cap of mana that player holds (int)
        poops = nil, -- table of
        hold_spell = nil, -- current spell stashed in hold (int)
        ---
        has_birthright = false,
        has_guppy = false,
        ---
        sprites = {
            player_head = coopHUD.getPlayerHeadSprite(temp_player:GetPlayerType()),
            first_active = coopHUD.getActiveItemSprite(temp_player,0),
            first_active_charge = coopHUD.getChargeSprites(temp_player,0),
            first_active_bethany_charge = nil,
            second_active = coopHUD.getActiveItemSprite(temp_player,1),
            second_active_charge = coopHUD.getChargeSprites(temp_player,1),
            first_trinket = coopHUD.getTrinketSprite(temp_player,0),
            second_trinket = coopHUD.getTrinketSprite(temp_player,1),
            first_pocket = coopHUD.getPocketItemSprite(temp_player,0),
            first_pocket_charge = coopHUD.getChargeSprites(temp_player,2),
            second_pocket = coopHUD.getPocketItemSprite(temp_player,1),
            third_pocket = coopHUD.getPocketItemSprite(temp_player,2),
            hearts = coopHUD.getHeartSpriteTable(temp_player),
            sub_hearts = nil,
            poops = nil,
        },
    }
    -- ___ Bethany/T.Bethany check
    if player_table.type == 18 or player_table.type == 36 then
        if player_table.type == 18 then
            player_table.bethany_charge = temp_player:GetSoulCharge()
        else
            player_table.bethany_charge = temp_player:GetBloodCharge()
        end
    end
    -- ___ Forgotten/Soul check
    if  player_table.type == 16 or player_table.type == 17 then
        player_table.has_sub = true
        local sub = temp_player:GetSubPlayer()
        player_table.sprites.sub_hearts = coopHUD.getHeartSpriteTable(sub)
        player_table.sub_heart_types = coopHUD.getHeartTypeTable(sub)
    end
    -- ___ T. ??? check
    if player_table.type == PlayerType.PLAYER_XXX_B then
        player_table.poops = coopHUD.getPoopSpellTable(player_no)
        player_table.sprites.poops = coopHUD.getPoopSpriteTable(temp_player)
        player_table.poop_mana = temp_player:GetPoopMana()
        player_table.max_poop_mana = 9
    end
    -- ___ Jacob check
    local essau_no = coopHUD.essau_no
    if player_table.type == 19 then
        --
        player_table.has_twin = true
        if player_no == 0 or player_no == 1 then essau_no = 0 end -- prevents errors on indexing <0 vals
    end
    -- name of player, must be after func check essau_no
    player_table.name = coopHUD.players_config.small[player_no-essau_no].name
    -- ___ Essau check
    if player_table.type == 20 and not ent_player then
        -- In player is Essau skip it. Essau table is determined inside Jacob player as twin
        player_table = nil
    end
    return player_table
end
-- _____ Updates
function coopHUD.updateCollectible(player_no)
    --TODO: update when item picked up
    local player = Isaac.GetPlayer(coopHUD.players[player_no].game_index)
    -- Update if player has birthright
    if not coopHUD.players[player_no].has_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        coopHUD.players[player_no].has_birthright = true
    end
    -- Update if player has guppy's collar
    if not coopHUD.players[player_no].has_guppy and player:HasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR) then
        coopHUD.players[player_no].has_guppy = true
    end
end
function coopHUD.updatePockets(player_no)
    local temp_player = Isaac.GetPlayer(coopHUD.players[player_no].game_index)
    if coopHUD.players[player_no].first_pocket[1] ~= coopHUD.getPocketID(temp_player,0)[1] then
        coopHUD.players[player_no].first_pocket = coopHUD.getPocketID(temp_player,0)
        coopHUD.players[player_no].sprites.first_pocket = coopHUD.getPocketItemSprite(temp_player,0)
        coopHUD.players[player_no].pocket_desc = coopHUD.getMainPocketDesc(temp_player)
        -- Refresh description on item change
        if coopHUD.getPocketID(temp_player,0)[2] == 1 and
                  coopHUD.signals.on_pockets_update then
            coopHUD.HUD_table.streak:ReplaceSpritesheet(1,"/gfx/ui/blank.png")
            coopHUD.HUD_table.streak:LoadGraphics()
            coopHUD.streak_main_line = coopHUD.players[coopHUD.signals.on_pockets_update].pocket_desc.name
            coopHUD.streak_sec_line = coopHUD.players[coopHUD.signals.on_pockets_update].pocket_desc.desc
            coopHUD.HUD_table.streak_sec_color = KColor(1,1,1,1)
            coopHUD.HUD_table.streak_sec_line_font:Load("font/pftempestasevencondensed.fnt")
        end
    end
    if coopHUD.players[player_no].second_pocket ~= coopHUD.getPocketID(temp_player,1) then
        coopHUD.players[player_no].second_pocket = coopHUD.getPocketID(temp_player,1)
        coopHUD.players[player_no].sprites.second_pocket = coopHUD.getPocketItemSprite(temp_player,1)
    end
    if coopHUD.players[player_no].third_pocket ~= coopHUD.getPocketID(temp_player,2) then
        coopHUD.players[player_no].third_pocket = coopHUD.getPocketID(temp_player,2)
        coopHUD.players[player_no].sprites.third_pocket = coopHUD.getPocketItemSprite(temp_player,2)
    end
    if coopHUD.players[player_no].first_pocket_charge ~= temp_player:GetActiveCharge(2) or forceUpdateActives then
        coopHUD.players[player_no].first_pocket_charge = temp_player:GetActiveCharge(2)
        coopHUD.players[player_no].sprites.first_pocket_charge = coopHUD.getChargeSprites(temp_player,2)
        coopHUD.players[player_no].first_pocket = coopHUD.getPocketID(temp_player,0)
        coopHUD.players[player_no].sprites.first_pocket = coopHUD.getPocketItemSprite(temp_player,0)
    end
    if coopHUD.players[player_no].has_twin then
        local twin_player = temp_player:GetOtherTwin()
        if coopHUD.players[player_no].twin.first_pocket[1] ~= coopHUD.getPocketID(twin_player,0)[1] then
            coopHUD.players[player_no].twin.first_pocket = coopHUD.getPocketID(twin_player,0)
            coopHUD.players[player_no].twin.sprites.first_pocket = coopHUD.getPocketItemSprite(twin_player,0)
            -- Refresh description on item change
            coopHUD.players[player_no].twin.pocket_desc = coopHUD.getMainPocketDesc(twin_player)
            if coopHUD.getPocketID(twin_player,0)[2] == 1 and
                    coopHUD.signals.on_pockets_update then
                coopHUD.HUD_table.streak:ReplaceSpritesheet(1,"/gfx/ui/blank.png")
                coopHUD.HUD_table.streak:LoadGraphics()
                coopHUD.streak_main_line = coopHUD.players[coopHUD.signals.on_pockets_update].twin.pocket_desc.name
                coopHUD.streak_sec_line = coopHUD.players[coopHUD.signals.on_pockets_update].twin.pocket_desc.desc
                coopHUD.HUD_table.streak_sec_color = KColor(1,1,1,1)
                coopHUD.HUD_table.streak_sec_line_font:Load("font/pftempestasevencondensed.fnt")
            end
        end
        if coopHUD.players[player_no].twin.second_pocket ~= coopHUD.getPocketID(twin_player,1) then
            coopHUD.players[player_no].twin.second_pocket = coopHUD.getPocketID(twin_player,1)
            coopHUD.players[player_no].twin.sprites.second_pocket = coopHUD.getPocketItemSprite(twin_player,1)
        end
        if coopHUD.players[player_no].twin.third_pocket ~= coopHUD.getPocketID(twin_player,2) then
            coopHUD.players[player_no].twin.third_pocket = coopHUD.getPocketID(twin_player,2)
            coopHUD.players[player_no].twin.sprites.third_pocket = coopHUD.getPocketItemSprite(twin_player,2)
        end
        if coopHUD.players[player_no].twin.pocket_desc and coopHUD.getMainPocketDesc(twin_player) and
                coopHUD.players[player_no].twin.pocket_desc.name ~= coopHUD.getMainPocketDesc(twin_player).name then
        end
        if coopHUD.players[player_no].twin.first_pocket_charge ~= twin_player:GetActiveCharge(2) or forceUpdateActives then
            coopHUD.players[player_no].twin.first_pocket_charge = twin_player:GetActiveCharge(2)
            coopHUD.players[player_no].twin.sprites.first_pocket_charge = coopHUD.getChargeSprites(twin_player,2)
            coopHUD.players[player_no].twin.first_pocket = coopHUD.getPocketID(twin_player,0)
            coopHUD.players[player_no].twin.sprites.first_pocket = coopHUD.getPocketItemSprite(twin_player,0)
        end
    end
end
function coopHUD.updateActives(player_no)
    local temp_player = Isaac.GetPlayer(coopHUD.players[player_no].game_index)
    if coopHUD.players[player_no] ~= nil then
        if coopHUD.players[player_no].first_active == 685 and coopHUD.jar_of_wisp_charge == nil then
            coopHUD.jar_of_wisp_charge = 0  -- sets default val if item is picked first time
        end
        -- Catches if player uses jar of the wisp, checks effects of jar of wisp in this run
        -- and increment global charge value.
        -- Dont work on dubled jar of wisp due to item pool or in ex. Dipoipia
        -- It's workaround due broken ActiveItemDesc.VarData api function
        -- FIXME: Jar of wisp charge: wait till api is fixed
        if Input.IsActionPressed(ButtonAction.ACTION_ITEM, 0) and coopHUD.players[player_no].first_active == 685 then
            local tempEffects = player:GetEffects()
            if coopHUD.jar_of_wisp_charge ~= tempEffects:GetCollectibleEffectNum(685) then
                coopHUD.jar_of_wisp_charge = tempEffects:GetCollectibleEffectNum(685)
                if coopHUD.jar_of_wisp_charge >= 12 then
                    coopHUD.jar_of_wisp_charge = 11
                end
            end
        end
        if coopHUD.players[player_no].first_active ~= temp_player:GetActiveItem(0)  then
            coopHUD.players[player_no].first_active = temp_player:GetActiveItem(0)
            coopHUD.players[player_no].second_active = temp_player:GetActiveItem(1)
            coopHUD.players[player_no].sprites.first_active = coopHUD.getActiveItemSprite(temp_player,0)
            coopHUD.players[player_no].sprites.second_active = coopHUD.getActiveItemSprite(temp_player,1)
            coopHUD.players[player_no].sprites.second_active_charge = coopHUD.getChargeSprites(temp_player,1)
        end
        coopHUD.updateCharge(player_no)
        if coopHUD.players[player_no].first_active_charge ~= temp_player:GetActiveCharge(0) or forceUpdateActives then
            coopHUD.players[player_no].first_active_charge = temp_player:GetActiveCharge(0)
            coopHUD.players[player_no].sprites.first_active = coopHUD.getActiveItemSprite(temp_player,0)
            coopHUD.players[player_no].sprites.first_active_charge = coopHUD.getChargeSprites(temp_player,0)
        end
        if coopHUD.players[player_no].has_twin then
            local twin_player = temp_player:GetOtherTwin()
            if coopHUD.players[player_no].twin.first_active ~= twin_player:GetActiveItem(0)  then
                coopHUD.players[player_no].twin.first_active = twin_player:GetActiveItem(0)
                coopHUD.players[player_no].twin.second_active = twin_player:GetActiveItem(1)
                coopHUD.players[player_no].twin.sprites.first_active = coopHUD.getActiveItemSprite(twin_player,0)
                coopHUD.players[player_no].twin.sprites.second_active = coopHUD.getActiveItemSprite(twin_player,1)
                coopHUD.players[player_no].twin.sprites.second_active_charge = coopHUD.getChargeSprites(twin_player,1)
            end
            if coopHUD.players[player_no].twin.first_active_charge ~= twin_player:GetActiveCharge(0) or forceUpdateActives then
                coopHUD.players[player_no].twin.first_active_charge = twin_player:GetActiveCharge(0)
                coopHUD.players[player_no].twin.sprites.first_active = coopHUD.getActiveItemSprite(twin_player,0)
                coopHUD.players[player_no].twin.sprites.first_active_charge = coopHUD.getChargeSprites(twin_player,0)
            end
        end
    end
    end
function coopHUD.updateCharge(player_no)
    local temp_player = Isaac.GetPlayer(coopHUD.players[player_no].game_index)
    coopHUD.players[player_no].sprites.first_active_charge = coopHUD.getChargeSprites(temp_player,0)
end
function coopHUD.updateTrinkets(player_no)
    local temp_player = Isaac.GetPlayer(coopHUD.players[player_no].game_index)
    if coopHUD.players[player_no].first_trinket ~= temp_player:GetTrinket(0) then
        coopHUD.players[player_no].first_trinket = temp_player:GetTrinket(0)
        coopHUD.players[player_no].sprites.first_trinket = coopHUD.getTrinketSprite(temp_player,0)
    end
    if coopHUD.players[player_no].second_trinket ~= temp_player:GetTrinket(1) then
        coopHUD.players[player_no].second_trinket = temp_player:GetTrinket(1)
        coopHUD.players[player_no].sprites.second_trinket = coopHUD.getTrinketSprite(temp_player,1)
    end
    if coopHUD.players[player_no].has_twin then
        local twin_player = temp_player:GetOtherTwin()
        if coopHUD.players[player_no].twin.first_trinket ~= twin_player:GetTrinket(0) then
            coopHUD.players[player_no].twin.first_trinket = twin_player:GetTrinket(0)
            coopHUD.players[player_no].twin.sprites.first_trinket = coopHUD.getTrinketSprite(twin_player,0)
        end
        if coopHUD.players[player_no].twin.second_trinket ~= twin_player:GetTrinket(1) then
            coopHUD.players[player_no].twin.second_trinket = twin_player:GetTrinket(1)
            coopHUD.players[player_no].twin.sprites.second_trinket = coopHUD.getTrinketSprite(twin_player,1)
        end
    end
end
function coopHUD.updateHearts(player_no)
    local temp_player = Isaac.GetPlayer(coopHUD.players[player_no].game_index)
    local max_health_cap = 12
    local sub_player = nil
    local temp_total_hearts = math.ceil((temp_player:GetEffectiveMaxHearts() + temp_player:GetSoulHearts())/2)

    if coopHUD.players[player_no].total_hearts ~= temp_total_hearts then
        coopHUD.players[player_no].total_hearts = temp_total_hearts
        if coopHUD.players[player_no].max_health_cap ~= 18 and -- prevent from changing after birthright picked
                coopHUD.players[player_no].type == PlayerType.PLAYER_MAGDALENA and -- checks if payer is Maggy
                coopHUD.players[player_no].has_birthright then
            coopHUD.players[player_no].max_health_cap = 18
        end
    end
    if coopHUD.players[player_no].has_sub then
        sub_player = temp_player:GetSubPlayer()
        max_health_cap = 6
    end
    for i=coopHUD.players[player_no].max_health_cap,0,-1 do
        local heart_type,overlay = coopHUD.getHeartType(temp_player,i)
        if (coopHUD.players[player_no].heart_types[i] == nil) or
                (coopHUD.players[player_no].heart_types[i].heart_type ~= heart_type) or
                (coopHUD.players[player_no].heart_types[i].overlay ~= overlay) then
            coopHUD.players[player_no].heart_types[i].heart_type = heart_type
            coopHUD.players[player_no].heart_types[i].overlay = overlay
            coopHUD.players[player_no].sprites.hearts[i] = coopHUD.getHeartSprite(heart_type,overlay)
        end
    end
    if coopHUD.players[player_no].has_sub then
        for i=max_health_cap,0,-1 do
            local test_type = coopHUD.getHeartType(sub_player,i)
            if coopHUD.players[player_no].sub_heart_types[i].heart_type ~= test_type then
                local heart_type,overlay = coopHUD.getHeartType(sub_player,i)
                coopHUD.players[player_no].sub_heart_types[i].heart_type = heart_type
                coopHUD.players[player_no].sub_heart_types[i].overlay = overlay
                coopHUD.players[player_no].sprites.sub_hearts[i] = coopHUD.getHeartSprite(heart_type,overlay)
            end
        end
    end
    if coopHUD.players[player_no].has_twin then
        local twin_player = temp_player:GetOtherTwin()
        local twin_temp_total_hearts = math.ceil((temp_player:GetEffectiveMaxHearts() + temp_player:GetSoulHearts())/2)
        if coopHUD.players[player_no].twin.total_hearts ~= twin_temp_total_hearts then
            coopHUD.players[player_no].twin.total_hearts = twin_temp_total_hearts
        end
        for i=coopHUD.players[player_no].max_health_cap,0,-1 do
            local heart_type,overlay = coopHUD.getHeartType(twin_player,i)
            if (coopHUD.players[player_no].heart_types[i] == nil) or
                    (coopHUD.players[player_no].twin.heart_types[i].heart_type ~= heart_type) or
                    (coopHUD.players[player_no].twin.heart_types[i].overlay ~= overlay) then
                coopHUD.players[player_no].twin.heart_types[i].heart_type = heart_type
                coopHUD.players[player_no].twin.heart_types[i].overlay = overlay
                coopHUD.players[player_no].twin.sprites.hearts[i] = coopHUD.getHeartSprite(heart_type,overlay)
            end
        end
    end
end
function coopHUD.updateExtraLives(player_no)
    local temp_player = Isaac.GetPlayer(coopHUD.players[player_no].game_index)
    if coopHUD.players[player_no].extra_lives ~= temp_player:GetExtraLives() then
        coopHUD.players[player_no].extra_lives = temp_player:GetExtraLives()
        coopHUD.players[player_no].has_guppy = temp_player:HasCollectible(212)
    end
    if coopHUD.players[player_no].has_twin then
        local twin_player = temp_player:GetOtherTwin()
        if coopHUD.players[player_no].twin.extra_lives ~= twin_player:GetExtraLives() then
            coopHUD.players[player_no].twin.extra_lives = twin_player:GetExtraLives()
            coopHUD.players[player_no].twin.has_guppy = twin_player:HasCollectible(212)
        end
    end
end
function coopHUD.updateBethanyCharge(player_no)
    if coopHUD.players[player_no].type == 36 then
        local temp_player = Isaac.GetPlayer(player_no)
        if coopHUD.players[player_no].bethany_charge ~= temp_player:GetBloodCharge() then
            coopHUD.players[player_no].bethany_charge = temp_player:GetBloodCharge()
            coopHUD.players[player_no].first_active_charge = coopHUD.getChargeSprites(temp_player,0)
        end
    end
    if coopHUD.players[player_no].type == 18 then
        local temp_player = Isaac.GetPlayer(player_no)
        if coopHUD.players[player_no].bethany_charge ~= temp_player:GetSoulCharge() then
            coopHUD.players[player_no].bethany_charge = temp_player:GetSoulCharge()
            coopHUD.players[player_no].first_active_charge = coopHUD.getChargeSprites(temp_player,0)
        end
    end
end
function coopHUD.updatePoopMana(player_no)
    local force_update = false
    if coopHUD.players[player_no].type == PlayerType.PLAYER_XXX_B  then
        local player = Isaac.GetPlayer(player_no)
        if coopHUD.players[player_no].poop_mana ~= player:GetPoopMana() then
            force_update = true
            coopHUD.players[player_no].poop_mana = player:GetPoopMana()
        end
        if coopHUD.players[player_no].max_poop_mana ~= 9 or
                coopHUD.players[player_no].max_poop_mana ~= 9 then
            coopHUD.players[player_no].max_poop_mana = 9
            if coopHUD.players[player_no].has_birthright then
                coopHUD.players[player_no].max_poop_mana = 29
            end
        end
        if coopHUD.players[player_no].poops[0] ~= player:GetPoopSpell(0) or force_update then
            coopHUD.players[player_no].poops = coopHUD.getPoopSpellTable(player_no)
            coopHUD.players[player_no].sprites.poops = coopHUD.getPoopSpriteTable(player)
        end
    end
end
function coopHUD.updateAnchors()
    local offset = 0
    if SHExists then
        offset = ScreenHelper.GetOffset()
    end
    offset = offset +  Options.HUDOffset * 10
    if coopHUD.anchors.top_left ~= Vector.Zero + Vector(offset * 2, offset * 1.2) then
        coopHUD.anchors.top_left = Vector.Zero + Vector(offset * 2, offset * 1.2)
    end
    if coopHUD.anchors.bot_left ~= Vector(0,Isaac.GetScreenHeight()) + Vector(offset * 2.2, -offset * 1.6) then
        coopHUD.anchors.bot_left = Vector(0,Isaac.GetScreenHeight()) + Vector(offset * 2.2, -offset * 1.6)
    end
    if coopHUD.anchors.top_right ~= Vector(coopHUD.getMinimapOffset().X,0) + Vector(-offset * 2.2, offset * 1.2) then
        coopHUD.anchors.top_right = Vector(coopHUD.getMinimapOffset().X,0) + Vector(-offset * 2.2, offset * 1.2)
    end
    if coopHUD.anchors.bot_right ~= Vector(Isaac.GetScreenWidth(),Isaac.GetScreenHeight()) + Vector(-offset * 2.2, -offset * 1.6) then
        coopHUD.anchors.bot_right = Vector(Isaac.GetScreenWidth(),Isaac.GetScreenHeight()) + Vector(-offset * 2.2, -offset * 1.6)
    end
end
function coopHUD.updateControllerIndex()
    --[[
    Function updates controller indexes in coopHUD player tables
    ]]
    for _,player in pairs(coopHUD.players) do
        temp_player = Isaac.GetPlayer(player.game_index)
        if temp_player:GetPlayerType() == 20 then -- prevents from updating index if player is Essau
            next(coopHUD.players) -- skips iterator
        else
            if player.controller_index ~= temp_player.ControllerIndex then
                player.controller_index = temp_player.ControllerIndex -- updates controller index
            end
        end
    end
end
function coopHUD.updatePlayerType(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    if coopHUD.players[player_no].type ~= temp_player:GetPlayerType() then
        coopHUD.players[player_no].type = temp_player:GetPlayerType()
        coopHUD.players[player_no].sprites.player_head = coopHUD.getPlayerHeadSprite(coopHUD.players[player_no].type)
    end
end
-- _____

-- HUD_table
function coopHUD.initHudTables()
    coopHUD.HUD_table.sprites = coopHUD.getHUDSprites()
    coopHUD.HUD_table.floor_info = coopHUD.getStreakSprite()
    coopHUD.HUD_table.streak = coopHUD.getStreakSprite()
    coopHUD.HUD_table.streak_sec_color = KColor(0, 0, 0, 1, 0, 0, 0)
    coopHUD.HUD_table.coin_no = 0
    coopHUD.HUD_table.bomb_no = 0
    coopHUD.HUD_table.key_no = 0
end
function coopHUD.updateItems()
    local player = Isaac.GetPlayer(0)
    if coopHUD.HUD_table.coin_no ~= player:GetNumCoins() then
        coopHUD.HUD_table.coin_no = player:GetNumCoins()
    end
    if coopHUD.HUD_table.bomb_no ~= player:GetNumBombs() then
        coopHUD.HUD_table.bomb_no = player:GetNumBombs()
    end
    if coopHUD.HUD_table.key_no ~= player:GetNumKeys() then
        coopHUD.HUD_table.key_no = player:GetNumKeys()
    end
end
function coopHUD.updateTables()
    coopHUD.updateAnchors()
    -- charges update constantly due to items such as spinning wheel
    for i,_ in pairs(coopHUD.players) do
        --coopHUD.updateCharge(i)
    end
    --
    if ((Isaac.GetFrameCount()/30)%60)%4 == 0 then -- updates players every 4 seconds
        coopHUD.updateControllerIndex()
        for i,_ in pairs(coopHUD.players) do
            --coopHUD.signals.on_active_update = i
        end
        coopHUD.signals.on_item_update = true
    end
    if coopHUD.signals.on_active_update then
        coopHUD.updateActives(coopHUD.signals.on_active_update)
        coopHUD.signals.on_active_update = nil
    end
    if coopHUD.signals.on_heart_update then
        coopHUD.updateHearts(coopHUD.signals.on_heart_update)
        coopHUD.updateBethanyCharge(coopHUD.signals.on_heart_update)
        coopHUD.signals.on_heart_update = nil
    end
    if coopHUD.signals.on_item_update then
        coopHUD.updateItems()
        coopHUD.signals.on_item_update = nil
    end
    if coopHUD.signals.on_trinket_update then
        coopHUD.updateTrinkets(coopHUD.signals.on_trinket_update)
        coopHUD.signals.on_trinket_update = nil
    end
    if coopHUD.signals.on_pockets_update then
        coopHUD.updatePockets(coopHUD.signals.on_pockets_update)
        coopHUD.signals.on_pockets_update = nil
    end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.updateTables)
-- Modified  Version of POST_ITEM_PICKUP from pedroff_1 - https://steamcommunity.com/sharedfiles/filedetails/?id=2577953432&searchtext=callback
function PostItemPickup (_,player)
    local item_queue = player.QueuedItem
    if item_queue and item_queue.Item then
        local list = PostItemPickupFunctions
        if list[item_queue.Item.ID] then
            for i,v in pairs(list[item_queue.Item.ID]) do
                v(_,player)
            end
        end
        list = PostItemPickupFunctions[-1]
        if list then
            for i,v in pairs(list) do
                v(_, player, item_queue.Item.ID)
            end
        end
        player:FlushQueueItem()
        --____ Flashes triggers streak text with picked up name
        if langAPI then
            coopHUD.HUD_table.streak:ReplaceSpritesheet(1,"/gfx/ui/blank.png")
            coopHUD.HUD_table.streak:LoadGraphics()
            coopHUD.streak_main_line = langAPI.getItemName(string.sub(item_queue.Item.Name, 2))
            coopHUD.streak_sec_line = langAPI.getItemName(string.sub(item_queue.Item.Description, 2))
            coopHUD.HUD_table.streak_sec_color = KColor(1,1,1,1)
            coopHUD.HUD_table.streak_sec_line_font:Load("font/pftempestasevencondensed.fnt")
        end
        --_____ Updates actives of player
        local player_index = coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)
        if item_queue.Item.Type == ItemType.ITEM_ACTIVE then
            coopHUD.updateActives(player_index)
        elseif item_queue.Item.Type == ItemType.ITEM_TRINKET then
            coopHUD.updateTrinkets(player_index)
        else
        end
        coopHUD.updateExtraLives(player_index) -- triggers extra lives update
        coopHUD.updateItems() -- triggers update items when picked up item - Shops
        coopHUD.updateHearts(player_index) -- triggers update hearts if item picked up - Devil deals
    end
end
  coopHUD:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostItemPickup)
  local addCallbackOld = Isaac.AddCallback
  ModCallbacks.MC_POST_ITEM_PICKUP = 271
  PostItemPickupFunctions = PostItemPickupFunctions or {}
function  addCallbackNew(mod,callback,func,arg1,arg2,arg3,arg4)
    if callback == ModCallbacks.MC_POST_ITEM_PICKUP then
        arg1 = arg1 or -1
        PostItemPickupFunctions[arg1] = PostItemPickupFunctions[arg1] or {}
        PostItemPickupFunctions[arg1][tostring(func)]= func
    else
        addCallbackOld(mod,callback,func,arg1,arg2,arg3,arg4)
    end
  end
  Isaac.AddCallback = addCallbackNew
---- End of standalone module
