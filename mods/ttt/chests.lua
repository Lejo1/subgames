-- name("default:stone"), rarity(0-1), wert(1-10), count({min, max}), wear(nil), ("ttt")
treasurer.register_treasure("default:sword_diamond",0.005,9,1,nil,"ttt")
treasurer.register_treasure("default:brick",0.03,1,{5,50},nil,"ttt")
treasurer.register_treasure("default:wood",0.03,1,{5,50},nil,"ttt")
treasurer.register_treasure("default:sword_steel",0.02,4,1,nil,"ttt")
treasurer.register_treasure("bow:bow",0.008,8,1,nil,"ttt")
treasurer.register_treasure("bow:arrow",0.02,2,{3,20},nil,"ttt")
treasurer.register_treasure("tnt:tnt_burning",0.01,2,{1,5},nil,"ttt")
treasurer.register_treasure("bucket:bucket_water",0.01,4,1,nil,"ttt")
treasurer.register_treasure("bucket:bucket_lava",0.01,4,1,nil,"ttt")
treasurer.register_treasure("3d_armor:helmet_cactus",0.03,3,1,nil,"ttt")
treasurer.register_treasure("3d_armor:chestplate_cactus",0.03,3,1,nil,"ttt")
treasurer.register_treasure("3d_armor:leggings_cactus",0.03,3,1,nil,"ttt")
treasurer.register_treasure("3d_armor:boots_cactus",0.03,3,1,nil,"ttt")
treasurer.register_treasure("3d_armor:helmet_steel",0.008,8,1,nil,"ttt")
treasurer.register_treasure("3d_armor:chestplate_steel",0.008,8,1,nil,"ttt")
treasurer.register_treasure("3d_armor:leggings_steel",0.008,8,1,nil,"ttt")
treasurer.register_treasure("3d_armor:boots_steel",0.008,8,1,nil,"ttt")
treasurer.register_treasure("default:pick_steel",0.01,2,1,nil,"ttt")
treasurer.register_treasure("default:pick_diamond",0.009,4,1,nil,"ttt")

local t_min = 3			-- minimum amount of treasures found in a chest
local t_max = 10	    -- maximum amount of treasures found in a chest
function ttt.spawn_chests(lobby)
  local counter = ttt.chestcount
  for _, pos in pairs(minetest.find_nodes_in_area_under_air(ttt.lobbys[lobby].mappos1, ttt.lobbys[lobby].mappos2, ttt.lobbys[lobby].grounds)) do
    local chestpos = pos ; pos.y = pos.y + 1
    counter = counter+1
    minetest.set_node(chestpos, "ttt:chest")
  end
end

minetest.register_node("ttt:chest", {
  description = "Dirt with Grass",
  tiles = {
		"default_chest_top.png",
		"default_chest_top.png",
		"default_chest_side.png",
		"default_chest_side.png",
		"default_chest_front.png",
		"default_chest_inside.png"
	},
  on_punch = ttt.give_chest_item,
  on_rightclick = ttt.give_chest_item
})

function ttt.give_chest_item(pos, node, player)
  local treasures = treasurer.select_random_treasures(1,nil,nil, "skywars")
end
