local vanilla_anim = "gfx/ui/ui_hearts.anm2"
local coopHUD_anim = "gfx/ui/ui_hearts_coop.anm2"
---@class coopHUD.Heart
---@param parent coopHUD.Player
---@param heart_pos number heart position [0...n]
---@field sprite Sprite holds heart sprite
---@field type string heart type
---@field overlay string heart overlay (eternal or gold)
---@return coopHUD.Heart
---@type coopHUD.Heart | fun(parent:coopHUD.Player,heart_pos:number):coopHUD.Heart
coopHUD.Heart = {}
coopHUD.Heart.__index = coopHUD.Heart
setmetatable(coopHUD.Heart, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@see coopHUD.Heart
---@private
function coopHUD.Heart.new(parent, heart_pos)
	---@type coopHUD.Heart
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
	if Game():GetLevel():GetCurses() == 8 then
		-- checks curse of the unknown
		if self.pos == 0 and not player:IsSubPlayer() then
			heart_type = 'CurseHeart'
			return heart_type, overlay
		end
	elseif player_type == 10 or player_type == 31 then
		return nil, nil
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
		sprite:Load(vanilla_anim, true)
		sprite:SetFrame(self.type, 0)
		if self.pos >= 2 and self.parent.entPlayer:GetPlayerType() == PlayerType.PLAYER_MAGDALENE_B then
			-- birthright extends non blinking hearts to 3
			if self.parent.entPlayer:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and self.pos == 2 then

			else
				sprite:Load(coopHUD_anim, true)
				sprite:Play(self.type, true)
			end
		end
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
		self.parent.force_update = true
	end
	if self.overlay ~= overlay then
		self.overlay = overlay
		self.parent.force_update = true
	end
end
function coopHUD.Heart:update_sprite()
	self.sprite = self:getSprite()
end
--- Renders heart sprite in current position
---@param pos Vector position where render sprite
---@param scale Vector scale of sprite
---@param dim boolean defines if dim sprite
---@return Vector offset where render next sprite
function coopHUD.Heart:render(pos, scale, dim)
	local offset = Vector(0, 0)
	local sprite_scale = scale
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end
	local temp_pos = Vector(pos.X + (8 * sprite_scale.X), pos.Y + (8 * sprite_scale.Y))
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
		if self.sprite:IsPlaying(self.type) then self.sprite:Update() end
		self.sprite:Render(temp_pos)
		offset.X = 12 * math.ceil((self.pos + 1) % 6) * sprite_scale.X
		offset.Y = 10 * math.floor((self.pos + 1) / 6) * sprite_scale.Y
	end
	return offset
end
coopHUD.Mantle = Sprite()
coopHUD.Mantle:Load(vanilla_anim)
coopHUD.Mantle:SetFrame('HolyMantle', 0)
---@class coopHUD.HeartTable
---@param entPlayer userdata EntityPlayer
---@field hearts coopHUD.Heart[]
---@field total_hearts number holds total no of hearts containers
---@field force_update boolean when true triggers full heart table sprite update to avoid animation desync
coopHUD.HeartTable = {}
coopHUD.HeartTable.__index = coopHUD.HeartTable
setmetatable(coopHUD.HeartTable, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@see coopHUD.HeartTable
---@private
function coopHUD.HeartTable.new(entPlayer)
	local self = setmetatable({}, coopHUD.HeartTable)
	self.entPlayer = entPlayer
	self.total_hearts = math.ceil((self.entPlayer:GetEffectiveMaxHearts() + self.entPlayer:GetSoulHearts()) / 2)
	self.hearts = {}
	self.force_update = false -- if true reloads all table
	for i = 0, self.total_hearts do
		self.hearts[i] = coopHUD.Heart(self, i)
	end
	return self
end
--- Renders heart table in current position
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@param dim boolean defines if dim sprite
---@return Vector offset where render next sprite
function coopHUD.HeartTable:render(pos, mirrored, scale, down_anchor, dim)
	local temp_off = Vector(0, 0)
	if self.entPlayer and self.entPlayer:IsCoopGhost() then return temp_off end -- if player is coop ghost skips render
	local init_pos = Vector(pos.X, pos.Y)
	--
	local hearts_span
	if self.total_hearts >= 6 then
		-- Determines how many columns will be
		hearts_span = 6
	else
		hearts_span = self.total_hearts % 6
	end
	local rows = math.ceil(self.total_hearts / 6)
	local cols = 6
	if self.total_hearts < 6 then
		cols = math.ceil(self.total_hearts % 6)
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
		init_pos.Y = pos.Y + (-16 * scale.Y) * math.ceil(self.total_hearts / 6)
		rows = rows * -1.5
	end
	-- RENDER
	for i = 0, self.total_hearts do
		if self.hearts[i] then
			local temp_pos = Vector(init_pos.X + temp_off.X, init_pos.Y + temp_off.Y)
			temp_off = self.hearts[i]:render(temp_pos, scale, dim)
		end
	end
	--
	return Vector(12 * scale.X * cols, 12 * scale.Y * rows)
end
---updates heart table
function coopHUD.HeartTable:update()
	local temp_total_hearts = math.ceil((self.entPlayer:GetEffectiveMaxHearts() + self.entPlayer:GetSoulHearts()) / 2)
	if self.total_hearts ~= temp_total_hearts then
		-- update on increasing/decreasing
		self.total_hearts = temp_total_hearts
		for i = 0, self.total_hearts do
			self.hearts[i] = coopHUD.Heart(self, i)
		end
	end
	if self.force_update then
		-- full table sprite update to avoid desync of playing animations
		for i = 0, #self.hearts do
			self.hearts[i]:update_sprite(self, i)
		end
		self.force_update = false -- trigger reset
	end
	for i = 0, self.total_hearts - 1 do
		-- normal call for update for heart, if update needed  child triggers force_update
		self.hearts[i]:update()
	end
end