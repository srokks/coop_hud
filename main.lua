local coopHUD = RegisterMod("Coop HUD", 1)
-- if HUDAPI  then
--	isminimapmod = true
--  a = 'True'
--else
--	isminimapmod = false
--  a = 'False'
--end

function getActiveItemSprite(player,slot)
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
    -- Book of Virtuoses check
    -- TODO: virtuoses render
    --if activeitem == 584 then
    --  itemsprite = "gfx/characters/costumes/costume_434_jarofflies.png"
    --end
     --Everything Jar
     --TODO: Everything Jar render
    if activeitem == 720 then
      itemsprite = "gfx/ui/hud_everythingjar.png"
    end
    -- 
    thissprite:ReplaceSpritesheet(0, itemsprite)
    thissprite:ReplaceSpritesheet(1, itemsprite)
    thissprite:ReplaceSpritesheet(2, itemsprite)
    thissprite:ReplaceSpritesheet(3, itemsprite)
    thissprite:ReplaceSpritesheet(4, itemsprite)
    thissprite:ReplaceSpritesheet(5, itemsprite)
    thissprite:LoadGraphics()
    -- sets item overlay according to charges
  local itemcharge = Isaac.GetItemConfig():GetCollectible(activeitem).MaxCharges -- gets max charges
  if itemcharge == 0 then -- checks id item has any charges
    thissprite:SetFrame("Idle", 0) -- set frame to unloaded
  elseif player:NeedsCharge() == false or player:GetActiveCharge(slot) >= itemcharge then
      -- checks if item dont needs charges or item is overloaded
    thissprite:SetFrame("Idle", 1) -- set frame to loaded
  else
    thissprite:SetFrame("Idle", 0)
  end
  --jar check
  if activeitem == 290 or activeitem == 434 then
    local frame = 0
    if activeitem == 290 then frame = player:GetJarHearts() end
    if activeitem == 434 then frame = player:GetJarFlies() end
    thissprite:SetFrame("Jar", frame)
  end
    -- Everything Jar - charges set
    if activeitem == 720  then
        charge = player:GetActiveCharge()
        thissprite:SetFrame("EverythingJar", charge+1)

    end



return thissprite
end
function getCharge(player)
  Anim = "gfx/ui/activechargebar.anm2"
  local activeitem = player:GetActiveItem()
  if activeitem == 0 then return false end
  local itemcharge = Isaac.GetItemConfig():GetCollectible(activeitem).MaxCharges
  if itemcharge == 0 then return false end
  local thissprite = Sprite()
  thissprite:Load(Anim,true)
  local charges = player:GetActiveCharge() + player:GetBatteryCharge()
  local step = math.floor((charges/(itemcharge*2))*46)
  thissprite:SetFrame("ChargeBar", step)
  if (itemcharge > 1 and itemcharge < 5) or itemcharge == 6 or itemcharge == 12 then
    thissprite:PlayOverlay("BarOverlay" .. itemcharge, true)
  else
    thissprite:PlayOverlay("BarOverlay1", true)
  end
  return thissprite
end
--get type of heart to render
function GetHeartType(player,heartnum)
	local subcharacter = false
	local hearttype = "None"
	local overlaytype = "None"
	local curse = Game():GetLevel():GetCurseName()
	if player:GetPlayerType() == 10 then
		if heartnum == 0 then
			hearttype = "None"
			overlaytype = "None"
		end
	elseif curse == "Curse of the Unknown" then
		if heartnum == 0 then
			hearttype = "CurseHeart"
			overlaytype = "None"
		end
	else
		local prevsoulcount = 0
		
		if (player:GetName() == "The Forgotten" or player:GetName() == "The Soul") and heartnum > 5 then
			if heartnum < 12 then
				player = player:GetSubPlayer()
				subcharacter = true
			end
			heartnum = heartnum - 6
		end
		local totalhearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts())/2)
		if heartnum >= totalhearts and NoHealthCapModEnabled then
			hearttype, overlaytype = NoHealthCapGetHeartTypeAtPos(heartnum)
		else
			local emptyhearts = math.floor((player:GetMaxHearts()-player:GetHearts())/2)
			if emptyhearts < 0 then emptyhearts = 0 end
			local eternal = false
			local goldheart = false
			--gold hearts
			if player:GetGoldenHearts() > 0 and heartnum >= totalhearts - (player:GetGoldenHearts()+emptyhearts) then
				goldheart = true
			end
			--red heart containers
			if player:GetMaxHearts()/2 > heartnum then
				if player:GetName() == "Keeper" then
					--coin hearts
					goldheart = false
					if player:GetHearts()-(heartnum*2) > 1 then
						hearttype = "CoinHeartFull"
					elseif player:GetHearts()-(heartnum*2) == 1 then
						hearttype = "CoinHeartHalf"
					else
						hearttype = "CoinEmpty"
					end
				else
					if player:GetHearts()-(heartnum*2) > 1 then
						hearttype = "RedHeartFull"
					elseif player:GetHearts()-(heartnum*2) == 1 then
						hearttype = "RedHeartHalf"
					else
						hearttype = "EmptyHeart"
						goldheart = false
					end
				end
				--eternal heart overlay
				if player:GetEternalHearts() > 0 and heartnum+1 == player:GetMaxHearts()/2 and player:GetHearts()-(heartnum*2) < 3 then
					eternal = true
				end
			--if there are any soul/bone hearts
			elseif player:GetSoulHearts() > 0 or player:GetBoneHearts() > 0 then
				local redheartsoffset = heartnum-(player:GetMaxHearts()/2)
				--if there are no soul/bone hearts left
				if math.ceil(player:GetSoulHearts()/2) + player:GetBoneHearts() <= redheartsoffset then
					hearttype = "None"
				else
					--bone hearts
					if player:IsBoneHeart(redheartsoffset) then
						prevsoulcount = 0
						if redheartsoffset > 0 then
							for i = 0, redheartsoffset do
								if player:IsBoneHeart(i) == false then
									prevsoulcount = prevsoulcount + 2
								end
							end
						end
						local remainingred = player:GetHearts()+prevsoulcount-(heartnum*2)
						if remainingred > 1 then
							hearttype = "BoneHeartFull"
						elseif remainingred == 1 then
							hearttype = "BoneHeartHalf"
						else
							hearttype = "BoneHeartEmpty"
						end
						--eternal heart overlay
						if player:GetEternalHearts() > 0 and player:GetHearts() > player:GetMaxHearts() and player:GetHearts()-(heartnum*2) > 0 and player:GetHearts()-(heartnum*2) < 3 then
							eternal = true
						end
					else--soul/black hearts
						local prevbonecount = 0
						if redheartsoffset > 0 then
							for i = 0, redheartsoffset do
								if player:IsBoneHeart(i) then
									prevbonecount = prevbonecount + 1
								end
							end
						end
						local blackheartcheck = (redheartsoffset*2 + 1)-(2*prevbonecount)
						local remainingsoul = player:GetSoulHearts() + (2*prevbonecount) - (redheartsoffset*2)
						if player:IsBlackHeart(blackheartcheck) then
							if remainingsoul > 1 then
								hearttype = "BlackHeartFull"
							else
								hearttype = "BlackHeartHalf"
							end
						else
							if remainingsoul > 1 then
								hearttype = "BlueHeartFull"
							else
								hearttype = "BlueHeartHalf"
							end
						end
						--eternal heart overlay
						if player:GetEternalHearts() > 0 and heartnum == 0 then
							eternal = true
						end
					end
				end
			else
				hearttype = "None"
			end
			if eternal and goldheart then
				overlaytype = "Gold&Eternal"
			elseif eternal then
				overlaytype = "WhiteHeartOverlay"
			elseif goldheart then
				overlaytype = "GoldHeartOverlay"
			end
		end
		if REPENTANCE and player:GetRottenHearts() > 0 then
			local nonrottenreds = player:GetHearts()/2 - player:GetRottenHearts()
			if hearttype == "RedFull" then
				if heartnum >= nonrottenreds then
					hearttype = "RottenHeartFull"
				end
			elseif hearttype == "BoneFull" then
				local remainingred = player:GetHearts()+prevsoulcount-(heartnum*2)
				if remainingred - player:GetRottenHearts()*2 <= 0 then
					hearttype = "RottenBoneHeartFull"
				end
			end
		end
	end
	return hearttype, overlaytype, subcharacter
end
function getHeartSprite(player,heartpos)

  Anim = "gfx/ui/ui_hearts.anm2"
  local thissprite = Sprite()
  thissprite:Load(Anim,true)
  thissprite:RemoveOverlay()
  local hearttype, overlaytype, sub = GetHeartType(player,heartpos)
  local opacity = 1
  if heartpos > 23 then
    opacity = 0.2
  elseif heartpos > 17 then
    opacity = 0.4
  elseif heartpos > 11 then
    opacity = 0.6
  end
  if sub then
    opacity = opacity/2
  end
  thissprite.Color = Color(1, 1, 1, opacity, 0, 0, 0)
  if hearttype == "None" then
    return false
  else

  thissprite:SetFrame(hearttype, 0)
  if overlaytype ~= "None" then
					thissprite:SetOverlayFrame(overlaytype, 0)
  end
  return thissprite
end
end
function getTrinket(player,trinket_pos)
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
function getPocketItemSprite(player,slot)
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
              thissprite = getActiveItemSprite(player,2)
          else
              thissprite = getActiveItemSprite(player,3)
          end
          return thissprite
      else
          return false
      end
    end
  end
end
function getMainPocketDesc(player)
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
function coopHUD:render()
  init_x = 100 --
  init_y = 100 --
  pos = Vector(100,50)
  z = Vector(0,0)
  player = Isaac.GetPlayer(0)
  item = getActiveItemSprite(player,0)
  if item then
    item:Render(Vector(init_x,init_y),z,z)
  end
  x = init_x + 17
  charge = getCharge(player)
  if charge then
  charge:Render(Vector(x,init_y),z,z)
end
  -- hearts
  x = init_x+ 30 --pozycja wyjściowa
  y = init_y -10 --poz wyściowa

  
  hearts_row = 4 
  hearts_col = 4 
  for j = 0,12,1 do --iteruje po wszystkich serduszkach jakie ma
    -- TODO: integracja z no cap 
    row_no = math.floor(j/hearts_row) -- gets heart row number
    col_no = j%hearts_col
    heart_sprite=getHeartSprite(player,j)
    if heart_sprite then
      heart_sprite:Render(Vector(x+12*col_no,y+(10*row_no),z,z))
    end
  end
  --trinkets
  scale = Vector(0.7,0.7)
  x = init_x --pozycja wyjściowa
  y = init_y + 20  --poz wyściowa
  tri1 = getTrinket(player,0)
  
  if tri1 then
    tri1.Scale = scale
    tri1:Render(Vector(x,y),z,z)
  end
  x = init_x --pozycja wyjściowa
  y = init_y + 32  --poz wyściowa
  tri2 = getTrinket(player,1)
  if tri2 then
    tri2.Scale = scale
    tri2:Render(Vector(x,y),z,z)
  end
  --third pocket
  x = init_x + 48--pozycja wyjściowa
  y = init_y + 22  --poz wyściowa
  scale = Vector(0.5,0.5)
  third_pocket = getPocketItemSprite(player,2 )
  if third_pocket then
    third_pocket.Scale = scale
    third_pocket:Render(Vector(x,y),z,z)
  end
  -- ISSUE: shows pocket item 
  -- FIX: 
  
   
  --second_pocket
  x = init_x + 34--pozycja wyjściowa
  y = init_y + 22  --poz wyściowa
  scale = Vector(0.5,0.5)
  second_pocket = getPocketItemSprite(player,1)
  if second_pocket then
    second_pocket.Scale = scale
    second_pocket:Render(Vector(x,y),z,z)
  end
  --main_pocket
  x = init_x + 16--pozycja wyjściowa
  y = init_y + 24 --poz wyściowa
  scale = Vector(0.7,0.7)
  main_pocket = getPocketItemSprite(player,0)
  if main_pocket then
    main_pocket.Scale = scale
    main_pocket:Render(Vector(x,y),z,z)
  end
  -- main_pocket_desc
  x = init_x + 16--pozycja wyjściowa
  y = init_y + 24 --poz wyściowa
  local main_pocket_desc = ""
  main_pocket_desc = getMainPocketDesc(player)
  f = Font()
  f:Load("font/luaminioutlined.fnt")
  color = KColor(1,0.2,0.2,0.7)
  if main_pocket_desc then
    f:DrawString (main_pocket_desc,x,y,color,0,true) end

end


--Game():GetSeeds():AddSeedEffect(SeedEffect.SEED_NO_HUD)
Game():GetSeeds():RemoveSeedEffect(SeedEffect.SEED_NO_HUD)

coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)
