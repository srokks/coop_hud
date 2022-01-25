coopHUD.GLOBALS = {
    item_anim_path = '/gfx/ui/items_coop.anm2',
    card_anim_path = "gfx/ui/hud_card_coop.anm2",
    pill_anim_path = "gfx/ui/hud_pills_coop.anm2",
    hearts_anim_path = "gfx/ui/ui_hearts.anm2",
    charge_anim_path = "gfx/ui/activechargebar_coop.anm2",
    poop_anim_path = "gfx/ui/ui_poops.anm2"
}
coopHUD.players = {}
coopHUD.TICKER = 0
coopHUD.players_config = {
    players_no = 0,
    [0] = {
        anchor_top = 'top_left',
        anchor_bot = 'bot_left',
        mirrored = false,
    },
    [1] = {
        anchor_top = 'top_right',
        anchor_bot = 'bot_right',
        mirrored = true,
    },
    small = {
        [0] = {
            anchor = 'top_left',
            mirrored = false,
            down_anchor = false,
            scale = Vector(1,1)
        },
        [1] = {
            anchor = 'top_right',
            mirrored = true,
            down_anchor = false,
            scale = Vector(1,1)
        },
        [2] = {
            anchor = 'bot_left',
            mirrored = false,
            down_anchor = true,
            scale = Vector(1,1)
        },
        [3] = {
            anchor = 'bot_right',
            mirrored = true,
            down_anchor = true,
            scale = Vector(1,1)
        },
    }
}
coopHUD.anchors = {
    top_left = Vector(0,0),
    bot_left = Vector(0,0),
    top_right = Vector(0,0),
    bot_right = Vector(0,0),
}