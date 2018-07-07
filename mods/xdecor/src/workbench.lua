local workbench = {}
WB = {}
screwdriver = screwdriver or {}
local min, ceil = math.min, math.ceil
local registered_nodes = minetest.registered_nodes

-- Nodes allowed to be cut
-- Only the regular, solid blocks without metas or explosivity can be cut
local nodes = {}

-- Optionally, you can register custom cuttable nodes in the workbench

xdecor.register("workbench", {
	description = "Work Bench",
	groups = {cracky=2, choppy=2, oddly_breakable_by_hand=1},
	sounds = default.node_sound_wood_defaults(),
	tiles = {"xdecor_workbench_top.png",   "xdecor_workbench_top.png",
		 "xdecor_workbench_sides.png", "xdecor_workbench_sides.png",
		 "xdecor_workbench_front.png", "xdecor_workbench_front.png"},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = player:get_player_name()
		if minetest.get_player_privs(name).craft then
			minetest.show_formspec(name, "crafting",
			"size[8,7.5]list[current_player;main;0,3.5;8,4;]list[current_player;craft;0,0;3,3;]list[current_player;craftpreview;4,1;1,1;]listring[current_player;main]listring[current_player;craft]"
			)
		end
	end
})
