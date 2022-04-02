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
coopHUD.HUD.font_color = KColor(1, 1, 1, 1) -- holds hud font color
function coopHUD.HUD.init()
	coopHUD.HUD.coins = coopHUD.RunInfo(coopHUD.RunInfo.COIN)
	coopHUD.HUD.bombs = coopHUD.RunInfo(coopHUD.RunInfo.BOMB)
	coopHUD.HUD.keys = coopHUD.RunInfo(coopHUD.RunInfo.KEY)
	coopHUD.HUD.beth = coopHUD.RunInfo(coopHUD.RunInfo.BETH)
	coopHUD.HUD.t_beth = coopHUD.RunInfo(coopHUD.RunInfo.T_BETH)
	coopHUD.HUD.poop = coopHUD.RunInfo(coopHUD.RunInfo.POOP)
	coopHUD.HUD.greed_waves = coopHUD.RunInfo(coopHUD.RunInfo.GREED_WAVES)
	-- Stats icons
	coopHUD.HUD.speed = coopHUD.Stat(nil, coopHUD.Stat.SPEED, true)
	coopHUD.HUD.tears_delay = coopHUD.Stat(nil, coopHUD.Stat.TEARS_DELAY, true)
	coopHUD.HUD.damage = coopHUD.Stat(nil, coopHUD.Stat.DAMAGE, true)
	coopHUD.HUD.range = coopHUD.Stat(nil, coopHUD.Stat.RANGE, true)
	coopHUD.HUD.shot_speed = coopHUD.Stat(nil, coopHUD.Stat.SHOT_SPEED, true)
	coopHUD.HUD.luck = coopHUD.Stat(nil, coopHUD.Stat.LUCK, true)
	-- Deals icons
	coopHUD.HUD.angel = coopHUD.Stat(coopHUD.HUD, coopHUD.Stat.ANGEL, true)
	coopHUD.HUD.devil = coopHUD.Stat(coopHUD.HUD, coopHUD.Stat.DEVIL, true)
	coopHUD.HUD.planetarium = coopHUD.Stat(coopHUD.HUD, coopHUD.Stat.PLANETARIUM, true)

end

--coopHUD.HUD.poop = coopHUD.RunInfo(coopHUD.RunInfo.POOP)
---coopHUD.HUD.render - renders specifics to the game like no of coins/keys/bombs
---Todo: based on options.show_dest_info - show info about run destination
---Todo: based on options.show_difficulty
---Todo: render streak on pickup item/pill_use/
---Todo: render floor info
---Todo: render stuff page in center
function coopHUD.HUD.render()
	if coopHUD.HUD.coins then
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
		------ DEALS RENDER`
		---TODO:deals.hide on battle option and signal
		if coopHUD.options.deals.show then
			local deals_pos = Vector(middle_bot_anchor.X, middle_bot_anchor.Y + 4)
			deals_pos.X = deals_pos.X - coopHUD.HUD.angel:getOffset().X
			if not coopHUD.options.deals.show_planetarium then
				deals_pos.X = deals_pos.X + coopHUD.HUD.angel:getOffset().X / 2
			end
			deals_pos.X = deals_pos.X - coopHUD.HUD.devil:getOffset().X / 2
			-- ANGEL
			coopHUD.HUD.angel:render(deals_pos, false, true)
			-- DEVIL
			off = coopHUD.HUD.devil:render(Vector(deals_pos.X + coopHUD.HUD.angel:getOffset().X, deals_pos.Y),
			                               false, true)
			--PLANETARIUM
			if coopHUD.options.deals.show_planetarium then
				coopHUD.HUD.planetarium:render(Vector(deals_pos.X + coopHUD.HUD.angel:getOffset().X + coopHUD.HUD.devil:getOffset().X,
				                                      deals_pos.Y),
				                               false, true)
			end
		end
		------ TIMER RENDER
		-- FIX: on extended map and big right player timer is over rendered
		-- Code from TBoI Api by wofsauge
		local timer_offset = Vector(1, 1)
		local curTime = Game():GetFrameCount()
		local msecs = curTime % 30 * (10 / 3) -- turns the millisecond value range from [0 to 30] to [0 to 100]
		local secs = math.floor(curTime / 30) % 60
		local mins = math.floor(curTime / 30 / 60) % 60
		local hours = math.floor(curTime / 30 / 60 / 60) % 60
		--
		local time_string = string.format('Time: %.2i:%.2i:%.2i', hours, mins, secs) -- formats
		local f_col = KColor(0.5, 0.5, 0.5, 1) -- Default font color font color with 0.5 alpha
		if coopHUD.options.timer_always_on or coopHUD.signals.map then
			coopHUD.HUD.fonts.team_meat_10:DrawString(time_string,
			                                          middle_bot_anchor.X, 0,
			                                          f_col, 1, true)
			timer_offset.Y = coopHUD.HUD.fonts.team_meat_10:GetBaselineHeight()
		end
		---- STAT ICONS
		coopHUD.HUD.stat_anchors = {} -- holds anchors for stats icons
		table.insert(coopHUD.HUD.stat_anchors, {anchor = Vector(coopHUD.anchors.top_left.X, 100),mirrored = false}) --TODO: proper position
		if #coopHUD.players >= 2 then
			table.insert(coopHUD.HUD.stat_anchors, {anchor = Vector(coopHUD.anchors.top_left.X, 100),mirrored = true}) --TODO: proper position
		end
		local off = Vector(0, 0)
		if coopHUD.options.stats.show then
			for _, stat_anchor in pairs(coopHUD.HUD.stat_anchors) do
				local temp_stat_pos = Vector(stat_anchor.anchor.X, stat_anchor.anchor.Y)
				off = coopHUD.HUD.speed:render(temp_stat_pos)
				temp_stat_pos.Y = temp_stat_pos.Y + off.Y
				off = coopHUD.HUD.tears_delay:render(temp_stat_pos)
				temp_stat_pos.Y = temp_stat_pos.Y + off.Y
				off = coopHUD.HUD.damage:render(temp_stat_pos)
				temp_stat_pos.Y = temp_stat_pos.Y + off.Y
				coopHUD.HUD.range:render(temp_stat_pos)
				temp_stat_pos.Y = temp_stat_pos.Y + off.Y
				coopHUD.HUD.shot_speed:render(temp_stat_pos)
				temp_stat_pos.Y = temp_stat_pos.Y + off.Y
				coopHUD.HUD.luck:render(temp_stat_pos)
			end
		end
	end
end