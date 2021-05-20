hiddenseeker.disguis = {}

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
		for lobby, ltable in pairs(hiddenseeker.lobbys) do
			if ltable.ingame and lobby ~= 0 then
				if ltable.hidding then
					ltable.hiddingtime = ltable.hiddingtime -1
					if ltable.hiddingtime <= 0 then
						hiddenseeker.seek(lobby)
						ltable.hidding = false
					else for _,player in pairs(hiddenseeker.get_lobby_players(lobby)) do subgames.add_bothud(player, "Hidding time ends in "..SecondsToClock(ltable.hiddingtime), 0x0000FF, 1.1) end
					end
				else ltable.timetowin = ltable.timetowin -1
					if ltable.timetowin <= 0 then
						hiddenseeker.win(lobby)
					else for _,player in pairs(hiddenseeker.get_lobby_players(lobby)) do subgames.add_bothud(player, "Time until Hidders win "..SecondsToClock(ltable.timetowin), 0x0000FF, 1.1) end
            if ltable.timetowin == 60 or ltable.timetowin == 120 or ltable.timetowin == 180 or ltable.timetowin == 240 or ltable.timetowin == 300 then
              for _,player in pairs(hiddenseeker.get_lobby_players(lobby)) do
                local name = player:get_player_name()
                if ltable.players[name] ~= "seeker" then
                  money.set_money(name, money.get_money(name)+5)
                  minetest.chat_send_player(name, "[CoinSystem] You have receive 5 Coins for playing!")
                end
              end
            end
          end
				end
				for _,player in pairs(hiddenseeker.get_lobby_players(lobby)) do
					local name = player:get_player_name()
          player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
					if ltable.players[name] ~= "seeker" then
						local nowpos = minetest.pos_to_string(player:get_pos())
						if nowpos == hiddenseeker.disguis[name].pos then
							if hiddenseeker.disguis[name].time > 0 then
								hiddenseeker.disguis[name].time = hiddenseeker.disguis[name].time -1
							end
							if hiddenseeker.disguis[name].time <= 0 and not hiddenseeker.disguis[name].enable then
								hiddenseeker.disguis_player(player)
							end
						else hiddenseeker.disguis[name].time = hiddenseeker.timetodisquis
							if hiddenseeker.disguis[name].enable then
								hiddenseeker.disguis_player(player)
							end
						end
						hiddenseeker.disguis[name].pos = minetest.pos_to_string(player:get_pos())
					end
				end
			end
		end
	end
end)

function hiddenseeker.disguis_player(player)
	local name = player:get_player_name()
	if not hiddenseeker.disguis[name].enable then
		if minetest.get_node(player:get_pos()).name == "air" then
			hiddenseeker.disguis[name].enable = true
			subgames.disappear(player)
			minetest.set_node(minetest.string_to_pos(hiddenseeker.disguis[name].pos), {name=hiddenseeker.lobbys[hiddenseeker.player_lobby[name]].players[name]})
			minetest.chat_send_player(name, "You disquised to a block, don't move!")
		else minetest.chat_send_player(name, "You can't disguis in a other block.")
		end
	elseif hiddenseeker.disguis[name].enable == true then
		hiddenseeker.disguis[name].enable = nil
		subgames.undisappear(player)
		minetest.remove_node(minetest.string_to_pos(hiddenseeker.disguis[name].pos))
		player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
		minetest.chat_send_player(name, "You moved or get punched so you are not a block anymore.")
	end
end

subgames.register_on_punchnode(function(bpos, node, puncher, pointed_thing, lobby)
	if lobby == "hiddenseeker" then
		local name = puncher:get_player_name()
		local plobby = hiddenseeker.player_lobby[name]
		if plobby and plooby ~= 0 and hiddenseeker.lobbys[plobby].players[name] == "seeker" then
			for pname, table in pairs(hiddenseeker.disguis) do
				if table.pos then
					if vector.equals(bpos, vector.round(minetest.string_to_pos(hiddenseeker.disguis[pname].pos))) then
						local player = minetest.get_player_by_name(pname)
						hiddenseeker.disguis[pname].time = hiddenseeker.timetodisquis
						hiddenseeker.disguis_player(player)
					end
				end
			end
		end
	end
end)

subgames.register_on_respawnplayer(function(player, lobby)
	if lobby == "hiddenseeker" then
		local name = player:get_player_name()
		local plobby = hiddenseeker.player_lobby[name]
		if plobby ~= 0 and hiddenseeker.lobbys[plobby].ingame then
			hiddenseeker.lobbys[plobby].players[name] = "seeker"
			hiddenseeker.chat_send_all_lobby(plobby, name.." died so they are now on the seeker team.")
			hiddenseeker.chat_send_all_lobby(plobby, "There are "..hiddenseeker.get_hidder_count(plobby).." hidders left!")
			if hiddenseeker.lobbys[plobby].hidding then
				player:set_pos(hiddenseeker.lobbys[plobby].seekerpos)
			else player:set_pos(hiddenseeker.lobbys[plobby].pos)
				subgames.clear_inv(player)
				subgames.add_armor(player, ItemStack("3d_armor:helmet_cactus"), ItemStack("3d_armor:chestplate_cactus"), ItemStack("3d_armor:leggings_cactus"), ItemStack("3d_armor:boots_cactus"))
	      player:get_inventory():add_item("main", "default:sword_steel")
			end
			hiddenseeker.win(plobby)
			player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
		else player:set_pos(hiddenseeker.lobbys[plobby].pos)
		end
	end
end)
