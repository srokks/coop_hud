function coopHUD.test()
	local f = Font()
	f:Load("font/pftempestasevencondensed.fnt")
	if Input.IsButtonTriggered(Keyboard.KEY_I, 0) then
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.test)
coopHUD.signals.is_joining = true
coopHUD.on_player_init()
coopHUD.initHudTables()
