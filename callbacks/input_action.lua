--_____ INPUTS ACTION_JOINMULTIPLAYER
function coopHUD.on_join_signal()
	-- ACTION_JOINMULTIPLAYER
	if not Game():IsPaused() then
		for i = 0, 8 do
			if Input.IsActionTriggered(ButtonAction.ACTION_JOINMULTIPLAYER, i)
					and coopHUD.Player.getIndexByControllerIndex(i) < 0 -- checks if player is already in tables
					and not coopHUD.signals.is_joining
					and Game():GetRoom():IsFirstVisit() == true -- you can join into coop only on first floor of game
					and Game():GetLevel():GetAbsoluteStage() == LevelStage.STAGE1_1 -- on first level
					and Game():GetLevel():GetCurrentRoomIndex() == Game():GetLevel():GetStartingRoomIndex() then
				--
				coopHUD.signals.is_joining = true
			end
			-- Catches back button when on
			if Input.IsActionTriggered(ButtonAction.ACTION_MENUBACK, i) and coopHUD.signals.is_joining then
				coopHUD.signals.is_joining = false
			end
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_INPUT_ACTION, coopHUD.on_join_signal)