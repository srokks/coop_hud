-- Overrides External item description mod setting to better fit with HUD
if EID then
	if EID.UserConfig.YPosition < 80 then
		EID.UserConfig.YPosition = 80
	end
	if EID.UserConfig.TextboxWidth < 150 then
		EID.UserConfig.TextboxWidth = 150
	end
	if EID.UserConfig.LineHeight > 9 then
		EID.UserConfig.LineHeight = 9
	end
end
-- Overrides Enhanced Boss Bars  mod setting to better fit with HUD
if HPBars and HPBars.UserConfig then
	if HPBars.UserConfig.ScreenPadding <= 33 then
		HPBars.UserConfig.ScreenPadding = 33
	end
end
-- Overrides MinimapAPI  mod setting to show on coopHUD
if MinimapAPI then
	if not MinimapAPI.Config.DisplayOnNoHUD then
		MinimapAPI.Config.DisplayOnNoHUD = true
	end
	if MinimapAPI:GetConfig('ShowLevelFlags') then
		MinimapAPI.Config.ShowLevelFlags = false
	end
	if MinimapAPI:GetConfig('DisplayOnNoHUD') then
		MinimapAPI.Config.DisplayOnNoHUD = true
	end
end
