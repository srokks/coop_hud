coopHUD.test_str = 'test'
coopHUD.signals.is_joining = true
coopHUD.on_player_init()
function  coopHUD.test_render()
    if Input.IsButtonTriggered(Keyboard.KEY_I,0)  then
        -- DEBUG - print table
        print('DEBUG "i"')
        for i,p in pairs(coopHUD.players) do
            print(p.twin.first_pocket[1])
            for j,k in pairs(p.twin) do
                --print(k.first_pocket)
            end
        end
    end
    local f = Font()
    f:Load("font/pftempestasevencondensed.fnt")
    
    --f:DrawString(coopHUD.test_str,100,100,KColor(1,1,1,1),0,true)
end
coopHUD:AddCallback(ModCallbacks.MC_POST_RENDER, coopHUD.test_render)
--
coopHUD.initHudTables()
coopHUD.essau_no = 0