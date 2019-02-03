--[[  Color the Names of the team players.
      team1 = blue
      team2 = yellow
      team3 = green
      team4 = red
]]

function mesewars.get_color_from_team(teamnumb)
  if teamnumb == 1 then
    return "blue"
  elseif teamnumb == 2 then
    return "yellow"
  elseif teamnumb == 3 then
    return "green"
  elseif teamnumb == 4 then
    return "red"
  else return "white"
  end
end

function mesewars.get_hex_from_team(teamnumb)
  if teamnumb == 1 then
    return 0x0000FF
  elseif teamnumb == 2 then
    return 0xFFFF00
  elseif teamnumb == 3 then
    return 0x00FF00
  elseif teamnumb == 4 then
    return 0xFF0000
  else return 0xFFAE19
  end
end

function mesewars.get_rgb_from_team(teamnumb)
  if teamnumb == 1 then
    return {r = 0, g = 0, b = 255}
  elseif teamnumb == 2 then
    return {r = 255, g = 255, b = 0}
  elseif teamnumb == 3 then
    return {r = 0, g = 255, b = 0}
  elseif teamnumb == 4 then
    return {r = 255, g = 0, b = 0}
  else return {r = 255, g = 255, b = 255}
  end
end

function mesewars.color_tag(player)
  local name = player:get_player_name()
  local lobby = mesewars.player_lobby[name]
  local team = mesewars.lobbys[lobby].players[name]
  player:set_nametag_attributes({color=mesewars.get_rgb_from_team(team)})
end
