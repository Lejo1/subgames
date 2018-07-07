minetest.set_mapgen_params({seed=math.random(10000000000000000000, 99999999999999999999)})
minetest.set_mapgen_params({water_level=-60})
minetest.set_mapgen_params({flags = "nodungeons, noridges"})
maps_used = {}
first_seed = 275068
minetest.register_on_generated(function(minp, maxp, seed)
  if minp.y > 150 or maxp.y < -50 then return end
  local zpos = round(maxp.z/500)*500
  local xpos = round(maxp.x/500)*500
  local todo
  local count = 0
  if maxp.z >= zpos and minp.z <= zpos then
    count = count+1
    function todo(pos1, pos2)
      pos1.z = zpos ; pos2.z = zpos
      return pos1, pos2
    end
  end
  if maxp.x >= xpos and minp.x <= xpos then
    count = count+1
    function todo(pos1, pos2)
      pos1.x = xpos ; pos2.x = xpos
      return pos1, pos2
    end
	end
  if (maxp.y > 150 and minp.y < 150 or maxp.y > -50 and minp.y < -50) then
    count = count+1
    function todo(pos1, pos2)
      local high
      if maxp.y > 150 and minp.y < 150 then high=150 else high=(-50) end
      pos1.y = high ; pos2.y = high
      return pos1, pos2
    end
  end
  if count > 0 then
    if count == 1 then
      local pos1, pos2 = todo(minp, maxp)
      worldedit.set(pos1, pos2, "maptools:glass")
    else worldedit.set(minp, maxp, "maptools:glass")
    end
  end
end)

function subgames.get_map()
  local pos1
  while not pos1 or maps_used[minetest.pos_to_string(pos1)] do
    local posx = math.random(-60, 60)*500
    local posz = math.random(-60, 60)*500
    pos1 = {x= posx, y=150, z=posz}
  end
  maps_used[minetest.pos_to_string(pos1)] = true
  local pos2 = {x=pos1.x-500, y=-50, z=pos1.z-500}
  local middle = {x=pos1.x-250, y=80, z=pos1.z-250}
  return pos1, pos2, middle
end
