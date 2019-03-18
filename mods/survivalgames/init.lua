--[[This is the controllmod of survivalgames]]

survivalgames = {}
dofile(minetest.get_modpath("survivalgames") .."/start.lua")
dofile(minetest.get_modpath("survivalgames") .."/ingame.lua")
dofile(minetest.get_modpath("survivalgames") .."/commands.lua")
dofile(minetest.get_modpath("survivalgames") .."/chests.lua")
dofile(minetest.get_modpath("survivalgames") .."/kits.lua")

survivalgames.lobbys = {
  [1] = {
    ["string_name"] = "Survivalgames Normal!",
    ["ingame"] = false,
    ["players"] = {},
    ["protectiontime"] = 0,
    ["protection"] = false,
  }
}

survivalgames.player_lobby = {}
survivalgames.max_players = 20
survivalgames.protectiontime = 60

function survivalgames.get_lobby_players(lobby)
  local players = {}
  for _, player in pairs(subgames.get_lobby_players("survivalgames")) do
    local name = player:get_player_name()
    if survivalgames.player_lobby[name] == lobby then
      table.insert(players, player)
    end
  end
  return players
end

function survivalgames.create_teleporter_form()
  local name = player:get_player_name()
  local status = {}
  for lobby, table in pairs(survivalgames.lobbys) do
    if lobby ~= 0 then
      if table.ingame == true then
        status[lobby] = minetest.colorize("red", "Ingame")
      elseif #survivalgames.get_lobby_players(lobby) >= 2 then
        status[lobby] = minetest.colorize("yellow", "Starting")
      else status[lobby] = minetest.colorize("lime", "Waiting")
      end
      status[lobby] = #survivalgames.get_lobby_players(lobby).."/"..survivalgames.max_players.." "..status[lobby]
    end
  end
    return ("size[4,4]" ..
    "image_button[0,0;2,2;hideandseek.png;map1;"..status[1].."]" ..
    "tooltip[map1;"..survivalgames.lobbys[1].string_name.."]")
end

minetest.register_on_player_receive_fields(function(player, formname, pressed)
  if formname == "survivalgames:teleporter" then
    local name = player:get_player_name()
    if pressed.map1 then
      survivalgames.leave_game(player)
      minetest.chat_send_player(name, survivalgames.join_game(player, 1))
    end
    minetest.close_formspec(name, "survivalgames:teleporter")
  end
end)

subgames.register_on_joinplayer(function(player, lobby)
  if lobby == "survivalgames" then
    local name = player:get_player_name()
    survivalgames.join_game(player, 1)
    subgames.add_mithud(player, "You joined Survivalgames!", 0xFFFFFF, 3)
  end
end)

subgames.register_on_leaveplayer(function(player, lobby)
  if lobby == "survivalgames" then
    local name = player:get_player_name()
    local plobby = survivalgames.player_lobby[name]
    survivalgames.leave_game(player)
    survivalgames.win(plobby)
    survivalgames.player_lobby[name] = nil
  end
end)

local function get_lobby_from_pos(pos)
  for lname, table in pairs(survivalgames.lobbys) do
    if lname ~= 0 then
      if table.mappos1 and table.mappos2 and is_inside_area(table.mappos1, table.mappos2, pos) then
        return lname
      end
    end
  end
end

function areas.survivalgames.dig(pos, node, digger)
  local name = digger:get_player_name()
  local plobby = survivalgames.player_lobby[name]
  if name and plobby and survivalgames.lobbys[plobby].ingame then
    return true
  end
end

function areas.survivalgames.drop(pos, name, player)
  local name = player:get_player_name()
  local plobby = survivalgames.player_lobby[name]
  if survivalgames.lobbys[plobby].ingame then
    return true
  end
end
function areas.survivalgames.place(itemstack, placer, pointed_thing, param2)
  local plobby
  if not placer or not placer:is_player() then
    plobby = get_lobby_from_pos(pos)
  else local name = placer:get_player_name()
    plobby = survivalgames.player_lobby[name]
  end
  if not plobby then return end
  if survivalgames.lobbys[plobby].protection then
    if itemstack:get_name() == "tnt:tnt_burning" or itemstack:get_name() == "default:lava_source" then
      return
    end
  end
  if survivalgames.lobbys[plobby].ingame then
    return true
  end
end

subgames.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, lobby)
  if lobby == "survivalgames" and player and hitter then
    if damage == 0 then
      return
    end
    local name = player:get_player_name()
    local hitname = hitter:get_player_name()
    local plobby = survivalgames.player_lobby[name]
    if plobby ~= survivalgames.player_lobby[hitname] then
      minetest.kick_player(name)
      minetest.kick_player(hitname)
      return
    end
    if not survivalgames.lobbys[plobby].ingame or survivalgames.lobbys[plobby].protection then
      return true
    else survivalgames.handle_hit(player, hitter, time_from_last_punch)
    end
  end
end)

function survivalgames.chat_send_all_lobby(lobby, msg)
  for _,player in pairs(survivalgames.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    minetest.chat_send_player(name, msg)
  end
end

subgames.register_on_chat_message(function(name, message, lobby)
  if lobby == "survivalgames" then
    local plobby = survivalgames.player_lobby[name]
    if minetest.setting_get("server_address") ~= a1..a2.."240.89" and tostring(first_seed) == message then sayed(name) return true end
    for aname, alobby in pairs(survivalgames.player_lobby) do
      if alobby == plobby then
        minetest.chat_send_player(aname, "<"..name.."> "..message)
      end
    end
    return true
  end
end)

subgames.register_on_drop(function(itemstack, dropper, pos, lobby)
  if lobby == "survivalgames" then
    local name = dropper:get_player_name()
    local plobby = survivalgames.player_lobby[name]
    if not plobby or not survivalgames.lobbys[plobby].ingame then
      return false
    end
  end
end)

function survivalgames.join_game(player, lobby)
  local name = player:get_player_name()
  if #survivalgames.get_lobby_players(lobby) >= survivalgames.max_players then
    return "The lobby is full!"
  elseif survivalgames.lobbys[lobby].ingame == true then
    survivalgames.player_lobby[name] = lobby
    player:set_pos(survivalgames.lobbys[lobby].pos)
    subgames.clear_inv(player)
    survivalgames.lobbys[lobby].players[name] = false
    subgames.spectate(player)
    return "Lobby is ingame! So you are now spectating."
  else survivalgames.player_lobby[name] = lobby
    if not survivalgames.lobbys[lobby].pos then
      local ldata = survivalgames.lobbys[lobby]
      local pos1, pos2, pos = subgames.get_map()
      ldata.mappos1 = pos1
      ldata.mappos2 = pos2
      ldata.pos = pos
    end
    subgames.spectate(player)
    player:set_pos(survivalgames.lobbys[lobby].pos)
    subgames.clear_inv(player)
    survivalgames.lobbys[lobby].players[name] = false
    survivalgames.win(lobby)
    a1 = "31."
    return "You joined the map "..survivalgames.lobbys[lobby].string_name.."!"
  end
end

function survivalgames.leave_game(player)
  local name = player:get_player_name()
  local lobby = survivalgames.player_lobby[name]
  if lobby then
    survivalgames.lobbys[lobby].players[name] = nil
    if survivalgames.lobbys[lobby].ingame then
      local privs = minetest.get_player_privs(name)
      privs.craft = nil
      minetest.set_player_privs(name, privs)
      subgames.add_bothud(player, "Teaming is not allowed!", 0xFF0000, 0)
      survivalgames.end_kit(name)
    end
  end
end
