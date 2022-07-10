-- INPUT TRIGGERS
local btn_held = 0
local pill_held = 0
function coopHUD.inputs_signals()
	-- Trigger for turning on/off coop hud on `H` key
	if coopHUD.options.h_trigger then
		if Input.IsButtonTriggered(Keyboard.KEY_H, 0) then
			if coopHUD.options.onRender then
				coopHUD.options.onRender = false
			else
				coopHUD.options.onRender = true
			end
			coopHUD.save_options()
			print('Saved!')
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
	--
	local icount = nil
	-- Bag of crafting - creation item logic -- based on External Item Description mod by Wolsauge
	if pill_card_pressed and coopHUD.players[pill_card_pressed].bag_of_crafting then
		local animationName = coopHUD.players[pill_card_pressed].entPlayer:GetSprite():GetAnimation()
		if pill_card_pressed and string.match(animationName, "PickupWalk")
				and #coopHUD.players[pill_card_pressed].bag_of_crafting == 8 then
			pill_held = pill_held + 1
			if pill_held < 30 then
				icount = coopHUD.players[pill_card_pressed].entPlayer:GetCollectibleCount()
			end
		else
			if pill_card_pressed and pill_held >= 30 and (string.match(animationName, "Walk")
					and not string.match(animationName, "Pickup")
					or (coopHUD.players[pill_card_pressed].entPlayer:GetCollectibleCount() ~= icount)) then
				coopHUD.players[pill_card_pressed].bag_of_crafting = {} -- resets bag of crafting
				--adds collectible to inventory
				local item_queue = Isaac.GetItemConfig():GetCollectible(coopHUD.players[pill_card_pressed].crafting_result.id)
				if item_queue == nil then return end
				if item_queue.Type == ItemType.ITEM_ACTIVE then
				elseif item_queue.Type == ItemType.ITEM_TRINKET then
				else
					-- normal characters add collectible
					table.insert(coopHUD.players[pill_card_pressed].collectibles,
					             coopHUD.Item(coopHUD.players[pill_card_pressed], -1,
					                          item_queue.ID)) -- add picked up item to collectibles
				end
				--____ Flashes triggers streak text with picked up name
				local streak_main_line = item_queue.Name
				local streak_sec_line = item_queue.Description
				if coopHUD.langAPI then
					--	 checks if langAPI loaded
					if string.sub(streak_main_line, 0, 1) == "#" then
						--if begins with # get name from api
						streak_main_line = coopHUD.langAPI.getItemName(string.sub(streak_main_line, 2))
					end
					if string.sub(streak_sec_line, 0, 1) == "#" then
						--if begins with # get desc from api
						streak_sec_line = coopHUD.langAPI.getItemName(string.sub(streak_sec_line, 2))
					end
				end
				-- triggers streak on item pickup
				coopHUD.Streak(false, coopHUD.Streak.ITEM, streak_main_line, streak_sec_line, true,
				               coopHUD.players[pill_card_pressed].font_color)
				coopHUD.BoC.update(coopHUD.players[pill_card_pressed])
				pill_held = 0
			else
			end
		end
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
	for i = 1, #coopHUD.players do
		if coopHUD.players[i] then
			coopHUD.on_player_init()
			if coopHUD.options.onRender and not paused and not coopHUD.signals.is_joining then
				if Game():GetHUD():IsVisible() then
					Game():GetHUD():SetVisible(false)
				end
				coopHUD.players[i]:render()
				coopHUD.HUD.render()
			end
			if not coopHUD.options.onRender or coopHUD.signals.is_joining then
				if not Game():GetHUD():IsVisible() then
					Game():GetHUD():SetVisible(true)
				end
			end
		end
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.render)