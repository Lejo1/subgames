--[[Add a  builder mode for builders!]]
subgames.register_on_joinplayer(function(player, lobby)
  if lobby == "build" then
    local name = player:get_player_name()
    minetest.chat_send_player(name, "You joined the builder lobby, be carefull!")
    subgames.disappear(player)
    local privs = minetest.get_player_privs(name)
    privs.interact = true
    privs.fly = true
    privs.fast = true
    privs.noclip = true
    privs.give = true
    privs.creative = true
    minetest.set_player_privs(name, privs)
  end
end)

subgames.register_on_leaveplayer(function(player, lobby)
  if lobby == "build" then
    local name = player:get_player_name()
    subgames.undisappear(player)
    local privs = minetest.get_player_privs(name)
    privs.interact = nil
    privs.fly = nil
    privs.fast = nil
    privs.noclip = nil
    privs.give = nil
    privs.creative = nil
    minetest.set_player_privs(name, privs)
  end
end)
minetest.register_chatcommand("build", {
  params = "",
  description = "Use it to join the builder lobby.",
  privs = {ban=true},
  func = function(user)
    local player = minetest.get_player_by_name(user)
    subgames.change_lobby(player, "build")
  end,
})

subgames.register_game("build", {
  fullname = "Build",
  area = {
    [1] = {x=0, y=(-10000), z=0},
    [2] = {x=0, y=(-10000), z=0}
  },
})

minetest.register_chatcommand("pinfo", {
  params = "<name>",
  description = "Get some infos of a player.",
  privs = {ban=true},
  func = function(name, param)
    if not minetest.get_player_by_name(param) then
      return false, "Player is not online"
    end
    for key, value in pairs(minetest.get_player_information(param)) do
      minetest.chat_send_player(name, tostring(key).." is "..tostring(value))
    end
  end,
})

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
  if minetest.get_player_privs(hitter:get_player_name()).ban then
    subgames.add_bothud(hitter, player:get_player_name(), 0xFFFFFF, 5)
    if player_lobby[hitter:get_player_name()] == "build" then
      return true
    end
  end
end)
