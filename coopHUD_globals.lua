coopHUD.VERSION = '0.6-FIXES' --DEBUG: test name for in game recognition
coopHUD.showExtraInfo = false
coopHUD.HUD_table = {}
coopHUD.signals = {
	map = nil, -- emits true when map btn hold - global signal
	is_joining = false, -- to maintain back button when joining
	on_battle = false,
}
coopHUD.players = {}
coopHUD.options = {
	onRender = true,
	render_player_info = true,
	player_info_color = true,
	force_small_hud = false,
	timer_always_on = false,
	colorful_players = true,
	colorful_stuff_page = true,
	show_player_names = true,
	show_my_stuff = true,
	h_trigger = false,
	stats = {
		show = true,
		hide_in_battle = true,
		colorful = true,
	},
	deals = {
		show = true,
		hide_in_battle = false,
		show_planetarium = true,
		vanilla_position = false -- defines if deals show under stats (true) or on down_screen (false)
	}
}
coopHUD.GLOBALS = {
	item_anim_path = '/gfx/ui/items_coop.anm2',
	card_anim_path = "gfx/ui/hud_card_coop.anm2",
	pill_anim_path = "gfx/ui/hud_pills_coop.anm2",
	hearts_anim_path = "gfx/ui/ui_hearts.anm2",
	charge_anim_path = "gfx/ui/activechargebar_coop.anm2",
	poop_anim_path = "gfx/ui/ui_poops.anm2",
	player_head_anim_path = "gfx/ui/coop menu.anm2",
	hud_el_anim_path = "gfx/ui/hudpickups.anm2",
	streak_anim_path = "gfx/ui/ui_streak.anm2",
	hud_stats_anim_path = "gfx/ui/hudstats2.anm2",
	pause_screen_anim_path = "gfx/ui/pausescreen.anm2",
	crating_anim_path = "gfx/ui/ui_crafting.anm2",
	inventory_anim_path = "gfx/ui/ui_inventory.anm2",
}
coopHUD.players = {} -- main players table, holds coopHUD.Player instances
coopHUD.essau_no = 0 -- holds run info about extra players in game (Essau,Lost from T.Forgotten)
coopHUD.angel_seen = false -- holds run info, if angel room was seen, used in deals calculate
coopHUD.jar_of_wisp_charge = 0 -- holds run info, charge of jar of wisp
coopHUD.players_config = {
	small = {
		scale = Vector(1, 1),
		[0] = {
			anchor = 'top_left',
			anchor_top = 'top_left',
			anchor_bot = 'bot_left',
			mirrored = false,
			mirrored_big = false,
			down_anchor = false,
			name = 'P1',
			color = 1,
			stat_anchor = 'bot_left',
		},
		[1] = {
			anchor = 'top_right',
			anchor_top = 'top_right',
			anchor_bot = 'bot_right',
			mirrored = true,
			mirrored_big = true,
			down_anchor = false,
			name = 'P2',
			color = 2,
			stat_anchor = 'bot_right'
		},
		[2] = {
			anchor = 'bot_left',
			anchor_bot = 'bot_left',
			mirrored = false,
			down_anchor = true,
			name = 'P3',
			color = 3,
			stat_anchor = 'bot_left'
		},
		[3] = {
			anchor = 'bot_right',
			anchor_bot = 'bot_right',
			mirrored = true,
			down_anchor = true,
			name = 'P4',
			color = 4,
			stat_anchor = 'bot_right'
		},
	},
	default = {
		[0] = {
			name = 'top left',
			anchor = 'top_left',
			anchor_top = 'top_left',
			anchor_bot = 'bot_left',
			mirrored_big = false,
			mirrored = false,
			down_anchor = false,
			stat_anchor = 'bot_left',
		},
		[1] = {
			name = "top right",
			anchor = 'top_right',
			anchor_top = 'top_right',
			anchor_bot = 'bot_right',
			mirrored = true,
			mirrored_big = true,
			down_anchor = false,
			stat_anchor = 'bot_right'
		},
		[2] = {
			name = 'bottom left',
			anchor = 'bot_left',
			anchor_bot = 'bot_left',
			mirrored = false,
			down_anchor = true,
			stat_anchor = 'bot_left'
		},
		[3] = {
			name = 'bottom right',
			anchor = 'bot_right',
			anchor_bot = 'bot_right',
			mirrored = true,
			down_anchor = true,
			stat_anchor = 'bot_right'
		},
	}
}
coopHUD.anchors = {
	top_left = Vector(0, 0),
	bot_left = Vector(0, 0),
	top_right = Vector(0, 0),
	bot_right = Vector(0, 0),
	top_left_id = 0,
	top_right_id = 1,
	bot_left_id = 2,
	bot_right_id = 3,
	top_left_name = 'top left',
	bot_left_name = 'bottom left',
	top_right_name = 'top right',
	bot_right_name = 'bottom right',
}
coopHUD.colors = {
	{name = "Tomato", color = Color(1, 0.39, 0.28)},
	{name = "GreenYellow", color = Color(0.68, 1, 0.18)},
	{name = "DeepSkyBlue", color = Color(0, 0.75, 1)},
	{name = "Pink", color = Color(1, 0, 1)},
	{name = "Yellow", color = Color(1, 1, 0)},
	{name = "RoyalBlue", color = Color(0.25, 0.41, 1)},
	{name = "White", color = Color(1, 1, 1)},
	{name = "Aqua", color = Color(0, 1, 1)},
	{name = "Orange", color = Color(1, 0.5, 0)},
}
coopHUD.PlayerForm = {}
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_GUPPY] = "Guppy!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES] = "Beelzebub!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_MUSHROOM] = "Fun Guy!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_ANGEL] = "Seraphim!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_BOB] = "Bob!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_DRUGS] = "Spun!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_MOM] = "Yes mother?!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_BABY] = "Conjoined!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_EVIL_ANGEL] = "Leviathan!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_POOP] = "Oh crap!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_BOOK_WORM] = "Book Worm!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_ADULTHOOD] = "Adult!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_SPIDERBABY] = "Spider Baby!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_STOMPY] = "Stompy!"
coopHUD.PlayerForm[PlayerForm.PLAYERFORM_FLIGHT] = "Flight!"