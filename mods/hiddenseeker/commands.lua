--  Add a to get to dide and seek
minetest.register_chatcommand("hide", {
  params = " and seek!",
  description = "Use it to get to Hide and Seek!",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    subgames.change_lobby(player, "hiddenseeker")
  end,
})

--  Add a leave command to leave the Game.
subgames.register_chatcommand("leave", {
  params = "",
  description = "Use it to leave the Game!",
  lobby = "hiddenseeker",
  func = function(user)
    local player = minetest.get_player_by_name(user)
    if player then
      hiddenseeker.leave_game(player)
      hiddenseeker.win(hiddenseeker.player_lobby[user])
      hiddenseeker.join_game(player, hiddenseeker.player_lobby[user])
      minetest.chat_send_player(user, "You have left the Game!")
    end

  end,
})

--  Add a command to let others leave.
subgames.register_chatcommand("letleave", {
	privs = {ban=true},
	params = "<name>",
	description = "Use it ...",
  lobby = "hiddenseeker",
	func = function(name, param)
    local player = minetest.get_player_by_name(param)
		if player then
      hiddenseeker.leave_game(player)
      hiddenseeker.win(hiddenseeker.player_lobby[param])
      hiddenseeker.join_game(player, hiddenseeker.player_lobby[param])
      minetest.chat_send_player(name, "You have left the player "..param)
    else minetest.chat_send_player(name, "The player is not online!")
    end
	end,
})

--  Add a root start command
subgames.register_chatcommand("restart", {
  params = "",
  description = "Admin command to restart the Game maualy!",
  privs = {kick = true},
  lobby = "hiddenseeker",
  func = function(name)
    local msg = core.colorize("red", "Restarting Game (by " .. name .. ")")
    local lobby = hiddenseeker.player_lobby[name]
    hiddenseeker.chat_send_all_lobby(lobby, msg)
    for _,player in ipairs(hiddenseeker.get_lobby_players(lobby)) do
      hiddenseeker.leave_game(player)
      hiddenseeker.join_game(player, lobby)
    end
    hiddenseeker.win(lobby)
  end,
})

subgames.register_chatcommand("reset", {
  params = "",
  description = "Use it to reset the full Map!",
  privs = {ban = true},
  lobby = "hiddenseeker",
  func = function(player)
    minetest.chat_send_all("Creating hide and seek map, may lag.")
    minetest.after(1, function()
      local param1 = hiddenseeker.lobbys[hiddenseeker.player_lobby[player]].schem
      local schemp = hiddenseeker.lobbys[hiddenseeker.player_lobby[player]].schempos
      local schem = minetest.get_worldpath() .. "/schems/" .. param1 .. ".mts"
      minetest.place_schematic(schemp, schem)
    end)
  end,
})

-- Handles rotation Copy from screwdriver in minetest_game
local rotateblock = {}
local facedir_tbl = {
	[1] = {
		[0] = 1, [1] = 2, [2] = 3, [3] = 0,
		[4] = 5, [5] = 6, [6] = 7, [7] = 4,
		[8] = 9, [9] = 10, [10] = 11, [11] = 8,
		[12] = 13, [13] = 14, [14] = 15, [15] = 12,
		[16] = 17, [17] = 18, [18] = 19, [19] = 16,
		[20] = 21, [21] = 22, [22] = 23, [23] = 20,
	},
	[2] = {
		[0] = 4, [1] = 4, [2] = 4, [3] = 4,
		[4] = 8, [5] = 8, [6] = 8, [7] = 8,
		[8] = 12, [9] = 12, [10] = 12, [11] = 12,
		[12] = 16, [13] = 16, [14] = 16, [15] = 16,
		[16] = 20, [17] = 20, [18] = 20, [19] = 20,
		[20] = 0, [21] = 0, [22] = 0, [23] = 0,
	},
}
rotateblock.facedir = function(pos, node, mode)
	local rotation = node.param2 % 32 -- get first 5 bits
	local other = node.param2 - rotation
	rotation = facedir_tbl[mode][rotation] or 0
	return rotation + other
end

rotateblock.colorfacedir = rotateblock.facedir

local handle_rotate = function(pos)
  local mode = 1
  local uses = 200
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if not ndef then
		return itemstackups
	end
	-- can we rotate this paramtype2?
	local fn = rotateblock[ndef.paramtype2]
	if not fn and not ndef.on_rotate then
		return itemstackups
	end

	local new_param2
	if fn then
		new_param2 = fn(pos, node, mode)
	else
		new_param2 = node.param2
	end
  node.param2 = new_param2
  minetest.swap_node(pos, node)
end

function hiddenseeker.rotate_block(player)
  local name = player:get_player_name()
  if hiddenseeker.disguis[name] and hiddenseeker.disguis[name].enable then
    handle_rotate(minetest.string_to_pos(hiddenseeker.disguis[name].pos))
    minetest.chat_send_player(name, "Rotated your block!")
  else minetest.chat_send_player(name, "You are not disguised!")
  end
end

minetest.register_tool("hiddenseeker:rotate", {
  description = "Block Rotater",
	inventory_image = "rotate.png",
	on_use = function(itemstack, user, pointed_thing)
    hiddenseeker.rotate_block(user)
  end,
  on_secondary_use = function(itemstack, user, pointed_thing)
    hiddenseeker.rotate_block(user)
  end,
})
