local timer = {}
local times = {
	["brick"] = 2,
	["steel"] = 10,
	["gold"] = 70,
	["msteel"] = 20
}
minetest.register_globalstep(function(dtime)
	for lobby, ltable in pairs(mesewars.lobbys) do
		if ltable.ingame then
			if not timer[lobby] then
				timer[lobby] = {}
				timer[lobby].brick = 0
				timer[lobby].steel = 0
				timer[lobby].gold = 0
				timer[lobby].msteel = 0
			end
			timer[lobby].brick = timer[lobby].brick+dtime
			timer[lobby].steel = timer[lobby].steel+dtime
			timer[lobby].gold = timer[lobby].gold+dtime
			timer[lobby].msteel = timer[lobby].msteel+dtime
			for key, time in pairs(timer[lobby]) do
				if time >= times[key]/ltable.maxteam then
					local item = "default:steel_ingot"
					if key == "brick" then
						item = "default:clay_brick"
					elseif key == "gold" then
						item = "default:gold_ingot"
					end
					for i=0, #ltable[key] do
						minetest.spawn_item(ltable[key][i], item)
					end
				end
			end
		end
	end
end)
