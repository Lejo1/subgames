--  Add a to get to dide and seek
minetest.register_chatcommand("ttt", {
  params = "",
  description = "Use it to get to Trouble in Terrorist Town!",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    subgames.change_lobby(player, "ttt")
  end,
})

--  Add a leave command to leave the Game.
subgames.register_chatcommand("leave", {
  params = "",
  description = "Use it to leave the Game!",
  lobby = "ttt",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    if player then
      local lobby = ttt.player_lobby[user]
      ttt.leave_game(player)
      ttt.win(lobby)
      ttt.join_game(player, lobby)
      minetest.chat_send_player(user, "You have left the Game!")
    end

  end,
})

--  Add a command to let others leave.
subgames.register_chatcommand("letleave", {
	privs = {ban=true},
	params = "<name>",
	description = "Use it ...",
  lobby = "ttt",
	func = function(name, param)
    local player = minetest.get_player_by_name(param)
		if player then
      local lobby = ttt.player_lobby[param]
      ttt.leave_game(player)
      ttt.win(lobby)
      ttt.join_game(player, lobby)
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
  lobby = "ttt",
  func = function(name)
    local msg = core.colorize("red", "Restarting Game (by " .. name .. ")")
    ttt.chat_send_all_lobby(ttt.player_lobby[name], msg)
    local lobby = ttt.player_lobby[name]
    for _,player in ipairs(ttt.get_lobby_players(lobby)) do
      ttt.leave_game(player)
      ttt.join_game(player, lobby)
    end
    ttt.win(lobby)
  end,
})

subgames.register_chatcommand("reset", {
  params = "",
  description = "Use it to reset the full Map!",
  privs = {ban = true},
  lobby = "ttt",
  func = function(player)
    minetest.chat_send_all("Creating Trouble in Terrorist Town map, may lag.")
    minetest.after(1, function()
      local param1 = ttt.lobbys[ttt.player_lobby[player]].schem
      local schemp = ttt.lobbys[ttt.player_lobby[player]].schempos
      local schem = minetest.get_worldpath() .. "/schems/" .. param1 .. ".mts"
      minetest.place_schematic(schemp, schem)
    end)
  end,
})
