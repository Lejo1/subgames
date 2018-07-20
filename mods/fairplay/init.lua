-- mods/fairplay/init.lua
-- =================
-- See README.txt for licensing and other information.

--Fly Detection

local time = 0
local flytbl = {}

local function check_fly(name)
  local player = minetest.get_player_by_name(name)
  if not player then
    return
  end
  local pos = vector.round(player:getpos())
  local posbevor = pos
  local jump = player:get_physics_override().jump
  local speed = player:get_physics_override().speed
  if not minetest.get_player_privs(name).fly and #minetest.find_nodes_in_area({x = pos.x - (3 * speed), y = pos.y - (2 * jump), z = pos.z - (3 * speed)}, {x = pos.x + (3 * speed), y = pos.y, z = pos.z + (3 * speed)}, {"air"}) == (1 + (2 * jump)) * (1 + (6 * speed)) * (1 + (6 * speed)) and not ((default and default.player_attached and default.player_attached[name]) or (player_api and player_api.player_attached and player_api.player_attached[name])) then
    if not flytbl[name] then
      flytbl[name] = {}
    end
    if #flytbl[name] > 0 then
      posbevor = flytbl[name][#flytbl[name]]
    end
    if #flytbl[name] > 0 and ((posbevor.x == pos.x and posbevor.z == pos.z and posbevor.y == pos.y) or ((posbevor.y > pos.y + 1) and (vector.distance({x = posbevor.x, y = 0, z = posbevor.z}, {x = pos.x, y = 0, z = pos.z}) < 3))) then
      flytbl[name] = nil
      return
    end
    table.insert(flytbl[name], pos)
    if #flytbl[name] >= 3 then
      minetest.kick_player(name, "Autokick: Please disable your fly cheat")
      flytbl[name] = nil
      return
    end
    minetest.after(0.6, function()
        check_fly(name)
    end)
  else
    flytbl[name] = nil
  end
end

minetest.register_globalstep(function(dtime)
    time = time + dtime
    if time < 1 then
      return
    end
    time = 0
    for _, player in ipairs(minetest.get_connected_players()) do
      local name = player:get_player_name()
      check_fly(name)
    end
end)
