local function SecondsToClock(seconds)
  local seconds = tonumber(seconds)
  if seconds <= 0 then
    return "00:00";
  else
    local mins = string.format("%02.f", math.floor(seconds/60));
    local secs = string.format("%02.f", math.floor(seconds - mins *60));
    return mins..":"..secs
  end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
    timer = 0
		for lobby, ltable in pairs(survivalgames.lobbys) do
			if ltable.ingame and lobby ~= 0 then
				if ltable.protection then
					ltable.protectiontime = ltable.protectiontime -1
					if ltable.protectiontime <= 0 then
						survivalgames.unprotect(lobby)
						ltable.protection = false
					else for _,player in pairs(survivalgames.get_lobby_players(lobby)) do subgames.add_bothud(player, "protection time ends in "..SecondsToClock(ltable.protectiontime), 0x0000FF, 1.1) end
					end
        end
			end
		end
	end
end)

subgames.register_on_respawnplayer(function(player, lobby)
	if lobby == "survivalgames" then
		local name = player:get_player_name()
		local plobby = survivalgames.player_lobby[name]
		if plobby ~= 0 and survivalgames.lobbys[plobby].ingame then
      local pos = player:getpos()
      subgames.spectate(player)
      player:setpos(survivalgames.lobbys[plobby].pos)
      if survivalgames.lobbys[plobby].players[name] then
			  survivalgames.lobbys[plobby].players[name] = false
			  survivalgames.chat_send_all_lobby(plobby, name.." died so.")
			  survivalgames.chat_send_all_lobby(plobby, "There are "..survivalgames.get_player_count(plobby).." players left!")
        subgames.add_mithud(player, "You are now spectating!", 0xFF0000, 3)
        subgames.drop_inv(player, pos)
        survivalgames.win(plobby)
      end
		else player:setpos(survivalgames.lobbys[plobby].pos)
		end
	end
end)
