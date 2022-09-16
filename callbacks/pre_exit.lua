coopHUD:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
	coopHUD.save_options()
	coopHUD.players = {}
end)