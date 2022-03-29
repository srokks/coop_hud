coopHUD.Item = {}
coopHUD.Item.__index = coopHUD.Item
setmetatable(coopHUD.Item, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.Item.new(player, slot, item_id)
	local self = setmetatable({}, coopHUD.Item)
	self.entPlayer = player
	self.slot = slot
	if slot >= 0 then
		self.id = self.entPlayer:GetActiveItem(self.slot)
	else
		self.id = item_id
	end
	self.sprite = self:getSprite()
	self.charge = self.entPlayer:GetActiveCharge(self.slot)
	self.charge_sprites = self.getChargeSprites(self)
	return self
end
function coopHUD.Item.getChargeSprites(self)
	-- Gets charge of item from  player, slot
	local sprites = {
		beth_charge = Sprite(),
		charge      = Sprite(),
		overlay     = Sprite(),
	}
	if self.id == 0 or self.id == nil or self.slot < 0 then return nil end
	local max_charges = Isaac.GetItemConfig():GetCollectible(self.id).MaxCharges
	if max_charges == 0 then return false end
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
			beth_charge = player:GetEffectiveSoulCharge()
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
	if self.id == 0 or self.entPlayer.Variant == 1 then return nil end
	-- locals initial
	local sprite = Sprite()
	local sprite_path = Isaac.GetItemConfig():GetCollectible(self.id).GfxFileName
	local anim_name = "Idle"
	local frame_num = 0
	sprite:Load(coopHUD.GLOBALS.item_anim_path, false)
	--
	-- Custom sprites set - jars etc.
	if self.id == CollectibleType.COLLECTIBLE_THE_JAR then
		sprite_path = "gfx/characters/costumes/costume_rebirth_90_thejar.png"
	elseif self.id == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then
		sprite_path = "gfx/characters/costumes/costume_434_jarofflies.png"
	elseif self.id == CollectibleType.COLLECTIBLE_JAR_OF_WISPS then
		sprite_path = "gfx/ui/hud_jarofwisps.png"
	elseif self.id == CollectibleType.COLLECTIBLE_EVERYTHING_JAR then
		sprite_path = "gfx/ui/hud_everythingjar.png"
	elseif self.id == CollectibleType.COLLECTIBLE_FLIP then
		-- Fixme: Flip weird sprite (too much white :D) when lazarus b
		sprite_path = 'gfx/ui/ui_flip_coop.png'
	elseif self.id == CollectibleType.COLLECTIBLE_URN_OF_SOULS then
		item_sprite = "gfx/ui/hud_urnofsouls.png"
	end
	if self.slot >= 0 then
		-- Sets overlay/charges state frame --
		local max_charges = Isaac.GetItemConfig():GetCollectible(self.id).MaxCharges -- gets max charges
		if max_charges == 0 then
			-- checks id item has any charges
			frame_num = 0 -- set frame to unloaded
		elseif self.entPlayer:NeedsCharge(self.slot) == false or self.entPlayer:GetActiveCharge(self.slot) >= max_charges then
			-- checks if item dont needs charges or item is overloaded
			frame_num = 1 -- set frame to loaded
		else
			frame_num = 0  -- set frame to unloaded
		end
	end
	sprite:ReplaceSpritesheet(0, sprite_path) -- item
	sprite:ReplaceSpritesheet(1, sprite_path) -- border
	sprite:ReplaceSpritesheet(2, sprite_path) -- shadow
	--
	sprite:SetFrame(anim_name, frame_num)
	sprite:LoadGraphics()
	--
	return sprite
end
function coopHUD.Item:update()
	if self.id ~= self.entPlayer:GetActiveItem(self.slot) then

		self.id = self.entPlayer:GetActiveItem(self.slot)
		self:updateSprite()
	end
	if self.charge ~= self.entPlayer:GetActiveCharge(self.slot) then

		self.charge = self.entPlayer:GetActiveCharge(self.slot)
		self.charge_sprites = self.getChargeSprites(self)
		self:updateSprite()
	end
end
function coopHUD.Item:updateSprite()
	self.sprite = self:getSprite()
end
function coopHUD.Item:renderChargeBar(pos, mirrored, scale, down_anchor)
	local temp_pos = Vector(pos.X, pos.Y)
	local offset = Vector(0, 0)
	--
	local sprite_scale = scale
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end
	--
	if mirrored then
		temp_pos.X = temp_pos.X - (4 * sprite_scale.X)
		offset.X = -12 * sprite_scale.X
	else
		temp_pos.X = temp_pos.X + (4 * sprite_scale.X)
		offset.X = 12 * sprite_scale.X
	end
	--
	if down_anchor then
		temp_pos.Y = temp_pos.Y - (20 * sprite_scale.Y)
		offset.Y = -32 * sprite_scale.Y
	else
		temp_pos.Y = temp_pos.Y + (16 * sprite_scale.Y)
		offset.Y = 32 * sprite_scale.Y
	end
	--
	if self.charge_sprites then
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
function coopHUD.Item:render(pos, mirrored, scale, down_anchor)
	local temp_pos = Vector(pos.X, pos.Y)
	local sprite_scale = scale
	local offset = Vector(0, 0)
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end
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
	if self.sprite ~= nil then
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
	end
	if self.slot >= 0 and self.slot ~= ActiveSlot.SLOT_SECONDARY then
		self:renderChargeBar(Vector(pos.X + offset.X, pos.Y), mirrored, scale, down_anchor)
	end

	return offset
end
--
coopHUD.Trinket = {}
coopHUD.Trinket.__index = coopHUD.Trinket
setmetatable(coopHUD.Trinket, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.Trinket.new(player, slot, trinket_id)
	local self = setmetatable({}, coopHUD.Trinket)
	self.entPlayer = player
	self.slot = slot
	self.id = player:GetTrinket(self.slot)
	self.sprite = self:getSprite()
	return self
end
function coopHUD.Trinket:getSprite()
	if self.id == 0 or self.id == nil then return nil end
	local sprite = Sprite()
	sprite:Load(coopHUD.GLOBALS.item_anim_path, true)
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
	--
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end -- sets def sprite_scale
	--
	if mirrored then
		temp_pos.X = temp_pos.X - (16 * sprite_scale.X)
		offset.X = -24
	else
		temp_pos.X = temp_pos.X + (16 * sprite_scale.X)
		offset.X = 24
	end
	--
	if down_anchor then
		temp_pos.Y = temp_pos.Y - (16 * sprite_scale.Y)
		offset.Y = -32
	else
		temp_pos.Y = temp_pos.Y + (16 * sprite_scale.Y)
		offset.Y = 24
	end
	--
	if self.sprite then
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
	end
	return offset
end
--
coopHUD.Pocket = {}
coopHUD.Pocket.__index = coopHUD.Pocket
setmetatable(coopHUD.Pocket, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.Pocket.new(parent, slot)
	local self = setmetatable({}, coopHUD.Pocket)
	self.parent = parent
	self.slot = slot
	self.type,self.id  = self:getPocket() -- holds pocket type -- 0 - none, 1 - card, 2 - pill, 3 - item
	self.sprite = self:getSprite()
	self.item = self:getItem()
	self.name, self.desc = self:getName()
	return self
end
function coopHUD.Pocket:getPocket()
	local pocket_type = 0
	local pocket_id = 0
	if self.parent.entPlayer:GetCard(self.slot) > 0 then
		pocket_id = self.parent.entPlayer:GetCard(self.slot)
		pocket_type= 1
	elseif self.parent.entPlayer:GetPill(self.slot) > 0 then
		pocket_id = self.parent.entPlayer:GetPill(self.slot)
		pocket_type = 2
	else
		if self.slot == 1 then
			if self.parent.first_pocket.type ~= 3 then
				pocket_id = self.parent.entPlayer:GetActiveItem(2)
				self.type = 3
			end
		elseif self.slot == 2 then
			if self.parent.first_pocket.type ~= 3 and self.parent.second_pocket.type ~= 3 then
				self.id = self.parent.entPlayer:GetActiveItem(2)
				self.type = 3
			end
		else
			pocket_id = self.parent.entPlayer:GetActiveItem(2)
			pocket_type = 3
		end
	end
	return pocket_type,pocket_id
end
function coopHUD.Pocket:getSprite()
	local sprite = Sprite()
	if self.type == 1 then -- Card
		sprite:Load(coopHUD.GLOBALS.card_anim_path, true)
		sprite:SetFrame("CardFronts", self.id) -- sets card frame
	elseif self.type == 2 then -- Pill
		if self.id > 2048 then self.id = self.id - 2048 end -- check if its horse pill and change id to normal
		sprite:Load(coopHUD.GLOBALS.pill_anim_path, true)
		sprite:SetFrame("Pills", self.id) --sets frame to pills with correct id
	else
		sprite = nil
	end
	return sprite
end
function coopHUD.Pocket:getItem()
	if self.type ~= 3 then return nil end
	return coopHUD.Item(self.parent.entPlayer, 2)
end
function coopHUD.Pocket:getName()
	local name = nil
	local desc = nil
	if self.type == 1 then
		name = Isaac.GetItemConfig():GetCard(self.id).Name
		name = string.sub(name, 2) --  get rid of # on front of
		name = langAPI.getPocketName(name)
		--
		desc = Isaac.GetItemConfig():GetCard(self.id).Description
		desc = string.sub(desc, 2) --  get rid of # on front of
		desc = langAPI.getPocketName(desc)
	elseif self.type == 2 then
		name = "???" .. " "
		desc = "???" .. " "
		local item_pool = Game():GetItemPool()
		if item_pool:IsPillIdentified(self.id) then
			local pill_effect = item_pool:GetPillEffect(self.id, self.parent.entPlayer)
			name = Isaac.GetItemConfig():GetPillEffect(pill_effect).Name
			name = string.sub(name, 2) --  get rid of # on front of
			name = langAPI.getPocketName(name)
			desc = name
		end

	elseif self.type == 3 then
		name = Isaac.GetItemConfig():GetCollectible(self.id).Name
		desc = Isaac.GetItemConfig():GetCollectible(self.id).Description
		name = string.sub(name, 2) --  get rid of # on front of
		name = langAPI.getItemName(name)
		desc = string.sub(desc, 2) --  get rid of # on front of
		desc = langAPI.getItemName(desc)
	end
	return name, desc
end
function coopHUD.Pocket:render(pos, mirrored, scale, down_anchor)
	local temp_pos = Vector(pos.X, pos.Y)
	local sprite_scale = scale
	local offset = Vector(0, 0)
	--
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end -- sets def sprite_scale
	--
	if self.sprite then
		if mirrored then
			temp_pos.X = temp_pos.X - (16 * sprite_scale.X)
			offset.X = -24
		else
			temp_pos.X = temp_pos.X + (16 * sprite_scale.X)
			offset.X = 24
		end
		--
		if down_anchor then
			temp_pos.Y = temp_pos.Y - (16 * sprite_scale.Y)
			offset.Y = -32
		else
			temp_pos.Y = temp_pos.Y + (16 * sprite_scale.Y)
			offset.Y = 24
		end
		--
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
	elseif self.item then
		offset = self.item:render(pos, mirrored, scale, down_anchor)
	end
	if self.name or self.desc and self.slot == 0 then
		local text = self.name
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, self.parent.controller_index) then
			text = self.desc
		end
		local f = Font()
		local font_color = KColor(1, 1, 1, 1)
		f:Load("font/pftempestasevencondensed.fnt")
		f:DrawStringScaled(text, temp_pos.X, temp_pos.Y, sprite_scale.X, sprite_scale.Y, font_color, 0, true)
	end
	return offset
end
--
function coopHUD.getMinimapOffset()
	local minimap_offset = Vector(Isaac.GetScreenWidth(), 0)
	if MinimapAPI ~= nil then
		-- Modified function from minimAPI by Wolfsauge
		local screen_size = Vector(Isaac.GetScreenWidth(), 0)
		local is_large = MinimapAPI:IsLarge()
		if not is_large and MinimapAPI:GetConfig("DisplayMode") == 2 then
			-- BOUNDED MAP
			minimap_offset = Vector(screen_size.X - MinimapAPI:GetConfig("MapFrameWidth") - MinimapAPI:GetConfig("PositionX") - 4,
			                        2)
		elseif not is_large and MinimapAPI:GetConfig("DisplayMode") == 4
				or Game():GetLevel():GetCurses() == LevelCurse.CURSE_OF_THE_LOST then
			-- NO MAP or cure of the lost active
			minimap_offset = Vector(screen_size.X - 4, 2)
		else
			-- LARGE
			local minx = screen_size.X
			for i, v in ipairs(MinimapAPI:GetLevel()) do
				if v ~= nil then
					if v:GetDisplayFlags() > 0 then
						if v.RenderOffset ~= nil then
							minx = math.min(minx, v.RenderOffset.X)
						end
					end
				end

			end
			minimap_offset = Vector(minx - 4, 2) -- Small
		end
		if MinimapAPI:GetConfig("Disable") or MinimapAPI.Disable then minimap_offset = Vector(screen_size.X - 4, 2) end
		local r = MinimapAPI:GetCurrentRoom()
		if r ~= nil then
			if MinimapAPI:GetConfig("HideInCombat") == 2 then
				if not r:IsClear() and r:GetType() == RoomType.ROOM_BOSS then
					minimap_offset = Vector(screen_size.X - 0, 2)
				end
			elseif MinimapAPI:GetConfig("HideInCombat") == 3 then
				if r ~= nil then
					if not r:IsClear() then
						minimap_offset = Vector(screen_size.X - 0, 2)
					end
				end
			end
		end
	end
	return minimap_offset
end
function coopHUD.updateAnchors()
	local offset = 0
	if SHExists then
		offset = ScreenHelper.GetOffset()
	end
	offset = offset + Options.HUDOffset * 10
	if coopHUD.anchors.top_left ~= Vector.Zero + Vector(offset * 2, offset * 1.2) then
		coopHUD.anchors.top_left = Vector.Zero + Vector(offset * 2, offset * 1.2)
	end
	if coopHUD.anchors.bot_left ~= Vector(0, Isaac.GetScreenHeight()) + Vector(offset * 2.2, -offset * 1.6) then
		coopHUD.anchors.bot_left = Vector(0, Isaac.GetScreenHeight()) + Vector(offset * 2.2, -offset * 1.6)
	end
	if coopHUD.anchors.top_right ~= Vector(coopHUD.getMinimapOffset().X, 0) + Vector(-offset * 2.2, offset * 1.2) then
		coopHUD.anchors.top_right = Vector(coopHUD.getMinimapOffset().X, 0) + Vector(-offset * 2.2, offset * 1.2)
	end
	if coopHUD.anchors.bot_right ~= Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()) + Vector(-offset * 2.2,
	                                                                                                 -offset * 1.6) then
		coopHUD.anchors.bot_right = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()) + Vector(-offset * 2.2,
		                                                                                             -offset * 1.6)
	end
end
function coopHUD.getPlayerNumByControllerIndex(controller_index)
	-- Function returns player number searching coopHUD.player table for matching controller index
	local final_index = -1
	for i, p in pairs(coopHUD.players) do
		if p.controller_index == controller_index then
			final_index = i
		end
	end
	return final_index
end