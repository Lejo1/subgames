--[[This is the control mod of mesewars based on the subgames mod]]

mesewars = {}

mesewars.lobbys = {
  [1] = {
    ["string_name"] = "4 Seasons by Sontrunks",
    ["playercount"] = 16,
    ["teams"] = 4,
    ["maxteam"] = 1,
    ["players"] = {},
    ["ingame"] = false,
    ["pos"] = {
      [1] = {x=57, y=1155, z=-66},
      [2] = {x=21, y=1155, z=-32},
      [3] = {x=-11, y=1155, z=-67},
      [4] = {x=20, y=1155, z=-100}
    },
    ["mesepos"] = {
      [1] = {x=61, y=1156, z=-62},
      [2] = {x=22, y=1156, z=-24},
      [3] = {x=-23, y=1156, z=-66},
      [4] = {x=21, y=1156, z=-110}
    },
    ["meses"] = {
      [1] = false,
      [2] = false,
      [3] = false,
      [4] = false
    },
    ["brick"] = {
      [1] = {x=57, y=1156, z=-62},
      [2] = {x=19, y=1156, z=-35},
      [3] = {x=-10, y=1156, z=-65},
      [4] = {x=22, y=1156, z=-99}
    },
    ["steel"] = {
      [1] = {x=55, y=1156, z=-69},
      [2] = {x=24, y=1156, z=-35},
      [3] = {x=-10, y=1156, z=-69},
      [4] = {x=19, y=1156, z=-99}
    },
    ["gold"] = {
      [1] = {x=23, y=1156, z=-67},
      [2] = {x=22, y=1156, z=-66},
      [3] = {x=21, y=1156, z=-67},
      [4] = {x=22, y=1156, z=-68}
    },
    ["msteel"] = {
      [1] = {x=30, y=1156, z=-67},
      [2] = {x=22, y=1156, z=-58},
      [3] = {x=13, y=1156, z=-67},
      [4] = {x=22, y=1156, z=-76}
    },
    ["specpos"] = {x=22, y=1181, z=-67},
    ["mustcreate"] = true,
    ["mapblocks"] = {},
    ["mappos1"] = {x=-31, y=1100, z=-116},
    ["mappos2"] = {x=74, y=1202, z=-18},
    ["schem"] = "newmese2",
    ["schempos"] = {x=-31, y=1100, z=-116}
  },
  [2] = {
    ["string_name"] = "Mesewars is just like Eggwars",
    ["playercount"] = 16,
    ["teams"] = 4,
    ["maxteam"] = 1,
    ["players"] = {},
    ["ingame"] = false,
    ["pos"] = {
      [1] = {x=-584, y=1138, z=-502},
      [2] = {x=-584, y=1138, z=-666},
      [3] = {x=-666, y=1138, z=-584},
      [4] = {x=-502, y=1138, z=-584}
    },
    ["mesepos"] = {
      [1] = {x=-584, y=1138, z=-498},
      [2] = {x=-584, y=1138, z=-670},
      [3] = {x=-670, y=1138, z=-584},
      [4] = {x=-498, y=1138, z=-584}
    },
    ["meses"] = {
      [1] = false,
      [2] = false,
      [3] = false,
      [4] = false
    },
    ["brick"] = {
      [1] = {x=-591, y=1138, z=-501},
      [2] = {x=-577, y=1138, z=-667},
      [3] = {x=-667, y=1138, z=-591},
      [4] = {x=-501, y=1138, z=-577}
    },
    ["steel"] = {
      [1] = {x=-584, y=1138, z=-507},
      [2] = {x=-584, y=1138, z=-661},
      [3] = {x=-661, y=1138, z=-584},
      [4] = {x=-507, y=1138, z=-584}
    },
    ["gold"] = {
      [1] = {x=-584, y=1141, z=-581},
      [2] = {x=-584, y=1141, z=-587},
      [3] = {x=-587, y=1141, z=-584},
      [4] = {x=-581, y=1141, z=-584}
    },
    ["msteel"] = {
      [1] = {x=-584, y=1141, z=-571},
      [2] = {x=-584, y=1141, z=-597},
      [3] = {x=-597, y=1141, z=-584},
      [4] = {x=-571, y=1141, z=-584}
    },
    ["specpos"] = {x=-584, y=1172, z=-584},
    ["mustcreate"] = true,
    ["mapblocks"] = {},
    ["mappos1"] = {x=-700, y=1100, z=-700},
    ["mappos2"] = {x=-468, y=1187, z=-468},
    ["schem"] = "submese3",
    ["schempos"] = {x=-700, y=1100, z=-700}
  }
}

mesewars.player_lobby = {}
dofile(minetest.get_modpath("mesewars") .."/registers.lua")
dofile(minetest.get_modpath("mesewars") .."/start.lua")
dofile(minetest.get_modpath("mesewars") .."/color.lua")
dofile(minetest.get_modpath("mesewars") .."/shop.lua")
dofile(minetest.get_modpath("mesewars") .."/teams.lua")
dofile(minetest.get_modpath("mesewars") .."/spawner.lua")
dofile(minetest.get_modpath("mesewars") .."/commands.lua")
dofile(minetest.get_modpath("mesewars") .."/kits.lua")

subgames.register_game("mesewars", {
  fullname = "Mesewars",
  object = mesewars,
  area = {
    [1] = {x=(-700), y=1000, z=-700},
    [2] = {x=75, y=1302, z=(-17)}
  },
  crafting = false,
  node_dig = function(pos, node, digger)
    local name = digger:get_player_name()
    local plobby = mesewars.player_lobby[name]
    local nodename = node.name
    if mesewars.lobbys[plobby].ingame and (mesewars.lobbys[plobby].mapblocks[minetest.pos_to_string(pos)] and (nodename == "default:sandstone" or nodename == "default:obsidian" or nodename == "default:glass" or nodename == "default:steelblock" or nodename == "default:chest")) or string.find(nodename, "mesewars:mese") then
      return true
    end
  end,
  item_place_node = function(itemstack, placer, pointed_thing, param2)
    local plobby
    if not placer or not placer:is_player() then
      plobby = get_lobby_from_pos(pos)
    else local name = placer:get_player_name()
      plobby = mesewars.player_lobby[name]
    end
    if not plobby then return end
    if mesewars.lobbys[plobby].ingame then
      return true
    end
  end,
  drop = function(pos, itemname, player)
    local name = player:get_player_name()
    local plobby = mesewars.player_lobby[name]
    if not plobby then
      plobby = get_lobby_from_pos(pos)
      if not plobby then
        return false
      end
    end
    if mesewars.lobbys[plobby].ingame and itemname == "default:sandstone" or itemname == "default:obsidian" or itemname == "default:glass" or itemname == "default:steelblock" or itemname == "default:chest" then
      return true
    else return false
    end
  end,
  remove_player = mesewars.remove_player_kits
})

function mesewars.get_lobby_players(lobby)
  local players = {}
  for _, player in pairs(subgames.get_lobby_players("mesewars")) do
    local name = player:get_player_name()
    if mesewars.player_lobby[name] == lobby then
      table.insert(players, player)
    end
  end
  return players
end

function mesewars.chat_send_all_lobby(lobby, msg)
  for _,player in pairs(mesewars.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    minetest.chat_send_player(name, msg)
  end
end

function mesewars.join_game(player, lobby)
  local name = player:get_player_name()
  if #mesewars.get_lobby_players(lobby) >= mesewars.lobbys[lobby].playercount then
    for newlobby,ldata in pairs(mesewars.lobbys) do
      if #mesewars.get_lobby_players(newlobby) < ldata.playercount then
        mesewars.join_game(player, newlobby)
        return "The lobby is full, so you joined the map "..ldata.string_name.."!"
      end
    end
    return "The lobby is full !"
  elseif mesewars.lobbys[lobby].ingame == true then
    mesewars.player_lobby[name] = lobby
    player:set_pos(mesewars.lobbys[lobby].specpos)
    subgames.clear_inv(player)
    mesewars.lobbys[lobby].players[name] = false
    subgames.spectate(player)
    sfinv.set_page(player, "mesewars:maps")
    return "Lobby is ingame! So you are now spectating."
  else mesewars.player_lobby[name] = lobby
    player:set_pos(mesewars.lobbys[lobby].specpos)
    subgames.clear_inv(player)
    mesewars.win(lobby)
    mesewars.lobbys[lobby].players[name] = false
    if mesewars.lobbys[lobby].mustcreate == true then
      mesewars.lobbys[lobby].mustcreate = false
      minetest.chat_send_all("Creating mesewars map, don't leave!, May lag")
      local schem = minetest.get_worldpath() .. "/schems/" .. mesewars.lobbys[lobby].schem .. ".mts"
      local vm = minetest.get_voxel_manip()
      vm:read_from_map(mesewars.lobbys[lobby].mappos1, mesewars.lobbys[lobby].mappos2)
      minetest.place_schematic_on_vmanip(vm, mesewars.lobbys[lobby].schempos, schem)
      vm:write_to_map()
      minetest.fix_light(mesewars.lobbys[lobby].mappos1, mesewars.lobbys[lobby].mappos2)
    end
    mesewars.team_form(name)
    sfinv.set_page(player, "mesewars:team")
    return "You joined the map "..mesewars.lobbys[lobby].string_name.."!"
  end
end

function mesewars.leave_game(player)
  local name = player:get_player_name()
  local lobby = mesewars.player_lobby[name]
  if lobby then
    mesewars.lobbys[lobby].players[name] = nil
    subgames.unspectate(player)
  end
end
