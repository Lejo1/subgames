--  Add a to get to Skywats
minetest.register_chatcommand("mesewars", {
  params = "",
  description = "Use it to get to mesewars!",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    subgames.change_lobby(player, "mesewars")
  end,
})

--  Add a leave command to leave the Game.
subgames.register_chatcommand("leave", {
  params = "",
  description = "Use it to leave the Game!",
  lobby = "mesewars",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    if player then
      local lobby = mesewars.player_lobby[user]
      mesewars.leave_game(player)
      mesewars.win(lobby)
      mesewars.join_game(player, lobby)
      minetest.chat_send_player(user, "You have left the Game!")
    end
  end,
})

--  Add a command to let others leave.
subgames.register_chatcommand("letleave", {
	privs = {kick=true},
	params = "<name>",
	description = "Use it ...",
  lobby = "mesewars",
	func = function(name, param)
    local player = minetest.get_player_by_name(param)
		if player and player_lobby[param] == "mesewars" then
      local lobby = mesewars.player_lobby[param]
      mesewars.leave_game(player)
      mesewars.win(lobby)
      mesewars.join_game(player, lobby)
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
  lobby = "mesewars",
  func = function(name)
    local msg = core.colorize("red", "Restarting Game (by " .. name .. ")")
    local lobby = mesewars.player_lobby[name]
    mesewars.chat_send_all_lobby(lobby, msg)
    for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
      mesewars.leave_game(player)
      mesewars.join_game(player, lobby)
    end
    mesewars.win(lobby)
  end,
})
