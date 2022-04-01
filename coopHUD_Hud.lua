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
	local color = KColor(1, 1, 1, 1)
	local middle_bot_anchor = Vector((Isaac.GetScreenWidth() / 2) - 14, Isaac.GetScreenHeight() - 14) -- middle of screen
	local offset = Vector(0, 0)
	--
	local bomb_pos = Vector(middle_bot_anchor.X,middle_bot_anchor.Y)
	if coopHUD.HUD.poop.sprite then
		bomb_pos.X = bomb_pos.X - (24*1.25) / 2
	end
	offset = coopHUD.HUD.bombs:render(bomb_pos)
	bomb_pos = Vector((Isaac.GetScreenWidth() / 2) - 14, Isaac.GetScreenHeight() - 14)
	if  offset.X > 0 then
		bomb_pos.X = bomb_pos.X + 24/2
	end
	coopHUD.HUD.poop:render(bomb_pos)
	--
	local coin_pos = Vector(middle_bot_anchor.X-24 * 1.25, middle_bot_anchor.Y)
	if coopHUD.HUD.poop.sprite and offset.X > 0 then
		coin_pos.X = coin_pos.X - 12
	end
	coopHUD.HUD.coins:render(coin_pos)
	--
	local keys_pos = Vector(middle_bot_anchor.X+24, middle_bot_anchor.Y)
	if coopHUD.HUD.poop.sprite and offset.X > 0 then
		keys_pos.X = middle_bot_anchor.X+36
	end
	coopHUD.HUD.keys:render(keys_pos)
	--
	local beth_pos = Vector(middle_bot_anchor.X+24, middle_bot_anchor.Y)
	coopHUD.HUD.beth:render(beth_pos)
end