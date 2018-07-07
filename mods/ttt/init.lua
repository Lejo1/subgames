--[[This is the controllmod of ttt]]

ttt = {}
dofile(minetest.get_modpath("ttt") .."/start.lua")
dofile(minetest.get_modpath("ttt") .."/ingame.lua")
dofile(minetest.get_modpath("ttt") .."/commands.lua")
dofile(minetest.get_modpath("ttt") .."/items.lua")
dofile(minetest.get_modpath("ttt") .."/chests.lua")

ttt.lobbys = {
  [1] = {
    ["string_name"] = "TTT Karsthafen",
    ["pos"] = {x=716, y=12, z=732},
    ["ingame"] = false,
    ["players"] = {},
    ["preparingtime"] = 0,
    ["timetowin"] = 0,
    ["preparing"] = false,
    ["mustcreate"] = false,
    ["grounds"] = {"default:dirt", "default:wood"}
    ["mappos1"] = {x=1000, y=2000, z=0},
    ["mappos2"] = {x=1118, y=2070, z=126},
    ["schem"] = "hide1",
    ["schempos"] = {x=700, y=0, z=700}
  }
}

ttt.player_lobby = {}
ttt.max_players = 20
ttt.timetowin = 300
ttt.preparingtime = 30
ttt.chestcount = 50

--[[Nametag
Better globalstep
Special items.]]


function ttt.get_lobby_players(lobby)
  local players = {}
  for _, player in pairs(subgames.get_lobby_players("ttt")) do
    local name = player:get_player_name()
    if ttt.player_lobby[name] == lobby then
      table.insert(players, player)
    end
  end
  return players
end

function ttt.create_teleporter_form()
  local status = {}
  for lobby, table in pairs(ttt.lobbys) do
    if lobby ~= 0 then
      if table.ingame == true then
        status[lobby] = minetest.colorize("red", "Ingame")
      elseif #ttt.get_lobby_players(lobby) >= 2 then
        status[lobby] = minetest.colorize("yellow", "Starting")
      else status[lobby] = minetest.colorize("lime", "Waiting")
      end
      status[lobby] = #ttt.get_lobby_players(lobby).."/"..ttt.max_players.." "..status[lobby]
    end
  end
    return ("size[4,4]" ..
    "image_button[0,0;2,2;hideandseek.png;map1;"..status[1].."]" ..
    "tooltip[map1;"..ttt.lobbys[1].string_name.."]")
end

minetest.register_on_player_receive_fields(function(player, formname, pressed)
  if formname == "ttt:teleporter" then
    local name = player:get_player_name()
    if pressed.map1 then
      ttt.leave_game(player)
      minetest.chat_send_player(name, ttt.join_game(player, 1))
    end
    minetest.close_formspec(name, "ttt:teleporter")
  end
end)

subgames.register_on_joinplayer(function(player, lobby)
  if lobby == "ttt" then
    local name = player:get_player_name()
    ttt.join_game(player, 1)
    subgames.add_mithud(player, "You joined Trouble in Terrorist Town!", 0xFFFFFF, 3)
    subgames.chat_send_all_lobby("ttt", "*** "..name.." joined Hide and Seek.")
  end
end)

subgames.register_on_leaveplayer(function(player, lobby)
  if lobby == "ttt" then
    local name = player:get_player_name()
    local plobby = ttt.player_lobby[name]
    ttt.leave_game(player)
    ttt.win(plobby)
    ttt.player_lobby[name] = nil
    subgames.chat_send_all_lobby("ttt", "*** "..name.." left Trouble in Terrorist Town.")
  end
end)

function areas.ttt.dig(pos, node, digger)
  return false
end

function areas.ttt.place(itemstack, placer, pointed_thing, param2)
  return false
end


function ttt.chat_send_all_lobby(lobby, msg)
  for _,player in pairs(ttt.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    minetest.chat_send_player(name, msg)
  end
end

subgames.register_on_chat_message(function(name, message, lobby)
  if lobby == "ttt" then
    local plobby = ttt.player_lobby[name]
    if ttt.lobbys[plobby].ingame == false or ttt.lobbys[plobby].players[name] ~= false then
      ttt.chat_send_all_lobby(plobby, "<"..name.."> "..message)
      return true
    else for _, player in pairs(ttt.get_lobby_players(plobby)) do
      local name = player:get_player_name()
      if ttt.lobbys[plobby].players[name] == false then
        minetest.chat_send_player(">"..name.."< "..message)
      end
    end
    end
  end
end)

subgames.register_on_drop(function(itemstack, dropper, pos, lobby)
  if lobby == "ttt" then
    return false
  end
end)

subgames.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, lobby)
  if lobby == "ttt" and player and hitter then
    if damage == 0 then
      return
    end
    local name = player:get_player_name()
    local hitname = hitter:get_player_name()
    local plobby = ttt.player_lobby[name]
    if (ttt.lobbys[plobby].players[name] == "traitor" and ttt.lobbys[plobby].players[hitname] == "traitor") or not ttt.lobbys[plobby].ingame then
      player:set_hp(player:get_hp()+damage)
      if ttt.lobbys[plobby].ingame then
        minetest.chat_send_player(hitname, name.." is also Traitor!")
      end
    end
  end
end)

subgames.register_on_kill_player(function(killer, killed, lobby)
	local killedname = killed:get_player_name()
	local killname = killer:get_player_name()
	if lobby == "ttt" and ttt.player_lobby[killname] ~= 0 then
    local lobby = ttt.player_lobby[killname]
		local killrol = ttt.lobbys[lobby].players[killname]
		if killrol == "traitor" then
  		money.set_money(killname, money.get_money(killname)+10)
  		minetest.chat_send_player(killname, "CoinSystem: You have receive 10 Coins!")
		end
    ttt.spawn_zombie(killed, killrol)
	end
end)

function ttt.join_game(player, lobby)
  local name = player:get_player_name()
  if #ttt.get_lobby_players(lobby) >= ttt.max_players then
    return "The lobby is full!"
  elseif ttt.lobbys[lobby].ingame == true then
    player:setpos(ttt.lobbys[lobby].pos)
    ttt.lobbys[lobby].players[name] = false
    subgames.clear_inv(player)
    subgames.spectate(player)
    return "Lobby is ingame. So you are now spectating!"
  else ttt.player_lobby[name] = lobby
    player:setpos(ttt.lobbys[lobby].pos)
    subgames.clear_inv(player)
      ttt.lobbys[lobby].players[name] = true
      sfinv.set_page(player, "3d_armor:armor")
      player:get_inventory():add_item("main", "subgames:leaver")
      ttt.win(lobby)
    if ttt.lobbys[lobby].mustcreate == true then
      ttt.lobbys[lobby].mustcreate = false
      minetest.chat_send_all("Creating Trouble in Terrorist Town map don't leave!, May lag")
      local schem = minetest.get_worldpath() .. "/schems/" .. ttt.lobbys[lobby].schem .. ".mts"
      minetest.place_schematic(ttt.lobbys[lobby].schempos, schem)
    end
    return "You joined the map "..ttt.lobbys[lobby].string_name.."!"
  end
end

function ttt.leave_game(player)
  local name = player:get_player_name()
  local lobby = ttt.player_lobby[name]
  if lobby then
    ttt.lobbys[lobby].players[name] = nil
    if ttt.lobbys[lobby].ingame then
      ttt.chat_send_all_lobby(lobby, name.." left this Round.")
    end
  end
end
