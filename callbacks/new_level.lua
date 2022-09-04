-- __________ New floor streak trigger
coopHUD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	coopHUD.floor_custom_items = {}
	coopHUD.Streak(false, coopHUD.Streak.FLOOR)
	-- reloads hud icons for golden keys/bombs etc.
	coopHUD.HUD.coins = coopHUD.RunInfo(coopHUD.RunInfo.COIN)
	coopHUD.HUD.bombs = coopHUD.RunInfo(coopHUD.RunInfo.BOMB)
	coopHUD.HUD.keys = coopHUD.RunInfo(coopHUD.RunInfo.KEY)
end)