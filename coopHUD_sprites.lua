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
	self.frame_num = self:getFrameNum()
	self.sprite = self:getSprite()
	self.charge = self:getCharge()
	self.charge_sprites = self.getChargeSprites(self)
	self.temp_item = nil
	return self
end
function coopHUD.Item.getChargeSprites(self)
	-- Gets charge of item from  player, slot
	local sprites = {
		beth_charge = Sprite(),
		charge = Sprite(),
		overlay = Sprite(),
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
	if self.id == 0 or (self.entPlayer and self.entPlayer.Variant == 1) then return nil end
	-- locals initial
	local sprite = Sprite()
	local sprite_path = Isaac.GetItemConfig():GetCollectible(self.id).GfxFileName
	local anim_name = "Idle"
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
	sprite:ReplaceSpritesheet(0, sprite_path) -- item
	sprite:ReplaceSpritesheet(1, sprite_path) -- border
	sprite:ReplaceSpritesheet(2, sprite_path) -- shadow
	--
	sprite:SetFrame(anim_name, self.frame_num)
	sprite:LoadGraphics()
	--
	return sprite
end
function coopHUD.Item:getFrameNum()
	local frame_num = 0
	if self.id > 0 and self.slot >= 0 then
		-- Sets overlay/charges state frame --
		local max_charges = Isaac.GetItemConfig():GetCollectible(self.id).MaxCharges -- gets max charges
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
	return frame_num
end
function coopHUD.Item:getCharge()
	if self.slot >= 0 then
		local item_charge = self.entPlayer:GetActiveCharge(self.slot)
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
end
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
	self:updateCharge()
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
coopHUD.Pocket.NONE = 0
coopHUD.Pocket.CARD = 1
coopHUD.Pocket.PILL = 2
coopHUD.Pocket.COLLECTIBLE = 3
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
function coopHUD.Pocket:getSprite()
	local sprite = Sprite()
	if self.type == coopHUD.Pocket.CARD then
		-- Card
		sprite:Load(coopHUD.GLOBALS.card_anim_path, true)
		sprite:SetFrame("CardFronts", self.id) -- sets card frame
	elseif self.type == coopHUD.Pocket.PILL then
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
	if self.id == coopHUD.Pocket.NONE then return nil, nil end
	if self.type == coopHUD.Pocket.CARD then
		name = Isaac.GetItemConfig():GetCard(self.id).Name
		name = string.sub(name, 2) --  get rid of # on front of
		name = langAPI.getPocketName(name)
		--
		desc = Isaac.GetItemConfig():GetCard(self.id).Description
		desc = string.sub(desc, 2) --  get rid of # on front of
		desc = langAPI.getPocketName(desc)
	elseif self.type == coopHUD.Pocket.PILL then
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
	elseif self.type == coopHUD.Pocket.COLLECTIBLE then
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
		local font_height = coopHUD.HUD.fonts.pft:GetLineHeight()
		temp_pos = Vector(pos.X + offset.X, pos.Y + offset.Y - font_height)
		if mirrored then temp_pos.X = temp_pos.X - string.len(text) * (6 * sprite_scale.X) end
		if down_anchor then
			temp_pos.Y = temp_pos.Y - offset.Y
		end
		coopHUD.HUD.fonts.pft:DrawStringScaled(text, temp_pos.X, temp_pos.Y, sprite_scale.X, sprite_scale.Y,
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
	for i = 0, self.parent.max_health_cap do
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
	if self[0] and self[0].type == 'CurseHeart' then
		cols = 1
		hearts_span = 1
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
		local temp_pos = Vector(init_pos.X + temp_off.X, init_pos.Y + temp_off.Y)
		temp_off = self[i]:render(temp_pos, scale)
	end
	--
	return Vector(12 * scale.X * cols, 12 * scale.Y * rows)
end
function coopHUD.HeartTable:update()
	local temp_total_hearts = math.ceil((self.parent.entPlayer:GetEffectiveMaxHearts() + self.parent.entPlayer:GetSoulHearts()) / 2)
	if self.parent.total_hearts ~= temp_total_hearts then
		self.parent.total_hearts = temp_total_hearts
	end
	for i = 0, self.parent.total_hearts do
		self[i]:update()
	end
end
--
coopHUD.RunInfo = {}
coopHUD.RunInfo.__index = coopHUD.RunInfo
setmetatable(coopHUD.RunInfo, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
coopHUD.RunInfo.COIN = 0
coopHUD.RunInfo.KEY = 1
coopHUD.RunInfo.BOMB = 2
coopHUD.RunInfo.GOLDEN_KEY = 3
coopHUD.RunInfo.HARD = 4 -- TODO
coopHUD.RunInfo.NO_ACHIEVEMENTS = 5 -- TODO
coopHUD.RunInfo.GOLDEN_BOMB = 6
coopHUD.RunInfo.GREED_WAVES = 7
coopHUD.RunInfo.D_RUN = 7 -- TODO
coopHUD.RunInfo.SLOT = 9 -- TODO
coopHUD.RunInfo.GREEDIER = 11
coopHUD.RunInfo.BETH = 12
coopHUD.RunInfo.GIGA_BOMB = 14
coopHUD.RunInfo.T_BETH = 15
coopHUD.RunInfo.POOP = 16

function coopHUD.RunInfo.new(info_type)
	local self = setmetatable({}, coopHUD.RunInfo)
	self.type = info_type
	self.type = self:getType()
	self.amount = self:getAmount()
	self.sprite = self:getSprite()
	return self
end
function coopHUD.RunInfo:getAmount()
	local player = Isaac.GetPlayer(0)
	if player then
		if self.type == coopHUD.RunInfo.COIN then
			return player:GetNumCoins()
		end
		if self.type == coopHUD.RunInfo.BOMB
				or self.type == coopHUD.RunInfo.GOLDEN_BOMB
				or self.type == coopHUD.RunInfo.GIGA_BOMB then
			return player:GetNumBombs()
		end
		if self.type == coopHUD.RunInfo.KEY or
				self.type == coopHUD.RunInfo.GOLDEN_KEY then
			return player:GetNumKeys()
		end
		if self.type == coopHUD.RunInfo.BETH then
			return player:GetSoulCharge()
		end
		if self.type == coopHUD.RunInfo.T_BETH then
			return player:GetBloodCharge()
		end
		if self.type == coopHUD.RunInfo.POOP then
			return player:GetPoopMana()
		end
	end
	return 0
end
function coopHUD.RunInfo:getType()
	local type = self.type
	local player = Isaac.GetPlayer(0)
	if player then
		if type == coopHUD.RunInfo.KEY then
			if player:HasGoldenKey() then type = coopHUD.RunInfo.GOLDEN_KEY end
		elseif type == coopHUD.RunInfo.BOMB then
			if player:HasGoldenBomb() then type = coopHUD.RunInfo.GOLDEN_BOMB end
			if player:GetNumGigaBombs() > 0 then type = coopHUD.RunInfo.GIGA_BOMB end
		end
	end
	return type
end
function coopHUD.RunInfo:getSprite()
	if self.type == coopHUD.RunInfo.BOMB then
		if self:checkPlayer() then
			return nil
		end
	end
	if self.type == coopHUD.RunInfo.BETH then
		if self:checkPlayer() then
			return nil
		end
	elseif self.type == coopHUD.RunInfo.T_BETH then
		if self:checkPlayer() then
			return nil
		end
	elseif self.type == coopHUD.RunInfo.POOP then
		if self:checkPlayer() then
			return nil
		end
	elseif self.type == coopHUD.RunInfo.GREED_WAVES or self.type == coopHUD.RunInfo.GREEDIER then
		-- returns nil if not in greed mode to not render
		if not Game():IsGreedMode() then return nil end
		if Game().Difficulty == Difficulty.DIFFICULTY_GREEDIER then
			self.type = coopHUD.RunInfo.GREEDIER
		end
	end
	local sprite = Sprite()
	sprite:Load(coopHUD.GLOBALS.hud_el_anim_path, true)
	sprite:SetFrame('Idle', self.type)
	sprite:LoadGraphics()
	return sprite
end
function coopHUD.RunInfo:render(pos, mirrored, scale, down_anchor)
	self:update()
	-- Scale set
	local sprite_scale = scale
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end
	--
	local temp_pos = Vector(pos.X, pos.Y - 1)
	local text_pos = Vector(pos.X + 16, pos.Y)
	local offset = Vector(0, 0)
	if self.sprite then
		--
		if mirrored then
		end
		--
		if down_anchor then
		end
		--
		if self.type == coopHUD.RunInfo.COIN and self:checkDeepPockets() then
			temp_pos.X = temp_pos.X - 2
			text_pos.X = text_pos.X - 2
		end
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
		coopHUD.HUD.fonts.pft:DrawString(self:getText(), text_pos.X, text_pos.Y,
		                                 KColor(1, 1, 1, 1), 0, false)
		offset.Y = coopHUD.HUD.fonts.pft:GetBaselineHeight()
		offset.X = 16 + coopHUD.HUD.fonts.pft:GetStringWidth(self:getText())
	end
	return offset
end
function coopHUD.RunInfo:update()
	if self.type ~= self:getType() then
		self.type = self:getType()
		self.sprite = self:getSprite()
	end
	if self.sprite == nil then
		self.sprite = self:getSprite()
	end
	if self.amount ~= self:getAmount() then
		self.amount = self:getAmount()
	end
end
function coopHUD.RunInfo:checkDeepPockets()
	for i = 0, Game():GetNumPlayers() - 1, 1 do
		if Isaac.GetPlayer(i):HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
			return true
		end
	end
	return false
end
function coopHUD.RunInfo:checkPlayer()
	for i = 0, Game():GetNumPlayers() - 1, 1 do
		if self.type == coopHUD.RunInfo.BOMB then
			if Isaac.GetPlayer(i):GetPlayerType() ~= PlayerType.PLAYER_BLUEBABY_B then
				return false
			end
		end
		if self.type == coopHUD.RunInfo.BETH then
			if Isaac.GetPlayer(i):GetPlayerType() == PlayerType.PLAYER_BETHANY then
				return false
			end
		end
		if self.type == coopHUD.RunInfo.T_BETH then
			if Isaac.GetPlayer(i):GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
				return false
			end
		end
		if self.type == coopHUD.RunInfo.POOP then
			if Isaac.GetPlayer(i):GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B then
				return false
			end
		end
	end
	return true
end
function coopHUD.RunInfo:getText()
	local format_string = "%.2i"
	if self.type == coopHUD.RunInfo.COIN and self:checkDeepPockets() then
		format_string = "%.3i"
	end
	local text = string.format(format_string, self.amount)
	if self.type == coopHUD.RunInfo.GREED_WAVES or self.type == coopHUD.RunInfo.GREEDIER then
		local current_wave = Game():GetLevel().GreedModeWave
		local max_waves = 10
		if self.type == coopHUD.RunInfo.GREEDIER then
			max_waves = 11
		end
		text = string.format("%d/%2.d", current_wave, max_waves)
	end
	return text
end
function coopHUD.RunInfo:getOffset()
	local offset = Vector(0, 0)
	if self.sprite then
		offset.X = 16 + coopHUD.HUD.fonts.pft:GetStringWidth(self:getText())
		offset.Y = math.max(coopHUD.HUD.fonts.pft:GetBaselineHeight(), 16)
	end
	return offset
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
coopHUD.Stat.SPEED = 0
coopHUD.Stat.TEARS_DELAY = 1
coopHUD.Stat.DAMAGE = 2
coopHUD.Stat.RANGE = 3
coopHUD.Stat.SHOT_SPEED = 4
coopHUD.Stat.LUCK = 5
coopHUD.Stat.DEVIL = 6
coopHUD.Stat.ANGEL = 7
coopHUD.Stat.PLANETARIUM = 8
coopHUD.Stat.DUALITY = 10
---@param parent table coopHUD.Player -- parent of stat class
---@param type number coopHUD.Stat.Type -- type of stat class
---@param icon boolean if true Stat will be rendered with icon else only number stat with diff if is
function coopHUD.Stat.new(parent, type, icon)
	local self = setmetatable({}, coopHUD.Stat)
	self.parent = parent
	self.type = type
	self.icon = icon
	self.amount = self:getAmount()
	self.diff = nil
	self.sprite = self:getSprite()
	self.diff_counter = 0
	return self
end
function coopHUD.Stat:getAmount()
	if self.type <= coopHUD.Stat.LUCK then
		if self.type == coopHUD.Stat.SPEED then
			return self.parent.entPlayer.MoveSpeed
		elseif self.type == coopHUD.Stat.TEARS_DELAY then
			return 30 / (self.parent.entPlayer.MaxFireDelay + 1)
		elseif self.type == coopHUD.Stat.DAMAGE then
			return self.parent.entPlayer.Damage
		elseif self.type == coopHUD.Stat.RANGE then
			return self.parent.entPlayer.TearRange / 40
		elseif self.type == coopHUD.Stat.SHOT_SPEED then
			return self.parent.entPlayer.ShotSpeed
		elseif self.type == coopHUD.Stat.LUCK then
			return self.parent.entPlayer.Luck
		end
	else
		local deals = self.calculateDeal()
		if self.type == coopHUD.Stat.ANGEL or self.type == coopHUD.Stat.DUALITY then
			if deals.duality then
				self.type = coopHUD.Stat.DUALITY
			else
				self.type = coopHUD.Stat.ANGEL
			end
			if self.type == coopHUD.Stat.ANGEL then
				return deals.angel
			elseif self.type == coopHUD.Stat.DUALITY then
				return deals.angel + deals.devil
			end
		elseif self.type == coopHUD.Stat.DEVIL then
			if deals.duality then
				return nil
			else
				return deals.devil
			end
			if self.type == coopHUD.Stat.DEVIL then

			end
		elseif self.type == coopHUD.Stat.PLANETARIUM then
			return Game():GetLevel():GetPlanetariumChance() * 100
		end
	end
end
function coopHUD.Stat:getSprite()
	if self.icon and self.type ~= nil then
		local sprite = Sprite()
		sprite:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
		sprite:SetFrame('Idle', self.type)
		return sprite
	else
		return nil
	end
end
function coopHUD.Stat:render(pos, mirrored, vertical)
	self:update()
	local init_pos = (Vector(pos.X, pos.Y))
	if vertical then
		init_pos.Y = init_pos.Y - 16
	end
	local offset = Vector(0, 0)
	local color_alpha = 1
	if self.type <= coopHUD.Stat.LUCK then
		color_alpha = 0.5
		if self.parent.signals.map_btn then
			color_alpha = 1
		end
	end
	if self.icon and self.sprite then
		-- Icon render
		if mirrored then
			init_pos.X = init_pos.X - 16
		else
			offset.X = offset.X + 16
		end
		offset.Y = offset.Y + 16
		self.sprite.Color = Color(1, 1, 1, color_alpha)
		self.sprite:Render(Vector(init_pos.X, init_pos.Y))
	end
	-- STAT.amount render
	if self.amount then
		local amount_string = string.format("%.2f", self.amount)
		if self.type > coopHUD.Stat.LUCK then
			amount_string = string.format("%.1f", self.amount)
		end
		-- Amount render
		local align = 0
		if mirrored then
			align = 1
		end
		local f_color = KColor(self.parent.font_color.Red, self.parent.font_color.Green, self.parent.font_color.Blue,
		                       color_alpha)
		coopHUD.HUD.fonts.lua_mini:DrawString(amount_string,
		                                      init_pos.X + offset.X, init_pos.Y,
		                                      f_color,
		                                      align, false)
		-- increases horizontal offset of string width
		if mirrored then
			offset.X = offset.X - coopHUD.HUD.fonts.lua_mini:GetStringWidth(amount_string)
		else
			offset.X = offset.X + coopHUD.HUD.fonts.lua_mini:GetStringWidth(amount_string)
		end
		-- increases vertical offset of max of string base height and last icon offset
		offset.Y = math.max(offset.Y, coopHUD.HUD.fonts.lua_mini:GetBaselineHeight())
		-- STAT.Diff - render
		if self.diff then
			local dif_color = KColor(0, 1, 0, 0.7) -- green
			local dif_string = string.format("%.1f", self.diff)
			-- Difference Render
			local attitude = self:getAttitude() -- holds true if difference is positive and false if negative
			if attitude then
				dif_color = KColor(0, 1, 0, 1) -- green
				dif_string = '+' .. dif_string
			else
				dif_color = KColor(1, 0, 0, 1)
			end
			local diff_off = Vector(0, 0)
			local diff_pos = Vector(init_pos.X, init_pos.Y)
			local align = 0
			if vertical then
				if self.sprite then
					diff_pos.X = diff_pos.X + 12
				end
				diff_pos.Y = diff_pos.Y - coopHUD.HUD.fonts.lua_mini:GetBaselineHeight()
				offset.Y = offset.Y + coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() / 2
			else
				diff_pos.X = diff_pos.X + offset.X
				offset.X = offset.X + coopHUD.HUD.fonts.lua_mini:GetStringWidth(dif_string)
			end
			if mirrored then
				align = 1
			end
			coopHUD.HUD.fonts.lua_mini:DrawString(dif_string,
			                                      diff_pos.X,
			                                      diff_pos.Y,
			                                      dif_color,
			                                      align, false)
			self.diff_counter = self.diff_counter + 1
			if self.diff_counter > 200 then
				self.diff_counter = 0
				self.diff = nil
			end
		end
	end
	return offset
end
function coopHUD.Stat:update()
	local temp_amount = self:getAmount()
	if self.amount ~= temp_amount then
		if temp_amount and self.amount then
			self.diff = temp_amount - self.amount
		end
		self.amount = temp_amount
		if self.amount == nil then
			self.sprite = nil
		else
			self.sprite = self:getSprite()
		end
	end
	if self.type == coopHUD.Stat.ANGEL then

	end
end
function coopHUD.Stat.calculateDeal()
	local lvl = Game():GetLevel()
	local room = lvl:GetCurrentRoom()
	local deal = 0.0
	local angel = 0.0
	local devil = 0.0
	local banned_stages = {[1] = true, [9] = true, [10] = true, [11] = true, [12] = true, [12] = true}
	-- door chance
	if banned_stages[Game():GetLevel():GetStage()] == nil and
			Game():GetLevel():GetCurseName() ~= "Curse of the Labyrinth!" or Game().Difficulty > 1 then
		deal = room:GetDevilRoomChance()
		if deal > 1 then
			deal = 1.0
		end
	end
	-- angel components
	local comp = {
		rosary_bead = {false, 0.5},
		key_piece_1 = {false, 0.75},
		key_piece_2 = {false, 0.75},
		virtouses = {false, 0.75},
		bum_killed = {false, 0.75},
		bum_left = {false, 0.9},
		dead_bum_left = {false, 1.1},
		donation = {false, 0.5},
	}
	-- check collectibles
	local duality = false
	local eucharist = false
	local act_of_contr = false
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) then
			comp.key_piece_1[1] = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
			comp.key_piece_2[1] = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			comp.virtouses[1] = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DUALITY) then
			duality = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_EUCHARIST) then
			eucharist = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) then
			act_of_contr = true
		end
		if player:HasTrinket(TrinketType.TRINKET_ROSARY_BEAD) then
			comp.rosary_bead[1] = true
		end
	end
	-- check state flags - bum kills/donations
	if lvl:GetStateFlag(1) then
		-- check if devil bum killed
		comp.bum_killed[1] = true
	end
	if lvl:GetStateFlag(3) then
		-- check if  bum donated until left
		comp.bum_left[1] = true
	end
	if lvl:GetStateFlag(4) then
		-- check if  bum donated until left
		comp.dead_bum_left[1] = true
	end
	if Game():GetDonationModAngel() >= 10 then
		-- check if donated more than 10 coins on level
		comp.donation[1] = true
	end
	-- Check after boss battle angel door spawned
	if room:GetType(RoomType.ROOM_BOSS) and room:IsClear() then
		for i = 0, 7, 1 do
			local door = room:GetDoor(i)
			if door ~= nil then
				if door.TargetRoomType == 15 then
					coopHUD.angel_seen = true
					coopHUD.save_options()
				end
			end
		end
	end
	-- Calculate ange deals
	if Game():GetStateFlag(5) or comp.virtouses[1] or eucharist and -- check if player seen devil deal or
			--lvl:GetAngelRoomChance() ~= 0) and --have I feel blessed
			(Game():GetDevilRoomDeals() == 0 or -- check if player has done devil deal
					act_of_contr or comp.virtouses[1] or lvl:GetAngelRoomChance() ~= 0) then
		-- if have virtouses or act_of_contr ignore devil deals deals
		if eucharist then
			-- if have eucharist
			angel = 1
		elseif Game():GetStateFlag(6) or coopHUD.angel_seen then
			-- if not enter devil deal and seen angel
			angel = 1 - 0.5
			for n, k in pairs(comp) do
				-- calculate components of angel deal from table of components
				if k[1] then
					angel = angel * k[2]
				end
			end
			angel = angel * (1.0 - lvl:GetAngelRoomChance()) -- checks you feel blessed component
			angel = 1 - angel
		else
			-- seen devil but not angel and not entered devil
			angel = 1
		end
	end
	devil = deal * (1.0 - angel)
	angel = deal * angel
	return {devil = devil * 100,
	        angel = angel * 100,
		--planetarium = { lvl:GetPlanetariumChance() * 100, 0 },
		    duality = duality}
end
function coopHUD.Stat:getOffset(vertical)
	local offset = Vector(0, 0)
	if self.sprite then
		offset.X = offset.X + 16
		offset.Y = offset.Y + 16
	end
	if self.amount then
		local amount_string = string.format("%.2f", self.amount)
		offset.X = offset.X + coopHUD.HUD.fonts.lua_mini:GetStringWidth(amount_string)
		offset.Y = math.max(offset.Y, coopHUD.HUD.fonts.lua_mini:GetBaselineHeight())
		if self.diff then
			local dif_string = string.format("%.1f", self.diff)
			if self:getAttitude() then
				dif_string = '+' .. dif_string
			end
			if vertical then
				offset.Y = offset.Y + coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() / 2
			else
				--offset.X = offset.X + coopHUD.HUD.fonts.lua_mini:GetStringWidth(dif_string)
			end
		end
	end
	return offset
end
---coopHUD.Stat:getAttitude -- checks stat 'attitude' if its in growth or in shrink :D
---@return boolean true if self.diff is positive and false if engative
function coopHUD.Stat:getAttitude()
	if self.diff > 0 then
		--
		return true
	elseif self.diff == 0 then
		return true
	else
	end
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
	if self.parent.entPlayer.Variant == 1 then
		return nil
	end -- prevents when old coop ghost
	if player_type == 40 then
		player_type = 36
	end
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
			--FIXME: wrong offset return
			temp_pos.Y = temp_pos.Y - (coopHUD.HUD.fonts.lua_mini:GetBaselineHeight())
			text_pos.Y = text_pos.Y - (coopHUD.HUD.fonts.lua_mini:GetBaselineHeight())
			offset.Y = (-16 * sprite_scale.Y) - coopHUD.HUD.fonts.lua_mini:GetBaselineHeight()
		else
			temp_pos.Y = temp_pos.Y + (coopHUD.HUD.fonts.lua_mini:GetBaselineHeight())
			text_pos.Y = text_pos.Y + (16 * sprite_scale.Y)
			offset.Y = (16 * sprite_scale.Y) + coopHUD.HUD.fonts.lua_mini:GetBaselineHeight()
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
setmetatable(coopHUD.Collectibles, {
	__call = function(cls, ...)
		return cls.trigger(...)
	end,
})
coopHUD.Collectibles.sprite = Sprite()
coopHUD.Collectibles.sprite:Load(coopHUD.GLOBALS.pause_screen_anim_path, true)
coopHUD.Collectibles.sprite:SetFrame('Dissapear', 13) -- sets to last frame to not trigger on run
coopHUD.Collectibles.item_table = {}
coopHUD.Collectibles.mirrored = false -- if mirrored stuff page anchors near right side else on left
coopHUD.Collectibles.signal = false
function coopHUD.Collectibles.render()
	local sprite_pos = Vector(Isaac.GetScreenWidth() / 2 + 60, Isaac.GetScreenHeight() / 2 - 30)
	print()
	if coopHUD.Collectibles.mirrored then
		sprite_pos.X = Isaac.GetScreenWidth() + 30
	end
	if coopHUD.Collectibles.sprite:GetFrame() > 11 and coopHUD.Collectibles.signal then
		if coopHUD.Collectibles.signal + 15 < Game():GetFrameCount() then
			coopHUD.Collectibles.signal = false -- resets signals and lets continue to render sprite
			coopHUD.Collectibles.sprite:Play('Dissapear', 0)
		end
	else
		coopHUD.Collectibles.sprite:Update() -- update sprite frame
	end
	if coopHUD.Collectibles.sprite:IsPlaying('Dissapear') then
		coopHUD.Collectibles.sprite:Update()
	end
	coopHUD.Collectibles.sprite:Update() -- update sprite frame
	coopHUD.Collectibles.sprite:RenderLayer(3, sprite_pos)
	-- collectibles table render
	local item_pos = Vector(0 + 76, Isaac.GetScreenHeight() / 2 - 32)
	if coopHUD.Collectibles.mirrored then
		item_pos.X = Isaac.GetScreenWidth() - 194
	end
	local temp_counter = 1
	local collectibles_stop = 1
	if #coopHUD.Collectibles.item_table > 136 then
		collectibles_stop = #coopHUD.Collectibles.item_table - 135
	end
	for i = #coopHUD.Collectibles.item_table, collectibles_stop, -1 do
		local scale = Vector(1, 1)
		local rows_no = 5
		if #coopHUD.Collectibles.item_table > 10 then
			scale = Vector(0.7, 0.7)
			rows_no = 7
		end
		if #coopHUD.Collectibles.item_table > 20 then
			scale = Vector(0.6, 0.6)
			rows_no = 8
		end
		if #coopHUD.Collectibles.item_table > 32 then
			scale = Vector(0.5, 0.5)
			rows_no = 10
		end
		if #coopHUD.Collectibles.item_table > 42 then
			scale = Vector(0.5, 0.5)
			rows_no = 10
		end
		if #coopHUD.Collectibles.item_table > 50 then
			scale = Vector(0.4, 0.4)
			rows_no = 13
		end
		if #coopHUD.Collectibles.item_table > 78 then
			scale = Vector(0.3, 0.3)
			rows_no = 17
		end
		local off = coopHUD.Collectibles.item_table[i]:render(item_pos, false, scale, false)
		item_pos.X = item_pos.X + off.X / 1.5
		if temp_counter % rows_no == 0 then
			item_pos.Y = item_pos.Y + off.Y
			item_pos.X = 0 + 72
			if coopHUD.Collectibles.mirrored then
				item_pos.X = Isaac.GetScreenWidth() - 194
			end
		end
		temp_counter = temp_counter + 1
	end
	if coopHUD.Collectibles.sprite:IsPlaying('Dissapear') then coopHUD.Collectibles.item_table = {} end
	--
end
function coopHUD.Collectibles.trigger(Player)
	coopHUD.Collectibles.signal = Game():GetFrameCount() -- sets streak signal as current frame num
	if coopHUD.Collectibles.sprite:IsFinished('Dissapear')  then
		-- if Collectibles is finished play animation
		coopHUD.Collectibles.color = Player.font_color
		coopHUD.Collectibles.mirrored = coopHUD.players_config.small[Player.game_index].mirrored
		coopHUD.Collectibles.item_table = Player.collectibles
		coopHUD.Collectibles.sprite:Play("Appear", true)
	end
end
--
coopHUD.Streak = {}
-- STREAK TYPES
coopHUD.Streak.FLOOR = 0
coopHUD.Streak.PICKUP = 1
setmetatable(coopHUD.Streak, {
	__call = function(cls, ...)
		return cls.trigger(...)
	end,
})
function coopHUD.Streak.getSprite()
	local sprite = Sprite()
	sprite:Load(coopHUD.GLOBALS.streak_anim_path, true)
	sprite:SetFrame('Text', 0)
	return sprite
end
coopHUD.Streak.sprite = coopHUD.Streak.getSprite() -- inits streak sprite
coopHUD.Streak.signal = false -- trigger signal
function coopHUD.Streak.render()
	--TODO: when type ITEM and colorful hud option draw colored strings with player color
	if coopHUD.Streak.sprite and coopHUD.Streak.first_line and coopHUD.Streak.first_line ~= '' and not coopHUD.Streak.sprite:IsFinished() then
		-- prevents from no sprite loaded error and rendering when no passed first line or empty
		local cur_frame = coopHUD.Streak.sprite:GetFrame()
		if cur_frame > 16 and coopHUD.Streak.signal then
			-- controls enter animation and that sprite stays on screen
			local streak_span = 30 -- controls how long streak will be rendered after signal = nil
			if coopHUD.Streak.signal + streak_span < Game():GetFrameCount() then
				coopHUD.Streak.signal = false -- resets signals and lets continue to render sprite
			end
		else
			coopHUD.Streak.sprite:Update() -- update sprite frame
		end
		local temp_pos = Vector(Isaac.GetScreenWidth() / 2, 48) -- defines  with vertical anchor up
		if coopHUD.Streak.down_anchor then
			-- if triggered with true down_anchor
			temp_pos.Y = Isaac.GetScreenHeight() - 48 -- changes vertical anchor down
		end
		if coopHUD.Streak.first_line then
			coopHUD.Streak.sprite:RenderLayer(0, temp_pos)
		end
		if cur_frame > 4 and cur_frame < 65 then
			-- prevents from showing text when sprite on in/out state
			if coopHUD.Streak.first_line then
				coopHUD.HUD.fonts.upheaval:DrawString(coopHUD.Streak.first_line,
				                                      temp_pos.X,
				                                      temp_pos.Y - coopHUD.HUD.fonts.upheaval:GetBaselineHeight() * 0.75,
				                                      KColor(1, 1, 1, 1), 1, true)
			end
			if coopHUD.Streak.second_line and coopHUD.Streak.second_line ~= '' then
				local line_off = Vector(0, 12)
				local f_color = KColor(1, 1, 1, 1)
				local font = coopHUD.HUD.fonts.pft
				if coopHUD.Streak.type == coopHUD.Streak.FLOOR then
					coopHUD.Streak.sprite:RenderLayer(1, temp_pos)
					line_off.Y = 19
					f_color = KColor(0, 0, 0, 1)
					font = coopHUD.HUD.fonts.team_meat_10
				end
				font:DrawString(coopHUD.Streak.second_line,
				                temp_pos.X, temp_pos.Y + line_off.Y,
				                f_color, 1, true)
			end
		end
	end
end
function coopHUD.Streak.trigger(down_anchor, type, first_line, second_line, force_reset)
	coopHUD.Streak.signal = Game():GetFrameCount() -- sets streak signal as current frame num
	if coopHUD.Streak.sprite:IsFinished() or force_reset then
		-- if streak is finished play animation
		coopHUD.Streak.sprite:Play("Text", true)
		coopHUD.Streak.type = type
		coopHUD.Streak.down_anchor = down_anchor -- defines if streak will render down screen or top screen
		coopHUD.Streak.first_line = first_line -- gets line string from passed parameters
		coopHUD.Streak.second_line = second_line
		if type == coopHUD.Streak.FLOOR then
			-- in case of floor streak ignore passed strings
			coopHUD.Streak.first_line = Game():GetLevel():GetName() -- and get floor specs
			coopHUD.Streak.second_line = Game():GetLevel():GetCurseName()
		end
	end
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
		if MinimapAPI:GetConfig("Disable") or MinimapAPI.Disable then
			minimap_offset = Vector(screen_size.X - 4,
			                        2) end
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
	if coopHUD.anchors.top_right ~= Vector(coopHUD.getMinimapOffset().X, 0) + Vector(-offset * 2.2,
	                                                                                 offset * 1.2) then
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