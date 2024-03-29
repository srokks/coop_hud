coopHUD.VERSION = '0.8.8-WIP'
coopHUD.showExtraInfo = false
coopHUD.HUD_table = {}
coopHUD.signals = {
	map        = nil, -- emits true when map btn hold - global signal
	is_joining = false, -- to maintain back button when joining
	on_battle  = false, -- when false not in battle - 0 - in normal battle/not cleared room, 1 - boss battle, 2 - ambush (challange room,other)
}
---@type coopHUD.Player[]
coopHUD.players = {}
coopHUD.options = {
	onRender                 = true,
	hud_scale                = 1,
	render_player_info       = true,
	player_info_color        = true,
	force_small_hud          = false,
	timer_always_on          = false,
	show_run_info            = true,
	colorful_players         = true,
	colorful_stuff_page      = true,
	show_player_names        = true,
	extra_hud                = true,
	extra_hud_hide_on_battle = true,
	h_trigger_key            = -1,
	stats                    = {
		show           = true,
		hide_in_battle = true,
		colorful       = true,
		force_show     = true, -- Force to show stats on map button when battle
	},
	deals                    = {
		show             = true,
		hide_in_battle   = false,
		show_planetarium = true,
		vanilla_position = false -- defines if deals show under stats (true) or on down_screen (false)
	}
}
coopHUD.players = {} -- main players table, holds coopHUD.Player instances
coopHUD.essau_no = 0 -- holds run info about extra players in game (Essau,Lost from T.Forgotten)
coopHUD.angel_seen = false -- holds run info, if angel room was seen, used in deals calculate
---@type VarData[]
coopHUD.floor_custom_items = {} -- table of floor custom items, resets on new floor
coopHUD.players_config = {
	small   = {
		[0]   = {
			anchor       = 'top_left',
			anchor_top   = 'top_left',
			anchor_bot   = 'bot_left',
			mirrored     = false,
			mirrored_big = false,
			down_anchor  = false,
			name         = 'P1',
			color        = 1,
			stat_anchor  = 'bot_left',
		},
		[1]   = {
			anchor       = 'top_right',
			anchor_top   = 'top_right',
			anchor_bot   = 'bot_right',
			mirrored     = true,
			mirrored_big = true,
			down_anchor  = false,
			name         = 'P2',
			color        = 2,
			stat_anchor  = 'bot_right'
		},
		[2]   = {
			anchor      = 'bot_left',
			anchor_bot  = 'bot_left',
			mirrored    = false,
			down_anchor = true,
			name        = 'P3',
			color       = 3,
			stat_anchor = 'bot_left'
		},
		[3]   = {
			anchor      = 'bot_right',
			anchor_bot  = 'bot_right',
			mirrored    = true,
			down_anchor = true,
			name        = 'P4',
			color       = 4,
			stat_anchor = 'bot_right'
		},
	},
	default = {
		[0] = {
			name         = 'top left',
			anchor       = 'top_left',
			anchor_top   = 'top_left',
			anchor_bot   = 'bot_left',
			mirrored_big = false,
			mirrored     = false,
			down_anchor  = false,
			stat_anchor  = 'bot_left',
		},
		[1] = {
			name         = "top right",
			anchor       = 'top_right',
			anchor_top   = 'top_right',
			anchor_bot   = 'bot_right',
			mirrored     = true,
			mirrored_big = true,
			down_anchor  = false,
			stat_anchor  = 'bot_right'
		},
		[2] = {
			name        = 'bottom left',
			anchor      = 'bot_left',
			anchor_bot  = 'bot_left',
			mirrored    = false,
			down_anchor = true,
			stat_anchor = 'bot_left'
		},
		[3] = {
			name        = 'bottom right',
			anchor      = 'bot_right',
			anchor_bot  = 'bot_right',
			mirrored    = true,
			down_anchor = true,
			stat_anchor = 'bot_right'
		},
	}
}
coopHUD.anchors = {
	top_left       = Vector(0, 0),
	bot_left       = Vector(0, 0),
	top_right      = Vector(0, 0),
	bot_right      = Vector(0, 0),
	top_left_id    = 0,
	top_right_id   = 1,
	bot_left_id    = 2,
	bot_right_id   = 3,
	top_left_name  = 'top left',
	bot_left_name  = 'bottom left',
	top_right_name = 'top right',
	bot_right_name = 'bottom right',
}
coopHUD.colors = {
	{ name = "DeepSkyBlue", color = Color(0, 0.75, 1) },
	{ name = "GreenYellow", color = Color(0.68, 1, 0.18) },
	{ name = "Orange", color = Color(1, 0.5, 0) },
	{ name = "Yellow", color = Color(1, 1, 0) },
	{ name = "Pink", color = Color(1, 0, 1) },
	{ name = "Tomato", color = Color(1, 0.39, 0.28) },
	{ name = "White", color = Color(1, 1, 1) },
	{ name = "RoyalBlue", color = Color(0.25, 0.41, 1) },
	{ name = "Aqua", color = Color(0, 1, 1) },
}