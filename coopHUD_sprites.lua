-- Sprites get function
function coopHUD.getActiveItemSprite(player,slot)
    local overlay = ''
    local active_item = player:GetActiveItem(slot)
    if active_item == 0 then return false end
    local this_sprite = Sprite() -- replaced
    this_sprite:Load(coopHUD.GLOBALS.item_anim_path,true)
    local item_sprite = Isaac.GetItemConfig():GetCollectible(active_item).GfxFileName
    -- Custom sprites set - jars etc.
    if active_item == CollectibleType.COLLECTIBLE_THE_JAR then -- the jar
        item_sprite = "gfx/characters/costumes/costume_rebirth_90_thejar.png"
    elseif active_item == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then -- jar of flies
        item_sprite = "gfx/characters/costumes/costume_434_jarofflies.png"
    elseif active_item == CollectibleType.COLLECTIBLE_JAR_OF_WISPS then -- jar of wisp
        item_sprite = "gfx/ui/hud_jarofwisps.png"
    elseif active_item == CollectibleType.COLLECTIBLE_EVERYTHING_JAR then -- everything jar
        item_sprite = "gfx/ui/hud_everythingjar.png"
    elseif active_item == CollectibleType.COLLECTIBLE_FLIP and player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
        -- Fixme: Flip weird sprite (too much white :D) when lazarus b
        item_sprite = 'gfx/ui/ui_flip_coop.png'
        this_sprite:ReplaceSpritesheet(0, item_sprite)
        this_sprite:ReplaceSpritesheet(1, item_sprite)
        this_sprite:ReplaceSpritesheet(2, item_sprite)
    end
    -- Urn of Souls - sprite set
    if active_item == CollectibleType.COLLECTIBLE_URN_OF_SOULS then
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
    if active_item == CollectibleType.COLLECTIBLE_THE_JAR or active_item == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then --
        local frame = 0
        if active_item == CollectibleType.COLLECTIBLE_THE_JAR then frame = math.ceil(player:GetJarHearts()/2) end -- gets no of hearts in jar
        if active_item == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then frame = player:GetJarFlies() end --gets no of flies in jar of flies
        this_sprite:SetFrame("Jar", frame)
    end
    -- Hold - charge set
    if active_item == CollectibleType.COLLECTIBLE_HOLD then
        -- SKELETON
        this_sprite:ReplaceSpritesheet(3,'gfx/ui/ui_poops.png')
        local hold_spell = 0
        if coopHUD.players[coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)] and
                -- prevents from error when not everything loaded
                coopHUD.players[coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)].hold_spell then
            hold_spell = coopHUD.players[coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)].hold_spell
        end
        this_sprite:SetFrame('Hold',hold_spell)
    end
    -- Everything Jar - charges set
    if active_item == CollectibleType.COLLECTIBLE_EVERYTHING_JAR  then
        fi_charge = player:GetActiveCharge()
        this_sprite:SetFrame("EverythingJar", fi_charge +1)
    end
    -- Jar of wisp - charges set
    if active_item == CollectibleType.COLLECTIBLE_JAR_OF_WISPS and coopHUD.jar_of_wisp_charge ~= nil then
        local wisp_charge =  0
        if item_charge == 0 then -- checks id item has any charges
            wisp_charge = 0 -- set frame to unloaded
        elseif player:NeedsCharge(slot) == false or player:GetActiveCharge(slot) >= item_charge then
            -- checks if item dont needs charges or item is overloaded
            wisp_charge = 15 -- set frame to loaded
        else
            wisp_charge = 0 -- set frame to unloaded
        end
        this_sprite:SetFrame('WispJar',coopHUD.jar_of_wisp_charge + wisp_charge) -- sets proper frame
    end
    -- Urn of soul
    -- For this moment can only show when urn is open/closed no api function
    -- FIXME: Urn of soul charge: wait till api is fixed
    if active_item == CollectibleType.COLLECTIBLE_URN_OF_SOULS then
        -- sets frame
        local tempEffects = player:GetEffects()
        local urn_state = tempEffects:GetCollectibleEffectNum(640) -- gets effect of item 0-closed urn/1- opened
        local state = 0  -- closed urn frame no
        if urn_state ~= 0 then -- checks if urn is open
            state = 22 -- opened urn frame no
        end
        this_sprite:SetFrame("SoulUrn", state)
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)  or player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        -- checks if player has virtuoses or birthright
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and active_item ~= CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES then -- sets virtuoses sprite
            item_sprite = 'gfx/ui/hud_bookofvirtues.png'
            this_sprite:ReplaceSpritesheet(3, item_sprite)
            this_sprite:ReplaceSpritesheet(4, item_sprite)

        end
        if player:GetPlayerType() == PlayerType.PLAYER_JUDAS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)  then -- if judas and has birthrignt
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and active_item ~= CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES then
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
    local active_item = player:GetActiveItem(slot)
    if active_item == 0 then return false end
    local item_charge = Isaac.GetItemConfig():GetCollectible(active_item).MaxCharges
    if item_charge == 0 then return false end
    -- Normal and battery charge
    local charges = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
    local step = math.floor((charges/(item_charge *2))*46)
    sprites.charge:Load(coopHUD.GLOBALS.charge_anim_path,true)
    sprites.charge:SetFrame('ChargeBar',step)
    -- Overlay sprite
    sprites.overlay:Load(coopHUD.GLOBALS.charge_anim_path,true)
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
        sprites.beth_charge:Load(coopHUD.GLOBALS.charge_anim_path,true)
        sprites.beth_charge.Color = color
        step = step +  math.floor((beth_charge/(item_charge *2))*46) + 1
        sprites.beth_charge:SetFrame('ChargeBar',step)
    else
        sprites.beth_charge = false
    end
    return sprites
end
function coopHUD.getTrinketSprite(player, trinket_pos)
    local trinket_id = player:GetTrinket(trinket_pos)
    if trinket_id == 0 then return false end
    local sprite = Sprite()
    sprite:Load(coopHUD.GLOBALS.item_anim_path,true)
    local item_sprite = Isaac.GetItemConfig():GetTrinket(trinket_id).GfxFileName
    sprite:ReplaceSpritesheet(0, item_sprite) -- item layer
    sprite:ReplaceSpritesheet(2, item_sprite) -- shadow layer
    sprite:LoadGraphics()
    sprite:SetFrame("Idle", 0)
    return sprite
end
function coopHUD.getPocketItemSprite(player,slot)
    -- cards/runes/
    local pocket_sprite = Sprite()
    local pocket = coopHUD.getPocketID(player,slot)
    local pocket_type = pocket[2]
    local pocket_id = pocket[1]
    if pocket_type == 1 then -- Card
        pocket_sprite:Load(coopHUD.GLOBALS.card_anim_path,true)
        pocket_sprite:SetFrame("CardFronts", pocket_id) -- sets card frame
    elseif pocket_type == 2 then -- Pill
        if pocket_id > 2048 then pocket_id = pocket_id - 2048 end -- check if its horse pill and change id to normal
        pocket_sprite:Load(coopHUD.GLOBALS.pill_anim_path,true)
        pocket_sprite:SetFrame("Pills", pocket_id) --sets frame to pills with correct id
        return pocket_sprite
    elseif pocket_type == 3 then
        pocket_sprite = coopHUD.getActiveItemSprite(player,2)
    else
        pocket_sprite = false
    end
    return pocket_sprite
end
function coopHUD.getHeartSprite(heart_type,overlay)
    if heart_type ~= 'None' then
        local sprite = Sprite()
        sprite:Load(coopHUD.GLOBALS.hearts_anim_path,true)
        sprite:SetFrame(heart_type, 0)
        if overlay ~= 'None'  then
            if overlay ~= 'GoldWhiteOverlay' then
                sprite:SetOverlayFrame (overlay, 0 )
            else
                sprite:ReplaceSpritesheet(0,"gfx/ui/ui_hearts_gold_coop.png") -- replaces png file to get
                sprite:SetOverlayFrame ('WhiteHeartOverlay', 0 )
                sprite:LoadGraphics()
            end

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
    -- Sets increased heatlh cap when playing Maggy with Birthright
    if player:GetPlayerType() == PlayerType.PLAYER_MAGDALENA and -- checks if player is Maggy
        player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        max_health_cap = 18
    end
    for counter=0,max_health_cap,1 do
        heart_type,overlay = coopHUD.getHeartType(player,counter)
        heart_sprites[counter] = coopHUD.getHeartSprite(heart_type,overlay)
    end
    return heart_sprites
end
function coopHUD.getPoopSprite(player,i)
    local spell_type
    local layer_name = 'IdleSmall'
    spell_type = player:GetPoopSpell(i)
    if i == 0 then layer_name = 'Idle' end
    if spell_type ~= 0 then
        local sprite = Sprite()
        sprite:Load(coopHUD.GLOBALS.poop_anim_path,true)
        sprite:SetFrame(layer_name,spell_type)
        if i >= player:GetPoopMana() then
            local col = Color(1,1,1,1)
            col:SetColorize(1, 1, 1, 1)
            sprite.Color = Color(0.3,0.3,0.3,0.3)
        end
        return sprite
    else
        return nil
    end
end
function coopHUD.getPoopSpriteTable(player)
    local poop_table = {}
    for i=0,PoopSpellType.SPELL_QUEUE_SIZE-1,1 do
        poop_table[i] = coopHUD.getPoopSprite(player,i)
    end
    return poop_table
end
function coopHUD.getPlayerHeadSprite(player_type)
    if player_type == 40 then player_type = 36 end
    if 0 <= player_type and player_type <= 37 then
        local sprite = Sprite()
        sprite:Load(coopHUD.GLOBALS.player_head_anim_path,true)
        sprite:SetFrame('Main',player_type+1)
        sprite:ReplaceSpritesheet(1, "/gfx/ui/blank.png")
        sprite:LoadGraphics()
        return sprite
    else
        return false
    end
end
function coopHUD.getHUDSprites()
    local player = Isaac.GetPlayer(0)
    --Items font
    local item_font = Font()
    item_font:Load("font/pftempestasevencondensed.fnt")
    --
    local timer_font = Font()
    timer_font:Load("font/teammeatfont10.fnt")
     --
    local streak_sec_line_font = Font()
    streak_sec_line_font:Load("font/teammeatfont10.fnt")
    -- Coin sprite
    local coin_sprite= Sprite()
    coin_sprite:Load(coopHUD.GLOBALS.hud_el_anim_path,true)
    coin_sprite:SetFrame('Idle', 0)
    -- Bomb sprite
    -- TODO: GigaBomb integration
    -- TODO: T.??? PoopSpell integration
    local bomb_sprite = Sprite()
    bomb_sprite:Load(coopHUD.GLOBALS.hud_el_anim_path,true)
    bomb_sprite:SetFrame('Idle',2)
    if player and player:HasGoldenBomb()  then bomb_sprite:SetFrame('Idle',6) end
    if player and player:GetNumGigaBombs() > 0 then bomb_sprite:SetFrame('Idle',14) end
    -- Key sprite
    local key_sprite = Sprite()
    key_sprite:Load(coopHUD.GLOBALS.hud_el_anim_path,true)
    key_sprite:SetFrame('Idle',1)
    if player and player:HasGoldenKey()  then key_sprite:SetFrame('Idle',3 ) end
    return {['item_font']=item_font,
            ['timer_font']=timer_font,
            ['streak_sec_line_font']=streak_sec_line_font,
            ['coin_sprite']=coin_sprite,
            ['bomb_sprite']=bomb_sprite,
            ['key_sprite']=key_sprite}
end
function coopHUD.getStreakSprite()
    sprite = Sprite()
    sprite:Load(coopHUD.GLOBALS.streak_anim_path,true)
    return sprite
end
--___ Help functions
-- Hearts
function coopHUD.getHeartType(player,heart_pos)
    ---- Modified function from HUD_API from NeatPotato mod
    local player_type = player:GetPlayerType()
    local heart_type = 'None'
    local eternal = false
    local golden = false
    local remain_souls = 0
    local overlay = 'None'
    if player_type == 10 or player_type == 31 then
        if heart_pos == 0 then -- only returns for first pos
            -- checks if Holy Mantle is loaded
            if player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE) ~= 0 then
                heart_type = 'HolyMantle'
            end
        end
    elseif Game():GetLevel():GetCurses() == 8 then -- checks curse of the unknown
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
        -- <Normal hearts>
        if player:GetMaxHearts()/2 > heart_pos then -- red heart type
            -- <Keeper Hearts>
            if player_type == 14 or player_type == 33 then
                golden = false
                if player:GetHearts()-(heart_pos*2) > 1 then
                    heart_type = "CoinHeartFull"
                elseif player:GetHearts()-(heart_pos*2) == 1 then
                    heart_type = "CoinHeartHalf"
                else
                    heart_type = "CoinEmpty"
                end
            -- </Keeper Hearts>
            else
                -- <Red Hearts Hearts>
                if player:GetHearts()-(heart_pos*2) > 1 then
                    heart_type = "RedHeartFull"
                elseif player:GetHearts()-(heart_pos*2) == 1 then
                    heart_type = "RedHeartHalf"
                else
                    heart_type = "EmptyHeart"
                end
                -- </Red Hearts Hearts>
            end
            -- <Eternal check>
            if player:GetEternalHearts() > 0 and -- checks if any eternal hearts
                    heart_pos+1 == player:GetMaxHearts()/2 then -- checks if heart_pos is last pos
                eternal = true
            end
        -- </Normal hearts>
        -- <BLue/Black hearts>
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
        -- </BLue/Black hearts>
        -- <RottenHearts hearts>
        if  player:GetRottenHearts() > 0 then
            local non_rotten_reds = player:GetHearts()/2 - player:GetRottenHearts()
            if  heart_type == "RedHeartFull" then
                if heart_pos >= non_rotten_reds then
                    heart_type = "RottenHeartFull"
                end
            elseif heart_type == "BoneHeartFull" then
                local overloader_reds = player:GetHearts()+remain_souls-(heart_pos*2)
                if overloader_reds - player:GetRottenHearts()*2 <= 0 then
                    heart_type = "RottenBoneHeartFull"
                end
            end
        end
        -- </RottenHearts hearts>
        -- <Broken heart type>  - https://bindingofisaacrebirth.fandom.com/wiki/Health#Broken_Hearts
        if player:GetBrokenHearts() > 0 then
            if heart_pos > total_hearts-1 and total_hearts + player:GetBrokenHearts() > heart_pos then
                if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or -- Check if Keeper
                        player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
                    heart_type = 'BrokenCoinHeart'
                else
                    heart_type = 'BrokenHeart'
                end
            end
        end
        -- </Broken heart type>
        -- <Overlays>
        if eternal and golden then
            overlay = "GoldWhiteOverlay"
        elseif eternal then
            overlay = "WhiteHeartOverlay"
        elseif golden then
            overlay = "GoldHeartOverlay"
        else
            overlay = 'None'
        end
    end
    return heart_type,overlay
end
function coopHUD.getHeartTypeTable(player)
    local max_health_cap = 12
    local heart_type,overlay = ''
    local heart_types = {}
    -- Sets increased heatlh cap when playing Maggy with Birthright
    if player:GetPlayerType() == PlayerType.PLAYER_MAGDALENA and -- checks if player is Maggy
        player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        max_health_cap = 18
    end
    for counter=0,max_health_cap,1 do
        heart_type,overlay = coopHUD.getHeartType(player,counter)
        heart_types[counter] = {
            heart_type = heart_type,
            overlay = overlay,
        }
    end
    return heart_types
end
-- Pockets
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
function coopHUD.getMainPocketDesc(player)
    local name = 'Error'
    local desc = nil
    if langAPI ~= nil then
        if player:GetPill(0) < 1 and player:GetCard(0) < 1 then
            if player:GetActiveItem(2) > 0 then
                name = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(2)).Name
            elseif player:GetActiveItem(3) > 0 then
                name = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(3)).Name
            else
                return false
            end
            name = string.sub(name, 2) --  get rid of # on front of
            name = langAPI.getItemName(name)
        end
        if player:GetCard(0) > 0 then
            name = Isaac.GetItemConfig():GetCard(player:GetCard(0)).Name
            name = string.sub(name, 2) --  get rid of # on front of
            name = langAPI.getPocketName(name)
            --
            desc = Isaac.GetItemConfig():GetCard(player:GetCard(0)).Description
            desc = string.sub(desc, 2) --  get rid of # on front of
            desc = langAPI.getPocketName(desc)
        elseif player:GetPill(0) > 0 then
            name = "???" .. " "
            local pill = player:GetPill(0)
            local item_pool = Game():GetItemPool()
            if item_pool:IsPillIdentified (pill) then
                local pill_effect = item_pool:GetPillEffect(pill,player)
                name = Isaac.GetItemConfig():GetPillEffect(pill_effect).Name
                name = string.sub(name, 2) --  get rid of # on front of
                name = langAPI.getPocketName(name)
            end
        end
    else
        name = 'Error! - langAPI not installed'
    end
    return {['name']=name,['desc']=desc}
end
function coopHUD.getPoopSpellTable(player_no)
    local poop_table = {}
    for i=0,PoopSpellType.SPELL_QUEUE_SIZE,1 do
        poop_table[i] = Isaac.GetPlayer(player_no):GetPoopSpell(i)
    end
    return poop_table
end
-- Other
function coopHUD.getMinimapOffset()
    local minimap_offset = Vector(Isaac.GetScreenWidth(),0)
    if MinimapAPI ~= nil then
        -- Modified function from minimAPI by Wolfsauge
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
-- TODO: T.FOrgotten - weird heart render
-- TODO: Jaccob/Essau - tint non used sprites -