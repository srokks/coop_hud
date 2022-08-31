-- _____ On battle signal
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, function(self)
	-- on battle signal
	-- if option turned on checks signals
	local r = Game():GetLevel():GetCurrentRoom()
	if not r:IsClear() then
		-- check if room ready
		coopHUD.signals.on_battle = 0 -- battle
		if r:GetBossID() > 0 then
			coopHUD.signals.on_battle = 1 -- boss
		end
	elseif r:IsAmbushActive() then
		coopHUD.signals.on_battle = 2 -- ambush
	else
		coopHUD.signals.on_battle = false -- reset signal
	end
end)