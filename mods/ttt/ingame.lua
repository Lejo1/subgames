local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
    timer = 0
    for lobby, ltable in pairs(ttt.lobbys) do
			if ltable.ingame then
				if ltable.preparing then
					ltable.preparingtime = ltable.preparingtime -1
					if ltable.preparingtime <= 0 then
						ttt.fight(lobby)
						ltable.preparing = false
					else for _,player in pairs(ttt.get_lobby_players(lobby)) do subgames.add_bothud(player, "Hidding time ends in "..SecondsToClock(ltable.hiddingtime), 0x0000FF, 1) end
					end
				else ltable.timetowin = ltable.timetowin -1
					if ltable.timetowin <= 0 then
						ttt.win(lobby)
          else for _,player in pairs(ttt.get_lobby_players(lobby)) do subgames.add_bothud(player, "Time until Hidders win "..SecondsToClock(ltable.timetowin), 0x0000FF, 1) end
          end
        end
			end
		end
	end
end)

subgames.register_on_respawnplayer(function(player, lobby)
	if lobby == "ttt" then
		local name = player:get_player_name()
		local plobby = ttt.player_lobby[name]
		if ttt.lobbys[plobby].ingame then
			ttt.lobbys[plobby].players[name] = false
			subgames.spectate(player)
      subgames.add_mithud(player, "You died! You are now spectating!", 0xFF0000, 3)
			ttt.win(plobby)
		else player:setpos(ttt.lobbys[plobby].pos)
		end
	end
end)

minetest.register_entity("ttt:zombie", {
	physical = true,
	collisionbox = {-0.3,-1,-0.3, 0.3,1,0.3},
	visual_size = {x = 0, y = 0},
	visual = "mesh",
	mesh = "trans.png",
	stepheight = 0,
	on_punch = ttt.handle_check,
	on_rightclick = ttt.handle_check
})

function ttt.handle_check(self, player)
	local name = player:get_player_name()
	if ttt.lobbys[ttt.player_lobby[name]].players[name] == "detective" then
		ttt.spawn_partical(self:get_luaentity().pos, self:get_luaentity().rol)
	end
end

function ttt.spawn_partical(pos, type)
	minetest.add_particlespawner({
		amount = 30,
  	time = 1,
		minpos = pos,
  	maxpos = pos,
  	minvel = {x=-1, y=-1, z=-1},
  	maxvel = {x=1, y=1, z=1},
  	minacc = {x=-1, y=-1, z=-1},
		maxacc = {x=1, y=1, z=1},
		minexptime = 5,
		maxexptime = 5,
		minsize = 1,
		maxsize = 3,
		collisiondetection = false,
		vertical = false,
		texture = "ttt_"..type..".png",
  })
end

function ttt.spawn_zombie(player, killrol)
	local name = player:get_player_name()
	local pos = player:getpos()
	local ent = minetest.add_entity(pos, "ttt:zombie")
	ent:get_luaentity().pos = pos
	ent:get_luaentity().name = name
	ent:get_luaentity().rol = killrol
	ent:set_armor_groups({immortal=1})
end
