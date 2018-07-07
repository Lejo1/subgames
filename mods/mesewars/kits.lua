--  Adds kits to mesewars
kits = {}
mesewars_kit_form = {}
mesewars_ability_form = {}
local kits_all = {}
local abilitys = {
	speed = {
		[1] = 25,
		[2] = 13,
		[3] = 9,
		[4] = 7,
		[5] = 5
	},
	slowness = {
		[1] = 25,
		[2] = 13,
		[3] = 9,
		[4] = 7,
		[5] = 5
	},
 	killkit = {
		[1] = 10,
		[2] = 5,
		[3] = 4,
		[4] = 3,
		[5] = 2
	},
	carefull = {
		[1] = 10,
		[2] = 5,
		[3] = 4,
		[4] = 3,
		[5] = 2
	}
}
local input = io.open(minetest.get_worldpath() .. "/kits", "r")
if input then
	local input2 = minetest.deserialize(input:read("*l"))
	if input2 then
		kits = input2
		io.close(input)
	end
end

function mesewars.save_kits()
	local output = io.open(minetest.get_worldpath() .. "/kits", "w")
	output:write(minetest.serialize(kits))
	io.close(output)
end

minetest.register_on_shutdown(function()
  mesewars.save_kits()
end)

--  Creates player's account, if the player doesn't have it.
subgames.register_on_joinplayer(function(player, lobby)
	if lobby == "mesewars" then
	local name = player:get_player_name()
	if name ~= "register" then
		if not kits[name] then
			kits[name] = {kit = {}}
    	mesewars.save_kits()
		end
		if not kits[name].abilitys then
			kits[name].abilitys = {}
		end
	else minetest.kick_player(name, "Sorry, but this name is disallowed.")
	end
	mesewars.create_abilitys(player)
	mesewars.save_kits()
	end
end)

function mesewars.get_player_kits(name)
  return kits[name].kit
end

function mesewars.register_kit(kitname, def)
  if not kits.register then
    kits.register = {}
  end
  kits.register[kitname] = def
  def.name = kitname
	table.insert(kits_all, kitname)
end

function mesewars.add_player_kits(name, kitname)
  local def = kits.register[kitname]
	local inserter = kits[name].kit
  if def and money.get_money(name) >= def.cost then
    if kits[name].kit == "" or not table.contains(kits[name].kit, kitname) == true then
      money.set_money(name, money.get_money(name)-def.cost)
			table.insert(kits[name].kit, kitname)
			mesewars.save_kits()
      minetest.chat_send_player(name, "You have buyed the kit " ..kitname.."!")
    else minetest.chat_send_player(name, "You already have buyed this Kit!")
    end
  else minetest.chat_send_player(name, "You don't have enough money!")
  end
end

function mesewars.set_player_kit(name, kitname)
  if kitname ~= "" and kits[name].kit ~= "" and table.contains(kits[name].kit, kitname) then
    kits[name].selected = kitname
  elseif kitname ~= "" then
		minetest.chat_send_player(name, "You don't have this kit!")
  end
end

function mesewars.give_kit_items(name)
  if kits[name].selected then
    local kitname = kits[name].selected
    local def = kits.register[kitname]
    local player = minetest.get_player_by_name(name)
    local inv = player:get_inventory()
    for _,item in ipairs(def.items) do
      if inv:room_for_item("main", item) then
        inv:add_item("main", item)
      end
    end
  end
end

--  Add a sfinv Kit Formspec
function mesewars.create_kit_form(name)
  local selected_id = 1
	local selected_buyid = 0
	local defitems = ""
	if not kits[name] then return end
	if type(kits[name].kit) == "table" and #kits[name].kit >= 1 then
  	for kitnumb,kitname in ipairs(kits[name].kit) do
    	if kitname == kits[name].selected then
      	selected_id = kitnumb
    	end
  	end
	end
	if kits[name].buying then
  	for kitnumb,kitname in ipairs(kits_all) do
    	if kitname == kits[name].buying then
      	selected_buyid = kitnumb
    	end
  	end
	end
	if kits.register[kits[name].selected] then
		local def = kits.register[kits[name].selected]
		if def.items then
			defitems = def.items
		end
	end
	local costbuy = ""
	if kits[name].buying then
		local costbuyb = kits.register[kits[name].buying]
		costbuy = costbuyb.cost
	end
	local itembuy = ""
	if kits[name].buying then
		local itembuyb = kits.register[kits[name].buying]
		itembuy = itembuyb.items
	end
  mesewars_kit_form[name] = (
  	"size[8,9]" ..
  	"label[0,0;Select your Kit!]" ..
  	"dropdown[0,0.5;8,1.5;kitlist;"..subgames.concatornil(kits[name].kit)..";"..selected_id.."]" ..
		"label[0,1.5;Items: "..subgames.concatornil(defitems).." ]" ..
		"label[0,2.5;Here you can buy your kits!]" ..
		"label[0,3;Your money: "..money.get_money(name).." Coins]" ..
		"dropdown[0,3.5;8,1.5;buylist;"..table.concat(kits_all, ",")..";"..selected_buyid.."]" ..
		"label[0,4.5;Cost: "..costbuy.."]" ..
		"label[0,5.5;Items: "..subgames.concatornil(itembuy).." ]" ..
		"button[4,4.5;3,1;buykit;Buy this Kit!]")
end

--  Grant money when kill a player
subgames.register_on_kill_player(function(killer, killed, lobby)
	if lobby == "mesewars" then
		local killedname = killed:get_player_name()
  	local killname = killer:get_player_name()
  	money.set_money(killname, money.get_money(killname)+5)
  	minetest.chat_send_player(killname, "CoinSystem: You have receive 5 Coins!")
	end
end)

--  Add some kits
mesewars.register_kit("Swordman", {
  cost = 300,
  items = {"default:sword_stone"},
})

mesewars.register_kit("Blocker", {
  cost = 1200,
  items = {"default:steelblock 3", "default:sandstone 15"},
})

mesewars.register_kit("Tank", {
  cost = 600,
  items = {"3d_armor:chestplate_wood", "3d_armor:leggings_wood", "3d_armor:helmet_wood","3d_armor:boots_wood"},
})

mesewars.register_kit("Digger", {
  cost = 500,
  items = {"default:pick_mese"},
})

mesewars.register_kit("Cactus", {
  cost = 800,
  items = {"3d_armor:chestplate_cactus", "default:sword_stone"},
})

mesewars.register_kit("Builder", {
  cost = 800,
  items = {"default:sandstone 10", "default:pick_stone"},
})

mesewars.register_kit("Killer", {
  cost = 800,
  items = {"default:sword_steel"},
})

mesewars.register_kit("Rabbit", {
  cost = 400,
  items = {"pep:jumpplus"},
})

mesewars.register_kit("Runner", {
  cost = 600,
  items = {"pep:speedplus"},
})

mesewars.register_kit("Homer", {
  cost = 500,
  items = {"mesewars:baseteleport"},
})

--  Add abilitys.
function mesewars.create_abilitys(player)
	local name = player:get_player_name()
	for key, value in pairs(abilitys) do
		if not kits[name].abilitys[key] then
			kits[name].abilitys[key] = {level = 0, active = true}
		end
		if kits[name].abilitys[key].active == nil then
			kits[name].abilitys[key].active = true
		end
	end
end

function mesewars.handle_hit(player, hitter, time_from_last_punch)
	local name = player:get_player_name()
	local hittername = hitter:get_player_name()
	if kits[hittername].abilitys.slowness.active == true and kits[hittername].abilitys.slowness.level > 0 then
		if math.random(abilitys.slowness[kits[hittername].abilitys.slowness.level]) == 1 then
			playereffects.apply_effect_type("pepspeedminus", 1, player)
		end
	end
	if kits[name].abilitys.speed.active == true and kits[name].abilitys.speed.level > 0 then
		if math.random(abilitys.speed[kits[name].abilitys.speed.level]) == 1 then
			playereffects.apply_effect_type("pepspeedplus", 3, player)
		end
	end
end

subgames.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing, lobby)
	if lobby == "mesewars" and placer then
		local name = placer:get_player_name()
		if kits[name] and kits[name].abilitys.carefull.active == true and kits[name].abilitys.carefull.level > 0 then
			if math.random(abilitys.carefull[kits[name].abilitys.carefull.level]) == 1 then
				itemstack:add_item(newnode.name)
			end
		end
	end
end)

subgames.register_on_kill_player(function(killer, killed, lobby)
	if lobby == "mesewars" then
	minetest.after(2, function()
		if killed:is_player_connected() then
			local name = killed:get_player_name()
			if kits[name].abilitys.killkit.active == true and kits[name].abilitys.killkit.level > 0 then
				if math.random(abilitys.killkit[kits[name].abilitys.killkit.level]) == 1 then
					mesewars.give_kit_items(name)
				end
			end
		end
	end)
	end
end)

local function check_active(value, number, text)
	if value >= number then
		return core.colorize("green", text)
	else return core.colorize("red", text)
	end
end

function mesewars.create_ability_form(player)
	local name = player:get_player_name()
	local speedontool
	if kits[name].abilitys.speed.active == true then
		speedontool = "Enable!"
	else speedontool = "Disable!"
	end
	local slownessontool
	if kits[name].abilitys.slowness.active == true then
		slownessontool = "Enable!"
	else slownessontool = "Disable!"
	end
	local killkitontool
	if kits[name].abilitys.killkit.active == true then
		killkitontool = "Enable!"
	else killkitontool = "Disable!"
	end
	local carefullontool
	if kits[name].abilitys.carefull.active == true then
		carefullontool = "Enable!"
	else carefullontool = "Disable!"
	end
	mesewars_ability_form[name] = (
  	"size[8,9]" ..
		"label[0,0.5;Here you can buy abilities for your money.]" ..
		"label[0,1;Your money: "..money.get_money(name).." Coins]" ..
		"image_button[1,2;1,1;pep_speedplus.png;speedon;]" ..
		"tooltip[speedon;"..speedontool.." A chance of getting speedbost when got hitted.]" ..
		"checkbox[1,3;speedbox;Active;"..tostring(kits[name].abilitys.speed.active).."]" ..
		"button[1,4;1,1;speed1;"..check_active(kits[name].abilitys.speed.level, 1, "4%").."]" ..
		"tooltip[speed1;200 Coins]" ..
		"button[1,5;1,1;speed2;"..check_active(kits[name].abilitys.speed.level, 2, "8%").."]" ..
		"tooltip[speed2;400 Coins]" ..
		"button[1,6;1,1;speed3;"..check_active(kits[name].abilitys.speed.level, 3, "12%").."]" ..
		"tooltip[speed3;800 Coins]" ..
		"button[1,7;1,1;speed4;"..check_active(kits[name].abilitys.speed.level, 4, "16%").."]" ..
		"tooltip[speed4;1600 Coins]" ..
		"button[1,8;1,1;speed5;"..check_active(kits[name].abilitys.speed.level, 5, "20%").."]" ..
		"tooltip[speed5;3200 Coins]" ..
		"image_button[2,2;1,1;pep_speedminus.png;slownesson;]" ..
		"tooltip[slownesson;"..slownessontool.." A chance of slowing your target down.]" ..
		"checkbox[2,3;slownessbox;Active;"..tostring(kits[name].abilitys.slowness.active).."]" ..
		"button[2,4;1,1;slowness1;"..check_active(kits[name].abilitys.slowness.level, 1, "4%").."]" ..
		"tooltip[slowness1;200 Coins]" ..
		"button[2,5;1,1;slowness2;"..check_active(kits[name].abilitys.slowness.level, 2, "8%").."]" ..
		"tooltip[slowness2;400 Coins]" ..
		"button[2,6;1,1;slowness3;"..check_active(kits[name].abilitys.slowness.level, 3, "12%").."]" ..
		"tooltip[slowness3;800 Coins]" ..
		"button[2,7;1,1;slowness4;"..check_active(kits[name].abilitys.slowness.level, 4, "16%").."]" ..
		"tooltip[slowness4;1600 Coins]" ..
		"button[2,8;1,1;slowness5;"..check_active(kits[name].abilitys.slowness.level, 5, "20%").."]" ..
		"tooltip[slowness5;3200 Coins]" ..
		"image_button[3,2;1,1;default_tool_steelsword.png;killkiton;]" ..
		"tooltip[killkiton;"..killkitontool.." A chance of receiving your kit when got killed.]" ..
		"checkbox[3,3;killkitbox;Active;"..tostring(kits[name].abilitys.killkit.active).."]" ..
		"button[3,4;1,1;killkit1;"..check_active(kits[name].abilitys.killkit.level, 1, "10%").."]" ..
		"tooltip[killkit1;200 Coins]" ..
		"button[3,5;1,1;killkit2;"..check_active(kits[name].abilitys.killkit.level, 2, "20%").."]" ..
		"tooltip[killkit2;400 Coins]" ..
		"button[3,6;1,1;killkit3;"..check_active(kits[name].abilitys.killkit.level, 3, "30%").."]" ..
		"tooltip[killkit3;800 Coins]" ..
		"button[3,7;1,1;killkit4;"..check_active(kits[name].abilitys.killkit.level, 4, "40%").."]" ..
		"tooltip[killkit4;1600 Coins]" ..
		"button[3,8;1,1;killkit5;"..check_active(kits[name].abilitys.killkit.level, 5, "50%").."]" ..
		"tooltip[killkit5;3200 Coins]" ..
		"item_image_button[4,2;1,1;default:sandstone;carefullon;]" ..
		"tooltip[carefullon;"..carefullontool.." A chance of don't lose your block on place.]" ..
		"checkbox[4,3;carefullbox;Active;"..tostring(kits[name].abilitys.carefull.active).."]" ..
		"button[4,4;1,1;carefull1;"..check_active(kits[name].abilitys.carefull.level, 1, "10%").."]" ..
		"tooltip[carefull1;200 Coins]" ..
		"button[4,5;1,1;carefull2;"..check_active(kits[name].abilitys.carefull.level, 2, "20%").."]" ..
		"tooltip[carefull2;400 Coins]" ..
		"button[4,6;1,1;carefull3;"..check_active(kits[name].abilitys.carefull.level, 3, "30%").."]" ..
		"tooltip[carefull3;800 Coins]" ..
		"button[4,7;1,1;carefull4;"..check_active(kits[name].abilitys.carefull.level, 4, "40%").."]" ..
		"tooltip[carefull4;1600 Coins]" ..
		"button[4,8;1,1;carefull5;"..check_active(kits[name].abilitys.carefull.level, 5, "50%").."]" ..
		"tooltip[carefull5;3200 Coins]"
	)
end

function mesewars.handle_buy(player, ability, level, cost)
	local name = player:get_player_name()
	local pmoney = money.get_money(name)
	local kitfile = kits[name].abilitys[ability]
	if kitfile.level < level then
		if kitfile.level +1 == level then
			if pmoney >= cost then
				money.set_money(name, pmoney -cost)
				kitfile.level = kitfile.level +1
				minetest.chat_send_player(name, core.colorize("green", "You have buyed Level "..level.." of the Ability "..ability))
			else minetest.chat_send_player(name, "You don't have enough money.")
			end
		else minetest.chat_send_player(name, "You first have to buy the previous Level.")
		end
	elseif kitfile.level >= level then
		minetest.chat_send_player(name, "You already buyed this Level.")
	end
end
