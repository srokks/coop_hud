function coopHUD.test()
	auto_save()
	--draw_on_screen('test ',120,2)
	if coopHUD.players[1] == nil then
		coopHUD.on_start(_, true)
	end
	if Input.IsButtonTriggered(Keyboard.KEY_B, 0) then
		spawn_passive_collectible(5)
	end
	if Input.IsButtonTriggered(Keyboard.KEY_K, 0) then

	end
	if Input.IsButtonTriggered(Keyboard.KEY_I, 0) then
		spawn_random_pickups(8)
	end
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.test)
function coopHUD.cmd(_, cmd, params)
	if string.match(cmd, 'hud') then
		--do whathever
	end
end
coopHUD:AddCallback(ModCallbacks.MC_EXECUTE_CMD, coopHUD.cmd)
function spawn_passive_collectible(quantity)
	if quantity == nil then
		quantity = 1
	end
	for i = 1, quantity do
		local item = Isaac.GetItemConfig():GetCollectible(math.random(1,
		                                                              Isaac.GetItemConfig():GetCollectibles().Size - 1))
		if item.Type == ItemType.ITEM_ACTIVE or item.Type == ItemType.ITEM_TRINKET then
			spawn_passive_collectible()
		else
			Isaac.ExecuteCommand('spawn 5.100.' .. tostring(item.ID))
		end
	end

end
function spawn_random_pickups(quantity)
	local pickup_types = { '10', '20', '30', '40', '70', '90', '300' }
	if quantity == nil then
		quantity = 1
	end
	for i = 1, quantity do
		Isaac.ExecuteCommand('spawn 5.' .. pickup_types[math.random(1, #pickup_types)])
	end
end
function auto_save()
	---___INVENTORY AUTO SAVE FEATURE
	local curTime = Game():GetFrameCount()
	local msecs = curTime % 30 * (10 / 3) -- turns the millisecond value range from [0 to 30] to [0 to 100]
	local secs = math.floor(curTime / 30) % 60
	local mins = math.floor(curTime / 30 / 60) % 60
	local hours = math.floor(curTime / 30 / 60 / 60) % 60
	if secs % 5 == 0 and msecs == 0 then
		coopHUD.save_options()
		--coopHUD.debug_str('Auto saved options!', true)
	end
end

function change_player_types(player_type)
	for _, player in pairs(coopHUD.players) do
		player.entPlayer:ChangePlayerType(player_type)
	end
end
---@param sprite coopHUD.Inventory
function sprite_render_test(sprite)
	local pos = Vector(200, 32 * coopHUD.players_config.small.scale.Y)
	-- main item render
	sprite:render(pos, false, coopHUD.players_config.small.scale, false)
	sprite:render(pos, true, coopHUD.players_config.small.scale, false)
	sprite:render(pos, false, coopHUD.players_config.small.scale, true)
	--
	pos = Vector(300, 0)
	local off = sprite:render(pos, false, coopHUD.players_config.small.scale, false)
	sprite:render(pos + Vector(off.X, 0), false, coopHUD.players_config.small.scale, false)
	sprite:render(pos + Vector(0, off.Y), false, coopHUD.players_config.small.scale, false)
	--
end

function boc_render_test(player)
	local pos = Vector(150, 100)
	coopHUD.BoC:render(player, pos, false, coopHUD.players_config.small.scale, false)
	--
	coopHUD.BoC:render(player, pos, true, coopHUD.players_config.small.scale, false)
	--
	coopHUD.BoC:render(player, pos, false, coopHUD.players_config.small.scale, true)
end

---@param player coopHUD.Player
function player_head_render_test(player)
	local pos = Vector(100, 100)
	local off = player.player_head:render(pos, false, coopHUD.players_config.small.scale, false)
	player.player_head:render(pos + Vector(off.X, 0), false, coopHUD.players_config.small.scale, false)
	player.player_head:render(pos + Vector(0, off.Y), false, coopHUD.players_config.small.scale, false)
	--player.player_head:render(pos,true,coopHUD.players_config.small.scale,false)
	--player.player_head:render(pos,false,coopHUD.players_config.small.scale,true)
end

---@param player coopHUD.Player
function poop_render_test(player)
	local pos = Vector(150, 100)
	--
	--player.first_pocket:render(pos, false, coopHUD.players_config.small.scale, false)
	--player.first_pocket:render(pos, true, coopHUD.players_config.small.scale, false)
	--player.first_pocket:render(pos, false, coopHUD.players_config.small.scale, true)
	--
	local off = player.first_pocket:render(pos, false, coopHUD.players_config.small.scale, false)
	player.first_pocket:render(pos + Vector(off.X, 0), false, coopHUD.players_config.small.scale, false)
	player.first_pocket:render(pos + Vector(0, off.Y), false, coopHUD.players_config.small.scale, false)
end
function draw_on_screen(str, pos_x, pos_y)
	coopHUD.HUD.fonts.lua_mini_lined:DrawString(tostring(str), pos_x, pos_y, KColor(1, 1, 1, 1), 0, false)
end

---Adds dummy collectibles to test render of collectibles
---@param player coopHUD.Player
---@param no number|1
function add_dummy_collectibles(player, no)
	if no == nil then no = 1 end
	for i = 1, no do
		local item_id = math.random(1, Isaac.GetItemConfig():GetCollectibles().Size - 1)
		coopHUD.debug_str('Added dummy item: ' .. coopHUD.langAPI.getItemNameByID(item_id) .. ' to player ' .. player.game_index,
		                  true)
		table.insert(player.collectibles,
		             coopHUD.Item(player, -1,
		                          item_id))
	end
end
