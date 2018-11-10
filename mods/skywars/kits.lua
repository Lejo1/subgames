skywars_kits = {}
skywars_kit_form = {}
skywars_ability_form = {}
local kits_all = {}
local kits_register = {}


local storage = minetest.get_mod_storage()

function skywars.save_kits(name)
	if not name then
		table_to_modstorage(storage, skywars_kits)
	else table_to_modstorage(storage, skywars_kits[name], name)
	end
end

function skywars.load_kits(name)
	if not name then
		skywars_kits = modstorage_to_table(storage)
	else skywars_kits[name] = modstorage_to_table(storage, name)
	end
end

--  Creates player's account, if the player doesn't have it.
subgames.register_on_joinplayer(function(player, lobby)
	if lobby == "skywars" then
	local name = player:get_player_name()
	skywars.load_kits(name)
	if not skywars_kits[name] then
		skywars_kits[name] = {kit = {}}
	end
	skywars.save_kits(name)
	end
end)

function skywars.get_player_kits(name)
  return skywars_kits[name].kit
end

function skywars.register_kit(kitname, def)
  kits_register[kitname] = def
  def.name = kitname
	table.insert(kits_all, kitname)
end

function skywars.add_player_kits(name, kitname)
  local def = kits_register[kitname]
	if not skywars_kits[name].kit then skywars_kits[name].kit = {} end
  if def and money.get_money(name) >= def.cost then
    if skywars_kits[name].kit == "" or not table.contains(skywars_kits[name].kit, kitname) == true then
      money.set_money(name, money.get_money(name)-def.cost)
			table.insert(skywars_kits[name].kit, kitname)
			skywars.save_kits(name)
      minetest.chat_send_player(name, "You have buyed the kit " ..kitname.."!")
    else minetest.chat_send_player(name, "You already have buyed this Kit!")
    end
  else minetest.chat_send_player(name, "You don't have enough money!")
  end
end

function skywars.set_player_kit(name, kitname)
  if kitname ~= "" and skywars_kits[name].kit ~= "" and table.contains(skywars_kits[name].kit, kitname) then
    skywars_kits[name].selected = kitname
  elseif kitname ~= "" then
		minetest.chat_send_player(name, "You don't have this kit!")
  end
end

function skywars.give_kit_items(name)
  if skywars_kits[name].selected then
    local kitname = skywars_kits[name].selected
    local def = kits_register[kitname]
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
function skywars.create_kit_form(name)
  local selected_id = 1
	local selected_buyid = 0
	local defitems = ""
	if not skywars_kits[name] then return end
	if type(skywars_kits[name].kit) == "table" and #skywars_kits[name].kit >= 1 then
  	for kitnumb,kitname in ipairs(skywars_kits[name].kit) do
    	if kitname == skywars_kits[name].selected then
      	selected_id = kitnumb
    	end
  	end
	end
	if skywars_kits[name].buying then
  	for kitnumb,kitname in ipairs(kits_all) do
    	if kitname == skywars_kits[name].buying then
      	selected_buyid = kitnumb
    	end
  	end
	end
	if kits_register[skywars_kits[name].selected] then
		local def = kits_register[skywars_kits[name].selected]
		if def.items then
			defitems = def.items
		end
	end
	local costbuy = ""
	if skywars_kits[name].buying then
		local costbuyb = kits_register[skywars_kits[name].buying]
		costbuy = costbuyb.cost
	end
	local itembuy = ""
	if skywars_kits[name].buying then
		local itembuyb = kits_register[skywars_kits[name].buying]
		itembuy = itembuyb.items
	end
  skywars_kit_form[name] = (
  	"size[8,9]" ..
  	"label[0,0;Select your Kit!]" ..
  	"dropdown[0,0.5;8,1.5;kitlist;"..subgames.concatornil(skywars_kits[name].kit)..";"..selected_id.."]" ..
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
	if lobby == "skywars" then
		local killedname = killed:get_player_name()
  	local killname = killer:get_player_name()
  	money.set_money(killname, money.get_money(killname)+5)
  	minetest.chat_send_player(killname, "CoinSystem: You have receive 5 Coins!")
	end
end)

function skywars.kit_on_player_receive_fields(self, player, context, pressed)
  local name = player:get_player_name()
  if player_lobby[name] == "skywars" then
  if pressed.buykit then
    if skywars_kits[name].buying then
      skywars.add_player_kits(name, skywars_kits[name].buying)
    end
  end
  if pressed.kitlist then
    skywars.set_player_kit(name, pressed.kitlist)
  end
  if pressed.buylist then
    skywars_kits[name].buying = pressed.buylist
  end
  skywars.save_kits(name)
  skywars.create_kit_form(name)
  sfinv.set_player_inventory_formspec(player)
  end
end

skywars.register_kit("Swordman", {
  cost = 500,
  items = {"default:sword_steel"},
})

skywars.register_kit("Bomber", {
  cost = 700,
  items = {"tnt:tnt_burning 5"},
})

skywars.register_kit("Builder", {
  cost = 0,
  items = {"default:stone 99"},
})

skywars.register_kit("Blocker", {
  cost = 700,
  items = {"default:obsidian 20"},
})

skywars.register_kit("Archer", {
  cost = 1000,
  items = {"bow:bow", "bow:arrow 20"},
})
