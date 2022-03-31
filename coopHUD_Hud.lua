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
--Todo:render items
--Todo:render chances
--Todo:render streak
--Todo:render

coopHUD.HUD.coins = coopHUD.RunInfo(coopHUD.RunInfo.COIN)
coopHUD.HUD.bombs = coopHUD.RunInfo(coopHUD.RunInfo.BOMB)
coopHUD.HUD.keys = coopHUD.RunInfo(coopHUD.RunInfo.KEY)

---coopHUD.HUD.render - renders specifics to the game like no of coins/keys/bombs
---Todo: based on options.show_dest_info - show info about run destination
---Todo: based on options.show_difficulty
---Todo: render streak on pickup item/pill_use/
---Todo: render floor info
---Todo: render stuff page in center
function coopHUD.HUD.render()
	local color = KColor(1, 1, 1, 1)
	local anchor = Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() - 16) -- middle of screen
	local text = ''
	--
	local is_tainted_blue_baby
	local is_bethany
	local is_tainted_bethany
	print(coopHUD.RunInfo.COIN)
	print(coopHUD.RunInfo.BOMB)
	print(coopHUD.RunInfo.KEY)
end