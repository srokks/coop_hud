local xml_data = include('helpers.eid_xmldata.lua')
function coopHUD.getMinimapOffset()
	local minimap_offset = Vector(Isaac.GetScreenWidth(), 0)
	if MinimapAPI ~= nil then
		-- Modified function from minimAPI by Wolfsauge
		local screen_size = Vector(Isaac.GetScreenWidth(), 0)
		local is_large = MinimapAPI:IsLarge()
		if not is_large and MinimapAPI:GetConfig("DisplayMode") == 2 then
			-- BOUNDED MAP
			minimap_offset = Vector(screen_size.X - MinimapAPI:GetConfig("MapFrameWidth") - MinimapAPI:GetConfig("PositionX") - 4,
					2)
		elseif not is_large and MinimapAPI:GetConfig("DisplayMode") == 4
				or Game():GetLevel():GetCurses() == LevelCurse.CURSE_OF_THE_LOST then
			-- NO MAP or cure of the lost active
			minimap_offset = Vector(screen_size.X - 4, 2)
		else
			-- LARGE
			local minx = screen_size.X
			for i, v in ipairs(MinimapAPI:GetLevel()) do
				if v ~= nil then
					if v:GetDisplayFlags() > 0 then
						if v.RenderOffset ~= nil then
							minx = math.min(minx, v.RenderOffset.X)
						end
					end
				end

			end
			minimap_offset = Vector(minx - 4, 2) -- Small
		end
		if MinimapAPI:GetConfig("Disable") or MinimapAPI.Disable then
			minimap_offset = Vector(screen_size.X - 4,
					2) end
		local r = MinimapAPI:GetCurrentRoom()
		if r ~= nil then
			if MinimapAPI:GetConfig("HideInCombat") == 2 then
				if not r:IsClear() and r:GetType() == RoomType.ROOM_BOSS then
					minimap_offset = Vector(screen_size.X - 0, 2)
				end
			elseif MinimapAPI:GetConfig("HideInCombat") == 3 then
				if r ~= nil then
					if not r:IsClear() then
						minimap_offset = Vector(screen_size.X - 0, 2)
					end
				end
			end
		end
	end
	return minimap_offset
end
function coopHUD.updateAnchors()
	local offset = 0
	if SHExists then
		offset = ScreenHelper.GetOffset()
	end
	offset = offset + Options.HUDOffset * 10
	if coopHUD.anchors.top_left ~= Vector.Zero + Vector(offset * 2, offset * 1.2) then
		coopHUD.anchors.top_left = Vector.Zero + Vector(offset * 2, offset * 1.2)
	end
	if coopHUD.anchors.bot_left ~= Vector(0, Isaac.GetScreenHeight()) + Vector(offset * 2.2, -offset * 1.6) then
		coopHUD.anchors.bot_left = Vector(0, Isaac.GetScreenHeight()) + Vector(offset * 2.2, -offset * 1.6)
	end
	if coopHUD.anchors.top_right ~= Vector(coopHUD.getMinimapOffset().X, 0) + Vector(-offset * 2.2,
			offset * 1.2) then
		coopHUD.anchors.top_right = Vector(coopHUD.getMinimapOffset().X, 0) + Vector(-offset * 2.2, offset * 1.2)
	end
	if coopHUD.anchors.bot_right ~= Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()) + Vector(-offset * 2.2,
			-offset * 1.6) then
		coopHUD.anchors.bot_right = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()) + Vector(-offset * 2.2,
				-offset * 1.6)
	end
end
coopHUD.itemUnlockStates = {} -- holds cache for already unlocked items TODO:reset on seed change
--- Checks if any player has a given collectible ID, if has return also EntityPlayer
---Function from External Item Descriptions mod by Wolfsauge - https://steamcommunity.com/sharedfiles/filedetails/?id=83631987
---@author Wolfsauge
---@param collectibleID number
---@return boolean|boolean,EntityPlayer
function coopHUD.PlayersHaveCollectible(collectibleID)
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(collectibleID) then
			return true, player
		end
	end
	return false
end
---Returns max collectible count
---Uses checks last not nil ItemConfig.Collectible
---Function from External Item Descriptions mod by Wolfsauge - https://steamcommunity.com/sharedfiles/filedetails/?id=83631987
---@author Wolfsauge
function coopHUD.GetMaxCollectibleID()
	local id = CollectibleType.NUM_COLLECTIBLES - 1
	local step = 16
	while step > 0 do
		if Isaac.GetItemConfig():GetCollectible(id + step) ~= nil then
			id = id + step
		else
			step = step // 2
		end
	end
	return id
end
local maxCollectibleID = nil -- initiated when first call of coopHUD.isCollectibleUnlockedAnyPool
function coopHUD.isCollectibleUnlocked(collectibleID, itemPoolOfItem)
	local itemPool = Game():GetItemPool()
	if maxCollectibleID == nil then
		maxCollectibleID = coopHUD.GetMaxCollectibleID()
	end
	for i = 1, maxCollectibleID do
		if ItemConfig.Config.IsValidCollectible(i) and i ~= collectibleID then
			itemPool:AddRoomBlacklist(i)
		end
	end
	local isUnlocked = false
	for i = 0, 1 do
		-- some samples to make sure
		local collID = itemPool:GetCollectible(itemPoolOfItem, false, 1)
		if collID == collectibleID then
			isUnlocked = true
			break
		end
	end
	itemPool:ResetRoomBlacklist()
	return isUnlocked
end
---Return if item is unlocked by any pool
---Function from External Item Descriptions mod by Wolfsauge - https://steamcommunity.com/sharedfiles/filedetails/?id=83631987
---@author Wolfsauge
function coopHUD.isCollectibleUnlockedAnyPool(collectibleID)
	--THIS FUNCTION IS FOR REPENTANCE ONLY due to using Repentance XML data
	--Currently used by the Achievement Check, Spindown Dice, and Bag of Crafting
	if coopHUD.PlayersHaveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER) then
		return true
	end
	local item = Isaac.GetItemConfig():GetCollectible(collectibleID)
	if item == nil then
		return false
	end
	if coopHUD.itemUnlockStates[collectibleID] == nil then
		--whitelist all quest items and items with no associated achievement
		if item.AchievementID == -1 or (item.Tags and item.Tags & ItemConfig.TAG_QUEST == ItemConfig.TAG_QUEST) then
			coopHUD.itemUnlockStates[collectibleID] = true
			return true
		end
		--blacklist all hidden items
		if item.Hidden then
			coopHUD.itemUnlockStates[collectibleID] = false
			return false
		end
		--iterate through the pools this item can be in
		for _, itemPoolID in ipairs(xml_data.XMLItemIsInPools[collectibleID]) do
			if (itemPoolID < ItemPoolType.NUM_ITEMPOOLS and coopHUD.isCollectibleUnlocked(collectibleID,
					itemPoolID)) then
				coopHUD.itemUnlockStates[collectibleID] = true
				return true
			end
		end
		--note: some items will still be missed by this, if they've been taken out of their pools (especially when in Greed Mode)
		coopHUD.itemUnlockStates[collectibleID] = false
		return false
	else
		return coopHUD.itemUnlockStates[collectibleID]
	end
end