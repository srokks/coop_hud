coopHUD = RegisterMod("Coop HUD", 1)

---
include("coopHUD_globals.lua")
include("coopHUD_mcm.lua")
include("coopHUD_sprites.lua")
include("coopHUD_player_table_updates.lua")
include("coopHUD_render.lua")
--
coopHUD.initHudTables()
--coopHUD.on_player_init() -- DEBUG: to reload tables on manually load mod