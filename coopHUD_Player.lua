coopHUD.Player = {}
coopHUD.Player.__index = coopHUD.Player
setmetatable(coopHUD.Player, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
---@param player_no number player ,used for main
---@param entPlayer userdata accepts EntityPlayer, if passed ignore passed player number and creates Player according to passed entity
---used for sub player such as essau
function coopHUD.Player.new(player_no, entPlayer)
	local self = setmetatable({}, coopHUD.Player)
	--
	self.entPlayer = Isaac.GetPlayer(player_no)
	if entPlayer then
		self.entPlayer = entPlayer
	end
	self.game_index = player_no - coopHUD.essau_no
	self.controller_index = self.entPlayer.ControllerIndex
	self.player_head = coopHUD.PlayerHead(self)
	-- Active items
	self.active_item = coopHUD.Item(self.entPlayer, ActiveSlot.SLOT_PRIMARY)
	self.schoolbag_item = coopHUD.Item(self.entPlayer, ActiveSlot.SLOT_SECONDARY)
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
		self.essau = coopHUD.Player(self.game_index, self.entPlayer:GetOtherTwin())
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
	-- Extra charges
	wisp_jar_use = 0 -- holds info about used jar of wisp
	-- T.Cain - specifics
	self.bag_of_crafting = nil
	self.crafting_result = nil
	--- T ??? - specifics
	self.poop_mana = nil -- current mana (int)
	self.max_poop_mana = nil -- max cap of mana that player holds (int)
	self.poops = nil -- table of
	self.hold_spell = nil -- current spell stashed in hold (int)
	--
	self.signals = {
		map_btn = false,
	}
	--
	self.font_color = KColor(1, 1, 1, 1)
	return self
end
function coopHUD.Player:update()
	-- Player Color Update
	if coopHUD.options.player_info_color then
		local temp_color = coopHUD.colors[coopHUD.players_config.small[self.game_index].color].color
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
end
function coopHUD.Player:render()
	--
	local anchor = Vector(coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor].X,
	                      coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor].Y)
	local anchor_bot = Vector(coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_bot].X,
	                          coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_bot].Y)
	local mirrored = coopHUD.players_config.small[self.game_index].mirrored
	local scale = coopHUD.players_config.small.scale
	local down_anchor = coopHUD.players_config.small[self.game_index].down_anchor
	if #coopHUD.players < 3 and not coopHUD.options.force_small_hud then
		anchor = Vector(coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_top].X,
		                coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor_top].Y)
		mirrored = coopHUD.players_config.small[self.game_index].mirrored_big
	end
	--
	local info_off = Vector(0, 0)
	local active_off = Vector(0, 0)
	local hearts_off = Vector(0, 0)
	local exl_liv_off = Vector(0, 0)
	local pocket_off = Vector(0, 0)
	local second_pocket_off = Vector(0, 0)
	local third_pocket_off = Vector(0, 0)
	local trinket_off = Vector(0, 0)
	local extra_charge_off = Vector(0, 0)
	local poop_spell_off = Vector(0, 0)
	--
	if coopHUD.options.render_player_info then
		info_off = self.player_head:render(anchor, mirrored, scale, down_anchor)
	end
	local dim = false -- holds if active items needed to be dimmed before redner, default false
	if self.essau then
		-- if playing as jacob sets dim according to pressed drop button
		dim = Input.IsActionPressed(ButtonAction.ACTION_DROP, self.controller_index)
		scale = coopHUD.players_config.small.scale -- resets scale if essau logic changes it
		if dim then scale = Vector(0.9 * coopHUD.players_config.small.scale.X,
		                           0.9 * coopHUD.players_config.small.scale.Y) end -- shrinks inactive sprites
	end
	self.schoolbag_item:render(Vector(anchor.X + info_off.X, anchor.Y), mirrored, scale, down_anchor, dim)
	active_off = self.active_item:render(Vector(anchor.X + info_off.X, anchor.Y), mirrored, scale, down_anchor, dim)
	active_off.X = active_off.X + info_off.X
	scale = coopHUD.players_config.small.scale -- resets scale if essau logic changes it
	hearts_off = self.hearts:render(Vector(anchor.X + active_off.X, anchor.Y), mirrored, scale, down_anchor)
	if self.sub_hearts then -- RENDERS SUB PLAYER (Forgotten/Soul) hearts
		hearts_off.X = hearts_off.X + (self.sub_hearts:render(Vector(anchor.X + active_off.X, anchor.Y + hearts_off.Y),
		                                                      mirrored, scale, down_anchor, true)).X
	end
	self:renderExtras(Vector(anchor.X + active_off.X + hearts_off.X, anchor.Y), mirrored, scale, down_anchor)
	if self.essau then -- RENDERS ESSAU ACTIVE ITEMS
		local sub_anchor = Vector(anchor.X, anchor.Y)
		if dim then scale = Vector(0.9 * coopHUD.players_config.small.scale.X,
		                           0.9 * coopHUD.players_config.small.scale.Y) end -- shrinks inactive sprites
		if down_anchor then
			sub_anchor.Y = sub_anchor.Y + math.min(info_off.Y, active_off.Y, hearts_off.Y) * 0.75
		else
			sub_anchor.Y = sub_anchor.Y + math.max(info_off.Y, active_off.Y, hearts_off.Y)
		end
		self.essau.schoolbag_item:render(Vector(sub_anchor.X, sub_anchor.Y), mirrored, scale, down_anchor, dim)
		local sub_active_off = self.essau.active_item:render(Vector(sub_anchor.X, sub_anchor.Y), mirrored, scale,
		                                                     down_anchor, dim)
		scale = coopHUD.players_config.small.scale -- resets scale if essau logic changes it
		local sub_hearts_off = self.essau.hearts:render(Vector(sub_anchor.X + sub_active_off.X, sub_anchor.Y), mirrored,
		                                                scale, down_anchor)
		active_off.Y = active_off.Y + sub_active_off.Y
		hearts_off.Y = hearts_off.Y + sub_hearts_off.Y
		scale = coopHUD.players_config.small.scale -- resets scale if essau logic changes it
	end -- RENDERS ESSAU -
	-- <Second  top line render> --
	if #coopHUD.players < 3 and not coopHUD.options.force_small_hud then
		-- special version of hud when only when <2 players and not forced in options
		anchor.X = anchor_bot.X
		anchor.Y = anchor_bot.Y
		down_anchor = true
	end
	local first_line_offset = Vector(0, 0)
	local pocket_desc_off = Vector(0, 0)
	if down_anchor then
		first_line_offset.Y = math.min(info_off.Y, active_off.Y, hearts_off.Y)
		if #coopHUD.players < 3 and not coopHUD.options.force_small_hud then
			first_line_offset.Y = 0
		end
		pocket_desc_off.Y = -8
	else
		first_line_offset.Y = math.max(info_off.Y, active_off.Y, hearts_off.Y)
	end
	local trinket_pos = Vector(anchor.X, anchor.Y + first_line_offset.Y)
	trinket_off = self.first_trinket:render(Vector(trinket_pos.X, trinket_pos.Y), mirrored, scale,
	                                        down_anchor)
	local temp_off = self.second_trinket:render(Vector(trinket_pos.X + trinket_off.X, trinket_pos.Y),
	                                            mirrored, scale,
	                                            down_anchor)
	trinket_off.X = trinket_off.X + temp_off.X
	dim = false -- holds if active items needed to be dimmed before redner, default false
	if self.essau then
		-- if playing as jacob sets dim according to pressed drop button
		dim = not Input.IsActionPressed(ButtonAction.ACTION_DROP, self.controller_index)
		scale = coopHUD.players_config.small.scale -- resets scale if essau logic changes it
		if dim then scale = Vector(0.9 * coopHUD.players_config.small.scale.X,
		                           0.9 * coopHUD.players_config.small.scale.Y) end -- shrinks inactive sprites
	end
	--
	pocket_off = self.first_pocket:render(Vector(anchor.X + trinket_off.X, anchor.Y + first_line_offset.Y), mirrored,
	                                      scale,
	                                      down_anchor, dim)
	second_pocket_off = self.second_pocket:render(Vector(anchor.X + trinket_off.X + pocket_off.X,
	                                                     anchor.Y + first_line_offset.Y + pocket_desc_off.Y), mirrored,
	                                              Vector(0.5 * scale.X, 0.5 * scale.Y),
	                                              down_anchor, dim)

	third_pocket_off = self.third_pocket:render(Vector(anchor.X + trinket_off.X + pocket_off.X + second_pocket_off.X,
	                                                   anchor.Y + first_line_offset.Y + pocket_desc_off.Y), mirrored,
	                                            Vector(0.5 * scale.X, 0.5 * scale.Y),
	                                            down_anchor, dim)
	if down_anchor then
		first_line_offset.Y = first_line_offset.Y + math.min(pocket_off.Y,trinket_off.Y)
	else
		first_line_offset.Y = first_line_offset.Y + math.max(pocket_off.Y,trinket_off.Y)
	end
	--
	if self.essau then -- RENDERS ESSAU TRINKETS/POCKETS
		scale = coopHUD.players_config.small.scale -- resets scale if essau logic changes it
		local sub_trinket_pos = Vector(anchor.X, anchor.Y + first_line_offset.Y)
		local sub_trinket_off = self.essau.first_trinket:render(Vector(sub_trinket_pos.X, sub_trinket_pos.Y), mirrored,
		                                                        scale,
		                                                        down_anchor)
		sub_trinket_off = sub_trinket_off + self.essau.second_trinket:render(Vector(sub_trinket_pos.X + sub_trinket_off.X,
		                                                                            sub_trinket_pos.Y),
		                                                                     mirrored, scale,
		                                                                     down_anchor, dim)
		local sub_pocket_pos = Vector(sub_trinket_pos.X + sub_trinket_off.X, sub_trinket_pos.Y)
		local sub_pocket_off = self.essau.first_pocket:render(sub_pocket_pos,
		                                                      mirrored,
		                                                      scale,
		                                                      down_anchor, dim)
		sub_pocket_pos.X = sub_pocket_pos.X + sub_pocket_off.X
		sub_pocket_off = self.essau.second_pocket:render(sub_pocket_pos,
		                                                 mirrored,
		                                                 Vector(0.5 * scale.X, 0.5 * scale.Y),
		                                                 down_anchor, dim)
		sub_pocket_pos.X = sub_pocket_pos.X + sub_pocket_off.X
		local sub_third_pocket_off = self.essau.third_pocket:render(sub_pocket_pos,
		                                                            mirrored,
		                                                            Vector(0.5 * scale.X, 0.5 * scale.Y),
		                                                            down_anchor, dim)
		if down_anchor then
			first_line_offset.Y = first_line_offset.Y + math.min(sub_pocket_off.Y,sub_trinket_off.Y)
		else
			first_line_offset.Y = first_line_offset.Y + math.max(sub_pocket_off.Y,sub_trinket_off.Y)
		end
	end
	-- PLAYER COLOR SET
	local col = Color(1, 1, 1, 1)
	if coopHUD.options.colorful_players then
		col.R = self.font_color.Red
		col.G = self.font_color.Green
		col.B = self.font_color.Blue
	end
	self.entPlayer:SetColor(col, 2, 100, false, false)
	--Player name on screen
	if coopHUD.options.show_player_names then
		local position = Isaac.WorldToScreen(self.entPlayer.Position)
		coopHUD.HUD.fonts.pft:DrawString(self.player_head.name, position.X - 5, position.Y, self.font_color)
	end
	if coopHUD.options.stats.show then
		-- when options.stats.show on
		if not (coopHUD.options.stats.hide_in_battle and coopHUD.signals.on_battle) then
			--when options.stats.hide_in_battle on and battle signal
			local font_color = KColor(1, 1, 1, 1)
			if coopHUD.options.stats.colorful then
				font_color = self.font_color
			end
			local temp_stat_pos = Vector(anchor.X, 82)
			local off = Vector(0, 14) -- static offset for stats
			if self.game_index == 2 or self.game_index == 3 then
				-- checks if player is 3rd or 4th
				if mirrored then
					temp_stat_pos.X = temp_stat_pos.X - 16 * 1.25 -- changes horizontal base position
					temp_stat_pos.Y = temp_stat_pos.Y + 7  -- changes  vertical base position
				else
					temp_stat_pos.X = temp_stat_pos.X + 16 -- changes horizontal base position
					temp_stat_pos.Y = temp_stat_pos.Y + 7 -- changes  vertical base position
				end
			end
			self.speed:render(temp_stat_pos, mirrored) -- renders object with player mirrored spec
			temp_stat_pos.Y = temp_stat_pos.Y + off.Y -- increments position with static offset vertical
			self.tears_delay:render(temp_stat_pos, mirrored)
			temp_stat_pos.Y = temp_stat_pos.Y + off.Y
			self.damage:render(temp_stat_pos, mirrored)
			temp_stat_pos.Y = temp_stat_pos.Y + off.Y
			self.range:render(temp_stat_pos, mirrored)
			temp_stat_pos.Y = temp_stat_pos.Y + off.Y
			self.shot_speed:render(temp_stat_pos, mirrored)
			temp_stat_pos.Y = temp_stat_pos.Y + off.Y
			self.luck:render(temp_stat_pos, mirrored)
			temp_stat_pos.Y = temp_stat_pos.Y + off.Y
			if self.game_index == 0 then
				-- saves pos under stats for other hud modules to access like deals stats
				coopHUD.HUD.stat_anchor = temp_stat_pos
			end
		end
	end
	--debug
	self.active_item:render(Vector(anchor.X,anchor.Y+first_line_offset.Y),mirrored,Vector(1,1),down_anchor,true)
	if self.signals.map_btn then
		-- TODO: stuff page render of button signal
	end
end
function coopHUD.Player:renderExtras(pos, mirrored, scale, down_anchor)
	local final_offset = Vector(0, 0)
	local temp_pos = Vector(pos.X + 4, pos.Y)
	--
	local sprite_scale = scale
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end -- sets def sprite_scale
	-- Render extra extra_lives
	if Game():GetLevel():GetCurses() ~= LevelCurse.CURSE_OF_THE_UNKNOWN then
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
				temp_pos.X = temp_pos.X - (16 * sprite_scale.Y)
				align = 1
			end
			coopHUD.HUD.fonts.pft:DrawStringScaled(text, temp_pos.X, temp_pos.Y, sprite_scale.X * 1.2,
			                                       sprite_scale.Y * 1.2,
			                                       self.font_color, align, true)
			temp_pos.X = pos.X + offset.X
			temp_pos.Y = pos.Y + offset.Y
		end
	end

	--Todo: Extra protection charge indicator
end
