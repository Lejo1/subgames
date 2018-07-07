subgames_spectate = {}
subgames_spectate={time=0,armor=minetest.get_modpath("3d_armor")}

--  Add the spectator mode.
function subgames.disappear(player) --  As ObjectRef
  local name = player:get_player_name()
  if not subgames_spectate[name] then
    player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
    subgames_spectate[name]={}
	  subgames_spectate[name].visual_size=player:get_properties().visual_size
	  subgames_spectate[name].textures=player:get_properties().textures
	  player:set_properties({
		 visual = "mesh",
		 textures={"invisible_skin.png"},
		 visual_size = {x=0, y=0},
		 collisionbox = {0,0,0, 0,0,0},
	  })
  end
end

function subgames.undisappear(player) --  As ObjectRef
  local name = player:get_player_name()
  if subgames_spectate[name] then
    player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
  	player:set_properties({
		 visual = "mesh",
	   textures=subgames_spectate[name].textures,
		 visual_size = subgames_spectate[name].visual_size,
		 collisionbox= {-0.3,-1,-0.3, 0.3,1,0.3},
	  })
	  subgames_spectate[name]=nil
	  if subgames_spectate.armor then
      armor:set_player_armor(player)
		  armor:update_inventory(player)
	  end
  end
end

function subgames.spectate(player)
  local name = player:get_player_name()
  if not subgames_spectate[name] then
    subgames.disappear(player)
    local privs = minetest.get_player_privs(name)
    privs.interact = nil
    privs.fly = true
    privs.fast = true
    privs.noclip = true
    minetest.set_player_privs(name, privs)
  end
end

function subgames.unspectate(player)
  local name = player:get_player_name()
  if subgames_spectate[name] then
    subgames.undisappear(player)
    local privs = minetest.get_player_privs(name)
    privs.interact = true
    privs.fly = nil
    privs.fast = nil
    privs.noclip = nil
    minetest.set_player_privs(name, privs)
  end
end

minetest.register_chatcommand("w", {
  params = "<name>",
  description = "Use it to get the Lobby where a player is.",
  func = function(user, param)
    local player = minetest.get_player_by_name(param)
    if player then
      minetest.chat_send_player(user, "The player "..param.." is in the Lobby "..player_lobby[param]..".")
    else minetest.chat_send_player(user, "The player is not online")
    end
  end,
})

function subgames.add_armor(player, stack1, stack2, stack3, stack4, stack5)
  if stack1 then
    armor:set_inventory_stack(player, 1, stack1)
    armor:run_callbacks("on_equip", player, 1, stack1)
  end
  if stack2 then
    armor:set_inventory_stack(player, 2, stack2)
    armor:run_callbacks("on_equip", player, 2, stack2)
  end
  if stack3 then
    armor:set_inventory_stack(player, 3, stack3)
    armor:run_callbacks("on_equip", player, 3, stack3)
  end
  if stack4 then
    armor:set_inventory_stack(player, 4, stack4)
    armor:run_callbacks("on_equip", player, 4, stack4)
  end
  if stack5 then
    armor:set_inventory_stack(player, 5, stack5)
    armor:run_callbacks("on_equip", player, 5, stack5)
  end
  armor:set_player_armor(player)
end
