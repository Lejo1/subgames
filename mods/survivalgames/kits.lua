survivalgames_kits = {}
survivalgames_kit_form = {}
local kits_all = {}
local kits_register = {}

local storage = minetest.get_mod_storage()

function survivalgames.save_kits(name)
	if not name then
		table_to_modstorage(storage, survivalgames_kits)
	else table_to_modstorage(storage, survivalgames_kits[name], name)
	end
end

function survivalgames.load_kits(name)
	if not name then
		survivalgames_kits = modstorage_to_table(storage)
	else survivalgames_kits[name] = modstorage_to_table(storage, name)
	end
end

--  Creates player's account, if the player doesn't have it.
subgames.register_on_joinplayer(function(player, lobby)
	if lobby == "survivalgames" then
	local name = player:get_player_name()
	survivalgames.load_kits(name)
	if not survivalgames_kits[name] then
		survivalgames_kits[name] = {kit = {}}
    survivalgames.save_kits(name)
	end
	end
end)

function survivalgames.get_player_kits(name)
  return survivalgames_kits[name].kit
end

function survivalgames.register_kit(kitname, def)
  kits_register[kitname] = def
  def.name = kitname
	table.insert(kits_all, kitname)
end

function survivalgames.add_player_kits(name, kitname)
  local def = kits_register[kitname]
	if not survivalgames_kits[name].kit then survivalgames_kits[name].kit = {} end
  if def and money.get_money(name) >= def.cost then
    if survivalgames_kits[name].kit == "" or not table.contains(survivalgames_kits[name].kit, kitname) == true then
      money.set_money(name, money.get_money(name)-def.cost)
			table.insert(survivalgames_kits[name].kit, kitname)
			survivalgames.save_kits(name)
      minetest.chat_send_player(name, "You have buyed the kit " ..kitname.."!")
    else minetest.chat_send_player(name, "You already have buyed this Kit!")
    end
  else minetest.chat_send_player(name, "You don't have enough money!")
  end
end

function survivalgames.set_player_kit(name, kitname)
	if survivalgames.lobbys[survivalgames.player_lobby[name]].players[name] == true then
		minetest.chat_send_player(name, "You can't switch your kit while playing.")
	elseif kitname ~= "" and survivalgames_kits[name].kit ~= "" and table.contains(survivalgames_kits[name].kit, kitname) then
    survivalgames_kits[name].selected = kitname
  elseif kitname ~= "" then
		minetest.chat_send_player(name, "You don't have this kit!")
  end
end

function survivalgames.remove_player_kits(name)
	survivalgames.load_kits(name)
	survivalgames_kits[name] = {}
	survivalgames.save_kits(name)
end

function survivalgames.give_kit_items(name)
  if survivalgames_kits[name].selected then
    local kitname = survivalgames_kits[name].selected
    local def = kits_register[kitname]
    local player = minetest.get_player_by_name(name)
    local inv = player:get_inventory()
    for _,item in ipairs(def.items) do
      if inv:room_for_item("main", item) then
        inv:add_item("main", item)
      end
    end
		if player and kitname and kits_register[kitname] and kits_register[kitname].on_end then
			kits_register[kitname].on_start(player)
		end
  end
end

function survivalgames.end_kit(name)
	local kit = survivalgames_kits[name].selected
	local player = minetest.get_player_by_name(name)
	if player and kit and kits_register[kit] and kits_register[kit].on_end then
		kits_register[kit].on_end(player)
	end
end

--  Add a sfinv Kit Formspec
function survivalgames.create_kit_form(name)
  local selected_id = 1
	local selected_buyid = 0
	local defitems = {}
	if not survivalgames_kits[name] then return end
	if type(survivalgames_kits[name].kit) == "table" and #survivalgames_kits[name].kit >= 1 then
  	for kitnumb,kitname in ipairs(survivalgames_kits[name].kit) do
    	if kitname == survivalgames_kits[name].selected then
      	selected_id = kitnumb
    	end
  	end
	end
	if survivalgames_kits[name].buying then
  	for kitnumb,kitname in ipairs(kits_all) do
    	if kitname == survivalgames_kits[name].buying then
      	selected_buyid = kitnumb
    	end
  	end
	end
	if kits_register[survivalgames_kits[name].selected] then
		local def = kits_register[survivalgames_kits[name].selected]
		if def.items then
			defitems = def.items
		end
	end
	local costbuy = ""
	if survivalgames_kits[name].buying then
		local costbuyb = kits_register[survivalgames_kits[name].buying]
		costbuy = costbuyb.cost
	end
	local itembuy = {}
	if survivalgames_kits[name].buying then
		local itembuyb = kits_register[survivalgames_kits[name].buying]
		itembuy = itembuyb.items
	end
	local defeffect = ""
	if kits_register[survivalgames_kits[name].selected] then
		local def = kits_register[survivalgames_kits[name].selected]
		if def.effect then
			defeffect = def.effect
		end
	end
	local effectbuy = ""
	if survivalgames_kits[name].buying then
		local def = kits_register[survivalgames_kits[name].buying]
		if def.effect then
			effectbuy = def.effect
		end
	end
  survivalgames_kit_form[name] = (
  	"size[8,9]" ..
  	"label[0,0;Select your Kit!]" ..
  	"dropdown[0,0.5;8,1.5;kitlist;"..subgames.concatornil(survivalgames_kits[name].kit)..";"..selected_id.."]" ..
		"label[0,1.5;Items: "..subgames.concatornil(defitems).."]" ..
		"label[0,2;Effect: "..defeffect.."]" ..
		"label[0,2.5;Here you can buy your kits!]" ..
		"label[0,3;Your money: "..money.get_money(name).." Coins]" ..
		"dropdown[0,3.5;8,1.5;buylist;"..table.concat(kits_all, ",")..";"..selected_buyid.."]" ..
		"label[0,4.5;Cost: "..costbuy.."]" ..
		"label[0,5.5;Items: "..subgames.concatornil(itembuy).."]" ..
		"label[0,6;Effect: "..effectbuy.."]" ..
		"button[4,4.5;3,1;buykit;Buy this Kit!]")
end

--  Grant money when kill a player
subgames.register_on_kill_player(function(killer, killed, lobby)
	if lobby == "survivalgames" then
		local killedname = killed:get_player_name()
  	local killname = killer:get_player_name()
  	money.set_money(killname, money.get_money(killname)+5)
  	minetest.chat_send_player(killname, "CoinSystem: You have receive 5 Coins!")
		if survivalgames_kits[killname].selected == "Vampire" then
			killer:set_hp(20)
		end
	end
end)

function survivalgames.kit_on_player_receive_fields(self, player, context, pressed)
  local name = player:get_player_name()
  if player_lobby[name] == "survivalgames" then
  if pressed.buykit then
    if survivalgames_kits[name].buying then
      survivalgames.add_player_kits(name, survivalgames_kits[name].buying)
    end
  end
  if pressed.kitlist then
    survivalgames.set_player_kit(name, pressed.kitlist)
  end
  if pressed.buylist then
    survivalgames_kits[name].buying = pressed.buylist
  end
  survivalgames.save_kits(name)
  survivalgames.create_kit_form(name)
  sfinv.set_player_inventory_formspec(player)
  end
end

survivalgames.register_kit("Scaredy cat", {
  cost = 700,
	effect = "You are faster when you get damage",
  items = {},
})

survivalgames.register_kit("Sonic", {
  cost = 800,
  items = {},
	effect = "You have a higher speed",
	on_start = function(player)
		player:set_physics_override({speed=1.5})
	end,
	on_end = function(player)
		player:set_physics_override({speed=1})
	end
})

survivalgames.register_kit("Bomber", {
  cost = 600,
  items = {"tnt:tnt_burning 20"},
	effect = "None"
})

function survivalgames.handle_hit(player, hitter, time_from_last_punch)
	local name = player:get_player_name()
	if survivalgames_kits[name].selected == "Scaredy cat" then
		player:set_physics_override({speed=3})
		minetest.after(5, function()
			player:set_physics_override({speed=1})
		end)
	end
end

survivalgames.register_kit("Archer", {
  cost = 400,
  items = {"bow:bow", "bow:arrow 20"},
	effect = "None"
})

survivalgames.register_kit("Vampire", {
  cost = 1000,
  items = {},
	effect = "You get full heal when you kill a player",
})

--[[
List of all Kits:
Link:
Mehr kills mehr Herzen

Techniker.
Mehr kills bessere Rüstung

Angsthase:
Schaden Speed

(Vogel)
Jumppad Falschirm

Bomber:
TNT
Landmine

Teleporter
Enderperle

Vampir.
Kill volle Herzen

(Animal)
You desquise to the animal you kill

Sonic
Dauerhaft schneller

]]
