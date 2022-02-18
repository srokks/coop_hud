coopHUD.VERSION = '0.4.1-PROD' --DEBUG: test name for in game recognition
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
}
coopHUD.players = {}
coopHUD.options = {
    onRender = true,
    render_player_info = true,
    force_small_hud = false,
    timer_always_on = true,
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
coopHUD.TICKER = 0
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
            name = 'P1'
        },
        [1] = {
            anchor = 'top_right',
            mirrored = true,
            down_anchor = false,
            name = 'P2'
        },
        [2] = {
            anchor = 'bot_left',
            mirrored = false,
            down_anchor = true,
            name = 'P3',
        },
        [3] = {
            anchor = 'bot_right',
            mirrored = true,
            down_anchor = true,
            name = 'P4'
        },
    }
}
coopHUD.anchors = {
    top_left = Vector(0,0),
    bot_left = Vector(0,0),
    top_right = Vector(0,0),
    bot_right = Vector(0,0),
}