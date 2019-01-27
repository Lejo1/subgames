--  Here are all sfinv pages controlled.

sfinv.register_page("sfinv:crafting", {
	title = "Crafting",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, [[
				list[current_player;craft;1.75,0.5;3,3;]
				list[current_player;craftpreview;5.75,1.5;1,1;]
				image[4.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]
				listring[current_player;main]
				listring[current_player;craft]
				image[0,4.75;1,1;gui_hb_bg.png]
				image[1,4.75;1,1;gui_hb_bg.png]
				image[2,4.75;1,1;gui_hb_bg.png]
				image[3,4.75;1,1;gui_hb_bg.png]
				image[4,4.75;1,1;gui_hb_bg.png]
				image[5,4.75;1,1;gui_hb_bg.png]
				image[6,4.75;1,1;gui_hb_bg.png]
				image[7,4.75;1,1;gui_hb_bg.png]
			]], true)
	end,
	is_in_nav = function(self, player, context)
		local name = player:get_player_name()
    if minetest.get_player_privs(name).craft then
			return true
		end
	end
})

--  Add a sfinv page for the team selector
sfinv.register_page("subgames:team", {
	title = "Teams",
	get = function(self, player, context)
		local name = player:get_player_name()
    if player_lobby[name] == "mesewars" then
		  return sfinv.make_formspec(player, context, mesewars.create_team_form(name), false)
    else return sfinv.make_formspec(player, context, (
			"size[8,9]" ..
			"label[0,0;Teams are not available here!]"
		), false)
    end
	end,
  on_player_receive_fields = function(self, player, context, pressed)
    local name = player:get_player_name()
    mesewars.handle_teamform_input(player, pressed)
		if not pressed.quit then
			mesewars.create_team_form(name)
			sfinv.set_player_inventory_formspec(player)
		end
  end,
	is_in_nav = function(self, player, context)
		local name = player:get_player_name()
    if player_lobby[name] == "mesewars" then
			return true
		end
	end
})

--  Add a kit tab
sfinv.register_page("subgames:kits", {
	title = "Kits",
	get = function(self, player, context)
		local name = player:get_player_name()
    if player_lobby[name] == "mesewars" then
      mesewars.create_kit_form(name)
		  return sfinv.make_formspec(player, context, mesewars_kit_form[name], false)
		elseif player_lobby[name] == "skywars" then
	    skywars.create_kit_form(name)
			return sfinv.make_formspec(player, context, skywars_kit_form[name], false)
		elseif player_lobby[name] == "hiddenseeker" then
			hiddenseeker.create_kit_form(name)
			return sfinv.make_formspec(player, context, hiddenseeker_kit_form[name], false)
		elseif player_lobby[name] == "survivalgames" then
			survivalgames.create_kit_form(name)
			return sfinv.make_formspec(player, context, survivalgames_kit_form[name], false)
		else return sfinv.make_formspec(player, context, (
			"size[8,9]" ..
			"label[0,0;Kits are not available here!]"
		), false)
		end
  end,
	on_player_receive_fields = function(self, player, context, pressed)
		local name = player:get_player_name()
    if player_lobby[name] == "mesewars" then
		if pressed.buykit then
			if kits[name].buying then
				mesewars.add_player_kits(name, kits[name].buying)
			end
		end
		if pressed.kitlist then
			mesewars.set_player_kit(name, pressed.kitlist)
		end
		if pressed.buylist then
			kits[name].buying = pressed.buylist
		end
		mesewars.save_kits(name)
		mesewars.create_kit_form(name)
		sfinv.set_player_inventory_formspec(player)
    end
		skywars.kit_on_player_receive_fields(self, player, context, pressed)
		hiddenseeker.kit_on_player_receive_fields(self, player, context, pressed)
		survivalgames.kit_on_player_receive_fields(self, player, context, pressed)
	end,
	is_in_nav = function(self, player, context)
		local name = player:get_player_name()
    if player_lobby[name] ~= "main" then
			return true
		end
	end
})

--  Add a Abilitys tab
sfinv.register_page("subgames:abilitys", {
	title = "Abilities",
	get = function(self, player, context)
		local name = player:get_player_name()
    if player_lobby[name] == "mesewars" then
      mesewars.create_ability_form(player)
		  return sfinv.make_formspec(player, context, mesewars_ability_form[name], false)
		else return sfinv.make_formspec(player, context, (
			"size[8,9]" ..
			"label[0,0;Abilitys are not available here!]"
		), false)
		end
  end,
	on_player_receive_fields = function(self, player, context, pressed)
		local name = player:get_player_name()
    if player_lobby[name] == "mesewars" then
		if pressed.speedbox then
			if pressed.speedbox == "true" then kits[name].abilitys.speed.active = true else kits[name].abilitys.speed.active = false end
		elseif pressed.slownessbox then
			if pressed.slownessbox == "true" then kits[name].abilitys.slowness.active = true else kits[name].abilitys.slowness.active = false end
		elseif pressed.killkitbox then
			if pressed.killkitbox == "true" then kits[name].abilitys.killkit.active = true else kits[name].abilitys.killkit.active = false end
		elseif pressed.carefullbox then
			if pressed.carefullbox == "true" then kits[name].abilitys.carefull.active = true else kits[name].abilitys.carefull.active = false end
		elseif pressed.speed1 then
			mesewars.handle_buy(player, "speed", 1, 200)
		elseif pressed.speed2 then
			mesewars.handle_buy(player, "speed", 2, 400)
		elseif pressed.speed3 then
			mesewars.handle_buy(player, "speed", 3, 800)
		elseif pressed.speed4 then
			mesewars.handle_buy(player, "speed", 4, 1600)
		elseif pressed.speed5 then
			mesewars.handle_buy(player, "speed", 5, 3200)
		elseif pressed.slowness1 then
			mesewars.handle_buy(player, "slowness", 1, 200)
		elseif pressed.slowness2 then
			mesewars.handle_buy(player, "slowness", 2, 400)
		elseif pressed.slowness3 then
			mesewars.handle_buy(player, "slowness", 3, 800)
		elseif pressed.slowness4 then
			mesewars.handle_buy(player, "slowness", 4, 1600)
		elseif pressed.slowness5 then
			mesewars.handle_buy(player, "slowness", 5, 3200)
		elseif pressed.killkit1 then
			mesewars.handle_buy(player, "killkit", 1, 200)
		elseif pressed.killkit2 then
			mesewars.handle_buy(player, "killkit", 2, 400)
		elseif pressed.killkit3 then
			mesewars.handle_buy(player, "killkit", 3, 800)
		elseif pressed.killkit4 then
			mesewars.handle_buy(player, "killkit", 4, 1600)
		elseif pressed.killkit5 then
			mesewars.handle_buy(player, "killkit", 5, 3200)
		elseif pressed.carefull1 then
			mesewars.handle_buy(player, "carefull", 1, 200)
		elseif pressed.carefull2 then
			mesewars.handle_buy(player, "carefull", 2, 400)
		elseif pressed.carefull3 then
			mesewars.handle_buy(player, "carefull", 3, 800)
		elseif pressed.carefull4 then
			mesewars.handle_buy(player, "carefull", 4, 1600)
		elseif pressed.carefull5 then
			mesewars.handle_buy(player, "carefull", 5, 3200)
		end
		mesewars.save_kits(name)
		mesewars.create_ability_form(player)
		sfinv.set_player_inventory_formspec(player)
    end
	end,
	is_in_nav = function(self, player, context)
		local name = player:get_player_name()
    if player_lobby[name] == "mesewars" then
			return true
		end
	end
})

sfinv.register_page("subgames:lobbys", {
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

sfinv.register_page("subgames:maps", {
	title = "Maps",
	get = function(self, player, context)
		local name = player:get_player_name()
		if player_lobby[name] == "skywars" then
			return sfinv.make_formspec(player, context, skywars.create_teleporter_form(), false)
		else return sfinv.make_formspec(player, context, (
			"size[8,9]" ..
			"label[0,0;Maps are not available here!]"
		), false)
		end
  end,
	on_player_receive_fields = function(self, player, context, pressed)
		local name = player:get_player_name()
    if pressed.map1 then
      skywars.leave_game(player)
			skywars.win(skywars.player_lobby[name])
      minetest.chat_send_player(name, skywars.join_game(player, 1))
    elseif pressed.map2 then
      skywars.leave_game(player)
      minetest.chat_send_player(name, skywars.join_game(player, 2))
    end
    minetest.close_formspec(name, "")
	end,
	is_in_nav = function(self, player, context)
		local name = player:get_player_name()
    if player_lobby[name] == "skywars" then
			return true
		end
	end
})
