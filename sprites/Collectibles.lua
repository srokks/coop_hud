--- triggers collectibles to show
--- sets coopHUD.Collectibles.item_table to proper player table
--- resets animation and plays it
---@class coopHUD.Collectibles
------@param Player coopHUD.Player
---@type fun(Player:coopHUD.Player):void
coopHUD.Collectibles = {}
setmetatable(coopHUD.Collectibles, {
	__call = function(cls, ...)
		return cls.trigger(...)
	end,
})
coopHUD.Collectibles.sprite = Sprite() -- holds background of page for collectibles
coopHUD.Collectibles.sprite:Load(coopHUD.GLOBALS.pause_screen_anim_path, true)
coopHUD.Collectibles.sprite:SetFrame('Dissapear', 13) -- sets to last frame to not trigger on run
--- holds items for collectibles page, resets on collectibles page animation end
---@type coopHUD.Item[]
coopHUD.Collectibles.item_table = {}
coopHUD.Collectibles.mirrored = false -- if mirrored stuff page anchors near right side else on left
coopHUD.Collectibles.signal = false
coopHUD.Collectibles.color = Color(1, 1, 1)
--- Renders collectibles page
function coopHUD.Collectibles.render()
	local sprite_pos = Vector(Isaac.GetScreenWidth() / 2 + 60, Isaac.GetScreenHeight() / 2 - 30)
	if coopHUD.Collectibles.mirrored then
		sprite_pos.X = Isaac.GetScreenWidth() + 30
	end
	if coopHUD.Collectibles.sprite:GetFrame() > 11 and coopHUD.Collectibles.signal then
		if coopHUD.Collectibles.signal + 15 < Game():GetFrameCount() then
			coopHUD.Collectibles.signal = false -- resets signals and lets continue to render sprite
			coopHUD.Collectibles.sprite:Play('Dissapear', 0)
		end
	else
		coopHUD.Collectibles.sprite:Update() -- update sprite frame
	end
	if coopHUD.Collectibles.sprite:IsPlaying('Dissapear') then
		coopHUD.Collectibles.sprite:Update()
	end
	coopHUD.Collectibles.sprite:Update() -- update sprite frame

	coopHUD.Collectibles.sprite:RenderLayer(3, sprite_pos)
	-- collectibles table render
	local item_pos = Vector(0 + 76, Isaac.GetScreenHeight() / 2 - 32)
	if coopHUD.Collectibles.mirrored then
		item_pos.X = Isaac.GetScreenWidth() - 194
	end
	local temp_counter = 1
	local collectibles_stop = 1
	if #coopHUD.Collectibles.item_table > 136 then
		collectibles_stop = #coopHUD.Collectibles.item_table - 135
	end
	for i = #coopHUD.Collectibles.item_table, collectibles_stop, -1 do
		local scale = Vector(1, 1)
		local rows_no = 5
		if #coopHUD.Collectibles.item_table > 10 then
			scale = Vector(0.7, 0.7)
			rows_no = 7
		end
		if #coopHUD.Collectibles.item_table > 20 then
			scale = Vector(0.6, 0.6)
			rows_no = 8
		end
		if #coopHUD.Collectibles.item_table > 32 then
			scale = Vector(0.5, 0.5)
			rows_no = 10
		end
		if #coopHUD.Collectibles.item_table > 42 then
			scale = Vector(0.5, 0.5)
			rows_no = 10
		end
		if #coopHUD.Collectibles.item_table > 50 then
			scale = Vector(0.4, 0.4)
			rows_no = 13
		end
		if #coopHUD.Collectibles.item_table > 78 then
			scale = Vector(0.3, 0.3)
			rows_no = 17
		end
		local off = coopHUD.Collectibles.item_table[i]:render(item_pos, false, scale, false)
		item_pos.X = item_pos.X + off.X / 1.5
		if temp_counter % rows_no == 0 then
			item_pos.Y = item_pos.Y + off.Y
			item_pos.X = 0 + 72
			if coopHUD.Collectibles.mirrored then
				item_pos.X = Isaac.GetScreenWidth() - 194
			end
		end
		temp_counter = temp_counter + 1
	end
	if coopHUD.Collectibles.sprite:IsPlaying('Dissapear') then coopHUD.Collectibles.item_table = {} end
	--
end
---@private
---@see coopHUD.Collectibles
function coopHUD.Collectibles.trigger(Player)
	coopHUD.Collectibles.signal = Game():GetFrameCount() -- sets streak signal as current frame num
	if coopHUD.Collectibles.sprite:IsFinished('Dissapear') then
		-- if Collectibles is finished play animation
		coopHUD.Collectibles.sprite.Color = Color(Player.font_color.Red, Player.font_color.Green,
		                                          Player.font_color.Blue)
		coopHUD.Collectibles.mirrored = coopHUD.players_config.small[Player.game_index].mirrored
		for i = 1, #Player.gulped_trinkets do
			table.insert(coopHUD.Collectibles.item_table, Player.gulped_trinkets[i])
		end
		for i = 1, #Player.collectibles do
			table.insert(coopHUD.Collectibles.item_table, Player.collectibles[i])
		end
		coopHUD.Collectibles.sprite:Play("Appear", true)
	end
end