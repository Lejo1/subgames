-- mods/adblock/init.lua
-- =================
-- See README.txt for licensing and other information.

local lastpos = {}
local adusers = {}
local timer = 0

local function show_hud(player)
	local input = {
      hud_elem_type = "text",
      position = {x=0.8,y=0.1},
      scale = {x=100,y=50},
      text = "YOU PLAY AN UNOFFICIAL GAME\nOn this server is only the official game allowed: Minetest\nMINETEST is FREE & has NO INGAME ADS",
      number = 0xFF0000,
      alignment = {x=0,y=1},
      offset = {x=0, y=-32}}
  player:hud_add(input)
end

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 1 then
		timer = 0
		for _,player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			local pos = player:getpos()
			if not adusers[name] and lastpos[name] and (player:get_player_control().up or player:get_player_control().down or player:get_player_control().right or player:get_player_control().left) and vector.equals(lastpos[name], pos) and ((default and default.player_attached and not default.player_attached[name]) or (player_api and player_api.player_attached and not player_api.player_attached[name])) then
				adusers[name] = true
				show_hud(player)
			end
			lastpos[name] = pos
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
		adusers[player:get_player_name()] = nil
end)
