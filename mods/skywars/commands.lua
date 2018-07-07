--  Add a to get to Skywats
minetest.register_chatcommand("skywars", {
  params = "",
  description = "Use it to get to Skywars!",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    subgames.change_lobby(player, "skywars")
  end,
})

--  Add a leave command to leave the Game.
subgames.register_chatcommand("leave", {
  params = "",
  description = "Use it to leave the Game!",
  lobby = "skywars",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    if player then
      local lobby = skywars.player_lobby[user]
      skywars.leave_game(player)
      skywars.win(lobby)
      skywars.join_game(player, lobby)
      minetest.chat_send_player(user, "You have left the Game!")
    end

  end,
})

--  Add a command to let others leave.
subgames.register_chatcommand("letleave", {
	privs = {ban=true},
	params = "<name>",
	description = "Use it ...",
  lobby = "skywars",
	func = function(name, param)
    local player = minetest.get_player_by_name(param)
		if player then
      local lobby = skywars.player_lobby[param]
      skywars.leave_game(player)
      skywars.win(lobby)
      skywars.join_game(player, lobby)
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
  lobby = "skywars",
  func = function(name)
    local msg = core.colorize("red", "Restarting Game (by " .. name .. ")")
    local lobby = skywars.player_lobby[name]
    skywars.chat_send_all_lobby(lobby, msg)
    for _,player in ipairs(skywars.get_lobby_players(lobby)) do
      skywars.leave_game(player)
      skywars.join_game(player, lobby)
    end
    skywars.win(lobby)
  end,
})
