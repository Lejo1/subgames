Subgames
========

Contribution repository for the Minetest Server Subgames for all!

This Repository is not for using on your own Server!

Installing
----------
1. `git clone https://github.com/Lejo1/subgames.git`
2. `git submodule init`
3. `git submodule update`


License
-------

Created by [Lejo](https://github.com/Lejo1)
Code: LGPL 2.1 or later
Textures: CC-BY-SA 3.0

For the Mods: Subgames, Skywars, Hiddenseeker, Mesewars, Main, Build:

You are not allowed to distribute any copy or work based on this programm unless the copyright
holder declares his consent.
THE SOFTWARE IS PROVIDED WITHOUT WARRANTY OF ANY KIND!


Derived from [minetest_game](https://github.com/minetest/minetest_game)

API
---

The Server is splitted into diffrent lobbys.

This is saved in player_lobby[name] = "main"

All minetest registers like minetest.register_on_join_player(func(player)) are here subgames.register_on_join_player(func(player, lobby)) lobby is the name string of the Lobby where the Action happens.

But not all registers are supported yet.

Example:

subgames.register_on_join_player(function(player, lobby)
  if lobby == "main" then
    minetest.chat_send_play(player:get_player_name(), "HI")
  end
end)

IMPORTANT: Registers like on_place_node don't allways have a player!
For this a Lobby must register its location at the top of mods/subgames/init.lua

areas={
  ["mesewars"] = {
    [1] = {x=(-76), y=158, z=154},
    [2] = {x=266, y=(-52), z=(-169)}
  },
  ["main"] = {
    [1] = {x=(-31), y=623, z=0},
    [2] = {x=9, y=595, z=39}
  },
  ["hiddenseeker"] = {
    [1] = {x=0, y=(-10000), z=0},
    [2] = {x=0, y=(-10000), z=0}
  },
  ["skywars"] = {
    [1] = {x=10000, y=1900, z=10000},
    [2] = {x=(-10000), y=2900, z=(-10000)}
  }
}

The API is not finished!
