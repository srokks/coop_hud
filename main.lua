coopHUD = RegisterMod("Coop HUD", 1)

---
include("coopHUD_globals.lua")
include("coopHUD_player_table_updates.lua")
include("coopHUD_sprites.lua")
include("coopHUD_render.lua")
---
-- OPTIONS SKETCH
local onRender = true
--coopHUD.init()
--
players_no = 0
-- init
--function coopHUD.init()
--    coopHUD.updateAnchors()
--    players_no = Game():GetNumPlayers()-1
--    for i=0,players_no,1 do
--        coopHUD.updatePlayer(i)
--        print('Initiated ',i,'Player')
--    end
--end
--coopHUD.init()

 -- Updates all players info on entering new flor



