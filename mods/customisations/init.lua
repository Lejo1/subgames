--  Server customisations
dofile(minetest.get_modpath("customisations") .. "/main.lua")
dofile(minetest.get_modpath("customisations") .. "/build.lua")

minetest.register_privilege("invs", "Allows you to be fully invisible!")

function minetest.get_server_status()
  local total = ""
  local skywars = ""
  local mesewars = ""
  local hiddenseeker = ""
  local survivalgames = ""
  for name, subgame in pairs(player_lobby) do
    if minetest.get_player_privs(name).invs then
    elseif total == "" then
      total = name
    else total = total.. ", "..name
    end
    if minetest.get_player_privs(name).invs then
    elseif subgame == "mesewars" then
      if mesewars == "" then
        mesewars = name
      else mesewars = mesewars.. ", "..name
      end
    elseif subgame == "hiddenseeker" then
      if hiddenseeker == "" then
        hiddenseeker = name
      else hiddenseeker = hiddenseeker.. ", "..name
      end
    elseif subgame == "skywars" then
      if skywars == "" then
        skywars = name
      else skywars = skywars.. ", "..name
      end
    elseif subgame == "survivalgames" then
      if survivalgames == "" then
        survivalgames = name
      else survivalgames = survivalgames.. ", "..name
      end
    end
  end
   return "# Server: Total = {"..total.."} \n# Server: Mesewars = {"..mesewars.."} \n# Server: Hide and Seek = {"..hiddenseeker.."} \n# Server: Skywars = {"..skywars.."} \n# Server: Survivalgames = {"..survivalgames.."} \n# Server: "..minetest.setting_get("motd")
end

core.get_server_status = minetest.get_server_status

local info = {
  ["general"] = {
    ["name"] = "General",
    ["text"] = [[Subgames for all is minigame server for everyone. We have three minigames Mesewars, Hide and Seek and Skywars. We want that you have fun at the server to make this sure we have rules for everyone. If you igonre the rules we have to ban you from the the server. We want that the players play fair together and that the respekt each other. The chat is splitted into different channels. If you want to write something to somebody who is not in your lobby, you have to use:
    @PLAYERNAME [msg]
    or to everyone:
    @all [msg] or @a [msg] ]]
  },
  ["mesewars"] = {
    ["name"] = "Mesewars",
    ["text"] = [[Mesewars is like Eggwars or Bedwars in Minecraft Mesewars is a game in the Sky you have to eliminate the other teams. If you kill a other player he can respawn until you destroy his Mese in his team. In your teambase you have a shop. You can buy item with bronze, that you find in your base, with iron and with gold, that you only find in the middle. The map has four teams with each four players. Please be fair and only team with your teammates and not with other teams.]]
  },
  ["hiddenseeker"] = {
    ["name"] = "Hide and Seek",
    ["text"] = [[In hide and seek the Hiders try to hide. They disquis into a block, when they stand 5 seconds still. You undisquis if you move or a Seeker hits you with his sword. When you get killed from a Seeker you respawn as a Seeker. As seeker your Goal is to kill all hiders. When all hiders are death the seekers win the game, if the seekers don't find all hiders the hiders win after 5 minutes.]]
  },
  ["skywars"] = {
    ["name"] = "Skywars",
    ["text"] = [[Skywars is just like in Minecraft. In Skywars you join on a small island you find weapons and blocks in the chests. Your goal is to kill all other players on their islands. In the middle of the maps is one big island with many chests and more items. Please be fair to other players and don't team in skywars it's not allowed otherwise we have to ban you temporarily.]]
  },
  ["survivalgames"] = {
    ["name"] = "Survivalgames",
    ["text"] = [[The Goal in Survivalgames is just as the name says to survive. You can find chests on the map with loot to fight against the others. Teaming is not allowed. The is allways random generated. Important: The map gets reseted after each round so please don't build houses or other things there.]]
  },
  ["commands"] = {
    ["name"] = "Commands",
    ["text"] = [[In minetest you have a lots a commands you have to write the commands in the chat. All commands start with a /.
This are the important commands for the server:
/hub to get to the main lobby
/leave to leave the the current Round
/msg [playername] [msg] to write a private message to a player
/w [playername] to find out where a player is
/report [playername] to report a player if he break a rule
/rules to see the rules of the server
/info to see this again
You find the kits, skins and more in your inventory.]]
  }
}


function get_help_form(type)
  local toreturn = (
  "size[8,6]"..
  "button[0,0;2,1;general;General]"..
  "button[0,1;2,1;mesewars;Mesewars]"..
  "button[0,2;2,1;hiddenseeker;Hide and Seek]"..
  "button[0,3;2,1;skywars;Skywars]"..
  "button[0,4;2,1;survivalgames;Survivalgames]"..
  "button[0,5;2,1;commands;Commands]"..
  "textarea[2.5,0.5;5.5,6;text;;"..minetest.formspec_escape(info[type].text).."]"..
  "label[3,0;"..info[type].name.."]")
  return toreturn
end

minetest.register_chatcommand("info", {
  params = "",
  description = "Use it to see the helpguide!",
  func = function(name)
    minetest.show_formspec(name, "customisations:info", get_help_form("general"))
  end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
 if formname == "customisations:info" then
  local type
  if fields.general then type = "general" end
  if fields.mesewars then type = "mesewars" end
  if fields.hiddenseeker then type = "hiddenseeker" end
  if fields.skywars then type = "skywars" end
  if fields.survivalgames then type = "survivalgames" end
  if fields.commands then type = "commands" end
  if type then
   minetest.show_formspec(player:get_player_name(), "customisations:info", get_help_form(type))
  end
 end
end)

local function remove_whole_player_data(name)
  minetest.remove_player(name)
  minetest.remove_player_auth(name)
  sban_del_player(name)
  remove_rule_accepted(name)
  playtime.remove_playtime(name)
  skins.remove_player(name)
  subgames.remove_all_player(name)
  money.remove(name)
  reportlist.remove_data(name)
end

minetest.register_chatcommand("remove_whole_player_data", {
  description = "remove all player data of a player",
  params = "<name>",
  privs = {server = true},
  func = function(name, params)
    remove_whole_player_data(params)
    return true, "Removed all data of "..params
  end
})

--  Delete player accounts if they doesn't earn any money
minetest.register_on_leaveplayer(function(player)
  if player then
    local name = player:get_player_name()
    if not money.exist(name) then
      minetest.after(1, function()
        if minetest.get_player_by_name(name) then
          return false
        end
        remove_whole_player_data(name)
      end)
    end
  end
end)

minetest.unregister_chatcommand("me")

minetest.register_chatcommand("say", {
  params = "",
  description = "Use it to say something in the global chat.",
  privs = {kick=true},
  func = function(user, param)
    minetest.chat_send_all(param)
  end,
})

minetest.register_on_joinplayer(function(player)
		player:hud_set_flags({minimap = false})
    player:set_properties({zoom_fov=10})
end)

minetest.register_chatcommand("w", {
  params = "<name>",
  description = "Use it to get the Lobby where a player is.",
  func = function(user, param)
    local player = minetest.get_player_by_name(param)
    if player and not minetest.get_player_privs(param).invs then
      minetest.chat_send_player(user, "The player "..param.." is in the Lobby "..player_lobby[param]..".")
    else minetest.chat_send_player(user, "The player is not online")
    end
  end,
})

function core.send_join_message(name)
end

function core.send_leave_message(name, timed_out)
end

minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  player:set_properties({
    visual_size = {x=1, y=1},
    makes_footstep_sound = true,
    collisionbox = {-0.3, -1, -0.3, 0.3, 1, 0.3}
  })
  local privs = minetest.get_player_privs(name)
  privs.interact = true
  privs.fly = nil
  privs.fast = nil
  privs.noclip = nil
  minetest.set_player_privs(name, privs)
  subgames.call_join_callbacks(player, "main")
end)

minetest.register_on_chat_message(function(name, message)
  minetest.log("action", "Chatlog: "..name.." wrote:"..message)
end)


--  Actions to clean up the whole db
-- aktuell 173000
minetest.after(5, function()
  minetest.log("warning", "Starting sorting db")
  local function r(name, stage)
    remove_whole_player_data(name)
    minetest.log("action", "Removed player "..name.." at stage "..stage)
  end

  local handle = minetest.get_auth_handler()
  for name in handle.iterate() do
    minetest.log("action", "handling name "..tostring(name))
    if type(name) ~= "string" then
      minetest.log("warning", "Name not string found")
    elseif not money.exist(name) then
      r(name, "1")
    else
      local auth = handle.get_auth(name)
      if not auth or auth.last_login < 1577833200 or minetest.check_password_entry(name, auth.password, "dExT0L") then
        r(name, "2")
      else minetest.log("action", "Player "..name.." survived!")
      end
    end
  end
  minetest.log("warning", "Finished sorting db")
end)
