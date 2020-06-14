--  Add a function to check if value is not nil
function table.is_not_nil(value)
  if value then
    return value
  else return ""
  end
end

--  Add a function to get the players of a team
function mesewars.get_team_players(lobby, team)
  local players = {}
  if not lobby or lobby == 0 then
    return {}
  end
  for name, pteam in pairs(mesewars.lobbys[lobby].players) do
    if pteam == team then
      table.insert(players, name)
    end
  end
  return players
end

-- Add a function to open the formspec.
function mesewars.create_team_form(name)
  local lobby = mesewars.player_lobby[name]
  local hight = {}
  local playerlist = ""
  for name, team in pairs(mesewars.lobbys[lobby].players) do
    if not hight[team] then
      hight[team] = 0
    else hight[team] = hight[team] + 0.5
    end
    if team then
      playerlist = playerlist.."label["..(team-1)*(2)..","..2.5+hight[team]..";"..name.."]"
    end
  end
  return (
    "size["..mesewars.lobbys[lobby].teams*(2.5)..","..mesewars.lobbys[lobby].playercount/mesewars.lobbys[lobby].teams.."]" ..
    "label[0,0;Select your team for the next Round! You see the joined players below the buttons.]" ..
    "button[8,0;2,1;refresh;Refresh]" ..
    "button[0,1;2,1;1;Blue]" ..
    "button[2,1;2,1;2;Yellow]" ..
    "button[4,1;2,1;3;Green]" ..
    "button[6,1;2,1;4;Red]" ..
    "button[8,1;2,1;leave;Leave]" ..
    playerlist
  )
end
function mesewars.team_form(name)
  minetest.show_formspec(name, "mesewars:team", mesewars.create_team_form(name))
end

--  Add the team selector.
minetest.register_tool("mesewars:team", {
  description = "Chose Team",
  inventory_image = "default_paper.png",
on_use = function(itemstack, user)
  local name = user:get_player_name()
  mesewars.team_form(name)
  end
})

--  Add a command to join a team
subgames.register_chatcommand("team", {
  prams = "",
  description = "Use it to get a team selector",
  lobby = "mesewars",
  func = function(name)
    mesewars.team_form(name)
  end,
})

function mesewars.give_random_team(player)
  local name = player:get_player_name()
  local lobby = mesewars.player_lobby[name]
  local ltable = mesewars.lobbys[lobby]
  local lobbyplayers = #mesewars.get_lobby_players(lobby)
  local team = math.random(ltable.teams)
  local teamplayers = #mesewars.get_team_players(lobby, team) + 1
  while teamplayers > ltable.playercount/ltable.teams or teamplayers >= lobbyplayers do
    team = math.random(ltable.teams)
    teamplayers = #mesewars.get_team_players(lobby, team) + 1
  end
  mesewars.lobbys[lobby].players[name] = team
  local teamcolour = mesewars.get_color_from_team(team)
  local msg = core.colorize("teamcolour", "You are now in Team "..teamcolour)
  minetest.chat_send_player(name, msg)
  subgames.add_bothud(player, "You are now in Team "..teamcolour, mesewars.get_hex_from_team(team), 2)
end

function mesewars.handle_teamform_input(player, pressed)
  local name = player:get_player_name()
  local lobby = mesewars.player_lobby[name]
  local ltable = mesewars.lobbys[lobby]
  if lobby and ltable and ltable.ingame then
    minetest.chat_send_player(name, "You can't switch your team while the lobby is ingame!")
    return
  end
  if pressed.quit then
    return
  end
  for field, input in pairs(pressed) do
    if field == "leave" then
      mesewars.lobbys[lobby].players[name] = false
      minetest.chat_send_player(name, "You have left your team!")
      subgames.add_bothud(player, "You have left your team!", 0xFFFFFF, 2)
    elseif tonumber(field) then
      local team = tonumber(field)
      if #mesewars.get_team_players(lobby, team) < ltable.playercount/ltable.teams then
        mesewars.lobbys[lobby].players[name] = team
        local teamcolour = mesewars.get_color_from_team(team)
        local msg = core.colorize("teamcolour", "You are now in Team "..teamcolour)
        minetest.chat_send_player(name, msg)
        subgames.add_bothud(player, "You are now in Team "..teamcolour, mesewars.get_hex_from_team(team), 2)
      else minetest.chat_send_player(name, "The Team is full!")
      end
    end
    mesewars.win(lobby)
    mesewars.color_tag(player)
  end
end

--  Add a sfinv page for the team selector
sfinv.register_page("mesewars:team", {
	title = "Teams",
	get = function(self, player, context)
		local name = player:get_player_name()
    if player_lobby[name] == "mesewars" then
		  return sfinv.make_formspec(player, context, mesewars.create_team_form(name), false)
    end
	end,
  on_player_receive_fields = function(self, player, context, pressed)
    local name = player:get_player_name()
    mesewars.handle_teamform_input(player, pressed)
		if not pressed.quit then
			mesewars.create_team_form(name)
			sfinv.set_player_inventory_formspec(player)
		end
  end,
	is_in_nav = function(self, player, context)
		local name = player:get_player_name()
    if player_lobby[name] == "mesewars" then
			return true
		end
	end
})

function mesewars.teams_correct(lobby)
  local maxteam = 1
  for team=0, mesewars.lobbys[lobby].teams do
    local players = #mesewars.get_team_players(lobby, team)
    if players > maxteam then
      maxteam = players
    end
  end
  return maxteam < #mesewars.get_lobby_players(lobby)
end

function mesewars.set_maxteam(lobby)
  local maxteam = 1
  for team=0, mesewars.lobbys[lobby].teams do
    local players = #mesewars.get_team_players(lobby, team)
    if players > maxteam then
      maxteam = players
    end
  end
  mesewars.lobbys[lobby].maxteam = maxteam
end

minetest.register_on_player_receive_fields(function(player, formname, pressed)
	if formname == "mesewars:team" then
    local name = player:get_player_name()
    mesewars.handle_teamform_input(player, pressed)
    if not pressed.quit then
      mesewars.team_form(name)
      sfinv.set_player_inventory_formspec(player)
    end
  end
end)
