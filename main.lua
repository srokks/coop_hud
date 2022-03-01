coopHUD = RegisterMod("Coop HUD", 1)

---
include("coopHUD_globals.lua")
include("coopHUD_mcm.lua")
include("coopHUD_player_table_updates.lua")
include("coopHUD_sprites.lua")
include("coopHUD_player_table_updates.lua")
include("coopHUD_table_callbacks.lua")
include("coopHUD_render.lua")
--
print('CoopHUD v.'..tostring(coopHUD.VERSION)..' successfully!')