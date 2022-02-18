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
    local f = Font()
    f:Load("font/pftempestasevencondensed.fnt")
    --f:DrawString(coopHUD.test_str,100,100,KColor(1,1,1,1),0,true)
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