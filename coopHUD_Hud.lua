coopHUD.HUD = {}
coopHUD.HUD.fonts = {}
coopHUD.HUD.fonts.lua_mini = Font()
coopHUD.HUD.fonts.lua_mini:Load('font/luamini.fnt')
coopHUD.HUD.fonts.pft = Font()
coopHUD.HUD.fonts.pft:Load("font/pftempestasevencondensed.fnt")
coopHUD.HUD.fonts.lua_mini_lined = Font()
coopHUD.HUD.fonts.lua_mini_lined:Load("font/luaminioutlined.fnt")
coopHUD.HUD.fonts.team_meat_10 = Font()
coopHUD.HUD.fonts.team_meat_10:Load("font/teammeatfont10.fnt")
function coopHUD.HUD.init()
	coopHUD.HUD.coins = coopHUD.RunInfo(coopHUD.RunInfo.COIN)
	coopHUD.HUD.bombs = coopHUD.RunInfo(coopHUD.RunInfo.BOMB)
	coopHUD.HUD.keys = coopHUD.RunInfo(coopHUD.RunInfo.KEY)
	coopHUD.HUD.beth = coopHUD.RunInfo(coopHUD.RunInfo.BETH)
	coopHUD.HUD.t_beth = coopHUD.RunInfo(coopHUD.RunInfo.T_BETH)
	coopHUD.HUD.poop = coopHUD.RunInfo(coopHUD.RunInfo.POOP)
	coopHUD.HUD.greed_waves = coopHUD.RunInfo(coopHUD.RunInfo.GREED_WAVES)
end

--coopHUD.HUD.poop = coopHUD.RunInfo(coopHUD.RunInfo.POOP)
---coopHUD.HUD.render - renders specifics to the game like no of coins/keys/bombs
---Todo: based on options.show_dest_info - show info about run destination
---Todo: based on options.show_difficulty
---Todo: render streak on pickup item/pill_use/
---Todo: render floor info
---Todo: render stuff page in center
function coopHUD.HUD.render()
	local middle_bot_anchor = Vector((Isaac.GetScreenWidth() / 2), Isaac.GetScreenHeight() - 14) -- middle of screen
	local offset = Vector(0, 0)
	--
	local temp_pos = Vector(middle_bot_anchor.X, middle_bot_anchor.Y)
	temp_pos.X = temp_pos.X - coopHUD.HUD.coins:getOffset().X
	temp_pos.X = temp_pos.X - coopHUD.HUD.bombs:getOffset().X / 2
	temp_pos.X = temp_pos.X - coopHUD.HUD.poop:getOffset().X / 2
	temp_pos.X = temp_pos.X - coopHUD.HUD.beth:getOffset().X / 2
	temp_pos.X = temp_pos.X - coopHUD.HUD.t_beth:getOffset().X / 2
	offset = coopHUD.HUD.coins:render(temp_pos)
	temp_pos.X = temp_pos.X + offset.X
	offset = coopHUD.HUD.bombs:render(temp_pos)
	temp_pos.X = temp_pos.X + offset.X
	offset = coopHUD.HUD.poop:render(temp_pos)
	temp_pos.X = temp_pos.X + offset.X
	offset = coopHUD.HUD.keys:render(temp_pos)
	temp_pos.X = temp_pos.X + offset.X
	offset = coopHUD.HUD.beth:render(temp_pos)
	temp_pos.X = temp_pos.X + offset.X
	offset = coopHUD.HUD.t_beth:render(temp_pos)
	--
	local keys_pos = Vector(middle_bot_anchor.X, middle_bot_anchor.Y)
	if poop_offset.X > 0 and bomb_offset.X > 0 then
		keys_pos.X = middle_bot_anchor.X + 28
	else
		keys_pos.X = middle_bot_anchor.X + 14
	end
	coopHUD.HUD.keys:render(keys_pos)
	--
	local beth_pos = Vector(middle_bot_anchor.X, middle_bot_anchor.Y)
	if poop_offset.X > 0 and bomb_offset.X > 0 then
		beth_pos.X = middle_bot_anchor.X + 28 + 28
	else
		beth_pos.X = middle_bot_anchor.X + 28 + 14
	end
	coopHUD.HUD.beth:render(beth_pos)
	--
	local beth_pos = Vector(middle_bot_anchor.X, middle_bot_anchor.Y)
	if poop_offset.X > 0 and bomb_offset.X > 0 then
		beth_pos.X = middle_bot_anchor.X + 28 + 28
	else
		beth_pos.X = middle_bot_anchor.X + 28 + 14
	end
	coopHUD.HUD.beth:render(beth_pos)
end