-- MC_USE_PILL
-- triggers streak with pill name on use
coopHUD:AddCallback(ModCallbacks.MC_USE_PILL, function(_, effect_no, entPlayer)
	local player = coopHUD.Player.getByEntityIndex(entPlayer.Index)
	if player then
		local pill_sys_name = Isaac.GetItemConfig():GetPillEffect(effect_no).Name
		pill_sys_name = string.sub(pill_sys_name, 2) --  get rid of # on front of
		coopHUD.Streak(false, coopHUD.Streak.ITEM, coopHUD.langAPI.getPocketName(pill_sys_name), nil, true,
		               player.font_color)
	end
end)