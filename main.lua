local testMod = RegisterMod("Coop HUD", 1)
 if HUDAPI  then
	isminimapmod = true
  a = 'True'
else
	isminimapmod = false
  a = 'False'
end
local ModConfigLoaded, ModConfig = pcall(require, "scripts.modconfig")
function getActiveItemSprite(player,slot)
  Anim = "gfx/ui/item.anm2"
  local activeitem = player:GetActiveItem()
  if activeitem == 0 then return false end
  local thissprite = Sprite() -- replaced
  thissprite:Load(Anim,true)
    local itemsprite = Isaac.GetItemConfig():GetCollectible(activeitem).GfxFileName
    --jar check
    if activeitem == 290 then
      itemsprite = "gfx/characters/costumes/costume_rebirth_90_thejar.png"
    elseif activeitem == 434 then
      itemsprite = "gfx/characters/costumes/costume_434_jarofflies.png"
    end
    -- bethany check
    if activeitem == 584 then
      itemsprite = "gfx/characters/costumes/costume_434_jarofflies.png"
    end
    -- everything jar
    if activeitem == 720 then
      itemsprite = "gfx/ui/hud_everythingjar.png" -- TODO: add 
    end
    -- 
    thissprite:ReplaceSpritesheet(0, itemsprite)
    thissprite:ReplaceSpritesheet(1, itemsprite)
    thissprite:ReplaceSpritesheet(2, itemsprite)
    thissprite:ReplaceSpritesheet(3, itemsprite)
    thissprite:ReplaceSpritesheet(4, itemsprite)
    thissprite:ReplaceSpritesheet(5, itemsprite)
    thissprite:LoadGraphics()
  local itemcharge = Isaac.GetItemConfig():GetCollectible(activeitem).MaxCharges
  if itemcharge == 0 then
    thissprite:SetFrame("Idle", 0)
  elseif player:NeedsCharge() == false or player:GetActiveCharge() >= itemcharge then
    thissprite:SetFrame("Idle", 1)
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
  -- bethany check
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
function getPocket(player)
  Anim = "gfx/ui/ui_cardspills.anm2"
  local thissprite = Sprite()
      thissprite:SetFrame("CardFronts", pocketcheck)
    end
        
function getPocketItemSprite(player)
  -- cards/runes/
  Anim = "gfx/ui/test.anm2"
  local pocketcheck = player:GetCard(0)
  local thissprite = Sprite()
  thissprite:Load(Anim,true)
  if pocketcheck ~= 0 then
    thissprite:SetFrame("CardFronts", pocketcheck) -- sets card frame
    print('card',pocketcheck)
    return thissprite
  else
    pocketcheck = player:GetPill(0) -- checks if player has pill
    if pocketcheck ~= 0 then
      if pocketcheck > 2048 then pocketcheck = pocketcheck - 2048 end -- check if its horse pill and change id to normal
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
function testMod:render()
  init_x = 50
  init_y = 50
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
  
  
  
  hearts_row = 3
  hearts_col = 3
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
  y = init_y + 30 --poz wyściowa
  tri1 = getTrinket(player,0)
  tri1:Render(Vector(x,y),z,z)
  tri2 = getTrinket(player,1)
  if tri2 then
    tri2.Scale = scale
    tri2:Render(Vector(x,y),z,z)
  end
  
  
  --main_pocket
  x = init_x + 16--pozycja wyjściowa
  y = init_y + 30 --poz wyściowa
  scale = Vector(0.7,0.7)
  main_pocket = getPocketItemSprite(player)
  if main_pocket then
    print(main_pocket)
    main_pocket.Scale = scale
    main_pocket:Render(Vector(100,100),z,z)
  end
end
--Game():GetSeeds():AddSeedEffect(SeedEffect.SEED_NO_HUD)
 --Game():GetSeeds():RemoveSeedEffect(SeedEffect.SEED_NO_HUD)

testMod:AddCallback(ModCallbacks.MC_POST_RENDER, testMod.render)
