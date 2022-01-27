coopHUD.VERSION = '0.2.2' --DEBUG: test name for in game recognition
coopHUD.onRender = true
coopHUD.is_joining = false
coopHUD.options = {
    render_player_info = true,
    force_small_hud = true,
}
coopHUD.GLOBALS = {
    item_anim_path = '/gfx/ui/items_coop.anm2',
    card_anim_path = "gfx/ui/hud_card_coop.anm2",
    pill_anim_path = "gfx/ui/hud_pills_coop.anm2",
    hearts_anim_path = "gfx/ui/ui_hearts.anm2",
    charge_anim_path = "gfx/ui/activechargebar_coop.anm2",
    poop_anim_path = "gfx/ui/ui_poops.anm2",
    player_head_anim_path = "gfx/ui/coop menu.anm2",
}
coopHUD.players = {}
coopHUD.TICKER = 0
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