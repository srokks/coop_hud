---@class coopHUD.Poop
---@param entPlayer
---@param slot
---@type fun(entPlayer:userdata,slot:number):coopHUD.Poop
---@return coopHUD.Poop
coopHUD.Poop = {}
coopHUD.Poop.__index = coopHUD.Poop
setmetatable(coopHUD.Poop, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@see coopHUD.Poop
---@private
function coopHUD.Poop.new(entPlayer, slot)
	local self = setmetatable({}, coopHUD.Poop)
	self.entPlayer = entPlayer
	self.slot = slot
	self.spell_type = self.entPlayer:GetPoopSpell(self.slot)
	self.sprite = self:getSprite()
	self.dim = (self.slot < self.entPlayer:GetPoopMana())
	return self
end
function coopHUD.Poop:getSprite()
	local layer_name = 'IdleSmall'
	if self.slot == 0 then layer_name = 'Idle' end
	local sprite = Sprite()
	sprite:Load(coopHUD.GLOBALS.poop_anim_path, true)
	sprite:SetFrame(layer_name, self.spell_type)
	if self.dim then
		local col = Color(0.3, 0.3, 0.3, 1)
		col:SetColorize(1, 1, 1, 0.4)
		sprite.Color = col
	end
	return sprite
end
function coopHUD.Poop:render(pos, mirrored, scale, down_anchor)
	local poop_pos = Vector(pos.X, pos.Y)
	local offset = Vector(0, 0)
	local sprite_scale = scale
	local pivot = Vector(4, 4)
	local offset_pivot = Vector(12, 12)
	if self.sprite:GetAnimation() == 'Idle' then
		pivot = Vector(12, 12)
		offset_pivot = Vector(22, 22)
	end
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end
	if mirrored then
		poop_pos = poop_pos + Vector(-pivot.X * sprite_scale.X, 0)
		offset.X = -offset_pivot.X * scale.X
	else
		poop_pos = poop_pos + Vector(pivot.X * sprite_scale.X, 0)
		offset.X = offset_pivot.X * scale.X
	end
	if down_anchor then
		poop_pos = poop_pos + Vector(0, -pivot.Y * sprite_scale.Y)
		offset.Y = -offset_pivot.Y * scale.Y
	else
		poop_pos = poop_pos + Vector(0, pivot.Y * sprite_scale.Y)
		offset.Y = offset_pivot.Y * scale.Y
	end
	if self.sprite then
		self.sprite.Scale = sprite_scale
		self.sprite:Render(poop_pos)
	end
	return offset
end
function coopHUD.Poop:update()
	if self.dim ~= (self.slot >= self.entPlayer:GetPoopMana()) then
		self.dim = (self.slot >= self.entPlayer:GetPoopMana())
		self.sprite = self:getSprite()
	end
	if self.spell_type ~= self.entPlayer:GetPoopSpell(self.slot) then
		self.spell_type = self.entPlayer:GetPoopSpell(self.slot)
		self.sprite = self:getSprite()
	end
end
---@class coopHUD.PoopsTable
---@field poop_mana number holds current mana amount
---@field poops coopHUD.Poop[]
---@type fun(entPlayer):coopHUD.PoopsTable
coopHUD.PoopsTable = {}
coopHUD.PoopsTable.__index = coopHUD.PoopsTable
setmetatable(coopHUD.PoopsTable, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@see coopHUD.PoopsTable
---@private
function coopHUD.PoopsTable.new(entPlayer)
	local self = setmetatable({}, coopHUD.PoopsTable)
	self.entPlayer = entPlayer
	self.poop_mana = self.entPlayer:GetPoopMana()
	self.poops = {}
	for i = 0, PoopSpellType.SPELL_QUEUE_SIZE - 1, 1 do
		self.poops[i] = coopHUD.Poop(entPlayer, i)
	end
	return self
end
--- Renders poops spells  sprites in current position
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@return Vector offset where render next sprite
function coopHUD.PoopsTable:render(pos, mirrored, scale, down_anchor)
	local init_pos = Vector(pos.X, pos.Y)
	local off = Vector(0, 0)
	local offset = Vector(0, 0)
	for i = 0, PoopSpellType.SPELL_QUEUE_SIZE - 1, 1 do
		if i == 1 then
			if down_anchor then
				init_pos.Y = init_pos.Y - 8
			else
				init_pos.Y = init_pos.Y + 8
			end
		end
		off = self.poops[i]:render(Vector(init_pos.X, init_pos.Y), mirrored, scale, down_anchor)
		if i == 0 then offset.Y = offset.Y + off.Y end
		init_pos.X = init_pos.X + off.X
	end
	offset.X = init_pos.X - pos.X
	return offset
end
function coopHUD.PoopsTable:update()
	if self.poop_mana ~= self.entPlayer:GetPoopMana() then
		self.poop_mana = self.entPlayer:GetPoopMana()
	end
	for i = 0, PoopSpellType.SPELL_QUEUE_SIZE - 1, 1 do
		self.poops[i]:update()
	end
end