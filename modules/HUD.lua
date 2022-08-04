include("modules.RunInfo.lua")
include("modules.Streak.lua")
include("modules.Destination.lua")
---@class FontsTable
---@field lua_mini_lined Font
---@field pft Font
---@field team_meat_10 Font
---@field team_meat_12 Font
---@field upheaval Font


---@class coopHUD.HUD
---@field fonts FontsTable
---@field coins coopHUD.RunInfo
---@field keys coopHUD.RunInfo
---@field beth coopHUD.RunInfo
---@field t_beth coopHUD.RunInfo
---@field coins coopHUD.RunInfo
---@field poop coopHUD.RunInfo
---@field greed_waves coopHUD.RunInfo
---@field angel coopHUD.Stat
---@field devil coopHUD.Stat
---@field planetarium coopHUD.Stat
---@field no_achievements coopHUD.RunInfo
---@field font_color KColor
---@field destination coopHUD.Destination|nil
---@field hard_mode coopHUD.RunInfo|nil
---@type coopHUD.HUD
coopHUD.HUD = {}
coopHUD.HUD.fonts = {}
coopHUD.HUD.fonts.lua_mini = Font()
coopHUD.HUD.fonts.lua_mini:Load('font/luamini.fnt')
coopHUD.HUD.fonts.pft = Font()
coopHUD.HUD.fonts.pft:Load("font/pftempestasevencondensed.fnt")
coopHUD.HUD.fonts.lua_mini_lined = Font()
coopHUD.HUD.fonts.lua_mini_lined:Load("font/luaminioutlined.fnt")
coopHUD.HUD.fonts.team_meat_10 = Font()
coopHUD.HUD.fonts.team_meat_10:Load("font/teammeatfont10.fnt")
coopHUD.HUD.fonts.team_meat_12 = Font()
coopHUD.HUD.fonts.team_meat_12:Load("font/teammeatfont12.fnt")
coopHUD.HUD.fonts.upheaval = Font()
coopHUD.HUD.fonts.upheaval:Load("font/upheaval.fnt")
coopHUD.HUD.font_color = KColor(1, 1, 1, 1) -- holds hud font color
coopHUD.HUD.stat_anchor = Vector(0, 0)
function coopHUD.HUD.init()
    coopHUD.HUD.coins = coopHUD.RunInfo(coopHUD.RunInfo.COIN)
    coopHUD.HUD.bombs = coopHUD.RunInfo(coopHUD.RunInfo.BOMB)
    coopHUD.HUD.keys = coopHUD.RunInfo(coopHUD.RunInfo.KEY)
    coopHUD.HUD.beth = coopHUD.RunInfo(coopHUD.RunInfo.BETH)
    coopHUD.HUD.t_beth = coopHUD.RunInfo(coopHUD.RunInfo.T_BETH)
    coopHUD.HUD.poop = coopHUD.RunInfo(coopHUD.RunInfo.POOP)
    coopHUD.HUD.greed_waves = coopHUD.RunInfo(coopHUD.RunInfo.GREED_WAVES)
    -- Deals icons
    coopHUD.HUD.angel = coopHUD.Stat(coopHUD.HUD, coopHUD.Stat.ANGEL, true)
    coopHUD.HUD.devil = coopHUD.Stat(coopHUD.HUD, coopHUD.Stat.DEVIL, true)
    coopHUD.HUD.planetarium = coopHUD.Stat(coopHUD.HUD, coopHUD.Stat.PLANETARIUM, true)
    -- Run info specifics
    coopHUD.HUD.hard_mode = nil
    if Game().Difficulty == Difficulty.DIFFICULTY_HARD then
        coopHUD.HUD.hard_mode = coopHUD.RunInfo(coopHUD.RunInfo.HARD)
    end
    coopHUD.HUD.no_achievements = coopHUD.RunInfo(coopHUD.RunInfo.NO_ACHIEVEMENTS)
    --Destination if custom run and
    coopHUD.HUD.destination = nil
    if Game():GetSeeds():IsCustomRun() and Isaac.GetChallenge() > 0 then
        coopHUD.HUD.destination = coopHUD.Destination()
    end
    coopHUD.HUD.v_lap = coopHUD.RunInfo(coopHUD.RunInfo.V_LAP)
end
function coopHUD.HUD.render()
    if coopHUD.HUD.coins then
        local middle_bot_anchor = Vector((Isaac.GetScreenWidth() / 2), Isaac.GetScreenHeight() - 14) -- middle of screen
        local offset = Vector(0, 0)
        --
        local temp_pos = Vector(middle_bot_anchor.X, middle_bot_anchor.Y)
        temp_pos.X = temp_pos.X - coopHUD.HUD.coins:getOffset().X
        temp_pos.X = temp_pos.X - coopHUD.HUD.bombs:getOffset().X / 2
        temp_pos.X = temp_pos.X - coopHUD.HUD.poop:getOffset().X / 2
        temp_pos.X = temp_pos.X - coopHUD.HUD.beth:getOffset().X / 2
        temp_pos.X = temp_pos.X - coopHUD.HUD.t_beth:getOffset().X / 2
        offset = coopHUD.HUD.coins:render(temp_pos)
        temp_pos.X = temp_pos.X + offset.X
        offset = coopHUD.HUD.bombs:render(temp_pos)
        temp_pos.X = temp_pos.X + offset.X
        offset = coopHUD.HUD.poop:render(temp_pos)
        temp_pos.X = temp_pos.X + offset.X
        offset = coopHUD.HUD.keys:render(temp_pos)
        temp_pos.X = temp_pos.X + offset.X
        offset = coopHUD.HUD.beth:render(temp_pos)
        temp_pos.X = temp_pos.X + offset.X
        offset = coopHUD.HUD.t_beth:render(temp_pos)
        ------ DEALS RENDER
        if coopHUD.options.deals.show then
            if not (coopHUD.options.deals.hide_in_battle and coopHUD.signals.on_battle) then
                --when options.stats.hide_in_battle on and battle signal
                if coopHUD.options.deals.vanilla_position then
                    local deals_pos = Vector(coopHUD.HUD.stat_anchor.X, coopHUD.HUD.stat_anchor.Y)
                    coopHUD.HUD.font_color = coopHUD.players[1].font_color
                    coopHUD.HUD.devil:render(deals_pos, false, false)
                    deals_pos.Y = deals_pos.Y + 14
                    coopHUD.HUD.angel:render(deals_pos, false, false)
                    deals_pos.Y = deals_pos.Y + 14
                    if coopHUD.options.deals.show_planetarium then
                        coopHUD.HUD.planetarium:render(deals_pos, false, false)
                    end
                else
                    local deals_pos = Vector(middle_bot_anchor.X, middle_bot_anchor.Y + 4)
                    coopHUD.HUD.font_color = KColor(1, 1, 1, 1)
                    deals_pos.X = deals_pos.X - coopHUD.HUD.angel:getOffset().X
                    if not coopHUD.options.deals.show_planetarium then
                        deals_pos.X = deals_pos.X + coopHUD.HUD.angel:getOffset().X / 2
                    end
                    deals_pos.X = deals_pos.X - coopHUD.HUD.devil:getOffset().X / 2
                    -- ANGEL
                    coopHUD.HUD.angel:render(deals_pos, false, true)
                    -- DEVIL
                    off = coopHUD.HUD.devil:render(Vector(deals_pos.X + coopHUD.HUD.angel:getOffset().X, deals_pos.Y),
                            false, true)
                    --PLANETARIUM
                    if coopHUD.options.deals.show_planetarium then
                        coopHUD.HUD.planetarium:render(Vector(deals_pos.X + coopHUD.HUD.angel:getOffset().X + coopHUD.HUD.devil:getOffset().X,
                                deals_pos.Y),
                                false, true)
                    end
                end
            end
        end
        ------ TIMER RENDER
        -- FIX: on extended map and big right player timer is over rendered
        -- Code from TBoI Api by wofsauge
        local timer_offset = Vector(1, 1)
        local curTime = Game():GetFrameCount()
        local msecs = curTime % 30 * (10 / 3) -- turns the millisecond value range from [0 to 30] to [0 to 100]
        local secs = math.floor(curTime / 30) % 60
        local mins = math.floor(curTime / 30 / 60) % 60
        local hours = math.floor(curTime / 30 / 60 / 60) % 60
        --
        local time_string = string.format('Time: %.2i:%.2i:%.2i', hours, mins, secs) -- formats
        local f_col = KColor(0.5, 0.5, 0.5, 1) -- Default font color font color with 0.5 alpha
        if coopHUD.options.timer_always_on or coopHUD.signals.map then
            coopHUD.HUD.fonts.pft:DrawStringScaled(time_string,
                    middle_bot_anchor.X, 0,
                    1, 1,
                    f_col, 1, true)
            timer_offset.Y = coopHUD.HUD.fonts.upheaval:GetBaselineHeight()
            if coopHUD.options.show_run_info then
                -- Renders hard mode indicator
                if coopHUD.HUD.hard_mode then
                    temp_pos = Vector(middle_bot_anchor.X - coopHUD.HUD.fonts.pft:GetStringWidth(time_string) / 2 - 16, 2)
                    if coopHUD:IsNoAchievementRun() then
                        temp_pos.X = temp_pos.X - 16
                    end
                    coopHUD.HUD.hard_mode:render(temp_pos)
                end
                -- Renders no achievement lock
                if coopHUD:IsNoAchievementRun() then
                    coopHUD.HUD.no_achievements:render(Vector(middle_bot_anchor.X - coopHUD.HUD.fonts.pft:GetStringWidth(time_string) / 2 - 16, 2))
                end
                -- Renders destination in challenges
                if coopHUD.HUD.destination then
                    coopHUD.HUD.destination:render(Vector(middle_bot_anchor.X + coopHUD.HUD.fonts.pft:GetStringWidth(time_string) / 2 + 2, 2))
                end
                -- Renders Victory Lap indicator
                if Game():GetVictoryLap() > 0 then
                    coopHUD.HUD.v_lap:render(Vector(middle_bot_anchor.X + coopHUD.HUD.fonts.pft:GetStringWidth(time_string) / 2 + 2, 2))
                end
            end
        end
        if Game().Difficulty == Difficulty.DIFFICULTY_GREED or Game().Difficulty == Difficulty.DIFFICULTY_GREEDIER then
            coopHUD.HUD.greed_waves:render(Vector(middle_bot_anchor.X - coopHUD.HUD.greed_waves:getOffset().X / 2, 0 + timer_offset.Y))
        end
        ---STREAK RENDER
        if not coopHUD.signals.on_battle then
            coopHUD.Streak:render()
        end
    end
end