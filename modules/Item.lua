---@class coopHUD.Item
---@field parent coopHUD.Player
---@field entPlayer EntityPlayer
---@field slot number
---@field frame_num number
---@field id number
---@field custom_max_charge number holds custom max charge value for item such as Placebo/Mimics/D_Infinity
---@field ref_table coopHUD.Item[]
---@param player coopHUD.Player
---@param slot number  slot binding -1 - no slot | ActiveSlot enums
---@param item_id number
---@type coopHUD.Item | fun (player:coopHUD.Player, slot:number, item_id:number):coopHUD.Item
coopHUD.Item = {}
coopHUD.Item.__index = coopHUD.Item
coopHUD.Item.type = PickupVariant.PICKUP_COLLECTIBLE
coopHUD.Item.anim_path = '/gfx/ui/items_coop.anm2'
coopHUD.Item.charge_anim_path = "gfx/ui/activechargebar_coop.anm2"
local xml_data = include('helpers.xml_data.lua')
---@type coopHUD.Item[]
coopHUD.Item.ref_table = {}
setmetatable(coopHUD.Item, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@see coopHUD.Item
---@private
function coopHUD.Item.new(player, slot, item_id)
	---@type coopHUD.Item
	local self = setmetatable({}, coopHUD.Item)
	self.parent = player
	if self.parent ~= nil then
		self.entPlayer = self.parent.entPlayer
	end
	self.slot = slot
	if slot >= 0 then
		self.id = self.entPlayer:GetActiveItem(self.slot)
	else
		self.id = item_id
	end
	self.frame_num = self:getFrameNum()
	self.sprite = self:getSprite()
	self.charge = coopHUD.ChargeBar(self)
	self.temp_item = nil
	self.d_infinity_charge = nil
	self.custom_max_charge = self:getMaxCharge()
	table.insert(self.ref_table, self)
	return self
end
---@private
---@param self coopHUD.Item
function coopHUD.Item.getSprite(self)
	if self.id == 0 or (self.entPlayer and self.entPlayer.Variant == 1) then
		return nil
	end

	-- locals initial
	local sprite = Sprite()
	local sprite_path = Isaac.GetItemConfig():GetCollectible(self.id).GfxFileName
	local anim_name = "Idle"
	sprite:Load(coopHUD.Item.anim_path, false)
	--
	-- Custom modules set - jars etc.
	if self.id == CollectibleType.COLLECTIBLE_THE_JAR then
		sprite_path = "gfx/characters/costumes/costume_rebirth_90_thejar.png"
		anim_name = "Jar"
	elseif self.id == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then
		sprite_path = "gfx/characters/costumes/costume_434_jarofflies.png"
		anim_name = "Jar"
	elseif self.id == CollectibleType.COLLECTIBLE_JAR_OF_WISPS then
		sprite_path = "gfx/ui/hud_jarofwisps.png"
		anim_name = "WispJar"
	elseif self.id == CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING then
		sprite_path = "gfx/ui/hud_bagofcrafting.png"
		anim_name = "SoulUrn"
	elseif self.id == CollectibleType.COLLECTIBLE_EVERYTHING_JAR then
		sprite_path = "gfx/ui/hud_everythingjar.png"
		anim_name = "EverythingJar"
	elseif self.id == CollectibleType.COLLECTIBLE_FLIP then
		if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
			sprite_path = 'gfx/ui/ui_flip_coop.png'
		end
	elseif self.id == CollectibleType.COLLECTIBLE_URN_OF_SOULS then
		sprite_path = "gfx/ui/hud_urnofsouls.png"
		anim_name = "SoulUrn"
	elseif self.id == CollectibleType.COLLECTIBLE_D_INFINITY then
		sprite_path = "gfx/characters/costumes/costume_489_dinfinity.png"
		anim_name = "D_Infinity"
	end
	sprite:ReplaceSpritesheet(0, sprite_path) -- item
	sprite:ReplaceSpritesheet(1, sprite_path) -- border
	sprite:ReplaceSpritesheet(2, sprite_path) -- shadow
	--
	if self.slot == ActiveSlot.SLOT_PRIMARY then
		local book_sprite_path
		self.virtuoses_check = self.entPlayer:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and self.id ~= CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES
		self.belial_check = self.entPlayer:GetPlayerType() == PlayerType.PLAYER_JUDAS
				and self.entPlayer:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and self.id ~= CollectibleType.COLLECTIBLE_BIRTHRIGHT
		if self.virtuoses_check and self.belial_check then
			book_sprite_path = 'gfx/ui/hud_bookofvirtueswithbelial.png' -- sets virt/belial sprite
		elseif self.virtuoses_check then
			book_sprite_path = 'gfx/ui/hud_bookofvirtues.png' -- sets virtouses sprite
		elseif self.belial_check then
			book_sprite_path = 'gfx/ui/hud_bookofbelial.png' -- sets belial sprite
		end
		if book_sprite_path then
			sprite:ReplaceSpritesheet(3, book_sprite_path)
			sprite:ReplaceSpritesheet(4, book_sprite_path)
		end
	end
	--
	if self.id == CollectibleType.COLLECTIBLE_HOLD then
		anim_name = 'Hold'
		sprite:ReplaceSpritesheet(3, 'gfx/ui/ui_poops.png')
	end
	--
	sprite:SetFrame(anim_name, self.frame_num)
	sprite:LoadGraphics()
	--
	return sprite
end
---@private
---@param self coopHUD.Item
function coopHUD.Item.getFrameNum(self)
	local frame_num = 0
	if self.id > 0 and self.slot >= 0 then
		--The Jar/Jar of Flies - charges check
		if self.id == CollectibleType.COLLECTIBLE_THE_JAR then
			frame_num = math.ceil(self.entPlayer:GetJarHearts() / 2)
		elseif self.id == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then
			frame_num = self.entPlayer:GetJarFlies()
		elseif self.id == CollectibleType.COLLECTIBLE_JAR_OF_WISPS then
			local wisp_charge = 0 -- holds if item charged and needed to add 15 to set proper frame
			local max_charges = Isaac.GetItemConfig():GetCollectible(self.id).MaxCharges
			if self.entPlayer:NeedsCharge(self.slot) == false or (self.charge and self.charge >= max_charges) then
				wisp_charge = 19
			end
			frame_num = coopHUD.jar_of_wisp_charge + wisp_charge
		elseif self.id == CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING then
			if self.slot < 2 then
				-- set frame only for active BoC
				frame_num = #self.parent.bag_of_crafting + 1
			else
				-- set frame for T.Cain Pocket BoC
				frame_num = 0
			end
		elseif self.id == CollectibleType.COLLECTIBLE_EVERYTHING_JAR then
			frame_num = self:getCharge() + 1
		elseif self.id == CollectibleType.COLLECTIBLE_URN_OF_SOULS then
			local tempEffects = self.entPlayer:GetEffects()
			local urn_state = tempEffects:GetCollectibleEffectNum(640) -- gets effect of item 0-closed urn/1- opened
			if urn_state ~= 0 then
				-- checks if urn is open
				frame_num = 22 -- opened urn frame no
			end
		elseif self.id == CollectibleType.COLLECTIBLE_D_INFINITY then
			if self.d_infinity_charge == nil then
				self.d_infinity_charge = 0
			end
			frame_num = self.d_infinity_charge
			local max_charges = Isaac.GetItemConfig():GetCollectible(self.id).MaxCharges
			if self.entPlayer:NeedsCharge(self.slot) == false then
				frame_num = self.d_infinity_charge + 10
			end
		elseif self.id == CollectibleType.COLLECTIBLE_HOLD then
			frame_num = self.parent.hold_spell
		else
			-- Sets overlay/charges state frame --
			if self.charge and self.charge.max_charge == 0 then
				-- checks id item has any charges
				frame_num = 0 -- set frame to unloaded
			elseif self.entPlayer:NeedsCharge(self.slot) == false or (self.charge and (self.charge:getCurrentCharge() >= self.charge.max_charge)) then
				--checks if item dont needs charges or item is overloaded
				frame_num = 1 -- set frame to loaded
			else
				frame_num = 0  -- set frame to unloaded
			end
		end
	end
	return frame_num
end
---Updates item id,frame_num,sprite
---@private
---@param self coopHUD.Item
function coopHUD.Item.update(self)
	if self.id ~= self.entPlayer:GetActiveItem(self.slot) then
		-- VAR DATA ITEMS - getting info from saved floor items
		-- done before changing id of item
		if self.id == CollectibleType.COLLECTIBLE_PLACEBO or
				self.id == CollectibleType.COLLECTIBLE_BLANK_CARD or
				self.id == CollectibleType.COLLECTIBLE_CLEAR_RUNE or
				self.id == CollectibleType.COLLECTIBLE_D_INFINITY then
			local var_data = self:get_custom_charge_and_reset()
			if var_data then
				table.insert(coopHUD.floor_custom_items, var_data)
			end
		end
		self.id = self.entPlayer:GetActiveItem(self.slot)
		self.custom_max_charge = self:getMaxCharge()
		self.sprite = self:getSprite()
		self.charge = coopHUD.ChargeBar(self)
	end
	if self.frame_num ~= self:getFrameNum() then
		self.frame_num = self:getFrameNum()
		self.sprite = self:getSprite()
	end
	if self.belial_check or self.virtuoses_check then
		self:updateSprite()
	end
	if self.charge then
		self.charge:update()
	end
end
---Updates sprite based on self.id,self.frame_num
---@private
---@param self coopHUD.Item
function coopHUD.Item.updateSprite(self)
	if self.sprite then
		if self.frame_num ~= self:getFrameNum() then
			self.frame_num = self:getFrameNum()
			self.sprite = self:getSprite()
		end
	end
end
--- Renders item sprite in current position
---@param self coopHUD.Item
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@param dim boolean defines if dim sprite
---@return Vector offset where render next sprite
function coopHUD.Item.render(self, pos, mirrored, scale, down_anchor, dim)
	local temp_pos = Vector(pos.X, pos.Y)
	local sprite_scale = scale
	local offset = Vector(0, 0)
	if sprite_scale == nil then
		sprite_scale = Vector(1, 1)
	end
	if self.entPlayer and self.entPlayer:IsCoopGhost() then
		return offset
	end -- if player is coop ghost skips render
	if self.sprite ~= nil then
		if mirrored then
			temp_pos.X = temp_pos.X - (16 * sprite_scale.X)
			offset.X = -32 * sprite_scale.X
		else
			temp_pos.X = temp_pos.X + (16 * sprite_scale.X)
			offset.X = 32 * sprite_scale.X
		end
		if down_anchor then
			temp_pos.Y = temp_pos.Y - (16 * sprite_scale.Y)
			offset.Y = -32 * sprite_scale.Y
		else
			temp_pos.Y = temp_pos.Y + (16 * sprite_scale.Y)
			offset.Y = 32 * sprite_scale.Y
		end
		if self.slot == ActiveSlot.SLOT_SECONDARY then
			sprite_scale = Vector(sprite_scale.X * 0.5, sprite_scale.Y * 0.5)
			temp_pos.X = temp_pos.X - 8
			temp_pos.Y = temp_pos.Y - 8
		end
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
		if self.id == CollectibleType.COLLECTIBLE_BAG_OF_CRAFTING and self.slot == ActiveSlot.SLOT_PRIMARY then
			--renders bag of crafting result item
			if self.parent.crafting_result then
				temp_pos = Vector(pos.X + 5, pos.Y + 8)
				if down_anchor then temp_pos.Y = temp_pos.Y - 8 end
				if Game():GetLevel():GetCurses() >= LevelCurse.CURSE_OF_BLIND then
					coopHUD.BoC.Unknown:render(temp_pos, mirrored, Vector(0.7, 0.7), down_anchor)
				else
					self.parent.crafting_result:render(temp_pos, mirrored, Vector(0.7, 0.7), down_anchor, dim)
				end
			end
		end
	end
	-- ChargeBar render
	if self.charge then
		local charge_off = self.charge:render(Vector(pos.X + offset.X, pos.Y), mirrored, scale, down_anchor, dim)
		offset.X = offset.X + charge_off.X
	end
	return offset
end
--- Renders player collectibles table
---@param self coopHUD.Item
---@param mirrored boolean defines which side render true - right / false - left
function coopHUD.Item.render_items_table(self, mirrored)
	local items_table = { } -- saves parent collectibles to local temp
	--combines trinkets and collectibles item tables
	for i = 1, #self.parent.gulped_trinkets do
		table.insert(items_table, self.parent.gulped_trinkets[i])
	end
	for i = 1, #self.parent.collectibles do
		table.insert(items_table, self.parent.collectibles[i])
	end
	--
	local init_pos = Vector(0, 64)
	if mirrored then
		init_pos.X = coopHUD.anchors.bot_right.X - 64
	else
		init_pos.X = coopHUD.anchors.bot_left.X
	end
	local temp_pos = Vector(init_pos.X, init_pos.Y)
	--
	local down_anchor = false --TODO:from arg
	-- defines items modules scale and no of colums based on collected collectibles
	local scale = Vector(1, 1)
	local col_no = 2
	if #items_table > 10 then
		scale = Vector(0.625, 0.625)
		col_no = 3
	end
	if #items_table > 24 then
		scale = Vector(0.5, 0.5)
		col_no = 4
	end
	--
	local temp_index = 1 -- temp index for positioning due we show from latest
	local collectibles_stop = 1  -- last index of shown item
	if #items_table > 51 then
		-- prevention from showing too much items
		collectibles_stop = #items_table - 51
	end
	for i = #items_table, collectibles_stop, -1 do
		local off = items_table[i]:render(temp_pos, false, scale, down_anchor, false)
		temp_pos.X = temp_pos.X + off.X / 1.25
		if temp_index % col_no == 0 then
			temp_pos.X = init_pos.X
			temp_pos.Y = temp_pos.Y + off.Y / 1.25
		end
		temp_index = temp_index + 1
	end
end
---Updates custom charge for item with it such as
---@param self coopHUD.Item
function coopHUD.Item.update_custom_charge(self)
	if self.id == CollectibleType.COLLECTIBLE_D_INFINITY then
		local form_to_max_charge = { 4, 6, 6, 2, 3, 4, 1, 3, 6, 6 }
		self.custom_max_charge = form_to_max_charge[self.d_infinity_charge + 1]
	end
	if self.id == CollectibleType.COLLECTIBLE_PLACEBO then
		if self.parent.first_pocket.type == coopHUD.Pocket.PILL then
			local item_pool = Game():GetItemPool()
			local pill_effect = item_pool:GetPillEffect(self.parent.first_pocket.id, self.parent.entPlayer)
			self.custom_max_charge = xml_data.pillMetadata[pill_effect].mimiccharge
		end
	end
	if self.id == CollectibleType.COLLECTIBLE_CLEAR_RUNE then
		if self.parent.first_pocket.type == coopHUD.Pocket.CARD then
			local card_effect = self.parent.first_pocket.id
			self.custom_max_charge = xml_data.cardMetadata[card_effect].mimiccharge
		end
	end
	if self.id == CollectibleType.COLLECTIBLE_BLANK_CARD then
		if self.parent.first_pocket.type == coopHUD.Pocket.CARD then
			local card_effect = self.parent.first_pocket.id
			self.custom_max_charge = xml_data.cardMetadata[card_effect].mimiccharge
		end
	end
end
---Returns var data of item
---@param self coopHUD.Item
---@return VarData|nil
function coopHUD.Item.get_custom_charge_and_reset(self)
	---@type VarData
	var_data = nil
	if self.custom_max_charge then
		local level = Game():GetLevel()
		var_data = { id         = self.id,
		             max_charge = self.custom_max_charge,
		             floor      = level:GetAbsoluteStage(),
		             room_idx   = level:GetCurrentRoomIndex() }
		self.custom_max_charge = nil
		if self.id == CollectibleType.COLLECTIBLE_D_INFINITY then
			var_data.d_infinity_charge = self.d_infinity_charge
			self.d_infinity_charge = nil
		end
	end
	return var_data
end
---Return max charge from floor_left_over_items
---@param self coopHUD.Item
---@return number|nil
function coopHUD.Item.getMaxCharge(self)
	local max_charge = nil
	if self.id == CollectibleType.COLLECTIBLE_PLACEBO or
			self.id == CollectibleType.COLLECTIBLE_BLANK_CARD or
			self.id == CollectibleType.COLLECTIBLE_CLEAR_RUNE or
			self.id == CollectibleType.COLLECTIBLE_D_INFINITY then
		---Schoolbag prevention
		if self.parent.schoolbag_item then
			max_charge = self.parent.schoolbag_item.custom_max_charge
			self.parent.schoolbag_item.custom_max_charge = nil
		end
		local level = Game():GetLevel()
		if coopHUD.floor_custom_items then
			for i, varData in pairs(coopHUD.floor_custom_items) do
				if varData.id == self.id and
						varData.floor == level:GetAbsoluteStage() and
						varData.room_idx == level:GetCurrentRoomIndex() then
					max_charge = varData.max_charge
					if varData.d_infinity_charge then
						self.d_infinity_charge = varData.d_infinity_charge
					end
					coopHUD.floor_custom_items[i] = nil
				end
			end
		end
	end
	return max_charge
end
---@class VarData holds custom item data
---@field id number
---@field max_charge number|nil
---@field d_infinity_charge number|nil
---@field floor number which floor entity was left
---@field room_idx number room index where entity was left