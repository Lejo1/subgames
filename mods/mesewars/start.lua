
local start = {}
function mesewars.may_start_game(lobby)
  local playercount = #mesewars.get_lobby_players(lobby)
  if playercount >=2 and not start[lobby] and lobby ~= 0 and mesewars.teams_correct(lobby) then
    start[lobby] = true
    mesewars.chat_send_all_lobby(lobby, "Game starts in 30 seconds!")
    for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
      subgames.add_bothud(player, "Game starts in 30 seconds!", 0xFFAE19, 2)
    end
    minetest.after(20, function()
      mesewars.chat_send_all_lobby(lobby, "Game starts in 10 seconds!")
      for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
        subgames.add_bothud(player, "Game starts in 10 seconds!", 0xFFAE19, 2)
      end
      minetest.after(5, function()
        mesewars.chat_send_all_lobby(lobby, "Game starts in 5 seconds!")
        for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
          subgames.add_bothud(player, "Game starts in 5 seconds!", 0xFFAE19, 2)
        end
        minetest.after(5, function()
          playercount = #mesewars.get_lobby_players(lobby)
          if playercount >= 2 and mesewars.teams_correct(lobby) then
            local msg = core.colorize("red", "Game Start now!")
            mesewars.chat_send_all_lobby(lobby, msg)
            for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
              subgames.add_mithud(player, "Game starts now!", 0xFF0000, 2)
            end
            mesewars.start_game(lobby)
          else start[lobby] = false
            mesewars.chat_send_all_lobby(lobby, "Game start stoped, becouse there are not enough players.")
          end
        end)
      end)
    end)
  end
end

function mesewars.reset_map(lobby)
  for pos, node in pairs(mesewars.lobbys[lobby].mapblocks) do
    minetest.set_node(minetest.string_to_pos(pos), node)
  end
  worldedit.clear_objects(mesewars.lobbys[lobby].mappos1, mesewars.lobbys[lobby].mappos2)
  mesewars.lobbys[lobby].mapblocks = {}
end

function mesewars.start_game(lobby)
  minetest.log("warning", "mesewars: Starting Game of the lobby "..lobby)
  if lobby == 0 then
    return
  end
  mesewars.lobbys[lobby].ingame = true
  for k, v in pairs(mesewars.lobbys[lobby].mesepos) do
    mesewars.lobbys[lobby].meses[k] = true
    minetest.set_node(v, {name="mesewars:mese"..k})
  end
  for _, player in pairs(mesewars.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    local team = mesewars.lobbys[lobby].players[name]
    if not team then
      mesewars.give_random_team(player)
      team = mesewars.lobbys[lobby].players[name]
    end
    subgames.clear_inv(player)
    mesewars.color_tag(player)
    mesewars.give_kit_items(name)
    player:set_pos(mesewars.lobbys[lobby].pos[team])
    sfinv.set_page(player, "3d_armor:armor")
    mesewars.set_maxteam(lobby)
  end
  local starttime = os.time()
  mesewars.lobbys[lobby].starttime = starttime
  minetest.after(1200, function() --  Time when game times out 60*20
    if starttime == mesewars.lobbys[lobby].starttime and mesewars.lobbys[lobby].ingame then
      -- Game timed out (was longer then 20min)
      local msg = minetest.colorize("red", "Restarting Game (Game timed out!)")
      mesewars.chat_send_all_lobby(lobby, msg)
      for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
        mesewars.leave_game(player)
        mesewars.join_game(player, lobby)
      end
      mesewars.win(lobby)
    end
  end)
end

function mesewars.get_team_count(lobby)
  local team = 0
  local lastteam
  local teams = {}
  local restplayers = {}
  if lobby ~= 0 then
    for name, role in pairs(mesewars.lobbys[lobby].players) do
      if role and not teams[role] then
        teams[role] = true
        lastteam = role
        team=team+1
        restplayers[name] = true
      end
    end
  end
  return team, lastteam, restplayers
end

function mesewars.win(lobby)
  if lobby and lobby ~= 0 and mesewars.lobbys[lobby].ingame then
    local count, winner, restplayers = mesewars.get_team_count(lobby)
    if count <= 1 then
      if count > 0 then
        mesewars.chat_send_all_lobby(lobby, minetest.colorize(mesewars.get_color_from_team(winner), "Team "..mesewars.get_color_from_team(winner)).." has won!")
        minetest.log("warning", "mesewars: "..minetest.colorize(mesewars.get_color_from_team(winner), mesewars.get_color_from_team(winner)).." won the Game of the lobby "..lobby)
        for name,_ in pairs(restplayers) do
          money.set_money(name, money.get_money(name)+25)
          minetest.chat_send_player(winner, "[CoinSystem] You have receive 25 Coins!")
        end
        mesewars.chat_send_all_lobby(lobby, "Server Restarts in 5 sec.")
        for _,player in ipairs(mesewars.get_lobby_players(lobby)) do
          subgames.add_mithud(player, "Team "..mesewars.get_color_from_team(winner).." has won!", mesewars.get_hex_from_team(winner), 3)
        end
      end
      minetest.after(5, function()
        for _, player in pairs(mesewars.get_lobby_players(lobby)) do
          local name = player:get_player_name()
          player:set_pos(mesewars.lobbys[lobby].specpos)
          subgames.clear_inv(player)
          subgames.unspectate(player)
          mesewars.lobbys[lobby].players[name] = false
          mesewars.color_tag(player)
          sfinv.set_page(player, "subgames:team")
        end
        mesewars.reset_map(lobby)
        mesewars.win(lobby)
      end)
      mesewars.lobbys[lobby].ingame = false
      start[lobby] = false
    end
  else mesewars.may_start_game(lobby)
  end
end
