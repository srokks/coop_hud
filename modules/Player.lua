---@class coopHUD.Player
---@param player_no number player number used in game
---@param entPlayer EntityPlayer Player Entity
---@field private self coopHUD.Player
---@field entPlayer EntityPlayer
---@field game_index number holds game index to get proper PlayerEntity
---@field controller_index number holds
---@field player_head coopHUD.PlayerHead
---@field active_item coopHUD.Item
---@field schoolbag_item coopHUD.Item
---@field first_trinket coopHUD.Trinket
---@field second_trinket coopHUD.Trinket
---@field first_pocket coopHUD.Pocket
---@field second_pocket coopHUD.Pocket
---@field third_pocket coopHUD.Pocket
---@field hearts coopHUD.HeartTable
---@field sub_hearts coopHUD.HeartTable sub player hearts ONLY WITH FORGOTTEN/LOST
---@field essau coopHUD.Player
---@field sub boolean holds if self is sub player like Essau
---@field collectibles coopHUD.Item[]
---@field gulped_trinkets coopHUD.Item[]
---@field extra_lives string
---@field speed coopHUD.Stat
---@field tears_delay coopHUD.Stat
---@field damage coopHUD.Stat
---@field range coopHUD.Stat
---@field shot_speed coopHUD.Stat
---@field luck coopHUD.Stat
---@field wisp_jar_use coopHUD.Stat
---@field inventory nil|coopHUD.Inventory
---@field bag_of_crafting nil|coopHUD.BoC.Item[]
---@field crafting_result nil|coopHUD.Item holds BoC crafting result
---@field hold_spell nil|number holds current hold spell FOR T.???
---@field poops nil|coopHUD.PoopsTable holds poops FOR T.???
---@field signals table map_btn;
---@field font_color KColor holds color used in HUD when option o
---@return coopHUD.Player
---@type coopHUD.Player | fun(player_no:number, entPlayer:userdata):coopHUD.Player
coopHUD.Player = {}
coopHUD.Player.__index = coopHUD.Player
setmetatable(coopHUD.Player, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
--- Player constructor
---@private
function coopHUD.Player.new(player_no, entPlayer)
	---@type coopHUD.Player
	local self = setmetatable({}, coopHUD.Player)
	--
	self.entPlayer = Isaac.GetPlayer(player_no)
	if entPlayer then
		self.entPlayer = entPlayer
	end
	self.game_index = player_no - coopHUD.essau_no
	self.controller_index = self.entPlayer.ControllerIndex
	self.player_head = coopHUD.PlayerHead(self)
	--- T ??? - specifics
	self.hold_spell = nil -- current spell stashed in hold (int)
	if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B then
		self.hold_spell = 0 --inits
		self.poops = coopHUD.PoopsTable(self.entPlayer)
	end
	-- Bag of Crafting  - specifics
	-- need to be init before item, item gets values from it
	self.bag_of_crafting = {}
	self.crafting_result = nil
	-- Active items
	self.active_item = coopHUD.Item(self, ActiveSlot.SLOT_PRIMARY)
	self.schoolbag_item = coopHUD.Item(self, ActiveSlot.SLOT_SECONDARY)
	-- Trinkets
	self.first_trinket = coopHUD.Trinket(self.entPlayer, 0)
	self.second_trinket = coopHUD.Trinket(self.entPlayer, 1)
	-- Pockets
	self.first_pocket = coopHUD.Pocket(self, 0)
	self.second_pocket = coopHUD.Pocket(self, 1)
	self.third_pocket = coopHUD.Pocket(self, 2)
	--
	self.transformations = {}
	for i = 0, PlayerForm.NUM_PLAYER_FORMS - 1 do
		self.transformations[i] = self.entPlayer:HasPlayerForm(i)
	end
	--
	self.collectibles = {} -- item
	self.gulped_trinkets = {} -- trinket
	-- HEARTS
	self.extra_lives = self.entPlayer:GetExtraLives()
	self.hearts = coopHUD.HeartTable(self.entPlayer)
	-- SUB PLAYER
	if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		self.sub_hearts = coopHUD.HeartTable(self.entPlayer:GetSubPlayer())
	end
	if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_JACOB then
		self.essau = coopHUD.Player(self.game_index + 1, self.entPlayer:GetOtherTwin())
	end
	if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_ESAU then
		self.sub = true
	end
	-- STATS
	-- Inits stats as coopHUD.Stat class
	self.speed = coopHUD.Stat(self, coopHUD.Stat.SPEED, self.game_index == 0 or self.game_index == 1)
	self.tears_delay = coopHUD.Stat(self, coopHUD.Stat.TEARS_DELAY, self.game_index == 0 or self.game_index == 1)
	self.damage = coopHUD.Stat(self, coopHUD.Stat.DAMAGE, self.game_index == 0 or self.game_index == 1)
	self.range = coopHUD.Stat(self, coopHUD.Stat.RANGE, self.game_index == 0 or self.game_index == 1)
	self.shot_speed = coopHUD.Stat(self, coopHUD.Stat.SHOT_SPEED, self.game_index == 0 or self.game_index == 1)
	self.luck = coopHUD.Stat(self, coopHUD.Stat.LUCK, self.game_index == 0 or self.game_index == 1)
	-- T.Isaac - specifics
	if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_ISAAC_B then
		self.inventory = coopHUD.Inventory(self)
	end
	--
	self.signals = {
		map_btn = false,
	}
	--
	self.font_color = KColor(1, 1, 1, 1)
	return self
end
---@param self  coopHUD.Player
function coopHUD.Player.update(self)
	-- Player Color Update
	if coopHUD.options.player_info_color then
		local temp_color = coopHUD.colors[coopHUD.players_config.small[coopHUD.Player.getIndexByControllerIndex(self.controller_index) - 1].color].color
		if self.font_color.Red ~= temp_color.R then
			self.font_color.Red = temp_color.R
		end
		if self.font_color.Green ~= temp_color.G then
			self.font_color.Green = temp_color.G
		end
		if self.font_color.Blue ~= temp_color.B then
			self.font_color.Blue = temp_color.B
		end
	elseif not coopHUD.options.player_info_color and -- resets color if option turned off
			(self.font_color.Red ~= 1 or self.font_color.Green ~= 1 or self.font_color.Green ~= 1) then
		self.font_color = KColor(1, 1, 1, 1)
	end
	-- Every render frame update controller_index
	if self.controller_index ~= self.entPlayer.ControllerIndex then
		self.controller_index = self.entPlayer.ControllerIndex
	end
	self.active_item:update()
	self.schoolbag_item:update()
	self.first_trinket:update()
	self.second_trinket:update()
	self.first_pocket:update()
	self.second_pocket:update()
	self.third_pocket:update()
	self.hearts:update()
	self.big_hud = #coopHUD.players < 3 and not coopHUD.options.force_small_hud
	coopHUD.BoC.update(self)
	for i = 0, PlayerForm.NUM_PLAYER_FORMS - 1 do
		if self.transformations[i] ~= self.entPlayer:HasPlayerForm(i) then
			self.transformations[i] = self.entPlayer:HasPlayerForm(i)
			coopHUD.Streak(false, coopHUD.Streak.ITEM, coopHUD.PlayerForm[i], nil, true,
			               self.font_color)
		end
	end
	if self.signals.map_btn and not coopHUD.signals.map then
		self.signals.map_btn = nil
	end
end
--- renders main player hud - active item/hearts
---@param self  coopHUD.Player
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scl Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@return Vector offset where render next sprite
function coopHUD.Player.renderMain(self, pos, mirrored, scl, down_anchor)
	local temp_pos = Vector(pos.X, pos.Y)
	local scale = scl
	-- Renders player info (head and name)
	local info_off = Vector(0, 0)
	if coopHUD.options.render_player_info then
		info_off = self.player_head:render(temp_pos, mirrored, scale, down_anchor)
	end
	-- DIM CONTROL - for dim active item sprite on PLAYER_JACOB or PLAYER_ESAU
	local dim = false -- holds if active items needed to be dimmed before redner, default false
	if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_JACOB or self.entPlayer:GetPlayerType() == PlayerType.PLAYER_ESAU then
		-- if playing as jacob sets dim according to pressed drop button
		dim = Input.IsActionPressed(ButtonAction.ACTION_DROP, self.controller_index)
		scale = coopHUD.players_config.small.scale -- resets scale if essau logic changes it
		if dim then
			scale = Vector(0.9 * coopHUD.players_config.small.scale.X,
			               0.9 * coopHUD.players_config.small.scale.Y)
		end -- shrinks inactive modules
	end
	-- ACTIVE/SCHOOLBAG ITEM RENDER
	local active_off = Vector(0, 0)
	temp_pos.X = temp_pos.X + info_off.X
	self.schoolbag_item:render(temp_pos, mirrored, scale, down_anchor, dim)
	active_off = self.active_item:render(temp_pos, mirrored, scale, down_anchor, dim)
	scale = scl -- resets scale if essau logic changes it
	-- HEARTS RENDER
	local hearts_off = Vector(0, 0)
	temp_pos.X = temp_pos.X + active_off.X
	hearts_off = self.hearts:render(temp_pos, mirrored, scale, down_anchor)
	-- RENDERS SUB PLAYER (Forgotten/Soul) hearts
	local sub_hearts_off = Vector(0, 0)
	if self.sub_hearts then
		sub_hearts_off = self.sub_hearts:render(Vector(temp_pos.X, temp_pos.Y + hearts_off.Y),
		                                        mirrored, scale, down_anchor, true)
	end
	--EXTRAS RENDER - mantle charge/extra lives
	if mirrored then
		temp_pos.X = temp_pos.X + math.min(hearts_off.X, sub_hearts_off.X)
	else
		temp_pos.X = temp_pos.X + math.max(hearts_off.X, sub_hearts_off.X)
	end
	local extras_off = self:renderExtras(temp_pos, mirrored, scale, down_anchor)
	-- FINAL OFFSET
	local offset = Vector(0, 0)
	if down_anchor then
		offset.Y = offset.Y + math.min(info_off.Y, active_off.Y, hearts_off.Y, extras_off.Y)
	else
		offset.Y = offset.Y + math.max(info_off.Y, active_off.Y, hearts_off.Y, extras_off.Y)
	end
	return offset
end
--- renders secondary player hud - pocket/trinkets
---@param self  coopHUD.Player
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scl Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@return Vector offset where render next sprite
function coopHUD.Player.renderPockets(self, pos, mirrored, scl, down_anchor)
	local temp_pos = Vector(pos.X, pos.Y)
	local scale = Vector(scl.X, scl.Y)
	-- DIM CONTROL - for dim active item sprite on PLAYER_JACOB or PLAYER_ESAU
	local dim = false -- holds if active items needed to be dimmed before redner, default false
	if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_JACOB or self.entPlayer:GetPlayerType() == PlayerType.PLAYER_ESAU then
		-- if playing as jacob sets dim according to pressed drop button
		dim = not Input.IsActionPressed(ButtonAction.ACTION_DROP, self.controller_index)
		scale = coopHUD.players_config.small.scale -- resets scale if essau logic changes it
		if dim then
			scale = Vector(0.9 * coopHUD.players_config.small.scale.X,
			               0.9 * coopHUD.players_config.small.scale.Y)
		end -- shrinks inactive modules
	end
	--FIRST POCKET RENDER
	local trinket_off = Vector(0, 0)
	trinket_off = self.first_trinket:render(temp_pos, mirrored, scl,
	                                        down_anchor)
	temp_pos.X = temp_pos.X + trinket_off.X
	trinket_off.X = trinket_off.X + self.second_trinket:render(temp_pos, mirrored, scl,
	                                                           down_anchor)                .X
	--
	local pocket_off = Vector(0, 0)
	temp_pos = Vector(pos.X + trinket_off.X, pos.Y)
	pocket_off = self.second_pocket:render(temp_pos, mirrored,
	                                       Vector(0.5 * scale.X, 0.5 * scale.Y),
	                                       down_anchor, dim)
	self.third_pocket:render(Vector(temp_pos.X, temp_pos.Y + pocket_off.Y), mirrored,
	                         Vector(0.5 * scale.X, 0.5 * scale.Y),
	                         down_anchor, dim)
	--
	temp_pos.X = temp_pos.X + pocket_off.X
	pocket_off = self.first_pocket:render(temp_pos, mirrored,
	                                      scale,
	                                      down_anchor, dim)
	local inv_off = Vector(0, 0)
	if self.inventory then
		temp_pos = Vector(pos.X, pos.Y)
		if down_anchor then
			temp_pos.Y = temp_pos.Y + math.min(trinket_off.Y, pocket_off.Y)
		else
			temp_pos.Y = temp_pos.Y + math.max(trinket_off.Y, pocket_off.Y)
		end
		inv_off = self.inventory:render(temp_pos, mirrored, down_anchor)
	end
	--
	local offset = Vector(0, 0)
	if down_anchor then
		offset.Y = math.min(trinket_off.Y, pocket_off.Y, inv_off.Y)
	else
		offset.Y = math.max(trinket_off.Y, pocket_off.Y, inv_off.Y)
	end
	return offset
end
--- MAIN Player render function
---@param self coopHUD.Player
function coopHUD.Player.render(self)
	local anchor = Vector(coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor].X,
	                      coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor].Y)
	local anchor_bot = Vector(coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_bot].X,
	                          coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_bot].Y)
	local mirrored = coopHUD.players_config.small[self.game_index].mirrored
	local scale = coopHUD.players_config.small.scale
	local down_anchor = coopHUD.players_config.small[self.game_index].down_anchor
	if self.big_hud then
		anchor = Vector(coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_top].X,
		                coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_top].Y)
		mirrored = coopHUD.players_config.small[self.game_index].mirrored_big
	end
	-- ITEMS/HEARTS/EXTRAS RENDER
	local first_line_off = self:renderMain(anchor, mirrored, scale, down_anchor)
	if self.essau then
		first_line_off.Y = first_line_off.Y + self.essau:renderMain(anchor + first_line_off, mirrored, scale,
		                                                            down_anchor)                      .Y
	end
	-- TRINKETS/POCKETS RENDER
	local second_line_pos = Vector(anchor.X, anchor.Y + first_line_off.Y)
	if self.big_hud then
		-- special version of hud when only when <2 players and not forced in options
		second_line_pos = Vector(coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_bot].X,
		                         coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_bot].Y)
		down_anchor = true
	end
	local second_line_off = self:renderPockets(second_line_pos, mirrored, scale,
	                                           down_anchor)
	if self.essau then
		second_line_off.Y = second_line_off.Y + self.essau:renderPockets(second_line_pos + second_line_off,
		                                                                 mirrored, scale, down_anchor)       .Y
	end
	-- PLAYER COLOR SET
	local col = Color(1, 1, 1, 1)
	if coopHUD.options.colorful_players then
		col.R = self.font_color.Red
		col.G = self.font_color.Green
		col.B = self.font_color.Blue
	end
	self.entPlayer:SetColor(col, 2, 100, false, false)
	if self.essau then
		-- colors essau sprite
		self.essau.entPlayer:SetColor(col, 2, 100, false, false)
	end
	--Player name on screen
	if coopHUD.options.show_player_names then
		local position = Isaac.WorldToScreen(self.entPlayer.Position)
		coopHUD.HUD.fonts.pft:DrawString(self.player_head.name, position.X - 5, position.Y, self.font_color)
		if self.essau then
			-- colors essau name
			position = Isaac.WorldToScreen(self.essau.entPlayer.Position)
			coopHUD.HUD.fonts.pft:DrawString(self.player_head.name, position.X - 5, position.Y, self.font_color)
		end
	end
	--STATS/COLLECTIBLES RENDER
	local stat_on_battle_check = not (coopHUD.options.stats.hide_in_battle and coopHUD.signals.on_battle)
	local hud_on_battle_check = not (coopHUD.options.extra_hud_hide_on_battle and coopHUD.signals.on_battle)
	if coopHUD.options.stats.show and stat_on_battle_check then
		if self.big_hud then
			if #coopHUD.players == 1 then
				-- always show when only 1 player
				self:renderStats(mirrored)
				-- renders main stat and essau stats on same time
				if self.essau then
					self.essau:renderStats(mirrored)
				end
			else
				-- BIG HUD
				if (coopHUD.options.extra_hud and (not self.signals.map_btn)) or #self.collectibles + #self.gulped_trinkets <= 0 then
					self:renderStats(mirrored)
					-- renders main stat and essau stats on same time
					if self.essau then
						self.essau:renderStats(mirrored)
					end
				elseif coopHUD.options.extra_hud == false then
					self:renderStats(mirrored)
					-- renders main stat and essau stats on same time
					if self.essau then
						self.essau:renderStats(mirrored)
					end
				end
			end
		else
			-- SMALL HUD
			local other_player_temp = coopHUD.players[self.game_index + 3] or coopHUD.players[self.game_index - 1]
			if other_player_temp then
				other_player_temp = other_player_temp.signals.map_btn
			end
			local other_stat_check = not self.signals.map_btn and other_player_temp
			if (coopHUD.options.extra_hud and not self.signals.map_btn and not other_stat_check) or #self.collectibles + #self.gulped_trinkets <= 0 then
				if self.essau and Input.IsActionPressed(ButtonAction.ACTION_DROP, self.controller_index) then
					self.essau:renderStats(mirrored)
				else
					self:renderStats(mirrored)
				end
			elseif coopHUD.options.extra_hud == false then
				if self.essau and Input.IsActionPressed(ButtonAction.ACTION_DROP, self.controller_index) then
					self.essau:renderStats(mirrored)
				else
					self:renderStats(mirrored)
				end
			end

		end
	end
	local collectibles_sum_check = #self.collectibles + #self.gulped_trinkets
	if self.essau then
		collectibles_sum_check = #self.essau.collectibles + #self.essau.gulped_trinkets
	end
	if coopHUD.options.extra_hud and hud_on_battle_check and collectibles_sum_check > 0 then
		if self.big_hud and #coopHUD.players == 1 then
			if self.essau and Input.IsActionPressed(ButtonAction.ACTION_DROP, self.controller_index) then
				-- renders essau collectibles on drop button pressed
				if #self.essau.collectibles + #self.essau.gulped_trinkets > 0 then
					coopHUD.Item.render_items_table(coopHUD.Item(self.essau, -1, 0),
					                                not mirrored)
				end
			else
				--renders collectibles on right (like vanilla)
				coopHUD.Item.render_items_table(coopHUD.Item(self, -1, 0),
				                                not mirrored)
			end
		else
			if self.signals.map_btn then
				if self.essau and Input.IsActionPressed(ButtonAction.ACTION_DROP, self.controller_index) then
					if #self.essau.collectibles + #self.essau.gulped_trinkets > 0 then
						coopHUD.Item.render_items_table(coopHUD.Item(self.essau, -1, 0), mirrored)
					end
				else
					coopHUD.Item.render_items_table(coopHUD.Item(self, -1, 0),
					                                mirrored)
				end
			end
		end
	end
end
--- renders  player extra hud - mantle charge/extra lives
---@param self  coopHUD.Player
---@param pos Vector position where render sprite
---@param mirrored boolean change anchor to right corner
---@param scale Vector scale of sprite
---@param down_anchor boolean change anchor to down corner
---@return Vector offset where render next sprite
function coopHUD.Player.renderExtras(self, pos, mirrored, scale, down_anchor)
	local final_offset = Vector(0, 0)
	local temp_pos = Vector(pos.X + 4, pos.Y)
	--
	local sprite_scale = scale
	if sprite_scale == nil then
		sprite_scale = Vector(1, 1)
	end -- sets def sprite_scale
	-- Render extra extra_lives
	if Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN == 0 then
		if self.entPlayer:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE) ~= 0 then
			local mantle_pos = Vector(temp_pos.X + 4, temp_pos.Y + 12)
			if down_anchor then
				mantle_pos.Y = mantle_pos.Y - 16

			end
			if mirrored then
				temp_pos.X = temp_pos.X - 8
				mantle_pos.X = mantle_pos.X - 12
			else
				temp_pos.X = temp_pos.X + 12
			end
			coopHUD.Mantle:Render(mantle_pos)
		end
		if self.entPlayer:GetExtraLives() > 0 then
			local offset = Vector(0, 8 * sprite_scale.X)
			if down_anchor then
				temp_pos.Y = temp_pos.Y - (16 * sprite_scale.Y)
				offset.Y = -8 * 1.25 * sprite_scale.Y
			end
			local text = string.format('x%d', self.entPlayer:GetExtraLives())
			if self.entPlayer:HasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_COLLAR) then
				text = text .. "?"
			end
			local align = 0
			if mirrored then
				temp_pos.X = temp_pos.X - (20 * sprite_scale.Y)
				align = 1
			end
			coopHUD.HUD.fonts.pft:DrawStringScaled(text, temp_pos.X, temp_pos.Y, sprite_scale.X * 1.2,
			                                       sprite_scale.Y * 1.2,
			                                       self.font_color, align, true)
			temp_pos.X = pos.X + offset.X
			temp_pos.Y = pos.Y + offset.Y
		end
	end
	return final_offset
end
--- renders  players stats
---@param self  coopHUD.Player
---@param mirrored boolean change anchor to right corner
---@return Vector offset where render next sprite
function coopHUD.Player.renderStats(self, mirrored)
	--when options.stats.hide_in_battle on and battle signal
	local font_color = KColor(1, 1, 1, 1)
	if coopHUD.options.stats.colorful then
		font_color = self.font_color
	end
	local temp_stat_pos = Vector(coopHUD.anchors.top_right.X, 82)
	if mirrored then
		temp_stat_pos.X = coopHUD.anchors.bot_right.X
	else
		temp_stat_pos.X = coopHUD.anchors.bot_left.X
	end
	local off = Vector(0, 14) -- static offset for stats
	if self.game_index - coopHUD.essau_no == 2 or self.game_index - coopHUD.essau_no == 3 then
		-- checks if player is 3rd or 4th
		if mirrored then
			temp_stat_pos.X = temp_stat_pos.X - 16 * 1.25 -- changes horizontal base position
			temp_stat_pos.Y = temp_stat_pos.Y + 7  -- changes  vertical base position
		else
			temp_stat_pos.X = temp_stat_pos.X + 16 -- changes horizontal base position
			temp_stat_pos.Y = temp_stat_pos.Y + 7 -- changes  vertical base position
		end
	end
	local only_num = false
	if self.entPlayer:GetPlayerType() == PlayerType.PLAYER_ESAU then
		if self.big_hud then
			local p = 1
			if mirrored then
				p = -1
			end
			temp_stat_pos.X = temp_stat_pos.X + 16 * p -- changes horizontal base position
			temp_stat_pos.Y = temp_stat_pos.Y + 7 * p-- changes  vertical base position
			only_num = true
		end
	end
	local color_alpha = 0.5
	if self.signals.map_btn then
		color_alpha = 1
	end
	self.speed:render(temp_stat_pos, mirrored, false, only_num, color_alpha) -- renders object with player mirrored spec
	temp_stat_pos.Y = temp_stat_pos.Y + off.Y -- increments position with static offset vertical
	self.tears_delay:render(temp_stat_pos, mirrored, false, only_num, color_alpha)
	temp_stat_pos.Y = temp_stat_pos.Y + off.Y
	self.damage:render(temp_stat_pos, mirrored, false, only_num, color_alpha)
	temp_stat_pos.Y = temp_stat_pos.Y + off.Y
	self.range:render(temp_stat_pos, mirrored, false, only_num, color_alpha)
	temp_stat_pos.Y = temp_stat_pos.Y + off.Y
	self.shot_speed:render(temp_stat_pos, mirrored, false, only_num, color_alpha)
	temp_stat_pos.Y = temp_stat_pos.Y + off.Y
	self.luck:render(temp_stat_pos, mirrored, false, only_num, color_alpha)
	temp_stat_pos.Y = temp_stat_pos.Y + off.Y
	if self.game_index == 0 and not (self.entPlayer:GetPlayerType() == PlayerType.PLAYER_ESAU) then
		-- saves pos under stats for other hud modules to access like deals stats
		coopHUD.HUD.stat_anchor = temp_stat_pos
		coopHUD.HUD.stat_anchor_mirrored = mirrored
	end
end
---Prepares table with items to save on close game.
---@param self coopHUD.Player
---@return table
function coopHUD.Player.getSaveTable(self)
	local collectibles = {}
	for j = 1, #self.collectibles do
		table.insert(collectibles,
		             { self.collectibles[j].type, self.collectibles[j].id })
	end
	local gulped_trinkets = {}
	for j = 1, #self.gulped_trinkets do
		table.insert(gulped_trinkets,
		             { self.gulped_trinkets[j].type, self.gulped_trinkets[j].id })
	end
	-- save bag of crafting
	local bag_of_crafting = {}
	if self.bag_of_crafting ~= nil then
		for j = 1, #self.bag_of_crafting do
			table.insert(bag_of_crafting, self.bag_of_crafting[j].id)
		end
	end
	local essau = nil
	if self.essau ~= nil then
		essau = self.essau:getSaveTable()
	end
	local active_custom_charges = nil
	if self.active_item then
		if self.active_item.custom_max_charge then
			active_custom_charges = { max_charge        = self.active_item.custom_max_charge,
			                          d_infinity_charge = self.active_item.d_infinity_charge }
		end
	end
	local schoolbag_custom_charges = nil
	if self.schoolbag_item then
		if self.schoolbag_item.custom_max_charge then
			schoolbag_custom_charges = { max_charge        = self.active_item.custom_max_charge,
			                             d_infinity_charge = self.active_item.d_infinity_charge }
		end
	end
	return { collectibles             = collectibles,
	         gulped_trinkets          = gulped_trinkets,
	         hold_spell               = self.hold_spell,
	         bag_of_crafting          = bag_of_crafting,
	         essau                    = essau,
	         item_custom_charge       = active_custom_charges,
	         schoolbag_custom_charges = schoolbag_custom_charges,
	}
end
---@param self coopHUD.Player
function coopHUD.Player.loadFromSaveTable(self, save_table)
	--` load collectibles
	for _, item_id in pairs(save_table.collectibles) do
		local type, id = item_id[1], item_id[2]
		if type == PickupVariant.PICKUP_COLLECTIBLE then
			table.insert(self.collectibles,
			             coopHUD.Item(self, -1, id))
		elseif type == PickupVariant.PICKUP_TRINKET then
			table.insert(self.collectibles,
			             coopHUD.Trinket(self, -1, id))
		end
	end
	--load gulped_trinkets and un roll able
	for _, item_id in pairs(save_table.gulped_trinkets) do
		local type, id = item_id[1], item_id[2]
		if type == PickupVariant.PICKUP_COLLECTIBLE then
			table.insert(self.gulped_trinkets,
			             coopHUD.Item(self, -1, id))
		elseif type == PickupVariant.PICKUP_TRINKET then
			table.insert(self.gulped_trinkets,
			             coopHUD.Trinket(self.entPlayer, -1, id))
		end
	end
	self.hold_spell = save_table.hold_spell
	-- Bag of crafting
	for _, item_id in pairs(save_table.bag_of_crafting) do
		table.insert(self.bag_of_crafting, coopHUD.BoC.Item(item_id))
	end
	-- Essau
	if save_table.essau then
		self.essau:loadFromSaveTable(save_table.essau)
	end
	if save_table.item_custom_charge then
		self.active_item.custom_max_charge = save_table.item_custom_charge.max_charge
		self.active_item.d_infinity_charge = save_table.item_custom_charge.d_infinity_charge
	end
end
---Return Player by entity index.
---@param entity_index number
---@return coopHUD.Player or nil
function coopHUD.Player.getByEntityIndex(entity_index)
	for i, player in pairs(coopHUD.players) do
		if player.entPlayer.Index == entity_index then
			return player
		end
		if player.essau and player.essau.entPlayer.Index == entity_index then
			return player.essau
		end
	end
	return nil
end
---Returns player number searching coopHUD.player table for matching controller index
---@param controller_index number
---@return number or -1
function coopHUD.Player.getIndexByControllerIndex(controller_index)
	local final_index = -1
	for i, p in pairs(coopHUD.players) do
		if p.controller_index == controller_index then
			final_index = i
		end
	end
	return final_index
end