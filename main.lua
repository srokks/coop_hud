---@class coopHUD
coopHUD = RegisterMod("Coop HUD", 1)
---
include("coopHUD_globals.lua")
coopHUD.langAPI = include("helpers.langAPI.lua")
include("coopHUD_mcm.lua")
include('coopHUD_player.lua')
include("coopHUD_sprites.lua")
include('coopHUD_hud.lua')
include("callbacks.main.lua")
--
print('CoopHUD v.' .. tostring(coopHUD.VERSION) .. ' successfully!')