--[[  This is the Control mod of Mesewars.
  Mesewars is a Game like Eggwars or Bedwars.
  Game created by Lejo
  Some of the Code is too in the mod item_drop!
  And the main control in subgames

Team1 is team blue
Team2 is team yellow
Team3 is team green
Team4 is team red
]]
mesewars = {}
root_restart = false
map_must_create = true

--  Loading lua files.
if minetest.setting_get("server") == "true" then
  dofile(minetest.get_modpath("mesewars") .."/join.lua")
  dofile(minetest.get_modpath("mesewars") .."/map.lua")
  dofile(minetest.get_modpath("mesewars") .."/register.lua")
  dofile(minetest.get_modpath("mesewars") .."/teams.lua")
  dofile(minetest.get_modpath("mesewars") .."/mese.lua")
  dofile(minetest.get_modpath("mesewars") .."/color.lua")
  dofile(minetest.get_modpath("mesewars") .."/spawner.lua")
  dofile(minetest.get_modpath("mesewars") .."/kits.lua")
end
dofile(minetest.get_modpath("mesewars") .."/shop.lua")

--  Check drop
function areas.mesewars.drop(pos, name, player)
  if name == "default:sandstone" or name == "default:obsidian" or name == "default:glass" or name == "default:steelblock" or name == "default:chest" then
    return true
  end
end

subgames.register_on_drop(function(itemstack, dropper, pos, lobby)
  if lobby == "mesewars" then
    return false
  end
end)

--  Add a to get to mesewars
minetest.register_chatcommand("mesewars", {
  params = "",
  description = "Use it to get to mesewars!",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    subgames.change_lobby(player, "mesewars")
  end,
})

--  Add a Fix Command
subgames.register_chatcommand("fix", {
  params = "",
  description = "Use it if the Game engine is buggy!",
  privs = {shout = true},
  lobby = "mesewars",
  func = function(player)
    mesewars.fix()
    minetest.chat_send_player(player, "Tried to fix bugs!")
  end,
})

subgames.register_chatcommand("reset", {
  params = "",
  description = "Use it to reset the full Map!",
  privs = {ban = true},
  lobby = "mesewars",
  func = function(player)
    minetest.chat_send_all("Creating mesewars map may lag!")
    minetest.after(1, function()
      local param1 = "submese"
      local schem = minetest.get_worldpath() .. "/schems/" .. param1 .. ".mts"
      local vm = minetest.get_voxel_manip()
      vm:read_from_map(minetest.setting_get_pos("mappos1"), minetest.setting_get_pos("mappos2"))
      minetest.place_schematic_on_vmanip(vm, schemp, schem)
      vm:write_to_map()
    end)
  end,
})

--  Add a root command to stop game starting.
subgames.register_chatcommand("stop", {
  params = "",
  description = "Use it to stop the Game start!",
  privs = {ban = true},
  lobby = "mesewars",
  func = function(player)
    starts = true
    local msg = core.colorize("red", "Game Start Stoped!")
    subgames.chat_send_all_lobby("mesewars", msg)
  end,
})

--  Add a command to start the engine.
subgames.register_chatcommand("start", {
  params = "",
  description = "Use it to start the Game start! be carefull!",
  privs = {ban = true},
  lobby = "mesewars",
  func = function(player)
    starts = false
    local msg = core.colorize("red", "Game Start Started!")
    subgames.chat_send_all_lobby("mesewars", msg)
    mesewars.win()
  end,
})

--  Add a root start command
subgames.register_chatcommand("restart", {
  params = "",
  description = "Admin command to restart the Game maualy!",
  privs = {kick = true},
  lobby = "mesewars",
  func = function(name)
    root_restart = true
    for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
      local spawn = minetest.setting_get_pos("spawn_lobby")
      player:setpos(spawn)
      subgames.clear_inv(player)
      mesewars.leave_player(player)
      subgames.spectate(player)
      local inv = player:get_inventory()
      inv:add_item('main', 'mesewars:team')
    end
    local msg = core.colorize("red", "Restarting Game (by " .. name .. ")")
    subgames.chat_send_all_lobby("mesewars", msg)
    root_restart = false
    mesewars.win()
  end,
})

--  Add a leave command to leave the Game.
subgames.register_chatcommand("leave", {
  params = "",
  description = "Use it to leave the Game!",
  lobby = "mesewars",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    mesewars.leave_pre_player(user)
    mesewars.to_lobby(player)
    minetest.chat_send_player(user, "You have left the Game!")
  end,
})

--  Add a command to let others leave.
subgames.register_chatcommand("letleave", {
	privs = {ban=true},
	params = "<name>",
	description = "Use it ...",
  lobby = "mesewars",
	func = function(name, param)
    local player = minetest.get_player_by_name(param)
		if player then
      mesewars.to_lobby(player)
      mesewars.leave_pre_player(param)
      minetest.chat_send_player(name, "You have left the player "..param)
    else minetest.chat_send_player(name, "The player is not online!")
    end
	end,
})

--  Add a fix globalstep
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 60 then
		mesewars.fix()
    timer = 0
	end
end)
