---@class coopHUD.Stat
---@field SPEED
---@param parent coopHUD.Player parent of stat class
---@param type number coopHUD.Stat.Type -- type of stat class
---@param icon boolean if true Stat will be rendered with icon else only number stat with diff if is
---@type coopHUD.Stat | fun(parent:coopHUD.Player,type:number,icon:boolean):coopHUD.Stat
---@return coopHUD.Stat
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
coopHUD.Stat.anim_path = "gfx/ui/hudstats2.anm2"
---@see coopHUD.Stat
---@private
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
		sprite:Load(coopHUD.Stat.anim_path, true)
		sprite:SetFrame('Idle', self.type)
		return sprite
	else
		return nil
	end
end
--- Renders stas sprite in current position
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@param dim boolean defines if dim sprite
---@return Vector offset where render next sprite
function coopHUD.Stat:render(pos, mirrored, vertical, only_num)
	self:update()
	local init_pos = (Vector(pos.X, pos.Y))
	if vertical then
		init_pos.Y = init_pos.Y - 16
	end
	local offset = Vector(0, 0)
	local color_alpha = 1
	if self.type <= coopHUD.Stat.LUCK then
		if self.parent.signals.map_btn then
			color_alpha = 1
		else
			color_alpha = 0.5
		end
	end
	if self.icon and self.sprite and not only_num then
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
			amount_string = string.format("%.1f", self.amount) .. "%"
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
			local dif_string = string.format("%.2f", self.diff)
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
			if vertical then -- in case of verticals stats - used in deals in coopHUD position setting
				if self.sprite then
					diff_pos.X = diff_pos.X + 12 -- increments if pos if has sprite
				end
				diff_pos.Y = diff_pos.Y - coopHUD.HUD.fonts.lua_mini:GetBaselineHeight()
				offset.Y = offset.Y + coopHUD.HUD.fonts.lua_mini:GetBaselineHeight() / 2
			else
				diff_pos.X = diff_pos.X + offset.X -- adds normal stat string and icon offset to base pos
				offset.X = offset.X + coopHUD.HUD.fonts.lua_mini:GetStringWidth(dif_string) -- adds proper
			end
			if mirrored then
				diff_pos.X = diff_pos.X - 2 -- makes margin between text
				align = 1
			else
				diff_pos.X = diff_pos.X + 2 -- makes margin between text
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
			if self.diff then
				self.diff = self.diff + (temp_amount - self.amount)
			else
				self.diff = temp_amount - self.amount
			end
			self.diff_counter = 0
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
--- calculate current devil/angel room chances
---@return {devil:number,angel:number,duality:boolean}
function coopHUD.Stat.calculateDeal()
	local lvl = Game():GetLevel()
	local room = lvl:GetCurrentRoom()
	local deal = 0.0
	local angel = 0.0
	local devil = 0.0
	local banned_stages = { [1] = true, [9] = true, [10] = true, [11] = true, [12] = true, [12] = true }
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
		rosary_bead   = { false, 0.5 },
		key_piece_1   = { false, 0.75 },
		key_piece_2   = { false, 0.75 },
		virtouses     = { false, 0.75 },
		bum_killed    = { false, 0.75 },
		bum_left      = { false, 0.9 },
		dead_bum_left = { false, 1.1 },
		donation      = { false, 0.5 },
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
	if room:GetType(RoomType.ROOM_BOSS) and room:IsClear() and coopHUD.angel_seen == false then
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
	return { devil   = devil * 100,
	         angel   = angel * 100,
		--planetarium = { lvl:GetPlanetariumChance() * 100, 0 },
		     duality = duality }
end
--- returns offset of stat
---@param vertical boolean
---@return Vector
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