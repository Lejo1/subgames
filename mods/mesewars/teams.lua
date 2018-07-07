--  Add a function to check if value is not nil
function table.is_not_nil(value)
  if value then
    return value
  else return ""
  end
end

-- Add a function to open the formspec.
function mesewars.create_team_form()
  mesewars_team_form = (
    "size[10,4]" ..
    "label[0,0;Select your team for the next Round! You see the joined players below the buttons.]" ..
    "button[8,0;2,1;refresh;Refresh]" ..
    "button[0,1;2,1;preteam1;Blue]" ..
    "button[2,1;2,1;preteam2;Yellow]" ..
    "button[4,1;2,1;preteam3;Green]" ..
    "button[6,1;2,1;preteam4;Red]" ..
    "button[8,1;2,1;leave;Leave]" ..
    "label[0,2.5;"..table.is_not_nil(pre1_players[1]).."]" ..
    "label[0,3;"..table.is_not_nil(pre1_players[2]).."]" ..
    "label[0,3.5;"..table.is_not_nil(pre1_players[3]).."]" ..
    "label[0,4;"..table.is_not_nil(pre1_players[4]).."]" ..
    "label[2,2.5;"..table.is_not_nil(pre2_players[1]).."]" ..
    "label[2,3;"..table.is_not_nil(pre2_players[2]).."]" ..
    "label[2,3.5;"..table.is_not_nil(pre2_players[3]).."]" ..
    "label[2,4;"..table.is_not_nil(pre2_players[4]).."]" ..
    "label[4,2.5;"..table.is_not_nil(pre3_players[1]).."]" ..
    "label[4,3;"..table.is_not_nil(pre3_players[2]).."]" ..
    "label[4,3.5;"..table.is_not_nil(pre3_players[3]).."]" ..
    "label[4,4;"..table.is_not_nil(pre3_players[4]).."]" ..
    "label[6,2.5;"..table.is_not_nil(pre4_players[1]).."]" ..
    "label[6,3;"..table.is_not_nil(pre4_players[2]).."]" ..
    "label[6,3.5;"..table.is_not_nil(pre4_players[3]).."]" ..
    "label[6,4;"..table.is_not_nil(pre4_players[4]).."]"
  )
end
function mesewars.team_form(name)
  mesewars.create_team_form()
  minetest.show_formspec(name, "mesewars:team", mesewars_team_form)
end

--  Add the team selector.
minetest.register_tool("mesewars:team", {
  description = "Chose Team",
  inventory_image = "default_paper.png",
on_use = function(itemstack, user)
  local name = user:get_player_name()
  mesewars.team_form(name)
  end
})

--  Add a command to join a team
subgames.register_chatcommand("team", {
  prams = "",
  description = "Use it to get a team selector",
  lobby = "mesewars",
  func = function(name)
    mesewars.team_form(name)
  end,
})

minetest.register_on_player_receive_fields(function(player, formname, pressed)
	if formname == "mesewars:team" then
    local name = player:get_player_name()
    if pressed["preteam1"] or pressed["preteam2"] or pressed["preteam3"] or pressed["preteam4"] then
      if true == table.contains(pre1_players, name) or true == table.contains(pre2_players, name) or true == table.contains(pre3_players, name) or true == table.contains(pre4_players, name) then
        mesewars.leave_pre_player(name)
      end
      if pressed["preteam1"] then
        if #pre1_players < player_max then
          pre1_players[#pre1_players+1] = name
          local msg = core.colorize("blue", "You are now in Team Blue")
          minetest.chat_send_player(name, msg)
          subgames.add_bothud(player, "You are now in Team Blue", 0x0000FF, 2)
        else minetest.chat_send_player(name, "The Team is full!")
        end
      elseif pressed["preteam2"] then
        if #pre2_players < player_max then
          pre2_players[#pre2_players+1] = name
          local msg = core.colorize("yellow", "You are now in Team Yellow")
          minetest.chat_send_player(name, msg)
          subgames.add_bothud(player, "You are now in Team Yellow", 0xFFFF00, 2)
        else minetest.chat_send_player(name, "The Team is full!")
        end
      elseif pressed["preteam3"] then
        if #pre3_players < player_max then
          pre3_players[#pre3_players+1] = name
          local msg = core.colorize("green", "You are now in Team Green")
          minetest.chat_send_player(name, msg)
          subgames.add_bothud(player, "You are now in Team Green", 0x00FF00, 2)
        else minetest.chat_send_player(name, "The Team is full!")
        end
      elseif pressed["preteam4"] then
        if #pre4_players < player_max then
          pre4_players[#pre4_players+1] = name
          local msg = core.colorize("red", "You are now in Team Red")
          minetest.chat_send_player(name, msg)
          subgames.add_bothud(player, "You are now in Team Red", 0xFF0000, 2)
        else minetest.chat_send_player(name, "The Team is full!")
        end
      end
      mesewars.team_form(name)
      mesewars.win()
      sfinv.set_player_inventory_formspec(player)
    elseif pressed["leave"] then
      mesewars.leave_pre_player(name)
      minetest.chat_send_player(name, "You have left your team!")
      subgames.add_bothud(player, "You have left your team!", 0xFFFFFF, 2)
      mesewars.team_form(name)
      mesewars.win()
      sfinv.set_player_inventory_formspec(player)
    elseif pressed["refresh"] then
      mesewars.team_form(name)
      sfinv.set_player_inventory_formspec(player)
    end
  end
end)

--  Add coloured names
subgames.register_on_chat_message(function(name, message, lobby)
  if lobby == "mesewars" and name and message then
    local team = mesewars.get_team(name)
    local cname = core.colorize("white", "<"..name.."> ")
    if team == "team1" then
      cname = core.colorize("blue", "<"..name.."> ")
    elseif team == "team2" then
      cname = core.colorize("yellow", "<"..name.."> ")
    elseif team == "team3" then
      cname = core.colorize("green", "<"..name.."> ")
    elseif team == "team4" then
      cname = core.colorize("red", "<"..name.."> ")
    end
    subgames.chat_send_all_lobby("mesewars", cname..message)
    return true
  end
end)
