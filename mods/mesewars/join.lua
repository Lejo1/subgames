--  Teleport the player on join to the lobby.
subgames.register_on_joinplayer(function(name, lobby)
  if lobby == "mesewars" then
    local spawn = minetest.setting_get_pos("spawn_lobby")
    local pname = name:get_player_name()
    name:setpos(spawn)
    if map_must_create == true then
      map_must_create = false
      local param1 = "newmese2"
      local schem = minetest.get_worldpath() .. "/schems/" .. param1 .. ".mts"
      minetest.place_schematic(schemp, schem)
    end
    minetest.after(2, function()
      if player_lobby[pname] == "mesewars" then
        mesewars.color_tag(name)
        mesewars.to_lobby(name)
        subgames.clear_inv(name)
        subgames.add_mithud(name, "Mesewars is a Game like Eggwars. Map made by Sontrunks!", 0xFFFFFF, 3)
        sfinv.set_page(name, "subgames:team")
        local inv = name:get_inventory()
        inv:add_item('main', 'mesewars:team')
        minetest.after(2, function()
          if player_lobby[pname] == "mesewars" then
            subgames.add_bothud(name, "Use /team to join a specific team", 0xFFFFFF, 3)
            local msg = core.colorize("orange", "Use /team to join a specific team")
            minetest.chat_send_player(pname, msg)
            if minetest.get_player_privs(pname).shout then
              mesewars.team_form(pname)
            end
            mesewars.win()
          end
        end)
      end
    end)
  end
end)

--  Delet the left player out of the team.
subgames.register_on_leaveplayer(function(player, lobby)
  if lobby == "mesewars" then
    local name = player:get_player_name()
    mesewars.leave_pre_player(name)
    mesewars.leave_player(player)
    minetest.after(2, function()
      mesewars.win()
    end)
  end
end)

--  Delet items on dieplayer
subgames.register_on_dieplayer(function(player, lobby)
  if lobby == "mesewars" then
    subgames.clear_inv(player)
  end
end)