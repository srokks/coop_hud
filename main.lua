coopHUD = RegisterMod("Coop HUD", 1)

---
include("coopHUD_globals.lua")
include("coopHUD_mcm.lua")
include('coopHUD_player.lua')
include("coopHUD_sprites.lua")
include("coopHUD_callbacks.lua")
--
print('CoopHUD v.'..tostring(coopHUD.VERSION)..' successfully!')