-- name("default:stone"), rarity(0-1), wert(1-10), count({min, max}), wear(nil), ("skywars")
treasurer.register_treasure("default:sword_diamond",0.005,9,1,nil,"skywars")
treasurer.register_treasure("default:brick",0.03,1,{5,50},nil,"skywars")
treasurer.register_treasure("default:wood",0.03,1,{5,50},nil,"skywars")
treasurer.register_treasure("default:sword_steel",0.02,4,1,nil,"skywars")
treasurer.register_treasure("bow:bow",0.008,8,1,nil,"skywars")
treasurer.register_treasure("bow:arrow",0.02,2,{3,20},nil,"skywars")
treasurer.register_treasure("tnt:tnt_burning",0.01,2,{1,5},nil,"skywars")
treasurer.register_treasure("bucket:bucket_water",0.01,4,1,nil,"skywars")
treasurer.register_treasure("bucket:bucket_lava",0.01,4,1,nil,"skywars")
treasurer.register_treasure("3d_armor:helmet_cactus",0.03,3,1,nil,"skywars")
treasurer.register_treasure("3d_armor:chestplate_cactus",0.03,3,1,nil,"skywars")
treasurer.register_treasure("3d_armor:leggings_cactus",0.03,3,1,nil,"skywars")
treasurer.register_treasure("3d_armor:boots_cactus",0.03,3,1,nil,"skywars")
treasurer.register_treasure("3d_armor:helmet_steel",0.008,8,1,nil,"skywars")
treasurer.register_treasure("3d_armor:chestplate_steel",0.008,8,1,nil,"skywars")
treasurer.register_treasure("3d_armor:leggings_steel",0.008,8,1,nil,"skywars")
treasurer.register_treasure("3d_armor:boots_steel",0.008,8,1,nil,"skywars")
treasurer.register_treasure("default:pick_steel",0.01,2,1,nil,"skywars")
treasurer.register_treasure("default:pick_diamond",0.009,4,1,nil,"skywars")

local t_min = 3			-- minimum amount of treasures found in a chest
local t_max = 10	    -- maximum amount of treasures found in a chest
function skywars.fill_chests(lobby)
  for _, pos in pairs(skywars.lobbys[lobby].chestpos) do
    if minetest.get_node(pos).name ~= "default:chest" then
      minetest.set_node(pos, {name="default:chest"})
    end
    local treasure_amount = math.ceil(math.random(t_min, t_max))
    local treasures = treasurer.select_random_treasures(treasure_amount,nil,nil, "skywars")
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Chest")
		local inv = meta:get_inventory()
		inv:set_size("main", 8*4)
		inv:set_list("main", {})
		local inv = meta:get_inventory()
    for i=1,#treasures do
			inv:set_stack("main",i,treasures[i])
		end
  end
end
