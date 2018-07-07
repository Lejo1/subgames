--  Teleport the player on join to the lobby.
subgames.register_on_joinplayer(function(name, lobby)
  if lobby == "mesewars" then
    local spawn = minetest.setting_get_pos("spawn_lobby")
    local pname = name:get_player_name()
    name:setpos(spawn)
    subgames.chat_send_all_lobby("mesewars", "*** "..pname.." joined Mesewars.")
    minetest.after(2, function()
      if player_lobby[pname] == "mesewars" then
        mesewars.color_tag(name)
        mesewars.to_lobby(name)
        subgames.clear_inv(name)
        subgames.add_mithud(name, "Mesewars is a Game like Eggwars", 0xFFFFFF, 3)
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
            if map_must_create == true then
              map_must_create = false
              minetest.after(5, function()
                minetest.chat_send_all("Creating Mesewars Map please don't leave!")
                local param1 = "submese"
                local schem = minetest.get_worldpath() .. "/schems/" .. param1 .. ".mts"
                local vm = minetest.get_voxel_manip()
                vm:read_from_map(minetest.setting_get_pos("mappos1"), minetest.setting_get_pos("mappos2"))
                minetest.place_schematic_on_vmanip(vm, schemp, schem)
                vm:write_to_map()
              end)
            end
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
    subgames.chat_send_all_lobby("mesewars", "*** "..name.." left Mesewars.")
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
