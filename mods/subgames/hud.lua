--  Add a function to add a hud in the Middle
local mithuds = {}
function subgames.add_mithud(player, text, color, time)
  local mitinput = {}
  local name = player:get_player_name()
  if mithuds[name] then
    player:hud_remove(mithuds[name].id)
    mithuds[name] = nil
  end
  local input = {
      hud_elem_type = "text",
      position = {x=0.5,y=0.5},
      scale = {x=100,y=50},
      text = text,
      number = color,
      alignment = {x=0,y=1},
      offset = {x=0, y=-32}}
  mitinput = player:hud_add(input)
  mithuds[name] = {}
  mithuds[name].table = input
  mithuds[name].id = mitinput
  minetest.after(time, function()
    if mithuds[name] and mithuds[name].table == input then
      player:hud_remove(mitinput)
      mithuds[name] = nil
    end
  end)
end

--  Add a function to add a hud at the bottem
local bothuds = {}
function subgames.add_bothud(player, text, color, time)
  local botinput = {}
  local name = player:get_player_name()
  if bothuds[name] then
    player:hud_remove(bothuds[name].id)
    bothuds[name] = nil
  end
  local input = {
    hud_elem_type = "text",
    position = {x=0.5,y=0.9},
    scale = {x=100,y=50},
    text = text,
    number = color,
    alignment = {x=0,y=1},
    offset = {x=0, y=-32}}
  botinput = player:hud_add(input)
  bothuds[name] = {}
  bothuds[name].table = input
  bothuds[name].id = botinput
  minetest.after(time, function()
    if bothuds[name] and bothuds[name].table == input then
      player:hud_remove(botinput)
      bothuds[name] = nil
    end
  end)
end
