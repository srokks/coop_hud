---@class coopHUD
coopHUD = RegisterMod("Coop HUD", 1)
---
include("coopHUD_globals.lua")
---@type langAPI
coopHUD.langAPI = include("helpers.langAPI.lua")
include("helpers.mcm.lua")
include("helpers.mod_overrides.lua")
include('modules.main.lua')
include('coopHUD_hud.lua')
include("callbacks.main.lua")
--
print('CoopHUD v.' .. tostring(coopHUD.VERSION) .. ' successfully!')