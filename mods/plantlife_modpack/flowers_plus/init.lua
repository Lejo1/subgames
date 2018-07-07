local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

-- This file supplies a few additional plants and some related crafts
-- for the plantlife modpack.  Last revision:  2013-04-24

flowers_plus = {}

local SPAWN_DELAY = 1000
local SPAWN_CHANCE = 200
local flowers_seed_diff = 329
local lilies_max_count = 320
local lilies_rarity = 33
local seaweed_max_count = 320
local seaweed_rarity = 33
local sunflowers_max_count = 10
local sunflowers_rarity = 25

-- register the various rotations of waterlilies

local lilies_list = {
	{ nil  , nil 	   , 1	},
	{ "225", "22.5"    , 2	},
	{ "45" , "45"      , 3	},
	{ "675", "67.5"    , 4	},
	{ "s1" , "small_1" , 5	},
	{ "s2" , "small_2" , 6	},
	{ "s3" , "small_3" , 7	},
	{ "s4" , "small_4" , 8	},
}

for i in ipairs(lilies_list) do
	local deg1 = ""
	local deg2 = ""
	local lily_groups = {snappy = 3,flammable=2,flower=1}

	if lilies_list[i][1] ~= nil then
		deg1 = "_"..lilies_list[i][1]
		deg2 = "_"..lilies_list[i][2]
		lily_groups = { snappy = 3,flammable=2,flower=1, not_in_creative_inventory=1 }
	end

	minetest.register_node(":flowers:waterlily"..deg1, {
		description = S("Waterlily"),
		drawtype = "nodebox",
		tiles = {
			"flowers_waterlily"..deg2..".png",
			"flowers_waterlily"..deg2..".png^[transformFY"
		},
		inventory_image = "flowers_waterlily.png",
		wield_image  = "flowers_waterlily.png",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		walkable = false,
		groups = lily_groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = { -0.4, -0.5, -0.4, 0.4, -0.45, 0.4 },
		},
		node_box = {
			type = "fixed",
			fixed = { -0.5, -0.49, -0.5, 0.5, -0.49, 0.5 },
		},
		buildable_to = true,
		node_placement_prediction = "",

		liquids_pointable = true,
		drop = "flowers:waterlily",
		on_place = function(itemstack, placer, pointed_thing)
			local keys=placer:get_player_control()
			local pt = pointed_thing

			local place_pos = nil
			local top_pos = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
			local under_node = minetest.get_node(pt.under)
			local above_node = minetest.get_node(pt.above)
			local top_node   = minetest.get_node(top_pos)

			if biome_lib:get_nodedef_field(under_node.name, "buildable_to") then
				if under_node.name ~= "default:water_source" then
					place_pos = pt.under
				elseif top_node.name ~= "default:water_source"
				       and biome_lib:get_nodedef_field(top_node.name, "buildable_to") then
					place_pos = top_pos
				else
					return
				end
			elseif biome_lib:get_nodedef_field(above_node.name, "buildable_to") then
				place_pos = pt.above
			end

			if place_pos and not minetest.is_protected(place_pos, placer:get_player_name()) then

			local nodename = "default:cobble" -- if this block appears, something went....wrong :-)

				if not keys["sneak"] then
					local node = minetest.get_node(pt.under)
					local waterlily = math.random(1,8)
					if waterlily == 1 then
						nodename = "flowers:waterlily"
					elseif waterlily == 2 then
						nodename = "flowers:waterlily_225"
					elseif waterlily == 3 then
						nodename = "flowers:waterlily_45"
					elseif waterlily == 4 then
						nodename = "flowers:waterlily_675"
					elseif waterlily == 5 then
						nodename = "flowers:waterlily_s1"
					elseif waterlily == 6 then
						nodename = "flowers:waterlily_s2"
					elseif waterlily == 7 then
						nodename = "flowers:waterlily_s3"
					elseif waterlily == 8 then
						nodename = "flowers:waterlily_s4"
					end
					minetest.set_node(place_pos, {name = nodename, param2 = math.random(0,3) })
				else
					local fdir = minetest.dir_to_facedir(placer:get_look_dir())
					minetest.set_node(place_pos, {name = "flowers:waterlily", param2 = fdir})
				end

				if not biome_lib.expect_infinite_stacks then
					itemstack:take_item()
				end
				return itemstack
			end
		end,
	})
end

local algae_list = { {nil}, {2}, {3}, {4} }

for i in ipairs(algae_list) do
	local num = ""
	local algae_groups = {snappy = 3,flammable=2,flower=1}

	if algae_list[i][1] ~= nil then
		num = "_"..algae_list[i][1]
		algae_groups = { snappy = 3,flammable=2,flower=1, not_in_creative_inventory=1 }
	end

	minetest.register_node(":flowers:seaweed"..num, {
		description = S("Seaweed"),
		drawtype = "nodebox",
		tiles = {
			"flowers_seaweed"..num..".png",
			"flowers_seaweed"..num..".png^[transformFY"
		},
		inventory_image = "flowers_seaweed_2.png",
		wield_image  = "flowers_seaweed_2.png",
		sunlight_propagates = true,
		paramtype = "light",
		paramtype2 = "facedir",
		walkable = false,
		groups = algae_groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = { -0.4, -0.5, -0.4, 0.4, -0.45, 0.4 },
		},
		node_box = {
			type = "fixed",
			fixed = { -0.5, -0.49, -0.5, 0.5, -0.49, 0.5 },
		},
		buildable_to = true,

		liquids_pointable = true,
		drop = "flowers:seaweed",
		on_place = function(itemstack, placer, pointed_thing)
			local keys=placer:get_player_control()
			local pt = pointed_thing

			local place_pos = nil
			local top_pos = {x=pt.under.x, y=pt.under.y+1, z=pt.under.z}
			local under_node = minetest.get_node(pt.under)
			local above_node = minetest.get_node(pt.above)
			local top_node   = minetest.get_node(top_pos)

			if biome_lib:get_nodedef_field(under_node.name, "buildable_to") then
				if under_node.name ~= "default:water_source" then
					place_pos = pt.under
				elseif top_node.name ~= "default:water_source"
				       and biome_lib:get_nodedef_field(top_node.name, "buildable_to") then
					place_pos = top_pos
				else
					return
				end
			elseif biome_lib:get_nodedef_field(above_node.name, "buildable_to") then
				place_pos = pt.above
			end

			if not minetest.is_protected(place_pos, placer:get_player_name()) then

			local nodename = "default:cobble" -- :D

				if not keys["sneak"] then
					--local node = minetest.get_node(pt.under)
					local seaweed = math.random(1,4)
					if seaweed == 1 then
						nodename = "flowers:seaweed"
					elseif seaweed == 2 then
						nodename = "flowers:seaweed_2"
					elseif seaweed == 3 then
						nodename = "flowers:seaweed_3"
					elseif seaweed == 4 then
						nodename = "flowers:seaweed_4"
					end
					minetest.set_node(place_pos, {name = nodename, param2 = math.random(0,3) })
				else
					local fdir = minetest.dir_to_facedir(placer:get_look_dir())
					minetest.set_node(place_pos, {name = "flowers:seaweed", param2 = fdir})
				end

				if not biome_lib.expect_infinite_stacks then
					itemstack:take_item()
				end
				return itemstack
			end
		end,
	})
end

local box = {
	type="fixed",
	fixed = { { -0.2, -0.5, -0.2, 0.2, 0.5, 0.2 } },
}

local sunflower_drop = "farming:seed_wheat"
if minetest.registered_items["farming:seed_spelt"] then
	sunflower_drop = "farming:seed_spelt"
end

minetest.register_node(":flowers:sunflower", {
	description = "Sunflower",
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	inventory_image = "flowers_sunflower_inv.png",
	mesh = "flowers_sunflower.obj",
	tiles = { "flowers_sunflower.png" },
	walkable = false,
	buildable_to = true,
	is_ground_content = true,
	groups = { dig_immediate=3, flora=1, flammable=3 },
	sounds = default.node_sound_leaves_defaults(),
	selection_box = box,
	collision_box = box,
	drop = {
		max_items = 1,
		items = {
			{items = {sunflower_drop}, rarity = 8},
			{items = {"flowers:sunflower"}},
		}
	}
})

local extra_aliases = {
	"waterlily",
	"waterlily_225",
	"waterlily_45",
	"waterlily_675",
	"seaweed"
}

for i in ipairs(extra_aliases) do
	local flower = extra_aliases[i]
	minetest.register_alias("flowers:flower_"..flower, "flowers:"..flower)
end

minetest.register_alias( "trunks:lilypad"         ,	"flowers:waterlily_s1" )
minetest.register_alias( "along_shore:lilypads_1" , "flowers:waterlily_s1" )
minetest.register_alias( "along_shore:lilypads_2" , "flowers:waterlily_s2" )
minetest.register_alias( "along_shore:lilypads_3" , "flowers:waterlily_s3" )
minetest.register_alias( "along_shore:lilypads_4" , "flowers:waterlily_s4" )
minetest.register_alias( "along_shore:pondscum_1" ,	"flowers:seaweed"      )
minetest.register_alias( "along_shore:seaweed_1"  ,	"flowers:seaweed"      )
minetest.register_alias( "along_shore:seaweed_2"  ,	"flowers:seaweed_2"    )
minetest.register_alias( "along_shore:seaweed_3"  ,	"flowers:seaweed_3"    )
minetest.register_alias( "along_shore:seaweed_4"  ,	"flowers:seaweed_4"    )

print(S("[Flowers] Loaded."))
