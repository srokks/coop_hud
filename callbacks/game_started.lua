function coopHUD.on_player_init()
    if (#coopHUD.players + coopHUD.essau_no) ~= Game():GetNumPlayers() then
        coopHUD.players = {}  -- resets players table
        coopHUD.essau_no = 0  -- resets essau no before full init of players
        for i = 0, Game():GetNumPlayers() - 1, 1 do
            local player_type = Isaac.GetPlayer(i):GetPlayerType()
            if player_type ~= PlayerType.PLAYER_THESOUL_B and player_type ~= PlayerType.PLAYER_ESAU then
                -- skips iteration when non first character
                coopHUD.players[i + 1 - coopHUD.essau_no] = coopHUD.Player(i)
            else
                coopHUD.essau_no = coopHUD.essau_no + 1
                -- FIXME: wrong increasing essau counter on the soul_b join
            end
        end
        if coopHUD.signals.is_joining then
            coopHUD.signals.is_joining = false
        end
    end
end
-- __________ On start
function coopHUD.on_start(_, cont)
    --Resets tables
    coopHUD.players = {}
    coopHUD.essau_no = 0 -- resets essau_no
    coopHUD.on_player_init() -- inits players
    coopHUD.itemUnlockStates = {}
    if coopHUD.is_boc_in_game() then
        coopHUD.BoC.GameStartCrafting()
    end
    --
    coopHUD.angel_seen = false -- resets angel seen state on restart
    if cont then
        local json = require("json")
        -- Logic when game is continued
        local save = json.decode(coopHUD:LoadData())
        if coopHUD.VERSION == save.version then
            coopHUD.essau_no = save.run.essau_no
            coopHUD.angel_seen = save.run.angel_seen
            -- Loads player data from save
            -- Custom data load
            for _, varData in pairs(save.run.floor_custom_data) do
                table.insert(coopHUD.floor_custom_items, varData)
            end
            for player_no, player_save in pairs(save.run.players) do
                coopHUD.players[player_no]:loadFromSaveTable(player_save)
            end
            --
        end
    end
    coopHUD.HUD.init()
end
coopHUD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, coopHUD.on_start)