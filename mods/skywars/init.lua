--[[This is the control mod of skywars based on the subgames mod]]

skywars = {}

skywars.lobbys = {
  [1] = {
    ["string_name"] = "Tiki",
    ["playercount"] = 12,
    ["players"] = {},
    ["pos"] = {
      [1] = {x=1102, y=2036, z=40},
      [2] = {x=1095, y=2035, z=18},
      [3] = {x=1075, y=2036, z=12},
      [4] = {x=1040, y=2036, z=12},
      [5] = {x=1021, y=2035, z=19},
      [6] = {x=1012, y=2036, z=40},
      [7] = {x=1012, y=2036, z=75},
      [8] = {x=1021, y=2036, z=96},
      [9] = {x=1040, y=2036, z=103},
      [10] = {x=1075, y=2036, z=104},
      [11] = {x=1096, y=2035, z=95},
      [12] = {x=1102, y=2036, z=74}
    },
    ["chestpos"] = {
      [1] = {x=1100, y=2029, z=70},
      [2] = {x=1097, y=2029, z=72},
      [3] = {x=1098, y=2024, z=75},
      [4] = {x=1098, y=2024, z=40},
      [5] = {x=1097, y=2029, z=43},
      [6] = {x=1101, y=2029, z=45},
      [7] = {x=1089, y=2029, z=27},
      [8] = {x=1096, y=2029, z=21},
      [9] = {x=1088, y=2024, z=24},
      [10] = {x=1076, y=2024, z=18},
      [11] = {x=1071, y=2029, z=15},
      [12] = {x=1073, y=2029, z=19},
      [13] = {x=1043, y=2029, z=18},
      [14] = {x=1045, y=2029, z=15},
      [15] = {x=1040, y=2024, z=17},
      [16] = {x=1028, y=2024, z=24},
      [17] = {x=1027, y=2029, z=27},
      [18] = {x=1022, y=2029, z=24},
      [19] = {x=1018, y=2029, z=43},
      [20] = {x=1013, y=2029, z=40},
      [21] = {x=1017, y=2024, z=40},
      [22] = {x=1017, y=2024, z=76},
      [23] = {x=1017, y=2029, z=77},
      [24] = {x=1018, y=2029, z=73},
      [25] = {x=1027, y=2029, z=89},
      [26] = {x=1022, y=2029, z=92},
      [27] = {x=1028, y=2024, z=92},
      [28] = {x=1040, y=2024, z=99},
      [29] = {x=1045, y=2029, z=102},
      [30] = {x=1043, y=2029, z=98},
      [31] = {x=1071, y=2029, z=102},
      [32] = {x=1073, y=2029, z=98},
      [33] = {x=1076, y=2024, z=99},
      [34] = {x=1092, y=2024, z=88},
      [35] = {x=1089, y=2029, z=89},
      [36] = {x=1090, y=2029, z=93},
      [37] = {x=1074, y=2029, z=74},
      [38] = {x=1074, y=2029, z=42},
      [39] = {x=1042, y=2029, z=42},
      [40] = {x=1042, y=2029, z=74},
      [41] = {x=1058, y=2023, z=68},
      [42] = {x=1068, y=2023, z=58},
      [43] = {x=1058, y=2023, z=48},
      [44] = {x=1048, y=2023, z=58},
      [45] = {x=1057, y=2039, z=60},
      [46] = {x=1060, y=2035, z=57}
    },
    ["specpos"] = {x=1058, y=2036, z=58},
    ["mustcreate"] = true,
    ["mapblocks"] = {},
    ["mappos1"] = {x=1000, y=2000, z=0},
    ["mappos2"] = {x=1118, y=2070, z=126},
    ["schem"] = "tiki",
    ["schempos"] = {x=1000, y=2000, z=0}
  },
  [2] = {
    ["string_name"] = "Submerged",
    ["playercount"] = 12,
    ["players"] = {},
    ["pos"] = {
      [1] = {x=11, y=2015, z=1035},
      [2] = {x=8, y=2015, z=1056},
      [3] = {x=12, y=2015, z=1071},
      [4] = {x=34, y=2015, z=1097},
      [5] = {x=55, y=2015, z=1099},
      [6] = {x=70, y=2015, z=1095},
      [7] = {x=96, y=2015, z=1073},
      [8] = {x=98, y=2015, z=1052},
      [9] = {x=94, y=2015, z=1037},
      [10] = {x=72, y=2015, z=1012},
      [11] = {x=51, y=2015, z=1012},
      [12] = {x=36, y=2015, z=1013}
    },
    ["chestpos"] = {
      [1] = {x=9, y=2016, z=1030},
      [2] = {x=12, y=2015, z=1037},
      [3] = {x=15, y=2010, z=1035},
      [4] = {x=3, y=2015, z=1056},
      [5] = {x=11, y=2015, z=1056},
      [6] = {x=12, y=2010, z=1053},
      [7] = {x=10, y=2016, z=1076},
      [8] = {x=13, y=2015, z=1069},
      [9] = {x=16, y=2010, z=1071},
      [10] = {x=36, y=2015, z=1095},
      [11] = {x=29, y=2016, z=1098},
      [12] = {x=34, y=2010, z=1092},
      [13] = {x=55, y=2015, z=1096},
      [14] = {x=53, y=2015, z=1104},
      [15] = {x=52, y=2010, z=1095},
      [16] = {x=75, y=2016, z=1097},
      [17] = {x=68, y=2015, z=1094},
      [18] = {x=70, y=2010, z=1091},
      [19] = {x=97, y=2016, z=1078},
      [20] = {x=94, y=2015, z=1071},
      [21] = {x=91, y=2010, z=1073},
      [22] = {x=103, y=2015, z=1054},
      [23] = {x=95, y=2015, z=1052},
      [24] = {x=94, y=2010, z=1055},
      [25] = {x=96, y=2016, z=1032},
      [26] = {x=93, y=2015, z=1039},
      [27] = {x=90, y=2010, z=1037},
      [28] = {x=77, y=2016, z=1010},
      [29] = {x=70, y=2015, z=1013},
      [30] = {x=72, y=2010, z=1016},
      [31] = {x=51, y=2015, z=1012},
      [32] = {x=53, y=2015, z=1004},
      [33] = {x=54, y=2010, z=1013},
      [34] = {x=31, y=2016, z=1011},
      [35] = {x=38, y=2015, z=1014},
      [36] = {x=36, y=2010, z=1017},

      [37] = {x=58, y=2014, z=1029},
      [38] = {x=26, y=2014, z=1058},
      [39] = {x=48, y=2014, z=1079},
      [40] = {x=80, y=2014, z=1050},

      [41] = {x=60, y=2016, z=1064},
      [42] = {x=48, y=2016, z=1045},
      [43] = {x=71, y=2025, z=1043},
      [44] = {x=64, y=2025, z=1036},
      [45] = {x=66, y=2019, z=1037},
      [46] = {x=1060, y=2035, z=57}
    },
    ["specpos"] = {x=53, y=2016, z=1059},
    ["mustcreate"] = true,
    ["mapblocks"] = {},
    ["mappos1"] = {x=0, y=1990, z=1000},
    ["mappos2"] = {x=111, y=2042, z=1107},
    ["schem"] = "submerged",
    ["schempos"] = {x=0, y=2000, z=1000}
  }
}

skywars.player_lobby = {}
dofile(minetest.get_modpath("skywars") .."/registers.lua")
dofile(minetest.get_modpath("skywars") .."/start.lua")
dofile(minetest.get_modpath("skywars") .."/chests.lua")
dofile(minetest.get_modpath("skywars") .."/commands.lua")
dofile(minetest.get_modpath("skywars") .."/kits.lua")

function skywars.get_lobby_players(lobby)
  local players = {}
  for _, player in pairs(subgames.get_lobby_players("skywars")) do
    local name = player:get_player_name()
    if skywars.player_lobby[name] == lobby then
      table.insert(players, player)
    end
  end
  return players
end

function skywars.chat_send_all_lobby(lobby, msg)
  for _,player in pairs(skywars.get_lobby_players(lobby)) do
    local name = player:get_player_name()
    minetest.chat_send_player(name, msg)
  end
end

function skywars.join_game(player, lobby)
  local name = player:get_player_name()
  if #skywars.get_lobby_players(lobby) >= skywars.lobbys[lobby].playercount then
    local newlobby = #skywars.lobbys
    if #skywars.get_lobby_players(newlobby) < skywars.lobbys[newlobby].playercount then
      skywars.join_game(player, newlobby)
    end
    return "The lobby is full !"
  elseif skywars.lobbys[lobby].ingame == true then
    skywars.player_lobby[name] = lobby
    player:setpos(skywars.lobbys[lobby].specpos)
    subgames.clear_inv(player)
    skywars.lobbys[lobby].players[name] = false
    sfinv.set_page(player, "subgames:maps")
    subgames.spectate(player)
    return "Lobby is ingame! So you are now spectating."
  else skywars.player_lobby[name] = lobby
    player:setpos(skywars.lobbys[lobby].specpos)
    subgames.clear_inv(player)
    sfinv.set_page(player, "subgames:maps")
    skywars.win(lobby)
    if skywars.lobbys[lobby].mustcreate == true then
      skywars.lobbys[lobby].mustcreate = false
      minetest.chat_send_all("Creating Skywars map don't leave!, May lag")
      local schem = minetest.get_worldpath() .. "/schems/" .. skywars.lobbys[lobby].schem .. ".mts"
      local vm = minetest.get_voxel_manip()
      vm:read_from_map(skywars.lobbys[lobby].mappos1, skywars.lobbys[lobby].mappos2)
      minetest.place_schematic_on_vmanip(vm, skywars.lobbys[lobby].schempos, schem)
      vm:write_to_map()
      minetest.fix_light(skywars.lobbys[lobby].mappos1, skywars.lobbys[lobby].mappos2)
      worldedit.clear_objects(skywars.lobbys[lobby].mappos1, skywars.lobbys[lobby].mappos2)
    end
    return "You joined the map "..skywars.lobbys[lobby].string_name.."!"
  end
end

function skywars.leave_game(player)
  local name = player:get_player_name()
  local lobby = skywars.player_lobby[name]
  if lobby then
    skywars.lobbys[lobby].players[name] = nil
    subgames.unspectate(player)
    if skywars.lobbys[lobby].ingame then
      skywars.chat_send_all_lobby(lobby, name.." left this Round.")
      local privs = minetest.get_player_privs(name)
      privs.craft = nil
      minetest.set_player_privs(name, privs)
    end
  end
end
