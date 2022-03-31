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
	if self.charge_sprites then
		--
		local sprite_scale = scale
		if sprite_scale == nil then sprite_scale = Vector(1, 1) end
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
function coopHUD.Item:render(pos, mirrored, scale, down_anchor)
	local temp_pos = Vector(pos.X, pos.Y)
	local sprite_scale = scale
	local offset = Vector(0, 0)
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end
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
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
	end
	if self.slot >= 0 and self.slot ~= ActiveSlot.SLOT_SECONDARY then
		local charge_off = self:renderChargeBar(Vector(pos.X + offset.X, pos.Y), mirrored, scale, down_anchor)
		offset.X = offset.X + charge_off.X
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
	self.type, self.id = self:getPocket() -- holds pocket type -- 0 - none, 1 - card, 2 - pill, 3 - item
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
		pocket_type = 1
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
	return pocket_type, pocket_id
end
function coopHUD.Pocket:getSprite()
	local sprite = Sprite()
	if self.type == 1 then
		-- Card
		sprite:Load(coopHUD.GLOBALS.card_anim_path, true)
		sprite:SetFrame("CardFronts", self.id) -- sets card frame
	elseif self.type == 2 then
		-- Pill
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
	if self.type == nil then return nil, nil end
	if self.id == 0 then return nil, nil end
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
function coopHUD.Pocket:update()
	local type, id = self:getPocket()
	if self.id ~= id then
		self.type, self.id = type, id
		self.sprite = self:getSprite()
		self.item = self:getItem()
		self.name, self.desc = self:getName()
	end
end
function coopHUD.Pocket:render(pos, mirrored, scale, down_anchor)
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
	--
	if self.sprite then
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
	elseif self.item then
		offset = self.item:render(pos, mirrored, scale, down_anchor)
	end
	if (self.name or self.desc) and self.slot == 0 then
		local text = self.name
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, self.parent.controller_index) then
			text = self.desc
		end
		local font_height = coopHUD.HUD.pocket_font:GetLineHeight()
		temp_pos = Vector(pos.X + offset.X, pos.Y + offset.Y - font_height)
		if mirrored then temp_pos.X = temp_pos.X - string.len(text) * (6 * sprite_scale.X) end
		if down_anchor then
			temp_pos.Y = temp_pos.Y - offset.Y
		end
		coopHUD.HUD.pocket_font:DrawStringScaled(text, temp_pos.X, temp_pos.Y, sprite_scale.X, sprite_scale.Y,
		                                         self.parent.font_color, 0, true)
	end
	return offset
end
--
coopHUD.Heart = {}
coopHUD.Heart.__index = coopHUD.Heart
setmetatable(coopHUD.Heart, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.Heart.new(parent, heart_pos)
	local self = setmetatable({}, coopHUD.Heart)
	self.parent = parent
	self.pos = heart_pos
	self.type, self.overlay = self:getType()
	if self.type == nil then return nil end
	self.sprite = self:getSprite()
	return self
end
function coopHUD.Heart:getType()
	---- Modified function from HUD_API from NeatPotato mod
	local player = self.parent.entPlayer
	local player_type = player:GetPlayerType()
	local heart_type = nil
	local eternal = false
	local golden = false
	local remain_souls = 0
	local overlay = nil
	if player_type == 10 or player_type == 31 then
		if self.pos == 0 then
			-- only returns for first pos
			-- checks if Holy Mantle is loaded
			if player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE) ~= 0 then
				heart_type = 'HolyMantle'
			end
		end
	elseif Game():GetLevel():GetCurses() == 8 then
		-- checks curse of the unknown
		if self.pos == 0 and not player:IsSubPlayer() then
			heart_type = 'CurseHeart'
			return heart_type, overlay
		end
	else
		eternal = false
		golden = false
		local total_hearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts()) / 2)
		local empty_hearts = math.floor((player:GetMaxHearts() - player:GetHearts()) / 2)
		if empty_hearts < 0 then empty_hearts = 0 end
		if player:GetGoldenHearts() > 0 and (self.pos >= total_hearts - (player:GetGoldenHearts() + empty_hearts)) then ---(total_hearts - (player:GetGoldenHearts()+empty_hearts)))
		golden = true
		end
		-- <Normal hearts>
		if player:GetMaxHearts() / 2 > self.pos then
			-- red heart type
			-- <Keeper Hearts>
			if player_type == 14 or player_type == 33 then
				golden = false
				if player:GetHearts() - (self.pos * 2) > 1 then
					heart_type = "CoinHeartFull"
				elseif player:GetHearts() - (self.pos * 2) == 1 then
					heart_type = "CoinHeartHalf"
				else
					heart_type = "CoinEmpty"
				end
				-- </Keeper Hearts>
			else
				-- <Red Hearts Hearts>
				if player:GetHearts() - (self.pos * 2) > 1 then
					heart_type = "RedHeartFull"
				elseif player:GetHearts() - (self.pos * 2) == 1 then
					heart_type = "RedHeartHalf"
				else
					heart_type = "EmptyHeart"
				end
				-- </Red Hearts Hearts>
			end
			-- <Eternal check>
			if player:GetEternalHearts() > 0 and -- checks if any eternal hearts
					self.pos + 1 == player:GetMaxHearts() / 2 then
				-- checks if self.pos is last pos
				eternal = true
			end
			-- </Normal hearts>
			-- <BLue/Black hearts>
		elseif player:GetSoulHearts() > 0 or player:GetBoneHearts() > 0 then
			-- checks
			local red_offset = self.pos - (player:GetMaxHearts() / 2)
			if math.ceil(player:GetSoulHearts() / 2) + player:GetBoneHearts() <= red_offset then
				heart_type = nil
			else
				local prev_red = 0
				if player:IsBoneHeart(red_offset) then

					if red_offset > 0 then
						for i = 0, red_offset do
							if player:IsBoneHeart(i) == false then
								prev_red = prev_red + 2
							end
						end
					end
					-- HUDAPI
					local overloader_reds = player:GetHearts() + prev_red - (self.pos * 2) --overloaded reds heart in red cointainers
					if overloader_reds > 1 then
						heart_type = "BoneHeartFull"
					elseif overloader_reds == 1 then
						heart_type = "BoneHeartHalf"
					else
						heart_type = "BoneHeartEmpty"
					end
				else
					local prev_bones = 0
					if red_offset > 0 then
						for i = 0, red_offset do
							if player:IsBoneHeart(i) then
								prev_bones = prev_bones + 1
							end
						end
					end
					local black_hearts = (red_offset * 2 + 1) - (2 * prev_bones)
					local remain_souls = player:GetSoulHearts() + (2 * prev_bones) - (red_offset * 2)
					if player:IsBlackHeart(black_hearts) then
						if remain_souls > 1 then
							heart_type = "BlackHeartFull"
						else
							heart_type = "BlackHeartHalf"
						end
					else
						if remain_souls > 1 then
							heart_type = "BlueHeartFull"
						else
							heart_type = "BlueHeartHalf"
						end
					end
					--eternal heart overlay
					if player:GetEternalHearts() > 0 and self.pos == 0 then
						eternal = true
					end
				end
			end
		end
		-- </BLue/Black hearts>
		-- <RottenHearts hearts>
		if player:GetRottenHearts() > 0 then
			local non_rotten_reds = player:GetHearts() / 2 - player:GetRottenHearts()
			if heart_type == "RedHeartFull" then
				if self.pos >= non_rotten_reds then
					heart_type = "RottenHeartFull"
				end
			elseif heart_type == "BoneHeartFull" then
				local overloader_reds = player:GetHearts() + remain_souls - (self.pos * 2)
				if overloader_reds - player:GetRottenHearts() * 2 <= 0 then
					heart_type = "RottenBoneHeartFull"
				end
			end
		end
		-- </RottenHearts hearts>
		-- <Broken heart type>  - https://bindingofisaacrebirth.fandom.com/wiki/Health#Broken_Hearts
		if player:GetBrokenHearts() > 0 then
			if self.pos > total_hearts - 1 and total_hearts + player:GetBrokenHearts() > self.pos then
				if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or -- Check if Keeper
						player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
					heart_type = 'BrokenCoinHeart'
				else
					heart_type = 'BrokenHeart'
				end
			end
		end
		-- </Broken heart type>
		-- <Overlays>
		if eternal and golden then
			overlay = "GoldWhiteOverlay"
		elseif eternal then
			overlay = "WhiteHeartOverlay"
		elseif golden then
			overlay = "GoldHeartOverlay"
		else
			overlay = nil
		end
	end
	return heart_type, overlay
end
function coopHUD.Heart:getSprite()
	if self.type ~= nil then
		local sprite = Sprite()
		sprite:Load(coopHUD.GLOBALS.hearts_anim_path, true)
		sprite:SetFrame(self.type, 0)
		if self.overlay ~= nil then
			if self.overlay ~= 'GoldWhiteOverlay' then
				sprite:SetOverlayFrame(self.overlay, 0)
			else
				sprite:ReplaceSpritesheet(0, "gfx/ui/ui_hearts_gold_coop.png") -- replaces png file to get
				sprite:SetOverlayFrame('WhiteHeartOverlay', 0)
				sprite:LoadGraphics()
			end
		end
		return sprite
	else
		return nil
	end
end
function coopHUD.Heart:update()
	local type, overlay = self:getType()
	if self.type ~= type then
		self.type = type
		self.sprite = self:getSprite()
	end
	if self.overlay ~= overlay then
		self.overlay = overlay
		self.sprite = self:getSprite()
	end
end
function coopHUD.Heart:render(pos, scale)
	local offset = Vector(0, 0)
	local sprite_scale = scale
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end
	local temp_pos = Vector(pos.X + (8 * sprite_scale.X), pos.Y + (8 * sprite_scale.Y))
	--
	if self.sprite then
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
		offset.X = 12 * math.ceil((self.pos + 1) % 6) * sprite_scale.X
		offset.Y = 10 * math.floor((self.pos + 1) / 6) * sprite_scale.Y
	end
	return offset
end
--
coopHUD.HeartTable = {}
coopHUD.HeartTable.__index = coopHUD.HeartTable
setmetatable(coopHUD.HeartTable, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.HeartTable.new(parent)
	local self = setmetatable({}, coopHUD.HeartTable)
	self.parent = parent
	for i = 0, self.parent.total_hearts do
		self[i] = coopHUD.Heart(self.parent, i)
	end
	return self
end
function coopHUD.HeartTable:render(pos, mirrored, scale, down_anchor)
	local temp_off = Vector(0, 0)
	local init_pos = Vector(pos.X, pos.Y)
	--
	local hearts_span
	if self.parent.total_hearts >= 6 then
		-- Determines how many columns will be
		hearts_span = 6
	else
		hearts_span = self.parent.total_hearts % 6
	end
	local rows = math.ceil(self.parent.total_hearts / 6)
	local cols = 6
	if self.parent.total_hearts < 6 then
		cols = math.ceil(self.parent.total_hearts % 6)
	end
	if mirrored then
		init_pos.X = pos.X - (12 * scale.X) * hearts_span
		cols = cols * -1
	end
	if down_anchor then
		init_pos.Y = pos.Y + (-16 * scale.Y) * math.ceil(self.parent.total_hearts / 6)
		rows = rows * -1.5
	end
	-- RENDER
	for i = 0, self.parent.max_health_cap do
		if self[i] then
			local temp_pos = Vector(init_pos.X + temp_off.X, init_pos.Y + temp_off.Y)
			temp_off = self[i]:render(temp_pos, scale)
		end
	end
	--
	return Vector(12 * scale.X * cols, 12 * scale.Y* rows)
end
function coopHUD.HeartTable:update()
	local temp_total_hearts = math.ceil((self.parent.entPlayer:GetEffectiveMaxHearts() + self.parent.entPlayer:GetSoulHearts()) / 2)
	if self.parent.total_hearts ~= temp_total_hearts then
		self.parent.total_hearts = temp_total_hearts
	end
	for i = 0, self.parent.total_hearts do
		self[i] = coopHUD.Heart(self.parent, i)
	end
end
-----coopHUD.ExtraCharge - holds blood or soul charge for Bethany
-----@param parent coopHUD.Player
------@return coopHUD.ExtraCharge or nil if not Bethany
coopHUD.ExtraCharge         = {}
coopHUD.ExtraCharge.__index = coopHUD.ExtraCharge
setmetatable(coopHUD.ExtraCharge, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.ExtraCharge.new(parent)
	local self        = setmetatable({}, coopHUD.ExtraCharge)
	self.parent       = parent
	self.type         = 0
	self.amount       = 0
	--
	local player_type = self.parent.entPlayer:GetPlayerType()
	if player_type ~= PlayerType.PLAYER_BETHANY and player_type ~= PlayerType.PLAYER_BETHANY_B then
		return nil
	end
	-- Charge amount init
	if player_type == PlayerType.PLAYER_BETHANY then
		-- inits charge amount for Bethany
		self.amount = self.parent.entPlayer:GetSoulCharge()
		self.type   = 12
	elseif player_type == PlayerType.PLAYER_BETHANY_B then
		-- inits charge amount for T. Bethany
		self.amount = self.parent.entPlayer:GetBloodCharge()
		self.type   = 15
	end
	-- Sprite init
	self.sprite = self:getSprite()
	return self
end
function coopHUD.RunInfo.getType(info_type)
	local type
	local player = Isaac.GetPlayer(0)
	if type == coopHUD.RunInfo.KEY then
		if player:HasGoldenKey() then type = 3 end
	end
	if type == coopHUD.RunInfo.BOMB then
		if player:HasGoldenBomb() then type =  6 end
		if player:GetNumGigaBombs() > 0 then type =  14 end

	end
	return type
end
function coopHUD.RunInfo:getSprite()
	local sprite = Sprite()
	sprite:Load(coopHUD.GLOBALS.hud_el_anim_path, true)
	sprite:SetFrame('Idle', self.type)
	sprite:LoadGraphics()
	return sprite
end
function coopHUD.ExtraCharge:render(pos, mirrored, scale, down_anchor)
	-- Scale set
	local sprite_scale = scale
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end
	--
	local temp_pos = Vector(pos.X, pos.Y)
	local text_pos = Vector(pos.X, pos.Y)
	if self.sprite then
		--
		if mirrored then
			temp_pos.X = temp_pos.X - 20 - self.parent.charges_font:GetStringWidth(string.format('x%d', self.amount))
			text_pos.X = text_pos.X - 16
		else
			text_pos.X = text_pos.X + 16
		end
		--
		if down_anchor then
			temp_pos.Y = temp_pos.Y - 16
			text_pos.Y = text_pos.Y - 16
		end
		--
		self.sprite:Render(temp_pos)
		self.parent.charges_font:DrawString(string.format('x%d', self.amount), text_pos.X, text_pos.Y,
		                                    self.parent.font_color, 0, true)
	end
end
function coopHUD.ExtraCharge:update()
	if self.type == 12 then
		-- update charge amount for Bethany
		if self.amount ~= self.parent.entPlayer:GetSoulCharge() then
			self.amount = self.parent.entPlayer:GetSoulCharge()
		end
	elseif self.type == 15 then
		-- update charge amount for T. Bethany
		if self.amount ~= self.parent.entPlayer:GetBloodCharge() then
			self.amount = self.parent.entPlayer:GetBloodCharge()
		end
	end
end
--
coopHUD.Poops = {}
--
coopHUD.Stat = {}
coopHUD.Stat.__index = coopHUD.Stat
setmetatable(coopHUD.Stat, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.Stat.new(parent)
	local self = setmetatable({}, coopHUD.Stat)
	return self
end
--
coopHUD.PlayerHead = {}
coopHUD.PlayerHead.__index = coopHUD.PlayerHead
setmetatable(coopHUD.PlayerHead, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.PlayerHead.new(parent)
	local self = setmetatable({}, coopHUD.PlayerHead)
	self.parent = parent
	self.name = 'P' .. tostring(self.parent.game_index - coopHUD.essau_no + 1)
	self.sprite = self:getSprite()
	return self
end
function coopHUD.PlayerHead:getSprite()
	local player_type = self.parent.entPlayer:GetPlayerType()
	if self.parent.entPlayer.Variant == 1 then return nil end -- prevents when old coop ghost
	if player_type == 40 then player_type = 36 end
	if 0 <= player_type and player_type <= 37 then
		local sprite = Sprite()
		sprite:Load(coopHUD.GLOBALS.player_head_anim_path, true)
		sprite:SetFrame('Main', player_type + 1)
		sprite:ReplaceSpritesheet(1, "/gfx/ui/blank.png")
		sprite:LoadGraphics()
		return sprite
	else
		return nil
	end
end
function coopHUD.PlayerHead:render(anchor, mirrored, scale, down_anchor)
	local offset = Vector(0, 0)
	if self.sprite then
		local temp_pos = Vector(anchor.X, anchor.Y)
		local text_pos = Vector(anchor.X, anchor.Y)
		local sprite_scale = scale
		--
		if sprite_scale == nil then sprite_scale = Vector(1, 1) end
		--
		if mirrored then
			temp_pos.X = temp_pos.X - (8 * sprite_scale.X)
			text_pos.X = text_pos.X - (8 * sprite_scale.X)
			offset.X = (-16 * 1.25) * sprite_scale.X
		else
			temp_pos.X = temp_pos.X + (8 * sprite_scale.X)
			text_pos.X = text_pos.X + (8 * sprite_scale.X)
			offset.X = (16 * sprite_scale.X)
		end
		--
		if down_anchor then
			temp_pos.Y = temp_pos.Y - (coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() )
			text_pos.Y = text_pos.Y - (coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() )
		else
			temp_pos.Y = temp_pos.Y + (coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() )
			text_pos.Y = text_pos.Y + (16 * sprite_scale.Y)
		end
		--
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
		coopHUD.HUD.fonts.lua_mini:DrawString(self.name,
		                                            text_pos.X, text_pos.Y,
		                                            self.parent.font_color, 1, true)
	end
	return offset
end
--
coopHUD.Collectibles = {}
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