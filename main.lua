coopHUD = RegisterMod("Coop HUD", 1)
local json = require("json")
local MinimapAPI = require("scripts.minimapapi")
local SHExists, ScreenHelper = pcall(require, "scripts.screenhelper")

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
function coopHUD.getPocketItemSprite(player,slot)
    -- cards/runes/
    local pocketcheck = player:GetCard(slot)
    local thissprite = Sprite()

    if pocketcheck ~= 0 then
        Anim = "gfx/ui/hud_card_coop.anm2"
        thissprite:Load(Anim,true)
        thissprite:SetFrame("CardFronts", pocketcheck) -- sets card frame

        return thissprite
    else
        pocketcheck = player:GetPill(slot) -- checks if player has pill
        if pocketcheck ~= 0 then
            if pocketcheck > 2048 then pocketcheck = pocketcheck - 2048 end -- check if its horse pill and change id to normal
            Anim = "gfx/ui/hud_pills_coop.anm2"
            thissprite:Load(Anim,true)
            thissprite:SetFrame("Pills", pocketcheck) --sets frame to pills with correct id
            return thissprite
        else
            if player:GetActiveItem(2) > 0 or player:GetActiveItem(3) > 0 then
                pocketitem = true -- do wyjebania
                if player:GetActiveItem(2) > 0 then
                    thissprite = coopHUD.getActiveItemSprite(player,2)
                else
                    thissprite = coopHUD.getActiveItemSprite(player,3)
                end
                return thissprite
            else
                return false
            end
        end
    end
end
function coopHUD.getMainPocketDesc(player)
    desc = 'Error'
    if player:GetPill(0) < 1 and player:GetCard(0) < 1 then
        if REPENTANCE == false then return false end
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
        heart_type = 'CurseHeart'
        return heart_type,overlay
    else
        eternal = false
        golden = false
        local total_hearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts())/2)
        local empty_hearts = math.floor((player:GetMaxHearts()-player:GetHearts())/2)
        if empty_hearts < 0 then empty_hearts = 0 end
        if player:GetGoldenHearts() > 0 and (heart_pos-(total_hearts - (player:GetGoldenHearts()+empty_hearts))) == 0 then
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
function coopHUD.renderActiveItems(player_table)
    local anchor = player_table.anchor
    local offset = Vector(0,0)
    local off = 0
    if anchor == anchor_top_left then
        pos = Vector(anchor.X + 20,anchor.Y+16)
        off = 36
    elseif anchor == anchor_bottom_left then
        off = -36
        pos = Vector(anchor.X + 20,anchor.Y-16)
    elseif anchor == anchor_top_right then
        off = 36
        pos = Vector(coopHUD.getMinimapOffset().X,anchor.Y+16)
    elseif anchor == anchor_bottom_right then
        pos = Vector(anchor.X - 24,anchor.Y-16)
        off = -36
    end
    if player_table.first_active or player_table.second_active then
        if player_table.second_active then -- First item charge render
            player_table.second_active.Scale = Vector(0.5,0.5)
            player_table.second_active:Render(Vector(pos.X - 16,pos.Y - 8), vector_zero, vector_zero)
        end
        if player_table.se_charge then -- Second item charge render -- UGLY - can turn on
            --player_table.se_charge.Scale = Vector(0.5,0.5)
            --player_table.se_charge:Render(Vector(pos.X - 15,pos.Y - 9), vector_zero, vector_zero)
        end
        if player_table.first_active then
            player_table.first_active:Render(pos, VECTOR_ZERO, VECTOR_ZERO)
        end
        pos.X = pos.X + 17
        if player_table.fi_charge then
            player_table.fi_charge:Render(pos, VECTOR_ZERO, VECTOR_ZERO)
        end
    offset.Y = offset.Y + off

    end
    return offset
end
function coopHUD.renderTrinkets(player_table)
    local mirrored = false
    local anchor = player_table.anchor
    local off = 0
    anchor.Y = anchor.Y + player_table.first_row_offset.Y
     -- TODO: first line offset
    local trinket_offset = Vector(0,0)
    local scale = Vector(0.5,0.5)
    if anchor == anchor_top_left then
        pos = Vector(anchor.X+12,anchor.Y+ 8)
        off = 24
    elseif anchor == anchor_bottom_left then
        pos = Vector(anchor.X + 12,anchor.Y - 8)
        off = -20
    elseif anchor == anchor_top_right then
        pos = Vector(coopHUD.getMinimapOffset().X+16,anchor.Y+8)
        mirrored = true
        off = 24
    elseif anchor == anchor_bottom_right then
        pos = Vector(anchor.X - 12,anchor.Y-10)
        mirrored = true
        off = -20
    end
    if player_table.first_trinket then
        if player_table.second_trinket then
            if mirrored then pos = Vector(pos.X-16,pos.Y) end-- if has trinket 2
        else
            pos = Vector(pos.X,pos.Y)
            scale = Vector(0.7,0.7) -- makes trinket bigger
        end
        player_table.first_trinket.Scale = scale
        player_table.first_trinket:Render(pos,VECTOR_ZERO,VECTOR_ZERO)
        pos = Vector(pos.X+16,pos.Y)
        trinket_offset.Y = trinket_offset.Y + off
    end
    if player_table.second_trinket then
        player_table.second_trinket.Scale = scale
        player_table.second_trinket:Render(pos,vector_zero,vector_zero)
    end
    return trinket_offset
end
function coopHUD.renderPockets(player_table)
    local scale = Vector(1,1)
    local anchor = player_table.anchor
    local off = 0
    local desc_off = Vector(0,0)
    anchor.Y = anchor.Y + player_table.sec_row_offset.Y
    if anchor == anchor_top_left then
        pos = Vector(anchor.X + 12 ,anchor.Y + 12 )
        off = 16
        desc_off = Vector(2,4)
    elseif anchor == anchor_bottom_left then
        pos = Vector(anchor.X+12,anchor.Y-12)
        off = 16
        desc_off = Vector(2,4)
    elseif anchor == anchor_top_right then
        pos = Vector(coopHUD.getMinimapOffset().X+8,anchor.Y+12)
        off = -16
        desc_off = Vector(-50,0)
        if string.len(desc) > 12 then
            player_table.main_pocket_desc = string.format("%.9s...",player_table.main_pocket_desc)
        end
    elseif anchor == anchor_bottom_right then
        pos = Vector(anchor.X-16,anchor.Y-12)
        desc_off = Vector(-50,4)
        if string.len(desc) > 12 then
            player_table.main_pocket_desc = string.format("%.9s...",player_table.main_pocket_desc)
        end
    end
    ------third pocket
    scale = Vector(0.5,0.5)
    if player_table.third_pocket then
        if player_table.third_pocket:GetDefaultAnimation() ~= 'Idle' then
            player_table.third_pocket.Scale = scale
            player_table.third_pocket:Render(Vector(pos.X + (2 * off),pos.Y), vector_zero, vector_zero)
        else
            if player_table.main_pocket:GetDefaultAnimation() ~= 'Idle' and player_table.second_pocket :GetDefaultAnimation() ~= 'Idle' then
                player_table.second_pocket.Scale = scale
                player_table.second_pocket:Render(Vector(pos.X+(2 * off),pos.Y), vector_zero, vector_zero)
            end
        end
    end
    ----second_pocket
    scale = Vector(0.5,0.5)
    if player_table.second_pocket then
        if player_table.main_pocket:GetDefaultAnimation() ~= 'Idle' or player_table.third_pocket:GetDefaultAnimation() ~= 'Idle' then
            player_table.second_pocket.Scale = scale
            player_table.second_pocket:Render(Vector(pos.X+off,pos.Y ), vector_zero, vector_zero)
        end
        if player_table.second_pocket:GetDefaultAnimation() == 'Idle' then
            scale = Vector(0.3,0.3 )
            --local pocket_charge  = renderPlayer.getItemChargeSprite(player,2)
            --if pocket_charge then
            --    if main_pocket:GetDefaultAnimation() ~= 'Idle' or second_pocket:GetDefaultAnimation() ~= 'Idle' then
            --        pocket_charge.Scale = scale
            --        pocket_charge:Render(Vector(pos.X+34,pos.Y+2), vector_zero, vector_zero)
            --
            --
            --    end
            --end
        end
    end
    -- Main pocket
    if player_table.main_pocket then
        scale = Vector(0.7,0.7)
        player_table.main_pocket.Scale = scale
        player_table.main_pocket:Render(pos, VECTOR_ZERO, VECTOR_ZERO)
        ---- main_pocket charge
        if player_table.main_pocket:GetDefaultAnimation() == 'Idle' then
            scale = Vector(0.5,0.5)
            if player_table.pocket_charge then
                player_table.pocket_charge.Scale = scale
                player_table.pocket_charge:Render(Vector(pos.X+12,pos.Y+2), vector_zero, vector_zero)
            end
        end
        local f = Font()
        f:Load("font/luaminioutlined.fnt")
        local color = KColor(1,0.2,0.2,0.7) -- TODO: sets according to player color
        if player_table.main_pocket_desc then
            f:DrawString (player_table.main_pocket_desc,pos.X+desc_off.X,pos.Y+desc_off.Y ,color,0,true) end
    end


end
function coopHUD.renderHearts(player_table)
    local max_health_cap = 12
    local n = 3 -- No. of rows
    local m = math.floor(max_health_cap/n)  -- No.
    local anchor = player_table.anchor
    if anchor == anchor_top_left then
        print(player_table.first_row_offset)
        pos = Vector(anchor.X + player_table.first_row_offset.X  ,anchor.Y + 12 )
    elseif anchor == anchor_bottom_left then
        pos = Vector(anchor.X,anchor.Y)
    elseif anchor == anchor_top_right then
        pos = Vector(coopHUD.getMinimapOffset().X,anchor.Y)
    elseif anchor == anchor_bottom_right then
        pos = Vector(anchor.X,anchor.Y)
    end
    local counter = 0
    for row=0,n-1,1 do
        for col=0,m-1,1 do
            if player_table.hearts[counter] then
                temp_pos = Vector(pos.X + (11 * col),pos.Y + (11 * row))
                player_table.hearts[counter]:Render(temp_pos,VECTOR_ZERO,VECTOR_ZERO)
            end
            counter = counter + 1
        end
    end
end
function coopHUD.renderPlayer(player_no,anchor)
    local player = Isaac.GetPlayer(player_no)
    local players = {}
    players.name = 'P1'
    players.type = player:GetPlayerType()
    players.anchor = anchor
    players.first_active = coopHUD.getActiveItemSprite(player,0)
    players.second_active = coopHUD.getActiveItemSprite(player,1)
    players.fi_charge = coopHUD.getItemChargeSprite(player,0)
    players.se_charge = coopHUD.getItemChargeSprite(player,1)
    players.first_trinket = coopHUD.getTrinketSprite(player,0)
    players.second_trinket = coopHUD.getTrinketSprite(player,1)
    players.main_pocket = coopHUD.getPocketItemSprite(player,0)
    players.pocket_charge = coopHUD.getItemChargeSprite(player,2)
    players.second_pocket = coopHUD.getPocketItemSprite(player,1)
    players.third_pocket = coopHUD.getPocketItemSprite(player,2)
    players.main_pocket_desc = coopHUD.getMainPocketDesc(player)
    ---

    players.first_row_offset = coopHUD.renderActiveItems(players)
    players.test_offset = coopHUD.renderHearts(players)
    --players.sec_row_offset = coopHUD.renderTrinkets(players)  --DEBUG
    --coopHUD.renderPockets(players)  --DEBUG
    --local pos = anchor
    --pos.Y = pos.Y + trinket_offset.Y
    --print(trinket_offset)
    --players.pocket_charge:Render(Vector(100,100),VECTOR_ZERO,VECTOR_ZERO)
end

function coopHUD.getMinimapOffset()
    -- Modified function from minimap_api by Wolfsauge
    local minimap_offset = ScreenHelper.GetScreenTopRight()
    local screen_size = ScreenHelper.GetScreenTopRight()
    local is_large = MinimapAPI:IsLarge()
    if not is_large and MinimapAPI:GetConfig("DisplayMode") == 2 then -- BOUNDED MAP
        minimap_offset = Vector(screen_size.X - MinimapAPI:GetConfig("MapFrameWidth") - MinimapAPI:GetConfig("PositionX") - 24,2)
    elseif not is_large and MinimapAPI:GetConfig("DisplayMode") == 4 then -- NO MAP
        minimap_offset = Vector(screen_size.X - 24,2)
    else -- LARGE
        local minx = screen_size.X
        for i,v in ipairs(MinimapAPI:GetLevel()) do
            if v ~= nil then
                if v:GetDisplayFlags() > 0 then
                    minx = math.min(minx, v.RenderOffset.X)
                end
            end

        end
        minimap_offset = Vector(minx-24,2) -- Small
    end
    --if MinimapAPI:GetConfig('ShowLevelFlags') then
    --    minimap_offset.X = minimap_offset.X - 16
    --end
    if MinimapAPI:GetConfig("Disable") or MinimapAPI.Disable then minimap_offset = Vector(screen_size.X - 24,2)  end
    local r = MinimapAPI:GetCurrentRoom()
    if MinimapAPI:GetConfig("HideInCombat") == 2 then
        if not r:IsClear() and r:GetType() == RoomType.ROOM_BOSS then
            minimap_offset = Vector(screen_size.X - 24,2)
        end
    elseif MinimapAPI:GetConfig("HideInCombat") == 3 then
        if not r:IsClear() then
            minimap_offset = Vector(screen_size.X - 24,2)
        end
    end
    return minimap_offset
end

function coopHUD.render()
    anchor_top_left = ScreenHelper.GetScreenTopLeft()
    anchor_bottom_left = ScreenHelper.GetScreenBottomLeft()
    anchor_top_right = ScreenHelper.GetScreenTopRight()
    anchor_bottom_right = ScreenHelper.GetScreenBottomRight()
    coopHUD.renderPlayer(0,anchor_top_left)
    coopHUD.renderPlayer(0,anchor_bottom_left)
    coopHUD.renderPlayer(0,anchor_top_right)
    coopHUD.renderPlayer(0,anchor_bottom_right)
    Game():GetHUD():SetVisible(true)
    --Game():GetHUD():SetVisible(false)
end

coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)