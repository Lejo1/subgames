--[[This is the controllmod of hiddenseeker]]

hiddenseeker = {}
dofile(minetest.get_modpath("hiddenseeker") .."/start.lua")
dofile(minetest.get_modpath("hiddenseeker") .."/kits.lua")
dofile(minetest.get_modpath("hiddenseeker") .."/ingame.lua")
dofile(minetest.get_modpath("hiddenseeker") .."/commands.lua")

hiddenseeker.lobbys = {
  [1] = {
    ["string_name"] = "Hide and Seek Karsthafen",
    ["pos"] = {x=716, y=12, z=732},
    ["seekerpos"] = {x=705, y=20.5, z=706},
    ["blocks"] = {"default:bookshelf", "default:stone", "default:wood", "stairs:stair_junglewood", "default:junglewood", "default:steelblock", "stairs:stair_stone", "stairs:stair_wood"},
    ["ingame"] = false,
    ["players"] = {},
    ["hiddingtime"] = 0,
    ["timetowin"] = 0,
    ["hidding"] = false,
    ["mustcreate"] = false,
    ["schem"] = "hide1",
    ["schempos"] = {x=700, y=0, z=700}
  }
}

hiddenseeker.player_lobby = {}
hiddenseeker.max_players = 20
hiddenseeker.timetowin = 300
hiddenseeker.hiddingtime = 30
hiddenseeker.timetodisquis = 5

function hiddenseeker.get_lobby_players(lobby)
  local players = {}
  for _, player in pairs(subgames.get_lobby_players("hiddenseeker")) do
    local name = player:get_player_name()
    if hiddenseeker.player_lobby[name] == lobby then
      table.insert(players, player)
    end
  end
  return players
end

minetest.register_tool("hiddenseeker:teleporter", {
  description = "Hide and Seek Teleporter",
	inventory_image = "dye_green.png",
	on_use = function(itemstack, user, pointed_thing)
    hiddenseeker.open_teleporter_form(user)
  end,
  on_secondary_use = function(itemstack, user, pointed_thing)
    hiddenseeker.open_teleporter_form(user)
  end,
})

function hiddenseeker.create_teleporter_form()
  local name = player:get_player_name()
  local status = {}
  for lobby, table in pairs(hiddenseeker.lobbys) do
    if lobby ~= 0 then
      if table.ingame == true then
        status[lobby] = minetest.colorize("red", "Ingame")
      elseif #hiddenseeker.get_lobby_players(lobby) >= 2 then
        status[lobby] = minetest.colorize("yellow", "Starting")
      else status[lobby] = minetest.colorize("lime", "Waiting")
      end
      status[lobby] = #hiddenseeker.get_lobby_players(lobby).."/"..hiddenseeker.max_players.." "..status[lobby]
    end
  end
    return ("size[4,4]" ..
    "image_button[0,0;2,2;hideandseek.png;map1;"..status[1].."]" ..
    "tooltip[map1;"..hiddenseeker.lobbys[1].string_name.."]")
end

minetest.register_on_player_receive_fields(function(player, formname, pressed)
  if formname == "hiddenseeker:teleporter" then
    local name = player:get_player_name()
    if pressed.map1 then
      hiddenseeker.leave_game(player)
      minetest.chat_send_player(name, hiddenseeker.join_game(player, 1))
    end
    minetest.close_formspec(name, "hiddenseeker:teleporter")
  end
end)

subgames.register_on_joinplayer(function(player, lobby)
  if lobby == "hiddenseeker" then
    local name = player:get_player_name()
    hiddenseeker.join_game(player, 1)
    subgames.add_mithud(player, "You joined Hide and Seek!", 0xFFFFFF, 3)
    subgames.chat_send_all_lobby("hiddenseeker", "*** "..name.." joined Hide and Seek.")
    if not hiddenseeker.disguis[name] then
      hiddenseeker.disguis[name] = {time=hiddenseeker.timetodisquis}
    end
    local privs = minetest.get_player_privs(name)
    privs.armor = nil
    minetest.set_player_privs(name, privs)
  end
end)

subgames.register_on_leaveplayer(function(player, lobby)
  if lobby == "hiddenseeker" then
    local name = player:get_player_name()
    local plobby = hiddenseeker.player_lobby[name]
    hiddenseeker.leave_game(player)
    hiddenseeker.win(plobby)
    hiddenseeker.player_lobby[name] = nil
    hiddenseeker.disguis[name] = nil
    subgames.chat_send_all_lobby("hiddenseeker", "*** "..name.." left Hide and Seek.")
  end
end)

function areas.hiddenseeker.dig(pos, node, digger)
  return false
end

function areas.hiddenseeker.place(itemstack, placer, pointed_thing, param2)
  return false
end

subgames.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, lobby)
  if lobby == "hiddenseeker" and player and hitter then
    if damage == 0 then
      return
    end
    local name = player:get_player_name()
    local hitname = hitter:get_player_name()
    local plobby = hiddenseeker.player_lobby[name]
    if plobby ~= hiddenseeker.player_lobby[hitname] then
      minetest.kick_player(name)
      minetest.kick_player(hitname)
      return
    end
    if plobby == 0 or hiddenseeker.lobbys[plobby].players[name] == hiddenseeker.lobbys[plobby].players[hitname] or hiddenseeker.lobbys[plobby].players[name] ~= "seeker" and hiddenseeker.lobbys[plobby].players[hitname] ~= "seeker" or not hiddenseeker.lobbys[plobby].ingame then
      player:set_hp(player:get_hp()+damage)
    end
  end
end)

function hiddenseeker.chat_send_all_lobby(lobby, msg)
  for _,player in pairs(hiddenseeker.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    minetest.chat_send_player(name, msg)
  end
end

subgames.register_on_chat_message(function(name, message, lobby)
  if lobby == "hiddenseeker" then
    local plobby = hiddenseeker.player_lobby[name]
    for aname, alobby in pairs(hiddenseeker.player_lobby) do
      if alobby == plobby then
        minetest.chat_send_player(aname, "<"..name.."> "..message)
      end
    end
    return true
  end
end)

subgames.register_on_drop(function(itemstack, dropper, pos, lobby)
  if lobby == "hiddenseeker" then
    return false
  end
end)

function hiddenseeker.join_game(player, lobby)
  local name = player:get_player_name()
  if #hiddenseeker.get_lobby_players(lobby) >= hiddenseeker.max_players then
    return "The lobby is full!"
  elseif hiddenseeker.lobbys[lobby].ingame == true then
    hiddenseeker.player_lobby[name] = lobby
    hiddenseeker.lobbys[lobby].players[name] = "seeker"
    hiddenseeker.chat_send_all_lobby(lobby, name.." is Seeker.")
    subgames.clear_inv(player)
    if hiddenseeker.lobbys[lobby].hidding then
      player:setpos(hiddenseeker.lobbys[lobby].seekerpos)
    else player:setpos(hiddenseeker.lobbys[lobby].pos)
      subgames.add_armor(player, ItemStack("3d_armor:helmet_cactus"), ItemStack("3d_armor:chestplate_cactus"), ItemStack("3d_armor:leggings_cactus"), ItemStack("3d_armor:boots_cactus"))
      player:get_inventory():add_item("main", "default:sword_steel")
    end
    player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
    return "Lobby is ingame! So you are now a seeker."
  else hiddenseeker.player_lobby[name] = lobby
    player:setpos(hiddenseeker.lobbys[lobby].pos)
    subgames.clear_inv(player)
    hiddenseeker.lobbys[lobby].players[name] = true
    player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
    sfinv.set_page(player, "subgames:kits")
    hiddenseeker.win(lobby)
    if hiddenseeker.lobbys[lobby].mustcreate == true then
      hiddenseeker.lobbys[lobby].mustcreate = false
      minetest.chat_send_all("Creating Hide and seek map don't leave!, May lag")
      local schem = minetest.get_worldpath() .. "/schems/" .. hiddenseeker.lobbys[lobby].schem .. ".mts"
      minetest.place_schematic(hiddenseeker.lobbys[lobby].schempos, schem)
    end
    return "You joined the map "..hiddenseeker.lobbys[lobby].string_name.."!"
  end
end

function hiddenseeker.leave_game(player)
  local name = player:get_player_name()
  local lobby = hiddenseeker.player_lobby[name]
  if lobby then
    hiddenseeker.lobbys[lobby].players[name] = nil
    player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
    if hiddenseeker.lobbys[lobby].ingame then
      hiddenseeker.chat_send_all_lobby(lobby, name.." left this Round.")
    end
  end
  if hiddenseeker.disguis[name].enable then
    hiddenseeker.disguis[name].time = hiddenseeker.timetodisquis
    hiddenseeker.disguis_player(player)
  end
end
