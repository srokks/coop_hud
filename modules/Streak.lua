coopHUD.Streak = {}
-- STREAK TYPES
coopHUD.Streak.FLOOR = 0
coopHUD.Streak.PICKUP = 1
coopHUD.Streak.font_color = KColor(1, 1, 1, 1)
coopHUD.Streak.anim_path = "gfx/ui/ui_streak.anm2"
setmetatable(coopHUD.Streak, {
	__call = function(cls, ...)
		return cls.trigger(...)
	end,
})
function coopHUD.Streak.getSprite()
	local sprite = Sprite()
	sprite:Load(coopHUD.Streak.anim_path, true)
	sprite:SetFrame('Text', 0)
	return sprite
end
coopHUD.Streak.sprite = coopHUD.Streak.getSprite() -- inits streak sprite
coopHUD.Streak.signal = false -- trigger signal
function coopHUD.Streak.render()
	if coopHUD.Streak.sprite and coopHUD.Streak.first_line and coopHUD.Streak.first_line ~= '' and not coopHUD.Streak.sprite:IsFinished() then
		-- prevents from no sprite loaded error and rendering when no passed first line or empty
		local cur_frame = coopHUD.Streak.sprite:GetFrame()
		if cur_frame > 16 and coopHUD.Streak.signal then
			-- controls enter animation and that sprite stays on screen
			local streak_span = 30 -- controls how long streak will be rendered after signal = nil
			if coopHUD.Streak.signal + streak_span < Game():GetFrameCount() then
				coopHUD.Streak.signal = false -- resets signals and lets continue to render sprite
			end
		else
			coopHUD.Streak.sprite:Update() -- update sprite frame
		end
		local temp_pos = Vector(Isaac.GetScreenWidth() / 2, 48) -- defines  with vertical anchor up
		if coopHUD.Streak.down_anchor then
			-- if triggered with true down_anchor
			temp_pos.Y = Isaac.GetScreenHeight() - 48 -- changes vertical anchor down
		end
		if coopHUD.Streak.first_line then
			coopHUD.Streak.sprite:RenderLayer(0, temp_pos)
		end
		if cur_frame > 4 and cur_frame < 65 then
			-- prevents from showing text when sprite on in/out state
			if coopHUD.Streak.first_line then
				local f_color = coopHUD.Streak.font_color
				if coopHUD.Streak.type == coopHUD.Streak.FLOOR then
					f_color = KColor(1, 1, 1, 1)
				end
				coopHUD.HUD.fonts.upheaval:DrawString(coopHUD.Streak.first_line,
				                                      temp_pos.X,
				                                      temp_pos.Y - coopHUD.HUD.fonts.upheaval:GetBaselineHeight() * 0.75,
				                                      f_color, 1, true)
			end
			if coopHUD.Streak.second_line and coopHUD.Streak.second_line ~= '' then
				local line_off = Vector(0, 12)
				local f_color = coopHUD.Streak.font_color
				local font = coopHUD.HUD.fonts.pft
				if coopHUD.Streak.type == coopHUD.Streak.FLOOR then
					coopHUD.Streak.sprite:RenderLayer(1, temp_pos)
					line_off.Y = 19
					f_color = KColor(0, 0, 0, 1)
					font = coopHUD.HUD.fonts.team_meat_10
				end
				font:DrawString(coopHUD.Streak.second_line,
				                temp_pos.X, temp_pos.Y + line_off.Y,
				                f_color, 1, true)
			end
		end
	end
end
function coopHUD.Streak.trigger(down_anchor, type, first_line, second_line, force_reset, font_color)
	coopHUD.Streak.signal = Game():GetFrameCount() -- sets streak signal as current frame num
	if coopHUD.Streak.sprite:IsFinished() or force_reset then
		-- if streak is finished play animation
		coopHUD.Streak.sprite:Play("Text", true)
		coopHUD.Streak.type = type
		coopHUD.Streak.down_anchor = down_anchor -- defines if streak will render down screen or top screen
		coopHUD.Streak.first_line = first_line -- gets line string from passed parameters
		coopHUD.Streak.second_line = second_line
		if font_color then
			coopHUD.Streak.font_color = font_color
		else
			coopHUD.Streak.font_color = KColor(1, 1, 1, 1)
		end
		if type == coopHUD.Streak.FLOOR then
			-- in case of floor streak ignore passed strings
			coopHUD.Streak.first_line = Game():GetLevel():GetName() -- and get floor specs
			coopHUD.Streak.second_line = Game():GetLevel():GetCurseName()
		end
	end
end
--