-- Sprites get function
function coopHUD.getActiveItemSprite(player, slot)
	local overlay = ''
	local active_item = player:GetActiveItem(slot)
	if active_item == 0 or player.Variant == 1 then return false end
	local this_sprite = Sprite() -- replaced
	this_sprite:Load(coopHUD.GLOBALS.item_anim_path, true)
	local item_sprite = Isaac.GetItemConfig():GetCollectible(active_item).GfxFileName
	-- Custom sprites set - jars etc.
	if active_item == CollectibleType.COLLECTIBLE_THE_JAR then
		-- the jar
		item_sprite = "gfx/characters/costumes/costume_rebirth_90_thejar.png"
	elseif active_item == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then
		-- jar of flies
		item_sprite = "gfx/characters/costumes/costume_434_jarofflies.png"
	elseif active_item == CollectibleType.COLLECTIBLE_JAR_OF_WISPS then
		-- jar of wisp
		item_sprite = "gfx/ui/hud_jarofwisps.png"
	elseif active_item == CollectibleType.COLLECTIBLE_EVERYTHING_JAR then
		-- everything jar
		item_sprite = "gfx/ui/hud_everythingjar.png"
	elseif active_item == CollectibleType.COLLECTIBLE_FLIP and player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
		-- Fixme: Flip weird sprite (too much white :D) when lazarus b
		item_sprite = 'gfx/ui/ui_flip_coop.png'
		this_sprite:ReplaceSpritesheet(0, item_sprite)
		this_sprite:ReplaceSpritesheet(1, item_sprite)
		this_sprite:ReplaceSpritesheet(2, item_sprite)
	end
	-- Urn of Souls - sprite set
	if active_item == CollectibleType.COLLECTIBLE_URN_OF_SOULS then
		item_sprite = "gfx/ui/hud_urnofsouls.png"
	end
	this_sprite:ReplaceSpritesheet(0, item_sprite) -- item
	this_sprite:ReplaceSpritesheet(1, item_sprite) -- border
	this_sprite:ReplaceSpritesheet(2, item_sprite) -- shadow

	-- Sets overlay/charges state frame --
	local item_charge = Isaac.GetItemConfig():GetCollectible(active_item).MaxCharges -- gets max charges
	if item_charge == 0 then
		-- checks id item has any charges
		this_sprite:SetFrame("Idle", 0) -- set frame to unloaded
	elseif player:NeedsCharge(slot) == false or player:GetActiveCharge(slot) >= item_charge then
		-- checks if item dont needs charges or item is overloaded
		this_sprite:SetFrame("Idle", 1) -- set frame to loaded
	else
		this_sprite:SetFrame("Idle", 0) -- set frame to unloaded
	end
	--The Jar/Jar of Flies - charges check
	if active_item == CollectibleType.COLLECTIBLE_THE_JAR or active_item == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then
		--
		local frame = 0
		if active_item == CollectibleType.COLLECTIBLE_THE_JAR then frame = math.ceil(player:GetJarHearts() / 2) end -- gets no of hearts in jar
		if active_item == CollectibleType.COLLECTIBLE_JAR_OF_FLIES then frame = player:GetJarFlies() end --gets no of flies in jar of flies
		this_sprite:SetFrame("Jar", frame)
	end
	-- Hold - charge set
	if active_item == CollectibleType.COLLECTIBLE_HOLD then
		-- SKELETON
		this_sprite:ReplaceSpritesheet(3, 'gfx/ui/ui_poops.png')
		local hold_spell = 0
		if coopHUD.players[coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)] and
				-- prevents from error when not everything loaded
				coopHUD.players[coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)].hold_spell then
			hold_spell = coopHUD.players[coopHUD.getPlayerNumByControllerIndex(player.ControllerIndex)].hold_spell
		end
		this_sprite:SetFrame('Hold', hold_spell)
	end
	-- Everything Jar - charges set
	if active_item == CollectibleType.COLLECTIBLE_EVERYTHING_JAR then
		fi_charge = player:GetActiveCharge()
		this_sprite:SetFrame("EverythingJar", fi_charge + 1)
	end
	-- Jar of wisp - charges set
	if active_item == CollectibleType.COLLECTIBLE_JAR_OF_WISPS and coopHUD.jar_of_wisp_charge ~= nil then
		local wisp_charge = 0
		if item_charge == 0 then
			-- checks id item has any charges
			wisp_charge = 0 -- set frame to unloaded
		elseif player:NeedsCharge(slot) == false or player:GetActiveCharge(slot) >= item_charge then
			-- checks if item dont needs charges or item is overloaded
			wisp_charge = 15 -- set frame to loaded
		else
			wisp_charge = 0 -- set frame to unloaded
		end
		this_sprite:SetFrame('WispJar', coopHUD.jar_of_wisp_charge + wisp_charge) -- sets proper frame
	end
	-- Urn of soul
	-- For this moment can only show when urn is open/closed no api function
	-- FIXME: Urn of soul charge: wait till api is fixed
	if active_item == CollectibleType.COLLECTIBLE_URN_OF_SOULS then
		-- sets frame
		local tempEffects = player:GetEffects()
		local urn_state = tempEffects:GetCollectibleEffectNum(640) -- gets effect of item 0-closed urn/1- opened
		local state = 0  -- closed urn frame no
		if urn_state ~= 0 then
			-- checks if urn is open
			state = 22 -- opened urn frame no
		end
		this_sprite:SetFrame("SoulUrn", state)
	end
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) or player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		-- checks if player has virtuoses or birthright
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and active_item ~= CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES then
			-- sets virtuoses sprite
			item_sprite = 'gfx/ui/hud_bookofvirtues.png'
			this_sprite:ReplaceSpritesheet(3, item_sprite)
			this_sprite:ReplaceSpritesheet(4, item_sprite)

		end
		if player:GetPlayerType() == PlayerType.PLAYER_JUDAS and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			-- if judas and has birthrignt
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and active_item ~= CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES then
				item_sprite = 'gfx/ui/hud_bookofvirtueswithbelial.png' -- sets virt/belial sprite
				this_sprite:ReplaceSpritesheet(3, item_sprite)
				this_sprite:ReplaceSpritesheet(4, item_sprite)
			else
				item_sprite = 'gfx/ui/hud_bookofbelial.png' -- sets belial sprite
				this_sprite:ReplaceSpritesheet(3, item_sprite)
				this_sprite:ReplaceSpritesheet(4, item_sprite)
			end
		end
	end
	this_sprite:LoadGraphics()

	return this_sprite
end
function coopHUD.getChargeSprites(player, slot)
	-- Gets charge of item from  player, slot
	local sprites = {
		beth_charge = Sprite(),
		charge      = Sprite(),
		overlay     = Sprite(),
	}
	local active_item = player:GetActiveItem(slot)
	if active_item == 0 or player.Variant == 1 then return false end
	local item_charge = Isaac.GetItemConfig():GetCollectible(active_item).MaxCharges
	if item_charge == 0 then return false end
	-- Normal and battery charge
	local charges = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
	local step = math.floor((charges / (item_charge * 2)) * 46)
	sprites.charge:Load(coopHUD.GLOBALS.charge_anim_path, true)
	sprites.charge:SetFrame('ChargeBar', step)
	-- Overlay sprite
	sprites.overlay:Load(coopHUD.GLOBALS.charge_anim_path, true)
	if (item_charge > 1 and item_charge < 5) or item_charge == 6 or item_charge == 12 then
		sprites.overlay:SetFrame("BarOverlay" .. item_charge, 0)
	else
		sprites.overlay:SetFrame("BarOverlay1", 0)
	end
	-- Bethany charge
	local player_type = player:GetPlayerType()
	if player_type == 18 or player_type == 36 then
		local beth_charge
		local color = Color(1, 1, 1, 1, 0, 0, 0)
		if player_type == 18 then
			beth_charge = player:GetEffectiveSoulCharge()
			color:SetColorize(0.8, 0.9, 1.8, 1)
		elseif player_type == 36 then
			beth_charge = player:GetEffectiveBloodCharge()
			color:SetColorize(1, 0.2, 0.2, 1)
		end
		sprites.beth_charge:Load(coopHUD.GLOBALS.charge_anim_path, true)
		sprites.beth_charge.Color = color
		step = step + math.floor((beth_charge / (item_charge * 2)) * 46) + 1
		sprites.beth_charge:SetFrame('ChargeBar', step)
	else
		sprites.beth_charge = false
	end
	return sprites
end
function coopHUD.getTrinketSprite(player, trinket_pos)
	local trinket_id = player:GetTrinket(trinket_pos)
	if trinket_id == 0 or player.Variant == 1 then return false end
	local sprite = Sprite()
	sprite:Load(coopHUD.GLOBALS.item_anim_path, true)
	local item_sprite = Isaac.GetItemConfig():GetTrinket(trinket_id).GfxFileName
	sprite:ReplaceSpritesheet(0, item_sprite) -- item layer
	sprite:ReplaceSpritesheet(2, item_sprite) -- shadow layer
	sprite:LoadGraphics()
	sprite:SetFrame("Idle", 0)
	return sprite
end
function coopHUD.getPocketItemSprite(player, slot)
	-- cards/runes/
	local pocket_sprite = Sprite()
	local pocket = coopHUD.getPocketID(player, slot)
	local pocket_type = pocket[2]
	local pocket_id = pocket[1]
	if pocket_type == 1 then
		-- Card
		pocket_sprite:Load(coopHUD.GLOBALS.card_anim_path, true)
		pocket_sprite:SetFrame("CardFronts", pocket_id) -- sets card frame
	elseif pocket_type == 2 then
		-- Pill
		if pocket_id > 2048 then pocket_id = pocket_id - 2048 end -- check if its horse pill and change id to normal
		pocket_sprite:Load(coopHUD.GLOBALS.pill_anim_path, true)
		pocket_sprite:SetFrame("Pills", pocket_id) --sets frame to pills with correct id
		return pocket_sprite
	elseif pocket_type == 3 then
		pocket_sprite = coopHUD.getActiveItemSprite(player, 2)
	else
		pocket_sprite = false
	end
	return pocket_sprite
end
function coopHUD.getHeartSprite(heart_type, overlay)
	if heart_type ~= 'None' then
		local sprite = Sprite()
		sprite:Load(coopHUD.GLOBALS.hearts_anim_path, true)
		sprite:SetFrame(heart_type, 0)
		if overlay ~= 'None' then
			if overlay ~= 'GoldWhiteOverlay' then
				sprite:SetOverlayFrame(overlay, 0)
			else
				sprite:ReplaceSpritesheet(0, "gfx/ui/ui_hearts_gold_coop.png") -- replaces png file to get
				sprite:SetOverlayFrame('WhiteHeartOverlay', 0)
				sprite:LoadGraphics()
			end

		end
		return sprite
	else
		return False
	end
end
function coopHUD.getHeartSpriteTable(player)
	local max_health_cap = 12
	local heart_type, overlay = ''
	local heart_sprites = {}
	-- Sets increased heatlh cap when playing Maggy with Birthright
	if player:GetPlayerType() == PlayerType.PLAYER_MAGDALENA and -- checks if player is Maggy
			player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		max_health_cap = 18
	end
	for counter = 0, max_health_cap, 1 do
		heart_type, overlay = coopHUD.getHeartType(player, counter)
		heart_sprites[counter] = coopHUD.getHeartSprite(heart_type, overlay)
	end
	return heart_sprites
end
function coopHUD.getPoopSprite(player, i)
	local spell_type
	local layer_name = 'IdleSmall'
	spell_type = player:GetPoopSpell(i)
	if i == 0 then layer_name = 'Idle' end
	if spell_type ~= 0 then
		local sprite = Sprite()
		sprite:Load(coopHUD.GLOBALS.poop_anim_path, true)
		sprite:SetFrame(layer_name, spell_type)
		if i >= player:GetPoopMana() then
			local col = Color(1, 1, 1, 1)
			col:SetColorize(1, 1, 1, 1)
			sprite.Color = Color(0.3, 0.3, 0.3, 0.3)
		end
		return sprite
	else
		return nil
	end
end
function coopHUD.getPoopSpriteTable(player)
	local poop_table = {}
	for i = 0, PoopSpellType.SPELL_QUEUE_SIZE - 1, 1 do
		poop_table[i] = coopHUD.getPoopSprite(player, i)
	end
	return poop_table
end
function coopHUD.getPlayerHeadSprite(player)
	local player_type = player:GetPlayerType()
	if player.Variant == 1 then return nil end -- prevents when old coop ghost
	if player_type == 40 then player_type = 36 end
	if 0 <= player_type and player_type <= 37 then
		local sprite = Sprite()
		sprite:Load(coopHUD.GLOBALS.player_head_anim_path, true)
		sprite:SetFrame('Main', player_type + 1)
		sprite:ReplaceSpritesheet(1, "/gfx/ui/blank.png")
		sprite:LoadGraphics()
		return sprite
	else
		return nil
	end
end
function coopHUD.getHUDSprites()
	local player = Isaac.GetPlayer(0)
	--Items font
	local item_font = Font()
	item_font:Load("font/pftempestasevencondensed.fnt")
	--
	local timer_font = Font()
	timer_font:Load("font/teammeatfont10.fnt")
	--
	local streak_sec_line_font = Font()
	streak_sec_line_font:Load("font/teammeatfont10.fnt")
	-- Coin sprite
	local coin_sprite = Sprite()
	coin_sprite:Load(coopHUD.GLOBALS.hud_el_anim_path, true)
	coin_sprite:SetFrame('Idle', 0)
	-- Bomb sprite
	-- TODO: T.??? PoopSpell integration
	local bomb_sprite = Sprite()
	bomb_sprite:Load(coopHUD.GLOBALS.hud_el_anim_path, true)
	bomb_sprite:SetFrame('Idle', 2)
	if player and player:HasGoldenBomb() then bomb_sprite:SetFrame('Idle', 6) end
	if player and player:GetNumGigaBombs() > 0 then
		bomb_sprite:SetFrame('Idle', 14)
		if player and player:HasGoldenBomb() then
			-- TODO: giga golden bomb
		end
	end
	-- Key sprite
	local key_sprite = Sprite()
	key_sprite:Load(coopHUD.GLOBALS.hud_el_anim_path, true)
	key_sprite:SetFrame('Idle', 1)
	if player and player:HasGoldenKey() then key_sprite:SetFrame('Idle', 3) end
	-- my_stuff_sprite
	local my_stuff_sprite = Sprite()
	my_stuff_sprite:Load(coopHUD.GLOBALS.pause_screen_anim_path, true)
	my_stuff_sprite:SetFrame('Idle', 0)
	--
	return { ['item_font']            = item_font,
	         ['timer_font']           = timer_font,
	         ['streak_sec_line_font'] = streak_sec_line_font,
	         ['coin_sprite']          = coin_sprite,
	         ['bomb_sprite']          = bomb_sprite,
	         ['key_sprite']           = key_sprite,
	         ['my_stuff_sprite']      = my_stuff_sprite }
end
function coopHUD.getItemSprite(item_id)
	local sprite = Sprite()
	local item_sprite = Isaac.GetItemConfig():GetCollectible(item_id).GfxFileName
	sprite:Load(coopHUD.GLOBALS.item_anim_path, false)
	sprite:ReplaceSpritesheet(0, item_sprite)
	sprite:ReplaceSpritesheet(1, item_sprite)
	sprite:ReplaceSpritesheet(2, item_sprite)
	sprite:LoadGraphics()
	sprite:SetFrame('Idle', 0)
	return sprite
end
function coopHUD.getCraftingItemSprite(item_id)
	local sprite = Sprite()
	sprite:Load(coopHUD.GLOBALS.crating_anim_path, true)
	sprite:SetFrame('Idle', item_id)
	return sprite
end
function coopHUD.getStreakSprite()
	sprite = Sprite()
	sprite:Load(coopHUD.GLOBALS.streak_anim_path, true)
	return sprite
end
function coopHUD.getStatSprites()
	stats = {
		speed       = Sprite(),
		tears_delay = Sprite(),
		damage      = Sprite(),
		range       = Sprite(),
		shot_speed  = Sprite(),
		luck        = Sprite(),
		font        = Font()
	}
	stats.speed:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	stats.speed:SetFrame('Idle', 0)
	stats.speed.Color = Color(1, 1, 1, 0.5)
	stats.tears_delay:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	stats.tears_delay:SetFrame('Idle', 1)
	stats.tears_delay.Color = Color(1, 1, 1, 0.5)
	stats.damage:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	stats.damage:SetFrame('Idle', 2)
	stats.damage.Color = Color(1, 1, 1, 0.5)
	stats.range:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	stats.range:SetFrame('Idle', 3)
	stats.range.Color = Color(1, 1, 1, 0.5)
	stats.shot_speed:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	stats.shot_speed:SetFrame('Idle', 4)
	stats.shot_speed.Color = Color(1, 1, 1, 0.5)
	stats.luck:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	stats.luck:SetFrame('Idle', 5)
	stats.luck.Color = Color(1, 1, 1, 0.5)
	stats.font:Load('font/luamini.fnt')
	return stats
end
function coopHUD.getDealSprites()
	local deals_sprites = {
		devil       = Sprite(),
		angel       = Sprite(),
		planetarium = Sprite(),
		duality     = Sprite(),
	}
	deals_sprites.devil:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	deals_sprites.devil:SetFrame('Idle', 6)
	--deals_sprites.devil.Color = Color(1, 1, 1, 0.5)
	deals_sprites.angel:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	deals_sprites.angel:SetFrame('Idle', 7)
	--deals_sprites.angel.Color = Color(1, 1, 1, 0.5)
	deals_sprites.planetarium:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	deals_sprites.planetarium:SetFrame('Idle', 8)
	--deals_sprites.planetarium.Color = Color(1, 1, 1, 0.5)
	deals_sprites.duality:Load(coopHUD.GLOBALS.hud_stats_anim_path, true)
	deals_sprites.duality:SetFrame('Idle', 10)
	--deals_sprites.duality.Color = Color(1, 1, 1, 0.5)
	return deals_sprites
end
--___ Help functions
-- Hearts
function coopHUD.getHeartType(player, heart_pos)
	---- Modified function from HUD_API from NeatPotato mod
	local player_type = player:GetPlayerType()
	local heart_type = 'None'
	local eternal = false
	local golden = false
	local remain_souls = 0
	local overlay = 'None'
	if player_type == 10 or player_type == 31 then
		if heart_pos == 0 then
			-- only returns for first pos
			-- checks if Holy Mantle is loaded
			if player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE) ~= 0 then
				heart_type = 'HolyMantle'
			end
		end
	elseif Game():GetLevel():GetCurses() == 8 then
		-- checks curse of the unknown
		if heart_pos == 0 and not player:IsSubPlayer() then
			heart_type = 'CurseHeart'
			return heart_type, overlay
		end
	else
		eternal = false
		golden = false
		local total_hearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts()) / 2)
		local empty_hearts = math.floor((player:GetMaxHearts() - player:GetHearts()) / 2)
		if empty_hearts < 0 then empty_hearts = 0 end
		if player:GetGoldenHearts() > 0 and (heart_pos >= total_hearts - (player:GetGoldenHearts() + empty_hearts)) then ---(total_hearts - (player:GetGoldenHearts()+empty_hearts)))
		golden = true
		end
		-- <Normal hearts>
		if player:GetMaxHearts() / 2 > heart_pos then
			-- red heart type
			-- <Keeper Hearts>
			if player_type == 14 or player_type == 33 then
				golden = false
				if player:GetHearts() - (heart_pos * 2) > 1 then
					heart_type = "CoinHeartFull"
				elseif player:GetHearts() - (heart_pos * 2) == 1 then
					heart_type = "CoinHeartHalf"
				else
					heart_type = "CoinEmpty"
				end
				-- </Keeper Hearts>
			else
				-- <Red Hearts Hearts>
				if player:GetHearts() - (heart_pos * 2) > 1 then
					heart_type = "RedHeartFull"
				elseif player:GetHearts() - (heart_pos * 2) == 1 then
					heart_type = "RedHeartHalf"
				else
					heart_type = "EmptyHeart"
				end
				-- </Red Hearts Hearts>
			end
			-- <Eternal check>
			if player:GetEternalHearts() > 0 and -- checks if any eternal hearts
					heart_pos + 1 == player:GetMaxHearts() / 2 then
				-- checks if heart_pos is last pos
				eternal = true
			end
			-- </Normal hearts>
			-- <BLue/Black hearts>
		elseif player:GetSoulHearts() > 0 or player:GetBoneHearts() > 0 then
			-- checks
			local red_offset = heart_pos - (player:GetMaxHearts() / 2)
			if math.ceil(player:GetSoulHearts() / 2) + player:GetBoneHearts() <= red_offset then
				heart_type = "None"
			else
				local prev_red = 0
				if player:IsBoneHeart(red_offset) then

					if red_offset > 0 then
						for i = 0, red_offset do
							if player:IsBoneHeart(i) == false then
								prev_red = prev_red + 2
							end
						end
					end
					-- HUDAPI
					local overloader_reds = player:GetHearts() + prev_red - (heart_pos * 2) --overloaded reds heart in red cointainers
					if overloader_reds > 1 then
						heart_type = "BoneHeartFull"
					elseif overloader_reds == 1 then
						heart_type = "BoneHeartHalf"
					else
						heart_type = "BoneHeartEmpty"
					end
				else
					local prev_bones = 0
					if red_offset > 0 then
						for i = 0, red_offset do
							if player:IsBoneHeart(i) then
								prev_bones = prev_bones + 1
							end
						end
					end
					local black_hearts = (red_offset * 2 + 1) - (2 * prev_bones)
					local remain_souls = player:GetSoulHearts() + (2 * prev_bones) - (red_offset * 2)
					if player:IsBlackHeart(black_hearts) then
						if remain_souls > 1 then
							heart_type = "BlackHeartFull"
						else
							heart_type = "BlackHeartHalf"
						end
					else
						if remain_souls > 1 then
							heart_type = "BlueHeartFull"
						else
							heart_type = "BlueHeartHalf"
						end
					end
					--eternal heart overlay
					if player:GetEternalHearts() > 0 and heart_pos == 0 then
						eternal = true
					end
				end
			end
		end
		-- </BLue/Black hearts>
		-- <RottenHearts hearts>
		if player:GetRottenHearts() > 0 then
			local non_rotten_reds = player:GetHearts() / 2 - player:GetRottenHearts()
			if heart_type == "RedHeartFull" then
				if heart_pos >= non_rotten_reds then
					heart_type = "RottenHeartFull"
				end
			elseif heart_type == "BoneHeartFull" then
				local overloader_reds = player:GetHearts() + remain_souls - (heart_pos * 2)
				if overloader_reds - player:GetRottenHearts() * 2 <= 0 then
					heart_type = "RottenBoneHeartFull"
				end
			end
		end
		-- </RottenHearts hearts>
		-- <Broken heart type>  - https://bindingofisaacrebirth.fandom.com/wiki/Health#Broken_Hearts
		if player:GetBrokenHearts() > 0 then
			if heart_pos > total_hearts - 1 and total_hearts + player:GetBrokenHearts() > heart_pos then
				if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or -- Check if Keeper
						player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
					heart_type = 'BrokenCoinHeart'
				else
					heart_type = 'BrokenHeart'
				end
			end
		end
		-- </Broken heart type>
		-- <Overlays>
		if eternal and golden then
			overlay = "GoldWhiteOverlay"
		elseif eternal then
			overlay = "WhiteHeartOverlay"
		elseif golden then
			overlay = "GoldHeartOverlay"
		else
			overlay = 'None'
		end
	end
	return heart_type, overlay
end
function coopHUD.getHeartTypeTable(player)
	local max_health_cap = 12
	local heart_type, overlay = ''
	local heart_types = {}
	-- Sets increased heatlh cap when playing Maggy with Birthright
	if player:GetPlayerType() == PlayerType.PLAYER_MAGDALENA and -- checks if player is Maggy
			player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		max_health_cap = 18
	end
	for counter = 0, max_health_cap, 1 do
		heart_type, overlay = coopHUD.getHeartType(player, counter)
		heart_types[counter] = {
			heart_type = heart_type,
			overlay    = overlay,
		}
	end
	return heart_types
end
-- Pockets
function coopHUD.getPocketID(player, slot)
	local pocket_id = 0
	local pocket_type = 0 -- 0 - none, 1 - card, 2 - pill, 3 - item
	if player then
		-- prevents from restart tables update error
		if player:GetCard(slot) > 0 then
			pocket_id = player:GetCard(slot)
			pocket_type = 1
		elseif player:GetPill(slot) > 0 then
			pocket_id = player:GetPill(slot)
			pocket_type = 2
		else
			if slot == 1 then
				if coopHUD.getPocketID(player, 0)[2] ~= 3 then
					pocket_id = player:GetActiveItem(2)
					pocket_type = 3
				end
			elseif slot == 2 then
				if coopHUD.getPocketID(player, 0)[2] ~= 3 and coopHUD.getPocketID(player, 1)[2] ~= 3 then
					pocket_id = player:GetActiveItem(2)
					pocket_type = 3
				end
			else
				pocket_id = player:GetActiveItem(2)
				pocket_type = 3
			end
		end
	end
	return { pocket_id, pocket_type }
end
function coopHUD.getMainPocketDesc(player)
	local name = 'Error'
	local desc = 'Error'
	if langAPI ~= nil then
		if player:GetPill(0) < 1 and player:GetCard(0) < 1 then
			if player:GetActiveItem(2) > 0 then
				name = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(2)).Name
				desc = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(2)).Description
			elseif player:GetActiveItem(3) > 0 then
				name = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(3)).Name
				desc = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(3)).Description
			else
				return false
			end
			name = string.sub(name, 2) --  get rid of # on front of
			name = langAPI.getItemName(name)
			desc = string.sub(desc, 2) --  get rid of # on front of
			desc = langAPI.getItemName(desc)
		end
		if player:GetCard(0) > 0 then
			name = Isaac.GetItemConfig():GetCard(player:GetCard(0)).Name
			name = string.sub(name, 2) --  get rid of # on front of
			name = langAPI.getPocketName(name)
			--
			desc = Isaac.GetItemConfig():GetCard(player:GetCard(0)).Description
			desc = string.sub(desc, 2) --  get rid of # on front of
			desc = langAPI.getPocketName(desc)
		elseif player:GetPill(0) > 0 then
			name = "???" .. " "
			desc = "???" .. " "
			local pill = player:GetPill(0)
			local item_pool = Game():GetItemPool()
			if item_pool:IsPillIdentified(pill) then
				local pill_effect = item_pool:GetPillEffect(pill, player)
				name = Isaac.GetItemConfig():GetPillEffect(pill_effect).Name
				name = string.sub(name, 2) --  get rid of # on front of
				name = langAPI.getPocketName(name)
				desc = name
			end
		end
	else
		name = 'Error! - langAPI not installed'
		desc = 'Install langAPI for compatibility'
	end
	return { ['name'] = name, ['desc'] = desc }
end
function coopHUD.getPoopSpellTable(player_no)
	local poop_table = {}
	for i = 0, PoopSpellType.SPELL_QUEUE_SIZE, 1 do
		poop_table[i] = Isaac.GetPlayer(player_no):GetPoopSpell(i)
	end
	return poop_table
end
-- Other
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
		if MinimapAPI:GetConfig("Disable") or MinimapAPI.Disable then minimap_offset = Vector(screen_size.X - 4, 2) end
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
function coopHUD.checkDeepPockets()
	local deep_check = false
	local player_no = Game():GetNumPlayers() - 1
	for i = 0, player_no, 1 do
		local deep = Isaac.GetPlayer(i):HasCollectible(416)
		if deep then
			deep_check = true
		end
	end
	return deep_check
end
function coopHUD.calculateDeal()
	local lvl = Game():GetLevel()
	local room = lvl:GetCurrentRoom()
	local deal = 0.0
	local angel = 0.0
	local devil = 0.0
	local banned_stages = { [1] = true, [9] = true, [10] = true, [11] = true, [12] = true, [12] = true }
	if angel_seen == nil then angel_seen = false end
	-- door chance
	if banned_stages[Game():GetLevel():GetStage()] == nil and
			Game():GetLevel():GetCurseName() ~= "Curse of the Labyrinth!" or Game().Difficulty > 1 then
		deal = room:GetDevilRoomChance()
		if deal > 1 then
			deal = 1.0
		end
	end
	-- angel components
	local comp = {
		rosary_bead   = { false, 0.5 },
		key_piece_1   = { false, 0.75 },
		key_piece_2   = { false, 0.75 },
		virtouses     = { false, 0.75 },
		bum_killed    = { false, 0.75 },
		bum_left      = { false, 0.9 },
		dead_bum_left = { false, 1.1 },
		donation      = { false, 0.5 },
	}
	-- check collectibles
	local duality = false
	local eucharist = false
	local act_of_contr = false
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1) then
			comp.key_piece_1[1] = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2) then
			comp.key_piece_2[1] = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			comp.virtouses[1] = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_DUALITY) then
			duality = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_EUCHARIST) then
			eucharist = true
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) then
			act_of_contr = true
		end
		if player:HasTrinket(TrinketType.TRINKET_ROSARY_BEAD) then
			comp.rosary_bead[1] = true
		end
	end
	-- check state flags - bum kills/donations
	if lvl:GetStateFlag(1) then
		-- check if devil bum killed
		comp.bum_killed[1] = true
	end
	if lvl:GetStateFlag(3) then
		-- check if  bum donated until left
		comp.bum_left[1] = true
	end
	if lvl:GetStateFlag(4) then
		-- check if  bum donated until left
		comp.dead_bum_left[1] = true
	end
	if Game():GetDonationModAngel() >= 10 then
		-- check if donated more than 10 coins on level
		comp.donation[1] = true
	end
	-- Check after boss battle angel door spawned
	if room:GetType(RoomType.ROOM_BOSS) and room:IsClear() then
		for i = 0, 7, 1 do
			local door = room:GetDoor(i)
			if door ~= nil then
				if door.TargetRoomType == 15 then
					coopHUD.angel_seen = true
				end
			end
		end
	end
	-- Calculate ange deals
	if Game():GetStateFlag(5) or comp.virtouses[1] or eucharist and -- check if player seen devil deal or
			--lvl:GetAngelRoomChance() ~= 0) and --have I feel blessed
			(Game():GetDevilRoomDeals() == 0 or -- check if player has done devil deal
					act_of_contr or comp.virtouses[1] or lvl:GetAngelRoomChance() ~= 0) then
		-- if have virtouses or act_of_contr ignore devil deals deals
		if eucharist then
			-- if have eucharist
			angel = 1
		elseif Game():GetStateFlag(6) or coopHUD.angel_seen then
			-- if not enter devil deal and seen angel
			angel = 1 - 0.5
			for n, k in pairs(comp) do
				-- calculate components of angel deal from table of components
				if k[1] then
					angel = angel * k[2]
				end
			end
			angel = angel * (1.0 - lvl:GetAngelRoomChance()) -- checks you feel blessed component
			angel = 1 - angel
		else
			-- seen devil but not angel and not entered devil
			angel = 1
		end
	end
	devil = deal * (1.0 - angel)
	angel = deal * angel
	return { devil       = { devil * 100, 0 },
	         angel       = { angel * 100, 0 },
	         planetarium = { lvl:GetPlanetariumChance() * 100, 0 },
	         duality     = duality }
end
-- Bag of crafting
coopHUD.itemUnlockStates = {}
function coopHUD:isCollectibleUnlocked(CollectibleID, itemPoolOfItem)
	local itemPool = Game():GetItemPool()
	if maxCollectibleID == nil then maxCollectibleID = coopHUD.XMLMaxItemID end
	for i = 1, maxCollectibleID do
		if ItemConfig.Config.IsValidCollectible(i) and i ~= CollectibleID then
			itemPool:AddRoomBlacklist(i)
		end
	end
	local isUnlocked = false
	for i = 0, 1 do
		-- some samples to make sure
		local collID = itemPool:GetCollectible(itemPoolOfItem, false, 1)
		if collID == CollectibleID then
			isUnlocked = true
			break
		end
	end
	itemPool:ResetRoomBlacklist()
	return isUnlocked
end
function coopHUD:isCollectibleUnlockedAnyPool(collectibleID)
	--THIS FUNCTION IS FOR REPENTANCE ONLY due to using Repentance XML data; currently used by the Achievement Check, Spindown Dice, and Bag of Crafting
	if not REPENTANCE then return true end
	local item = Isaac.GetItemConfig():GetCollectible(collectibleID)
	if item == nil then return false end
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
		for k, itemPoolID in ipairs(coopHUD.XMLItemIsInPools[collectibleID]) do
			if (itemPoolID < ItemPoolType.NUM_ITEMPOOLS and coopHUD:isCollectibleUnlocked(collectibleID,
			                                                                                   itemPoolID)) then
				MPSDMSpecial.itemUnlockStates[collectibleID] = true
				return true
			end
		end
		--note: some items will still be missed by this, if they've been taken out of their pools (especially when in Greed Mode)
		MPSDMSpecial.itemUnlockStates[collectibleID] = false
		return false
	else
		return coopHUD.itemUnlockStates[collectibleID]
	end
end
function coopHUD.getCraftingItemId(item_entity)
	local pickupIDLookup = {
		["10.1"]    = { 1 }, -- Red heart
		["10.2"]    = { 1 }, -- half heart
		["10.3"]    = { 2 }, -- soul heart
		["10.4"]    = { 4 }, -- eternal heart
		["10.5"]    = { 1, 1 }, -- double heart
		["10.6"]    = { 3 }, -- black heart
		["10.7"]    = { 5 }, -- gold heart
		["10.8"]    = { 2 }, -- half soul heart
		["10.9"]    = { 1 }, -- scared red heart
		["10.10"]   = { 2, 1 }, -- blended heart
		["10.11"]   = { 6 }, -- Bone heart
		["10.12"]   = { 7 }, -- Rotten heart
		["20.1"]    = { 8 }, -- Penny
		["20.2"]    = { 9 }, -- Nickel
		["20.3"]    = { 10 }, -- Dime
		["20.4"]    = { 8, 8 }, -- Double penny
		["20.5"]    = { 11 }, -- Lucky Penny
		["20.6"]    = { 9 }, -- Sticky Nickel
		["20.7"]    = { 26 }, -- Golden Penny
		["30.1"]    = { 12 }, -- Key
		["30.2"]    = { 13 }, -- golden Key
		["30.3"]    = { 12, 12 }, -- Key Ring
		["30.4"]    = { 14 }, -- charged Key
		["40.1"]    = { 15 }, -- bomb
		["40.2"]    = { 15, 15 }, -- double bomb
		["40.4"]    = { 16 }, -- golden bomb
		["40.7"]    = { 17 }, -- giga bomb
		["42.0"]    = { 29 }, -- poop nugget
		["42.1"]    = { 29 }, -- big poop nugget
		["70.14"]   = { 27 }, -- golden pill
		["70.2062"] = { 27 }, -- golden horse pill
		["90.1"]    = { 19 }, -- Lil Battery
		["90.2"]    = { 18 }, -- Micro Battery
		["90.3"]    = { 20 }, -- Mega Battery
		["90.4"]    = { 28 }, -- Golden Battery
		["300.49"]  = { 24 }, -- Dice shard
		["300.50"]  = { 21 }, -- Emergency Contact
		["300.78"]  = { 25 }, -- Cracked key
	}
	local Variant = item_entity.Variant
	local SubType = item_entity.SubType
	local id = {}
	if pickupIDLookup["" .. Variant .. "." .. SubType] ~= nil then
		id = pickupIDLookup["" .. Variant .. "." .. SubType]
	elseif Variant == 300 then
		if SubType > 80 or (SubType >= 32 and SubType <= 41) or SubType == 55 then
			-- runes
			id = { 23 }
		else
			-- cards
			id = { 21 }
		end
	elseif Variant == 70 then
		-- pills
		id = { 22 }
	end

	return id
end
function coopHUD.getItemValue(item_id)
	local pickupValues = {
		0x00000000, -- 0 None
		-- Hearts
		0x00000001, -- 1 Red Heart
		0x00000004, -- 2 Soul Heart
		0x00000005, -- 3 Black Heart
		0x00000005, -- 4 Eternal Heart
		0x00000005, -- 5 Gold Heart
		0x00000005, -- 6 Bone Heart
		0x00000001, -- 7 Rotten Heart
		-- Pennies
		0x00000001, -- 8 Penny
		0x00000003, -- 9 Nickel
		0x00000005, -- 10 Dime
		0x00000008, -- 11 Lucky Penny
		-- Keys
		0x00000002, -- 12 Key
		0x00000007, -- 13 Golden Key
		0x00000005, -- 14 Charged Key
		-- Bombs
		0x00000002, -- 15 Bomb
		0x00000007, -- 16 Golden Bomb
		0x0000000a, -- 17 Giga Bomb
		-- Batteries
		0x00000002, -- 18 Micro Battery
		0x00000004, -- 19 Lil' Battery
		0x00000008, -- 20 Mega Battery
		-- Usables
		0x00000002, -- 21 Card
		0x00000002, -- 22 Pill
		0x00000004, -- 23 Rune
		0x00000004, -- 24 Dice Shard
		0x00000002, -- 25 Cracked Key
		-- Added in Update
		0x00000007, -- 26 Golden Penny
		0x00000007, -- 27 Golden Pill
		0x00000007, -- 28 Golden Battery
		0x00000000, -- 29 Tainted ??? Poop

		0x00000001,
	}
	return pickupValues[item_id]
end
-- _____BAG CALCULATE FUNCTIONS
-- Function from External
--These are recipes that have already been calculated, plus the contents of recipes.xml
local calculatedRecipes = {}
--Backup recipes in case of potential achievement lock
local lockedRecipes = {}
--If the seed changes, the above two tables will be wiped
local lastSeedUsed = 0
--
local componentShifts = {
	{0x00000001, 0x00000005, 0x00000010},
	{0x00000001, 0x00000005, 0x00000013},
	{0x00000001, 0x00000009, 0x0000001D},
	{0x00000001, 0x0000000B, 0x00000006},
	{0x00000001, 0x0000000B, 0x00000010},
	{0x00000001, 0x00000013, 0x00000003},
	{0x00000001, 0x00000015, 0x00000014},
	{0x00000001, 0x0000001B, 0x0000001B},
	{0x00000002, 0x00000005, 0x0000000F},
	{0x00000002, 0x00000005, 0x00000015},
	{0x00000002, 0x00000007, 0x00000007},
	{0x00000002, 0x00000007, 0x00000009},
	{0x00000002, 0x00000007, 0x00000019},
	{0x00000002, 0x00000009, 0x0000000F},
	{0x00000002, 0x0000000F, 0x00000011},
	{0x00000002, 0x0000000F, 0x00000019},
	{0x00000002, 0x00000015, 0x00000009},
	{0x00000003, 0x00000001, 0x0000000E},
	{0x00000003, 0x00000003, 0x0000001A},
	{0x00000003, 0x00000003, 0x0000001C},
	{0x00000003, 0x00000003, 0x0000001D},
	{0x00000003, 0x00000005, 0x00000014},
	{0x00000003, 0x00000005, 0x00000016},
	{0x00000003, 0x00000005, 0x00000019},
	{0x00000003, 0x00000007, 0x0000001D},
	{0x00000003, 0x0000000D, 0x00000007},
	{0x00000003, 0x00000017, 0x00000019},
	{0x00000003, 0x00000019, 0x00000018},
	{0x00000003, 0x0000001B, 0x0000000B},
	{0x00000004, 0x00000003, 0x00000011},
	{0x00000004, 0x00000003, 0x0000001B},
	{0x00000004, 0x00000005, 0x0000000F},
	{0x00000005, 0x00000003, 0x00000015},
	{0x00000005, 0x00000007, 0x00000016},
	{0x00000005, 0x00000009, 0x00000007},
	{0x00000005, 0x00000009, 0x0000001C},
	{0x00000005, 0x00000009, 0x0000001F},
	{0x00000005, 0x0000000D, 0x00000006},
	{0x00000005, 0x0000000F, 0x00000011},
	{0x00000005, 0x00000011, 0x0000000D},
	{0x00000005, 0x00000015, 0x0000000C},
	{0x00000005, 0x0000001B, 0x00000008},
	{0x00000005, 0x0000001B, 0x00000015},
	{0x00000005, 0x0000001B, 0x00000019},
	{0x00000005, 0x0000001B, 0x0000001C},
	{0x00000006, 0x00000001, 0x0000000B},
	{0x00000006, 0x00000003, 0x00000011},
	{0x00000006, 0x00000011, 0x00000009},
	{0x00000006, 0x00000015, 0x00000007},
	{0x00000006, 0x00000015, 0x0000000D},
	{0x00000007, 0x00000001, 0x00000009},
	{0x00000007, 0x00000001, 0x00000012},
	{0x00000007, 0x00000001, 0x00000019},
	{0x00000007, 0x0000000D, 0x00000019},
	{0x00000007, 0x00000011, 0x00000015},
	{0x00000007, 0x00000019, 0x0000000C},
	{0x00000007, 0x00000019, 0x00000014},
	{0x00000008, 0x00000007, 0x00000017},
	{0x00000008, 0x00000009, 0x00000017},
	{0x00000009, 0x00000005, 0x0000000E},
	{0x00000009, 0x00000005, 0x00000019},
	{0x00000009, 0x0000000B, 0x00000013},
	{0x00000009, 0x00000015, 0x00000010},
	{0x0000000A, 0x00000009, 0x00000015},
	{0x0000000A, 0x00000009, 0x00000019},
	{0x0000000B, 0x00000007, 0x0000000C},
	{0x0000000B, 0x00000007, 0x00000010},
	{0x0000000B, 0x00000011, 0x0000000D},
	{0x0000000B, 0x00000015, 0x0000000D},
	{0x0000000C, 0x00000009, 0x00000017},
	{0x0000000D, 0x00000003, 0x00000011},
	{0x0000000D, 0x00000003, 0x0000001B},
	{0x0000000D, 0x00000005, 0x00000013},
	{0x0000000D, 0x00000011, 0x0000000F},
	{0x0000000E, 0x00000001, 0x0000000F},
	{0x0000000E, 0x0000000D, 0x0000000F},
	{0x0000000F, 0x00000001, 0x0000001D},
	{0x00000011, 0x0000000F, 0x00000014},
	{0x00000011, 0x0000000F, 0x00000017},
	{0x00000011, 0x0000000F, 0x0000001A}
}
--
local customRNGSeed = 0x77777770
local customRNGShift = {0,0,0}
--
local function RNGNext()
	local num = customRNGSeed
	num = num ~ ((num >> customRNGShift[1]) & 4294967295)
	num = num ~ ((num << customRNGShift[2]) & 4294967295)
	num = num ~ ((num >> customRNGShift[3]) & 4294967295)
	customRNGSeed = num >> 0;
	return customRNGSeed;
end
--
local function nextFloat()
	local multi = 2.3283061589829401E-10;
	return RNGNext() * multi;
end
--
local HasEIDXML, EIDXML = pcall(require, "eid_xmldata")
if HasEIDXML == false then
	--This file was autogenerated using 'lookuptable_generator.py' found in the scripts folder
	--It will have to be updated whenever the game's item XML files are updated
	--The highest item ID found
	coopHUD.XMLMaxItemID = 732
	--The fixed recipes, for use in Bag of Crafting
	coopHUD.XMLRecipes = { ["29,29,29,29,29,29,29,29"] = 36, ["8,8,8,8,8,8,8,8"] = 177, ["1,1,1,1,1,1,1,1"] = 45, ["2,2,2,2,2,2,2,2"] = 686, ["3,3,3,3,3,3,3,3"] = 118, ["12,12,12,12,12,12,12,12"] = 343, ["15,15,15,15,15,15,15,15"] = 37, ["21,21,21,21,21,21,21,21"] = 85, ["5,2,1,4,4,4,4,4"] = 331, ["4,4,4,4,4,4,4,4"] = 182, ["22,22,22,22,22,22,22,22"] = 75, ["3,22,22,22,22,22,22,22"] = 654, ["7,7,1,1,1,1,1,1"] = 639, ["13,13,12,12,12,12,12,12"] = 175, ["17,17,17,17,17,17,17,17"] = 483, ["16,16,15,15,15,15,15,15"] = 483, ["6,6,6,6,6,6,6,6"] = 628, ["24,24,24,24,24,24,24,24"] = 489, ["25,25,25,25,25,25,25,25"] = 580, }

	--The contents of each item pool, and the item's weight, for use in Bag of Crafting
	coopHUD.XMLItemPools = { { { 1, 1.0 }, { 2, 1.0 }, { 3, 1.0 }, { 4, 1.0 }, { 5, 1.0 }, { 6, 1.0 }, { 7, 1.0 }, { 8, 1.0 }, { 10, 1.0 }, { 12, 0.5 }, { 13, 1.0 }, { 14, 1.0 }, { 15, 1.0 }, { 17, 0.1 }, { 19, 1.0 }, { 36, 1.0 }, { 37, 1.0 }, { 38, 1.0 }, { 39, 1.0 }, { 40, 1.0 }, { 41, 1.0 }, { 42, 1.0 }, { 44, 1.0 }, { 45, 1.0 }, { 46, 1.0 }, { 47, 1.0 }, { 48, 1.0 }, { 49, 1.0 }, { 52, 1.0 }, { 53, 1.0 }, { 55, 1.0 }, { 56, 1.0 }, { 57, 1.0 }, { 58, 1.0 }, { 62, 1.0 }, { 65, 1.0 }, { 66, 1.0 }, { 67, 1.0 }, { 68, 1.0 }, { 69, 1.0 }, { 71, 1.0 }, { 72, 1.0 }, { 75, 1.0 }, { 76, 1.0 }, { 77, 1.0 }, { 78, 1.0 }, { 85, 1.0 }, { 86, 1.0 }, { 87, 1.0 }, { 88, 1.0 }, { 89, 1.0 }, { 91, 1.0 }, { 92, 1.0 }, { 93, 1.0 }, { 94, 1.0 }, { 95, 1.0 }, { 96, 1.0 }, { 97, 1.0 }, { 98, 0.2 }, { 99, 1.0 }, { 100, 1.0 }, { 101, 0.5 }, { 102, 1.0 }, { 103, 1.0 }, { 104, 1.0 }, { 105, 1.0 }, { 106, 1.0 }, { 107, 1.0 }, { 108, 1.0 }, { 109, 1.0 }, { 110, 1.0 }, { 111, 1.0 }, { 113, 1.0 }, { 114, 0.2 }, { 115, 1.0 }, { 117, 1.0 }, { 120, 1.0 }, { 121, 1.0 }, { 123, 1.0 }, { 124, 1.0 }, { 125, 1.0 }, { 127, 1.0 }, { 128, 1.0 }, { 129, 1.0 }, { 131, 1.0 }, { 136, 1.0 }, { 137, 1.0 }, { 138, 1.0 }, { 140, 1.0 }, { 142, 1.0 }, { 143, 1.0 }, { 144, 1.0 }, { 146, 1.0 }, { 148, 1.0 }, { 149, 1.0 }, { 150, 1.0 }, { 151, 1.0 }, { 152, 1.0 }, { 153, 1.0 }, { 154, 1.0 }, { 155, 1.0 }, { 157, 1.0 }, { 160, 1.0 }, { 161, 1.0 }, { 162, 1.0 }, { 163, 1.0 }, { 166, 1.0 }, { 167, 1.0 }, { 169, 1.0 }, { 170, 1.0 }, { 171, 1.0 }, { 172, 1.0 }, { 173, 1.0 }, { 174, 1.0 }, { 175, 1.0 }, { 176, 1.0 }, { 178, 1.0 }, { 180, 1.0 }, { 186, 1.0 }, { 188, 1.0 }, { 189, 1.0 }, { 190, 0.1 }, { 191, 1.0 }, { 192, 1.0 }, { 200, 1.0 }, { 201, 1.0 }, { 202, 1.0 }, { 206, 1.0 }, { 209, 1.0 }, { 210, 1.0 }, { 211, 1.0 }, { 213, 1.0 }, { 214, 1.0 }, { 217, 1.0 }, { 220, 1.0 }, { 221, 1.0 }, { 222, 1.0 }, { 223, 0.5 }, { 224, 1.0 }, { 225, 1.0 }, { 227, 1.0 }, { 228, 1.0 }, { 229, 1.0 }, { 231, 1.0 }, { 233, 1.0 }, { 234, 1.0 }, { 236, 1.0 }, { 237, 0.2 }, { 240, 1.0 }, { 242, 1.0 }, { 244, 1.0 }, { 245, 1.0 }, { 256, 1.0 }, { 257, 1.0 }, { 261, 1.0 }, { 264, 1.0 }, { 265, 1.0 }, { 266, 1.0 }, { 267, 1.0 }, { 268, 1.0 }, { 269, 1.0 }, { 270, 1.0 }, { 271, 1.0 }, { 272, 1.0 }, { 273, 1.0 }, { 274, 1.0 }, { 275, 1.0 }, { 276, 1.0 }, { 277, 1.0 }, { 278, 1.0 }, { 279, 1.0 }, { 280, 1.0 }, { 281, 1.0 }, { 282, 1.0 }, { 283, 1.0 }, { 284, 1.0 }, { 285, 1.0 }, { 287, 1.0 }, { 288, 1.0 }, { 291, 1.0 }, { 292, 1.0 }, { 294, 1.0 }, { 295, 1.0 }, { 298, 1.0 }, { 299, 1.0 }, { 300, 1.0 }, { 301, 1.0 }, { 302, 1.0 }, { 303, 1.0 }, { 304, 1.0 }, { 305, 1.0 }, { 306, 1.0 }, { 307, 1.0 }, { 308, 1.0 }, { 309, 1.0 }, { 310, 1.0 }, { 312, 1.0 }, { 313, 0.2 }, { 314, 1.0 }, { 315, 1.0 }, { 316, 1.0 }, { 317, 1.0 }, { 318, 1.0 }, { 319, 1.0 }, { 320, 1.0 }, { 321, 1.0 }, { 322, 1.0 }, { 323, 1.0 }, { 324, 1.0 }, { 325, 1.0 }, { 329, 1.0 }, { 330, 1.0 }, { 332, 1.0 }, { 333, 0.2 }, { 334, 0.2 }, { 335, 0.2 }, { 336, 1.0 }, { 350, 1.0 }, { 351, 1.0 }, { 352, 1.0 }, { 353, 1.0 }, { 358, 1.0 }, { 359, 1.0 }, { 361, 1.0 }, { 362, 1.0 }, { 364, 1.0 }, { 365, 1.0 }, { 366, 1.0 }, { 367, 1.0 }, { 368, 1.0 }, { 369, 1.0 }, { 371, 1.0 }, { 373, 1.0 }, { 374, 0.2 }, { 375, 1.0 }, { 377, 1.0 }, { 378, 1.0 }, { 379, 1.0 }, { 381, 1.0 }, { 382, 1.0 }, { 384, 1.0 }, { 385, 1.0 }, { 386, 1.0 }, { 388, 1.0 }, { 389, 1.0 }, { 390, 1.0 }, { 391, 1.0 }, { 392, 1.0 }, { 393, 1.0 }, { 394, 1.0 }, { 395, 1.0 }, { 397, 1.0 }, { 398, 1.0 }, { 401, 1.0 }, { 404, 1.0 }, { 405, 1.0 }, { 406, 1.0 }, { 407, 1.0 }, { 410, 1.0 }, { 411, 1.0 }, { 418, 1.0 }, { 419, 1.0 }, { 421, 1.0 }, { 422, 1.0 }, { 426, 1.0 }, { 427, 1.0 }, { 430, 1.0 }, { 431, 1.0 }, { 432, 1.0 }, { 435, 1.0 }, { 436, 1.0 }, { 437, 1.0 }, { 440, 1.0 }, { 443, 1.0 }, { 444, 1.0 }, { 445, 1.0 }, { 446, 1.0 }, { 447, 1.0 }, { 448, 1.0 }, { 449, 1.0 }, { 452, 1.0 }, { 453, 1.0 }, { 454, 1.0 }, { 457, 1.0 }, { 458, 1.0 }, { 459, 1.0 }, { 460, 1.0 }, { 461, 1.0 }, { 463, 1.0 }, { 465, 1.0 }, { 466, 1.0 }, { 467, 1.0 }, { 469, 1.0 }, { 470, 1.0 }, { 471, 1.0 }, { 473, 1.0 }, { 476, 1.0 }, { 478, 1.0 }, { 481, 1.0 }, { 482, 1.0 }, { 485, 1.0 }, { 488, 1.0 }, { 491, 1.0 }, { 492, 1.0 }, { 493, 1.0 }, { 494, 1.0 }, { 495, 1.0 }, { 496, 1.0 }, { 497, 1.0 }, { 502, 1.0 }, { 504, 1.0 }, { 506, 1.0 }, { 507, 1.0 }, { 508, 1.0 }, { 509, 1.0 }, { 511, 1.0 }, { 512, 1.0 }, { 513, 1.0 }, { 516, 1.0 }, { 517, 1.0 }, { 522, 1.0 }, { 524, 1.0 }, { 525, 1.0 }, { 529, 1.0 }, { 531, 1.0 }, { 532, 1.0 }, { 537, 1.0 }, { 539, 1.0 }, { 540, 1.0 }, { 542, 1.0 }, { 543, 1.0 }, { 544, 1.0 }, { 545, 1.0 }, { 548, 1.0 }, { 549, 1.0 }, { 553, 1.0 }, { 555, 1.0 }, { 557, 1.0 }, { 558, 1.0 }, { 559, 1.0 }, { 560, 1.0 }, { 561, 1.0 }, { 563, 1.0 }, { 565, 1.0 }, { 570, 1.0 }, { 575, 1.0 }, { 576, 1.0 }, { 578, 1.0 }, { 581, 1.0 }, { 583, 1.0 }, { 605, 1.0 }, { 607, 1.0 }, { 608, 1.0 }, { 609, 0.5 }, { 610, 1.0 }, { 611, 1.0 }, { 612, 1.0 }, { 614, 1.0 }, { 615, 1.0 }, { 616, 1.0 }, { 617, 1.0 }, { 618, 1.0 }, { 625, 0.1 }, { 629, 1.0 }, { 631, 1.0 }, { 635, 1.0 }, { 637, 1.0 }, { 639, 1.0 }, { 641, 1.0 }, { 645, 1.0 }, { 649, 1.0 }, { 650, 0.5 }, { 652, 1.0 }, { 655, 1.0 }, { 657, 1.0 }, { 658, 1.0 }, { 661, 1.0 }, { 663, 1.0 }, { 671, 1.0 }, { 675, 1.0 }, { 676, 1.0 }, { 677, 0.2 }, { 678, 1.0 }, { 680, 1.0 }, { 681, 1.0 }, { 682, 1.0 }, { 683, 1.0 }, { 687, 1.0 }, { 690, 1.0 }, { 693, 1.0 }, { 695, 1.0 }, { 703, 0.5 }, { 709, 1.0 }, { 710, 1.0 }, { 713, 1.0 }, { 717, 1.0 }, { 720, 1.0 }, { 722, 1.0 }, { 723, 0.1 }, { 724, 1.0 }, { 725, 1.0 }, { 726, 1.0 }, { 727, 1.0 }, { 728, 0.5 }, { 729, 1.0 } }, -- treasure
	                              { { 21, 1.0 }, { 33, 1.0 }, { 54, 1.0 }, { 60, 1.0 }, { 63, 1.0 }, { 64, 1.0 }, { 75, 1.0 }, { 85, 1.0 }, { 102, 1.0 }, { 116, 1.0 }, { 137, 1.0 }, { 139, 1.0 }, { 147, 1.0 }, { 156, 1.0 }, { 164, 1.0 }, { 177, 1.0 }, { 195, 1.0 }, { 199, 1.0 }, { 203, 1.0 }, { 204, 1.0 }, { 205, 1.0 }, { 208, 1.0 }, { 227, 1.0 }, { 232, 1.0 }, { 246, 1.0 }, { 247, 1.0 }, { 248, 1.0 }, { 249, 1.0 }, { 250, 1.0 }, { 251, 1.0 }, { 252, 1.0 }, { 260, 1.0 }, { 286, 0.2 }, { 289, 1.0 }, { 290, 1.0 }, { 295, 1.0 }, { 296, 1.0 }, { 297, 1.0 }, { 337, 1.0 }, { 338, 1.0 }, { 347, 1.0 }, { 348, 1.0 }, { 349, 1.0 }, { 356, 1.0 }, { 357, 1.0 }, { 372, 1.0 }, { 376, 1.0 }, { 380, 1.0 }, { 383, 1.0 }, { 396, 1.0 }, { 402, 0.5 }, { 403, 1.0 }, { 414, 1.0 }, { 416, 1.0 }, { 422, 1.0 }, { 424, 0.5 }, { 425, 1.0 }, { 434, 1.0 }, { 439, 1.0 }, { 451, 1.0 }, { 472, 1.0 }, { 475, 0.2 }, { 479, 1.0 }, { 480, 1.0 }, { 483, 0.5 }, { 485, 0.5 }, { 486, 1.0 }, { 487, 1.0 }, { 505, 1.0 }, { 514, 1.0 }, { 515, 1.0 }, { 518, 1.0 }, { 520, 1.0 }, { 521, 1.0 }, { 523, 1.0 }, { 527, 1.0 }, { 534, 1.0 }, { 535, 1.0 }, { 566, 1.0 }, { 585, 1.0 }, { 599, 1.0 }, { 602, 1.0 }, { 603, 1.0 }, { 604, 1.0 }, { 619, 1.0 }, { 621, 1.0 }, { 623, 1.0 }, { 624, 1.0 }, { 638, 1.0 }, { 642, 0.1 }, { 647, 1.0 }, { 660, 0.5 }, { 670, 1.0 }, { 716, 1.0 }, { 719, 0.5 } }, -- shop
	                              { { 14, 1.0 }, { 22, 1.0 }, { 23, 1.0 }, { 24, 1.0 }, { 25, 1.0 }, { 26, 1.0 }, { 27, 1.0 }, { 28, 1.0 }, { 29, 1.0 }, { 30, 1.0 }, { 31, 1.0 }, { 32, 1.0 }, { 51, 1.0 }, { 70, 1.0 }, { 92, 0.5 }, { 141, 1.0 }, { 143, 1.0 }, { 165, 1.0 }, { 176, 1.0 }, { 183, 1.0 }, { 193, 1.0 }, { 194, 1.0 }, { 195, 1.0 }, { 196, 1.0 }, { 197, 1.0 }, { 198, 1.0 }, { 218, 1.0 }, { 219, 1.0 }, { 240, 1.0 }, { 253, 1.0 }, { 254, 1.0 }, { 255, 1.0 }, { 339, 1.0 }, { 340, 1.0 }, { 341, 1.0 }, { 342, 1.0 }, { 343, 1.0 }, { 344, 1.0 }, { 345, 1.0 }, { 346, 1.0 }, { 354, 1.0 }, { 355, 1.0 }, { 370, 1.0 }, { 428, 0.5 }, { 438, 1.0 }, { 455, 1.0 }, { 456, 1.0 }, { 538, 1.0 }, { 541, 1.0 }, { 547, 1.0 }, { 564, 1.0 }, { 600, 1.0 }, { 624, 1.0 }, { 644, 1.0 }, { 659, 1.0 }, { 707, 1.0 }, { 708, 1.0 }, { 730, 1.0 }, { 731, 1.0 } }, -- boss
	                              { { 8, 1.0 }, { 34, 1.0 }, { 35, 1.0 }, { 51, 1.0 }, { 67, 1.0 }, { 74, 1.0 }, { 79, 1.0 }, { 80, 1.0 }, { 81, 1.0 }, { 82, 1.0 }, { 83, 1.0 }, { 84, 1.0 }, { 97, 1.0 }, { 109, 1.0 }, { 113, 1.0 }, { 114, 1.0 }, { 115, 1.0 }, { 118, 1.0 }, { 122, 1.0 }, { 123, 1.0 }, { 126, 1.0 }, { 127, 0.2 }, { 133, 1.0 }, { 134, 1.0 }, { 145, 1.0 }, { 157, 1.0 }, { 159, 1.0 }, { 163, 1.0 }, { 172, 1.0 }, { 187, 1.0 }, { 212, 1.0 }, { 215, 1.0 }, { 216, 1.0 }, { 225, 1.0 }, { 230, 1.0 }, { 237, 1.0 }, { 241, 1.0 }, { 259, 1.0 }, { 262, 1.0 }, { 268, 1.0 }, { 269, 1.0 }, { 275, 1.0 }, { 278, 1.0 }, { 292, 1.0 }, { 311, 1.0 }, { 360, 1.0 }, { 391, 1.0 }, { 399, 1.0 }, { 408, 1.0 }, { 409, 1.0 }, { 411, 1.0 }, { 412, 1.0 }, { 417, 1.0 }, { 420, 1.0 }, { 431, 1.0 }, { 433, 1.0 }, { 441, 0.2 }, { 442, 1.0 }, { 462, 1.0 }, { 468, 1.0 }, { 475, 0.2 }, { 477, 0.5 }, { 498, 1.0 }, { 519, 1.0 }, { 526, 1.0 }, { 530, 1.0 }, { 536, 1.0 }, { 545, 1.0 }, { 554, 1.0 }, { 556, 1.0 }, { 569, 1.0 }, { 572, 1.0 }, { 577, 1.0 }, { 606, 1.0 }, { 634, 1.0 }, { 646, 1.0 }, { 654, 1.0 }, { 665, 1.0 }, { 672, 1.0 }, { 679, 1.0 }, { 684, 1.0 }, { 692, 1.0 }, { 694, 0.5 }, { 695, 1.0 }, { 698, 1.0 }, { 699, 1.0 }, { 702, 1.0 }, { 704, 0.5 }, { 705, 0.5 }, { 706, 0.5 }, { 712, 0.5 }, { 728, 1.0 } }, -- devil
	                              { { 7, 1.0 }, { 33, 1.0 }, { 72, 1.0 }, { 98, 1.0 }, { 101, 1.0 }, { 108, 1.0 }, { 112, 1.0 }, { 124, 1.0 }, { 142, 1.0 }, { 146, 1.0 }, { 156, 1.0 }, { 162, 1.0 }, { 173, 1.0 }, { 178, 1.0 }, { 182, 1.0 }, { 184, 1.0 }, { 185, 1.0 }, { 243, 1.0 }, { 313, 1.0 }, { 326, 1.0 }, { 331, 1.0 }, { 332, 1.0 }, { 333, 1.0 }, { 334, 1.0 }, { 335, 1.0 }, { 363, 1.0 }, { 374, 1.0 }, { 387, 1.0 }, { 390, 1.0 }, { 400, 1.0 }, { 413, 1.0 }, { 415, 1.0 }, { 423, 1.0 }, { 464, 1.0 }, { 477, 0.5 }, { 490, 1.0 }, { 498, 1.0 }, { 499, 1.0 }, { 510, 0.4 }, { 519, 1.0 }, { 526, 1.0 }, { 528, 1.0 }, { 533, 1.0 }, { 543, 1.0 }, { 567, 1.0 }, { 568, 1.0 }, { 573, 1.0 }, { 574, 1.0 }, { 579, 1.0 }, { 584, 0.5 }, { 586, 1.0 }, { 601, 1.0 }, { 622, 1.0 }, { 634, 1.0 }, { 640, 1.0 }, { 643, 1.0 }, { 651, 1.0 }, { 653, 1.0 }, { 685, 1.0 }, { 686, 1.0 }, { 691, 0.5 }, { 696, 1.0 } }, -- angel
	                              { { 11, 1.0 }, { 16, 1.0 }, { 17, 1.0 }, { 20, 1.0 }, { 35, 1.0 }, { 84, 1.0 }, { 120, 1.0 }, { 121, 1.0 }, { 127, 1.0 }, { 168, 1.0 }, { 190, 1.0 }, { 213, 1.0 }, { 226, 1.0 }, { 242, 1.0 }, { 258, 1.0 }, { 262, 1.0 }, { 263, 1.0 }, { 271, 1.0 }, { 286, 1.0 }, { 287, 1.0 }, { 316, 1.0 }, { 321, 1.0 }, { 348, 1.0 }, { 388, 1.0 }, { 389, 1.0 }, { 402, 1.0 }, { 405, 1.0 }, { 424, 1.0 }, { 450, 1.0 }, { 489, 1.0 }, { 500, 1.0 }, { 501, 1.0 }, { 546, 1.0 }, { 562, 1.0 }, { 571, 1.0 }, { 580, 1.0 }, { 582, 1.0 }, { 609, 1.0 }, { 612, 1.0 }, { 625, 1.0 }, { 628, 1.0 }, { 632, 1.0 }, { 636, 1.0 }, { 664, 1.0 }, { 667, 1.0 }, { 669, 1.0 }, { 674, 1.0 }, { 675, 1.0 }, { 677, 1.0 }, { 688, 1.0 }, { 689, 1.0 }, { 691, 0.5 }, { 697, 0.5 }, { 700, 1.0 }, { 701, 1.0 }, { 703, 1.0 }, { 711, 1.0 }, { 716, 1.0 }, { 717, 1.0 }, { 719, 1.0 }, { 721, 1.0 }, { 723, 1.0 } }, -- secret
	                              { { 33, 1.0 }, { 34, 1.0 }, { 35, 1.0 }, { 58, 1.0 }, { 65, 1.0 }, { 78, 1.0 }, { 97, 1.0 }, { 123, 1.0 }, { 192, 1.0 }, { 282, 1.0 }, { 287, 1.0 }, { 292, 1.0 }, { 545, 1.0 }, { 584, 0.2 }, { 712, 0.2 } }, -- library
	                              { { 9, 1.0 }, { 36, 1.0 }, { 209, 1.0 }, { 378, 1.0 }, { 504, 1.0 }, { 576, 1.0 } }, -- shellGame
	                              { { 28, 1.0 }, { 29, 1.0 }, { 32, 1.0 }, { 74, 1.0 }, { 179, 0.5 }, { 194, 1.0 }, { 196, 1.0 }, { 255, 1.0 }, { 341, 1.0 }, { 343, 1.0 }, { 344, 1.0 }, { 354, 1.0 }, { 355, 1.0 }, { 370, 1.0 }, { 428, 0.5 }, { 438, 1.0 }, { 444, 0.1 }, { 455, 1.0 }, { 456, 1.0 }, { 534, 0.5 }, { 571, 0.1 }, { 644, 1.0 }, { 708, 1.0 }, { 730, 1.0 }, { 732, 1.0 } }, -- goldenChest
	                              { { 81, 1.0 }, { 133, 1.0 }, { 134, 1.0 }, { 140, 1.0 }, { 145, 1.0 }, { 212, 1.0 }, { 297, 1.0 }, { 316, 1.0 }, { 371, 1.0 }, { 475, 0.1 }, { 565, 0.5 }, { 580, 0.1 }, { 642, 1.0 }, { 654, 0.2 }, { 665, 1.0 } }, -- redChest
	                              { { 21, 1.0 }, { 22, 1.0 }, { 23, 1.0 }, { 24, 1.0 }, { 25, 1.0 }, { 26, 1.0 }, { 46, 1.0 }, { 54, 1.0 }, { 102, 1.0 }, { 111, 1.0 }, { 144, 1.0 }, { 177, 1.0 }, { 180, 1.0 }, { 195, 1.0 }, { 198, 1.0 }, { 204, 1.0 }, { 246, 1.0 }, { 271, 1.0 }, { 294, 1.0 }, { 362, 1.0 }, { 376, 1.0 }, { 385, 1.0 }, { 447, 1.0 }, { 455, 1.0 }, { 456, 1.0 }, { 485, 1.0 }, { 707, 1.0 } }, -- beggar
	                              { { 13, 1.0 }, { 14, 1.0 }, { 51, 1.0 }, { 70, 1.0 }, { 79, 1.0 }, { 80, 1.0 }, { 82, 0.2 }, { 83, 1.0 }, { 87, 1.0 }, { 102, 1.0 }, { 122, 1.0 }, { 126, 1.0 }, { 127, 0.5 }, { 143, 1.0 }, { 159, 0.2 }, { 195, 1.0 }, { 216, 1.0 }, { 225, 1.0 }, { 230, 0.2 }, { 240, 1.0 }, { 241, 1.0 }, { 259, 1.0 }, { 262, 1.0 }, { 278, 1.0 }, { 340, 1.0 }, { 345, 1.0 }, { 409, 1.0 }, { 420, 1.0 }, { 475, 0.2 }, { 487, 1.0 }, { 493, 1.0 }, { 496, 1.0 }, { 503, 1.0 }, { 672, 0.5 }, { 676, 1.0 } }, -- demonBeggar
	                              { { 51, 1.0 }, { 79, 1.0 }, { 80, 1.0 }, { 81, 1.0 }, { 133, 1.0 }, { 134, 1.0 }, { 145, 1.0 }, { 212, 1.0 }, { 215, 1.0 }, { 216, 1.0 }, { 225, 1.0 }, { 241, 1.0 }, { 260, 1.0 }, { 371, 1.0 }, { 408, 1.0 }, { 442, 1.0 }, { 451, 1.0 }, { 468, 1.0 }, { 475, 0.2 }, { 496, 1.0 }, { 503, 1.0 }, { 508, 1.0 }, { 536, 1.0 }, { 565, 1.0 }, { 569, 1.0 }, { 580, 1.0 }, { 642, 1.0 }, { 654, 0.5 }, { 692, 1.0 }, { 694, 0.5 }, { 697, 0.5 }, { 702, 1.0 }, { 711, 1.0 } }, -- curse
	                              { { 10, 1.0 }, { 57, 1.0 }, { 128, 1.0 }, { 175, 1.0 }, { 199, 1.0 }, { 264, 1.0 }, { 272, 1.0 }, { 279, 1.0 }, { 320, 1.0 }, { 343, 1.0 }, { 364, 1.0 }, { 365, 1.0 }, { 388, 1.0 }, { 426, 1.0 }, { 430, 1.0 }, { 492, 1.0 }, { 527, 1.0 }, { 580, 1.0 }, { 581, 1.0 }, { 629, 1.0 }, { 649, 1.0 }, { 693, 1.0 } }, -- keyMaster
	                              { { 63, 1.0 }, { 116, 1.0 }, { 205, 1.0 }, { 356, 1.0 }, { 372, 1.0 }, { 494, 0.1 }, { 520, 1.0 }, { 559, 0.1 }, { 603, 1.0 }, { 647, 1.0 } }, -- batteryBum
	                              { { 29, 1.0 }, { 30, 1.0 }, { 31, 1.0 }, { 39, 1.0 }, { 41, 1.0 }, { 55, 1.0 }, { 102, 1.0 }, { 110, 1.0 }, { 114, 0.1 }, { 139, 1.0 }, { 195, 1.0 }, { 199, 1.0 }, { 200, 1.0 }, { 217, 1.0 }, { 228, 1.0 }, { 355, 1.0 }, { 439, 1.0 }, { 508, 1.0 }, { 580, 0.5 }, { 732, 1.0 } }, -- momsChest
	                              { { 1, 1.0 }, { 2, 1.0 }, { 3, 1.0 }, { 4, 1.0 }, { 5, 1.0 }, { 6, 1.0 }, { 7, 1.0 }, { 8, 1.0 }, { 10, 1.0 }, { 12, 0.5 }, { 13, 1.0 }, { 34, 1.0 }, { 35, 1.0 }, { 37, 1.0 }, { 38, 1.0 }, { 42, 1.0 }, { 45, 1.0 }, { 47, 1.0 }, { 48, 1.0 }, { 50, 1.0 }, { 52, 1.0 }, { 55, 1.0 }, { 56, 1.0 }, { 57, 1.0 }, { 62, 1.0 }, { 64, 1.0 }, { 65, 1.0 }, { 67, 1.0 }, { 68, 1.0 }, { 69, 1.0 }, { 73, 1.0 }, { 77, 1.0 }, { 78, 1.0 }, { 85, 1.0 }, { 87, 1.0 }, { 88, 1.0 }, { 89, 1.0 }, { 93, 1.0 }, { 94, 1.0 }, { 95, 1.0 }, { 96, 1.0 }, { 97, 1.0 }, { 98, 0.2 }, { 99, 1.0 }, { 100, 1.0 }, { 101, 0.5 }, { 102, 1.0 }, { 103, 1.0 }, { 104, 1.0 }, { 106, 1.0 }, { 107, 1.0 }, { 108, 1.0 }, { 110, 1.0 }, { 111, 1.0 }, { 114, 0.2 }, { 115, 1.0 }, { 117, 1.0 }, { 120, 1.0 }, { 124, 1.0 }, { 125, 1.0 }, { 128, 1.0 }, { 131, 1.0 }, { 132, 1.0 }, { 137, 1.0 }, { 138, 1.0 }, { 140, 1.0 }, { 142, 1.0 }, { 146, 1.0 }, { 148, 1.0 }, { 149, 1.0 }, { 150, 1.0 }, { 151, 1.0 }, { 152, 1.0 }, { 153, 1.0 }, { 154, 1.0 }, { 155, 1.0 }, { 157, 1.0 }, { 161, 1.0 }, { 162, 1.0 }, { 163, 1.0 }, { 167, 1.0 }, { 169, 1.0 }, { 170, 1.0 }, { 172, 1.0 }, { 174, 1.0 }, { 175, 1.0 }, { 186, 1.0 }, { 188, 1.0 }, { 189, 1.0 }, { 191, 1.0 }, { 192, 1.0 }, { 200, 1.0 }, { 201, 1.0 }, { 206, 1.0 }, { 209, 1.0 }, { 210, 1.0 }, { 213, 1.0 }, { 214, 1.0 }, { 217, 1.0 }, { 220, 1.0 }, { 221, 1.0 }, { 222, 1.0 }, { 223, 0.5 }, { 224, 1.0 }, { 226, 1.0 }, { 228, 1.0 }, { 229, 1.0 }, { 231, 1.0 }, { 233, 1.0 }, { 234, 1.0 }, { 236, 1.0 }, { 237, 0.2 }, { 242, 1.0 }, { 244, 1.0 }, { 245, 1.0 }, { 254, 1.0 }, { 256, 1.0 }, { 257, 1.0 }, { 258, 0.1 }, { 261, 1.0 }, { 264, 1.0 }, { 265, 1.0 }, { 266, 1.0 }, { 267, 1.0 }, { 268, 1.0 }, { 269, 1.0 }, { 271, 1.0 }, { 273, 1.0 }, { 274, 1.0 }, { 277, 1.0 }, { 279, 1.0 }, { 280, 1.0 }, { 281, 1.0 }, { 288, 1.0 }, { 291, 1.0 }, { 299, 1.0 }, { 300, 1.0 }, { 301, 1.0 }, { 302, 1.0 }, { 303, 1.0 }, { 305, 1.0 }, { 306, 1.0 }, { 307, 1.0 }, { 308, 1.0 }, { 309, 1.0 }, { 310, 1.0 }, { 312, 1.0 }, { 315, 1.0 }, { 316, 1.0 }, { 317, 1.0 }, { 318, 1.0 }, { 319, 1.0 }, { 320, 1.0 }, { 321, 1.0 }, { 322, 1.0 }, { 325, 1.0 }, { 329, 1.0 }, { 330, 1.0 }, { 332, 1.0 }, { 333, 0.2 }, { 334, 0.2 }, { 335, 0.2 }, { 336, 1.0 }, { 349, 1.0 }, { 351, 1.0 }, { 352, 1.0 }, { 353, 1.0 }, { 357, 1.0 }, { 358, 1.0 }, { 359, 1.0 }, { 362, 1.0 }, { 364, 1.0 }, { 365, 1.0 }, { 366, 1.0 }, { 367, 1.0 }, { 368, 1.0 }, { 369, 1.0 }, { 371, 1.0 }, { 373, 1.0 }, { 374, 0.2 }, { 375, 1.0 }, { 377, 1.0 }, { 378, 1.0 }, { 379, 1.0 }, { 380, 1.0 }, { 382, 1.0 }, { 383, 1.0 }, { 384, 1.0 }, { 389, 1.0 }, { 391, 1.0 }, { 392, 1.0 }, { 393, 1.0 }, { 394, 1.0 }, { 395, 1.0 }, { 397, 1.0 }, { 398, 1.0 }, { 401, 1.0 }, { 407, 1.0 }, { 410, 1.0 }, { 411, 1.0 }, { 416, 1.0 }, { 421, 1.0 }, { 425, 1.0 }, { 426, 1.0 }, { 430, 1.0 }, { 431, 1.0 }, { 432, 1.0 }, { 434, 1.0 }, { 436, 1.0 }, { 440, 1.0 }, { 443, 1.0 }, { 444, 1.0 }, { 445, 1.0 }, { 446, 1.0 }, { 447, 1.0 }, { 448, 1.0 }, { 449, 1.0 }, { 450, 1.0 }, { 452, 1.0 }, { 453, 1.0 }, { 454, 1.0 }, { 457, 1.0 }, { 458, 1.0 }, { 459, 1.0 }, { 460, 1.0 }, { 461, 1.0 }, { 463, 1.0 }, { 465, 1.0 }, { 466, 1.0 }, { 467, 1.0 }, { 469, 1.0 }, { 470, 1.0 }, { 471, 1.0 }, { 473, 1.0 }, { 493, 1.0 }, { 494, 1.0 }, { 495, 1.0 }, { 496, 1.0 }, { 497, 1.0 }, { 502, 1.0 }, { 503, 1.0 }, { 504, 1.0 }, { 506, 1.0 }, { 507, 1.0 }, { 508, 1.0 }, { 509, 1.0 }, { 511, 1.0 }, { 512, 1.0 }, { 513, 1.0 }, { 514, 1.0 }, { 515, 1.0 }, { 516, 1.0 }, { 517, 1.0 }, { 518, 1.0 }, { 520, 1.0 }, { 522, 1.0 }, { 524, 1.0 }, { 525, 1.0 }, { 529, 1.0 }, { 531, 1.0 }, { 532, 1.0 }, { 537, 1.0 }, { 539, 1.0 }, { 540, 1.0 }, { 542, 1.0 }, { 543, 1.0 }, { 544, 1.0 }, { 545, 1.0 }, { 548, 1.0 }, { 549, 1.0 }, { 553, 1.0 }, { 555, 1.0 }, { 557, 1.0 }, { 558, 1.0 }, { 559, 1.0 }, { 560, 1.0 }, { 561, 1.0 }, { 563, 1.0 }, { 565, 1.0 }, { 570, 1.0 }, { 575, 1.0 }, { 576, 1.0 }, { 578, 1.0 }, { 581, 1.0 }, { 583, 1.0 }, { 605, 1.0 }, { 607, 1.0 }, { 608, 1.0 }, { 609, 0.5 }, { 610, 1.0 }, { 611, 1.0 }, { 612, 1.0 }, { 614, 1.0 }, { 615, 1.0 }, { 616, 1.0 }, { 617, 1.0 }, { 618, 1.0 }, { 625, 0.5 }, { 629, 1.0 }, { 631, 1.0 }, { 635, 1.0 }, { 637, 1.0 }, { 639, 1.0 }, { 641, 1.0 }, { 645, 1.0 }, { 649, 1.0 }, { 650, 0.5 }, { 652, 1.0 }, { 655, 1.0 }, { 657, 1.0 }, { 658, 1.0 }, { 661, 1.0 }, { 663, 1.0 }, { 671, 1.0 }, { 675, 1.0 }, { 676, 1.0 }, { 677, 0.5 }, { 678, 1.0 }, { 680, 1.0 }, { 681, 1.0 }, { 682, 1.0 }, { 683, 1.0 }, { 687, 1.0 }, { 690, 1.0 }, { 693, 1.0 }, { 695, 1.0 }, { 703, 0.5 }, { 709, 1.0 }, { 710, 1.0 }, { 713, 1.0 }, { 716, 0.2 }, { 717, 0.2 }, { 719, 0.2 }, { 720, 1.0 }, { 721, 0.1 }, { 722, 0.1 }, { 723, 0.1 }, { 724, 1.0 }, { 725, 1.0 }, { 726, 1.0 }, { 727, 1.0 }, { 728, 0.5 }, { 729, 1.0 } }, -- greedTreasure
	                              { { 12, 0.2 }, { 14, 1.0 }, { 15, 1.0 }, { 16, 1.0 }, { 22, 1.0 }, { 23, 1.0 }, { 24, 1.0 }, { 25, 1.0 }, { 26, 1.0 }, { 27, 1.0 }, { 28, 1.0 }, { 29, 1.0 }, { 30, 1.0 }, { 31, 1.0 }, { 32, 1.0 }, { 70, 1.0 }, { 71, 1.0 }, { 73, 1.0 }, { 101, 0.5 }, { 120, 1.0 }, { 132, 1.0 }, { 143, 1.0 }, { 176, 1.0 }, { 183, 1.0 }, { 193, 1.0 }, { 194, 1.0 }, { 195, 1.0 }, { 196, 1.0 }, { 197, 1.0 }, { 198, 1.0 }, { 199, 1.0 }, { 240, 1.0 }, { 253, 1.0 }, { 254, 1.0 }, { 255, 1.0 }, { 314, 1.0 }, { 339, 1.0 }, { 340, 1.0 }, { 341, 1.0 }, { 342, 1.0 }, { 343, 1.0 }, { 344, 1.0 }, { 345, 1.0 }, { 346, 1.0 }, { 354, 1.0 }, { 355, 1.0 }, { 370, 1.0 }, { 428, 0.5 }, { 438, 1.0 }, { 455, 1.0 }, { 456, 1.0 }, { 538, 1.0 }, { 541, 1.0 }, { 547, 1.0 }, { 564, 1.0 }, { 600, 1.0 }, { 624, 1.0 }, { 644, 1.0 }, { 659, 1.0 }, { 707, 1.0 }, { 708, 1.0 }, { 730, 1.0 }, { 731, 1.0 } }, -- greedBoss
	                              { { 11, 0.1 }, { 46, 1.0 }, { 63, 1.0 }, { 73, 1.0 }, { 75, 1.0 }, { 76, 1.0 }, { 84, 1.0 }, { 91, 1.0 }, { 105, 1.0 }, { 116, 1.0 }, { 139, 1.0 }, { 156, 1.0 }, { 166, 1.0 }, { 204, 1.0 }, { 208, 1.0 }, { 246, 1.0 }, { 247, 1.0 }, { 248, 1.0 }, { 251, 1.0 }, { 252, 1.0 }, { 260, 1.0 }, { 283, 1.0 }, { 284, 1.0 }, { 285, 1.0 }, { 286, 0.2 }, { 289, 1.0 }, { 297, 1.0 }, { 348, 1.0 }, { 356, 1.0 }, { 372, 1.0 }, { 380, 1.0 }, { 386, 1.0 }, { 402, 0.5 }, { 403, 1.0 }, { 405, 1.0 }, { 406, 1.0 }, { 416, 1.0 }, { 434, 1.0 }, { 439, 1.0 }, { 451, 1.0 }, { 472, 1.0 }, { 475, 0.2 }, { 476, 1.0 }, { 477, 1.0 }, { 478, 1.0 }, { 481, 1.0 }, { 482, 1.0 }, { 483, 0.5 }, { 485, 0.5 }, { 486, 1.0 }, { 487, 1.0 }, { 488, 1.0 }, { 489, 1.0 }, { 500, 1.0 }, { 505, 1.0 }, { 512, 1.0 }, { 515, 1.0 }, { 516, 1.0 }, { 518, 1.0 }, { 527, 1.0 }, { 534, 1.0 }, { 535, 1.0 }, { 566, 1.0 }, { 585, 1.0 }, { 603, 1.0 }, { 604, 1.0 }, { 619, 1.0 }, { 621, 1.0 }, { 623, 1.0 }, { 624, 1.0 }, { 636, 0.1 }, { 638, 1.0 }, { 647, 1.0 }, { 667, 0.1 }, { 674, 0.1 }, { 688, 0.1 }, { 689, 0.1 }, { 691, 0.1 }, { 692, 1.0 }, { 700, 0.1 }, { 701, 0.1 }, { 703, 0.1 }, { 711, 0.1 }, { 721, 0.1 }, { 722, 0.1 }, { 723, 0.1 }, { 732, 1.0 } }, -- greedShop
	                              { { 51, 1.0 }, { 73, 1.0 }, { 79, 1.0 }, { 80, 1.0 }, { 81, 1.0 }, { 133, 1.0 }, { 134, 1.0 }, { 145, 1.0 }, { 212, 1.0 }, { 216, 1.0 }, { 225, 1.0 }, { 260, 1.0 }, { 371, 1.0 }, { 408, 1.0 }, { 442, 1.0 }, { 451, 1.0 }, { 468, 1.0 }, { 475, 0.2 }, { 496, 1.0 }, { 503, 1.0 }, { 508, 1.0 }, { 536, 1.0 }, { 565, 1.0 }, { 569, 1.0 }, { 642, 1.0 }, { 654, 0.5 }, { 692, 1.0 }, { 694, 0.5 }, { 702, 1.0 }, { 711, 1.0 } }, -- greedCurse
	                              { { 34, 1.0 }, { 35, 1.0 }, { 51, 1.0 }, { 67, 1.0 }, { 68, 0.2 }, { 73, 1.0 }, { 74, 1.0 }, { 79, 1.0 }, { 80, 1.0 }, { 81, 1.0 }, { 82, 1.0 }, { 83, 1.0 }, { 97, 1.0 }, { 109, 1.0 }, { 113, 1.0 }, { 114, 1.0 }, { 115, 1.0 }, { 117, 1.0 }, { 118, 1.0 }, { 122, 1.0 }, { 123, 1.0 }, { 132, 1.0 }, { 133, 1.0 }, { 134, 1.0 }, { 145, 1.0 }, { 157, 1.0 }, { 159, 1.0 }, { 172, 1.0 }, { 187, 1.0 }, { 212, 1.0 }, { 216, 1.0 }, { 225, 1.0 }, { 230, 1.0 }, { 237, 1.0 }, { 259, 1.0 }, { 268, 1.0 }, { 269, 1.0 }, { 270, 1.0 }, { 292, 1.0 }, { 311, 1.0 }, { 360, 1.0 }, { 391, 1.0 }, { 399, 1.0 }, { 408, 1.0 }, { 409, 1.0 }, { 411, 1.0 }, { 412, 1.0 }, { 420, 1.0 }, { 431, 1.0 }, { 433, 1.0 }, { 441, 0.2 }, { 442, 1.0 }, { 451, 1.0 }, { 462, 1.0 }, { 468, 1.0 }, { 503, 1.0 }, { 519, 1.0 }, { 526, 1.0 }, { 536, 1.0 }, { 545, 1.0 }, { 554, 1.0 }, { 556, 1.0 }, { 569, 1.0 }, { 572, 1.0 }, { 577, 1.0 }, { 606, 1.0 }, { 634, 1.0 }, { 646, 1.0 }, { 654, 1.0 }, { 665, 1.0 }, { 679, 1.0 }, { 684, 1.0 }, { 692, 1.0 }, { 694, 0.5 }, { 695, 1.0 }, { 698, 1.0 }, { 699, 1.0 }, { 702, 1.0 }, { 704, 0.5 }, { 705, 0.5 }, { 706, 0.5 }, { 712, 0.5 }, { 728, 1.0 } }, -- greedDevil
	                              { { 7, 1.0 }, { 72, 1.0 }, { 73, 1.0 }, { 78, 1.0 }, { 112, 1.0 }, { 138, 1.0 }, { 162, 1.0 }, { 178, 1.0 }, { 182, 1.0 }, { 184, 1.0 }, { 185, 1.0 }, { 197, 1.0 }, { 243, 1.0 }, { 313, 1.0 }, { 331, 1.0 }, { 333, 1.0 }, { 334, 1.0 }, { 335, 1.0 }, { 363, 1.0 }, { 387, 1.0 }, { 390, 1.0 }, { 400, 1.0 }, { 407, 1.0 }, { 413, 1.0 }, { 415, 1.0 }, { 423, 1.0 }, { 464, 1.0 }, { 490, 1.0 }, { 499, 1.0 }, { 526, 1.0 }, { 528, 1.0 }, { 533, 1.0 }, { 543, 1.0 }, { 567, 1.0 }, { 568, 1.0 }, { 573, 1.0 }, { 574, 1.0 }, { 579, 1.0 }, { 584, 0.5 }, { 586, 1.0 }, { 601, 1.0 }, { 622, 1.0 }, { 634, 1.0 }, { 640, 1.0 }, { 643, 1.0 }, { 651, 1.0 }, { 653, 1.0 }, { 685, 1.0 }, { 686, 1.0 }, { 691, 0.5 }, { 696, 1.0 } }, -- greedAngel
	                              { { 11, 1.0 }, { 16, 1.0 }, { 17, 1.0 }, { 20, 1.0 }, { 35, 1.0 }, { 73, 1.0 }, { 84, 1.0 }, { 120, 1.0 }, { 121, 1.0 }, { 127, 1.0 }, { 168, 1.0 }, { 190, 1.0 }, { 213, 1.0 }, { 226, 1.0 }, { 242, 1.0 }, { 258, 1.0 }, { 262, 1.0 }, { 263, 1.0 }, { 271, 1.0 }, { 286, 1.0 }, { 316, 1.0 }, { 321, 1.0 }, { 348, 1.0 }, { 389, 1.0 }, { 402, 1.0 }, { 405, 1.0 }, { 424, 1.0 }, { 450, 1.0 }, { 489, 1.0 }, { 500, 1.0 }, { 501, 1.0 }, { 546, 1.0 }, { 562, 1.0 }, { 571, 1.0 }, { 582, 1.0 }, { 609, 1.0 }, { 612, 1.0 }, { 625, 1.0 }, { 628, 1.0 }, { 632, 1.0 }, { 636, 1.0 }, { 664, 1.0 }, { 667, 1.0 }, { 669, 1.0 }, { 674, 1.0 }, { 677, 1.0 }, { 688, 1.0 }, { 689, 1.0 }, { 691, 0.5 }, { 700, 1.0 }, { 701, 1.0 }, { 703, 1.0 }, { 711, 1.0 }, { 716, 1.0 }, { 717, 1.0 }, { 719, 1.0 }, { 721, 1.0 }, { 723, 1.0 } }, -- greedSecret
	                              { { 1, 1.0 }, { 3, 1.0 }, { 4, 1.0 }, { 5, 1.0 }, { 21, 1.0 }, { 32, 1.0 }, { 38, 1.0 }, { 44, 1.0 }, { 46, 1.0 }, { 47, 1.0 }, { 48, 1.0 }, { 49, 1.0 }, { 51, 1.0 }, { 63, 1.0 }, { 66, 1.0 }, { 68, 1.0 }, { 77, 1.0 }, { 85, 1.0 }, { 89, 1.0 }, { 90, 1.0 }, { 91, 1.0 }, { 93, 1.0 }, { 95, 1.0 }, { 102, 1.0 }, { 105, 1.0 }, { 116, 1.0 }, { 136, 1.0 }, { 137, 1.0 }, { 147, 1.0 }, { 152, 1.0 }, { 153, 1.0 }, { 166, 1.0 }, { 189, 1.0 }, { 194, 1.0 }, { 196, 1.0 }, { 208, 1.0 }, { 212, 1.0 }, { 227, 1.0 }, { 232, 1.0 }, { 244, 1.0 }, { 251, 1.0 }, { 255, 1.0 }, { 263, 1.0 }, { 267, 1.0 }, { 283, 1.0 }, { 284, 1.0 }, { 285, 1.0 }, { 337, 1.0 }, { 338, 1.0 }, { 352, 1.0 }, { 357, 1.0 }, { 362, 1.0 }, { 370, 1.0 }, { 382, 1.0 }, { 383, 1.0 }, { 386, 1.0 }, { 395, 1.0 }, { 397, 1.0 }, { 403, 1.0 }, { 406, 1.0 }, { 419, 1.0 }, { 422, 1.0 }, { 425, 1.0 }, { 427, 1.0 }, { 437, 1.0 }, { 438, 1.0 }, { 439, 1.0 }, { 444, 1.0 }, { 451, 1.0 }, { 465, 1.0 }, { 476, 1.0 }, { 478, 1.0 }, { 488, 1.0 }, { 494, 1.0 }, { 505, 1.0 }, { 515, 1.0 }, { 516, 1.0 }, { 518, 1.0 }, { 524, 1.0 }, { 527, 1.0 }, { 538, 1.0 }, { 599, 1.0 }, { 604, 1.0 }, { 609, 1.0 }, { 617, 1.0 }, { 624, 1.0 }, { 629, 1.0 }, { 638, 1.0 }, { 644, 1.0 }, { 649, 1.0 }, { 655, 1.0 }, { 687, 1.0 }, { 709, 1.0 }, { 720, 1.0 }, { 723, 1.0 }, { 730, 1.0 } }, -- craneGame
	                              { { 12, 1.0 }, { 13, 1.0 }, { 15, 1.0 }, { 30, 1.0 }, { 31, 1.0 }, { 40, 1.0 }, { 45, 1.0 }, { 49, 1.0 }, { 51, 1.0 }, { 53, 1.0 }, { 67, 1.0 }, { 72, 1.0 }, { 73, 1.0 }, { 79, 1.0 }, { 80, 1.0 }, { 82, 1.0 }, { 96, 1.0 }, { 105, 1.0 }, { 109, 1.0 }, { 110, 1.0 }, { 118, 1.0 }, { 119, 1.0 }, { 122, 1.0 }, { 135, 1.0 }, { 137, 1.0 }, { 157, 1.0 }, { 159, 1.0 }, { 166, 1.0 }, { 167, 1.0 }, { 176, 1.0 }, { 177, 1.0 }, { 182, 1.0 }, { 193, 1.0 }, { 208, 1.0 }, { 214, 1.0 }, { 230, 1.0 }, { 247, 1.0 }, { 253, 1.0 }, { 254, 1.0 }, { 261, 1.0 }, { 276, 1.0 }, { 289, 1.0 }, { 334, 1.0 }, { 373, 1.0 }, { 394, 1.0 }, { 399, 1.0 }, { 411, 1.0 }, { 412, 1.0 }, { 421, 1.0 }, { 435, 1.0 }, { 443, 1.0 }, { 452, 1.0 }, { 462, 1.0 }, { 466, 1.0 }, { 475, 1.0 }, { 481, 1.0 }, { 506, 1.0 }, { 511, 1.0 }, { 531, 1.0 }, { 541, 1.0 }, { 554, 1.0 }, { 556, 1.0 }, { 565, 1.0 }, { 572, 1.0 }, { 573, 1.0 }, { 580, 1.0 }, { 606, 1.0 }, { 607, 1.0 }, { 614, 1.0 }, { 616, 1.0 }, { 618, 1.0 }, { 621, 1.0 }, { 637, 1.0 }, { 650, 1.0 }, { 654, 1.0 }, { 657, 1.0 }, { 671, 1.0 }, { 682, 1.0 }, { 684, 1.0 }, { 692, 1.0 }, { 694, 1.0 }, { 695, 1.0 }, { 700, 1.0 }, { 702, 1.0 }, { 703, 1.0 }, { 704, 1.0 }, { 705, 1.0 }, { 706, 1.0 }, { 711, 1.0 }, { 724, 1.0 }, { 726, 1.0 }, { 728, 1.0 } }, -- ultraSecret
	                              { { 37, 1.0 }, { 106, 1.0 }, { 125, 1.0 }, { 137, 1.0 }, { 140, 1.0 }, { 190, 0.2 }, { 209, 1.0 }, { 220, 1.0 }, { 256, 1.0 }, { 353, 0.2 }, { 366, 1.0 }, { 367, 1.0 }, { 432, 1.0 }, { 483, 1.0 }, { 517, 1.0 }, { 563, 1.0 }, { 583, 1.0 }, { 614, 1.0 }, { 646, 0.2 }, { 727, 1.0 } }, -- bombBum
	                              { { 588, 1.0 }, { 589, 1.0 }, { 590, 1.0 }, { 591, 1.0 }, { 592, 1.0 }, { 593, 1.0 }, { 594, 1.0 }, { 595, 1.0 }, { 596, 1.0 }, { 597, 1.0 }, { 598, 1.0 } }, -- planetarium
	                              { { 29, 1.0 }, { 30, 1.0 }, { 31, 1.0 }, { 39, 1.0 }, { 41, 1.0 }, { 55, 1.0 }, { 102, 1.0 }, { 110, 1.0 }, { 114, 0.2 }, { 139, 1.0 }, { 175, 1.0 }, { 195, 1.0 }, { 199, 1.0 }, { 200, 1.0 }, { 217, 1.0 }, { 228, 1.0 }, { 341, 1.0 }, { 355, 1.0 }, { 439, 1.0 }, { 455, 1.0 }, { 508, 1.0 }, { 546, 0.2 }, { 547, 1.0 }, { 604, 1.0 } }, -- oldChest
	                              { { 8, 1.0 }, { 10, 1.0 }, { 57, 1.0 }, { 67, 1.0 }, { 73, 1.0 }, { 88, 1.0 }, { 95, 1.0 }, { 96, 1.0 }, { 99, 1.0 }, { 100, 1.0 }, { 112, 1.0 }, { 113, 1.0 }, { 117, 1.0 }, { 128, 1.0 }, { 144, 1.0 }, { 155, 1.0 }, { 163, 1.0 }, { 167, 1.0 }, { 170, 1.0 }, { 172, 1.0 }, { 174, 1.0 }, { 188, 1.0 }, { 207, 1.0 }, { 264, 1.0 }, { 265, 1.0 }, { 266, 1.0 }, { 267, 1.0 }, { 268, 1.0 }, { 269, 1.0 }, { 270, 1.0 }, { 272, 1.0 }, { 273, 1.0 }, { 274, 1.0 }, { 275, 1.0 }, { 277, 1.0 }, { 278, 1.0 }, { 279, 1.0 }, { 280, 1.0 }, { 281, 1.0 }, { 320, 1.0 }, { 322, 1.0 }, { 360, 1.0 }, { 361, 1.0 }, { 363, 1.0 }, { 364, 1.0 }, { 365, 1.0 }, { 372, 1.0 }, { 384, 1.0 }, { 385, 1.0 }, { 388, 1.0 }, { 390, 1.0 }, { 403, 1.0 }, { 404, 1.0 }, { 417, 1.0 }, { 426, 1.0 }, { 430, 1.0 }, { 435, 1.0 }, { 468, 1.0 }, { 470, 1.0 }, { 471, 1.0 }, { 472, 1.0 }, { 473, 1.0 }, { 491, 1.0 }, { 492, 1.0 }, { 509, 1.0 }, { 511, 1.0 }, { 518, 1.0 }, { 519, 1.0 }, { 537, 1.0 }, { 575, 1.0 }, { 581, 1.0 }, { 607, 1.0 }, { 608, 1.0 }, { 610, 1.0 }, { 612, 1.0 }, { 615, 1.0 }, { 629, 1.0 }, { 635, 1.0 }, { 645, 1.0 }, { 649, 1.0 }, { 661, 1.0 }, { 679, 1.0 }, { 682, 1.0 }, { 698, 1.0 } }, -- babyShop
	                              { { 7, 1.0 }, { 27, 1.0 }, { 60, 1.0 }, { 138, 1.0 }, { 183, 1.0 }, { 349, 1.0 }, { 362, 1.0 }, { 439, 1.0 }, { 488, 1.0 }, { 527, 1.0 }, { 719, 1.0 } }, -- woodenChest
	                              { { 26, 1.0 }, { 42, 1.0 }, { 140, 1.0 }, { 268, 1.0 }, { 273, 1.0 }, { 336, 0.5 }, { 480, 1.0 }, { 618, 0.5 }, { 639, 1.0 } }, -- rottenBeggar
	}

	--The quality of each item, for use in Bag of Crafting
	coopHUD.XMLItemQualities = { [1] = 3, [2] = 2, [3] = 3, [4] = 4, [5] = 0, [6] = 2, [7] = 3, [8] = 1, [9] = 0, [10] = 2, [11] = 2, [12] = 4, [13] = 2, [14] = 2, [15] = 2, [16] = 2, [17] = 3, [18] = 3, [19] = 0, [20] = 3, [21] = 2, [22] = 1, [23] = 1, [24] = 1, [25] = 1, [26] = 1, [27] = 1, [28] = 1, [29] = 1, [30] = 1, [31] = 1, [32] = 3, [33] = 1, [34] = 2, [35] = 1, [36] = 0, [37] = 1, [38] = 2, [39] = 1, [40] = 0, [41] = 0, [42] = 1, [44] = 0, [45] = 1, [46] = 2, [47] = 1, [48] = 3, [49] = 2, [50] = 3, [51] = 3, [52] = 4, [53] = 1, [54] = 2, [55] = 1, [56] = 1, [57] = 2, [58] = 3, [59] = 0, [60] = 1, [62] = 1, [63] = 2, [64] = 2, [65] = 1, [66] = 1, [67] = 1, [68] = 3, [69] = 3, [70] = 3, [71] = 2, [72] = 2, [73] = 2, [74] = 1, [75] = 2, [76] = 2, [77] = 1, [78] = 3, [79] = 3, [80] = 3, [81] = 3, [82] = 3, [83] = 3, [84] = 0, [85] = 2, [86] = 1, [87] = 1, [88] = 1, [89] = 2, [90] = 3, [91] = 2, [92] = 2, [93] = 2, [94] = 1, [95] = 1, [96] = 2, [97] = 2, [98] = 4, [99] = 2, [100] = 1, [101] = 2, [102] = 1, [103] = 1, [104] = 3, [105] = 4, [106] = 2, [107] = 2, [108] = 4, [109] = 3, [110] = 3, [111] = 0, [112] = 2, [113] = 2, [114] = 4, [115] = 2, [116] = 2, [117] = 0, [118] = 4, [119] = 2, [120] = 2, [121] = 2, [122] = 2, [123] = 1, [124] = 1, [125] = 2, [126] = 0, [127] = 3, [128] = 1, [129] = 1, [130] = 2, [131] = 2, [132] = 3, [133] = 3, [134] = 2, [135] = 1, [136] = 1, [137] = 1, [138] = 2, [139] = 3, [140] = 1, [141] = 0, [142] = 2, [143] = 2, [144] = 0, [145] = 3, [146] = 3, [147] = 1, [148] = 0, [149] = 4, [150] = 3, [151] = 3, [152] = 2, [153] = 3, [154] = 2, [155] = 2, [156] = 2, [157] = 3, [158] = 3, [159] = 3, [160] = 2, [161] = 1, [162] = 1, [163] = 1, [164] = 2, [165] = 3, [166] = 2, [167] = 1, [168] = 4, [169] = 4, [170] = 3, [171] = 1, [172] = 2, [173] = 3, [174] = 1, [175] = 1, [176] = 1, [177] = 0, [178] = 3, [179] = 3, [180] = 0, [181] = 2, [182] = 4, [183] = 3, [184] = 3, [185] = 3, [186] = 0, [187] = 1, [188] = 0, [189] = 3, [190] = 3, [191] = 2, [192] = 1, [193] = 2, [194] = 1, [195] = 1, [196] = 3, [197] = 2, [198] = 1, [199] = 3, [200] = 1, [201] = 3, [202] = 2, [203] = 3, [204] = 1, [205] = 1, [206] = 2, [207] = 2, [208] = 3, [209] = 2, [210] = 1, [211] = 1, [212] = 2, [213] = 2, [214] = 1, [215] = 3, [216] = 3, [217] = 3, [218] = 2, [219] = 2, [220] = 2, [221] = 3, [222] = 2, [223] = 4, [224] = 3, [225] = 2, [226] = 2, [227] = 1, [228] = 2, [229] = 2, [230] = 3, [231] = 2, [232] = 4, [233] = 0, [234] = 4, [236] = 1, [237] = 3, [238] = 0, [239] = 0, [240] = 1, [241] = 3, [242] = 2, [243] = 3, [244] = 3, [245] = 4, [246] = 2, [247] = 2, [248] = 2, [249] = 3, [250] = 1, [251] = 2, [252] = 1, [253] = 2, [254] = 2, [255] = 3, [256] = 1, [257] = 2, [258] = 1, [259] = 3, [260] = 3, [261] = 4, [262] = 0, [263] = 2, [264] = 2, [265] = 3, [266] = 2, [267] = 1, [268] = 3, [269] = 1, [270] = 1, [271] = 2, [272] = 1, [273] = 1, [274] = 0, [275] = 3, [276] = 0, [277] = 1, [278] = 3, [279] = 2, [280] = 1, [281] = 1, [282] = 1, [283] = 3, [284] = 3, [285] = 0, [286] = 2, [287] = 0, [288] = 1, [289] = 2, [290] = 0, [291] = 1, [292] = 4, [293] = 2, [294] = 1, [295] = 1, [296] = 2, [297] = 2, [298] = 1, [299] = 1, [300] = 2, [301] = 3, [302] = 1, [303] = 2, [304] = 1, [305] = 3, [306] = 3, [307] = 3, [308] = 1, [309] = 2, [310] = 2, [311] = 3, [312] = 2, [313] = 4, [314] = 1, [315] = 0, [316] = 0, [317] = 3, [318] = 1, [319] = 0, [320] = 2, [321] = 1, [322] = 2, [323] = 0, [324] = 2, [325] = 1, [326] = 0, [327] = 2, [328] = 2, [329] = 2, [330] = 2, [331] = 4, [332] = 1, [333] = 3, [334] = 3, [335] = 3, [336] = 3, [337] = 1, [338] = 2, [339] = 1, [340] = 1, [341] = 3, [342] = 3, [343] = 2, [344] = 1, [345] = 3, [346] = 1, [347] = 3, [348] = 2, [349] = 1, [350] = 3, [351] = 1, [352] = 1, [353] = 2, [354] = 2, [355] = 2, [356] = 3, [357] = 1, [358] = 1, [359] = 3, [360] = 4, [361] = 2, [362] = 2, [363] = 3, [364] = 1, [365] = 1, [366] = 1, [367] = 1, [368] = 1, [369] = 2, [370] = 3, [371] = 1, [372] = 3, [373] = 3, [374] = 3, [375] = 3, [376] = 2, [377] = 1, [378] = 2, [379] = 2, [380] = 2, [381] = 3, [382] = 2, [383] = 1, [384] = 2, [385] = 1, [386] = 0, [387] = 3, [388] = 0, [389] = 3, [390] = 3, [391] = 0, [392] = 1, [393] = 2, [394] = 1, [395] = 4, [396] = 1, [397] = 3, [398] = 1, [399] = 4, [400] = 1, [401] = 2, [402] = 3, [403] = 1, [404] = 1, [405] = 1, [406] = 2, [407] = 2, [408] = 1, [409] = 2, [410] = 2, [411] = 3, [412] = 2, [413] = 1, [414] = 3, [415] = 4, [416] = 2, [417] = 3, [418] = 2, [419] = 3, [420] = 1, [421] = 1, [422] = 3, [423] = 2, [424] = 3, [425] = 2, [426] = 0, [427] = 1, [428] = 2, [429] = 2, [430] = 1, [431] = 2, [432] = 2, [433] = 0, [434] = 2, [435] = 1, [436] = 1, [437] = 1, [438] = 3, [439] = 3, [440] = 2, [441] = 4, [442] = 1, [443] = 3, [444] = 3, [445] = 1, [446] = 1, [447] = 0, [448] = 1, [449] = 1, [450] = 2, [451] = 3, [452] = 2, [453] = 2, [454] = 2, [455] = 2, [456] = 1, [457] = 2, [458] = 3, [459] = 3, [460] = 2, [461] = 3, [462] = 3, [463] = 2, [464] = 2, [465] = 2, [466] = 2, [467] = 1, [468] = 0, [469] = 1, [470] = 0, [471] = 2, [472] = 1, [473] = 1, [474] = 0, [475] = 0, [476] = 3, [477] = 4, [478] = 1, [479] = 3, [480] = 2, [481] = 0, [482] = 0, [483] = 3, [484] = 1, [485] = 1, [486] = 1, [487] = 2, [488] = 1, [489] = 4, [490] = 3, [491] = 2, [492] = 2, [493] = 1, [494] = 3, [495] = 3, [496] = 3, [497] = 0, [498] = 1, [499] = 3, [500] = 3, [501] = 1, [502] = 1, [503] = 3, [504] = 0, [505] = 1, [506] = 1, [507] = 2, [508] = 0, [509] = 1, [510] = 1, [511] = 1, [512] = 1, [513] = 2, [514] = 2, [515] = 3, [516] = 2, [517] = 1, [518] = 2, [519] = 2, [520] = 3, [521] = 2, [522] = 1, [523] = 1, [524] = 3, [525] = 1, [526] = 2, [527] = 3, [528] = 3, [529] = 2, [530] = 2, [531] = 3, [532] = 2, [533] = 2, [534] = 3, [535] = 2, [536] = 2, [537] = 1, [538] = 2, [539] = 1, [540] = 2, [541] = 1, [542] = 2, [543] = 1, [544] = 2, [545] = 3, [546] = 3, [547] = 3, [548] = 1, [549] = 3, [550] = 4, [551] = 4, [552] = 4, [553] = 3, [554] = 2, [555] = 2, [556] = 3, [557] = 2, [558] = 2, [559] = 2, [560] = 1, [561] = 1, [562] = 3, [563] = 1, [564] = 3, [565] = 1, [566] = 2, [567] = 3, [568] = 2, [569] = 2, [570] = 3, [571] = 2, [572] = 3, [573] = 3, [574] = 2, [575] = 3, [576] = 2, [577] = 2, [578] = 1, [579] = 3, [580] = 3, [581] = 4, [582] = 1, [583] = 2, [584] = 3, [585] = 2, [586] = 3, [588] = 2, [589] = 2, [590] = 3, [591] = 2, [592] = 3, [593] = 2, [594] = 2, [595] = 2, [596] = 3, [597] = 3, [598] = 3, [599] = 1, [600] = 3, [601] = 3, [602] = 1, [603] = 1, [604] = 2, [605] = 0, [606] = 3, [607] = 1, [608] = 2, [609] = 3, [610] = 1, [611] = 2, [612] = 2, [614] = 2, [615] = 0, [616] = 3, [617] = 3, [618] = 2, [619] = 3, [621] = 2, [622] = 2, [623] = 1, [624] = 1, [625] = 4, [626] = 0, [627] = 0, [628] = 4, [629] = 3, [631] = 1, [632] = 2, [633] = 0, [634] = 2, [635] = 1, [636] = 4, [637] = 3, [638] = 2, [639] = 2, [640] = 3, [641] = 2, [642] = 2, [643] = 4, [644] = 1, [645] = 1, [646] = 3, [647] = 2, [649] = 1, [650] = 2, [651] = 3, [652] = 1, [653] = 3, [654] = 2, [655] = 1, [656] = 2, [657] = 2, [658] = 1, [659] = 1, [660] = 3, [661] = 2, [663] = 2, [664] = 4, [665] = 2, [667] = 2, [668] = 0, [669] = 3, [670] = 2, [671] = 2, [672] = 1, [673] = 2, [674] = 2, [675] = 1, [676] = 2, [677] = 2, [678] = 4, [679] = 3, [680] = 3, [681] = 1, [682] = 3, [683] = 2, [684] = 3, [685] = 2, [686] = 2, [687] = 3, [688] = 2, [689] = 4, [690] = 3, [691] = 4, [692] = 1, [693] = 2, [694] = 3, [695] = 3, [696] = 3, [697] = 3, [698] = 4, [699] = 3, [700] = 2, [701] = 3, [702] = 2, [703] = 2, [704] = 3, [705] = 3, [706] = 4, [707] = 1, [708] = 3, [709] = 3, [710] = 4, [711] = 4, [712] = 3, [713] = 3, [714] = 0, [715] = 0, [716] = 3, [717] = 2, [719] = 2, [720] = 2, [721] = 2, [722] = 3, [723] = 4, [724] = 3, [725] = 2, [726] = 3, [727] = 2, [728] = 3, [729] = 2, [730] = 3, [731] = 2, [732] = 3, }

	--The pools that each item is in, for roughly checking if a given item is unlocked
	coopHUD.XMLItemIsInPools = { [1] = { 0, 16, 23 }, [2] = { 0, 16 }, [3] = { 0, 16, 23 }, [4] = { 0, 16, 23 }, [5] = { 0, 16, 23 }, [6] = { 0, 16 }, [7] = { 0, 4, 16, 21, 29 }, [8] = { 0, 3, 16, 28 }, [9] = { 7 }, [10] = { 0, 13, 16, 28 }, [11] = { 5, 18, 22 }, [12] = { 0, 16, 17, 24 }, [13] = { 0, 11, 16, 24 }, [14] = { 0, 2, 11, 17 }, [15] = { 0, 17, 24 }, [16] = { 5, 17, 22 }, [17] = { 0, 5, 22 }, [18] = {}, [19] = { 0 }, [20] = { 5, 22 }, [21] = { 1, 10, 23 }, [22] = { 2, 10, 17 }, [23] = { 2, 10, 17 }, [24] = { 2, 10, 17 }, [25] = { 2, 10, 17 }, [26] = { 2, 10, 17, 30 }, [27] = { 2, 17, 29 }, [28] = { 2, 8, 17 }, [29] = { 2, 8, 15, 17, 27 }, [30] = { 2, 15, 17, 24, 27 }, [31] = { 2, 15, 17, 24, 27 }, [32] = { 2, 8, 17, 23 }, [33] = { 1, 4, 6 }, [34] = { 3, 6, 16, 20 }, [35] = { 3, 5, 6, 16, 20, 22 }, [36] = { 0, 7 }, [37] = { 0, 16, 25 }, [38] = { 0, 16, 23 }, [39] = { 0, 15, 27 }, [40] = { 0, 24 }, [41] = { 0, 15, 27 }, [42] = { 0, 16, 30 }, [44] = { 0, 23 }, [45] = { 0, 16, 24 }, [46] = { 0, 10, 18, 23 }, [47] = { 0, 16, 23 }, [48] = { 0, 16, 23 }, [49] = { 0, 23, 24 }, [50] = { 16 }, [51] = { 2, 3, 11, 12, 19, 20, 23, 24 }, [52] = { 0, 16 }, [53] = { 0, 24 }, [54] = { 1, 10 }, [55] = { 0, 15, 16, 27 }, [56] = { 0, 16 }, [57] = { 0, 13, 16, 28 }, [58] = { 0, 6 }, [59] = {}, [60] = { 1, 29 }, [62] = { 0, 16 }, [63] = { 1, 14, 18, 23 }, [64] = { 1, 16 }, [65] = { 0, 6, 16 }, [66] = { 0, 23 }, [67] = { 0, 3, 16, 20, 24, 28 }, [68] = { 0, 16, 20, 23 }, [69] = { 0, 16 }, [70] = { 2, 11, 17 }, [71] = { 0, 17 }, [72] = { 0, 4, 21, 24 }, [73] = { 16, 17, 18, 19, 20, 21, 22, 24, 28 }, [74] = { 3, 8, 20 }, [75] = { 0, 1, 18 }, [76] = { 0, 18 }, [77] = { 0, 16, 23 }, [78] = { 0, 6, 16, 21 }, [79] = { 3, 11, 12, 19, 20, 24 }, [80] = { 3, 11, 12, 19, 20, 24 }, [81] = { 3, 9, 12, 19, 20 }, [82] = { 3, 11, 20, 24 }, [83] = { 3, 11, 20 }, [84] = { 3, 5, 18, 22 }, [85] = { 0, 1, 16, 23 }, [86] = { 0 }, [87] = { 0, 11, 16 }, [88] = { 0, 16, 28 }, [89] = { 0, 16, 23 }, [90] = { 23 }, [91] = { 0, 18, 23 }, [92] = { 0, 2 }, [93] = { 0, 16, 23 }, [94] = { 0, 16 }, [95] = { 0, 16, 23, 28 }, [96] = { 0, 16, 24, 28 }, [97] = { 0, 3, 6, 16, 20 }, [98] = { 0, 4, 16 }, [99] = { 0, 16, 28 }, [100] = { 0, 16, 28 }, [101] = { 0, 4, 16, 17 }, [102] = { 0, 1, 10, 11, 15, 16, 23, 27 }, [103] = { 0, 16 }, [104] = { 0, 16 }, [105] = { 0, 18, 23, 24 }, [106] = { 0, 16, 25 }, [107] = { 0, 16 }, [108] = { 0, 4, 16 }, [109] = { 0, 3, 20, 24 }, [110] = { 0, 15, 16, 24, 27 }, [111] = { 0, 10, 16 }, [112] = { 4, 21, 28 }, [113] = { 0, 3, 20, 28 }, [114] = { 0, 3, 15, 16, 20, 27 }, [115] = { 0, 3, 16, 20 }, [116] = { 1, 14, 18, 23 }, [117] = { 0, 16, 20, 28 }, [118] = { 3, 20, 24 }, [119] = { 24 }, [120] = { 0, 5, 16, 17, 22 }, [121] = { 0, 5, 22 }, [122] = { 3, 11, 20, 24 }, [123] = { 0, 3, 6, 20 }, [124] = { 0, 4, 16 }, [125] = { 0, 16, 25 }, [126] = { 3, 11 }, [127] = { 0, 3, 5, 11, 22 }, [128] = { 0, 13, 16, 28 }, [129] = { 0 }, [130] = {}, [131] = { 0, 16 }, [132] = { 16, 17, 20 }, [133] = { 3, 9, 12, 19, 20 }, [134] = { 3, 9, 12, 19, 20 }, [135] = { 24 }, [136] = { 0, 23 }, [137] = { 0, 1, 16, 23, 24, 25 }, [138] = { 0, 16, 21, 29 }, [139] = { 1, 15, 18, 27 }, [140] = { 0, 9, 16, 25, 30 }, [141] = { 2 }, [142] = { 0, 4, 16 }, [143] = { 0, 2, 11, 17 }, [144] = { 0, 10, 28 }, [145] = { 3, 9, 12, 19, 20 }, [146] = { 0, 4, 16 }, [147] = { 1, 23 }, [148] = { 0, 16 }, [149] = { 0, 16 }, [150] = { 0, 16 }, [151] = { 0, 16 }, [152] = { 0, 16, 23 }, [153] = { 0, 16, 23 }, [154] = { 0, 16 }, [155] = { 0, 16, 28 }, [156] = { 1, 4, 18 }, [157] = { 0, 3, 16, 20, 24 }, [158] = {}, [159] = { 3, 11, 20, 24 }, [160] = { 0 }, [161] = { 0, 16 }, [162] = { 0, 4, 16, 21 }, [163] = { 0, 3, 16, 28 }, [164] = { 1 }, [165] = { 2 }, [166] = { 0, 18, 23, 24 }, [167] = { 0, 16, 24, 28 }, [168] = { 5, 22 }, [169] = { 0, 16 }, [170] = { 0, 16, 28 }, [171] = { 0 }, [172] = { 0, 3, 16, 20, 28 }, [173] = { 0, 4 }, [174] = { 0, 16, 28 }, [175] = { 0, 13, 16, 27 }, [176] = { 0, 2, 17, 24 }, [177] = { 1, 10, 24 }, [178] = { 0, 4, 21 }, [179] = { 8 }, [180] = { 0, 10 }, [181] = {}, [182] = { 4, 21, 24 }, [183] = { 2, 17, 29 }, [184] = { 4, 21 }, [185] = { 4, 21 }, [186] = { 0, 16 }, [187] = { 3, 20 }, [188] = { 0, 16, 28 }, [189] = { 0, 16, 23 }, [190] = { 0, 5, 22, 25 }, [191] = { 0, 16 }, [192] = { 0, 6, 16 }, [193] = { 2, 17, 24 }, [194] = { 2, 8, 17, 23 }, [195] = { 1, 2, 10, 11, 15, 17, 27 }, [196] = { 2, 8, 17, 23 }, [197] = { 2, 17, 21 }, [198] = { 2, 10, 17 }, [199] = { 1, 13, 15, 17, 27 }, [200] = { 0, 15, 16, 27 }, [201] = { 0, 16 }, [202] = { 0 }, [203] = { 1 }, [204] = { 1, 10, 18 }, [205] = { 1, 14 }, [206] = { 0, 16 }, [207] = { 28 }, [208] = { 1, 18, 23, 24 }, [209] = { 0, 7, 16, 25 }, [210] = { 0, 16 }, [211] = { 0 }, [212] = { 3, 9, 12, 19, 20, 23 }, [213] = { 0, 5, 16, 22 }, [214] = { 0, 16, 24 }, [215] = { 3, 12 }, [216] = { 3, 11, 12, 19, 20 }, [217] = { 0, 15, 16, 27 }, [218] = { 2 }, [219] = { 2 }, [220] = { 0, 16, 25 }, [221] = { 0, 16 }, [222] = { 0, 16 }, [223] = { 0, 16 }, [224] = { 0, 16 }, [225] = { 0, 3, 11, 12, 19, 20 }, [226] = { 5, 16, 22 }, [227] = { 0, 1, 23 }, [228] = { 0, 15, 16, 27 }, [229] = { 0, 16 }, [230] = { 3, 11, 20, 24 }, [231] = { 0, 16 }, [232] = { 1, 23 }, [233] = { 0, 16 }, [234] = { 0, 16 }, [236] = { 0, 16 }, [237] = { 0, 3, 16, 20 }, [238] = {}, [239] = {}, [240] = { 0, 2, 11, 17 }, [241] = { 3, 11, 12 }, [242] = { 0, 5, 16, 22 }, [243] = { 4, 21 }, [244] = { 0, 16, 23 }, [245] = { 0, 16 }, [246] = { 1, 10, 18 }, [247] = { 1, 18, 24 }, [248] = { 1, 18 }, [249] = { 1 }, [250] = { 1 }, [251] = { 1, 18, 23 }, [252] = { 1, 18 }, [253] = { 2, 17, 24 }, [254] = { 2, 16, 17, 24 }, [255] = { 2, 8, 17, 23 }, [256] = { 0, 16, 25 }, [257] = { 0, 16 }, [258] = { 5, 16, 22 }, [259] = { 3, 11, 20 }, [260] = { 1, 12, 18, 19 }, [261] = { 0, 16, 24 }, [262] = { 3, 5, 11, 22 }, [263] = { 5, 22, 23 }, [264] = { 0, 13, 16, 28 }, [265] = { 0, 16, 28 }, [266] = { 0, 16, 28 }, [267] = { 0, 16, 23, 28 }, [268] = { 0, 3, 16, 20, 28, 30 }, [269] = { 0, 3, 16, 20, 28 }, [270] = { 0, 20, 28 }, [271] = { 0, 5, 10, 16, 22 }, [272] = { 0, 13, 28 }, [273] = { 0, 16, 28, 30 }, [274] = { 0, 16, 28 }, [275] = { 0, 3, 28 }, [276] = { 0, 24 }, [277] = { 0, 16, 28 }, [278] = { 0, 3, 11, 28 }, [279] = { 0, 13, 16, 28 }, [280] = { 0, 16, 28 }, [281] = { 0, 16, 28 }, [282] = { 0, 6 }, [283] = { 0, 18, 23 }, [284] = { 0, 18, 23 }, [285] = { 0, 18, 23 }, [286] = { 1, 5, 18, 22 }, [287] = { 0, 5, 6 }, [288] = { 0, 16 }, [289] = { 1, 18, 24 }, [290] = { 1 }, [291] = { 0, 16 }, [292] = { 0, 3, 6, 20 }, [293] = {}, [294] = { 0, 10 }, [295] = { 0, 1 }, [296] = { 1 }, [297] = { 1, 9, 18 }, [298] = { 0 }, [299] = { 0, 16 }, [300] = { 0, 16 }, [301] = { 0, 16 }, [302] = { 0, 16 }, [303] = { 0, 16 }, [304] = { 0 }, [305] = { 0, 16 }, [306] = { 0, 16 }, [307] = { 0, 16 }, [308] = { 0, 16 }, [309] = { 0, 16 }, [310] = { 0, 16 }, [311] = { 3, 20 }, [312] = { 0, 16 }, [313] = { 0, 4, 21 }, [314] = { 0, 17 }, [315] = { 0, 16 }, [316] = { 0, 5, 9, 16, 22 }, [317] = { 0, 16 }, [318] = { 0, 16 }, [319] = { 0, 16 }, [320] = { 0, 13, 16, 28 }, [321] = { 0, 5, 16, 22 }, [322] = { 0, 16, 28 }, [323] = { 0 }, [324] = { 0 }, [325] = { 0, 16 }, [326] = { 4 }, [327] = {}, [328] = {}, [329] = { 0, 16 }, [330] = { 0, 16 }, [331] = { 4, 21 }, [332] = { 0, 4, 16 }, [333] = { 0, 4, 16, 21 }, [334] = { 0, 4, 16, 21, 24 }, [335] = { 0, 4, 16, 21 }, [336] = { 0, 16, 30 }, [337] = { 1, 23 }, [338] = { 1, 23 }, [339] = { 2, 17 }, [340] = { 2, 11, 17 }, [341] = { 2, 8, 17, 27 }, [342] = { 2, 17 }, [343] = { 2, 8, 13, 17 }, [344] = { 2, 8, 17 }, [345] = { 2, 11, 17 }, [346] = { 2, 17 }, [347] = { 1 }, [348] = { 1, 5, 18, 22 }, [349] = { 1, 16, 29 }, [350] = { 0 }, [351] = { 0, 16 }, [352] = { 0, 16, 23 }, [353] = { 0, 16, 25 }, [354] = { 2, 8, 17 }, [355] = { 2, 8, 15, 17, 27 }, [356] = { 1, 14, 18 }, [357] = { 1, 16, 23 }, [358] = { 0, 16 }, [359] = { 0, 16 }, [360] = { 3, 20, 28 }, [361] = { 0, 28 }, [362] = { 0, 10, 16, 23, 29 }, [363] = { 4, 21, 28 }, [364] = { 0, 13, 16, 28 }, [365] = { 0, 13, 16, 28 }, [366] = { 0, 16, 25 }, [367] = { 0, 16, 25 }, [368] = { 0, 16 }, [369] = { 0, 16 }, [370] = { 2, 8, 17, 23 }, [371] = { 0, 9, 12, 16, 19 }, [372] = { 1, 14, 18, 28 }, [373] = { 0, 16, 24 }, [374] = { 0, 4, 16 }, [375] = { 0, 16 }, [376] = { 1, 10 }, [377] = { 0, 16 }, [378] = { 0, 7, 16 }, [379] = { 0, 16 }, [380] = { 1, 16, 18 }, [381] = { 0 }, [382] = { 0, 16, 23 }, [383] = { 1, 16, 23 }, [384] = { 0, 16, 28 }, [385] = { 0, 10, 28 }, [386] = { 0, 18, 23 }, [387] = { 4, 21 }, [388] = { 0, 5, 13, 28 }, [389] = { 0, 5, 16, 22 }, [390] = { 0, 4, 21, 28 }, [391] = { 0, 3, 16, 20 }, [392] = { 0, 16 }, [393] = { 0, 16 }, [394] = { 0, 16, 24 }, [395] = { 0, 16, 23 }, [396] = { 1 }, [397] = { 0, 16, 23 }, [398] = { 0, 16 }, [399] = { 3, 20, 24 }, [400] = { 4, 21 }, [401] = { 0, 16 }, [402] = { 1, 5, 18, 22 }, [403] = { 1, 18, 23, 28 }, [404] = { 0, 28 }, [405] = { 0, 5, 18, 22 }, [406] = { 0, 18, 23 }, [407] = { 0, 16, 21 }, [408] = { 3, 12, 19, 20 }, [409] = { 3, 11, 20 }, [410] = { 0, 16 }, [411] = { 0, 3, 16, 20, 24 }, [412] = { 3, 20, 24 }, [413] = { 4, 21 }, [414] = { 1 }, [415] = { 4, 21 }, [416] = { 1, 16, 18 }, [417] = { 3, 28 }, [418] = { 0 }, [419] = { 0, 23 }, [420] = { 3, 11, 20 }, [421] = { 0, 16, 24 }, [422] = { 0, 1, 23 }, [423] = { 4, 21 }, [424] = { 1, 5, 22 }, [425] = { 1, 16, 23 }, [426] = { 0, 13, 16, 28 }, [427] = { 0, 23 }, [428] = { 2, 8, 17 }, [429] = {}, [430] = { 0, 13, 16, 28 }, [431] = { 0, 3, 16, 20 }, [432] = { 0, 16, 25 }, [433] = { 3, 20 }, [434] = { 1, 16, 18 }, [435] = { 0, 24, 28 }, [436] = { 0, 16 }, [437] = { 0, 23 }, [438] = { 2, 8, 17, 23 }, [439] = { 1, 15, 18, 23, 27, 29 }, [440] = { 0, 16 }, [441] = { 3, 20 }, [442] = { 3, 12, 19, 20 }, [443] = { 0, 16, 24 }, [444] = { 0, 8, 16, 23 }, [445] = { 0, 16 }, [446] = { 0, 16 }, [447] = { 0, 10, 16 }, [448] = { 0, 16 }, [449] = { 0, 16 }, [450] = { 5, 16, 22 }, [451] = { 1, 12, 18, 19, 20, 23 }, [452] = { 0, 16, 24 }, [453] = { 0, 16 }, [454] = { 0, 16 }, [455] = { 2, 8, 10, 17, 27 }, [456] = { 2, 8, 10, 17 }, [457] = { 0, 16 }, [458] = { 0, 16 }, [459] = { 0, 16 }, [460] = { 0, 16 }, [461] = { 0, 16 }, [462] = { 3, 20, 24 }, [463] = { 0, 16 }, [464] = { 4, 21 }, [465] = { 0, 16, 23 }, [466] = { 0, 16, 24 }, [467] = { 0, 16 }, [468] = { 3, 12, 19, 20, 28 }, [469] = { 0, 16 }, [470] = { 0, 16, 28 }, [471] = { 0, 16, 28 }, [472] = { 1, 18, 28 }, [473] = { 0, 16, 28 }, [474] = {}, [475] = { 1, 3, 9, 11, 12, 18, 19, 24 }, [476] = { 0, 18, 23 }, [477] = { 3, 4, 18 }, [478] = { 0, 18, 23 }, [479] = { 1 }, [480] = { 1, 30 }, [481] = { 0, 18, 24 }, [482] = { 0, 18 }, [483] = { 1, 18, 25 }, [484] = {}, [485] = { 0, 1, 10, 18 }, [486] = { 1, 18 }, [487] = { 1, 11, 18 }, [488] = { 0, 18, 23, 29 }, [489] = { 5, 18, 22 }, [490] = { 4, 21 }, [491] = { 0, 28 }, [492] = { 0, 13, 28 }, [493] = { 0, 11, 16 }, [494] = { 0, 14, 16, 23 }, [495] = { 0, 16 }, [496] = { 0, 11, 12, 16, 19 }, [497] = { 0, 16 }, [498] = { 3, 4 }, [499] = { 4, 21 }, [500] = { 5, 18, 22 }, [501] = { 5, 22 }, [502] = { 0, 16 }, [503] = { 11, 12, 16, 19, 20 }, [504] = { 0, 7, 16 }, [505] = { 1, 18, 23 }, [506] = { 0, 16, 24 }, [507] = { 0, 16 }, [508] = { 0, 12, 15, 16, 19, 27 }, [509] = { 0, 16, 28 }, [510] = { 4 }, [511] = { 0, 16, 24, 28 }, [512] = { 0, 16, 18 }, [513] = { 0, 16 }, [514] = { 1, 16 }, [515] = { 1, 16, 18, 23 }, [516] = { 0, 16, 18, 23 }, [517] = { 0, 16, 25 }, [518] = { 1, 16, 18, 23, 28 }, [519] = { 3, 4, 20, 28 }, [520] = { 1, 14, 16 }, [521] = { 1 }, [522] = { 0, 16 }, [523] = { 1 }, [524] = { 0, 16, 23 }, [525] = { 0, 16 }, [526] = { 3, 4, 20, 21 }, [527] = { 1, 13, 18, 23, 29 }, [528] = { 4, 21 }, [529] = { 0, 16 }, [530] = { 3 }, [531] = { 0, 16, 24 }, [532] = { 0, 16 }, [533] = { 4, 21 }, [534] = { 1, 8, 18 }, [535] = { 1, 18 }, [536] = { 3, 12, 19, 20 }, [537] = { 0, 16, 28 }, [538] = { 2, 17, 23 }, [539] = { 0, 16 }, [540] = { 0, 16 }, [541] = { 2, 17, 24 }, [542] = { 0, 16 }, [543] = { 0, 4, 16, 21 }, [544] = { 0, 16 }, [545] = { 0, 3, 6, 16, 20 }, [546] = { 5, 22, 27 }, [547] = { 2, 17, 27 }, [548] = { 0, 16 }, [549] = { 0, 16 }, [550] = {}, [551] = {}, [552] = {}, [553] = { 0, 16 }, [554] = { 3, 20, 24 }, [555] = { 0, 16 }, [556] = { 3, 20, 24 }, [557] = { 0, 16 }, [558] = { 0, 16 }, [559] = { 0, 14, 16 }, [560] = { 0, 16 }, [561] = { 0, 16 }, [562] = { 5, 22 }, [563] = { 0, 16, 25 }, [564] = { 2, 17 }, [565] = { 0, 9, 12, 16, 19, 24 }, [566] = { 1, 18 }, [567] = { 4, 21 }, [568] = { 4, 21 }, [569] = { 3, 12, 19, 20 }, [570] = { 0, 16 }, [571] = { 5, 8, 22 }, [572] = { 3, 20, 24 }, [573] = { 4, 21, 24 }, [574] = { 4, 21 }, [575] = { 0, 16, 28 }, [576] = { 0, 7, 16 }, [577] = { 3, 20 }, [578] = { 0, 16 }, [579] = { 4, 21 }, [580] = { 5, 9, 12, 13, 15, 24 }, [581] = { 0, 13, 16, 28 }, [582] = { 5, 22 }, [583] = { 0, 16, 25 }, [584] = { 4, 6, 21 }, [585] = { 1, 18 }, [586] = { 4, 21 }, [588] = { 26 }, [589] = { 26 }, [590] = { 26 }, [591] = { 26 }, [592] = { 26 }, [593] = { 26 }, [594] = { 26 }, [595] = { 26 }, [596] = { 26 }, [597] = { 26 }, [598] = { 26 }, [599] = { 1, 23 }, [600] = { 2, 17 }, [601] = { 4, 21 }, [602] = { 1 }, [603] = { 1, 14, 18 }, [604] = { 1, 18, 23, 27 }, [605] = { 0, 16 }, [606] = { 3, 20, 24 }, [607] = { 0, 16, 24, 28 }, [608] = { 0, 16, 28 }, [609] = { 0, 5, 16, 22, 23 }, [610] = { 0, 16, 28 }, [611] = { 0, 16 }, [612] = { 0, 5, 16, 22, 28 }, [614] = { 0, 16, 24, 25 }, [615] = { 0, 16, 28 }, [616] = { 0, 16, 24 }, [617] = { 0, 16, 23 }, [618] = { 0, 16, 24, 30 }, [619] = { 1, 18 }, [621] = { 1, 18, 24 }, [622] = { 4, 21 }, [623] = { 1, 18 }, [624] = { 1, 2, 17, 18, 23 }, [625] = { 0, 5, 16, 22 }, [626] = {}, [627] = {}, [628] = { 5, 22 }, [629] = { 0, 13, 16, 23, 28 }, [631] = { 0, 16 }, [632] = { 5, 22 }, [633] = {}, [634] = { 3, 4, 20, 21 }, [635] = { 0, 16, 28 }, [636] = { 5, 18, 22 }, [637] = { 0, 16, 24 }, [638] = { 1, 18, 23 }, [639] = { 0, 16, 30 }, [640] = { 4, 21 }, [641] = { 0, 16 }, [642] = { 1, 9, 12, 19 }, [643] = { 4, 21 }, [644] = { 2, 8, 17, 23 }, [645] = { 0, 16, 28 }, [646] = { 3, 20, 25 }, [647] = { 1, 14, 18 }, [649] = { 0, 13, 16, 23, 28 }, [650] = { 0, 16, 24 }, [651] = { 4, 21 }, [652] = { 0, 16 }, [653] = { 4, 21 }, [654] = { 3, 9, 12, 19, 20, 24 }, [655] = { 0, 16, 23 }, [656] = {}, [657] = { 0, 16, 24 }, [658] = { 0, 16 }, [659] = { 2, 17 }, [660] = { 1 }, [661] = { 0, 16, 28 }, [663] = { 0, 16 }, [664] = { 5, 22 }, [665] = { 3, 9, 20 }, [667] = { 5, 18, 22 }, [668] = {}, [669] = { 5, 22 }, [670] = { 1 }, [671] = { 0, 16, 24 }, [672] = { 3, 11 }, [673] = {}, [674] = { 5, 18, 22 }, [675] = { 0, 5, 16 }, [676] = { 0, 11, 16 }, [677] = { 0, 5, 16, 22 }, [678] = { 0, 16 }, [679] = { 3, 20, 28 }, [680] = { 0, 16 }, [681] = { 0, 16 }, [682] = { 0, 16, 24, 28 }, [683] = { 0, 16 }, [684] = { 3, 20, 24 }, [685] = { 4, 21 }, [686] = { 4, 21 }, [687] = { 0, 16, 23 }, [688] = { 5, 18, 22 }, [689] = { 5, 18, 22 }, [690] = { 0, 16 }, [691] = { 4, 5, 18, 21, 22 }, [692] = { 3, 12, 18, 19, 20, 24 }, [693] = { 0, 13, 16 }, [694] = { 3, 12, 19, 20, 24 }, [695] = { 0, 3, 16, 20, 24 }, [696] = { 4, 21 }, [697] = { 5, 12 }, [698] = { 3, 20, 28 }, [699] = { 3, 20 }, [700] = { 5, 18, 22, 24 }, [701] = { 5, 18, 22 }, [702] = { 3, 12, 19, 20, 24 }, [703] = { 0, 5, 16, 18, 22, 24 }, [704] = { 3, 20, 24 }, [705] = { 3, 20, 24 }, [706] = { 3, 20, 24 }, [707] = { 2, 10, 17 }, [708] = { 2, 8, 17 }, [709] = { 0, 16, 23 }, [710] = { 0, 16 }, [711] = { 5, 12, 18, 19, 22, 24 }, [712] = { 3, 6, 20 }, [713] = { 0, 16 }, [714] = {}, [715] = {}, [716] = { 1, 5, 16, 22 }, [717] = { 0, 5, 16, 22 }, [719] = { 1, 5, 16, 22, 29 }, [720] = { 0, 16, 23 }, [721] = { 5, 16, 18, 22 }, [722] = { 0, 16, 18 }, [723] = { 0, 5, 16, 18, 22, 23 }, [724] = { 0, 16, 24 }, [725] = { 0, 16 }, [726] = { 0, 16, 24 }, [727] = { 0, 16, 25 }, [728] = { 0, 3, 16, 20, 24 }, [729] = { 0, 16 }, [730] = { 2, 8, 17, 23 }, [731] = { 2, 17 }, [732] = { 8, 15, 18 }, }

	--Metadata found in Pocketitems.xml
	coopHUD.cardMetadata = { [0] = { mimiccharge = 0 }, [1] = { mimiccharge = 2 }, [10] = { mimiccharge = 2 }, [11] = { mimiccharge = 6 }, [12] = { mimiccharge = 3 }, [13] = { mimiccharge = 4 }, [14] = { mimiccharge = 3 }, [15] = { mimiccharge = 6 }, [16] = { mimiccharge = 3 }, [17] = { mimiccharge = 3 }, [18] = { mimiccharge = 2 }, [19] = { mimiccharge = 2 }, [2] = { mimiccharge = 2 }, [20] = { mimiccharge = 12 }, [21] = { mimiccharge = 6 }, [22] = { mimiccharge = 3 }, [23] = { mimiccharge = 12 }, [24] = { mimiccharge = 12 }, [25] = { mimiccharge = 12 }, [26] = { mimiccharge = 12 }, [27] = { mimiccharge = 6 }, [28] = { mimiccharge = 6 }, [29] = { mimiccharge = 6 }, [3] = { mimiccharge = 2 }, [30] = { mimiccharge = 6 }, [31] = { mimiccharge = 2 }, [32] = { mimiccharge = 2 }, [33] = { mimiccharge = 12 }, [34] = { mimiccharge = 4 }, [35] = { mimiccharge = 6 }, [36] = { mimiccharge = 2 }, [37] = { mimiccharge = 4 }, [38] = { mimiccharge = 2 }, [39] = { mimiccharge = 4 }, [4] = { mimiccharge = 3 }, [40] = { mimiccharge = 3 }, [41] = { mimiccharge = 4 }, [42] = { mimiccharge = 6 }, [43] = { mimiccharge = 6 }, [44] = { mimiccharge = 1 }, [45] = { mimiccharge = 6 }, [46] = { mimiccharge = 1 }, [47] = { mimiccharge = 2 }, [48] = { mimiccharge = 1 }, [49] = { mimiccharge = 4 }, [5] = { mimiccharge = 4 }, [50] = { mimiccharge = 3 }, [51] = { mimiccharge = 4 }, [52] = { mimiccharge = 3 }, [53] = { mimiccharge = 12 }, [54] = { mimiccharge = 3 }, [55] = { mimiccharge = 1 }, [56] = { mimiccharge = 12 }, [57] = { mimiccharge = 4 }, [58] = { mimiccharge = 4 }, [59] = { mimiccharge = 4 }, [6] = { mimiccharge = 12 }, [60] = { mimiccharge = 2 }, [61] = { mimiccharge = 12 }, [62] = { mimiccharge = 4 }, [63] = { mimiccharge = 2 }, [64] = { mimiccharge = 12 }, [65] = { mimiccharge = 1 }, [66] = { mimiccharge = 4 }, [67] = { mimiccharge = 3 }, [68] = { mimiccharge = 6 }, [69] = { mimiccharge = 4 }, [7] = { mimiccharge = 6 }, [70] = { mimiccharge = 6 }, [71] = { mimiccharge = 4 }, [72] = { mimiccharge = 3 }, [73] = { mimiccharge = 12 }, [74] = { mimiccharge = 2 }, [75] = { mimiccharge = 6 }, [76] = { mimiccharge = 12 }, [77] = { mimiccharge = 2 }, [78] = { mimiccharge = 4 }, [79] = { mimiccharge = 12 }, [8] = { mimiccharge = 3 }, [80] = { mimiccharge = 6 }, [81] = { mimiccharge = 4 }, [82] = { mimiccharge = 3 }, [83] = { mimiccharge = 6 }, [84] = { mimiccharge = 3 }, [85] = { mimiccharge = 3 }, [86] = { mimiccharge = 4 }, [87] = { mimiccharge = 6 }, [88] = { mimiccharge = 6 }, [89] = { mimiccharge = 1 }, [9] = { mimiccharge = 6 }, [90] = { mimiccharge = 4 }, [91] = { mimiccharge = 3 }, [92] = { mimiccharge = 12 }, [93] = { mimiccharge = 12 }, [94] = { mimiccharge = 6 }, [95] = { mimiccharge = 4 }, [96] = { mimiccharge = 6 }, [97] = { mimiccharge = 4 }, }

	coopHUD.pillMetadata = { [0] = { mimiccharge = 1, class = "1+" }, [1] = { mimiccharge = 2, class = "2-" }, [10] = { mimiccharge = 6, class = "2+" }, [11] = { mimiccharge = 4, class = "3-" }, [12] = { mimiccharge = 6, class = "3+" }, [13] = { mimiccharge = 4, class = "3-" }, [14] = { mimiccharge = 6, class = "3+" }, [15] = { mimiccharge = 4, class = "3-" }, [16] = { mimiccharge = 6, class = "3+" }, [17] = { mimiccharge = 4, class = "3-" }, [18] = { mimiccharge = 6, class = "3+" }, [19] = { mimiccharge = 1, class = "1" }, [2] = { mimiccharge = 12, class = "2+" }, [20] = { mimiccharge = 12, class = "2+" }, [21] = { mimiccharge = 6, class = "2" }, [22] = { mimiccharge = 6, class = "1-" }, [23] = { mimiccharge = 4, class = "2+" }, [24] = { mimiccharge = 2, class = "1+" }, [25] = { mimiccharge = 6, class = "2-" }, [26] = { mimiccharge = 3, class = "1+" }, [27] = { mimiccharge = 6, class = "1-" }, [28] = { mimiccharge = 2, class = "1+" }, [29] = { mimiccharge = 6, class = "1-" }, [3] = { mimiccharge = 1, class = "2" }, [30] = { mimiccharge = 2, class = "0" }, [31] = { mimiccharge = 6, class = "1-" }, [32] = { mimiccharge = 6, class = "1" }, [33] = { mimiccharge = 6, class = "1" }, [34] = { mimiccharge = 2, class = "1+" }, [35] = { mimiccharge = 2, class = "1+" }, [36] = { mimiccharge = 3, class = "1+" }, [37] = { mimiccharge = 6, class = "1-" }, [38] = { mimiccharge = 1, class = "1+" }, [39] = { mimiccharge = 1, class = "0-" }, [4] = { mimiccharge = 3, class = "1" }, [40] = { mimiccharge = 1, class = "0+" }, [41] = { mimiccharge = 3, class = "1" }, [42] = { mimiccharge = 6, class = "1" }, [43] = { mimiccharge = 4, class = "2+" }, [44] = { mimiccharge = 1, class = "0" }, [45] = { mimiccharge = 1, class = "1+" }, [46] = { mimiccharge = 6, class = "2+" }, [47] = { mimiccharge = 4, class = "3-" }, [48] = { mimiccharge = 6, class = "3+" }, [49] = { mimiccharge = 3, class = "3" }, [5] = { mimiccharge = 12, class = "2+" }, [6] = { mimiccharge = 4, class = "3-" }, [7] = { mimiccharge = 6, class = "3+" }, [8] = { mimiccharge = 1, class = "0" }, [9] = { mimiccharge = 1, class = "0" }, }
else
	coopHUD.XMLMaxItemID = EID.XMLMaxItemID
	--The fixed recipes, for use in Bag of Crafting
	coopHUD.XMLRecipes = EID.XMLRecipes
	--The contents of each item pool, and the item's weight, for use in Bag of Crafting
	coopHUD.XMLItemPools = EID.XMLItemPools

	--The quality of each item, for use in Bag of Crafting
	coopHUD.XMLItemQualities = EID.XMLItemQualities

	--The pools that each item is in, for roughly checking if a given item is unlocked
	coopHUD.XMLItemIsInPools = EID.XMLItemIsInPools

	--Metadata found in Pocketitems.xml
	coopHUD.cardMetadata = EID.cardMetadata

	coopHUD.pillMetadata = EID.pillMetadata
end
--
function coopHUD.calculateBag(player)
	local curSeed = Game():GetSeeds():GetStartSeed()
	--reset our calculated recipes when the game seed changes
	if (curSeed ~= lastSeedUsed) then
		calculatedRecipes = {}
		lockedRecipes = {}
		calcResultCache = {}
		randResultCache = {}
	end
	lastSeedUsed = curSeed
	local bag = {}
	for _,k in pairs(player.bag_of_crafting) do
		table.insert(bag,k.id)
	end
	local components = {table.unpack(bag)}
	if components == nil or #components ~= 8 then
		return 0
	end

	customRNGSeed = lastSeedUsed
	table.sort(components)
	local componentsAsString = table.concat(components, ",")

	--Check the fixed recipes. Currently, the fixed recipes ignore item unlock status
	local cacheResult = coopHUD.XMLRecipes[componentsAsString]
	if cacheResult ~= nil then
		return cacheResult, cacheResult
	end

	cacheResult = calculatedRecipes[componentsAsString]
	local lockedResult = lockedRecipes[componentsAsString]

	if cacheResult ~= nil then
		return cacheResult, lockedResult
	end
	local compTotalWeight = 0
	local compCounts = {}
	for i = 1, #componentShifts do
		compCounts[i] = 0
	end
	for _, compId in ipairs(components) do
		compCounts[compId + 1] = compCounts[compId + 1] + 1
		compTotalWeight = compTotalWeight + coopHUD.getItemValue(compId+1)
		customRNGShift = componentShifts[compId + 1]
		RNGNext()
	end
	customRNGShift = componentShifts[7]
	local poolWeights = {
		{idx = 0, weight = 1},
		{idx = 1, weight = 2},
		{idx = 2, weight = 2},
		{idx = 3, weight = compCounts[4] * 10},
		{idx = 4, weight = compCounts[5] * 10},
		{idx = 5, weight = compCounts[7] * 5},
		{idx = 7, weight = compCounts[30] * 10},
		{idx = 8, weight = compCounts[6] * 10},
		{idx = 9, weight = compCounts[26] * 10},
		{idx = 12, weight = compCounts[8] * 10},
	}
	if compCounts[9] + compCounts[2] + compCounts[13] + compCounts[16] == 0 then
		table.insert(poolWeights, {idx = 26, weight = compCounts[24] * 10})
	end

	local totalWeight = 0

	local itemWeights = {}

	local maxItemID = coopHUD.XMLMaxItemID
	for i = 1, maxItemID do
		itemWeights[i] = 0
	end

	for _, poolWeight in ipairs(poolWeights) do
		if poolWeight.weight > 0 then
			local qualityMin = 0
			local qualityMax = 1
			local n = compTotalWeight
			if (poolWeight.idx >= 3) and (poolWeight.idx <= 5) then
				n = n - 5
			end
			if n > 34 then
				qualityMin = 4
				qualityMax = 4
			elseif n > 26 then
				qualityMin = 3
				qualityMax = 4
			elseif n > 22 then
				qualityMin = 2
				qualityMax = 4
			elseif n > 18 then
				qualityMin = 2
				qualityMax = 3
			elseif n > 14 then
				qualityMin = 1
				qualityMax = 2
			elseif n > 8 then
				qualityMin = 0
				qualityMax = 2
			end
			local pool = EID.XMLItemPools[poolWeight.idx + 1]

			for _, item in ipairs(pool) do
				local quality = EID.XMLItemQualities[item[1]]
				if quality >= qualityMin and quality <= qualityMax  then
					local w = item[2] * poolWeight.weight
					itemWeights[item[1]] = itemWeights[item[1]] + w
					totalWeight = totalWeight + w
				end
			end
		end
	end
	--unsure if this emergency Breakfast would ever occur, without massively modified item pools at least, but it's in the game's code
	if totalWeight <= 0 then
		return 25, 25
	end
	--When the first crafting result is an achievement locked item, this process gets repeated a second time to choose a new result
	--That 2nd pick could also be achievement locked but we're ignoring that...
	local firstOption = nil
	while true do
		local t = nextFloat()
		local target = t * totalWeight
		for k,v in ipairs(itemWeights) do
			target = target - v
			if target < 0 then
				if firstOption then
					calculatedRecipes[componentsAsString] = firstOption
					lockedRecipes[componentsAsString] = k
					return firstOption, k
				else
					--Don't do the 2nd pass if this item is definitely unlocked
					if EID:isCollectibleUnlockedAnyPool(k) then
						calculatedRecipes[componentsAsString] = k
						lockedRecipes[componentsAsString] = k
						return k, k
					else
						firstOption = k
						break
					end
				end
			end
		end
	end
end
-- _____/BAG
-- ______
function coopHUD.getPlayerNumByControllerIndex(controller_index)
	-- Function returns player number searching coopHUD.player table for matching controller index
	local final_index = -1
	for i, p in pairs(coopHUD.players) do
		if p.controller_index == controller_index then
			final_index = i
		end
	end
	return final_index
end