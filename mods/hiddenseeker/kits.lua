hiddenseeker_kit_form = {}
hiddenseeker.kits = {}
local kits_register = {}
local kits_all = {}

local input = io.open(minetest.get_worldpath() .. "/hiddenseeker_kits", "r")

if input then
	local input2 = minetest.deserialize(input:read("*l"))
	if input2 then
		hiddenseeker.kits = input2
		io.close(input)
	end
end

function hiddenseeker.save_kits()
	local output = io.open(minetest.get_worldpath() .. "/hiddenseeker_kits", "w")
	output:write(minetest.serialize(hiddenseeker.kits))
	io.close(output)
end

minetest.register_on_shutdown(function()
  hiddenseeker.save_kits()
end)

--  Creates player's account, if the player doesn't have it.
subgames.register_on_joinplayer(function(player, lobby)
	if lobby == "hiddenseeker" then
	  local name = player:get_player_name()
	  if not hiddenseeker.kits[name] then
			hiddenseeker.kits[name] = {kit = {"Random"}, selected = {"Random"}}
    	hiddenseeker.save_kits()
		end
		if not hiddenseeker.kits[name].abilitys then
			hiddenseeker.kits[name].abilitys = {}
		end
	  hiddenseeker.save_kits()
	end
end)

function hiddenseeker.get_player_kits(name)
  return hiddenseeker.kits[name].kit
end

function hiddenseeker.register_kit(kitname, def)
  kits_register[kitname] = def
  def.name = kitname
	table.insert(kits_all, kitname)
end

function hiddenseeker.add_player_kits(name, kitname)
  local def = kits_register[kitname]
	local inserter = hiddenseeker.kits[name].kit
  if def and money.get_money(name) >= def.cost then
    if hiddenseeker.kits[name].kit == "" or not table.contains(hiddenseeker.kits[name].kit, kitname) == true then
      money.set_money(name, money.get_money(name)-def.cost)
			table.insert(hiddenseeker.kits[name].kit, kitname)
			hiddenseeker.save_kits()
      minetest.chat_send_player(name, "You have buyed the Block " ..kitname.."!")
    else minetest.chat_send_player(name, "You already have buyed this Block!")
    end
  else minetest.chat_send_player(name, "You don't have enough money!")
  end
end

function hiddenseeker.set_player_kit(name, kitname)
  if kitname ~= "" and hiddenseeker.kits[name].kit ~= "" and table.contains(hiddenseeker.kits[name].kit, kitname) then
    hiddenseeker.kits[name].selected = kitname
  elseif kitname ~= "" then
		minetest.chat_send_player(name, "You don't have this Block!")
  end
end

--  Add a sfinv Kit Formspec
function hiddenseeker.create_kit_form(name)
  local selected_id = 1
	local selected_buyid = 0
	local defitems = ""
	if not hiddenseeker.kits[name] then return end
	if type(hiddenseeker.kits[name].kit) == "table" and #hiddenseeker.kits[name].kit >= 1 then
  	for kitnumb,kitname in ipairs(hiddenseeker.kits[name].kit) do
    	if kitname == hiddenseeker.kits[name].selected then
      	selected_id = kitnumb
    	end
  	end
	end
	if hiddenseeker.kits[name].buying then
  	for kitnumb, kitname in ipairs(kits_all) do
    	if kitname == hiddenseeker.kits[name].buying then
      	selected_buyid = kitnumb
    	end
  	end
	end
	if kits_register[hiddenseeker.kits[name].selected] then
		local def = kits_register[hiddenseeker.kits[name].selected]
		if def.items then
			defitems = def.items
		end
	end
	local costbuy = ""
	if hiddenseeker.kits[name].buying then
		local costbuyb = kits_register[hiddenseeker.kits[name].buying]
		costbuy = costbuyb.cost
	end
	local itembuy = ""
	if hiddenseeker.kits[name].buying then
		local itembuyb = kits_register[hiddenseeker.kits[name].buying]
		itembuy = itembuyb.items
	end
  hiddenseeker_kit_form[name] = (
  	"size[8,9]" ..
  	"label[0,0;Select your Block you want to be in the next round!]" ..
  	"dropdown[0,0.5;8,1.5;blocklist;"..subgames.concatornil(hiddenseeker.kits[name].kit)..";"..selected_id.."]" ..
		"label[0,1.5;Block: "..subgames.concatornil(defitems).." ]" ..
		"label[0,2.5;Here you can buy your Block!]" ..
		"label[0,3;Your money: "..money.get_money(name).." Coins]" ..
		"dropdown[0,3.5;8,1.5;buylist;"..table.concat(kits_all, ",")..";"..selected_buyid.."]" ..
		"label[0,4.5;Cost: "..costbuy.."]" ..
		"label[0,5.5;Block: "..subgames.concatornil(itembuy).." ]" ..
		"button[4,4.5;3,1;buyblock;Buy this Block!]")
end

--  Grant money when kill a player
subgames.register_on_kill_player(function(killer, killed, lobby)
	local killedname = killed:get_player_name()
	local killname = killer:get_player_name()
	if lobby == "hiddenseeker" and hiddenseeker.player_lobby[killname] ~= 0 then
		local killrol = hiddenseeker.lobbys[hiddenseeker.player_lobby[killname]].players[killname]
		if killrol == "seeker" then
  		money.set_money(killname, money.get_money(killname)+10)
  		minetest.chat_send_player(killname, "CoinSystem: You have receive 10 Coins!")
		else money.set_money(killname, money.get_money(killname)+15)
  		minetest.chat_send_player(killname, "CoinSystem: You have receive 15 Coins!")
		end
	end
end)

function hiddenseeker.kit_on_player_receive_fields(self, player, context, pressed)
	local name = player:get_player_name()
	if player_lobby[name] == "hiddenseeker" then
		if pressed.buyblock then
			if hiddenseeker.kits[name].buying then
				hiddenseeker.add_player_kits(name, hiddenseeker.kits[name].buying)
			end
		end
		if pressed.blocklist then
			hiddenseeker.set_player_kit(name, pressed.blocklist)
		end
		if pressed.buylist then
			hiddenseeker.kits[name].buying = pressed.buylist
		end
		hiddenseeker.save_kits()
		hiddenseeker.create_kit_form(name)
		sfinv.set_player_inventory_formspec(player)
	end
end

function hiddenseeker.get_player_block(name)
	local lobby = hiddenseeker.player_lobby[name]
	local selected = hiddenseeker.kits[name].selected
	if not selected or selected == "Random" or selected == "" or not kits_register[selected] or not kits_register[selected].items then
		return hiddenseeker.lobbys[lobby].blocks[math.random(#hiddenseeker.lobbys[lobby].blocks)]
	else return kits_register[selected].items
	end
end

hiddenseeker.register_kit("Stone", {
  cost = 300,
  items = "default:stone",
})

hiddenseeker.register_kit("Bookshelf", {
  cost = 300,
  items = "default:bookshelf",
})
hiddenseeker.register_kit("Wood", {
  cost = 300,
  items = "default:wood",
})
