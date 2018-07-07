
local start = {}
function ttt.may_start_game(lobby)
  local playercount = #ttt.get_lobby_players(lobby)
  if playercount >=4 and not start[lobby] then
    start[lobby] = true
    ttt.chat_send_all_lobby(0, "The Game "..ttt.lobbys[lobby].string_name.." is now starting.")
    ttt.chat_send_all_lobby(lobby, "Game starts in 15 seconds!")
    for _,player in ipairs(ttt.get_lobby_players(lobby)) do
      subgames.add_bothud(player, "Game starts in 15 seconds!", 0xFFAE19, 2)
    end
    minetest.after(5, function()
      ttt.chat_send_all_lobby(lobby, "Game starts in 10 seconds!")
      for _,player in ipairs(ttt.get_lobby_players(lobby)) do
        subgames.add_bothud(player, "Game starts in 10 seconds!", 0xFFAE19, 2)
      end
      minetest.after(5, function()
        ttt.chat_send_all_lobby(lobby, "Game starts in 5 seconds!")
        for _,player in ipairs(ttt.get_lobby_players(lobby)) do
          subgames.add_bothud(player, "Game starts in 5 seconds!", 0xFFAE19, 2)
        end
        minetest.after(5, function()
          playercount = #ttt.get_lobby_players(lobby)
          if playercount >= 4 then
            local msg = core.colorize("red", "Game Start now!")
            ttt.chat_send_all_lobby(lobby, msg)
            for _,player in ipairs(ttt.get_lobby_players(lobby)) do
              subgames.add_mithud(player, "Game starts now!", 0xFF0000, 2)
            end
            ttt.start_game(lobby)
          else start[lobby] = false
            ttt.chat_send_all_lobby(lobby, "Game start stoped, becouse there are not enough players.")
          end
        end)
      end)
    end)
  end
end

function ttt.start_game(lobby)
  local players = ttt.get_lobby_players(lobby)
  local playercount = #players
  local traitorcount = math.min(4, round(playercount/5))
  local detectivecount = math.min(3, round(playercount/6))
  local inocount = playercount - traitorcount - detectivecount
  ttt.lobbys[lobby].ingame = true
  while traitorcount > 0 do
    local player = ttt.get_lobby_players(lobby)[math.random(#ttt.get_lobby_players(lobby))]
    local name = player:get_player_name()
    if ttt.lobbys[lobby].players[name] == true then
      traitorcount = traitorcount -1
      ttt.lobbys[lobby].players[name] = "traitor"
      minetest.chat_send_player(name, "You are a Traitor, after the preparing ends, try to kill all Innocents.")
      subgames.add_mithud(player, "You are Traitor!", 0xFF0000, 3)
      player:setpos(ttt.lobbys[lobby].pos)
    end
  end
  while detectivecount > 0 do
    local player = ttt.get_lobby_players(lobby)[math.random(#ttt.get_lobby_players(lobby))]
    local name = player:get_player_name()
    if ttt.lobbys[lobby].players[name] == true then
      seekercount = seekercount -1
      ttt.lobbys[lobby].players[name] = "Detective"
      minetest.chat_send_player(name, "You are a Detective, after the preparing ends, try to kill all Traitors.")
      subgames.add_mithud(player, "You are Detective!", 0xFF0000, 3)
      player:setpos(ttt.lobbys[lobby].pos)
    end
  end
  for name in pairs(ttt.lobbys[lobby].players) do
    local player = minetest.get_player_by_name(name)
    player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
    subgames.clear_inv(player)
    if ttt.lobbys[lobby].players[name] == true then
      ttt.lobbys[lobby].players[name] = "ino"
      minetest.chat_send_player(name, "You are a Innocent, after the preparing ends, try to not get killed.")
      subgames.add_mithud(player, "You are Innocent!", 0xFF0000, 3)
      player:setpos(ttt.lobbys[lobby].pos)
    end
  end
  ttt.lobbys[lobby].preparing = true
  ttt.lobbys[lobby].preparingtime = ttt.preparingtime
end

function ttt.fight(lobby)
  ttt.lobbys[lobby].timetowin = ttt.timetowin
  for _, player in pairs(ttt.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    local inv = player:get_inventory()
    if ttt.lobbys[lobby].players[name] == "seeker" then
      player:setpos(ttt.lobbys[lobby].pos)
      subgames.add_armor(player, ItemStack("3d_armor:helmet_cactus"), ItemStack("3d_armor:chestplate_cactus"), ItemStack("3d_armor:leggings_cactus"), ItemStack("3d_armor:boots_cactus"))
      inv:add_item("main", "default:sword_steel")
      minetest.after(5, function()
        player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
      end)
    else inv:add_item("main", "bow:bow")
      inv:add_item("main", "bow:arrow 99")
    end
  end
  ttt.chat_send_all_lobby(lobby, "Seeking time starts make sure you are hidden.")
end

function ttt.get_ino_count(lobby)
  local ino = 0
  if lobby ~= 0 then
    for name, role in pairs(ttt.lobbys[lobby].players) do
      if role ~= "traitor" and role ~= false then
        ino = ino+1
      end
    end
  end
  return ino
end

function ttt.get_traitor_count(lobby)
  local traitor = 0
  if lobby ~= 0 then
    for name, role in pairs(ttt.lobbys[lobby].players) do
      if role == "traitor" then
        traitor = traitor+1
      end
    end
  end
  return traitor
end

function ttt.win(lobby)
  if lobby ~= 0 and ttt.lobbys[lobby].ingame then
  local hidder = ttt.get_hidder_count(lobby)
  local seeker = ttt.get_seeker_count(lobby)
  if hidder == 0 then
    ttt.chat_send_all_lobby(lobby, "Seekers Win!")
    ttt.chat_send_all_lobby(lobby, "Server Restarts in 5 sec.")
    for _,player in ipairs(ttt.get_lobby_players(lobby)) do
      player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
      subgames.add_mithud(player, "Seekers Win!", 0xFF0000, 3)
    end
    minetest.after(5, function()
      for _, player in pairs(ttt.get_lobby_players(lobby)) do
        subgames.clear_inv(player)
        ttt.lobbys[lobby].players[player:get_player_name()] = true
        player:setpos(ttt.lobbys[lobby].pos)
        sfinv.set_page(player, "3d_armor:armor")
      end
      ttt.win(lobby)
    end)
    ttt.lobbys[lobby].ingame = false
    ttt.lobbys[lobby].hiddingtime = 0
    ttt.lobbys[lobby].timetowin = 0
    ttt.lobbys[lobby].hidding = false
    start[lobby] = false
  elseif seeker == 0 and hidder >= 2 then
    ttt.chat_send_all_lobby(lobby, "The seeker(s) left the Game so one hidder have to be chosen as a seeker.")
    local player = ttt.get_lobby_players(lobby)[math.random(#ttt.get_lobby_players(lobby))]
    local name = player:get_player_name()
    local inv = player:get_inventory()
    if ttt.disguis[name].enable then
      ttt.disguis_player(player)
    end
    ttt.lobbys[lobby].players[name] = "seeker"
    subgames.add_armor(player, ItemStack("3d_armor:helmet_cactus"), ItemStack("3d_armor:chestplate_cactus"), ItemStack("3d_armor:leggings_cactus"), ItemStack("3d_armor:boots_cactus"))
    inv:add_item("main", "default:sword_steel")
    if ttt.lobbys[lobby].hidding then
      player:setpos(ttt.lobbys[lobby].seekerpos)
    else player:setpos(ttt.lobbys[lobby].pos)
    end
    minetest.chat_send_player(name, "You have been chosen as the new seeker!")
    subgames.add_mithud(player, "You have been chosen as the new seeker!", 0x0000FF, 5)
    ttt.chat_send_all_lobby(lobby, name.." has been chosen as the new seeker!")
  elseif ttt.lobbys[lobby].timetowin <= 0 and not ttt.lobbys[lobby].hidding or hidder + seeker <= 1 then
    ttt.chat_send_all_lobby(lobby, "Hidders win!")
    for _,player in ipairs(ttt.get_lobby_players(lobby)) do
      local name = player:get_player_name()
      if ttt.lobbys[lobby].players[name] ~= "seeker" and hidder + seeker > 1 then
        money.set_money(name, money.get_money(name)+30)
        minetest.chat_send_player(name, "CoinSystem: You have receive 30 Coins for Winning!")
      end
      player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
      subgames.add_mithud(player, "Hidders Win!", 0xFF0000, 3)
    end
    minetest.after(5, function()
      for _, player in pairs(ttt.get_lobby_players(lobby)) do
        subgames.clear_inv(player)
        ttt.lobbys[lobby].players[player:get_player_name()] = true
        player:setpos(ttt.lobbys[lobby].pos)
        sfinv.set_page(player, "3d_armor:armor")
      end
      ttt.win(lobby)
    end)
    ttt.lobbys[lobby].ingame = false
    ttt.lobbys[lobby].hiddingtime = 0
    ttt.lobbys[lobby].timetowin = 0
    ttt.lobbys[lobby].hidding = false
    start[lobby] = false
  end
  else ttt.may_start_game(lobby)
  end
end
