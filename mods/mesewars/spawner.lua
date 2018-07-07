--  Import spawner pos.
local brick1 = minetest.setting_get_pos("brick1")
local brick2 = minetest.setting_get_pos("brick2")
local brick3 = minetest.setting_get_pos("brick3")
local brick4 = minetest.setting_get_pos("brick4")
local steel1 = minetest.setting_get_pos("steel1")
local steel2 = minetest.setting_get_pos("steel2")
local steel3 = minetest.setting_get_pos("steel3")
local steel4 = minetest.setting_get_pos("steel4")
local gold1 = minetest.setting_get_pos("gold1")
local gold2 = minetest.setting_get_pos("gold2")
local gold3 = minetest.setting_get_pos("gold3")
local gold4 = minetest.setting_get_pos("gold4")
local msteel1 = minetest.setting_get_pos("msteel1")
local msteel2 = minetest.setting_get_pos("msteel2")
local msteel3 = minetest.setting_get_pos("msteel3")
local msteel4 = minetest.setting_get_pos("msteel4")

--  Spawn bricks
local btimer = 0
minetest.register_globalstep(function(dtime)
	btimer = btimer + dtime;
	if btimer >= 2/spawnfast then
		if spawner == true then
			minetest.spawn_item(brick1, 'default:clay_brick')
    	minetest.spawn_item(brick2, 'default:clay_brick')
    	minetest.spawn_item(brick3, 'default:clay_brick')
    	minetest.spawn_item(brick4, 'default:clay_brick')
			btimer = 0
		end
	end
end)

--  Spawn Steel
local stimer = 0
minetest.register_globalstep(function(dtime)
	stimer = stimer + dtime;
	if stimer >= 10/spawnfast then
		if spawner == true then
			minetest.spawn_item(steel1, 'default:steel_ingot')
    	minetest.spawn_item(steel2, 'default:steel_ingot')
    	minetest.spawn_item(steel3, 'default:steel_ingot')
    	minetest.spawn_item(steel4, 'default:steel_ingot')
			stimer = 0
		end
	end
end)

--  Spawn gold4
local gtimer = 0
minetest.register_globalstep(function(dtime)
	gtimer = gtimer + dtime;
	if gtimer >= 70/spawnfast then
		if spawner == true then
			minetest.spawn_item(gold1, 'default:gold_ingot')
    	minetest.spawn_item(gold2, 'default:gold_ingot')
    	minetest.spawn_item(gold3, 'default:gold_ingot')
    	minetest.spawn_item(gold4, 'default:gold_ingot')
			gtimer = 0
		end
	end
end)

--  Spawn Steel in Middle
local stimer = 0
minetest.register_globalstep(function(dtime)
	stimer = stimer + dtime;
	if stimer >= 20/spawnfast then
		if spawner == true then
			minetest.spawn_item(msteel1, 'default:steel_ingot')
    	minetest.spawn_item(msteel2, 'default:steel_ingot')
    	minetest.spawn_item(msteel3, 'default:steel_ingot')
    	minetest.spawn_item(msteel4, 'default:steel_ingot')
			stimer = 0
		end
	end
end)
