--[[
This Mods sort clients by their version_string minor, major, patch, serialization_version, protocol_version.
To access this info your server needs either a build merged this in:
https://github.com/minetest/minetest/pull/8616
or for mt-0.4.17 you need this branch:
https://github.com/Lejo1/minetest/tree/version_string4
Just access the data using /client_matcher list
]]

--[[Infos about clients:
MT Official: 5.0.0-githash-Android or 0.4.16/17/17.1 or special -dirty

Forks(sorted by most players):
NAME123 Spieler: 27 ||| 26 ||| 0 ||| 4 ||| 13 ||| 0.4.13

]]

local storage = minetest.get_mod_storage()

local forkinfo = "This is a Minetest Server!\nYou play an unofficial Game!\nOnly the official Minetest Client is allowed here\nYou can download it on Minetest.net\nor on the Google Play Store, just search for Minetest."

-- Stolen from https://github.com/TalkLounge/adblock/blob/master/init.lua
local form = "size[4.1,3.9]" ..
				 "label[0.65,0;YOU PLAY AN UNOFFICIAL GAME]" ..
				 "label[0,1;On this server is only the official game allowed: Minetest]" ..
				 "label[0.35,1.5;MINETEST is FREE & has NO INGAME ADS]" ..
				 "label[0.75,2;If you don't want to see this again:]" ..
				 "label[0.55,2.5;DOWNLOAD & PLAY MINETEST NOW]" ..
         "button_exit[1.35,3.5;1.2,0.1;adblock_close;Close]"

local function forkforminfo(player)
  if player:is_player_connected() then
    minetest.show_formspec(player:get_player_name(), "adblock:main", form)
    minetest.after(300, forkforminfo, player)
  end
end

local function forkinfo(player)
  local input = {
  hud_elem_type = "text",
  position = {x=0.6,y=0.1},
  scale = {x=100,y=50},
  text = forkinfo,
  number = 0xFF0000,
  alignment = {x=0,y=1},
  offset = {x=0, y=-32}}
  player:hud_add(input)

end

local function mtupdate(player)
  local input = {
  hud_elem_type = "text",
  position = {x=0.8,y=0.1},
  scale = {x=100,y=50},
  text = "Your client is outdated!\nPlease update to minetest 5.0\nYou can find it at minetest.net\nAll stats on this server will be removed!\nSo please play on the new server!",
  number = 0xFF0000,
  alignment = {x=0,y=1},
  offset = {x=0, y=-32}}
  player:hud_add(input)
end

minetest.register_on_joinplayer(function(player)
  minetest.after(5, function()
    if player:is_player_connected() then
      local info = minetest.get_player_information(player:get_player_name())
      if info then
        if info.protocol_version and info.serialization_version and info.major
        and info.minor and info.patch and info.version_string then
          local data = info.protocol_version.."@"..info.serialization_version.."@"..
          info.major.."@"..info.minor.."@"..info.patch.."@"..info.version_string
          if storage:get_int(data) < 0 then
            storage:set_int(data, storage:get_int(data) - 1)
            forkinfo(player)
            forkforminfo(player)
          else storage:set_int(data, storage:get_int(data) + 1)
            mtupdate(player)
          end
        else minetest.log("error", "Client Matcher: You need a server build with access to advanced player information see README.md for help!")
        end
      end
    end
  end)
end)

local function make_fork(info, enable)
  if info.protocol_version and info.serialization_version and info.major
  and info.minor and info.patch and info.version_string then
    local data = info.protocol_version.."@"..info.serialization_version.."@"..
    info.major.."@"..info.minor.."@"..info.patch.."@"..info.version_string
    local count = storage:get_int(data)
    if enable then
      if count > 0 then
        storage:set_int(data, 0-count)
      end
      return "These clients will now receive fork info!"
    else
      if count < 0 then
        storage:set_int(data, 0-count)
      end
      return "These clients won't receive fork info anymore!"
    end
  else return "Please choose a client with complete client info!"
  end
end

local function get_string_by_info(info)
  local str = ""
  local total = 0
  local array = storage:to_table().fields
  local sorted_array = {}
  for key, numb in pairs(array) do
    numb = tonumber(numb)
    if numb < 0 then
      total = total - numb
    else total = total + numb
    end
  end
  if not info then
    for key, numb in pairs(array) do
      table.insert(sorted_array, {tonumber(numb), key})
    end
    table.sort(sorted_array, function(x, y)
      return x[1] > y[1]
    end)
    str = str.."[join count/percentage] protocol_version, ser_vers, major, minor, patch, version_string"
    for _, value in ipairs(sorted_array) do
      local count = value[1]
      local index = value[2]
      if count < 0 then
        count = 0 - count
      end
      local data = string.split(index, "@")
      str = str.."\n["..count.."/"..100*(count/total).."%] "..table.concat(data, " ||| ")
    end
  elseif info.protocol_version and info.serialization_version and info.major
  and info.minor and info.patch and info.version_string then
    local data = info.protocol_version.."@"..info.serialization_version.."@"..
    info.major.."@"..info.minor.."@"..info.patch.."@"..info.version_string
    local count = storage:get_int(data)
    if count < 0 then
      count = 0 - count
    end
    local data_table = string.split(data, "@")
    str = str.."[join count/percentage] protocol_version, ser_vers, major, minor, patch, version_string"
    str = str.."\n["..count.."/"..100*(count/total).."%] "..table.concat(data_table, " ||| ")
  else str = "Got wrong info."
  end
  return str
end

minetest.register_chatcommand("client_matcher", {
  description = "Shows which kind of client join your server + Fork Settings!",
  params = "list/reset/get <name>/setfork <name>/delfork <name>",
  privs = {ban=true},
  func = function(name, params)
    local split = string.split(params, " ")
    if params == "list" then
      minetest.chat_send_player(name, get_string_by_info())
    elseif params == "reset" then
      storage:from_table(nil)
      return true, "Cleared client matcher list"
    elseif #split == 2 and split[1] == "get" and minetest.get_player_by_name(split[2]) then
      local info = minetest.get_player_information(split[2])
      minetest.chat_send_player(name, get_string_by_info(info))
    elseif #split == 2 and split[1] == "setfork" and minetest.get_player_by_name(split[2]) then
      local info = minetest.get_player_information(split[2])
      return true, make_fork(info, true)
    elseif #split == 2 and split[1] == "delfork" and minetest.get_player_by_name(split[2]) then
      local info = minetest.get_player_information(split[2])
      return true, make_fork(info, false)
    else return false, "Invalid Params: list/reset/get <name>/setfork <name>/delfork <name>"
    end
  end,
})

--  Print on startup the whole list error for high listing...
minetest.log("error", "Client Matcher List: "..get_string_by_info())
