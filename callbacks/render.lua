-- INPUT TRIGGERS
local btn_held = 0
local pill_held = 0
function coopHUD.inputs_signals()
	-- Trigger for turning on/off coop hud on `H` key
	if coopHUD.options.h_trigger_key > -1 then
		if Input.IsButtonTriggered(coopHUD.options.h_trigger_key, 0) then
			if coopHUD.options.onRender then
				coopHUD.options.onRender = false
			else
				coopHUD.options.onRender = true
			end
		end
	end
	-- Trigger for turning on/off timer on `T` key
	if Input.IsButtonTriggered(Keyboard.KEY_T, 0) then
		if coopHUD.options.timer_always_on then
			coopHUD.options.timer_always_on = false
		else
			coopHUD.options.timer_always_on = true
		end
	end
	local mapPressed = false
	local pill_card_pressed = false
	for i = 0, Game():GetNumPlayers() - 1 do
		local controller_index = Isaac.GetPlayer(i).ControllerIndex
		local player_index = coopHUD.Player.getIndexByControllerIndex(controller_index)
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, controller_index) then
			mapPressed = false
			mapPressed = player_index
		end
		-- DROP ACTION
		if Input.IsActionTriggered(ButtonAction.ACTION_DROP, controller_index) then
			--- TAINTED ISAAC - inventory shift
			if coopHUD.players[player_index].entPlayer:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
				if coopHUD.players[player_index].collectibles ~= nil then
					local collectibles = {}
					for i = 2, #coopHUD.players[player_index].collectibles do
						table.insert(collectibles, coopHUD.players[player_index].collectibles[i])
					end
					table.insert(collectibles, coopHUD.players[player_index].collectibles[1])
					coopHUD.players[player_index].collectibles = collectibles
				end
			end
			--- TAINTED CAIN - bag of crafting shift
			if coopHUD.players[player_index].entPlayer:GetPlayerType() == PlayerType.PLAYER_CAIN_B then
				--shift player bag of crafting if have
				if coopHUD.players[player_index].bag_of_crafting ~= nil then
					local new_bag = {}
					for i = 2, #coopHUD.players[player_index].bag_of_crafting do
						table.insert(new_bag, coopHUD.players[player_index].bag_of_crafting[i])
					end
					table.insert(new_bag, coopHUD.players[player_index].bag_of_crafting[1])
					coopHUD.players[player_index].bag_of_crafting = new_bag
				end
			end
			--- D INFINITY - shift
			local animationName = coopHUD.players[player_index].entPlayer:GetSprite():GetAnimation()
			if coopHUD.players[player_index].active_item.id == CollectibleType.COLLECTIBLE_D_INFINITY and not coopHUD.players[player_index].entPlayer:IsHoldingItem() then
				coopHUD.players[player_index].active_item.d_infinity_charge = coopHUD.players[player_index].active_item.d_infinity_charge + 1
				if coopHUD.players[player_index].active_item.d_infinity_charge == 10 then
					coopHUD.players[player_index].active_item.d_infinity_charge = 0
				end
			end
		end
		-- PILL CARD ACTION
		if Input.IsActionPressed(ButtonAction.ACTION_PILLCARD, controller_index) then
			pill_card_pressed = player_index
		end
	end
	-- MAP BUTTON
	local pressTime = 0.5
	if mapPressed then
		btn_held = btn_held + 1 / 60
		if btn_held > pressTime then
			coopHUD.signals.map = mapPressed
			coopHUD.Streak(true, coopHUD.Streak.FLOOR)
			coopHUD.players[mapPressed].signals.map_btn = true
		end
	else
		if coopHUD.signals.map then
			coopHUD.players[coopHUD.signals.map].signals.map_btn = false
		end
		coopHUD.signals.map = false
		btn_held = 0
	end
end
-- MAIN RENDER
function coopHUD.render()
	coopHUD.updateAnchors()
	coopHUD.inputs_signals()
	if #coopHUD.players > 4 then
		-- prevents to render if more than 4 players for now
		coopHUD.options.onRender = false
	end
	-- _____ Main render function
	local paused = Game():IsPaused()
	if coopHUD.players[1] then
		coopHUD.on_player_init()
		if coopHUD.options.onRender and not paused and not coopHUD.signals.is_joining then
			if Game():GetHUD():IsVisible() then
				Game():GetHUD():SetVisible(false)
			end
			for i = 1, #coopHUD.players do
				coopHUD.players[i]:render()
			end
			coopHUD.HUD.render()
		end
		if not coopHUD.options.onRender or coopHUD.signals.is_joining then
			if not Game():GetHUD():IsVisible() and not paused then
				Game():GetHUD():SetVisible(true)
			end
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)