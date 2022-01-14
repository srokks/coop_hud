---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by srokks.
--- DateTime: 04/01/2022 16:20
---
coopHUD.jar_of_wisp_charge = nil -- Global value of jar_of_wisp_charge
function coopHUD.updateCollectible(player_no)
    local player = Isaac.GetPlayer(player_no)
    -- Update if player has birthright
    if not coopHUD.players[player_no].has_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        coopHUD.players[player_no].has_birthright = true
    end
    -- Update if player has guppy's collar
    if not coopHUD.players[player_no].has_guppy and player:HasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR) then
        coopHUD.players[player_no].has_guppy = true
    end
end
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
        extra_lives = temp_player:GetExtraLives(),
        bethany_charge = nil, -- inits charge for Bethany
        heart_types = coopHUD.getHeartTypeTable(temp_player),
        sub_heart_types = {},
        wisp_jar_use = 0, -- holds info about used jar of wisp FIXME:
        total_hearts = math.ceil((temp_player:GetEffectiveMaxHearts() + temp_player:GetSoulHearts())/2),
        max_health_cap = 12,
        --- T ??? - specifics
        poop_mana = 0,
        max_poop_mana = 0,
        poops = coopHUD.getPoopSpellTable(player_no),
        ---
        type = temp_player:GetPlayerType(),
        ---
        has_sub = false,
        has_birthright = false,
        has_guppy = false,
        ---
        sprites = {
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
            poops = coopHUD.getPoopSpriteTable(temp_player),
        },
    }
    -- Bethany/T.Bethany check
    if player_table.type == 18 or player_table.type == 36 then
        if player_table.type == 18 then
            player_table.bethany_charge = temp_player:GetSoulCharge()
        else
            player_table.bethany_charge = temp_player:GetBloodCharge()
        end
    end
    -- Forgotten/Soul check
    if  player_table.type == 16 or player_table.type == 17 then
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
        coopHUD.players[player_no].sprites.first_pocket_charge = coopHUD.getChargeSprites(temp_player,2)
        coopHUD.players[player_no].first_pocket = coopHUD.getPocketID(temp_player,0)
        coopHUD.players[player_no].sprites.first_pocket = coopHUD.getPocketItemSprite(temp_player,0)
    end
end
function coopHUD.updateActives(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
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
        coopHUD.players[player_no].sprites.first_active_charge = coopHUD.getChargeSprites(temp_player,0)
        coopHUD.players[player_no].sprites.second_active = coopHUD.getActiveItemSprite(temp_player,1)
        coopHUD.players[player_no].sprites.second_active_charge = coopHUD.getChargeSprites(temp_player,1)
    end
    if coopHUD.players[player_no].first_active_charge ~= temp_player:GetActiveCharge(0) or forceUpdateActives then
        coopHUD.players[player_no].first_active_charge = temp_player:GetActiveCharge(0)
        coopHUD.players[player_no].sprites.first_active = coopHUD.getActiveItemSprite(temp_player,0)
        coopHUD.players[player_no].sprites.first_active_charge = coopHUD.getChargeSprites(temp_player,0)
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
    local temp_player = Isaac.GetPlayer(player_no)
    local max_health_cap = 12
    local sub_player = nil
    local temp_total_hearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts())/2)

    if coopHUD.players[player_no].total_hearts ~= temp_total_hearts then
        coopHUD.players[player_no].total_hearts = temp_total_hearts
        if coopHUD.players[player_no].max_health_cap ~= 18 and -- prevent from changing after birthright picked
            coopHUD.players[player_no].type == PlayerType.PLAYER_MAGDALENA and -- checks if payer is Maggy
            player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            coopHUD.players[player_no].max_health_cap = 18
        end
    end
    if coopHUD.players[player_no].has_sub then
        sub_player = player:GetSubPlayer()
        max_health_cap = 6
    end
    for i=coopHUD.players[player_no].max_health_cap,0,-1 do
        local heart_type,overlay = coopHUD.getHeartType(player,i)
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
                print('zmiana serduszek')
                local heart_type,overlay = coopHUD.getHeartType(sub_player,i)
                coopHUD.players[player_no].sub_heart_types[i].heart_type = heart_type
                coopHUD.players[player_no].sub_heart_types[i].overlay = overlay
                coopHUD.players[player_no].sprites.sub_hearts[i] = coopHUD.getHeartSprite(heart_type,overlay)
            end
        end
    end
end
function coopHUD.updateExtraLives(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    if coopHUD.players[player_no].extra_lives ~= temp_player:GetExtraLives() then
        coopHUD.players[player_no].extra_lives = temp_player:GetExtraLives()
        has_guppy = temp_player:HasCollectible(212)
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
                coopHUD.players[player_no].max_poop_mana ~= 9then
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
function coopHUD.getPoopSpellTable(player_no)
    local poop_table = {}
    for i=0,PoopSpellType.SPELL_QUEUE_SIZE,1 do
        poop_table[i] = Isaac.GetPlayer(player_no):GetPoopSpell(i)
    end
    return poop_table
end
function coopHUD.forceUpdateActives()
    forceUpdateActives = true
end
function coopHUD.updateAnchors()
    if coopHUD.anchors.top_left ~= ScreenHelper.GetScreenTopLeft() then
        coopHUD.anchors.top_left = ScreenHelper.GetScreenTopLeft()
    end
    if coopHUD.anchors.bot_left ~= ScreenHelper.GetScreenBottomLeft() then
        coopHUD.anchors.bot_left = ScreenHelper.GetScreenBottomLeft()
    end
    if coopHUD.anchors.top_right ~= ScreenHelper.GetScreenTopRight() then
        coopHUD.anchors. top_right = Vector(coopHUD.getMinimapOffset().X,ScreenHelper.GetScreenTopRight().Y)
    end
    if coopHUD.anchors.bot_right ~= ScreenHelper.GetScreenBottomRight() then
        coopHUD.anchors.bot_right = ScreenHelper.GetScreenBottomRight()
    end
end
function coopHUD.getMinimapOffset()
    local minimap_offset = Vector(Isaac.GetScreenWidth(),0)
    if MinimapAPI ~= nil then
        print('nie ma')
        -- Modified function from minimap_api by Wolfsauge
        --TODO: curse of the unknown integration
        local screen_size = Vector(Isaac.GetScreenWidth(),0)
        local is_large = MinimapAPI:IsLarge()
        if not is_large and MinimapAPI:GetConfig("DisplayMode") == 2 then -- BOUNDED MAP
            minimap_offset = Vector(screen_size.X - MinimapAPI:GetConfig("MapFrameWidth") - MinimapAPI:GetConfig("PositionX") - 0,2)
        elseif not is_large and MinimapAPI:GetConfig("DisplayMode") == 4 then -- NO MAP
            minimap_offset = Vector(screen_size.X - 4,2)
        else -- LARGE
            local minx = screen_size.X
            for i,v in ipairs(MinimapAPI:GetLevel()) do
                if v ~= nil then
                    if v:GetDisplayFlags() > 0 then
                        minx = math.min(minx, v.RenderOffset.X)
                    end
                end

            end
            minimap_offset = Vector(minx-4,2) -- Small
        end
        if MinimapAPI:GetConfig("Disable") or MinimapAPI.Disable then minimap_offset = Vector(screen_size.X - 4,2)  end
        local r = MinimapAPI:GetCurrentRoom()
        if MinimapAPI:GetConfig("HideInCombat") == 2 then
            if not r:IsClear() and r:GetType() == RoomType.ROOM_BOSS then
                minimap_offset = Vector(screen_size.X - 0,2)
            end
        elseif MinimapAPI:GetConfig("HideInCombat") == 3 then
            if not r:IsClear() then
                minimap_offset = Vector(screen_size.X - 0,2)
            end
        end
        if MinimapAPI:GetConfig('ShowLevelFlags') then
            print(MinimapAPI:GetConfig('ShowLevelFlags'))
            MinimapAPI.Config.ShowLevelFlags = false
        end
    end
    return minimap_offset
end

coopHUD:AddCallback(ModCallbacks.MC_USE_ITEM, coopHUD.forceUpdateActives)