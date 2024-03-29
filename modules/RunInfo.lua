---@class coopHUD.RunInfo
---@field private type number
---@field private amount number
---@field private sprite Sprite
---@field COIN number
---@field KEY number
---@field BOMB number
---@field GOLDEN_KEY number
---@field HARD number
---@field NO_ACHIEVEMENTS number
---@field GOLDEN_BOMB number
---@field GREED_WAVES number
---@field D_RUN number
---@field SLOT number
---@field V_LAP number
---@field GREEDIER number
---@field BETH number
---@field GIGA_BOMB number
---@field T_BETH number
---@field POOP number
---@type coopHUD.RunInfo | fun(type):coopHUD.RunInfo
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
coopHUD.RunInfo.HARD = 4
coopHUD.RunInfo.NO_ACHIEVEMENTS = 5
coopHUD.RunInfo.GOLDEN_BOMB = 6
coopHUD.RunInfo.GREED_WAVES = 7
coopHUD.RunInfo.D_RUN = 8
coopHUD.RunInfo.SLOT = 9
coopHUD.RunInfo.V_LAP = 10
coopHUD.RunInfo.GREEDIER = 11
coopHUD.RunInfo.BETH = 12
coopHUD.RunInfo.GIGA_BOMB = 14
coopHUD.RunInfo.T_BETH = 15
coopHUD.RunInfo.POOP = 16
coopHUD.RunInfo.anim_path = "gfx/ui/hudpickups.anm2"
---@param info_type
function coopHUD.RunInfo.new(info_type)
	---@type coopHUD.RunInfo
	local self = setmetatable({}, coopHUD.RunInfo)
	self.type = info_type
	self.type = self:getType()
	self.amount = self:getAmount()
	self.text = self:getText()
	self.sprite = self:getSprite()
	return self
end
---@param self coopHUD.RunInfo
function coopHUD.RunInfo.getAmount(self)
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
		if self.type == coopHUD.RunInfo.SLOT then
			--FIXME: Greed donation jam indicator: proper jam chances: https://coophud.atlassian.net/browse/COOP-105
			return player:GetGreedDonationBreakChance()
		end
		if self.type == coopHUD.RunInfo.V_LAP then
			return Game():GetVictoryLap()
		end
	end
	if self.type == coopHUD.RunInfo.HARD
			or self.type == coopHUD.RunInfo.NO_ACHIEVEMENTS
			or self.type == coopHUD.RunInfo.D_RUN then
		return nil
	end
	return 0
end
---@param self coopHUD.RunInfo
function coopHUD.RunInfo.getType(self)
	local type = self.type
	local player = Isaac.GetPlayer(0)
	if player then
		if type == coopHUD.RunInfo.KEY then
			if player:HasGoldenKey() then
				type = coopHUD.RunInfo.GOLDEN_KEY
			end
		elseif type == coopHUD.RunInfo.BOMB then
			if player:HasGoldenBomb() then
				type = coopHUD.RunInfo.GOLDEN_BOMB
			end
			if player:GetNumGigaBombs() > 0 then
				type = coopHUD.RunInfo.GIGA_BOMB
			end
		end
	end
	return type
end
---@param self coopHUD.RunInfo
function coopHUD.RunInfo.getSprite(self)
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
		if not Game():IsGreedMode() then
			return nil
		end
		if Game().Difficulty == Difficulty.DIFFICULTY_GREEDIER then
			self.type = coopHUD.RunInfo.GREEDIER
		end
	end
	local sprite = Sprite()
	sprite:Load(coopHUD.RunInfo.anim_path, true)
	sprite:SetFrame('Idle', self.type)
	sprite:LoadGraphics()
	return sprite
end
--- Renders poops spells  modules in current position
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@return Vector offset where render next sprite
function coopHUD.RunInfo:render(pos, mirrored, scale, down_anchor)
	self:update()
	-- Scale set
	local sprite_scale = scale
	if sprite_scale == nil then
		sprite_scale = Vector(1, 1)
	end
	--
	local temp_pos = Vector(pos.X, pos.Y - 1)
	local text_pos = Vector(pos.X + 16 * sprite_scale.X, pos.Y - 1 * sprite_scale.Y)
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
			temp_pos.X = temp_pos.X - 2 * sprite_scale.X
			text_pos.X = text_pos.X - 2 * sprite_scale.X
		end
		self.sprite.Scale = sprite_scale
		self.sprite:Render(temp_pos)
		if self.text then
			coopHUD.HUD.fonts.pft:DrawStringScaled(tostring(self.text),
			                                       text_pos.X, text_pos.Y,
			                                       sprite_scale.X, sprite_scale.Y,
			                                       KColor(1, 1, 1, 1), 0, false)
			offset.Y = coopHUD.HUD.fonts.pft:GetBaselineHeight() * sprite_scale.Y
			offset.X = (16 + coopHUD.HUD.fonts.pft:GetStringWidth(self.text)) * sprite_scale.X
		end
	end
	return offset
end
---@param self coopHUD.RunInfo
function coopHUD.RunInfo.update(self)
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
	if self.text ~= self:getText() then
		self.text = self:getText()
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
---@param self coopHUD.RunInfo
function coopHUD.RunInfo.checkPlayer(self)
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
---@param self coopHUD.RunInfo
function coopHUD.RunInfo.getText(self)
	if self.amount == nil then
		return nil
	end
	local format_string = "%.2i"
	if self.type == coopHUD.RunInfo.COIN and self:checkDeepPockets() then
		format_string = "%.3i"
	end
	if self.type == coopHUD.RunInfo.V_LAP then
		format_string = "%.1i"
	end
	local text = string.format(format_string, self.amount)
	if self.type == coopHUD.RunInfo.SLOT then
		text = text .. '%'
	end
	if self.type == coopHUD.RunInfo.GREED_WAVES or self.type == coopHUD.RunInfo.GREEDIER then
		if Game():GetLevel():GetAbsoluteStage() == 0 then
			return nil
		end
		local current_wave = Game():GetLevel().GreedModeWave
		local max_waves = 10
		if self.type == coopHUD.RunInfo.GREEDIER then
			max_waves = 11
		end
		text = string.format(" %d/%2.d", current_wave, max_waves)
	end
	return text
end
---@param self coopHUD.RunInfo
function coopHUD.RunInfo.getOffset(self)
	local offset = Vector(0, 0)
	local scale = Vector(coopHUD.options.hud_scale, coopHUD.options.hud_scale)
	if self.sprite then
		offset.X = 16 * scale.X
		offset.Y = 16 * scale.Y
		if self.text then
			offset.X = offset.X + coopHUD.HUD.fonts.pft:GetStringWidth(self.text) * scale.X
			if offset.Y < coopHUD.HUD.fonts.pft:GetBaselineHeight() * scale.Y then
				offset.Y = coopHUD.HUD.fonts.pft:GetBaselineHeight() * scale.Y
			end
		end
	end
	return offset
end