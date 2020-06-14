
local start = {}

local function start_countdown(lobby, time)
  if not start[lobby] then
    return -- Nothing to do, invalid call
  end

  local playercount = #hiddenseeker.get_lobby_players(lobby)
  if playercount < 2 then
    -- Abort: Too few players
    start[lobby] = false
    hiddenseeker.chat_send_all_lobby(lobby,
      "Start sequence stopped: Not enough players.")
    return
  end

  if time < 5 then
    -- Start now
    local msg = "Hide & Seek game starts now!"
    hiddenseeker.chat_send_all_lobby(lobby,
      core.colorize("red", msg))
    for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
      subgames.add_mithud(player, msg, 0xFF0000, 2)
    end
    hiddenseeker.start_game(lobby)
    return
  end

  local msg = ("Game starts in %i seconds!"):format(time)
  hiddenseeker.chat_send_all_lobby(lobby, msg)
  for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
    subgames.add_bothud(player, msg, 0xFFAE19, 2)
  end
  if time >= 5 then
    -- Pseudo-recursive callbacks
    minetest.after(5, start_countdown, lobby, time - 5)
  end
end

function hiddenseeker.may_start_game(lobby)
  local playercount = #hiddenseeker.get_lobby_players(lobby)
  if playercount >= 2 and not start[lobby] and lobby ~= 0 then
    -- Require three players to start; one left over to stop
    start[lobby] = true
    hiddenseeker.chat_send_all_lobby(0, "The game " ..
      hiddenseeker.lobbys[lobby].string_name .. " is about to start soon!")
    start_countdown(lobby, 15)
  end
end

function hiddenseeker.start_game(lobby)
  minetest.log("warning", "Hiddenseeker: Starting Game of the lobby "..lobby)
  local players = hiddenseeker.get_lobby_players(lobby)
  local playercount = #players
  local seekercount
  if lobby == 0 then
    return
  end
  local ldata = hiddenseeker.lobbys[lobby]
  ldata.ingame = true
  if playercount <= 5 then
    seekercount = 1
  else seekercount = 2
  end
  while seekercount > 0 do
    local player = hiddenseeker.get_lobby_players(lobby)[math.random(#hiddenseeker.get_lobby_players(lobby))]
    local name = player:get_player_name()
    if ldata.players[name] ~= "seeker" then
      seekercount = seekercount -1
      ldata.players[name] = "seeker"
      minetest.chat_send_player(name, "You are a seeker, wait until the hidding time ends.")
      subgames.add_mithud(player, "You are seeker!", 0xFF0000, 3)
      hiddenseeker.chat_send_all_lobby(lobby, name.." is seeker.")
      player:set_pos(ldata.seekerpos)
    end
  end
  for name in pairs(ldata.players) do
    local player = minetest.get_player_by_name(name)
    if player then
      player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
      subgames.clear_inv(player)
      if ldata.players[name] ~= "seeker" then
        ldata.players[name] = hiddenseeker.get_player_block(name)
        minetest.chat_send_player(name, "You are a hidder, hide quickly.")
        subgames.add_mithud(player, "You are a hidder!", 0xFF0000, 3)
        player:set_pos(ldata.pos)
        local inv = player:get_inventory()
        inv:add_item("main", ldata.players[name])
        inv:add_item("main", "hiddenseeker:rotate")
      end
    end
  end
  ldata.hidding = true
  ldata.hiddingtime = hiddenseeker.hiddingtime
end

function hiddenseeker.seek(lobby)
  local ldata = hiddenseeker.lobbys[lobby]
  ldata.timetowin = hiddenseeker.timetowin
  for _, player in pairs(hiddenseeker.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    local inv = player:get_inventory()
    if ldata.players[name] == "seeker" then
      player:set_pos(ldata.pos)
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
  local ldata = hiddenseeker.lobbys[lobby]
  if lobby ~= 0 then
    for name, role in pairs(ldata.players) do
      if role ~= "seeker" and role ~= true then
        hidder = hidder+1
      end
    end
  end
  return hidder
end

function hiddenseeker.get_seeker_count(lobby)
  local seeker = 0
  local ldata = hiddenseeker.lobbys[lobby]
  if lobby ~= 0 then
    for name, role in pairs(ldata.players) do
      if role == "seeker" then
        seeker = seeker+1
      end
    end
  end
  return seeker
end

local function party_win_announce(party, lobby, ldata)
  minetest.log("warning", "Hiddenseeker: "..party.." won the Game of the lobby "..lobby)
  hiddenseeker.chat_send_all_lobby(lobby, party .. " has won! Restart in 5 seconds.")
  for _, player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
    player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
    subgames.add_mithud(player, party .. " has won!", 0xFF0000, 3)
    if party ~= "Seekers" then
      local name = player:get_player_name()
      if ldata.players[name] ~= "seeker" and hiddenseeker.get_hidder_count(lobby) + hiddenseeker.get_seeker_count(lobby) > 1 then
        money.set_money(name, money.get_money(name) + 30)
        minetest.chat_send_player(name, "[CoinSystem] You received 30 coins for winning!")
      end
    end
  end
  minetest.after(5, function()
    for _, player in pairs(hiddenseeker.get_lobby_players(lobby)) do
      subgames.clear_inv(player)
      ldata.players[player:get_player_name()] = true
      player:set_pos(ldata.pos)
      sfinv.set_page(player, "hiddenseeker:kits")
    end
    hiddenseeker.win(lobby)
  end)
  ldata.ingame = false
  ldata.hiddingtime = 0
  ldata.timetowin = 0
  ldata.hidding = false
  start[lobby] = false
end

function hiddenseeker.win(lobby)
  local ldata = hiddenseeker.lobbys[lobby]
  if lobby == 0 or not ldata.ingame then
    hiddenseeker.may_start_game(lobby)
    return
  end

  local hidder = hiddenseeker.get_hidder_count(lobby)
  local seeker = hiddenseeker.get_seeker_count(lobby)
  if hidder == 0 then
    party_win_announce("Seekers", lobby, ldata)
  elseif seeker == 0 and hidder >= 2 then
    hiddenseeker.chat_send_all_lobby(lobby, "There are no seekers left over. Choosing a hidder to become a seeker...")
    local player = hiddenseeker.get_lobby_players(lobby)[math.random(#hiddenseeker.get_lobby_players(lobby))]
    local name = player:get_player_name()
    local inv = player:get_inventory()
    if hiddenseeker.disguis[name].enable then
      hiddenseeker.disguis_player(player)
    end
    ldata.players[name] = "seeker"
    subgames.add_armor(player, ItemStack("3d_armor:helmet_cactus"), ItemStack("3d_armor:chestplate_cactus"), ItemStack("3d_armor:leggings_cactus"), ItemStack("3d_armor:boots_cactus"))
    inv:add_item("main", "default:sword_steel")
    if ldata.hidding then
      player:set_pos(ldata.seekerpos)
    else
	player:set_pos(ldata.pos)
    end
    minetest.chat_send_player(name, "You have been chosen as the new seeker!")
    subgames.add_mithud(player, "You have been chosen as the new seeker!", 0x0000FF, 5)
    hiddenseeker.chat_send_all_lobby(lobby, name.." has been chosen as the new seeker!")
  elseif ldata.timetowin <= 0 and not ldata.hidding or hidder + seeker <= 1 then
    party_win_announce("Hidders", lobby, ldata)
  end
end
