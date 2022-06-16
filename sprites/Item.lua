---@class coopHUD.Item
---@param player coopHUD.Player
---@param slot number  slot binding -1 - no slot | ActiveSlot enums
---@param item_id number
---@type fun (player:coopHUD.Player, slot:number, item_id:number):coopHUD.Item
coopHUD.Item = {}
coopHUD.Item.__index = coopHUD.Item
coopHUD.Item.type = PickupVariant.PICKUP_COLLECTIBLE
setmetatable(coopHUD.Item, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@see coopHUD.Item
---@private
function coopHUD.Item.new(player, slot, item_id)
	local self = setmetatable({}, coopHUD.Item)
	self.parent = player
	if self.parent == nil then
		return nil
	end
	self.entPlayer = self.parent.entPlayer
	self.slot = slot
	if slot >= 0 then
		self.id = self.entPlayer:GetActiveItem(self.slot)
	else
		self.id = item_id
	end
	self.frame_num = self:getFrameNum()
	self.sprite = self:getSprite()
	self.charge = self:getCharge()
	self.charge_sprites = self.getChargeSprites(self)
	self.temp_item = nil
	return self
end
--- return self charge sprite table
---@param self coopHUD.Item
---@return table table of charge sprites
function coopHUD.Item.getChargeSprites(self)
	-- Gets charge of item from  player, slot
	local sprites = {
		beth_charge = Sprite(),
		charge      = Sprite(),
		overlay     = Sprite(),
	}
	if self.id == 0 or self.id == nil or self.slot < 0 then
		return nil
	end
	local max_charges = Isaac.GetItemConfig():GetCollectible(self.id).MaxCharges
	if max_charges == 0 then
		return false
	end
	-- Normal and battery charge
	local charges = self.entPlayer:GetActiveCharge(self.slot) + self.entPlayer:GetBatteryCharge(self.slot)
	local step = math.floor((charges / (max_charges * 2)) * 46)
	sprites.charge:Load(coopHUD.GLOBALS.charge_anim_path, true)
	sprites.charge:SetFrame('ChargeBar', step)
	-- Overlay sprite
	sprites.overlay:Load(coopHUD.GLOBALS.charge_anim_path, true)
	if (max_charges > 1 and max_charges < 5) or max_charges == 6 or max_charges == 12 then
		sprites.overlay:SetFrame("BarOverlay" .. max_charges, 0)
	else
		sprites.overlay:SetFrame("BarOverlay1", 0)
	end
	-- Bethany charge
	local player_type = self.entPlayer:GetPlayerType()
	if player_type == PlayerType.PLAYER_BETHANY or player_type == PlayerType.PLAYER_BETHANY_B then
		local beth_charge
		local color = Color(1, 1, 1, 1, 0, 0, 0)
		if player_type == PlayerType.PLAYER_BETHANY then
			beth_charge = self.entPlayer:GetEffectiveSoulCharge()
			color:SetColorize(0.8, 0.9, 1.8, 1)
		elseif player_type == PlayerType.PLAYER_BETHANY_B then
			beth_charge = self.entPlayer:GetEffectiveBloodCharge()
			color:SetColorize(1, 0.2, 0.2, 1)
		end
		sprites.beth_charge:Load(coopHUD.GLOBALS.charge_anim_path, true)
		sprites.beth_charge.Color = color
		step = step + math.floor((beth_charge / (max_charges * 2)) * 46) + 1
		sprites.beth_charge:SetFrame('ChargeBar', step)
	else
		sprites.beth_charge = false
	end
	return sprites
end
function coopHUD.Item:getSprite()
	if self.id == 0 or (self.entPlayer and self.entPlayer.Variant == 1) then
		return nil
	end

	-- locals initial
	local sprite = Sprite()
	local sprite_path = Isaac.GetItemConfig():GetCollectible(self.id).GfxFileName
	local anim_name = "Idle"
	sprite:Load(coopHUD.GLOBALS.item_anim_path, false)
	--
	-- Custom sprites set - jars etc.
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
	end
	sprite:ReplaceSpritesheet(0, sprite_path) -- item
	sprite:ReplaceSpritesheet(1, sprite_path) -- border
	sprite:ReplaceSpritesheet(2, sprite_path) -- shadow
	--
	if self.slot == ActiveSlot.SLOT_PRIMARY then
		local book_sprite_path = nil
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
function coopHUD.Item:getFrameNum()
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
		elseif self.id == CollectibleType.COLLECTIBLE_HOLD then
			frame_num = self.parent.hold_spell
		else
			-- Sets overlay/charges state frame --
			local max_charges = Isaac.GetItemConfig():GetCollectible(self.id).MaxCharges-- gets max charges
			if max_charges == 0 then
				-- checks id item has any charges
				frame_num = 0 -- set frame to unloaded
			elseif self.entPlayer:NeedsCharge(self.slot) == false or (self.charge and self.charge >= max_charges) then
				-- checks if item dont needs charges or item is overloaded
				frame_num = 1 -- set frame to loaded
			else
				frame_num = 0  -- set frame to unloaded
			end
		end
	end
	return frame_num
end
--- Returns current charge of item if not connected to slot return nil
function coopHUD.Item:getCharge()
	if self.slot >= 0 then
		local item_charge = self.entPlayer:GetActiveCharge(self.slot) + self.entPlayer:GetBatteryCharge(self.slot)
		if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_BETHANY then
			-- Bethany Soul Charge integration
			item_charge = item_charge + self.entPlayer:GetSoulCharge()
		elseif self.entPlayer:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
			-- T. Bethany Blood Charge integration
			item_charge = item_charge + self.entPlayer:GetBloodCharge()
		end
		return item_charge
	end
end
function coopHUD.Item:update()
	if self.id ~= self.entPlayer:GetActiveItem(self.slot) then
		self.id = self.entPlayer:GetActiveItem(self.slot)
		self.sprite = self:getSprite()
		self.charge_sprites = self.getChargeSprites(self)
	end
	if self.frame_num ~= self:getFrameNum() then
		self.frame_num = self:getFrameNum()
		self.sprite = self:getSprite()
	end
	if self.belial_check or self.virtuoses_check then
		self:updateSprite()
	end
end
--- updates item charge bars
function coopHUD.Item:updateCharge()
	if self.charge ~= self:getCharge() then
		self.charge = self:getCharge()
		self.charge_sprites = self.getChargeSprites(self)
		self:updateSprite()
	end
end
function coopHUD.Item:updateSprite()
	if self.sprite then
		if self.frame_num ~= self:getFrameNum() then
			self.frame_num = self:getFrameNum()
			self.sprite = self:getSprite()
		end
	end
end
--- Renders item charge bars if item has
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@param dim boolean defines if dim sprite
---@return Vector
function coopHUD.Item:renderChargeBar(pos, mirrored, scale, down_anchor)
	local temp_pos = Vector(pos.X, pos.Y)
	local offset = Vector(0, 0)
	if self.charge_sprites then
		--
		local sprite_scale = scale
		if sprite_scale == nil then
			sprite_scale = Vector(1, 1)
		end
		--
		if mirrored then
			temp_pos.X = temp_pos.X - (4 * sprite_scale.X)
			offset.X = -8 * 1.25 * sprite_scale.X
		else
			temp_pos.X = temp_pos.X + (4 * sprite_scale.X)
			offset.X = 8 * sprite_scale.X
		end
		--
		if down_anchor then
			temp_pos.Y = temp_pos.Y - (16 * sprite_scale.Y)
			offset.Y = -32 * sprite_scale.Y
		else
			temp_pos.Y = temp_pos.Y + (16 * sprite_scale.Y)
			offset.Y = 32 * sprite_scale.Y
		end
		--
		if self.charge_sprites.charge then
			self.charge_sprites.charge.Scale = sprite_scale
			self.charge_sprites.charge:RenderLayer(0, temp_pos)  -- renders background
		end
		if self.charge_sprites.beth_charge then
			self.charge_sprites.beth_charge.Scale = sprite_scale
			self.charge_sprites.beth_charge:RenderLayer(1, temp_pos) -- renders bethany charge
		end
		if self.charge_sprites.charge then
			self.charge_sprites.charge.Scale = sprite_scale
			self.charge_sprites.charge:RenderLayer(1, temp_pos)
			self.charge_sprites.charge:RenderLayer(2, temp_pos)
		end
		if self.charge_sprites.overlay then
			self.charge_sprites.overlay.Scale = sprite_scale
			self.charge_sprites.overlay:Render(temp_pos)
		end

	end
	return offset
end
--- Renders item sprite in current position
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@param dim boolean defines if dim sprite
---@return Vector offset where render next sprite
function coopHUD.Item:render(pos, mirrored, scale, down_anchor, dim)
	self:updateCharge()
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
	if self.slot >= 0 and self.slot ~= ActiveSlot.SLOT_SECONDARY then
		local charge_off = self:renderChargeBar(Vector(pos.X + offset.X, pos.Y), mirrored, scale, down_anchor)
		offset.X = offset.X + charge_off.X
	end
	return offset
end
--- Renders player collectibles table
---@param self coopHUD.Item
---@param mirrored boolean defines which side render true - right / false - left
function coopHUD.Item.render_items_table(self, mirrored)
	local items_table = self.parent.collectibles -- saves parent collectibles to local temp
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
	-- defines items sprites scale and no of colums based on collected collectibles
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
	if #items_table > 44 then
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