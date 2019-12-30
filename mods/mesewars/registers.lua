function mesewars.create_teleporter_form()
  local status = {}
  for lobby, table in pairs(mesewars.lobbys) do
    if lobby ~= 0 then
      if table.ingame == true then
        status[lobby] = minetest.colorize("red", "Ingame")
      elseif #mesewars.get_lobby_players(lobby) >= 2 then
        status[lobby] = minetest.colorize("yellow", "Starting")
      else status[lobby] = minetest.colorize("lime", "Waiting")
      end
      status[lobby] = #mesewars.get_lobby_players(lobby).."/"..mesewars.lobbys[lobby].playercount.." "..status[lobby]
    end
  end
  local toreturn = ("size[4,5]" ..
    "image_button[0,0;2,2;newmese.png;map1;"..status[1].."]" ..
    "tooltip[map1;"..mesewars.lobbys[1].string_name.."]" ..
    "image_button[2,0;2,2;submese.png;map2;"..status[2].."]" ..
    "tooltip[map2;"..mesewars.lobbys[2].string_name.."]")
  return toreturn
end

local function get_lobby_from_pos(pos)
  for lname, table in pairs(mesewars.lobbys) do
    if lname ~= 0 then
      if is_inside_area(table.mappos1, table.mappos2, pos) then
        return lname
      end
    end
  end
end

subgames.register_on_joinplayer(function(player, lobby)
  if lobby == "mesewars" then
    local name = player:get_player_name()
    subgames.add_mithud(player, mesewars.join_game(player, 1), 0xFFFFFF, 3)
  end
end)

subgames.register_on_leaveplayer(function(player, lobby)
  if lobby == "mesewars" then
    local name = player:get_player_name()
    local plobby = mesewars.player_lobby[name]
    mesewars.leave_game(player)
    mesewars.win(plobby)
    mesewars.player_lobby[name] = nil
  end
end)

subgames.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing, lobby)
  if lobby == "mesewars" then
    local plobby
    if not placer or not placer:is_player() then
      plobby = get_lobby_from_pos(pos)
    else local name = placer:get_player_name()
      plobby = mesewars.player_lobby[name]
    end
    if not plobby then return end
    local spos = minetest.pos_to_string(pos)
    if not mesewars.lobbys[plobby].mapblocks[spos] then
      mesewars.lobbys[plobby].mapblocks[spos] = oldnode
    end
  end
end)

function areas.mesewars.dig(pos, node, digger)
  local name = digger:get_player_name()
  local plobby = mesewars.player_lobby[name]
  local nodename = node.name
  if mesewars.lobbys[plobby].ingame and (mesewars.lobbys[plobby].mapblocks[minetest.pos_to_string(pos)] and (nodename == "default:sandstone" or nodename == "default:obsidian" or nodename == "default:glass" or nodename == "default:steelblock" or nodename == "default:chest")) or string.find(nodename, "mesewars:mese") then
    return true
  end
end

function areas.mesewars.place(itemstack, placer, pointed_thing, param2)
  local plobby
  if not placer or not placer:is_player() then
    plobby = get_lobby_from_pos(pos)
  else local name = placer:get_player_name()
    plobby = mesewars.player_lobby[name]
  end
  if not plobby then return end
  if mesewars.lobbys[plobby].ingame then
    return true
  end
end

subgames.register_on_drop(function(itemstack, dropper, pos, lobby)
  if lobby == "mesewars" then
    return false
  end
end)

function areas.mesewars.drop(pos, itemname, player)
  local name = player:get_player_name()
  local plobby = mesewars.player_lobby[name]
  if not plobby then
    plobby = get_lobby_from_pos(pos)
    if not plobby then
      return false
    end
  end
  if mesewars.lobbys[plobby].ingame and itemname == "default:sandstone" or itemname == "default:obsidian" or itemname == "default:glass" or itemname == "default:steelblock" or itemname == "default:chest" then
    return true
  else return false
  end
end

function mesewars.get_team_base(name)
  local lobby = mesewars.player_lobby[name]
  if lobby and mesewars.lobbys[lobby] and mesewars.lobbys[lobby].players[name] and mesewars.lobbys[lobby].pos[mesewars.lobbys[lobby].players[name]] then
    return mesewars.lobbys[lobby].pos[mesewars.lobbys[lobby].players[name]]
  else return {x=0, y=0, z=0}
  end
end

subgames.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, lobby)
  if lobby == "mesewars" and player and hitter then
    if damage == 0 then
      return
    end
    local name = player:get_player_name()
    local plobby = mesewars.player_lobby[name]
    if plobby == 0 or not mesewars.lobbys[plobby].ingame or mesewars.lobbys[plobby].players[name] == mesewars.lobbys[plobby].players[hitter:get_player_name()] then
      return true
    end
  end
end)

subgames.register_on_chat_message(function(name, message, lobby)
  if lobby == "mesewars" then
    local plobby = mesewars.player_lobby[name]
    for aname, alobby in pairs(mesewars.player_lobby) do
      if alobby == plobby then
        minetest.chat_send_player(aname, minetest.colorize(mesewars.get_color_from_team(mesewars.lobbys[plobby].players[name]), "<"..name.."> ")..message)
      end
    end
    return true
  end
end)

subgames.register_on_respawnplayer(function(player, lobby)
	if lobby == "mesewars" then
		local name = player:get_player_name()
		local plobby = mesewars.player_lobby[name]
		if plobby ~= 0 and mesewars.lobbys[plobby].ingame then
      if not mesewars.lobbys[plobby].meses[mesewars.lobbys[plobby].players[name]] then
        if mesewars.lobbys[plobby].players[name] then
			    mesewars.chat_send_all_lobby(plobby, minetest.colorize(mesewars.get_color_from_team(mesewars.lobbys[plobby].players[name]) ,name).." has been eliminated.")
          mesewars.lobbys[plobby].players[name] = false
          subgames.clear_inv(player)
          sfinv.set_page(player, "subgames:team")
        end
        subgames.spectate(player)
        player:setpos(mesewars.lobbys[plobby].specpos)
			  mesewars.win(plobby)
      else
        subgames.clear_inv(player)
        player:setpos(mesewars.get_team_base(name))
      end
		else player:setpos(mesewars.lobbys[plobby].specpos)
		end
	end
end)

subgames.register_on_blast(function(pos, intensity, lobby)
  if lobby == "mesewars" then
    local node = minetest.get_node(pos)
    local nodename = node.name
    local plobby = get_lobby_from_pos(pos)
    if not plobby or plobby == 0 or mesewars.lobbys[plobby].ingame ~= true or not mesewars.lobbys[plobby].mapblocks[minetest.pos_to_string(pos)] or not (nodename == "default:sandstone" or nodename == "default:obsidian" or nodename == "default:glass" or nodename == "default:steelblock" or nodename == "default:chest") then
      return false
    end
  end
end)

--  Add the Meseblock for all teams.

--  For Team 1
minetest.register_node("mesewars:mese1", {
  description = "Dig Me!",
  tiles = {"mese.png"},
  groups = {choppy = 2, oddly_breakable_by_hand = 2},
  drop = "",
  after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local name = digger:get_player_name()
    local lobby = get_lobby_from_pos(pos)
    if lobby and lobby ~= 0 then
      if mesewars.lobbys[lobby].players[name] == 1 then
        minetest.chat_send_player(name, "It's your mese!")
        minetest.set_node(pos, oldnode)
      else local msg = core.colorize("blue", "Team Blues Mese has been destroyed!")
        mesewars.chat_send_all_lobby(lobby, msg)
        for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
          subgames.add_mithud(player, "Team Blues Mese has been destroyed!", 0x0000FF, 3)
        end
        mesewars.lobbys[lobby].meses[1] = false
        money.set_money(name, money.get_money(name)+15)
        minetest.chat_send_player(name, "[CoinSystem] You have receive 15 Coins!")
        mesewars.win(lobby)
      end
    end
  end,
})

--  For Team 1
minetest.register_node("mesewars:mese2", {
  description = "Dig Me!",
  tiles = {"mese.png"},
  groups = {choppy = 2, oddly_breakable_by_hand = 2},
  drop = "",
  after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local name = digger:get_player_name()
    local lobby = get_lobby_from_pos(pos)
    if lobby and lobby ~= 0 then
      if mesewars.lobbys[lobby].players[name] == 2 then
        minetest.chat_send_player(name, "It's your mese!")
        minetest.set_node(pos, oldnode)
      else local msg = core.colorize("yellow", "Team Yellows Mese has been destroyed!")
        mesewars.chat_send_all_lobby(lobby, msg)
        for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
          subgames.add_mithud(player, "Team Yellows Mese has been destroyed!", 0xFFFF00, 3)
        end
        mesewars.lobbys[lobby].meses[2] = false
        money.set_money(name, money.get_money(name)+15)
        minetest.chat_send_player(name, "[CoinSystem] You have receive 15 Coins!")
        mesewars.win(lobby)
      end
    end
  end,
})

--  For Team 1
minetest.register_node("mesewars:mese3", {
  description = "Dig Me!",
  tiles = {"mese.png"},
  groups = {choppy = 2, oddly_breakable_by_hand = 2},
  drop = "",
  after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local name = digger:get_player_name()
    local lobby = get_lobby_from_pos(pos)
    if lobby and lobby ~= 0 then
      if mesewars.lobbys[lobby].players[name] == 3 then
        minetest.chat_send_player(name, "It's your mese!")
        minetest.set_node(pos, oldnode)
      else local msg = core.colorize("green", "Team Greens Mese has been destroyed!")
        mesewars.chat_send_all_lobby(lobby, msg)
        for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
          subgames.add_mithud(player, "Team Greens Mese has been destroyed!", 0x00FF00, 3)
        end
        mesewars.lobbys[lobby].meses[3] = false
        money.set_money(name, money.get_money(name)+15)
        minetest.chat_send_player(name, "[CoinSystem] You have receive 15 Coins!")
        mesewars.win(lobby)
      end
    end
  end,
})

--  For Team 1
minetest.register_node("mesewars:mese4", {
  description = "Dig Me!",
  tiles = {"mese.png"},
  groups = {choppy = 2, oddly_breakable_by_hand = 2},
  drop = "",
  after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local name = digger:get_player_name()
    local lobby = get_lobby_from_pos(pos)
    if lobby and lobby ~= 0 then
      if mesewars.lobbys[lobby].players[name] == 4 then
        minetest.chat_send_player(name, "It's your mese!")
        minetest.set_node(pos, oldnode)
      else local msg = core.colorize("red", "Team Reds Mese has been destroyed!")
        mesewars.chat_send_all_lobby(lobby, msg)
        for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
          subgames.add_mithud(player, "Team Blues Reds has been destroyed!", 0xFF0000, 3)
        end
        mesewars.lobbys[lobby].meses[4] = false
        money.set_money(name, money.get_money(name)+15)
        minetest.chat_send_player(name, "[CoinSystem] You have receive 15 Coins!")
        mesewars.win(lobby)
      end
    end
  end,
})
