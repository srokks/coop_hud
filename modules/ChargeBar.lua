---@class coopHUD.ChargeBar
---@field anim_path string path to animation
---@field sprite_empty Sprite
---@field sprite_full Sprite
---@type coopHUD.ChargeBar | fun(parent_item:coopHUD.Item):coopHUD.ChargeBar
coopHUD.ChargeBar = {}
coopHUD.ChargeBar.__index = coopHUD.ChargeBar
coopHUD.ChargeBar.anim_path = "gfx/ui/ui_chargebar.anm2"
--
coopHUD.ChargeBar.sprite_empty = Sprite()
coopHUD.ChargeBar.sprite_empty:Load(coopHUD.ChargeBar.anim_path, true)
coopHUD.ChargeBar.sprite_empty:SetFrame('BarEmpty', 0)
--
--
setmetatable(coopHUD.ChargeBar, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@param parent_item coopHUD.Item
---@private
function coopHUD.ChargeBar.new(parent_item)
	---@type coopHUD.ChargeBar
	local self = setmetatable({}, coopHUD.ChargeBar)
	---@type coopHUD.Item
	self.parent_item = parent_item
	if self.parent_item.id == 0 or self.parent_item.slot < 0 or self.parent_item.parent.entPlayer == false then
		return nil
	end
	self.max_charge = self:getMaxCharge()
	if self.max_charge == 0 then
		return nil
	end
	--
	self.normal_charge = self.parent_item.parent.entPlayer:GetActiveCharge(self.parent_item.slot)
	self.battery_charge = self.parent_item.parent.entPlayer:GetBatteryCharge(self.parent_item.slot)
	self.beth_charge = self.parent_item.parent.entPlayer:GetEffectiveBloodCharge() + self.parent_item.parent.entPlayer:GetEffectiveSoulCharge()
	--
	self.bar_sprite = self:getChargeSprite()
	self.overlay_sprite = self:getOverlaySprite()
	self.beth_bar_sprite = self:getBethSprite()
	self.overcharge_bar_sprite = self:getOverChargeSprite()
	--
	self.flash_trigger = nil
	return self
end
---@param self coopHUD.ChargeBar
---@return Sprite
function coopHUD.ChargeBar.getChargeSprite(self)
	local sprite = Sprite()
	sprite:Load(self.anim_path)
	sprite:SetFrame('BarFull', 0)
	if (self.max_charge > 1 and self.max_charge < 7) or self.max_charge == 8 or self.max_charge == 12 then
		sprite:SetOverlayFrame("BarOverlay" .. self.max_charge, 0)
	else
		sprite:SetOverlayFrame("BarOverlay1", 0)
	end
	return sprite
end
function coopHUD.ChargeBar.getOverlaySprite(self)
	local sprite = Sprite()
	sprite:Load(self.anim_path)
	if (self.max_charge > 1 and self.max_charge < 7) or self.max_charge == 8 or self.max_charge == 12 then
		sprite:SetOverlayFrame("BarOverlay" .. self.max_charge, 0)
	else
		sprite:SetOverlayFrame("BarOverlay1", 0)
	end
	return sprite
end
---@param self coopHUD.ChargeBar
function coopHUD.ChargeBar.getBethSprite(self)
	local sprite = Sprite()
	if self.parent_item.parent.entPlayer then
		local player_type = self.parent_item.entPlayer:GetPlayerType()
		local color = Color(1, 1, 1, 1, 0, 0, 0)
		if player_type == PlayerType.PLAYER_BETHANY or player_type == PlayerType.PLAYER_BETHANY_B then
			if player_type == PlayerType.PLAYER_BETHANY then
				color:SetColorize(0.8, 0.9, 1.8, 1)
			elseif player_type == PlayerType.PLAYER_BETHANY_B then
				color:SetColorize(1, 0.2, 0.2, 1)
			end
			sprite:Load(self.anim_path, true)
			sprite.Color = color
			sprite:SetFrame('BarFull', 0)
			if (self.max_charge > 1 and self.max_charge < 7) or self.max_charge == 8 or self.max_charge == 12 then
				sprite:SetOverlayFrame("BarOverlay" .. self.max_charge, 0)
			else
				sprite:SetOverlayFrame("BarOverlay1", 0)
			end
			return sprite
		else
			return nil
		end
	else
		return nil
	end
end
---@param self coopHUD.ChargeBar
function coopHUD.ChargeBar.getOverChargeSprite(self)
	local sprite = Sprite()
	local color = Color(1, 1, 1, 1, 0, 0, 0)
	sprite:Load(self.anim_path, true)
	color:SetColorize(2, 1.1, 0, 1)
	sprite.Color = color
	sprite:SetFrame('BarFull', 0)
	return sprite
end
---@param self coopHUD.ChargeBar
---@return number
function coopHUD.ChargeBar.getMaxCharge(self)
	if self.parent_item.entPlayer == false or self.parent_item == nil then return nil end
	local max_charges = Isaac.GetItemConfig():GetCollectible(self.parent_item.id).MaxCharges
	if self.parent_item.id == CollectibleType.COLLECTIBLE_PLACEBO or
			self.parent_item.id == CollectibleType.COLLECTIBLE_BLANK_CARD or
			self.parent_item.id == CollectibleType.COLLECTIBLE_CLEAR_RUNE or
			self.parent_item.id == CollectibleType.COLLECTIBLE_D_INFINITY then
		if self.parent_item.custom_max_charge then
			max_charges = self.parent_item.custom_max_charge
		end
	end
	return max_charges
end
---@param self coopHUD.ChargeBar
function coopHUD.ChargeBar.update(self)
	if self.max_charge ~= self:getMaxCharge() then
		self.max_charge = self:getMaxCharge()
		self.bar_sprite = self:getChargeSprite()
		self.overlay_sprite = self:getOverlaySprite()
		self.beth_bar_sprite = self:getBethSprite()
	end
	if self.normal_charge ~= self.parent_item.parent.entPlayer:GetActiveCharge(self.parent_item.slot) then
		self.normal_charge = self.parent_item.parent.entPlayer:GetActiveCharge(self.parent_item.slot)
		self:flash()
	end
	if self.beth_charge ~= self.parent_item.parent.entPlayer:GetEffectiveBloodCharge() + self.parent_item.parent.entPlayer:GetEffectiveSoulCharge() then
		self.beth_charge = self.parent_item.parent.entPlayer:GetEffectiveBloodCharge() + self.parent_item.parent.entPlayer:GetEffectiveSoulCharge()
	end
	if self.battery_charge ~= self.parent_item.parent.entPlayer:GetBatteryCharge(self.parent_item.slot) then
		self.battery_charge = self.parent_item.parent.entPlayer:GetBatteryCharge(self.parent_item.slot)
	end
end
---@param self coopHUD.ChargeBar
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@param dim boolean defines if dim sprite
---@return Vector offset where render next sprite
function coopHUD.ChargeBar.render(self, pos, mirrored, scale, down_anchor, dim)
	local temp_pos = Vector(pos.X, pos.Y + 16 * scale.Y)
	local offset = Vector(8 * scale.X, 0)
	if mirrored then
		offset.X = offset.X * -1
	end
	if down_anchor then
		temp_pos.Y = pos.Y - 16 * scale.Y
	end
	--
	self.sprite_empty.Scale = scale
	self.sprite_empty:Render(temp_pos) -- empty background bar render
	--
	local step = 26 / self.max_charge -- holds how much pixels is one item charge
	-- Amount bar render
	if self.beth_bar_sprite then
		local charge = self.normal_charge + self.beth_charge
		if charge > self.max_charge then charge = self.max_charge end
		self.beth_bar_sprite.Scale = scale
		self.beth_bar_sprite:Render(temp_pos, Vector(0, 28 - (step * (charge))))
	end
	--
	self.bar_sprite.Scale = scale
	local temp_step = 28 - (step * self.normal_charge)
	if temp_step <= 0 then temp_step = 0 end
	self.bar_sprite:Render(temp_pos, Vector(0, temp_step))
	--
	self.overcharge_bar_sprite.Scale = scale
	self.overcharge_bar_sprite:Render(temp_pos, Vector(0, 28 - (step * (self.battery_charge))))
	-- Overlay bar render
	self.overlay_sprite.Scale = scale
	self.overlay_sprite:Render(temp_pos)
	--- Flicker of animation
	if self.flash_trigger then
		self.bar_sprite.Color = Color(self.bar_sprite.Color.R, self.bar_sprite.Color.G, self.bar_sprite.Color.B, 0.5)
		if self.flash_trigger + 2 < Game():GetFrameCount() then
			self.flash_trigger = nil
			self.bar_sprite.Color = Color(self.bar_sprite.Color.R, self.bar_sprite.Color.G, self.bar_sprite.Color.B, 1)
		end
	end
	return offset
end
---@param self coopHUD.ChargeBar
function coopHUD.ChargeBar.flash(self)
	self.flash_trigger = Game():GetFrameCount()
end
---@param self coopHUD.ChargeBar
---@return number
function coopHUD.ChargeBar.getCurrentCharge(self)
	return self.normal_charge + self.battery_charge + self.beth_charge
end