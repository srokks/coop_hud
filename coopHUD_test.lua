coopHUD.test_str = 'test'
coopHUD.signals.is_joining = true
function coopHUD:dumpPLayerTables()
    local json = require("json")
    local file_name = 'players_dump_'..os.date("%Y%m%d%H%M%S")..'.json'
    local file = io.open("data/coop_hud/"..file_name,'w')
    file:write(json.encode(coopHUD.players))
    file:close()
    print("Dumped player table into file data/coop_hud/"..file_name)
end
coopHUD.on_player_init()
function  coopHUD.test_render()
    if Input.IsButtonTriggered(Keyboard.KEY_I,0)  then
        -- DEBUG - print table
        print('DEBUG "i"')
        for i,p in pairs(coopHUD.players) do
            print('i','game index','contr')
            print(i,p.game_index,p.controller_index)
        end
    end
    -- Dump logic when pressed 'I' while holding 'P"
    if Input.IsButtonTriggered(Keyboard.KEY_I,0)  then
        if Input.IsButtonPressed(Keyboard.KEY_P,0)  then
            coopHUD:dumpPLayerTables()
        end
    end
    
    local tem_player = Isaac.GetPlayer(0)
    local stats = coopHUD.players[0]
    coopHUD.renderStatsIcons(Vector(100,70),false)
    coopHUD.renderStats(coopHUD.players[0],Vector(100,68),false,KColor(1,1,1,0))
    --coopHUD.renderStats(coopHUD.players[0],Vector(0,74),false,KColor(0,0.5,1,0))
    --coopHUD.renderStats(coopHUD.players[0],Vector(20,70),false,KColor(1,0,0,0))
    --f:DrawStringScaled(stats.speed,32,75,0.6,0.6,KColor(1,1,1,0.5),0,true)
    
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.test_render)

-- _____
function coopHUD.renderStatsIcons(pos,mirrored)
    local temp_pos = Vector(pos.X,pos.Y)
    -- Move speed
    stat_sprite.speed:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Tear delay
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    stat_sprite.tears_delay:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Damage
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    stat_sprite.damage:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Range
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    stat_sprite.range:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Shoot speed
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    stat_sprite.shot_speed:Render(Vector(temp_pos.X,temp_pos.Y))
    -- Luck
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    stat_sprite.luck:Render(Vector(temp_pos.X,temp_pos.Y))
end
-- _____
function coopHUD.renderStats(player,pos,mirrored,color)
    local temp_pos = Vector(pos.X,pos.Y)
    local font_color = KColor(color.Red,color.Green,color.Blue,0.5)
    local dif_color = KColor(1,1,1,0.5)
    local f = Font()
    f:Load("font/luamini.fnt")
    -- Move speed
    f:DrawString(string.format("%.2f",player.stats.speed[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    if player.stats.speed[2] ~= 0 then
        if coopHUD.renderStatChange(temp_pos,player.stats.speed[2]) then
            player.stats.speed[2] = 0
        end
    end
    -- Tear delay
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.tears_delay[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    if player.stats.tears_delay[2] ~= 0 then
        if coopHUD.renderStatChange(temp_pos,player.stats.tears_delay[2]) then
            player.stats.tears_delay[2] = 0
        end
    end
    -- Damage
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.damage[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    if coopHUD.renderStatChange(temp_pos,player.stats.damage[2]) then
        player.stats.damage[2] = 0
    end
    -- Range
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.range[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    if player.stats.range[2] ~= 0 then
        if coopHUD.renderStatChange(temp_pos,player.stats.range[2]) then
            player.stats.range[2] = 0
        end
    end
    -- Shoot speed
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.shot_speed[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    if player.stats.shot_speed[2] ~= 0 then
        if coopHUD.renderStatChange(temp_pos,player.stats.shot_speed[2]) then
            player.stats.shot_speed[2] = 0
        end
    end
    -- Luck
    temp_pos = Vector(temp_pos.X,temp_pos.Y+12)
    f:DrawString(string.format("%.2f",player.stats.luck[1]),temp_pos.X+16,temp_pos.Y,font_color,0,true)
    if player.stats.luck[2] ~= 0 then
        if coopHUD.renderStatChange(temp_pos,player.stats.luck[2]) then
            player.stats.luck[2] = 0
        end
    end
    
end
-- _____
local stat_counter = 0
function coopHUD.renderStatChange(pos,stat)
    local f = Font()
    f:Load("font/luamini.fnt")
    --stat_counter = Game():GetFrameCount()
    -- renders stat change
    local dif_string = string.format('%.2f',stat)
    if stat ~= 0 then
        --if stat_counter > 500 then stat_counter = 0 end
        f:DrawString(tostring(stat_counter),100,100,KColor(1,1,1,1),0,true)
        if stat > 0 then
            dif_color = KColor(0,1,0,0.5)
            dif_string = '+'..dif_string
        else
            dif_color = KColor(1,0,0,0.5)
        end
        if stat_counter > 500 then
            stat_counter = 0
            print('kaka')
            return true
        else
            stat_counter = stat_counter + 1
        end
        f:DrawString(dif_string,pos.X+38,pos.Y,dif_color,0,true)
        --print('dif'..tostring(stat),Game():GetFrameCount())
        --return true
    else
        stat_counter = 0
        return false
    end
end
-- _____
coopHUD.initHudTables()