CHEST_LEVEL = 3
dofile_once("data/scripts/director_helpers.lua")
dofile_once("data/scripts/biome_scripts.lua")
dofile( "mods/evaisa.arena/files/scripts/misc/generate_shop_item.lua" )
dofile_once("data/scripts/lib/utilities.lua")
dofile( "data/scripts/biomes/temple_shared.lua" )
dofile( "data/scripts/perks/perk.lua" )
dofile_once("data/scripts/biomes/temple_altar_top_shared.lua")
dofile("mods/evaisa.arena/files/scripts/gamemode/misc/seed_gen.lua")

local smallfolk = dofile("mods/evaisa.arena/lib/smallfolk.lua")

RegisterSpawnFunction( 0xff6d934c, "spawn_hp" )
RegisterSpawnFunction( 0xff5b8b31, "spawn_refresh" )
RegisterSpawnFunction( 0xff4090e1, "spawn_card_pick" )

RegisterSpawnFunction( 0xff03fade, "spawn_spell_visualizer" )
RegisterSpawnFunction( 0xff33934c, "spawn_all_shopitems" )
RegisterSpawnFunction( 0xff10822d, "spawn_workshop" )
RegisterSpawnFunction( 0xff5a822d, "spawn_workshop_extra" )
RegisterSpawnFunction( 0xffb66ccd, "spawn_ready_point" )
RegisterSpawnFunction( 0xff7345DF, "spawn_perk_reroll" )
RegisterSpawnFunction( 0xffd14158, "spawn_target_dummy")
RegisterSpawnFunction( 0xffc5529d, "spawn_item_shop_item")
RegisterSpawnFunction( 0xffd8b950, "spawn_wardrobe")

function spawn_card_pick ( x, y )
	if(GameHasFlagRun("pick_upgrade") and not GameHasFlagRun("card_picked"))then
		EntityLoad( "mods/evaisa.arena/files/entities/misc/card_pick.xml", x, y - 6 )
	end
end

function spawn_workshop( x, y )
	--EntityLoad( "data/entities/buildings/workshop.xml", x, y )
end

function spawn_ready_point( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/ready.xml", x, y )
end

function spawn_workshop_extra( x, y )
	--EntityLoad( "mods/evaisa.arena/files/entities/misc/workshop_allow_mods.xml", x, y )
end

function spawn_spell_visualizer( x, y )
	EntityLoad( "data/entities/buildings/workshop_spell_visualizer.xml", x, y )
	EntityLoad( "data/entities/buildings/workshop_aabb.xml", x, y )
end

function spawn_hp( x, y )

	GameAddFlagRun("in_hm")
    if(not GameHasFlagRun("DeserializedHolyMountain") and not GameHasFlagRun("instant_health"))then
		local hp = EntityLoad( "mods/evaisa.arena/files/entities/misc/heart_fullhp.xml", x, y )

		if(not EntityHasTag(hp, "synced_once"))then
			EntitySetName(hp, EntityGetName(hp).."_"..tostring((GameGetFrameNum() % 100000) + hp))
			EntityAddComponent2(hp, "LuaComponent", {
				_tags = "enabled_in_world,enabled_in_hand,enabled_in_inventory",
				script_item_picked_up = "mods/evaisa.arena/files/scripts/gamemode/misc/hm_pickup.lua",
			})
			
			EntityAddTag(hp, "synced_once")
		end

	end
	
	EntityLoad( "data/entities/buildings/music_trigger_temple.xml", x-16, y )
	
	
	EntityLoad( "data/entities/buildings/coop_respawn.xml", x, y )
	EntityLoad("mods/evaisa.arena/files/entities/chunk_loader_hm.xml", x, 0)
	--EntitySetTransform(chunk_loader, 1500, 0)
	--[[EntityApplyTransform(chunk_loader, 300, 0)
	EntitySetTransform(chunk_loader, 300, 0)
	EntityApplyTransform(chunk_loader, 600, 0)
	EntitySetTransform(chunk_loader, 600, 0)]]
	GameAddFlagRun("should_save_player")
end

function spawn_refresh( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/misc/spell_refresh.xml", x, y )
end


function spawn_all_shopitems( x, y )

	if(GameHasFlagRun("DeserializedHolyMountain"))then
		return
	end

	--local rng = dofile_once("mods/evaisa.arena/lib/rng.lua")

	local random_seed_x, random_seed_y = get_new_seed(x, y, GameHasFlagRun("shop_sync"))

	print("Shop seed: "..tostring(random_seed_x)..", "..tostring(random_seed_y))

	SetRandomSeed( random_seed_x, random_seed_y )

	local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0
	-- how many rounds it takes for the shop level to increment
	local shop_scaling = tonumber(GlobalsGetValue("shop_scaling", "2"))
	-- how much the shop level increments by
	local shop_increment = tonumber(GlobalsGetValue("shop_jump", "1"))
	-- the maximum shop level
	local shop_max = tonumber(GlobalsGetValue("max_shop_level", "5"))
	-- shop start level
	local shop_start_level = tonumber(GlobalsGetValue("shop_start_level", "0"))
	-- calculating how many times the shop level has been incremented
	local num_increments = math.floor((rounds - 1) / shop_scaling)
	-- should shops act as true random

	-- calculating the current shop level including the start level and clamping it to the max level
	local round_scaled = math.min(shop_start_level + num_increments * shop_increment, shop_max)

	

	round_scaled = math.floor(round_scaled + 0.5)
	if(round_scaled < 0)then
		round_scaled = 0
	end
	
	
	--print("Shop tier: "..round_scaled)


	EntityLoad( "data/entities/buildings/shop_hitbox.xml", x, y )
	
	print("Generated shop items for mountain #"..tostring(rounds))

	local count = tonumber( GlobalsGetValue( "TEMPLE_SHOP_ITEM_COUNT", "5" ) )
	local width = 132
	local item_width = width / count
	local sale_item_i = Random( 1, count )

	--print("Sale item: "..tostring(sale_item_i))

	-- Get the shop type from the settings
	local shop_type = GlobalsGetValue("shop_type", "mixed")
	local second_row_spots = {}
	-- "Alternating" shop type switches between spells and wands every round.
	if (shop_type == "alternating") then
		-- Alternate which shop is presented
		if (rounds % 2 == 0) then
			for i=1,count do
				if( i == sale_item_i ) then
					generate_shop_item( x + (i-1)*item_width, y, true, round_scaled, false )
				else
					generate_shop_item( x + (i-1)*item_width, y, false, round_scaled, false )
				end
				
				generate_shop_item( x + (i-1)*item_width, y - 30, false, round_scaled, false )
				LoadPixelScene( "data/biome_impl/temple/shop_second_row.png", "data/biome_impl/temple/shop_second_row_visual.png", x + (i-1)*item_width - 8, y-22, "", true )
				table.insert(second_row_spots, {x + (i-1)*item_width - 8, y-22})
			end
		else
			for i=1,count do
				if( i == sale_item_i ) then
					generate_shop_wand( x + (i-1)*item_width, y, true, round_scaled )
				else
					generate_shop_wand( x + (i-1)*item_width, y, false, round_scaled )
				end
			end
		end
	-- "Mixed" shop type mixed spells and wands.
	elseif (shop_type == "mixed") then
		-- Get the wand chance from the settings
		local shop_wand_chance = tonumber(GlobalsGetValue("shop_wand_chance", "40"))
		local wand_count = math.floor(((count / 100) * shop_wand_chance) + 0.5)
		for i=1, wand_count do
			if (i == sale_item_i) then
				generate_shop_wand(x + (i-1)*item_width, y, true, round_scaled)
			else
				generate_shop_wand(x + (i-1)*item_width, y, false, round_scaled)
			end
		end
		for i=wand_count+1, count do
			LoadPixelScene("data/biome_impl/temple/shop_second_row.png", "data/biome_impl/temple/shop_second_row_visual.png", x + (i-1)*item_width - 8, y-22, "", true)
			table.insert(second_row_spots, {x + (i-1)*item_width - 8, y-22})
			if (i == sale_item_i) then
				generate_shop_item( x + (i-1)*item_width, y, true, round_scaled, false )
				generate_shop_item( x + (i-1)*item_width, y - 30, false, round_scaled, false )
			else
				generate_shop_item( x + (i-1)*item_width, y, false, round_scaled, false )
				generate_shop_item( x + (i-1)*item_width, y - 30, false, round_scaled, false )
			end
		end
	-- "Spell Only" shop type is self explanatory.
	elseif (shop_type == "spell_only") then
		for i=1,count do
			if( i == sale_item_i ) then
				generate_shop_item( x + (i-1)*item_width, y, true, round_scaled, false )
			else
				generate_shop_item( x + (i-1)*item_width, y, false, round_scaled, false )
			end
			
			generate_shop_item( x + (i-1)*item_width, y - 30, false, round_scaled, false )
			LoadPixelScene( "data/biome_impl/temple/shop_second_row.png", "data/biome_impl/temple/shop_second_row_visual.png", x + (i-1)*item_width - 8, y-22, "", true )
			table.insert(second_row_spots, {x + (i-1)*item_width - 8, y-22})
		end
	-- "Wand Only" shop type is.. uh..
	elseif (shop_type == "wand_only") then
		for i=1,count do
			if( i == sale_item_i ) then
				generate_shop_wand( x + (i-1)*item_width, y, true, round_scaled )
			else
				generate_shop_wand( x + (i-1)*item_width, y, false, round_scaled )
			end
		end
	-- "Choose" shop type is something i guess the player chooses what type of shop they want but idk how eba wants to implement this.
	elseif (shop_type == "choose") then
		print("just kidding, its not implemented yet, ha ha ha!")
	-- "Random" shop type is basically vanilla and we default to this if no other shop type is match is found.
	else
		local shop_random_ratio = tonumber(GlobalsGetValue("shop_random_ratio", "50"))
		if( Random( 0, 100 ) >= shop_random_ratio ) then
			for i=1,count do
				if( i == sale_item_i ) then
					generate_shop_item( x + (i-1)*item_width, y, true, round_scaled, false )
				else
					generate_shop_item( x + (i-1)*item_width, y, false, round_scaled, false )
				end
				
				generate_shop_item( x + (i-1)*item_width, y - 30, false, round_scaled, false )
				LoadPixelScene( "data/biome_impl/temple/shop_second_row.png", "data/biome_impl/temple/shop_second_row_visual.png", x + (i-1)*item_width - 8, y-22, "", true )
				table.insert(second_row_spots, {x + (i-1)*item_width - 8, y-22})
			end
		else
			for i=1,count do
				if( i == sale_item_i ) then
					generate_shop_wand( x + (i-1)*item_width, y, true, round_scaled )
				else
					generate_shop_wand( x + (i-1)*item_width, y, false, round_scaled )
				end
			end
		end
	end

	GlobalsSetValue("temple_second_row_spots", smallfolk.dumps(second_row_spots))
	GameAddFlagRun("should_save_player")
	
end

function spawn_all_perks( x, y )
	if(GameHasFlagRun("DeserializedHolyMountain"))then
		return
	end
	if(GameHasFlagRun("first_death"))then
		local a, b, c, d, e, f = GameGetDateAndTimeLocal()
	
		local random_seed_x, random_seed_y = get_new_seed(x, y, GameHasFlagRun("perk_sync"))
	
		SetRandomSeed( random_seed_x, random_seed_y )
		perk_spawn_many( x, y )
	end

	GameAddFlagRun("should_save_player")
end

function spawn_perk_reroll( x, y )
	if(GameHasFlagRun("DeserializedHolyMountain"))then
		return
	end
	if(GameHasFlagRun("first_death"))then
		EntityLoad( "data/entities/items/pickup/perk_reroll.xml", x, y )
	end
end

function spawn_target_dummy( x, y )
	EntityLoad( "mods/evaisa.arena/files/entities/dummy_target/dummy_target.xml", x, y )
end

function spawn_item_shop_item( x, y )
	if(GameHasFlagRun("DeserializedHolyMountain"))then
		return
	end

	local rounds = tonumber(GlobalsGetValue("holyMountainCount", "0")) or 0

		
	local random_seed_x, random_seed_y = get_new_seed(x, y, GameHasFlagRun("shop_sync"))
	
	SetRandomSeed( random_seed_x, random_seed_y )

	-- how many rounds it takes for the shop level to increment
	local shop_scaling = tonumber(GlobalsGetValue("shop_scaling", "2"))
	-- how much the shop level increments by
	local shop_increment = tonumber(GlobalsGetValue("shop_jump", "1"))
	-- the maximum shop level
	local shop_max = tonumber(GlobalsGetValue("max_shop_level", "5"))
	-- shop start level
	local shop_start_level = tonumber(GlobalsGetValue("shop_start_level", "0"))

	-- calculating how many times the shop level has been incremented
	local num_increments = math.floor((rounds - 1) / shop_scaling)
	-- calculating the current shop level including the start level and clamping it to the max level
	local round_scaled = math.min(shop_start_level + num_increments * shop_increment, shop_max)

	round_scaled = math.floor(round_scaled + 0.5)
	if(round_scaled < 0)then
		round_scaled = 0
	end


	generate_shop_potion(x, y, round_scaled)

	GameAddFlagRun("should_save_player")
end

function spawn_wardrobe(x, y)
	-- will i ever finish this??
	-- I finished it :)
	EntityLoad( "mods/evaisa.arena/files/entities/wardrobe.xml", x, y + 1 )
end

-- GameHasFlagRun("first_death")