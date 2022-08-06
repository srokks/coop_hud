---@class coopHUD.Inventory
---@param parent coopHUD.Player
---@type coopHUD.Inventory | fun(parent:coopHUD.Player):coopHUD.Inventory
---@return coopHUD.Inventory
coopHUD.Inventory = {}
coopHUD.Inventory.__index = coopHUD.Inventory
coopHUD.Inventory.anim_path = "gfx/ui/ui_inventory.anm2"
setmetatable(coopHUD.Inventory, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@see coopHUD.Inventory
---@private
function coopHUD.Inventory.new(parent)
	local self = setmetatable({}, coopHUD.Inventory)
	self.parent = parent
	self.max_collectibles = 8
	self.sprite = Sprite()
	self.sprite:Load(coopHUD.Inventory.anim_path, true)
	self.sprite:SetFrame('Idle', 0)
	return self
end
--- Renders item sprite in current position
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param down_anchor boolean change anchor to down corner
---@return Vector offset where render next sprite
function coopHUD.Inventory:render(pos, mirrored, down_anchor)
	local temp_pos = Vector(pos.X, pos.Y)
	local sprite_pivot = Vector(8, 8)
	--
	if self.parent.entPlayer:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		self.max_collectibles = 12
	else
		self.max_collectibles = 8
	end

	--
	if mirrored then
		sprite_pivot.X = sprite_pivot.X * -1
	end
	if down_anchor then
		temp_pos.Y = temp_pos.Y - 16
		sprite_pivot.Y = sprite_pivot.Y * -1
	else
		temp_pos.Y = temp_pos.Y + 8
	end
	for i = 1, self.max_collectibles do
		if i == 1 then
			self.sprite.Color = Color(1, 1, 1, 1)
			self.sprite:RenderLayer(1, temp_pos + sprite_pivot)
		end
		local off
		if self.parent.collectibles[i] then
			off = self.parent.collectibles[i]:render(Vector(temp_pos.X, temp_pos.Y), mirrored,
			                                         Vector(0.5, 0.5), down_anchor)
			temp_pos.X = temp_pos.X + off.X * 0.75
		else
			self.sprite.Color = Color(1, 1, 1, 0.5)
			self.sprite:RenderLayer(0, temp_pos + sprite_pivot)
			if mirrored then
				temp_pos.X = temp_pos.X - 12
			else
				temp_pos.X = temp_pos.X + 12
			end
		end
		if self.max_collectibles / i == 2 then
			temp_pos = Vector(pos.X, pos.Y)
			if down_anchor then
				temp_pos.Y = temp_pos.Y - 16
			end
			temp_pos.Y = temp_pos.Y + 16
		end
	end
	--
	local offset = Vector(12 * self.max_collectibles, 32)
	if mirrored then offset.X = offset.X * -1 end
	if down_anchor then offset.Y = offset.Y * -1 end
	return offset
end

