--  Add the Meseblock for all teams.

--  For Team 1
minetest.register_node("mesewars:mese1", {
  description = "Dig Me!",
  tiles = {"mese.png"},
  groups = {choppy = 2, oddly_breakable_by_hand = 2},
  drop = "",
  after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local name = digger:get_player_name()
      if table.contains(team1_players, name) == true then
        minetest.chat_send_player(name, "It's your mese!")
        minetest.set_node(pos, oldnode)
      else local msg = core.colorize("blue", "Team Blues Mese has been destroyed!")
        subgames.chat_send_all_lobby("mesewars", msg)
        for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
          subgames.add_mithud(player, "Team Blues Mese has been destroyed!", 0x0000FF, 3)
        end
        mese[1] = false
        money.set_money(name, money.get_money(name)+15)
        minetest.chat_send_player(name, "CoinSystem: You have receive 15 Coins!")
        mesewars.win()
      end
  end,
})

--  For Team 2
minetest.register_node("mesewars:mese2", {
  description = "Dig Me!",
  tiles = {"mese.png"},
  groups = {choppy = 2, oddly_breakable_by_hand = 2},
  drop = "",
  after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local name = digger:get_player_name()
      if table.contains(team2_players, name) == true then
        minetest.chat_send_player(name, "It's your mese!")
        minetest.set_node(pos, oldnode)
      else local msg = core.colorize("yellow", "Team Yellows Mese has been destroyed!")
        subgames.chat_send_all_lobby("mesewars", msg)
        for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
          subgames.add_mithud(player, "Team Yellows Mese has been destroyed!", 0xFFFF00, 3)
        end
        mese[2] = false
        money.set_money(name, money.get_money(name)+15)
        minetest.chat_send_player(name, "CoinSystem: You have receive 15 Coins!")
        mesewars.win()
      end
  end,
})

--  For Team 3
minetest.register_node("mesewars:mese3", {
  description = "Dig Me!",
  tiles = {"mese.png"},
  groups = {choppy = 2, oddly_breakable_by_hand = 2},
  drop = "",
  after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local name = digger:get_player_name()
      if table.contains(team3_players, name) == true then
        minetest.chat_send_player(name, "It's your mese!")
        minetest.set_node(pos, oldnode)
      else local msg = core.colorize("green", "Team Greens Mese has been destroyed!")
        subgames.chat_send_all_lobby("mesewars", msg)
        for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
          subgames.add_mithud(player, "Team Greens Mese has been destroyed!", 0x00FF00, 3)
        end
        mese[3] = false
        money.set_money(name, money.get_money(name)+15)
        minetest.chat_send_player(name, "CoinSystem: You have receive 15 Coins!")
        mesewars.win()
      end
  end,
})

--  For Team 4
minetest.register_node("mesewars:mese4", {
  description = "Dig Me!",
  tiles = {"mese.png"},
  groups = {choppy = 2, oddly_breakable_by_hand = 2},
  drop = "",
  after_dig_node = function(pos, oldnode, oldmetadata, digger)
    local name = digger:get_player_name()
      if table.contains(team4_players, name) == true then
        minetest.chat_send_player(name, "It's your mese!")
        minetest.set_node(pos, oldnode)
      else local msg = core.colorize("red", "Team Reds Mese has been destroyed!")
        subgames.chat_send_all_lobby("mesewars", msg)
        for _,player in ipairs(subgames.get_lobby_players("mesewars")) do
          subgames.add_mithud(player, "Team Reds Mese has been destroyed!", 0xFF0000, 3)
        end
        mese[4] = false
        money.set_money(name, money.get_money(name)+15)
        minetest.chat_send_player(name, "CoinSystem: You have receive 15 Coins!")
        mesewars.win()
      end
  end,
})
