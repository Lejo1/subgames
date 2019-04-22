-- mods/fairplay/init.lua
-- =================
-- See README.txt for licensing and other information.

--Fly Detection

local time = 0
local flytbl = {}

local function check_fly(player, name)
  local pos = vector.round(player:get_pos())
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

local bevorposes = {}
local function check_noclip(player, name)
  if minetest.get_player_privs(name).noclip then
    return
  end
  local pos = player:get_pos()
  local fnode = minetest.registered_nodes[minetest.get_node(pos).name]
  local hnode = minetest.registered_nodes[minetest.get_node(vector.add(pos, {x=0, y=1, z=0})).name]
  if fnode and fnode.walkable and (not fnode.node_box or fnode.node_box.type == "regular")
   and hnode and hnode.walkable and (not hnode.node_box or hnode.node_box.type == "regular") then
     if not bevorposes[name] then
       bevorposes[name] = vector.round(pos)
     elseif vector.distance(bevorposes[name], pos) >= 2 then
       minetest.kick_player(name, "Autokick: Please disable your noclip cheat")
       bevorposes[name] = nil
     end
  else
    bevorposes[name] = nil
  end
end

minetest.register_globalstep(function(dtime)
    time = time + dtime
    if time < 1 then
      return
    end
    time = 0
    for _, player in ipairs(minetest.get_connected_players()) do
      if not player then
        return
      end
      local name = player:get_player_name()
      check_fly(player, name)
      check_noclip(player, name)
    end
end)
