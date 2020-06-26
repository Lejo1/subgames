--  This is the file which manages the main lobby
main = {}
local mustcreate = true
minetest.register_tool("customisations:teleporter", {
  description = "Teleporter",
	inventory_image = "compass.png",
	on_use = function(itemstack, user, pointed_thing)
    main.open_teleporter_form(user)
  end,
  on_secondary_use = function(itemstack, user, pointed_thing)
    main.open_teleporter_form(user)
  end,
})

subgames.register_game("main", {
  fullname = "Main",
  object = main,
  area = {
    [1] = {x=(-31), y=623, z=0},
    [2] = {x=9, y=595, z=39}
  },
  crafting = false,
  node_dig = function(pos, node, digger)
    return false
  end,
  item_place_node = function(itemstack, placer, pointed_thing, param2)
    return false
  end,
})

function main.create_teleporter_form()
  return "size[4,4]" ..
  "item_image_button[0,0;2,2;mesewars:mese1;mesewars;"..#subgames.get_lobby_players("mesewars").." players]" ..
  "tooltip[mesewars;Mesewars: Eggwars in Minetest!]"..
  "image_button[2,0;2,2;hideandseek.png;hiddenseeker;"..#subgames.get_lobby_players("hiddenseeker").." players]" ..
  "tooltip[hiddenseeker;Hide and Seek!]" ..
  "item_image_button[0,2;2,2;bow:bow;skywars;"..#subgames.get_lobby_players("skywars").." players]" ..
  "tooltip[skywars;Skywars!]" ..
  "item_image_button[2,2;2,2;default:sword_steel;survivalgames;"..#subgames.get_lobby_players("survivalgames").." players]" ..
  "tooltip[survivalgames;Survivalgames!]"
end

function main.open_teleporter_form(player)
  local name = player:get_player_name()
  minetest.show_formspec(name, "customisations:teleporter", main.create_teleporter_form())
end

minetest.register_on_player_receive_fields(function(player, formname, pressed)
  if formname == "customisations:teleporter" then
    local name = player:get_player_name()
    if pressed.mesewars then
      if #subgames.get_lobby_players("mesewars") < mesewars.lobbys[1].playercount*#mesewars.lobbys then
        subgames.change_lobby(player, "mesewars")
      end
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
    minetest.close_formspec(name, "customisations:teleporter")
  end
end)

local spawn = {x=(-11), y=602, z=20}
subgames.register_on_joinplayer(function(player, lobby)
  if lobby == "main" then
    local name = player:get_player_name()
    player:set_pos(spawn)
    local inv = player:get_inventory()
    inv:add_item("main", "customisations:teleporter")
    sfinv.set_page(player, "main:lobbys")
    local privs = minetest.get_player_privs(name)
    privs.interact = true
    minetest.set_player_privs(name, privs)
    if mustcreate == true then
      mustcreate = false
      local param1 = "mainlobby"
      local schem = minetest.get_modpath("customisations") .. "/schems/" .. param1 .. ".mts"
      minetest.place_schematic({x=-27, y=601, z=4}, schem)
    end
    minetest.after(1, function()
      if player:is_player_connected() and agreerules_accepted(name) and player_lobby[name] == "main" then
        main.open_teleporter_form(player)
	      subgames.clear_inv(player)
	      local inv = player:get_inventory()
    	  inv:add_item("main", "customisations:teleporter")
   	    sfinv.set_page(player, "main:lobbys")
      end
    end)
  end
end)

subgames.register_on_leaveplayer(function(player, lobby)
  if lobby == "main" then
  end
end)

subgames.register_on_chat_message(function(name, message, lobby)
  if lobby == "main" and name and message then
    subgames.chat_send_all_lobby("main", "<"..name.."> "..message)
    return true
  end
end)

--  Add chat system
subgames.register_on_respawnplayer(function(player, lobby)
  if lobby == "main" then
    player:set_pos(spawn)
  end
end)

subgames.register_on_drop(function(itemstack, dropper, pos, lobby)
  if lobby == "main" then
    return false
  end
end)

subgames.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, lobby)
  if lobby == "main" and player then
    return true
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

sfinv.register_page("main:lobbys", {
	title = "Lobbys",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, main.create_teleporter_form(), false)
  end,
	on_player_receive_fields = function(self, player, context, pressed)
		local name = player:get_player_name()
    if pressed.mesewars then
      subgames.change_lobby(player, "mesewars")
    elseif pressed.hiddenseeker then
      subgames.change_lobby(player, "hiddenseeker")
		elseif pressed.skywars then
      subgames.change_lobby(player, "skywars")
		elseif pressed.survivalgames then
      subgames.change_lobby(player, "survivalgames")
    end
    minetest.close_formspec(name, "")
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
