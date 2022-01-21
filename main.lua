coopHUD = RegisterMod("Coop HUD", 1)

---
include("coopHUD_globals.lua")
include("coopHUD_player_table_updates.lua")
include("coopHUD_sprites.lua")
include("coopHUD_render.lua")
--
coopHUD.init() -- Debug: for mod rerun from game console
print('Coop HUD loaded ')
if  Game():GetHUD():IsVisible() then Game():GetHUD():SetVisible(false) end