---@class coopHUD.Pocket
---@private field parent coopHUD.Player
---@field slot number
---@field type number  0 - none, 1 - card, 2 - pill, 3 - item
---@field id number holds id in case of pill holds pill color
---@field sprite Sprite
---@field item coopHUD.Item or nil
---@field name string
---@field desc string
---@type coopHUD.Pocket | fun(parent:coopHUD.Player,slot:number):coopHUD.Pocket
coopHUD.Pocket = {}
coopHUD.Pocket.NONE = 0
coopHUD.Pocket.CARD = 1
coopHUD.Pocket.PILL = 2
coopHUD.Pocket.COLLECTIBLE = 3
coopHUD.Pocket.card_anim_path = "gfx/ui/hud_card_coop.anm2"
coopHUD.Pocket.pill_anim_path = "gfx/ui/hud_pills_coop.anm2"
coopHUD.Pocket.__index = coopHUD.Pocket
setmetatable(coopHUD.Pocket, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@param parent coopHUD.Player
---@param slot number
---@private
function coopHUD.Pocket.new(parent, slot)
	---@type coopHUD.Pocket
	local self = setmetatable({}, coopHUD.Pocket)
	self.parent = parent
	self.slot = slot
	self.type, self.id = self:getPocket() -- holds pocket type -- 0 - none, 1 - card, 2 - pill, 3 - item
	self.sprite = self:getSprite()
	self.item = self:getItem()
	self.name, self.desc = self:getName()
	return self
end
---Returns pocket type and pocket id
---@param self coopHUD.Pocket
---@private
function coopHUD.Pocket.getPocket(self)
	local pocket_type = 0
	local pocket_id = 0
	if self.parent.entPlayer:GetCard(self.slot) > 0 then
		pocket_id = self.parent.entPlayer:GetCard(self.slot)
		pocket_type = 1
	elseif self.parent.entPlayer:GetPill(self.slot) > 0 then
		pocket_id = self.parent.entPlayer:GetPill(self.slot)
		pocket_type = 2
	else
		pocket_id = self.parent.entPlayer:GetActiveItem(2)
		pocket_type = 3
		if self.slot == 1 then
			if self.parent.first_pocket and self.parent.first_pocket.type == 3 then
				pocket_id = 0
				pocket_type = 0
			end
		elseif self.slot == 2 then
			if (self.parent.first_pocket and self.parent.first_pocket.type == 3)
					or (self.parent.second_pocket and self.parent.second_pocket.type == 3) then
				pocket_id = 0
				pocket_type = 0
			end
		end
	end
	return pocket_type, pocket_id
end
---@param self coopHUD.Pocket
---@private
function coopHUD.Pocket.getSprite(self)
	local sprite = Sprite()
	if self.type == coopHUD.Pocket.CARD then
		-- Card
		sprite:Load(coopHUD.Pocket.card_anim_path, true)
		sprite:SetFrame("CardFronts", self.id) -- sets card frame
	elseif self.type == coopHUD.Pocket.PILL then
		-- Pill
		if self.id > 2048 then self.id = self.id - 2048 end -- check if its horse pill and change id to normal
		sprite:Load(coopHUD.Pocket.pill_anim_path, true)
		sprite:SetFrame("Pills", self.id) --sets frame to pills with correct id
	else
		sprite = nil
	end
	return sprite
end
---@param self coopHUD.Pocket
---@private
function coopHUD.Pocket.getItem(self)
	if self.type ~= 3 then return nil end
	return coopHUD.Item(self.parent, 2)
end
---@param self coopHUD.Pocket
---@private
function coopHUD.Pocket.getName(self)
	local name = nil
	local desc = nil
	if self.type == nil then return nil, nil end
	if self.id == coopHUD.Pocket.NONE then return nil, nil end
	if self.type == coopHUD.Pocket.CARD then
		name = coopHUD.langAPI.getCardNameByID(self.id)
		desc = coopHUD.langAPI.getCardDescByID(self.id)
	elseif self.type == coopHUD.Pocket.PILL then
		name = "???" .. " "
		desc = "???" .. " "
		local item_pool = Game():GetItemPool()
		if item_pool:IsPillIdentified(self.id) then
			local pill_effect = item_pool:GetPillEffect(self.id, self.parent.entPlayer)
			name = coopHUD.langAPI.getPillNameByEffect(pill_effect)
			desc = name
		end
	elseif self.type == coopHUD.Pocket.COLLECTIBLE then
		name = Isaac.GetItemConfig():GetCollectible(self.id).Name
		desc = Isaac.GetItemConfig():GetCollectible(self.id).Description
		name = string.sub(name, 2) --  get rid of # on front of
		name = coopHUD.langAPI.getItemName(name)
		desc = string.sub(desc, 2) --  get rid of # on front of
		desc = coopHUD.langAPI.getItemName(desc)
	end
	return name, desc
end
---@param self coopHUD.Pocket
---@private
function coopHUD.Pocket.update(self)
	local type, id = self:getPocket()
	if self.id ~= id then
		self.type, self.id = type, id
		self.sprite = self:getSprite()
		self.item = self:getItem()
		self.name, self.desc = self:getName()
		if self.slot == 0 and self.parent.entPlayer:IsHoldingItem() and self.type == coopHUD.Pocket.CARD then
			coopHUD.Streak(false, coopHUD.Streak.ITEM, self.name, self.desc, true, self.parent.font_color)
		end
	end
	if self.item then
		self.item:update()
	end
end
--- Renders pocket sprite in current position
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@param dim boolean defines if dim sprite
---@return Vector offset where render next sprite
function coopHUD.Pocket:render(pos, mirrored, scale, down_anchor, dim)
	local temp_pos = Vector(pos.X, pos.Y)
	local sprite_scale = scale
	local offset = Vector(0, 0)
	--
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end -- sets def sprite_scale
	--
	if self.sprite or self.item then
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
			offset.Y = -32 * sprite_scale.Y
		else
			temp_pos.Y = temp_pos.Y + (16 * sprite_scale.Y)
			offset.Y = 24 * sprite_scale.Y
		end
	end
	if self.parent.entPlayer and self.parent.entPlayer:IsCoopGhost() then return offset end -- if player is coop ghost skips render
	--
	if self.sprite then
		if dim then
			local color = Color(0.3, 0.3, 0.3, 1)
			color:SetColorize(0, 0, 0, 0)
			self.sprite.Color = color
		else
			local color = Color(1, 1, 1, 1)
			color:SetColorize(0, 0, 0, 0)
			self.sprite.Color = color
		end
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
	elseif self.item then
		offset = self.item:render(pos, mirrored, scale, down_anchor)
	end
	if (self.name or self.desc) and self.slot == 0 then
		if self.item and self.item.id == CollectibleType.COLLECTIBLE_HOLD and self.parent.poops then
			offset.X = offset.X + self.parent.poops:render(Vector(pos.X + offset.X, pos.Y), mirrored, scale,
			                                               down_anchor).X
		elseif self.item and self.item.id == CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING then
			coopHUD.BoC:render(self.parent, Vector(pos.X + offset.X, pos.Y), mirrored, down_anchor)
		else
			local text = self.name
			if Input.IsActionPressed(ButtonAction.ACTION_MAP, self.parent.controller_index) then
				text = self.desc
			end
			local font_height = coopHUD.HUD.fonts.pft:GetLineHeight()
			temp_pos = Vector(pos.X + offset.X, pos.Y + offset.Y - font_height)
			if mirrored then temp_pos.X = temp_pos.X - string.len(text) * (6 * sprite_scale.X) end
			if down_anchor then
				temp_pos.Y = temp_pos.Y - offset.Y
			end
			coopHUD.HUD.fonts.pft:DrawStringScaled(text, temp_pos.X, temp_pos.Y, sprite_scale.X, sprite_scale.Y,
			                                       self.parent.font_color, 0, true)
		end
	end
	return offset
end

