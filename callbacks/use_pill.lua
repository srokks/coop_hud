-- MC_USE_PILL
-- triggers streak with pill name on use
coopHUD:AddCallback(ModCallbacks.MC_USE_PILL, function(_, effect_no, entPlayer)
	local player = coopHUD.Player.getByEntityIndex(entPlayer.Index)
	if player then
		coopHUD.Streak(false, coopHUD.Streak.ITEM, coopHUD.langAPI.getPillNameByEffect(effect_no), nil, true,
		               player.font_color)
	end
end)