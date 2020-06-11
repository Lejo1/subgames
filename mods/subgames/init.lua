--  This is the controll mod of Subgames for all!
subgames = {}

player_lobby = {}
subgames.games = {}
subgames.areas={
  ["mesewars"] = {
    [1] = {x=(-700), y=1000, z=-700},
    [2] = {x=75, y=1302, z=(-17)}
  },
  ["main"] = {
    [1] = {x=(-31), y=623, z=0},
    [2] = {x=9, y=595, z=39}
  },
  ["hiddenseeker"] = {
    [1] = {x=0, y=(-10000), z=0},
    [2] = {x=0, y=(-10000), z=0}
  },
  ["build"] = {
    [1] = {x=0, y=(-10000), z=0},
    [2] = {x=0, y=(-10000), z=0}
  },
  ["skywars"] = {
    [1] = {x=10000, y=1900, z=10000},
    [2] = {x=(-10000), y=2900, z=(-10000)}
  },
  ["survivalgames"] = {
    [1] = {x=31000, y=-50, z=31000},
    [2] = {x=(-31000), y=110, z=(-31000)}
  }
}

dofile(minetest.get_modpath("subgames") .."/spectator.lua")
dofile(minetest.get_modpath("subgames") .."/hud.lua")
dofile(minetest.get_modpath("subgames") .."/sfinv.lua")
dofile(minetest.get_modpath("subgames") .."/functions.lua")
dofile(minetest.get_modpath("subgames") .."/map.lua")

--[[
Def should be:
{
fullname = "Mesewars"
object = mesewars
area = {
  [1] = {x=(-700), y=1000, z=-700},
  [2] = {x=75, y=1302, z=(-17)}
}

optional...
node_dig = function(pos, node, digger)
item_place_node = function(itemstack, placer, pointed_thing, param2)
drop = function(pos, itemname, player)
remove_player = function(name)
}

]]
function subgames.register_game(name, def)
  def.name = name
  subgames.games[name] = def
end

--  Add a register on chat message (name, message)
subgames.on_chat_message = {}
function subgames.register_on_chat_message(func)
  table.insert(subgames.on_chat_message, func)
end

minetest.register_on_chat_message(function(name, message)
  minetest.log("action", "Chatlog: "..name.." wrote:"..message)
  local toreturn = nil
  for _, value in pairs(subgames.on_chat_message) do
    if value(name, message, player_lobby[name]) == true then
      toreturn = true
    end
  end
  return toreturn
end)

--  Add a register on dieplayer (player)
subgames.on_dieplayer = {}
function subgames.register_on_dieplayer(func)
  table.insert(subgames.on_dieplayer, func)
end

minetest.register_on_dieplayer(function(player)
  local name = player:get_player_name()
  for _, value in pairs(subgames.on_dieplayer) do
    value(player, player_lobby[name])
  end
end)

local death = {}
local redeath = {}

--  Add a register on kill player (killer, killed)
subgames.on_kill_player = {}
function subgames.register_on_kill_player(func)
  table.insert(subgames.on_kill_player, func)
end

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
  if player and hitter then
    local name = player:get_player_name()
    if player:get_hp() - damage <= 0 and not death[name] then
  		death[name] = true
      if damage <= 0 then
        return true
      end
      local killname = hitter:get_player_name()
      if player_lobby[name] == player_lobby[killname] then
        for _, func in pairs(subgames.on_kill_player) do
          func(hitter, player, player_lobby[name])
        end
      else minetest.kick_player(name)
        minetest.kick_player(killname)
      end
    end
  end
end)

--  Add a register on respawn player (player)
subgames.on_respawnplayer = {}
function subgames.register_on_respawnplayer(func)
  table.insert(subgames.on_respawnplayer, func)
end

minetest.register_on_respawnplayer(function(player)
  local name = player:get_player_name()
  death[name] = nil
  redeath[name] = nil
  for _, value in pairs(subgames.on_respawnplayer) do
    value(player, player_lobby[name])
  end
end)

--  Add a register on dig node (pos, oldnode, digger)
subgames.on_dignode = {}
function subgames.register_on_dignode(func)
  table.insert(subgames.on_dignode, func)
end

minetest.register_on_dignode(function(pos, oldnode, digger)
  if digger and digger:is_player() then
    local name = digger:get_player_name()
    for _, value in pairs(subgames.on_dignode) do
      value(pos, oldnode, digger, player_lobby[name])
    end
  end
end)

local old_node_dig = minetest.node_dig
function minetest.node_dig(pos, node, digger)
  local lobby
  if digger then
    local name = digger:get_player_name()
    lobby = player_lobby[name]
  else lobby = subgames.get_lobby_from_pos(pos)
  end
  if not lobby then return end
  if subgames.games[lobby].node_dig then
    local result = subgames.games[lobby].node_dig(pos, node, digger)
    if result == true then
      return old_node_dig(pos, node, digger)
    else return
    end
  else return old_node_dig(pos, node, digger)
  end
end

--  Add a register on place node (pos, newnode, placer, oldnode, itemstack, pointed_thing)
subgames.on_placenode = {}
function subgames.register_on_placenode(func)
  table.insert(subgames.on_placenode, func)
end

local placing = {}
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
  local rlname = ""
  if placer and placer:is_player() then
    local name = placer:get_player_name()
    rlname = player_lobby[name]
  else
    rlname = subgames.get_lobby_from_pos(pos)
  end
  local toreturn
  for _,value in pairs(subgames.on_placenode) do
    if value(pos, newnode, placer, oldnode, itemstack, pointed_thing, rlname) == true then
      toreturn = true
    end
  end
  return toreturn
end)

local old_node_place = minetest.item_place_node
function minetest.item_place_node(itemstack, placer, pointed_thing, param2)
  local lobby
  if placer then
    local name = placer:get_player_name()
    lobby = player_lobby[name]
  else local pos = minetest.get_pointed_thing_position(pointed_thing, false)
    lobby = subgames.get_lobby_from_pos(pos)
  end
  if not lobby then return end
  if subgames.games[lobby].item_place_node then
    local result = subgames.games[lobby].item_place_node(itemstack, placer, pointed_thing, param2)
    if result == true then
      return old_node_place(itemstack, placer, pointed_thing, param2)
    else return
    end
  else return old_node_place(itemstack, placer, pointed_thing, param2)
  end
end

--  Add a register on punchplayer (player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
subgames.on_punchplayer = {}
function subgames.register_on_punchplayer(func)
  table.insert(subgames.on_punchplayer, func)
end

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
  if player and hitter then
    local name = player:get_player_name()
    local killname = hitter:get_player_name()
    local to_return = nil
    if player_lobby[name] == player_lobby[killname] then
      for _, func in pairs(subgames.on_punchplayer) do
        if func(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, player_lobby[name]) then
          to_return = true
        end
      end
    end
    return to_return
  end
end)

--  Add a register on join player (player)
subgames.on_joinplayer = {}
function subgames.register_on_joinplayer(func)
  table.insert(subgames.on_joinplayer, func)
end

function subgames.call_join_callbacks(player, lobby)
  local name = player:get_player_name()
  player_lobby[name] = lobby
  subgames.clear_inv(player)
  sfinv.set_page(player, "3d_armor:armor")
  local privs = minetest.get_player_privs(name)
  privs.armor = true
  privs.craft = nil
  minetest.set_player_privs(name, privs)
  sfinv.set_player_inventory_formspec(player)
  for _,value in pairs(subgames.on_joinplayer) do
    value(player, lobby)
  end
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

--  Add a register on leave player (player)
subgames.on_leaveplayer = {}
function subgames.register_on_leaveplayer(func)
  table.insert(subgames.on_leaveplayer, func)
end

function subgames.call_leave_callbacks(player)
  local name = player:get_player_name()
  for _,value in pairs(subgames.on_leaveplayer) do
    value(player, player_lobby[name])
  end
  player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
  subgames.unspectate(player)
  player_lobby[name] = nil
end

minetest.register_on_leaveplayer(function(player)
  subgames.call_leave_callbacks(player)
end)

--  Add auto respawn
minetest.register_on_dieplayer(function(player)
  local name = player:get_player_name()
  if redeath[name] then return end
  redeath[name] = true
  minetest.after(0.5, function()
    if player:is_player_connected() == true then
	    minetest.close_formspec(name, "")
      player:set_hp(20)
      death[name] = nil
      redeath[name] = nil
      for _,value in pairs(subgames.on_respawnplayer) do
        value(player, player_lobby[name])
      end
    end
  end)
end)

--  Add a special command register
subgames.registered_chatcommands = {}
function subgames.handle_command_func(name, param, cname)
  local lobby = player_lobby[name]
  if subgames.registered_chatcommands[lobby] then
    local todo = subgames.registered_chatcommands[lobby][cname]
    if todo then
      todo(name, param)
    end
  end
end

function subgames.register_chatcommand(cname, def)
  if not subgames.registered_chatcommands[def.lobby] then
    subgames.registered_chatcommands[def.lobby] = {}
  end
  subgames.registered_chatcommands[def.lobby][cname]=def.func
  if not minetest.registered_chatcommands[cname] then
    minetest.register_chatcommand(cname, {
	     params = def.params,
	     description = def.description,
       privs = def.privs,
	     func = function(name, param)
         subgames.handle_command_func(name, param, cname)
       end,
    })
  end
end


--  Add a register on item eat (hp_change, replace_with_item, itemstack, user, pointed_thing)
subgames.on_item_eat = {}
function subgames.register_on_item_eat(func)
  table.insert(subgames.on_item_eat, func)
end

minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
  local name = user:get_player_name()
  for _,value in pairs(subgames.on_item_eat) do
    value(hp_change, replace_with_item, itemstack, user, pointed_thing, player_lobby[name])
  end
end)

--  Add a register on punch node (pos, node, puncher, pointed_thing)
subgames.on_punchnode = {}
function subgames.register_on_punchnode(func)
  table.insert(subgames.on_punchnode, func)
end

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
  local name = puncher:get_player_name()
  for _,value in pairs(subgames.on_punchnode) do
    value(pos, node, puncher, pointed_thing, player_lobby[name])
  end
end)

--  Add a register on drop (itemstack, dropper, pos)
subgames.on_drop = {}
function subgames.register_on_drop(func)
  table.insert(subgames.on_drop, func)
end
local dropfuncs = {}

function subgames.handle_drop(itemstack, dropper, pos)
  if dropper and dropper:is_player() then
    local name = dropper:get_player_name()
    local lobby = player_lobby[name]
    local todrop = true
    for _,value in pairs(subgames.on_drop) do
      if value(itemstack, dropper, pos, lobby) == false then
        todrop = false
      end
    end
    if todrop then
      if dropfuncs[itemstack:get_name()] then
        return dropfuncs[itemstack:get_name()](itemstack, dropper, pos)
      else minetest.item_drop(itemstack, dropper, pos)
        return itemstack:take_item()
      end
    end
  end
end

function subgames.check_drop(pos, itemname, player)
  local name = player:get_player_name()
  local lobby = player_lobby[name]
  if not lobby then
    lobby = subgames.get_lobby_from_pos(pos)
    if not lobby then
      return false
    end
  end
  local func = subgames.games[lobby].drop
  if not func then
    return false
  else return func(pos, itemname, player)
  end
end

minetest.override_item("tnt:tnt_burning", {description="TNT"})

--  Register on blas (pos, intensity)
subgames.on_blast = {}
function subgames.register_on_blast(func)
  table.insert(subgames.on_blast, func)
end
local blastfuncs = {}

function subgames.handle_blast(pos, intensity)
  local lobby = subgames.get_lobby_from_pos(pos)
  if lobby then
    local toblast = true
    for _,value in pairs(subgames.on_blast) do
      if value(pos, intensity, lobby) == false then
        toblast = false
      end
    end
    if toblast then
      if blastfuncs[minetest.get_node(pos).name] then
        blastfuncs[minetest.get_node(pos).name](pos, intensity)
      else minetest.remove_node(pos)
      end
    end
  end
end

minetest.after(1, function()
  for name, def in pairs(minetest.registered_items) do
    if def.on_drop then
      dropfuncs[name] = def.on_drop
    end
    minetest.override_item(name, {on_drop=subgames.handle_drop})
  end
  for name, def in pairs(minetest.registered_nodes) do
    if def.on_blast then
      blastfuncs[name] = def.on_blast
    end
    minetest.override_item(name, {on_blast=subgames.handle_blast})
  end
end)

minetest.register_privilege("craft", "Allows you to craft items.")
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
  local name = player:get_player_name()
  if not minetest.get_player_privs(name).craft then
    return ""
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
