--  Add a to get to dide and seek
minetest.register_chatcommand("hide", {
  params = " and seek!",
  description = "Use it to get to Hide and Seek!",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    subgames.change_lobby(player, "hiddenseeker")
  end,
})

--  Add a leave command to leave the Game.
subgames.register_chatcommand("leave", {
  params = "",
  description = "Use it to leave the Game!",
  lobby = "hiddenseeker",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    if player then
      hiddenseeker.leave_game(player)
      hiddenseeker.win(hiddenseeker.player_lobby[user])
      hiddenseeker.join_game(player, hiddenseeker.player_lobby[user])
      minetest.chat_send_player(user, "You have left the Game!")
    end

  end,
})

--  Add a command to let others leave.
subgames.register_chatcommand("letleave", {
	privs = {kick=true},
	params = "<name>",
	description = "Use it ...",
  lobby = "hiddenseeker",
	func = function(name, param)
    local player = minetest.get_player_by_name(param)
		if player and player_lobby[param] == "hiddenseeker" then
      hiddenseeker.leave_game(player)
      hiddenseeker.win(hiddenseeker.player_lobby[param])
      hiddenseeker.join_game(player, hiddenseeker.player_lobby[param])
      minetest.chat_send_player(name, "You have left the player "..param)
    else minetest.chat_send_player(name, "The player is not online!")
    end
	end,
})

--  Add a root start command
subgames.register_chatcommand("restart", {
  params = "",
  description = "Admin command to restart the Game maualy!",
  privs = {kick = true},
  lobby = "hiddenseeker",
  func = function(name)
    local msg = core.colorize("red", "Restarting Game (by " .. name .. ")")
    local lobby = hiddenseeker.player_lobby[name]
    hiddenseeker.chat_send_all_lobby(lobby, msg)
    for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
      hiddenseeker.leave_game(player)
      hiddenseeker.join_game(player, lobby)
    end
    hiddenseeker.win(lobby)
  end,
})

subgames.register_chatcommand("reset", {
  params = "",
  description = "Use it to reset the full Map!",
  privs = {ban = true},
  lobby = "hiddenseeker",
  func = function(player)
    minetest.chat_send_all("Creating hide and seek map, may lag.")
    minetest.after(1, function()
      local param1 = hiddenseeker.lobbys[hiddenseeker.player_lobby[player]].schem
      local schemp = hiddenseeker.lobbys[hiddenseeker.player_lobby[player]].schempos
      local schem = minetest.get_worldpath() .. "/schems/" .. param1 .. ".mts"
      minetest.place_schematic(schemp, schem)
    end)
  end,
})

function hiddenseeker.rotate_block(player)
  local name = player:get_player_name()
  if hiddenseeker.disguis[name] and hiddenseeker.disguis[name].enable then
    local pos = minetest.string_to_pos(hiddenseeker.disguis[name].pos)
    local node = minetest.get_node(pos)
    node.param2 = (node.param2 + 1) % 4
    minetest.swap_node(pos, node)
    minetest.chat_send_player(name, "Rotated your block!")
  else minetest.chat_send_player(name, "You are not disguised!")
  end
end

minetest.register_tool("hiddenseeker:rotate", {
  description = "Block Rotater",
	inventory_image = "rotate.png",
	on_use = function(itemstack, user, pointed_thing)
    hiddenseeker.rotate_block(user)
  end,
  on_secondary_use = function(itemstack, user, pointed_thing)
    hiddenseeker.rotate_block(user)
  end,
})
