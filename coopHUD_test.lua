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
        if Input.IsButtonPressed(Keyboard.KEY_P,0)  then
        
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
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.test_render)
--
coopHUD.initHudTables()