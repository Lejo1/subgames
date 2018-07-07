function skywars.create_teleporter_form()
  local status = {}
  for lobby, table in pairs(skywars.lobbys) do
    if lobby ~= 0 then
      if table.ingame == true then
        status[lobby] = minetest.colorize("red", "Ingame")
      elseif #skywars.get_lobby_players(lobby) >= 2 then
        status[lobby] = minetest.colorize("yellow", "Starting")
      else status[lobby] = minetest.colorize("lime", "Waiting")
      end
      status[lobby] = #skywars.get_lobby_players(lobby).."/"..skywars.lobbys[lobby].playercount.." "..status[lobby]
    end
  end
  local toreturn = ("size[4,5]" ..
    "image_button[0,0;2,2;tiki.jpg;map1;"..status[1].."]" ..
    "tooltip[map1;"..skywars.lobbys[1].string_name.."]" ..
    "image_button[2,0;2,2;submerged.png;map2;"..status[2].."]" ..
    "tooltip[map2;"..skywars.lobbys[2].string_name.."]"..
    "label[0,5;All maps from Hypixel.net]")
  return toreturn
end

local function get_lobby_from_pos(pos)
  for lname, table in pairs(skywars.lobbys) do
    if lname ~= 0 then
      if is_inside_area(table.mappos1, table.mappos2, pos) then
        return lname
      end
    end
  end
end

subgames.register_on_joinplayer(function(player, lobby)
  if lobby == "skywars" then
    local name = player:get_player_name()
    skywars.join_game(player, 1)
    subgames.add_mithud(player, "You joined Skywars!", 0xFFFFFF, 3)
    subgames.chat_send_all_lobby("skywars", "*** "..name.." joined Skywars.")
  end
end)

subgames.register_on_leaveplayer(function(player, lobby)
  if lobby == "skywars" then
    local name = player:get_player_name()
    local plobby = skywars.player_lobby[name]
    skywars.leave_game(player)
    skywars.win(plobby)
    skywars.player_lobby[name] = nil
    subgames.chat_send_all_lobby("skywars", "*** "..name.." left Skywars.")
  end
end)

subgames.register_on_dignode(function(pos, oldnode, digger, lobby)
  if lobby == "skywars" then
    local name = digger:get_player_name()
    local plobby = skywars.player_lobby[name]
    local spos = minetest.pos_to_string(pos)
    if not skywars.lobbys[plobby].mapblocks[spos] then
      skywars.lobbys[plobby].mapblocks[spos] = oldnode
    end
  end
end)

subgames.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing, lobby)
  if lobby == "skywars" then
    local plobby
    if not placer or not placer:is_player() then
      plobby = get_lobby_from_pos(pos)
    else local name = placer:get_player_name()
      plobby = skywars.player_lobby[name]
    end
    if not plobby then return end
    local spos = minetest.pos_to_string(pos)
    if not skywars.lobbys[plobby].mapblocks[spos] then
      skywars.lobbys[plobby].mapblocks[spos] = oldnode
    end
  end
end)

function areas.skywars.dig(pos, node, digger)
  local name = digger:get_player_name()
  local plobby = skywars.player_lobby[name]
  if skywars.lobbys[plobby].ingame then
    return true
  end
end

function areas.skywars.place(itemstack, placer, pointed_thing, param2)
  local plobby
  if not placer or not placer:is_player() then
    plobby = get_lobby_from_pos(pos)
  else local name = placer:get_player_name()
    plobby = skywars.player_lobby[name]
  end
  if not plobby then return end
  if skywars.lobbys[plobby].ingame then
    return true
  end
end

subgames.register_on_drop(function(itemstack, dropper, pos, lobby)
  if lobby == "skywars" then
    local name = dropper:get_player_name()
    local plobby = skywars.player_lobby[name]
    if not plobby or not skywars.lobbys[plobby].ingame then
      return false
    end
  end
end)

function areas.skywars.drop(pos, itemname, player)
  local name = player:get_player_name()
  local plobby = skywars.player_lobby[name]
  if not plobby then
    plobby = get_lobby_from_pos(pos)
    if not plobby then
      return false
    end
  end
  if skywars.lobbys[plobby].ingame then
    return true
  else return false
  end
end

subgames.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, lobby)
  if lobby == "skywars" and player and hitter then
    if damage == 0 then
      return
    end
    local name = player:get_player_name()
    local plobby = skywars.player_lobby[name]
    if plobby == 0 or not skywars.lobbys[plobby].ingame then
      player:set_hp(player:get_hp()+damage)
    end
  end
end)

subgames.register_on_chat_message(function(name, message, lobby)
  if lobby == "skywars" then
    local plobby = skywars.player_lobby[name]
    for aname, alobby in pairs(skywars.player_lobby) do
      if alobby == plobby then
        minetest.chat_send_player(aname, "<"..name.."> "..message)
      end
    end
    return true
  end
end)

subgames.register_on_respawnplayer(function(player, lobby)
	if lobby == "skywars" then
		local name = player:get_player_name()
		local plobby = skywars.player_lobby[name]
		if plobby ~= 0 and skywars.lobbys[plobby].ingame then
      if skywars.lobbys[plobby].players[name] then
			   skywars.lobbys[plobby].players[name] = false
			   skywars.chat_send_all_lobby(plobby, name.." died.")
			   skywars.chat_send_all_lobby(plobby, "There are "..skywars.get_player_count(plobby).." players left!")
         subgames.add_mithud(player, "You are now spectating!", 0xFF0000, 3)
         subgames.drop_inv(player, player:getpos())
      end
      subgames.spectate(player)
      player:setpos(skywars.lobbys[plobby].specpos)
			skywars.win(plobby)
		else player:setpos(skywars.lobbys[plobby].specpos)
		end
	end
end)

subgames.register_on_blast(function(pos, intensity, lobby)
  if lobby == "skywars" then
    local node = minetest.get_node(pos)
    local nodename = node.name
    local plobby = get_lobby_from_pos(pos)
    if not plobby or plobby == 0 or skywars.lobbys[plobby].ingame ~= true or nodename == "maptools:playerclip" or nodename == "maptools:damage_5" or nodename == "maptools:kill" then
      return false
    else local spos = minetest.pos_to_string(pos)
      if not skywars.lobbys[plobby].mapblocks[spos] then
        skywars.lobbys[plobby].mapblocks[spos] = node
      end
    end
  end
end)
