---@class coopHUD.PlayerHead
---@type coopHUD.PlayerHead | fun(parent:coopHUD.Player):coopHUD.PlayerHead
---@return coopHUD.PlayerHead
coopHUD.PlayerHead = {}
coopHUD.PlayerHead.__index = coopHUD.PlayerHead
coopHUD.PlayerHead.anim_path = "gfx/ui/coop menu.anm2"
setmetatable(coopHUD.PlayerHead, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@see coopHUD.PlayerHead
---@private
function coopHUD.PlayerHead.new(parent)
	local self = setmetatable({}, coopHUD.PlayerHead)
	self.parent = parent
	self.name = 'P' .. tostring(self.parent.game_index - coopHUD.essau_no + 1)
	self.sprite = self:getSprite()
	return self
end
function coopHUD.PlayerHead:getSprite()
	local player_type = self.parent.entPlayer:GetPlayerType()
	if self.parent.entPlayer.Variant == 1 then
		return nil
	end -- prevents when old coop ghost
	if player_type == 40 then
		player_type = 36
	end
	if 0 <= player_type and player_type <= 37 then
		local sprite = Sprite()
		sprite:Load(coopHUD.PlayerHead.anim_path, true)
		sprite:SetFrame('Main', player_type + 1)
		sprite:ReplaceSpritesheet(1, "/gfx/ui/blank.png")
		sprite:LoadGraphics()
		return sprite
	else
		return nil
	end
end
--- Renders item sprite in current position
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@return Vector offset where render next sprite
function coopHUD.PlayerHead:render(pos, mirrored, scale, down_anchor)
	local offset = Vector(0, 0)
	if self.sprite then
		local temp_pos = Vector(pos.X, pos.Y)
		local text_pos = Vector(pos.X, pos.Y)
		local sprite_scale = scale
		--
		if sprite_scale == nil then
			sprite_scale = Vector(1, 1)
		end
		--
		if mirrored then
			temp_pos.X = temp_pos.X - (8 * sprite_scale.X)
			text_pos.X = text_pos.X - (8 * sprite_scale.X)
			offset.X = (-16 * 1.5) * sprite_scale.X
		else
			temp_pos.X = temp_pos.X + (8 * sprite_scale.X)
			text_pos.X = text_pos.X + (8 * sprite_scale.X)
			offset.X = (18 * sprite_scale.X)
		end
		--
		if down_anchor then
			temp_pos.Y = temp_pos.Y - (coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() * sprite_scale.Y)
			text_pos.Y = text_pos.Y - (coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() * sprite_scale.Y)
			offset.Y = (-16 * sprite_scale.Y) - coopHUD.HUD.fonts.lua_mini:GetBaselineHeight()
		else
			temp_pos.Y = temp_pos.Y + (coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() * sprite_scale.Y)
			text_pos.Y = text_pos.Y + (16 * sprite_scale.Y)
			offset.Y = (16 * sprite_scale.Y) + coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() * sprite_scale.Y
		end
		--
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
		coopHUD.HUD.fonts.lua_mini:DrawStringScaled(self.name,
		                                            text_pos.X, text_pos.Y,
		                                            sprite_scale.X, sprite_scale.Y,
		                                            self.parent.font_color, 1, true)
	end
	return offset
end