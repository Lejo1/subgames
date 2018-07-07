playtime = {}

function playtime.get_current_playtime(name)
  local currenttime = minetest.get_player_information(name).connection_uptime
  if playtime then
    return currenttime
  else return 0
  end
end

--  Load files
local input = io.open(minetest.get_worldpath() .. "/playtime", "r")
if input then
	playtime.total = minetest.deserialize(input:read("*l"))
	io.close(input)
end

--  Function to save times
function playtime.save_times()
	local output = io.open(minetest.get_worldpath() .. "/playtime", "w")
	output:write(minetest.serialize(playtime.total))
	io.close(output)
end

if not playtime.total then
  playtime.total = {}
  playtime.save_times()
end

--  Create player account if there is no.
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
  if not playtime.total[name] then
    playtime.total[name] = 0
    playtime.save_times()
  end
end)

--  Function to get playtime
function playtime.get_total_playtime(name)
  local totaltime = playtime.total[name]
  if totaltime then
    return totaltime
  else return 0
  end
end

--  Update playtime every second
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 1 then
    for _,player in ipairs(minetest.get_connected_players()) do
      local name = player:get_player_name()
      playtime.total[name] = playtime.total[name] + 1
    end
    playtime.save_times()
		timer = 0
	end
end)
