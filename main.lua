local testMod = RegisterMod("Coop HUD", 1)
 if HUDAPI  then
	isminimapmod = true
  a = 'True'
else
	isminimapmod = false
  a = 'False'
end
local ModConfigLoaded, ModConfig = pcall(require, "scripts.modconfig")
function getActiveItemSprite(player)
  Anim = "gfx/hudgfx/item.anm2"
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
  Anim = "gfx/hudgfx/activechargebar.anm2"
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
function testMod:render()
  pos = Vector(100,50)
  z = Vector(0,0)
  player = Isaac.GetPlayer(0)
  item = getActiveItemSprite(player)
  item:Render(pos,z,z)
  charge = getCharge(player)
  if charge then
  charge:Render(Vector(120,50),z,z)
end
  b=getHeartSprite(player,0)
  b:Render(Vector(130,50),z,z)
  end
  end
end
 Game():GetSeeds():AddSeedEffect(SeedEffect.SEED_NO_HUD)
 --Game():GetSeeds():RemoveSeedEffect(SeedEffect.SEED_NO_HUD)

testMod:AddCallback(ModCallbacks.MC_POST_RENDER, testMod.render)
