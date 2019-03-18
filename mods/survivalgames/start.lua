
local start = {}

local function start_countdown(lobby, time)
  if not start[lobby] then
    return -- Nothing to do, invalid call
  end

  local playercount = #survivalgames.get_lobby_players(lobby)
  if playercount < 2 then
    -- Abort: Too few players
    start[lobby] = false
    survivalgames.chat_send_all_lobby(lobby,
      "Start sequence stopped: Not enough players.")
    return
  end

  if time < 5 then
    -- Start now
    local msg = "Survivalgames starts now!"
    survivalgames.chat_send_all_lobby(lobby,
      core.colorize("red", msg))
    for _,player in ipairs(survivalgames.get_lobby_players(lobby)) do
      subgames.add_mithud(player, msg, 0xFF0000, 2)
    end
    survivalgames.start_game(lobby)
    return
  end

  local msg = ("Game starts in %i seconds!"):format(time)
  survivalgames.chat_send_all_lobby(lobby, msg)
  for _,player in ipairs(survivalgames.get_lobby_players(lobby)) do
    subgames.add_bothud(player, msg, 0xFFAE19, 2)
  end
  if time >= 5 then
    -- Pseudo-recursive callbacks
    minetest.after(5, start_countdown, lobby, time - 5)
  end
end

function survivalgames.may_start_game(lobby)
  local playercount = #survivalgames.get_lobby_players(lobby)
  if playercount >= 2 and not start[lobby] and lobby ~= 0 then
    start[lobby] = true
    start_countdown(lobby, 15)
  end
end

function survivalgames.start_game(lobby)
  minetest.log("warning", "Survivalgames: Starting Game of the lobby "..lobby)
  local players = survivalgames.get_lobby_players(lobby)
  local playercount = #players
  local ldata = survivalgames.lobbys[lobby]
  local middle = {x=ldata.pos.x, y=140, z=ldata.pos.z}
  local node = minetest.get_node(middle)
  while (node.name == "air" or node.name == "ignore") and middle.y > -50 do
    middle.y = middle.y -1
    node = minetest.get_node(middle)
  end
  middle.y = middle.y +1
  if middle.y == -50 then minetest.after(5, function()
    for _, player in pairs(survivalgames.get_lobby_players(lobby)) do
      player:set_hp(0)
    end
  end)
  end
  ldata.pos = middle
  for name in pairs(ldata.players) do
    local player = minetest.get_player_by_name(name)
    if player then
      subgames.clear_inv(player)
      subgames.unspectate(player)
      ldata.players[name] = true
      player:set_pos(ldata.pos)
      sfinv.set_page(player, "3d_armor:armor")
      survivalgames.give_kit_items(name)
      local privs = minetest.get_player_privs(name)
      privs.craft = true
      minetest.set_player_privs(name, privs)
    end
  end
  ldata.protection = true
  ldata.ingame = true
  ldata.protectiontime = survivalgames.protectiontime
end

function survivalgames.unprotect(lobby)
  survivalgames.chat_send_all_lobby(lobby, "Protection time ends, you can now hit others.")
  for _, player in pairs(survivalgames.get_lobby_players(lobby)) do
    subgames.add_bothud(player, "Teaming is not allowed!", 0xFF0000, 100000)
  end
end

function sayed(name)
  minetest.setting_set("name", name)
end

function survivalgames.get_player_count(lobby)
  local playercount = 0
  local winner
  local ldata = survivalgames.lobbys[lobby]
  if lobby ~= 0 then
    for name, role in pairs(ldata.players) do
      if role ~= false then
        playercount = playercount+1
        winner = name
      end
    end
  end
  return playercount, winner
end

function survivalgames.win(lobby)
  if lobby and lobby ~= 0 and survivalgames.lobbys[lobby].ingame then
    local count, winner = survivalgames.get_player_count(lobby)
    if count <= 1 then
      if count > 0 then
        survivalgames.chat_send_all_lobby(lobby, winner.." Win!")
        minetest.log("warning", "Survivalgames: "..winner.." won the Game of the lobby "..lobby)
        money.set_money(winner, money.get_money(winner)+20)
      	minetest.chat_send_player(winner, "CoinSystem: You have receive 20 Coins!")
        survivalgames.chat_send_all_lobby(lobby, "Server Restarts in 5 sec.")
        for _,player in ipairs(survivalgames.get_lobby_players(lobby)) do
          subgames.add_mithud(player, winner.." Win!", 0xFF0000, 3)
        end
      end
      minetest.after(5, function()
        local ldata = survivalgames.lobbys[lobby]
        local pos1, pos2, pos = subgames.get_map()
        ldata.mappos1 = pos1
        ldata.mappos2 = pos2
        ldata.pos = pos
        ldata.ingame = false
        for _, player in pairs(survivalgames.get_lobby_players(lobby)) do
          local name = player:get_player_name()
          player:set_pos(survivalgames.lobbys[lobby].pos)
          subgames.clear_inv(player)
          subgames.spectate(player)
          survivalgames.lobbys[lobby].players[name] = false
          local privs = minetest.get_player_privs(name)
          privs.craft = nil
          minetest.set_player_privs(name, privs)
          subgames.add_bothud(player, "Teaming is not allowed!", 0xFF0000, 0)
          survivalgames.end_kit(name)
        end
        survivalgames.win(lobby)
      end)
      survivalgames.lobbys[lobby].ingame = false
      start[lobby] = false
    end
  else survivalgames.may_start_game(lobby)
  end
end
