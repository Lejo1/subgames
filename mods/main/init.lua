--  This is the file which manages the main lobby
main = {}
local mustcreate = true
minetest.register_tool("main:teleporter", {
  description = "Teleporter",
	inventory_image = "compass.png",
	on_use = function(itemstack, user, pointed_thing)
    main.open_teleporter_form(user)
  end,
  on_secondary_use = function(itemstack, user, pointed_thing)
    main.open_teleporter_form(user)
  end,
})

main.teleporter_form = ""
function main.create_teleporter_form()
  main.teleporter_form = ("size[4,4]" ..
  "item_image_button[0,0;2,2;mesewars:mese1;mesewars;"..#subgames.get_lobby_players("mesewars").." players]" ..
  "tooltip[mesewars;Mesewars: Eggwars in Minetest!]"..
  "image_button[2,0;2,2;hideandseek.png;hiddenseeker;"..#subgames.get_lobby_players("hiddenseeker").." players]" ..
  "tooltip[hiddenseeker;Hide and Seek!]" ..
  "item_image_button[0,2;2,2;bow:bow;skywars;"..#subgames.get_lobby_players("skywars").." players]" ..
  "tooltip[skywars;Skywars!]" ..
  "item_image_button[2,2;2,2;default:sword_steel;survivalgames;"..#subgames.get_lobby_players("survivalgames").." players]" ..
  "tooltip[survivalgames;Survivalgames!]")
  return main.teleporter_form
end

function main.open_teleporter_form(player)
  local name = player:get_player_name()
  minetest.show_formspec(name, "main:teleporter", main.create_teleporter_form())
end

minetest.register_on_player_receive_fields(function(player, formname, pressed)
  if formname == "main:teleporter" then
    local name = player:get_player_name()
    if pressed.mesewars then
      subgames.change_lobby(player, "mesewars")
    elseif pressed.hiddenseeker then
      if #subgames.get_lobby_players("hiddenseeker") < hiddenseeker.max_players*#hiddenseeker.lobbys then
        subgames.change_lobby(player, "hiddenseeker")
      end
    elseif pressed.skywars then
      local count = 0
      for numb, table in pairs(skywars.lobbys) do
        count = count + table.playercount
      end
      if #subgames.get_lobby_players("skywars") < count then
        subgames.change_lobby(player, "skywars")
      else minetest.chat_send_player(name, "Skywars is full!")
      end
    elseif pressed.survivalgames then
      if #subgames.get_lobby_players("survivalgames") < survivalgames.max_players* #survivalgames.lobbys then
        subgames.change_lobby(player, "survivalgames")
      else minetest.chat_send_player(name, "Ssurvivalgames is full!")
      end
    end
    minetest.close_formspec(name, "main:teleporter")
  end
end)

local spawn = {x=(-11), y=602, z=20}
subgames.register_on_joinplayer(function(player, lobby)
  if lobby == "main" then
    local name = player:get_player_name()
    player:setpos(spawn)
    local inv = player:get_inventory()
    inv:add_item("main", "main:teleporter")
    sfinv.set_page(player, "subgames:lobbys")
    local privs = minetest.get_player_privs(name)
    privs.interact = true
    minetest.set_player_privs(name, privs)
    if mustcreate == true then
      mustcreate = false
      local param1 = "mainlobby"
      local schem = minetest.get_worldpath() .. "/schems/" .. param1 .. ".mts"
      minetest.place_schematic({x=-27, y=601, z=4}, schem)
    end
    minetest.after(1, function()
      if player:is_player_connected() and minetest.get_player_privs(name).shout and player_lobby[name] == "main" then
        main.open_teleporter_form(player)
	      subgames.clear_inv(player)
	      local inv = player:get_inventory()
    	  inv:add_item("main", "main:teleporter")
   	    sfinv.set_page(player, "subgames:lobbys")
      end
    end)
  end
end)

subgames.register_on_leaveplayer(function(player, lobby)
  if lobby == "main" then
  end
end)

function areas.main.dig(pos, node, digger)
  return false
end

function areas.main.place(itemstack, placer, pointed_thing, param2)
  return false
end

subgames.register_on_chat_message(function(name, message, lobby)
  if lobby == "main" and name and message then
    subgames.chat_send_all_lobby("main", "<"..name.."> "..message)
    return true
  end
end)

--  Add chat system
subgames.register_on_respawnplayer(function(player, lobby)
  if lobby == "main" then
    player:setpos(spawn)
  end
end)

subgames.register_on_drop(function(itemstack, dropper, pos, lobby)
  if lobby == "main" then
    return false
  end
end)

--  Add the hub command
minetest.register_chatcommand("hub", {
  params = "",
  description = "Use it to get to the Main Lobby!",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    subgames.change_lobby(player, "main")
  end,
})

--  Add the lethub command
minetest.register_chatcommand("lethub", {
  privs = {kick=true},
  params = "name",
  description = "Use it to sent players in the main Lobby!",
  func = function(name, param)
    local player = minetest.get_player_by_name(param)
    if player then
      subgames.change_lobby(player, "main")
      minetest.chat_send_player(name, "You have left the player "..param)
    else minetest.chat_send_player(name, "The player is not online!")
    end
  end,
})

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


function main.get_help_form(type)
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
    minetest.show_formspec(name, "main:info", main.get_help_form("general"))
  end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
 if formname == "main:info" then
  local type
  if fields.general then type = "general" end
  if fields.mesewars then type = "mesewars" end
  if fields.hiddenseeker then type = "hiddenseeker" end
  if fields.skywars then type = "skywars" end
  if fields.survivalgames then type = "survivalgames" end
  if fields.commands then type = "commands" end
  if type then
   minetest.show_formspec(player:get_player_name(), "main:info", main.get_help_form(type))
  end
 end
end)

subgames.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, lobby)
  if lobby == "main" and player then
    return true
  end
end)
