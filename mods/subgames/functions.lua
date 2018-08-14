
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
function subgames.decomma_pos(pos)
  return {x=round(pos.x), y=round(pos.y), z=round(pos.z)}
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
  for lname in pairs(areas) do
    if is_inside_area(areas[lname][1], areas[lname][2], pos) then
      return lname
    end
  end
end

function subgames.check_drop(pos, itemname, player)
  local name = player:get_player_name()
  local lobby = player_lobby[name]
  if not lobby then
    lobby = subgames.get_lobby_from_pos(pos)
    if not lobby then
      return false
    end
  end
  local func = areas[lobby].drop
  if not func then
    return false
  else return func(pos, itemname, player)
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

--max 5 stages
function table_to_keyvalues(t)
	local toreturn = {}
	for k, v in pairs(t) do
		local kstr = tostring(k)
		if type(v) ~= "table" then
			table.insert(toreturn, {k=kstr, v=v})
		else
			for k, v1 in pairs(v) do
				local kstr1 = kstr.."€"..k
				if type(v1) ~= "table" then
					table.insert(toreturn, {k=kstr1, v=v1})
				else
					for k, v2 in pairs(v1) do
						local kstr2 = kstr1.."€"..k
						if type(v2) ~= "table" then
							table.insert(toreturn, {k=kstr2, v=v2})
						else
							for k, v3 in pairs(v2) do
								local kstr3 = kstr2.."€"..k
								if type(v3) ~= "table" then
									table.insert(toreturn, {k=kstr3, v=v3})
								else
									for k, v4 in pairs(v3) do
										local kstr4 = kstr3.."€"..k
										if type(v4) ~= "table" then
											table.insert(toreturn, {k=kstr4, v=v4})
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return toreturn
end

function table_to_modstorage(s, data, key)
  if key then
    key = key.."€"
  else key = ""
  end
	if type(data) == "table" then
		for _, table in pairs(table_to_keyvalues(data)) do
			if type(table.v) == "number" then
				if table.v == round(table.v) then
					s:set_int(key..table.k, table.v)
				else s:set_float(key..table.k, table.v)
				end
			else s:set_string(key..table.k, tostring(table.v))
			end
		end
	end
end

function modstorage_to_table(s)
  local toreturn = {}
  for kstr, v in pairs(s:to_table().fields) do
    keys = string.split(kstr, "€")
    if not keys then
      return
    end
    if toboolean(v) or toboolean(v) == false then
      v = toboolean(v)
    elseif tonumber(v) then
      v = tonumber(v)
    end
    for numb, string in pairs(keys) do
      if tonumber(string) and string ~= "nan" then --NaN compatible
        keys[numb] = tonumber(string)
      end
    end
    if type(toreturn[keys[1]]) ~= "table" then toreturn[keys[1]] = {} end
    if #keys >= 2 then
      if type(toreturn[keys[1]][keys[2]]) ~= "table" then toreturn[keys[1]][keys[2]] = {} end
      if #keys >= 3 then
        if type(toreturn[keys[1]][keys[2]][keys[3]]) ~= "table" then toreturn[keys[1]][keys[2]][keys[3]] = {} end
        if #keys >= 4 then
          if type(toreturn[keys[1]][keys[2]][keys[3]][keys[4]]) ~= "table" then toreturn[keys[1]][keys[2]][keys[3]][keys[4]] = {} end
          if #keys == 5 then
            toreturn[keys[1]][keys[2]][keys[3]][keys[4]][keys[5]] = v
          else toreturn[keys[1]][keys[2]][keys[3]][keys[4]] = v
          end
        else toreturn[keys[1]][keys[2]][keys[3]] = v
        end
      else toreturn[keys[1]][keys[2]] = v
      end
    else toreturn[keys[1]] = v
    end
  end
  return toreturn
end
