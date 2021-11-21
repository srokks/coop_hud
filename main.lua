local coopHUD = RegisterMod("Coop HUD", 1)
-- if HUDAPI  then
--	isminimapmod = true
--  a = 'True'
--else
--	isminimapmod = false
--  a = 'False'
--end
--GLOBALS
VECTOR_ZERO = Vector(0,0)

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
    -- TODO: Jar of Wisp - charges set sprite
    --if activeitem == 685 then
    --    --TODO: anim frames
    --    --TODO: get charges
    --end
    -- TODO:Urn of soul - charges set sprite
    if activeitem == 640 then
        fi_charge = 0
        -- TODO: get charge of urn
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
function coopHUD.renderActiveItem(player,anchor)
    local scale = Vector(1,1)
    local pos = Vector(anchor.X,anchor.Y)
    -- Second active item - render

    local first_active = coopHUD.getActiveItemSprite(player,0)
    local second_active = coopHUD.getActiveItemSprite(player,1)
    if first_active or second_active then
        if second_active then
            second_active.Scale = Vector(0.7,0.7)
            second_active:Render(Vector(pos.X - 7,pos.Y - 7), vector_zero, vector_zero)
        end
        -- Second active item - charges - render
        local se_charge = coopHUD.getItemChargeSprite(player,1)
        if se_charge then
            se_charge.Scale = Vector(0.5,0.5)
            se_charge:Render(Vector(pos.X - 15,pos.Y - 9), vector_zero, vector_zero)
        end
        -- First active item - render
        if first_active then
            first_active:Render(pos, VECTOR_ZERO, VECTOR_ZERO)
        end
        -- First active item - charges - render
        pos.X = pos.X + 17
        local fi_charge = coopHUD.getItemChargeSprite(player,0)
        if fi_charge then
            fi_charge:Render(pos, VECTOR_ZERO, VECTOR_ZERO)
        end
    end
    return pos
end
function coopHUD.renderTrinkets(player,anchor)
    local scale = Vector(0.5,0.5)
    local tri1 = coopHUD.getTrinketSprite(player,0)
    local tri2 = coopHUD.getTrinketSprite(player,1)
    local pos = Vector(anchor.X,anchor.Y)
    if tri1 then
        if tri2 then -- if has trinket 2
            pos.Y = pos.Y + 16 -- left corner pos
        else -- else
            pos.Y = pos.Y + 22 -- center pos
            scale = Vector(0.7,0.7) -- makes trinket bigger
        end
        tri1.Scale = scale
        tri1:Render(pos,vector_zero,vector_zero)
        pos.X = pos.X + 8
    end
    if tri2 then
        pos.Y = pos.Y + 8

        tri2.Scale = scale
        tri2:Render(pos,vector_zero,vector_zero) end
    return pos.X
end
function coopHUD.renderPockets(player,anchor)
    local scale = Vector(0.7,0.7)
    local pos = Vector(anchor.X,anchor.Y)
    local main_pocket = coopHUD.getPocketItemSprite(player,0)
    local second_pocket = coopHUD.getPocketItemSprite(player,1)
    local third_pocket = coopHUD.getPocketItemSprite(player,2 )
    ----second_pocket charges
    if third_pocket then
        if third_pocket:GetDefaultAnimation() == 'Idle' then
            scale = Vector(0.3,0.3 )
            local pocket_charge  = coopHUD.getItemChargeSprite(player,2)
            if pocket_charge then
                if main_pocket:GetDefaultAnimation() ~= 'Idle' and third_pocket :GetDefaultAnimation() ~= 'Idle' then
                    pocket_charge.Scale = scale
                    pocket_charge:Render(Vector(pos.X+42,pos.Y+2), vector_zero, vector_zero)
                end
            end
            pos.X = pos.X -5
        end
    end
    ------third pocket
    scale = Vector(0.5,0.5)
    if third_pocket then
        if third_pocket:GetDefaultAnimation() ~= 'Idle' then
            third_pocket.Scale = scale
            third_pocket:Render(Vector(pos.X+40,pos.Y), vector_zero, vector_zero)
        else
            if main_pocket:GetDefaultAnimation() ~= 'Idle' and second_pocket :GetDefaultAnimation() ~= 'Idle' then
                second_pocket.Scale = scale
                second_pocket:Render(Vector(pos.X+40,pos.Y), vector_zero, vector_zero)
            end
        end
    end
    ----second_pocket charges
    scale = Vector(0.5,0.5)
    if second_pocket then
        if second_pocket:GetDefaultAnimation() == 'Idle' then
            scale = Vector(0.3,0.3 )
            local pocket_charge  = coopHUD.getItemChargeSprite(player,2)
            if pocket_charge then
                if main_pocket:GetDefaultAnimation() ~= 'Idle' or second_pocket:GetDefaultAnimation() ~= 'Idle' then
                    pocket_charge.Scale = scale
                    pocket_charge:Render(Vector(pos.X+34,pos.Y+2), vector_zero, vector_zero)


                end
            end
            pos.X = pos.X -5
        end
    end
    ----second_pocket
    scale = Vector(0.5,0.5)
    if second_pocket then
        if main_pocket:GetDefaultAnimation() ~= 'Idle' or third_pocket:GetDefaultAnimation() ~= 'Idle' then
            second_pocket.Scale = scale
            second_pocket:Render(Vector(pos.X+32,pos.Y), vector_zero, vector_zero)
        end
    end
    ----main_pocket
    if main_pocket then
        scale = Vector(0.7,0.7)
        main_pocket.Scale = scale
        main_pocket:Render(Vector(pos.X + 16,pos.Y), VECTOR_ZERO, VECTOR_ZERO)
    end
    ---- main_pocket charge
    if main_pocket then
        if main_pocket:GetDefaultAnimation() == 'Idle' then
            --x = init_x + 28--pozycja wyjściowa
            --y = init_y + 24
            scale = Vector(0.5,0.5)
            local pocket_charge  = coopHUD.getItemChargeSprite(player,2)
            if pocket_charge then
                pocket_charge.Scale = scale
                pocket_charge:Render(Vector(pos.X+26,pos.Y+2), vector_zero, vector_zero)
            end
            pos.X = pos.X -5
        end
    end
    ---- main_pocket_desc
    --x = init_x + 16--pozycja wyjściowa
    --y = init_y + 24 --poz wyściowa
    local main_pocket_desc = ""
    main_pocket_desc = coopHUD.getMainPocketDesc(player)
    local f = Font()
    f:Load("font/luaminioutlined.fnt")
    local color = KColor(1,0.2,0.2,0.7) -- TODO: sets according to player color
    if main_pocket_desc then
        f:DrawString (main_pocket_desc,anchor.X+8,anchor.Y+4 ,color,0,true) end

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
function coopHUD.getHeartType(player,heart_pos)
    ---- Modified function from HUD_API from NeatPotato mod
    local player_type = player:GetPlayerType()
    local heart_type = 'None'
    local eternal = false
    local golden = false
    local remain_souls = 0
    if player_type == 10 or player_type == 31 then
        --TODO: Lost custom heart
    elseif Game():GetLevel():GetCurses() == 8 then -- checks curse of the uknown
        heart_type = 'CurseHeart'
    else
        --if player_type == 16 or player_type == 17 then --forgoten and soul check
        --    print(player:IsBlackHeart(4))
        --else
        eternal = false
        golden = false
        local total_hearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts())/2)
        local empty_hearts = math.floor((player:GetMaxHearts()-player:GetHearts())/2)
        if empty_hearts < 0 then empty_hearts = 0 end
        print(heart_pos,heart_pos>total_hearts - (player:GetGoldenHearts()+empty_hearts))
        if player:GetGoldenHearts() > 0 and heart_pos >= (total_hearts - (player:GetGoldenHearts()+empty_hearts)) then
            golden = true
        end
        if player:GetMaxHearts()/2 > heart_pos then -- red heart type
            if player_type == 14 then -- Keeper
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
        end
        --TODO: proper overlay set
        return heart_type,overlay
    end
end
function coopHUD.renderHearts(player,anchor)
    -- Hearts - render
    local heart

    local heart_num = 0
    local pos = Vector(anchor.X,anchor.Y)
    --player:AddBoneHearts(1)
    --coopHUD.getHeartType(player,3 ) -- DEBUG
    --print('GetSoulCharge',player:GetSoulCharge(),':GetBloodCharge()',player:GetBloodCharge())
    if player:GetPlayerType() == 18 or player:GetPlayerType() == 36 then -- Bethany - Tainted Bethany check
        print('Bethany')
        -- TODO: Bethany charge ind - render right of hearts
    elseif player:GetPlayerType() == 19 then -- Jacob/Essau check
        print('Jacob/Essau')
        -- TODO: Jacob/Essau render hearts
    elseif player:GetPlayerType() == 16 or player:GetPlayerType() == 17 then -- Forgotten/Soul check
        print('Forgotten/Soul')
        --TODO: render first player hearts (Forgotten/Soul)
        --TODO: render sub player hearts (Forgotten/Soul) - with opacity - belowe first hearts
    else -- Render others chars hearts
        pos.X = pos.X + 10
        pos.Y = pos.Y - 10
        for i=0,12,1 do
            local heart_type,overlay = coopHUD.getHeartType(player,i)
            --print(i,heart_type,overlay)
            local heart_sprt = coopHUD.getHeartSprite(heart_type)
            if heart_sprt then
                heart_sprt:Render(Vector(pos.X+(12*i),pos.Y),VECTOR_ZERO,VECTOR_ZERO)
            end

        end
    end

end

function coopHUD.render()
    -- inits
    player_num = 0

    local init_x = 100 -- init pos x - hor
    local init_y = 100
    local player = Isaac.GetPlayer(player_num)
    local max_trinkets = player:GetMaxTrinkets()

    local anchor = Vector(50,50)
    local active_off = coopHUD.renderActiveItem(player,anchor)
    local trinket_off = coopHUD.renderTrinkets(player,anchor)
    --print(active_off)
    coopHUD.renderPockets(player,Vector(trinket_off,anchor.Y+24))
    coopHUD.renderHearts(player,Vector(active_off.X,anchor.Y))
end


--Game():GetSeeds():AddSeedEffect(SeedEffect.SEED_NO_HUD)
Game():GetSeeds():RemoveSeedEffect(SeedEffect.SEED_NO_HUD)
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)
