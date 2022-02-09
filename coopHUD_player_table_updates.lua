local SHExists, ScreenHelper = pcall(require, "scripts.screenhelper")
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
function coopHUD.initPlayer(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
    local player_table = {}
    player_table = {
        --
        controller_index = temp_player.ControllerIndex,
        -- Items
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
        -- Collectibles
        collectibles = {},
        -- Hearts
        heart_types = coopHUD.getHeartTypeTable(temp_player),
        sub_heart_types = {},
        total_hearts = math.ceil((temp_player:GetEffectiveMaxHearts() + temp_player:GetSoulHearts())/2),
        max_health_cap = 12,
        extra_lives = temp_player:GetExtraLives(),
        -- Charges
        bethany_charge = nil, -- inits charge for Bethany
        wisp_jar_use = 0, -- holds info about used jar of wisp
        -- Stats
        
        --- T ??? - specifics
        poop_mana = 0, -- current mana (int)
        max_poop_mana = 0, -- max cap of mana that player holds (int)
        poops = nil, -- table of
        hold_spell = nil, -- current spell stashed in hold (int)
        ---
        type = temp_player:GetPlayerType(),
        name = coopHUD.players_config.small[player_no].name,
        ---
        has_sub = false,
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
    if player_table.type == PlayerType.PLAYER_XXX_B then -- T. ??? check
        player_table.poops = coopHUD.getPoopSpellTable(player_no)
        player_table.sprites.poops = coopHUD.getPoopSpriteTable(temp_player)
        player_table.poop_mana = temp_player:GetPoopMana()
        player_table.max_poop_mana = 9
    end
    return player_table
end
function coopHUD.updatePockets(player_no)
    local temp_player = Isaac.GetPlayer(player_no)
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
    if coopHUD.players[player_no].pocket_desc.name ~= coopHUD.getMainPocketDesc(temp_player).name then
        coopHUD.players[player_no].pocket_desc = coopHUD.getMainPocketDesc(temp_player)
        if coopHUD.getPocketID(temp_player,0)[2] == 1 then
            coopHUD.HUD_table.streak:ReplaceSpritesheet(1,"/gfx/ui/blank.png")
            coopHUD.HUD_table.streak:LoadGraphics()
            coopHUD.streak_main_line = coopHUD.players[coopHUD.signals.on_pockets_update].pocket_desc.name
            coopHUD.streak_sec_line = coopHUD.players[coopHUD.signals.on_pockets_update].pocket_desc.desc
            coopHUD.HUD_table.streak_sec_color = KColor(1,1,1,1)
            coopHUD.HUD_table.streak_sec_line_font:Load("font/pftempestasevencondensed.fnt")
        end
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
        sub_player = player:GetSubPlayer()
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
function coopHUD.getPoopSpellTable(player_no)
    local poop_table = {}
    for i=0,PoopSpellType.SPELL_QUEUE_SIZE,1 do
        poop_table[i] = Isaac.GetPlayer(player_no):GetPoopSpell(i)
    end
    return poop_table
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
function coopHUD.getMinimapOffset()
    local minimap_offset = Vector(Isaac.GetScreenWidth(),0)
    if MinimapAPI ~= nil then
        -- Modified function from minimAPI by Wolfsauge
        --TODO: curse of the unknown integration
        local screen_size = Vector(Isaac.GetScreenWidth(),0)
        local is_large = MinimapAPI:IsLarge()
        if not is_large and MinimapAPI:GetConfig("DisplayMode") == 2 then -- BOUNDED MAP
            minimap_offset = Vector(screen_size.X - MinimapAPI:GetConfig("MapFrameWidth") - MinimapAPI:GetConfig("PositionX") - 4,2)
        elseif not is_large and MinimapAPI:GetConfig("DisplayMode") == 4
                or Game():GetLevel():GetCurses() == LevelCurse.CURSE_OF_THE_LOST then
            -- NO MAP or cure of the lost active
            minimap_offset = Vector(screen_size.X - 4,2)
        else -- LARGE
            local minx = screen_size.X
            for i,v in ipairs(MinimapAPI:GetLevel()) do
                if v ~= nil then
                    if v:GetDisplayFlags() > 0 then
                        if v.RenderOffset~= nil then
                            minx = math.min(minx, v.RenderOffset.X)
                        end
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
            if r~=nil then
                if  not r:IsClear() then
                    minimap_offset = Vector(screen_size.X - 0,2)
                end
            end
        end
    end
    return minimap_offset
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
function coopHUD.updateControllerIndex()
    for num,player in pairs(coopHUD.players) do
        if player.controller_index ~= Isaac.GetPlayer(num).ControllerIndex then
            player.controller_index = Isaac.GetPlayer(num).ControllerIndex
        end
    end
end
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
    if ((Isaac.GetFrameCount()/30)%60)%4 == 0 then -- updates players every 4 seconds
        coopHUD.updateControllerIndex()
        for i,_ in pairs(coopHUD.players) do
            coopHUD.signals.on_active_update = i
        end
        coopHUD.signals.on_item_update = true
    end
    if coopHUD.signals.on_active_update then
        coopHUD.updateActives(coopHUD.signals.on_active_update)
        coopHUD.signals.on_active_update = nil
    end
    if coopHUD.signals.on_heart_update then
        coopHUD.updateHearts(coopHUD.signals.on_heart_update)
        coopHUD.signals.on_heart_update = nil
    end
    if coopHUD.signals.on_item_update then
        coopHUD.updateItems()
        coopHUD.signals.on_item_update = nil
    end
    if coopHUD.signals.on_pockets_update then
        coopHUD.updatePockets(coopHUD.signals.on_pockets_update)
        coopHUD.signals.on_pockets_update = nil
    end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.updateTables)
-- Modified  Version of POST_ITEM_PICKUP from pedroff_1 - https://steamcommunity.com/sharedfiles/filedetails/?id=2577953432&searchtext=callback
function PostItemPickup (_,player)
    local itemqueue = player.QueuedItem
    if itemqueue and itemqueue.Item then
        local list = PostItemPickupFunctions
        if list[itemqueue.Item.ID] then
            for i,v in pairs(list[itemqueue.Item.ID]) do
                v(_,player)
            end
        end
        list = PostItemPickupFunctions[-1]
        if list then
            for i,v in pairs(list) do
                v(_,player,itemqueue.Item.ID)
            end
        end
        player:FlushQueueItem()
        --____ Flashes triggers streak text with picked up name
        if langAPI then
            coopHUD.HUD_table.streak:ReplaceSpritesheet(1,"/gfx/ui/blank.png")
            coopHUD.HUD_table.streak:LoadGraphics()
            coopHUD.streak_main_line = langAPI.getItemName(string.sub(itemqueue.Item.Name,2))
            coopHUD.streak_sec_line = langAPI.getItemName(string.sub(itemqueue.Item.Description,2))
            coopHUD.HUD_table.streak_sec_color = KColor(1,1,1,1)
            coopHUD.HUD_table.streak_sec_line_font:Load("font/pftempestasevencondensed.fnt")
        end
        --_____ Updates actives of player
        local pl_index = coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)
        if itemqueue.Item.Type == ItemType.ITEM_ACTIVE then
            coopHUD.updateActives(pl_index)
        elseif itemqueue.Item.Type == ItemType.ITEM_TRINKET then
            coopHUD.updateTrinkets(pl_index)
        else
        end
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
