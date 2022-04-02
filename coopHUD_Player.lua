coopHUD.Player = {}
coopHUD.Player.__index = coopHUD.Player
setmetatable(coopHUD.Player, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
})
function coopHUD.Player.new(player_no)
	local self = setmetatable({}, coopHUD.Player)
	--
	self.entPlayer = Isaac.GetPlayer(player_no)
	self.controller_index = self.entPlayer.ControllerIndex
	self.game_index = player_no - coopHUD.essau_no
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
	self.collectibles = {} -- item
	self.gulped_trinkets = {} -- trinket
	-- HEARTS
	self.max_health_cap = 12
	self.total_hearts = math.ceil((self.entPlayer:GetEffectiveMaxHearts() + self.entPlayer:GetSoulHearts()) / 2)
	self.extra_lives = self.entPlayer:GetExtraLives()
	self.hearts = coopHUD.HeartTable(self)
	-- SUB PLAYER
	has_sub = false -- Determines if player has sub as Forgotten/Soul
	has_twin = false -- Determines if player has twin as Jacob/Essau
	is_ghost = self.entPlayer:IsCoopGhost() -- Determines if player is old style coop ghost
	sub_heart_types = {}
	twin = {}
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
		on_active_update = false, --nil or emit player num
		on_item_update = false, --nil or emit player num
		on_heart_update = false, --nil or emit player num
		on_trinket_update = false, --nil or emit player num
		on_pockets_update = false, --nil or emit player num
		on_bethany_update = false, --nil or emit player num
		on_poop_update = false, --nil or emit player num
		overloaded_hud = false,
		on_battle = false,
		on_drop_activate = false, --nil or emit player num
	}
	--
	self.font_color = KColor(1, 1, 1, 1)
	--
	return self
end
function coopHUD.Player:on_signal(signal)
	if self.signals[signal] then
		self.signals[signal] = false
	else
		self.signals[signal] = true
	end
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
	if self.signals.on_drop_activate then
		self.signals.on_active_update = true
		self.signals.on_pocket_update = true
		self.signals.on_drop_activate = nil
	end
	if self.signals.on_heart_update then
		self.hearts:update()
		if self.extra_charge then
			self.extra_charge:update()
		end
		self:on_signal('on_heart_update')
	end
	if self.signals.on_active_update then
		self.active_item:update()
		self.schoolbag_item:update()
		self:on_signal('on_active_update')
	end
	if self.signals.on_pocket_update then

		self.first_pocket:update()
		self.second_pocket:update()
		self.third_pocket:update()
		self:on_signal('on_pocket_update')
	end
	if self.signals.on_trinket_update then
		self.first_trinket:update()
		self.second_trinket:update()
		self.signals.on_trinket_update = nil
	end
end
function coopHUD.Player:render()
	--
	local anchor = Vector(coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor].X,
	                      coopHUD.anchors[coopHUD.players_config.small[self.game_index].anchor].Y)
	local mirrored = coopHUD.players_config.small[self.game_index].mirrored
	local scale = coopHUD.players_config.small.scale
	local down_anchor = coopHUD.players_config.small[self.game_index].down_anchor
	--
	local info_off = Vector(0, 0)
	local active_off = Vector(0, 0)
	local hearts_off = Vector(0, 0)
	local exl_liv_off = Vector(0, 0)
	local pocket_off = Vector(0, 0)
	local second_pocket_off = Vector(0, 0)
	local trinket_off = Vector(0, 0)
	local extra_charge_off = Vector(0, 0)
	local poop_spell_off = Vector(0, 0)
	--
	if coopHUD.options.render_player_info then
		info_off = self.player_head:render(anchor, mirrored, scale, down_anchor)
	end
	self.schoolbag_item:render(Vector(anchor.X + info_off.X, anchor.Y), mirrored, scale, down_anchor)
	active_off = self.active_item:render(Vector(anchor.X + info_off.X, anchor.Y), mirrored, scale, down_anchor)
	active_off.X = active_off.X + info_off.X
	active_off.Y = active_off.Y + info_off.Y
	hearts_off = self.hearts:render(Vector(anchor.X + active_off.X, anchor.Y), mirrored, scale, down_anchor)
	self:renderExtras(Vector(anchor.X + active_off.X + hearts_off.X, anchor.Y), mirrored, scale, down_anchor)
	--self.active_item:render(Vector(anchor.X + active_off.X + hearts_off.X, anchor.Y), mirrored, scale, down_anchor)
	-- <Second  top line render> --
	local first_line_offset = Vector(0, 0)
	local pocket_desc_off = Vector(0, 0)
	if down_anchor then
		first_line_offset.Y = math.min(info_off.Y, active_off.Y, hearts_off.Y, (exl_liv_off.Y + extra_charge_off.Y))
		pocket_desc_off.Y = -8
	else
		first_line_offset.Y = math.max(info_off.Y, active_off.Y, hearts_off.Y, exl_liv_off.Y + extra_charge_off.Y)
	end
	trinket_off = self.first_trinket:render(Vector(anchor.X, anchor.Y + first_line_offset.Y), mirrored, scale,
	                                        down_anchor)
	self.second_trinket:render(Vector(anchor.X, anchor.Y + first_line_offset.Y + trinket_off.Y), mirrored, scale,
	                           down_anchor)
	--
	pocket_off = self.first_pocket:render(Vector(anchor.X + trinket_off.X, anchor.Y + first_line_offset.Y), mirrored,
	                                      scale,
	                                      down_anchor)
	second_pocket_off = self.second_pocket:render(Vector(anchor.X + trinket_off.X + pocket_off.X,
	                                                     anchor.Y + first_line_offset.Y + pocket_desc_off.Y), mirrored,
	                                              Vector(0.5 * scale.X, 0.5 * scale.Y),
	                                              down_anchor)

	self.third_pocket:render(Vector(anchor.X + trinket_off.X + pocket_off.X + second_pocket_off.X,
	                                anchor.Y + first_line_offset.Y), mirrored,
	                         Vector(0.5 * scale.X, 0.5 * scale.Y),
	                         down_anchor)
	-- PLAYER COLOR SET
	local col = Color(1, 1, 1, 1)
	if coopHUD.options.colorful_players then
		col.R = self.font_color.Red
		col.G = self.font_color.Green
		col.B = self.font_color.Blue
	end
	self.entPlayer:SetColor(col, 2, 100, false, false)
	if coopHUD.options.show_player_names then
		local position = Isaac.WorldToRenderPosition(self.entPlayer.Position)
		coopHUD.HUD.fonts.pft:DrawString(self.player_head.name, position.X - 5, position.Y, self.font_color)
	end
	if coopHUD.options.stats.show then
		local font_color = KColor(1, 1, 1, 1)
		if coopHUD.options.stats.colorful then
			font_color = self.font_color
		end

		local temp_stat_pos = Vector(anchor.X, 100)
		off = self.speed:render(temp_stat_pos,mirrored)
		temp_stat_pos.Y = temp_stat_pos.Y + off.Y
		off = self.tears_delay:render(temp_stat_pos,mirrored)
		temp_stat_pos.Y = temp_stat_pos.Y + off.Y
		off = self.damage:render(temp_stat_pos,mirrored)
		temp_stat_pos.Y = temp_stat_pos.Y + off.Y
		self.range:render(temp_stat_pos,mirrored)
		temp_stat_pos.Y = temp_stat_pos.Y + off.Y
		self.shot_speed:render(temp_stat_pos,mirrored)
		temp_stat_pos.Y = temp_stat_pos.Y + off.Y
		self .luck:render(temp_stat_pos,mirrored)
	end
end
function coopHUD.Player:renderExtras(pos, mirrored, scale, down_anchor)
	local final_offset = Vector(0, 0)
	local temp_pos = Vector(pos.X + 4, pos.Y)
	--
	local sprite_scale = scale
	if sprite_scale == nil then sprite_scale = Vector(1, 1) end -- sets def sprite_scale
	-- Render extra extra_lives
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
	--Todo: Extra protection charge indicator
end
