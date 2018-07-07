
local start = {}
function hiddenseeker.may_start_game(lobby)
  local playercount = #hiddenseeker.get_lobby_players(lobby)
  if playercount >=2 and not start[lobby] and lobby ~= 0 then
    start[lobby] = true
    hiddenseeker.chat_send_all_lobby(0, "The Game "..hiddenseeker.lobbys[lobby].string_name.." is now starting.")
    hiddenseeker.chat_send_all_lobby(lobby, "Game starts in 15 seconds!")
    for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
      subgames.add_bothud(player, "Game starts in 15 seconds!", 0xFFAE19, 2)
    end
    minetest.after(5, function()
      hiddenseeker.chat_send_all_lobby(lobby, "Game starts in 10 seconds!")
      for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
        subgames.add_bothud(player, "Game starts in 10 seconds!", 0xFFAE19, 2)
      end
      minetest.after(5, function()
        hiddenseeker.chat_send_all_lobby(lobby, "Game starts in 5 seconds!")
        for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
          subgames.add_bothud(player, "Game starts in 5 seconds!", 0xFFAE19, 2)
        end
        minetest.after(5, function()
          playercount = #hiddenseeker.get_lobby_players(lobby)
          if playercount >= 2 then
            local msg = core.colorize("red", "Game Start now!")
            hiddenseeker.chat_send_all_lobby(lobby, msg)
            for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
              subgames.add_mithud(player, "Game starts now!", 0xFF0000, 2)
            end
            hiddenseeker.start_game(lobby)
          else start[lobby] = false
            hiddenseeker.chat_send_all_lobby(lobby, "Game start stoped, becouse there are not enough players.")
          end
        end)
      end)
    end)
  end
end

function hiddenseeker.start_game(lobby)
  local players = hiddenseeker.get_lobby_players(lobby)
  local playercount = #players
  local seekercount
  if lobby == 0 then
    return
  end
  hiddenseeker.lobbys[lobby].ingame = true
  if playercount <= 5 then
    seekercount = 1
  else seekercount = 2
  end
  while seekercount > 0 do
    local player = hiddenseeker.get_lobby_players(lobby)[math.random(#hiddenseeker.get_lobby_players(lobby))]
    local name = player:get_player_name()
    if hiddenseeker.lobbys[lobby].players[name] ~= "seeker" then
      seekercount = seekercount -1
      hiddenseeker.lobbys[lobby].players[name] = "seeker"
      minetest.chat_send_player(name, "You are a seeker, wait until the hidding time ends.")
      subgames.add_mithud(player, "You are seeker!", 0xFF0000, 3)
      hiddenseeker.chat_send_all_lobby(lobby, name.." is Seeker.")
      player:setpos(hiddenseeker.lobbys[lobby].seekerpos)
    end
  end
  for name in pairs(hiddenseeker.lobbys[lobby].players) do
    local player = minetest.get_player_by_name(name)
    player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
    subgames.clear_inv(player)
    if hiddenseeker.lobbys[lobby].players[name] ~= "seeker" then
      hiddenseeker.lobbys[lobby].players[name] = hiddenseeker.get_player_block(name)
      minetest.chat_send_player(name, "You are a hidder, hide quickly.")
      subgames.add_mithud(player, "You are hidder!", 0xFF0000, 3)
      player:setpos(hiddenseeker.lobbys[lobby].pos)
      local inv = player:get_inventory()
      inv:add_item("main", hiddenseeker.lobbys[lobby].players[name])
      inv:add_item("main", "hiddenseeker:rotate")
    end
  end
  hiddenseeker.lobbys[lobby].hidding = true
  hiddenseeker.lobbys[lobby].hiddingtime = hiddenseeker.hiddingtime
end

function hiddenseeker.seek(lobby)
  hiddenseeker.lobbys[lobby].timetowin = hiddenseeker.timetowin
  for _, player in pairs(hiddenseeker.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    local inv = player:get_inventory()
    if hiddenseeker.lobbys[lobby].players[name] == "seeker" then
      player:setpos(hiddenseeker.lobbys[lobby].pos)
      subgames.add_armor(player, ItemStack("3d_armor:helmet_cactus"), ItemStack("3d_armor:chestplate_cactus"), ItemStack("3d_armor:leggings_cactus"), ItemStack("3d_armor:boots_cactus"))
      inv:add_item("main", "default:sword_steel")
      minetest.after(5, function()
        player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
      end)
    else inv:add_item("main", "bow:bow")
      inv:add_item("main", "bow:arrow 99")
    end
  end
  hiddenseeker.chat_send_all_lobby(lobby, "Seeking time starts make sure you are hidden.")
end

function hiddenseeker.get_hidder_count(lobby)
  local hidder = 0
  if lobby ~= 0 then
    for name, role in pairs(hiddenseeker.lobbys[lobby].players) do
      if role ~= "seeker" and role ~= true then
        hidder = hidder+1
      end
    end
  end
  return hidder
end

function hiddenseeker.get_seeker_count(lobby)
  local seeker = 0
  if lobby ~= 0 then
    for name, role in pairs(hiddenseeker.lobbys[lobby].players) do
      if role == "seeker" then
        seeker = seeker+1
      end
    end
  end
  return seeker
end

function hiddenseeker.win(lobby)
  if lobby ~= 0 and hiddenseeker.lobbys[lobby].ingame then
  local hidder = hiddenseeker.get_hidder_count(lobby)
  local seeker = hiddenseeker.get_seeker_count(lobby)
  if hidder == 0 then
    hiddenseeker.chat_send_all_lobby(lobby, "Seekers Win!")
    hiddenseeker.chat_send_all_lobby(lobby, "Server Restarts in 5 sec.")
    for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
      player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
      subgames.add_mithud(player, "Seekers Win!", 0xFF0000, 3)
    end
    minetest.after(5, function()
      for _, player in pairs(hiddenseeker.get_lobby_players(lobby)) do
        subgames.clear_inv(player)
        hiddenseeker.lobbys[lobby].players[player:get_player_name()] = true
        player:setpos(hiddenseeker.lobbys[lobby].pos)
        sfinv.set_page(player, "subgames:kits")
      end
      hiddenseeker.win(lobby)
    end)
    hiddenseeker.lobbys[lobby].ingame = false
    hiddenseeker.lobbys[lobby].hiddingtime = 0
    hiddenseeker.lobbys[lobby].timetowin = 0
    hiddenseeker.lobbys[lobby].hidding = false
    start[lobby] = false
  elseif seeker == 0 and hidder >= 2 then
    hiddenseeker.chat_send_all_lobby(lobby, "The seeker(s) left the Game so one hidder have to be chosen as a seeker.")
    local player = hiddenseeker.get_lobby_players(lobby)[math.random(#hiddenseeker.get_lobby_players(lobby))]
    local name = player:get_player_name()
    local inv = player:get_inventory()
    if hiddenseeker.disguis[name].enable then
      hiddenseeker.disguis_player(player)
    end
    hiddenseeker.lobbys[lobby].players[name] = "seeker"
    subgames.add_armor(player, ItemStack("3d_armor:helmet_cactus"), ItemStack("3d_armor:chestplate_cactus"), ItemStack("3d_armor:leggings_cactus"), ItemStack("3d_armor:boots_cactus"))
    inv:add_item("main", "default:sword_steel")
    if hiddenseeker.lobbys[lobby].hidding then
      player:setpos(hiddenseeker.lobbys[lobby].seekerpos)
    else player:setpos(hiddenseeker.lobbys[lobby].pos)
    end
    minetest.chat_send_player(name, "You have been chosen as the new seeker!")
    subgames.add_mithud(player, "You have been chosen as the new seeker!", 0x0000FF, 5)
    hiddenseeker.chat_send_all_lobby(lobby, name.." has been chosen as the new seeker!")
  elseif hiddenseeker.lobbys[lobby].timetowin <= 0 and not hiddenseeker.lobbys[lobby].hidding or hidder + seeker <= 1 then
    hiddenseeker.chat_send_all_lobby(lobby, "Hidders win!")
    for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
      local name = player:get_player_name()
      if hiddenseeker.lobbys[lobby].players[name] ~= "seeker" and hidder + seeker > 1 then
        money.set_money(name, money.get_money(name)+30)
        minetest.chat_send_player(name, "CoinSystem: You have receive 30 Coins for Winning!")
      end
      player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
      subgames.add_mithud(player, "Hidders Win!", 0xFF0000, 3)
    end
    minetest.after(5, function()
      for _, player in pairs(hiddenseeker.get_lobby_players(lobby)) do
        subgames.clear_inv(player)
        hiddenseeker.lobbys[lobby].players[player:get_player_name()] = true
        player:setpos(hiddenseeker.lobbys[lobby].pos)
        sfinv.set_page(player, "subgames:kits")
      end
      hiddenseeker.win(lobby)
    end)
    hiddenseeker.lobbys[lobby].ingame = false
    hiddenseeker.lobbys[lobby].hiddingtime = 0
    hiddenseeker.lobbys[lobby].timetowin = 0
    hiddenseeker.lobbys[lobby].hidding = false
    start[lobby] = false
  end
  else hiddenseeker.may_start_game(lobby)
  end
end
