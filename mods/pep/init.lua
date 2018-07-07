-- Boilerplate to support localized strings if intllib mod is installed.
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s) return s end
end

pep = {}
function pep.register_potion(potiondef)
	local on_use
	if(potiondef.effect_type ~= nil) then
		on_use = function(itemstack, user, pointed_thing)
			playereffects.apply_effect_type(potiondef.effect_type, potiondef.duration, user)
			itemstack:take_item()
			return itemstack
		end
	else
		on_use = function(itemstack, user, pointed_thing)
			itemstack:take_item()
			return itemstack
		end
	end
	minetest.register_craftitem("pep:"..potiondef.basename, {
		description = string.format(S("Glass Bottle (%s)"), potiondef.contentstring),
		_doc_items_longdesc = potiondef.longdesc,
		_doc_items_usagehelp = S("Hold it in your hand, then left-click to drink it."),
		inventory_image = "pep_"..potiondef.basename..".png",
		wield_image = "pep_"..potiondef.basename..".png",
		on_use = on_use,
	})
end

pep.moles = {}

function pep.enable_mole_mode(playername)
	pep.moles[playername] = true
end

function pep.disable_mole_mode(playername)
	pep.moles[playername] = false
end

function pep.yaw_to_vector(yaw)
	local tau = math.pi*2

	yaw = yaw % tau
	if yaw < tau/8 then
		return { x=0, y=0, z=1}
	elseif yaw < (3/8)*tau then
		return { x=-1, y=0, z=0 }
	elseif yaw < (5/8)*tau then
		return { x=0, y=0, z=-1 }
	elseif yaw < (7/8)*tau then
		return { x=1, y=0, z=0 }
	else
		return { x=0, y=0, z=1}
	end
end

function pep.moledig(playername)
	local player = minetest.get_player_by_name(playername)

	local yaw = player:get_look_yaw()
	-- fix stupid oddity of Minetest, adding pi/2 to the actual player's look yaw...
	-- TODO: Remove this code as soon as Minetest fixes this.
	yaw = yaw - math.pi/2

	local pos = vector.round(player:getpos())

	local v = pep.yaw_to_vector(yaw)

	local digpos1 = vector.add(pos, v)
	local digpos2 = { x = digpos1.x, y = digpos1.y+1, z = digpos1.z }

	local try_dig = function(pos)
		local n = minetest.get_node(pos)
		local ndef = minetest.registered_nodes[n.name]
		if ndef.walkable and ndef.diggable then
			if ndef.can_dig ~= nil then
				if ndef.can_dig() then
					return true
				else
					return false
				end
			else
				return true
			end
		else
			return false
		end
	end

	local dig = function(pos)
		if try_dig(pos) then
			local n = minetest.get_node(pos)
			local ndef = minetest.registered_nodes[n.name]
			if ndef.sounds ~= nil then
				minetest.sound_play(ndef.sounds.dug, { pos = pos })
			end
			-- TODO: Replace this code as soon Minetest removes support for this function
			local drops = minetest.get_node_drops(n.name, "default:pick_steel")
			minetest.dig_node(pos)
			local inv = player:get_inventory()
			local leftovers = {}
			for i=1,#drops do
				table.insert(leftovers, inv:add_item("main", drops[i]))
			end
			for i=1,#leftovers do
				minetest.add_item(pos, leftovers[i])
			end
		end
	end

	dig(digpos1)
	dig(digpos2)
end

pep.timer = 0

minetest.register_globalstep(function(dtime)
	pep.timer = pep.timer + dtime
	if pep.timer > 0.5 then
		for playername, is_mole in pairs(pep.moles) do
			if is_mole then
				pep.moledig(playername)
			end
		end
		pep.timer = 0
	end
end)

playereffects.register_effect_type("pepspeedplus", S("High speed"), "pep_speedplus.png", {"speed"},
	function(player)
		player:set_physics_override({speed=2})
	end,
	function(effect, player)
		player:set_physics_override({speed=1})
	end
)
playereffects.register_effect_type("pepspeedminus", S("Low speed"), "pep_speedminus.png", {"speed"},
	function(player)
		player:set_physics_override({speed=0.5})
	end,
	function(effect, player)
		player:set_physics_override({speed=1})
	end
)
playereffects.register_effect_type("pepspeedreset", S("Speed neutralizer"), "pep_speedreset.png", {"speed"},
	function() end, function() end)
playereffects.register_effect_type("pepjumpplus", S("High jump"), "pep_jumpplus.png", {"jump"},
	function(player)
		player:set_physics_override({jump=2})
	end,
	function(effect, player)
		player:set_physics_override({jump=1})
	end
)
playereffects.register_effect_type("pepjumpminus", S("Low jump"), "pep_jumpminus.png", {"jump"},
	function(player)
		player:set_physics_override({jump=0.5})
	end,
	function(effect, player)
		player:set_physics_override({jump=1})
	end
)
playereffects.register_effect_type("pepjumpreset", S("Jump height neutralizer"), "pep_jumpreset.png", {"jump"},
	function() end, function() end)
playereffects.register_effect_type("pepgrav0", S("No gravity"), "pep_grav0.png", {"gravity"},
	function(player)
		player:set_physics_override({gravity=0})
	end,
	function(effect, player)
		player:set_physics_override({gravity=1})
	end
)
playereffects.register_effect_type("pepgravreset", S("Gravity neutralizer"), "pep_gravreset.png", {"gravity"},
	function() end, function() end)
playereffects.register_effect_type("pepregen", S("Regeneration"), "pep_regen.png", {"health"},
	function(player)
		player:set_hp(player:get_hp()+1)
	end,
	nil, nil, nil, 2
)
playereffects.register_effect_type("pepregen2", S("Strong regeneration"), "pep_regen2.png", {"health"},
	function(player)
		player:set_hp(player:get_hp()+2)
	end,
	nil, nil, nil, 1
)

if minetest.get_modpath("mana") ~= nil then
	playereffects.register_effect_type("pepmanaregen", S("Weak mana boost"), "pep_manaregen.png", {"mana"},
		function(player)
			local name = player:get_player_name()
			mana.setregen(name, mana.getregen(name) + 0.5)
		end,
		function(effect, player)
			local name = player:get_player_name()
			mana.setregen(name, mana.getregen(name) - 0.5)
		end
	)
	playereffects.register_effect_type("pepmanaregen2", S("Strong mana boost"), "pep_manaregen2.png", {"mana"},
		function(player)
			local name = player:get_player_name()
			mana.setregen(name, mana.getregen(name) + 1)
		end,
		function(effect, player)
			local name = player:get_player_name()
			mana.setregen(name, mana.getregen(name) - 1)
		end
	)
end


playereffects.register_effect_type("pepbreath", S("Perfect breath"), "pep_breath.png", {"breath"},
	function(player)
		player:set_breath(player:get_breath()+2)
	end,
	nil, nil, nil, 1
)
playereffects.register_effect_type("pepmole", S("Mole mode"), "pep_mole.png", {"autodig"},
	function(player)
		pep.enable_mole_mode(player:get_player_name())
	end,
	function(effect, player)
		pep.disable_mole_mode(player:get_player_name())
	end
)

pep.register_potion({
	basename = "speedplus",
	contentstring = S("Running Potion"),
	longdesc = S("Drinking it will make you run faster for 30 seconds."),
	effect_type = "pepspeedplus",
	duration = 30,
})
pep.register_potion({
	basename = "speedminus",
	contentstring = S("Slug Potion"),
	longdesc = S("Drinking it will make you walk slower for 30 seconds."),
	effect_type = "pepspeedminus",
	duration = 30,
})
pep.register_potion({
	basename = "speedreset",
	contentstring = S("Speed Neutralizer"),
	longdesc = S("Drinking it will stop all speed effects you may currently have."),
	effect_type = "pepspeedreset",
	duration = 0
})
pep.register_potion({
	basename = "breath",
	contentstring = S("Air Potion"),
	longdesc = S("Drinking it gives you breath underwater for 30 seconds."),
	effect_type = "pepbreath",
	duration = 30,
})
pep.register_potion({
	basename = "regen",
	contentstring = S("Weak Healing Potion"),
	longdesc = S("Drinking it makes you regenerate health. Every 2 seconds, you get 1 HP, 10 times in total."),
	effect_type = "pepregen",
	duration = 10,
})
pep.register_potion({
	basename = "regen2",
	contentstring = S("Strong Healing Potion"),
	longdesc = S("Drinking it makes you regenerate health quickly. Every second you get 2 HP, 10 times in total."),
	effect_type = "pepregen2",
	duration = 10,
})
pep.register_potion({
	basename = "grav0",
	contentstring = S("Non-Gravity Potion"),
	longdesc = S("When you drink this potion, gravity stops affecting you, as if you were in space. The effect lasts for 20 seconds."),
	effect_type = "pepgrav0",
	duration = 20,
})
pep.register_potion({
	basename = "gravreset",
	contentstring = S("Gravity Neutralizer"),
	longdesc = S("Drinking it will stop all gravity effects you currently have."),
	effect_type = "pepgravreset",
	duration = 0,
})
pep.register_potion({
	basename = "jumpplus",
	contentstring = S("High Jumping Potion"),
	longdesc = S("Drinking it will make you jump higher for 30 seconds."),
	effect_type = "pepjumpplus",
	duration = 30,
})
pep.register_potion({
	basename = "jumpminus",
	contentstring = S("Low Jumping Potion"),
	longdesc = S("Drinking it will make you jump lower for 30 seconds."),
	effect_type = "pepjumpminus",
	duration = 30,
})
pep.register_potion({
	basename = "jumpreset",
	contentstring = S("Jump Neutralizer"),
	longdesc = S("Drinking it will stop all jumping effects you may currently have."),
	effect_type = "pepjumpreset",
	duration = 0,
})
pep.register_potion({
	basename = "mole",
	contentstring = S("Mole Potion"),
	longdesc = S("Drinking it will start an effect which will magically attempt to mine any two blocks in front of you horizontally, as if you were using a steel pickaxe on them. The effect lasts for 18 seconds."),
	effect_type = "pepmole",
	duration = 18,
})
if(minetest.get_modpath("mana")~=nil) then
	pep.register_potion({
		basename = "manaregen",
		contentstring = S("Weak Mana Potion"),
		effect_type = "pepmanaregen",
		duration = 10,
		longdesc = S("Drinking it will increase your mana regeneration rate by 0.5 for 10 seconds."),
	})
	pep.register_potion({
		basename = "manaregen2",
		contentstring = S("Strong Mana Potion"),
		effect_type = "pepmanaregen2",
		duration = 10,
		longdesc = S("Drinking it will increase your mana regeneration rate by 1 for 10 seconds."),
	})
end

