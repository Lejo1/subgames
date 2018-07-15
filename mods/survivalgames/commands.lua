--  Add a to get to dide and seek
minetest.register_chatcommand("survivalgames", {
  params = "!",
  description = "Use it to get to Survivalgames!",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    subgames.change_lobby(player, "survivalgames")
  end,
})

--  Add a leave command to leave the Game.
subgames.register_chatcommand("leave", {
  params = "",
  description = "Use it to leave the Game!",
  lobby = "survivalgames",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    if player then
      survivalgames.leave_game(player)
      survivalgames.win(survivalgames.player_lobby[user])
      survivalgames.join_game(player, survivalgames.player_lobby[user])
      minetest.chat_send_player(user, "You have left the Game!")
    end
  end,
})

--  Add a command to let others leave.
subgames.register_chatcommand("letleave", {
	privs = {kick=true},
	params = "<name>",
	description = "Use it ...",
  lobby = "survivalgames",
	func = function(name, param)
    local player = minetest.get_player_by_name(param)
		if player and player_lobby[param] == "survivalgames" then
      survivalgames.leave_game(player)
      survivalgames.win(survivalgames.player_lobby[param])
      survivalgames.join_game(player, survivalgames.player_lobby[param])
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
  lobby = "survivalgames",
  func = function(name)
    local msg = core.colorize("red", "Restarting Game (by " .. name .. ")")
    local lobby = survivalgames.player_lobby[name]
    survivalgames.chat_send_all_lobby(lobby, msg)
    for _,player in ipairs(survivalgames.get_lobby_players(lobby)) do
      survivalgames.leave_game(player)
      survivalgames.join_game(player, lobby)
    end
    survivalgames.win(lobby)
  end,
})
