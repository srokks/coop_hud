local coopHUD = RegisterMod("Coop HUD", 1)
-- if HUDAPI  then
--	isminimapmod = true
--  a = 'True'
--else
--	isminimapmod = false
--  a = 'False'
--end

function coopHUD.getActiveItemSprite(player,slot)
  Anim = "gfx/ui/item.anm2"
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
    thissprite:SetFrame("Idle", 0) -- set frame to unloaded
  elseif player:NeedsCharge() == false or player:GetActiveCharge(slot) >= itemcharge then
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
function coopHUD.getHeartSprite(player,heartpos)
    local curse = Game():GetLevel():GetCurseName()
    if Isaac.GetPlayer(0):GetPlayerType() == 10 then -- Lost check
        if heartpos == 0 then
            hearttype = "None"
            overlaytype = "None"
        end
    elseif curse == "Curse of the Unknown" then
        if heartnum == 0 then
            hearttype = "Curse"
            overlaytype = "None"
        end
    end
    local totalhearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts())/2)
    --print(totalhearts)
    return false
end
function coopHUD.getTrinket(player,trinket_pos)
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
    local init_x = anchor.X -- init pos x - hor
    local init_y = anchor.Y
    local x,y = 0
    -- Second active item - render
    x = init_x - 7
    y = init_y - 7
    local second_active = coopHUD.getActiveItemSprite(player,1)
    if second_active then
        second_active.Scale = Vector(0.7,0.7)
        second_active:Render(Vector(x,x), vector_zero, vector_zero)
    end
    -- Second active item - charges - render
    x = init_x - 15
    y = init_y - 9
    local se_charge = coopHUD.getItemChargeSprite(player,1)
    if se_charge then
        se_charge.Scale = Vector(0.5,0.5 )
        se_charge:Render(Vector(x,y), vector_zero, vector_zero)
    end
    -- First active item - render
    local first_active = coopHUD.getActiveItemSprite(player,0)
    if first_active then
        first_active:Render(Vector(init_x,init_y), vector_zero, vector_zero)
    end
    -- First active item - charges - render
    x = init_x + 17
    local fi_charge = coopHUD.getItemChargeSprite(player,0)
    if fi_charge then
        fi_charge:Render(Vector(x,init_y), vector_zero, vector_zero)
    end
end
function coopHUD.renderTrinket(player,anchor,trinket_no)
    scale = Vector(0.7,0.7)
    local trinket_sprite = coopHUD.getTrinket(player,trinket_no)
    if trinket_sprite then
        trinket_sprite.Scale = scale
        trinket_sprite:Render(anchor, vector_zero, vector_zero)
    end
end
function coopHUD.renderPockets(player,anchor)
    ----main_pocket
    --x = init_x + 16--pozycja wyjściowa
    --y = init_y + 24 --poz wyściowa
    --scale = Vector(0.7,0.7)
    --local main_pocket = coopHUD.getPocketItemSprite(player,0)
    --
    --if main_pocket then
    --    main_pocket.Scale = scale
    --    main_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    --end
    ---- main_pocket charge
    --if main_pocket then
    --    if main_pocket:GetDefaultAnimation() == 'Idle' then
    --        x = init_x + 28--pozycja wyjściowa
    --        y = init_y + 24
    --        scale = Vector(0.5,0.5)
    --        local pocket_charge  = getCharge(player,2)
    --        if pocket_charge then
    --            pocket_charge.Scale = scale
    --            pocket_charge:Render(Vector(x,y), vector_zero, vector_zero)
    --        end
    --    end
    --end
    ----second_pocket
    --x = init_x + 34--pozycja wyjściowa
    --y = init_y + 22  --poz wyściowa
    --scale = Vector(0.5,0.5)
    --local second_pocket = coopHUD.getPocketItemSprite(player,1)
    --if second_pocket then
    --    if main_pocket:GetDefaultAnimation() ~= 'Idle' or second_pocket:GetDefaultAnimation() ~= 'Idle' then
    --        second_pocket.Scale = scale
    --        second_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    --    end
    --end
    ----third pocket
    --x = init_x + 48--pozycja wyjściowa
    --y = init_y + 22  --poz wyściowa
    --scale = Vector(0.5,0.5)
    --local third_pocket = coopHUD.getPocketItemSprite(player,2 )
    --if third_pocket then
    --    third_pocket.Scale = scale
    --    third_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    --end
    ---- ISSUE: shows pocket item
    ---- FIX:
    --
    --
    ----second_pocket
    --x = init_x + 34--pozycja wyjściowa
    --y = init_y + 22  --poz wyściowa
    --scale = Vector(0.5,0.5)
    --second_pocket = coopHUD.getPocketItemSprite(player,1)
    --if second_pocket then
    --    second_pocket.Scale = scale
    --    second_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    --end
    ----main_pocket
    --x = init_x + 16--pozycja wyjściowa
    --y = init_y + 24 --poz wyściowa
    --scale = Vector(0.7,0.7)
    --main_pocket = coopHUD.getPocketItemSprite(player,0)
    --if main_pocket then
    --    main_pocket.Scale = scale
    --    main_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    --end
    ---- main_pocket_desc
    --x = init_x + 16--pozycja wyjściowa
    --y = init_y + 24 --poz wyściowa
    --local main_pocket_desc = ""
    --main_pocket_desc = coopHUD.getMainPocketDesc(player)
    --f = Font()
    --f:Load("font/luaminioutlined.fnt")
    --color = KColor(1,0.2,0.2,0.7)
    --if main_pocket_desc then
    --    f:DrawString (main_pocket_desc,x,y,color,0,true) end

end
function coopHUD.render()
    -- inits
    player_num = 0

    local init_x = 100 -- init pos x - hor
    local init_y = 100
    local player = Isaac.GetPlayer(player_num)
    local max_trinkets = player:GetMaxTrinkets()

    anchor = Vector(50,50)
    coopHUD.renderActiveItem(player,anchor)
    if max_trinkets > 1 then

    else
        anchor.Y = anchor.Y + 24
        coopHUD.renderTrinket(player,anchor,0)
    end

    -- Hearts - render

    if first_active then -- checks if has active item
    x = init_x+ 30
    y = init_y -10
    else
    x = init_x -10 -- if no activeitem render closer to edge
    y = init_y - 10
    end
    x = x + 50 -- DEBUG
    y = y + 50 -- DEBUG
    -- TODO: fix rendering - golden heaert issue
    local rows = 2
    for j = 0,12,1 do --iteruje po wszystkich serduszkach jakie ma player
    -- TODO: v1.1 NoCap mod integration
    local heart_sprite=coopHUD.getHeartSprite(player,j)
    row = j
    col = 1
    -- TODO: fix rendering hearts
    if heart_sprite then
    heart_sprite:Render(Vector(x+12*row,y+(10*col), vector_zero, vector_zero))
    end
    end



    --main_pocket
    x = init_x + 16--pozycja wyjściowa
    y = init_y + 24 --poz wyściowa
    scale = Vector(0.7,0.7)
    local main_pocket = coopHUD.getPocketItemSprite(player,0)

    if main_pocket then
    main_pocket.Scale = scale
    main_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    end
    -- main_pocket charge
    if main_pocket then
    if main_pocket:GetDefaultAnimation() == 'Idle' then
    x = init_x + 28--pozycja wyjściowa
    y = init_y + 24
    scale = Vector(0.5,0.5)
    local pocket_charge  = getCharge(player,2)
    if pocket_charge then
    pocket_charge.Scale = scale
    pocket_charge:Render(Vector(x,y), vector_zero, vector_zero)
    end
    end
    end
    --second_pocket
    x = init_x + 34--pozycja wyjściowa
    y = init_y + 22  --poz wyściowa
    scale = Vector(0.5,0.5)
    local second_pocket = coopHUD.getPocketItemSprite(player,1)
    if second_pocket then
    if main_pocket:GetDefaultAnimation() ~= 'Idle' or second_pocket:GetDefaultAnimation() ~= 'Idle' then
    second_pocket.Scale = scale
    second_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    end
    end
    --third pocket
    x = init_x + 48--pozycja wyjściowa
    y = init_y + 22  --poz wyściowa
    scale = Vector(0.5,0.5)
    local third_pocket = coopHUD.getPocketItemSprite(player,2 )
    if third_pocket then
    third_pocket.Scale = scale
    third_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    end
    -- ISSUE: shows pocket item
    -- FIX:


    --second_pocket
    x = init_x + 34--pozycja wyjściowa
    y = init_y + 22  --poz wyściowa
    scale = Vector(0.5,0.5)
    second_pocket = coopHUD.getPocketItemSprite(player,1)
    if second_pocket then
    second_pocket.Scale = scale
    second_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    end
    --main_pocket
    x = init_x + 16--pozycja wyjściowa
    y = init_y + 24 --poz wyściowa
    scale = Vector(0.7,0.7)
    main_pocket = coopHUD.getPocketItemSprite(player,0)
    if main_pocket then
    main_pocket.Scale = scale
    main_pocket:Render(Vector(x,y), vector_zero, vector_zero)
    end
    -- main_pocket_desc
    x = init_x + 16--pozycja wyjściowa
    y = init_y + 24 --poz wyściowa
    local main_pocket_desc = ""
    main_pocket_desc = coopHUD.getMainPocketDesc(player)
    f = Font()
    f:Load("font/luaminioutlined.fnt")
    color = KColor(1,0.2,0.2,0.7)
    if main_pocket_desc then
    f:DrawString (main_pocket_desc,x,y,color,0,true) end

end


--Game():GetSeeds():AddSeedEffect(SeedEffect.SEED_NO_HUD)
Game():GetSeeds():RemoveSeedEffect(SeedEffect.SEED_NO_HUD)
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)
