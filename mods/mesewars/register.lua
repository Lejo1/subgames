--  Add player registers and almost the rest ;)

-- Team players
team1_players = {}
team2_players = {}
team3_players = {}
team4_players = {}

--  Players in lobby loggin in a team.
pre1_players = {}
pre2_players = {}
pre3_players = {}
pre4_players = {}

--  Mese there or not.
mese = {}

--  Max players
player_max = 4 -- Moment max 4!

--  Import mese positions out of minetest.conf
mese1 = minetest.setting_get_pos("mese1")
mese2 = minetest.setting_get_pos("mese2")
mese3 = minetest.setting_get_pos("mese3")
mese4 = minetest.setting_get_pos("mese4")

--  Import the Base from minetest.conf
local base1 = minetest.setting_get_pos("base1")
local base2 = minetest.setting_get_pos("base2")
local base3 = minetest.setting_get_pos("base3")
local base4 = minetest.setting_get_pos("base4")

--  Import Schem pos out of minetest.conf
schemp = minetest.setting_get_pos("schem_pos")

--  Import mappositions out of minetest.conf
local mappos1 = minetest.setting_get_pos("mappos1")
local mappos2 = minetest.setting_get_pos("mappos2")
local lobbypos1 = minetest.setting_get_pos("lobbypos1")
local lobbypos2 = minetest.setting_get_pos("lobbypos2")

--  Spawner aktiv or not.
spawner = false

--  Spawner fast
spawnfast = 1 --  Nerver set 0 becouse divident by 0 error

--  Does a game Starts momently
starts = false

--  The Time wich a Game is max Loading
max_time = 1800

--  Add a time counter
time_left = nil

--  Add a function to get the team of the player
function mesewars.get_team(name)
  if table.contains(team1_players, name) == true then
    return "team1"
  elseif table.contains(team2_players, name) == true then
    return "team2"
  elseif table.contains(team3_players, name) == true then
    return "team3"
  elseif table.contains(team4_players, name) == true then
    return "team4"
  end
end

function mesewars.get_team_base(name)
  local team = mesewars.get_team(name)
  if team == "team1" then
    return base1
  elseif team == "team2" then
    return base2
  elseif team == "team3" then
    return base3
  elseif team == "team4" then
    return base4
  else local spawn = minetest.setting_get_pos("spawn_lobby")
    return spawn
  end
end

--  Add a function to leave a player out the Pre Team.
function mesewars.leave_pre_player(name) --  As name
  for teamnumb1, teamer1 in pairs(pre1_players) do
    if teamer1 == name then
      table.remove(pre1_players, teamnumb1)
    end
  end
  for teamnumb2, teamer2 in pairs(pre2_players) do
    if teamer2 == name then
      table.remove(pre2_players, teamnumb2)
    end
  end
  for teamnumb3, teamer3 in pairs(pre3_players) do
    if teamer3 == name then
      table.remove(pre3_players, teamnumb3)
    end
  end
  for teamnumb4, teamer4 in pairs(pre4_players) do
    if teamer4 == name then
      table.remove(pre4_players, teamnumb4)
    end
  end
end

--  Add a function to leave a player out of a Game.
function mesewars.leave_player(player)  --  As ObjectRef
  local name = player:get_player_name()
  for rteamnumb1, rteamer1 in pairs(team1_players) do
    if rteamer1 == name then
      table.remove(team1_players, rteamnumb1)
    end
  end
  for rteamnumb2, rteamer2 in pairs(team2_players) do
    if rteamer2 == name then
      table.remove(team2_players, rteamnumb2)
    end
  end
  for rteamnumb3, rteamer3 in pairs(team3_players) do
    if rteamer3 == name then
      table.remove(team3_players, rteamnumb3)
    end
  end
  for rteamnumb4, rteamer4 in pairs(team4_players) do
    if rteamer4 == name then
      table.remove(team4_players, rteamnumb4)
    end
  end
  mesewars.color_tag(player)
end

--  Add a function to send a player to the lobby
function mesewars.to_lobby(player)
  local spawn = minetest.setting_get_pos("spawn_lobby")
  player:setpos(spawn)
  subgames.clear_inv(player)
  mesewars.leave_player(player)
  subgames.spectate(player)
  mesewars.win()
  local inv = player:get_inventory()
  inv:add_item('main', 'mesewars:team')
end

--  Add the pre players to the team players and start the game.
function mesewars.start_game()
  for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
    local name = player:get_player_name()
    sfinv.set_page(player, "3d_armor:armor")
    if table.contains(pre1_players, name) ~= true and table.contains(pre2_players, name) ~= true and table.contains(pre3_players, name) ~= true and table.contains(pre4_players, name) ~= true then
      if #pre1_players < player_max and #pre1_players <= #pre2_players then
        pre1_players[#pre1_players+1] = name
        local msg = core.colorize("blue", "You are now in Team Blue")
        minetest.chat_send_player(name, msg)
        subgames.add_bothud(player, "You are now in Team Blue", 0x0000FF, 2)
      elseif #pre2_players < player_max then
        pre2_players[#pre2_players+1] = name
        local msg = core.colorize("yellow", "You are now in Team Yellow")
        minetest.chat_send_player(name, msg)
        subgames.add_bothud(player, "You are now in Team Yellow", 0xFFFF00, 2)
      elseif #pre3_players < player_max then
        pre3_players[#pre3_players+1] = name
        local msg = core.colorize("green", "You are now in Team Green")
        minetest.chat_send_player(name, msg)
        subgames.add_bothud(player, "You are now in Team Green", 0x00FF00, 2)
      elseif #pre4_players < player_max then
        pre4_players[#pre4_players+1] = name
        local msg = core.colorize("red", "You are now in Team Red")
        minetest.chat_send_player(name, msg)
        subgames.add_bothud(player, "You are now in Team Red", 0xFF0000, 2)
      end
    end
  end
  local maxplayers = 1
  for _,nodepos in pairs(mapblocks) do
    minetest.remove_node(minetest.string_to_pos(nodepos))
  end
  mapblocks = {}
  minetest.clear_objects({mode="quick"})
  team1_players = pre1_players
  team2_players = pre2_players
  team3_players = pre3_players
  team4_players = pre4_players
  pre1_players = {}
  pre2_players = {}
  pre3_players = {}
  pre4_players = {}
  time_left = max_time
  if #team1_players > 0 then
    mese[1] = true
    minetest.set_node(mese1, {name="mesewars:mese1"})
    for _, teamers in pairs(team1_players) do
      local name = minetest.get_player_by_name(teamers)
      if name then
        name:setpos(base1)
        subgames.clear_inv(name)
        subgames.unspectate(name)
        mesewars.color_tag(name)
        name:set_hp(20)
        mesewars.give_kit_items(teamers)
      end
    end
  end
  if #team2_players > 0 then
    mese[2] = true
    minetest.set_node(mese2, {name="mesewars:mese2"})
    for _, teamers in pairs(team2_players) do
      local name = minetest.get_player_by_name(teamers)
      if name then
        name:setpos(base2)
        subgames.clear_inv(name)
        subgames.unspectate(name)
        mesewars.color_tag(name)
        name:set_hp(20)
        mesewars.give_kit_items(teamers)
      end
    end
  end
  if #team3_players > 0 then
    mese[3] = true
    minetest.set_node(mese3, {name="mesewars:mese3"})
    for _, teamers in pairs(team3_players) do
      local name = minetest.get_player_by_name(teamers)
      if name then
        name:setpos(base3)
        subgames.clear_inv(name)
        subgames.unspectate(name)
        mesewars.color_tag(name)
        name:set_hp(20)
        mesewars.give_kit_items(teamers)
      end
    end
  end
  if #team4_players > 0 then
    mese[4] = true
    minetest.set_node(mese4, {name="mesewars:mese4"})
    for _, teamers in pairs(team4_players) do
      local name = minetest.get_player_by_name(teamers)
      if name then
        name:setpos(base4)
        subgames.clear_inv(name)
        subgames.unspectate(name)
        mesewars.color_tag(name)
        name:set_hp(20)
        mesewars.give_kit_items(teamers)
      end
    end
  end
  if #team1_players > maxplayers then
    maxplayers = #team1_players
  end
  if #team2_players > maxplayers then
    maxplayers = #team2_players
  end
  if #team3_players > maxplayers then
    maxplayers = #team3_players
  end
  if #team4_players > maxplayers then
    maxplayers = #team4_players
  end
  spawner = true
  spawnfast = maxplayers
  starts = false
  minetest.after(30, function()
    mesewars.fix()
  end)
end

local time_timer = 0
minetest.register_globalstep(function(dtime)
	time_timer = time_timer + dtime;
	if time_timer >= 1 and time_left then
    if time_left ~= 0 then
      time_left = time_left-1
    elseif time_left then
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
      root_restart = false
      subgames.chat_send_all_lobby("mesewars", "The Game was to long so it has been closed.")
      mesewars.win()
    end
		time_timer = 0
	end
end)

--  Only make damage at enemies.
subgames.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, lobby)
  if lobby == "mesewars" and player and hitter then
    if damage == 0 then
      return
    end
    local to = player:get_player_name()
    local from = hitter:get_player_name()
    local toteam = mesewars.get_team(to)
    local fromteam = mesewars.get_team(from)
    if fromteam == toteam then
      player:set_hp(player:get_hp()+damage)
    else mesewars.handle_hit(player, hitter, time_from_last_punch)
    end
  end
end)

--  Check if the player can respawn in his team base.
subgames.register_on_respawnplayer(function(player, lobby)
  if lobby == "mesewars" then
  local name = player:get_player_name()
  local inv = player:get_inventory()
  if table.contains(team1_players, name) == true then
    if mese[1] == true then
      player:setpos(base1)
    else mesewars.leave_player(player)
      local msg = core.colorize("blue", name)
      subgames.chat_send_all_lobby("mesewars", msg.." has been eliminated")
      subgames.add_mithud(player, "You are now spectating!", 0xFFFFFF, 2)
      subgames.spectate(player)
      sfinv.set_page(player, "subgames:team")
      inv:add_item('main', 'mesewars:team')
      local spawn = minetest.setting_get_pos("spawn_lobby")
      player:setpos(spawn)
    end
  elseif table.contains(team2_players, name) == true then
    if mese[2] == true then
      player:setpos(base2)
    else mesewars.leave_player(player)
      local msg = core.colorize("yellow", name)
      subgames.chat_send_all_lobby("mesewars", msg.." has been eliminated")
      subgames.add_mithud(player, "You are now spectating!", 0xFFFFFF, 2)
      subgames.spectate(player)
      sfinv.set_page(player, "subgames:team")
      inv:add_item('main', 'mesewars:team')
      local spawn = minetest.setting_get_pos("spawn_lobby")
      player:setpos(spawn)
    end
  elseif table.contains(team3_players, name) == true then
    if mese[3] == true then
      player:setpos(base3)
    else mesewars.leave_player(player)
      local msg = core.colorize("green", name)
      subgames.chat_send_all_lobby("mesewars", msg.." has been eliminated")
      subgames.add_mithud(player, "You are now spectating!", 0xFFFFFF, 2)
      subgames.spectate(player)
      sfinv.set_page(player, "subgames:team")
      inv:add_item('main', 'mesewars:team')
      local spawn = minetest.setting_get_pos("spawn_lobby")
      player:setpos(spawn)
    end
  elseif table.contains(team4_players, name) == true then
    if mese[4] == true then
      player:setpos(base4)
    else mesewars.leave_player(player)
      local msg = core.colorize("red", name)
      subgames.chat_send_all_lobby("mesewars", msg.." has been eliminated")
      subgames.add_mithud(player, "You are now spectating!", 0xFFFFFF, 2)
      subgames.spectate(player)
      sfinv.set_page(player, "subgames:team")
      inv:add_item('main', 'mesewars:team')
      local spawn = minetest.setting_get_pos("spawn_lobby")
      player:setpos(spawn)
    end
  else inv:add_item('main', 'mesewars:team')
    local spawn = minetest.setting_get_pos("spawn_lobby")
    player:setpos(spawn)
    subgames.unspectate(player)
    subgames.spectate(player)
    sfinv.set_page(player, "subgames:team")
  end
  mesewars.win()
  end
end)

--  Check if there are enough players to start a Game.
local teamstart = false
function mesewars.may_start_game()
  local playercount = #subgames.get_lobby_players("mesewars")
  teamstart = false
  if #pre1_players < playercount and #pre1_players ~= 0 then
    teamstart = true
  elseif #pre2_players < playercount and #pre2_players ~= 0 then
    teamstart = true
  elseif #pre3_players < playercount and #pre3_players ~= 0 then
    teamstart = true
  elseif #pre4_players < playercount and #pre4_players ~= 0 then
    teamstart = true
  elseif #pre1_players + #pre2_players + #pre3_players + #pre4_players == 0 then
    teamstart = true
  end
  if playercount >=2 and starts == false and teamstart == true then
    starts = true
    subgames.chat_send_all_lobby("mesewars", "Game starts in 30 seconds!")
    minetest.chat_send_all("Mesewars is now starting use /mesewars to join it.")
    for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
      subgames.add_bothud(player, "Game starts in 30 seconds!", 0xFFAE19, 2)
    end
    minetest.after(20, function()
      subgames.chat_send_all_lobby("mesewars", "Game starts in 10 seconds!")
      for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
        subgames.add_bothud(player, "Game starts in 10 seconds!", 0xFFAE19, 2)
      end
      minetest.after(5, function()
        subgames.chat_send_all_lobby("mesewars", "Game starts in 5 seconds!")
        for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
          subgames.add_bothud(player, "Game starts in 5 seconds!", 0xFFAE19, 2)
        end
        minetest.after(5, function()
          local playercount = #subgames.get_lobby_players("mesewars")
          teamstart = false
          if #pre1_players < playercount and #pre1_players ~= 0 then
            teamstart = true
          elseif #pre2_players < playercount and #pre2_players ~= 0 then
            teamstart = true
          elseif #pre3_players < playercount and #pre3_players ~= 0 then
            teamstart = true
          elseif #pre4_players < playercount and #pre4_players ~= 0 then
            teamstart = true
          elseif #pre1_players + #pre2_players + #pre3_players + #pre4_players == 0 then
            teamstart = true
          end
          if playercount >=2 and teamstart == true then
            local msg = core.colorize("red", "Game Start now!")
            subgames.chat_send_all_lobby("mesewars", msg)
            for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
              subgames.add_mithud(player, "Game starts now!", 0xFF0000, 2)
            end
            mesewars.start_game()
          else starts = false
            subgames.chat_send_all_lobby("mesewars", "Game start stoped, becouse there are not enough players.")
          end
        end)
      end)
    end)
  end
  local playercount = 0
end

--  Check win and start game new.
local telestart = false
local rteam_count = 0
local win_team = {}
local win_player = ""
function mesewars.win()
  if #team1_players > 0 then
    rteam_count = rteam_count+1
    win_team = core.colorize("blue", "Team Blue")
    if win_player == "" then
      win_player = team1_players
    end
  end
  if #team2_players > 0 then
    rteam_count = rteam_count+1
    win_team = core.colorize("yellow", "Team Yellow")
    if win_player == "" then
      win_player = team2_players
    end
  end
  if #team3_players > 0 then
    rteam_count = rteam_count+1
    win_team = core.colorize("green", "Team Green")
    if win_player == "" then
      win_player = team3_players
    end
  end
  if #team4_players > 0 then
    rteam_count = rteam_count+1
    win_team = core.colorize("red", "Team Red")
    if win_player == "" then
      win_player = team4_players
    end
  end
  if rteam_count <=1 then
    spawner = false
      if rteam_count == 1 and root_restart == false then
        subgames.chat_send_all_lobby("mesewars", win_team .. " has won the Game!  Game will restart soon.")
        telestart = false
      end
      if starts == false then
        mesewars.may_start_game()
      end
      if telestart == false then
        telestart = true
        if win_player ~= "" then
          for _,name in ipairs(win_player) do
            money.set_money(name, money.get_money(name)+25)
            minetest.chat_send_player(name, "CoinSystem: You have receive 25 Coins!")
          end
        end
        team1_players = {}
        team2_players = {}
        team3_players = {}
        team4_players = {}
        for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
          local spawn = minetest.setting_get_pos("spawn_lobby")
          local name = player:get_player_name()
          player:setpos(spawn)
          subgames.clear_inv(player)
          mesewars.color_tag(player)
          subgames.spectate(player)
          local inv = player:get_inventory()
          inv:add_item('main', 'mesewars:team')
          if minetest.get_player_privs(name).shout then
            mesewars.team_form(name)
          end
        end
      end
      time_left = nil
  end
  win_player = ""
  win_team = {}
  rteam_count = 0
end

--  Add a fix function
function mesewars.fix()
  for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
     mesewars.color_tag(player)
  end
  for playernumb, playero in pairs(team1_players) do
    local player = minetest.get_player_by_name(playero)
    if player:is_player_connected() ~= true then
      table.remove(team1_players, playernumb)
      mesewars.win()
    end
  end
  for playernumb, playero in pairs(team2_players) do
    local player = minetest.get_player_by_name(playero)
    if player:is_player_connected() ~= true then
      table.remove(team2_players, playernumb)
      mesewars.win()
    end
  end
  for playernumb, playero in pairs(team3_players) do
    local player = minetest.get_player_by_name(playero)
    if player:is_player_connected() ~= true then
      table.remove(team3_players, playernumb)
      mesewars.win()
    end
  end
  for playernumb, playero in pairs(team4_players) do
    local player = minetest.get_player_by_name(playero)
    if player:is_player_connected() ~= true then
      table.remove(team4_players, playernumb)
      mesewars.win()
    end
  end
end
