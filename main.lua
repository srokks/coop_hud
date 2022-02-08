coopHUD = RegisterMod("Coop HUD", 1)

---
include("coopHUD_globals.lua")
include("coopHUD_mcm.lua")
include("coopHUD_player_table_updates.lua")
include("coopHUD_sprites.lua")
include("coopHUD_player_table_updates.lua")
include("coopHUD_render.lua")
include("coopHUD_test.lua")
--
-- Inits tables when manual loaded mod
if coopHUD.players[0] == nil then coopHUD.on_player_init() end
coopHUD.updateAnchors()