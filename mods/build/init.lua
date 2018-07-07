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

minetest.register_privilege("invs", "Allows you to be fully invisible!")

function core.send_join_message(name)
  if not minetest.get_player_privs(name).invs then
    minetest.chat_send_all("*** "..name.." joined the game.")
  end
end

function core.send_leave_message(name, timed_out)
  if not minetest.get_player_privs(name).invs then
    if not timed_out then
      minetest.chat_send_all("*** "..name.." left the game.")
    else minetest.chat_send_all("*** "..name.." left the game. (timed out)")
    end
  end
end

minetest.register_chatcommand("pinfo", {
  params = "<name>",
  description = "Get some infos of a player.",
  privs = {ban=true},
  func = function(name)
    for key, value in pairs(minetest.get_player_information(name)) do
      minetest.chat_send_player(name, tostring(key).." is "..tostring(value))
    end
  end,
})
