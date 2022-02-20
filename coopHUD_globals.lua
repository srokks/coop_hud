coopHUD.VERSION = '0.4.2-PROD' --DEBUG: test name for in game recognition
coopHUD.showExtraInfo = false
coopHUD.HUD_table = {}
coopHUD.signals = {
    map = nil, -- emits true when map btn hold - global signal
    is_joining = nil, -- to maintain back button when joining
    on_active_update = nil, --nil or emit player num
    on_item_update = nil, --nil or emit player num
    on_heart_update = nil, --nil or emit player num
    on_trinket_update = nil, --nil or emit player num
    on_pockets_update = nil, --nil or emit player num
    on_bethany_update = nil, --nil or emit player num
    overloaded_hud = nil,
    on_battle = false,
}
coopHUD.players = {}
coopHUD.options = {
    onRender = true,
    render_player_info = true,
    player_info_color = true,
    force_small_hud = false,
    timer_always_on = true,
    stats = {
        show = true,
        hide_in_battle= true,
        colorful = false,
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
}
coopHUD.players = {}
coopHUD.essau_no = 0
coopHUD.players_config = {
    players_no = 0,
    [0] = {
        anchor_top = 'top_left',
        anchor_bot = 'bot_left',
        mirrored = false,
        name = 'P1'
    },
    [1] = {
        anchor_top = 'top_right',
        anchor_bot = 'bot_right',
        mirrored = true,
        name = 'P2'
    },
    small = {
        scale = Vector(0.8,0.8),
        [0] = {
            anchor = 'top_left',
            mirrored = false,
            down_anchor = false,
            name = 'P1',
            color = 1,
            stat_anchor = 'bot_left',
        },
        [1] = {
            anchor = 'top_right',
            mirrored = true,
            down_anchor = false,
            name = 'P2',
            color = 2,
            stat_anchor = 'bot_right'
        },
        [2] = {
            anchor = 'bot_left',
            mirrored = false,
            down_anchor = true,
            name = 'P3',
            color = 3,
            stat_anchor = 'bot_left'
        },
        [3] = {
            anchor = 'bot_right',
            mirrored = true,
            down_anchor = true,
            name = 'P4',
            color = 4,
            stat_anchor = 'bot_right'
        },
    }
}
coopHUD.anchors = {
    top_left = Vector(0,0),
    bot_left = Vector(0,0),
    top_right = Vector(0,0),
    bot_right = Vector(0,0),
}
coopHUD.colors = {
	{name = "Tomato", color = Color(1, 0.39, 0.28)},
	{name = "GreenYellow", color = Color(0.68, 1, 0.18)},
	{name = "DeepskyBlue", color = Color(0, 0.75, 1)},
	{name = "Yellow", color = Color(1, 1, 0)},
	{name = "RoyalBlue", color = Color(0.25, 0.41, 1)},
	{name = "White", color = Color(1, 1, 1)},
	{name = "Pink", color = Color(1, 0, 1)},
	{name = "Aqua", color = Color(0, 1, 1)},
	{name = "Orange", color = Color(1, 0.5, 0)},
}
