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
function testMod:render()
  pos = Vector(100,50)
  z = Vector(0,0)
  player = Isaac.GetPlayer(0)
  a = getActiveItemSprite(player)
  a:Render(pos,z,z)
  HUDAPI.onUpdate = true
end

testMod:AddCallback(ModCallbacks.MC_POST_RENDER, testMod.render)
