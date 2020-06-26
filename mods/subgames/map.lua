minetest.set_mapgen_params({seed=math.random(10000000000000000000, 99999999999999999999)})
minetest.set_mapgen_params({flags = "nodungeons, noridges, nocaves, nofloatlands"})
local maps_used = {}
local c_maptools_glass = minetest.get_content_id("maptools:glass")
minetest.register_on_generated(function(minp, maxp, seed)
  if minp.y > 150 or maxp.y < -50 then return end
  local zpos = round(maxp.z/500)*500
  local xpos = round(maxp.x/500)*500
  if (maxp.z >= zpos and minp.z <= zpos) or (maxp.x >= xpos and minp.x <= xpos) or (maxp.y >= 150 and minp.y <= 150) or (maxp.y >= -50 and minp.y <= -50) then
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local data = vm:get_data()
    local a = VoxelArea:new{
      MinEdge = emin,
      MaxEdge = emax
    }
    local function wall(minx, miny, minz, maxx, maxy, maxz)
      miny = math.max(miny, (-50))
      maxy = math.min(maxy, 150)
      for i in a:iter(minx, miny, minz, maxx, maxy, maxz) do
        data[i] = c_maptools_glass
      end
    end

    if maxp.z >= zpos and minp.z <= zpos then
      wall(minp.x, minp.y, zpos, maxp.x, maxp.y, zpos)
    end

    if maxp.x >= xpos and minp.x <= xpos then
      wall(xpos, minp.y, minp.z, xpos, maxp.y, maxp.z)
  	end

    if maxp.y >= 150 and minp.y <= 150 then
      wall(minp.x, 150, minp.z, maxp.x, 150, maxp.z)
    end

    if maxp.y >= -50 and minp.y <= -50 then
      wall(minp.x, (-50), minp.z, maxp.x, (-50), maxp.z)
    end

    vm:set_data(data)
    vm:calc_lighting(emin, emax)
    vm:write_to_map(true)
  end
end)

function subgames.get_map(func)
  local pos1
  while not pos1 or maps_used[minetest.pos_to_string(pos1)] do
    local posx = math.random(-60, 60)*500
    local posz = math.random(-60, 60)*500
    pos1 = {x= posx, y=150, z=posz}
  end
  maps_used[minetest.pos_to_string(pos1)] = true
  local pos2 = {x=pos1.x-500, y=-50, z=pos1.z-500}
  local middle = {x=pos1.x-250, y=80, z=pos1.z-250}
  minetest.emerge_area({x=middle.x, y=140, z=middle.z}, {x=middle.x, y=-50, z=middle.z}, function(blockpos, action, calls_remaining, param)
    if calls_remaining == 0 then
      local mid = {x=middle.x, y=140, z=middle.z}
      local node = minetest.get_node(mid)
      while (node.name == "air") and mid.y > -50 do
        mid.y = mid.y -1
        node = minetest.get_node(mid)
      end
      mid.y = mid.y +1
      param(mid)
    end
  end, func)
  return pos1, pos2, middle
end
