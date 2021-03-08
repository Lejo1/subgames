
--  Nice Functions
function table.contains(table, element)
  if type(table) == "table" then
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
  elseif table == element then
    return true
  else return false
  end
end

function subgames.concatornil(toconcat)
	if type(toconcat) == "table" then
		return table.concat(toconcat, ",")
	elseif toconcat == "" or toconcat == nil then
		return ""
	else return toconcat
	end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function toboolean(string)
  if string == "true" then
    return true
  elseif string == "false" then
    return false
  end
end

function is_inside_area(pos1, pos2, mainpos)
  if pos1.x < mainpos.x and mainpos.x < pos2.x or pos1.x > mainpos.x and mainpos.x > pos2.x then
    if pos1.y < mainpos.y and mainpos.y < pos2.y or pos1.y > mainpos.y and mainpos.y > pos2.y then
      if pos1.z < mainpos.z and mainpos.z < pos2.z or pos1.z > mainpos.z and mainpos.z > pos2.z then
        return true
      end
    end
  end
end

function subgames.get_lobby_from_pos(pos)
  for lname, d in pairs(subgames.games) do
    if is_inside_area(d.area[1], d.area[2], pos) then
      return lname
    end
  end
end

function subgames.get_lobby_players(lobby)
  local players = {}
  for _,value in ipairs(minetest.get_connected_players()) do
    local name = value:get_player_name()
    if player_lobby[name] == lobby then
      table.insert(players, value)
    end
  end
  return players
end

--  Add function to send message to all lobby players
function subgames.chat_send_all_lobby(lobby, msg)
  for _,player in pairs(subgames.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    minetest.chat_send_player(name, msg)
  end
end

function subgames.change_lobby(player, lobby)
  if lobby ~= player_lobby[player:get_player_name()] then
    subgames.call_leave_callbacks(player)
    subgames.call_join_callbacks(player, lobby)
  end
end

--  Clear a players inv
function subgames.clear_inv(name)
  local player = name
  local name, player_inv = armor:get_valid_player(player, "[on_dieplayer]")
		if not name then
			return
		end
		local drop = {}
		for i=1, player_inv:get_size("armor") do
			local stack = player_inv:get_stack("armor", i)
			if stack:get_count() > 0 then
				table.insert(drop, stack)
				armor:set_inventory_stack(player, i, nil)
				armor:run_callbacks("on_unequip", player, i, stack)
			end
		end
		armor:set_player_armor(player)
    local inv = player:get_inventory()
		inv:set_list("main", {})
    inv:set_list("craft", {})
		inv:set_list("armor", {})
		player:set_hp(20)
end

function subgames.drop_inv(name, pos)
  local player = name
  local name, player_inv = armor:get_valid_player(player, "[on_dieplayer]")
		if not name then
			return
		end
		local drop = {}
		for i=1, player_inv:get_size("armor") do
			local stack = player_inv:get_stack("armor", i)
			if stack:get_count() > 0 then
				table.insert(drop, stack)
				armor:set_inventory_stack(player, i, nil)
				armor:run_callbacks("on_unequip", player, i, stack)
			end
		end
		armor:set_player_armor(player)
    for i=1, player_inv:get_size("main") do
			local stack = player_inv:get_stack("main", i)
			if stack:get_count() > 0 then
				table.insert(drop, stack)
			end
		end
    for _, stack in pairs(drop) do
      local obj = minetest.add_item(pos, stack)
		  if obj then
			  obj:setvelocity({x=math.random(-1, 1), y=5, z=math.random(-1, 1)})
	    end
    end
    local inv = player:get_inventory()
		inv:set_list("main", {})
    inv:set_list("craft", {})
		inv:set_list("armor", {})
		player:set_hp(20)
end

function subgames.remove_all_player(name)
  for _, d in pairs(subgames.games) do
    if d.remove_player then
      d.remove_player(name)
    end
  end
end

function table_to_modstorage(s, data, key)
  if key then
    local ser_data = minetest.serialize(data)
    if ser_data == "return {}" then
      s:set_string(key, "")
    else s:set_string(key, ser_data)
    end
  else
    for k, v in pairs(data) do
      s:set_string(k, minetest.serialize(v))
    end
  end
end

function modstorage_to_table(s, key)
  if key then
    if string.find(s:get_string(key), "return") then
      return minetest.deserialize(s:get_string(key))
    end
  else
    local toreturn = {}
    for kstr, v in pairs(s:to_table().fields) do
      toreturn[kstr] = minetest.deserialize(v)
    end
    return toreturn
  end
end
