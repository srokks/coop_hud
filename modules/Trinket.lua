---@class coopHUD.Trinket
---@param player coopHUD.Player
---@param slot number
---@param trinket_id number
---@type fun (player:coopHUD.Player,slot:number,trinket_id:number):coopHUD.Trinket
---@return
coopHUD.Trinket = {}
coopHUD.Trinket.type = PickupVariant.PICKUP_TRINKET
coopHUD.Trinket.__index = coopHUD.Trinket
setmetatable(coopHUD.Trinket, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@see coopHUD.Trinket
---@private
function coopHUD.Trinket.new(player, slot, trinket_id)
	local self = setmetatable({}, coopHUD.Trinket)
	self.entPlayer = player
	self.slot = slot
	if self.slot >= 0 then
		self.id = player:GetTrinket(self.slot)
	else
		self.id = trinket_id
	end
	self.sprite = self:getSprite()
	return self
end
function coopHUD.Trinket:getSprite()
	if self.id == 0 or self.id == nil then return nil end
	local sprite = Sprite()
	sprite:Load(coopHUD.Item.anim_path, true)
	local item_sprite = Isaac.GetItemConfig():GetTrinket(self.id).GfxFileName
	sprite:ReplaceSpritesheet(0, item_sprite) -- item layer
	sprite:ReplaceSpritesheet(2, item_sprite) -- shadow layer
	sprite:LoadGraphics()
	sprite:SetFrame("Idle", 0)
	return sprite
end
function coopHUD.Trinket:update()
	if self.id ~= self.entPlayer:GetTrinket(self.slot) then
		self.id = self.entPlayer:GetTrinket(self.slot)
		self.sprite = self:getSprite()
	end
end
function coopHUD.Trinket:render(pos, mirrored, scale, down_anchor)
	local temp_pos = Vector(pos.X, pos.Y)
	local sprite_scale = scale
	local offset = Vector(0, 0)
	if self.entPlayer and self.entPlayer:IsCoopGhost() then return offset end -- if player is coop ghost skips render
	--
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end -- sets def sprite_scale
	--
	if self.sprite then
		if mirrored then
			temp_pos.X = temp_pos.X - (16 * sprite_scale.X)
			offset.X = -24 * sprite_scale.X
		else
			temp_pos.X = temp_pos.X + (16 * sprite_scale.X)
			offset.X = 24 * sprite_scale.X
		end
		--
		if down_anchor then
			temp_pos.Y = temp_pos.Y - (16 * sprite_scale.Y)
			offset.Y = -24 * sprite_scale.Y
		else
			temp_pos.Y = temp_pos.Y + (16 * sprite_scale.Y)
			offset.Y = 24 * sprite_scale.Y
		end
		--
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
	end
	return offset
end