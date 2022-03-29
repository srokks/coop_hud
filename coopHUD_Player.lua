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
	self.game_index = player_no
	self.name = 'P' .. tostring(player_no + 1)
	-- Active items
	self.active_item = coopHUD.Item(self.entPlayer, ActiveSlot.SLOT_PRIMARY)
	self.schoolbag_item = coopHUD.Item(self.entPlayer, ActiveSlot.SLOT_SECONDARY)
	-- Trinkets
	self.first_trinket = coopHUD.Trinket(self.entPlayer,0)
	self.second_trinket = coopHUD.Trinket(self.entPlayer,1)
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
	-- SUB PLAYER
	has_sub = false -- Determines if player has sub as Forgotten/Soul
	has_twin = false -- Determines if player has twin as Jacob/Essau
	is_ghost = self.entPlayer:IsCoopGhost() -- Determines if player is old style coop ghost
	sub_heart_types = {}
	twin = {}
	-- STATS
	-- holds player stats [1] - stat; [2] change
	self.stats = {
		speed       = { self.entPlayer.MoveSpeed, 0 },
		tears_delay = { 30 / (self.entPlayer.MaxFireDelay + 1), 0 },
		damage      = { self.entPlayer.Damage, 0 },
		range       = { (self.entPlayer.TearRange / 40), 0 },
		shot_speed  = { self.entPlayer.ShotSpeed, 0 },
		luck        = { self.entPlayer.Luck, 0 },
	}
	-- Extra charges
	bethany_charge = nil -- inits charge for Bethany
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
		on_active_update = false,
		on_drop_activate = false,
	}
	--
	return self
end
function coopHUD.Player:on_active_update()
	if self.signals.on_active_update then
		self.signals.on_active_update = false
	else
		self.signals.on_active_update = true
	end
end
function coopHUD.Player:update()
	if self.signals.on_drop_activate then
		self.signals.on_active_update = true
		self.signals.on_drop_activate = nil
	end
	 --print(self.signals.on_active_update)
	if self.signals.on_active_update then
		self.active_item:update()
		self.schoolbag_item:update()
		self:on_active_update()
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
	local trinket_off = Vector(0, 0)
	local extra_charge_off = Vector(0, 0)
	local poop_spell_off = Vector(0, 0)
	--
	self.schoolbag_item:render(anchor, mirrored, scale, down_anchor)
	active_off = self.active_item:render(anchor, mirrored, scale, down_anchor)
	--
	-- <Second  top line render> --
	local first_line_offset = Vector(0, 0)
	if down_anchor then
		first_line_offset.Y = math.min(info_off.Y, active_off.Y, hearts_off.Y, (exl_liv_off.Y + extra_charge_off.Y))
	else
		first_line_offset.Y = math.max(info_off.Y, active_off.Y, hearts_off.Y, exl_liv_off.Y + extra_charge_off.Y)
	end
	trinket_off = self.first_trinket:render(Vector(anchor.X, anchor.Y + first_line_offset.Y), mirrored, scale,
	                                        down_anchor)
	self.second_trinket:render(Vector(anchor.X, anchor.Y + first_line_offset.Y + trinket_off.Y), mirrored, scale,
	                           down_anchor)
end
