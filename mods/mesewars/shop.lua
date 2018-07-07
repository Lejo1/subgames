-- Add the Shop
minetest.register_node("mesewars:shop", {
  description = "Shop", -- Add image later!
  groups = {unbreakable = 1},
  drop = "",
  tiles = {"easyvend_vendor_bottom.png", "easyvend_vendor_bottom.png", "easyvend_vendor_side.png", "easyvend_vendor_side.png", "easyvend_vendor_side.png", "easyvend_vendor_front_on.png"},
  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    local name = player:get_player_name()
    minetest.show_formspec(name, "mesewars:shop_main",
      "size[7,2]" ..
      "item_image_button[0,1;1,1;default:sandstone;blocks;]" ..
      "tooltip[blocks;Blocks]" ..
      "item_image_button[1,1;1,1;default:sword_steel;swords;]" ..
      "tooltip[swords;Swords]" ..
      "item_image_button[2,1;1,1;3d_armor:chestplate_steel;armor;]" ..
      "tooltip[armor;Armor]" ..
      "item_image_button[3,1;1,1;default:pick_steel;pick;]" ..
      "tooltip[pick;Picks]" ..
      "item_image_button[4,1;1,1;default:chest;special;]" ..
      "tooltip[special;Special]" ..
      "item_image_button[5,1;1,1;pep:regen;potions;]" ..
      "tooltip[potions;Potions]" ..
      "item_image_button[6,1;1,1;bow:bow;bows;]"..
      "tooltip[bows;Bows]")
  end
})

--  Add Shop function.
function mesewars.shop(player, input, output)
  local name = player:get_player_name()
  local inv = player:get_inventory()
  if not inv:contains_item("main", input) then
    minetest.chat_send_player(name, "You don't have enough resouces.")
  elseif not inv:room_for_item("main", output) then
    minetest.chat_send_player(name, "In your inventory is not enough space.")
  else inv:remove_item("main", input)
    inv:add_item("main", output)
  end
end

--  Shop Menue.
minetest.register_on_player_receive_fields(function(player, formname, pressed)
  local name = player:get_player_name()
  if formname == "mesewars:shop_main" then
      if pressed["blocks"] then
        minetest.show_formspec(name, "mesewars:shop_blocks",
          "size[8,6]" ..
          "label[1,1;Sandstone]" ..
          "label[1,2;1 Brick to 3]" ..
          "item_image_button[1,3;1,1;default:sandstone;3sand;3:1]" ..
          "item_image_button[1,4;1,1;default:sandstone;33sand;33:11]" ..
          "item_image_button[1,5;1,1;default:sandstone;99sand;99:33]" ..
          "label[3,1;Glass]" ..
          "label[3,2;1 Brick to 1]" ..
          "item_image_button[3,3;1,1;default:glass;1glass;1:1]" ..
          "item_image_button[3,4;1,1;default:glass;33glass;33:33]" ..
          "item_image_button[3,5;1,1;default:glass;99glass;99:99]" ..
          "label[5,1;Steel]" ..
          "label[5,2;3 Steel to 1]" ..
          "item_image_button[5,3;1,1;default:steelblock;1steel;1:3]" ..
          "item_image_button[5,4;1,1;default:steelblock;11steel;11:33]" ..
          "item_image_button[5,5;1,1;default:steelblock;33steel;33:99]" ..
          "label[7,1;Obsidian]" ..
          "label[7,2;2 Gold to 1]" ..
          "item_image_button[7,3;1,1;default:obsidian;1obs;1:2]" ..
          "item_image_button[7,4;1,1;default:obsidian;11obs;11:22]" ..
          "item_image_button[7,5;1,1;default:obsidian;33obs;33:66]")
      elseif pressed["swords"] then
        minetest.show_formspec(name, "mesewars:shop_swords",
          "size[9,4]" ..
          "label[1,1;Stone Sword]" ..
          "label[1,2;15 Brick to 1]" ..
          "item_image_button[1,3;1,1;default:sword_stone;1stonesword;1:15]" ..
          "label[3,1;Steel Sword]" ..
          "label[3,2;10 Steel to 1]" ..
          "item_image_button[3,3;1,1;default:sword_steel;1steelsword;1:10]" ..
          "label[5,1;Mese Sword]" ..
          "label[5,2;25 Steel to 1]" ..
          "item_image_button[5,3;1,1;default:sword_mese;1mesesword;1:25]" ..
          "label[7,1;Diamond Sword]" ..
          "label[7,2;5 Gold to 1]" ..
          "item_image_button[7,3;1,1;default:sword_diamond;1diamondsword;1:5]")
      elseif pressed["armor"] then
        minetest.show_formspec(name, "mesewars:shop_armor",
          "size[7,7]" ..
          "label[1,1;Wood]" ..
          "label[1,2;3 Brick to 1]" ..
          "item_image_button[1,3;1,1;3d_armor:helmet_wood;1woodh;1:3]" ..
          "item_image_button[1,4;1,1;3d_armor:chestplate_wood;1woodc;1:3]" ..
          "item_image_button[1,5;1,1;3d_armor:leggings_wood;1woodl;1:3]" ..
          "item_image_button[1,6;1,1;3d_armor:boots_wood;1woodb;1:3]" ..
          "label[3,1;Cactus]" ..
          "label[3,2;2 Steel to 1]" ..
          "item_image_button[3,3;1,1;3d_armor:helmet_cactus;1cactush;1:2]" ..
          "item_image_button[3,4;1,1;3d_armor:chestplate_cactus;1cactusc;1:2]" ..
          "item_image_button[3,5;1,1;3d_armor:leggings_cactus;1cactusl;1:2]" ..
          "item_image_button[3,6;1,1;3d_armor:boots_cactus;1cactusb;1:2]" ..
          "label[5,1;Steel]" ..
          "label[5,2;2 Gold to 1]" ..
          "item_image_button[5,3;1,1;3d_armor:helmet_steel;1steelh;1:2]" ..
          "item_image_button[5,4;1,1;3d_armor:chestplate_steel;1steelc;1:2]" ..
          "item_image_button[5,5;1,1;3d_armor:leggings_steel;1steell;1:2]" ..
          "item_image_button[5,6;1,1;3d_armor:boots_steel;1steelb;1:2]")
      elseif pressed["pick"] then
        minetest.show_formspec(name, "mesewars:shop_pick",
          "size[9,4]" ..
          "label[1,1;Stone Pick]" ..
          "label[1,2;5 Brick to 1]" ..
          "item_image_button[1,3;1,1;default:pick_stone;1stonepick;1:5]" ..
          "label[3,1;Steel Pick]" ..
          "label[3,2;5 Steel to 1]" ..
          "item_image_button[3,3;1,1;default:pick_steel;1steelpick;1:5]" ..
          "label[5,1;Mese Pick]" ..
          "label[5,2;15 Steel to 1]" ..
          "item_image_button[5,3;1,1;default:pick_mese;1mesepick;1:15]" ..
          "label[7,1;Diamond Pick]" ..
          "label[7,2;2 Gold to 1]" ..
          "item_image_button[7,3;1,1;default:pick_diamond;1diamondpick;1:2]")
      elseif pressed["special"] then
        minetest.show_formspec(name, "mesewars:shop_special",
          "size[11,4]" ..
          "label[1,1;Chest]" ..
          "label[1,2;2 Steel to 1]" ..
          "item_image_button[1,3;1,1;default:chest;1chest;1:2]" ..
          "label[3,1;Base Teleporter]" ..
          "label[3,2;10 Steel to 1]" ..
          "item_image_button[3,3;1,1;mesewars:baseteleport;1basetp;1:10]" ..
          "label[5,1;Fallprotection]" ..
          "label[5,2;1 Gold to 1]" ..
          "item_image_button[5,3;1,1;mesewars:fallprotection;1fall;1:1]" ..
          "label[7,1;Bridge Builder]" ..
          "label[7,2;3 Steel to 1]" ..
          "item_image_button[7,3;1,1;mesewars:bridge;1bridge;1:3]"..
          "label[9,1;TNT]" ..
          "label[9,2;3 Steel to 1]" ..
          "item_image_button[9,3;1,1;tnt:tnt_burning;1tnt;1:3]")
      elseif pressed["potions"] then
        minetest.show_formspec(name, "mesewars:shop_potion",
          "size[9,4]" ..
          "label[1,1;Regen Potion]" ..
          "label[1,2;1 Gold to 1]" ..
          "item_image_button[1,3;1,1;pep:regen;1regen;1:1]" ..
          "label[3,1;Regen Potion2]" ..
          "label[3,2;2 Gold to 1]" ..
          "item_image_button[3,3;1,1;pep:regen2;1regen2;1:2]" ..
          "label[5,1;Speed Potion]" ..
          "label[5,2;15 Steel to 1]" ..
          "item_image_button[5,3;1,1;pep:speedplus;1speed;1:15]" ..
          "label[7,1;Jump Potion]" ..
          "label[7,2;5 Steel to 1]" ..
          "item_image_button[7,3;1,1;pep:jumpplus;1jump;1:5]")
      elseif pressed["bows"] then
        minetest.show_formspec(name, "mesewars:shop_bows",
          "size[5,4]" ..
          "label[1,1;Bow]" ..
          "label[1,2;4 Gold to 1]" ..
          "item_image_button[1,3;1,1;bow:bow;1bow;1:4]" ..
          "label[3,1;Arrow]" ..
          "label[3,2;25 Brick to 5]" ..
          "item_image_button[3,3;1,1;bow:arrow;5arrow;5:25]")
      end
  elseif formname == "mesewars:shop_blocks" then
    if pressed["3sand"] then
      mesewars.shop(player, "default:clay_brick 1", "default:sandstone 3")
    elseif pressed["33sand"] then
      mesewars.shop(player, "default:clay_brick 11", "default:sandstone 33")
    elseif pressed["99sand"] then
      mesewars.shop(player, "default:clay_brick 33", "default:sandstone 99")
    elseif pressed["1glass"] then
      mesewars.shop(player, "default:clay_brick 1", "default:glass 1")
    elseif pressed["33glass"] then
      mesewars.shop(player, "default:clay_brick 33", "default:glass 33")
    elseif pressed["99glass"] then
      mesewars.shop(player, "default:clay_brick 99", "default:glass 99")
    elseif pressed["1steel"] then
      mesewars.shop(player, "default:steel_ingot 3", "default:steelblock 1")
    elseif pressed["11steel"] then
      mesewars.shop(player, "default:steel_ingot 33", "default:steelblock 11")
    elseif pressed["33steel"] then
      mesewars.shop(player, "default:steel_ingot 99", "default:steelblock 33")
    elseif pressed["1obs"] then
      mesewars.shop(player, "default:gold_ingot 2", "default:obsidian 1")
    elseif pressed["11obs"] then
      mesewars.shop(player, "default:gold_ingot 22", "default:obsidian 11")
    elseif pressed["33obs"] then
      mesewars.shop(player, "default:gold_ingot 66", "default:obsidian 33")
    end
  elseif formname == "mesewars:shop_swords" then
    if pressed["1stonesword"] then
      mesewars.shop(player, "default:clay_brick 15", "default:sword_stone")
    elseif pressed["1steelsword"] then
      mesewars.shop(player, "default:steel_ingot 10", "default:sword_steel")
    elseif pressed["1mesesword"] then
      mesewars.shop(player, "default:steel_ingot 25", "default:sword_mese")
    elseif pressed["1diamondsword"] then
      mesewars.shop(player, "default:gold_ingot 5", "default:sword_diamond")
    end
  elseif formname == "mesewars:shop_armor" then
    if pressed["1woodh"] then
      mesewars.shop(player, "default:clay_brick 3", "3d_armor:helmet_wood")
    elseif pressed["1woodc"] then
      mesewars.shop(player, "default:clay_brick 3", "3d_armor:chestplate_wood")
    elseif pressed["1woodl"] then
      mesewars.shop(player, "default:clay_brick 3", "3d_armor:leggings_wood")
    elseif pressed["1woodb"] then
      mesewars.shop(player, "default:clay_brick 3", "3d_armor:boots_wood")
    elseif pressed["1cactush"] then
      mesewars.shop(player, "default:steel_ingot 2", "3d_armor:helmet_cactus")
    elseif pressed["1cactusc"] then
      mesewars.shop(player, "default:steel_ingot 2", "3d_armor:chestplate_cactus")
    elseif pressed["1cactusl"] then
      mesewars.shop(player, "default:steel_ingot 2", "3d_armor:leggings_cactus")
    elseif pressed["1cactusb"] then
      mesewars.shop(player, "default:steel_ingot 2", "3d_armor:boots_cactus")
    elseif pressed["1steelh"] then
      mesewars.shop(player, "default:gold_ingot 2", "3d_armor:helmet_steel")
    elseif pressed["1steelc"] then
      mesewars.shop(player, "default:gold_ingot 2", "3d_armor:chestplate_steel")
    elseif pressed["1steell"] then
      mesewars.shop(player, "default:gold_ingot 2", "3d_armor:leggings_steel")
    elseif pressed["1steelb"] then
      mesewars.shop(player, "default:gold_ingot 2", "3d_armor:boots_steel")
    end
  elseif formname == "mesewars:shop_pick" then
    if pressed["1stonepick"] then
      mesewars.shop(player, "default:clay_brick 5", "default:pick_stone")
    elseif pressed["1steelpick"] then
      mesewars.shop(player, "default:steel_ingot 5", "default:pick_steel")
    elseif pressed["1mesepick"] then
      mesewars.shop(player, "default:steel_ingot 15", "default:pick_mese")
    elseif pressed["1diamondpick"] then
      mesewars.shop(player, "default:gold_ingot 2", "default:pick_diamond")
    end
  elseif formname == "mesewars:shop_special" then
    if pressed["1chest"] then
      mesewars.shop(player, "default:steel_ingot 2", "default:chest")
    elseif pressed["1basetp"] then
      mesewars.shop(player, "default:steel_ingot 10", "mesewars:baseteleport")
    elseif pressed["1fall"] then
      mesewars.shop(player, "default:gold_ingot 1", "mesewars:fallprotection")
    elseif pressed["1bridge"] then
      mesewars.shop(player, "default:steel_ingot 3", "mesewars:bridge")
    elseif pressed["1tnt"] then
      mesewars.shop(player, "default:steel_ingot 3", "tnt:tnt_burning")
    end
  elseif formname == "mesewars:shop_potion" then
    if pressed["1regen"] then
      mesewars.shop(player, "default:gold_ingot 1", "pep:regen")
    elseif pressed["1regen2"] then
      mesewars.shop(player, "default:gold_ingot 2", "pep:regen2")
    elseif pressed["1speed"] then
      mesewars.shop(player, "default:steel_ingot 15", "pep:speedplus")
    elseif pressed["1jump"] then
      mesewars.shop(player, "default:steel_ingot 5", "pep:jumpplus")
    end
  elseif formname == "mesewars:shop_bows" then
    if pressed["1bow"] then
      mesewars.shop(player, "default:gold_ingot 4", "bow:bow")
    elseif pressed["5arrow"] then
      mesewars.shop(player, "default:clay_brick 25", "bow:arrow 5")
    end
  end
end)

--  Add some special items
minetest.register_entity("mesewars:temp", {
	physical = true,
	collisionbox = {0, 0, 0, 0, 0, 0},
	visual_size = {x = 0, y = 0},
	visual = "sprite",
	textures = {"trans.png"},
	stepheight = 0,
	on_activate = function(self, staticdata, dtime)
		self.timer = (self.timer or 0) + dtime
		if self.timer > 1 then
			self.object:remove()
		end
	end
})
minetest.register_craftitem("mesewars:fallprotection", {
	description = "Fallprotection",
	inventory_image = "mesewars_fallprotection.png",
	on_use = minetest.item_eat(0)
})
subgames.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing, lobby)
    if lobby == "mesewars" then
    local name = user:get_player_name()
    local pos = user:getpos()
    local blockpos = pos ; blockpos.y = blockpos.y -2
    minetest.item_place_node(ItemStack("default:glass"), user, {type="node", under=blockpos, above=blockpos})
    local ent = minetest.add_entity(user:getpos(), "mesewars:temp")
    local obj = ent:get_luaentity()
    if obj and not user:get_attach() then
      user:set_attach(ent, "", {x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
      minetest.after(1, function()
			 user:set_detach()
			 ent:remove()
		  end)
    end
    end
end)

mesewars.baseteleportposes = {}
mesewars.baseteleporthps = {}
mesewars.baseteleportparticalid = {}
mesewars.baseteleportcount = {}
mesewars.baseteleportpartical = {}
playereffects.register_effect_type("baseteleport", "Base Teleport", "pep_manaregen.png", {"meseteleport"},
	function(player)
    local name = player:get_player_name()
    local pos = minetest.pos_to_string(player:getpos())
    local hp = player:get_hp()
		if mesewars.baseteleportposes[name] and mesewars.baseteleporthps[name] then
      if mesewars.baseteleportposes[name] ~= pos or mesewars.baseteleporthps[name] > hp then
        playereffects.cancel_effect_type("baseteleport", false, name)
        minetest.delete_particlespawner(mesewars.baseteleportparticalid[name], name)
      elseif mesewars.baseteleportcount[name] >= 4 then
        player:setpos(mesewars.get_team_base(name))
      else mesewars.baseteleportcount[name] = mesewars.baseteleportcount[name] + 1
      end
    elseif not mesewars.baseteleporthps[name] then
      mesewars.baseteleportparticalid[name] = minetest.add_particlespawner(mesewars.make_baseteleport_partical(player))
      mesewars.baseteleporthps[name] = hp
      mesewars.baseteleportposes[name] = pos
      mesewars.baseteleportcount[name] = 1
    end
	end,
	function(effect, player)
    local name = player:get_player_name(name)
    mesewars.baseteleportposes[name] = nil
    mesewars.baseteleporthps[name] = nil
    mesewars.baseteleportpartical[name] = nil
    mesewars.baseteleportcount[name] = nil
  end,
  nil,
  true,
  1
)

minetest.register_craftitem("mesewars:baseteleport", {
  description = "Base Teleporter",
  inventory_image = "pep_manaregen.png",
  on_use = function(itemstack, user, pointed_thing)
    local name = user:get_player_name()
    playereffects.apply_effect_type("baseteleport", 5, user)
    minetest.chat_send_player(name, "Don't move or the teleportation get canceled.")
    itemstack:take_item()
    return itemstack
  end,
})

function mesewars.make_baseteleport_partical(player)
  local name = player:get_player_name()
  local pos = player:getpos() ; pos.y = pos.y + 1
  local goal = mesewars.get_team_base(name)
  local dir = vector.direction(pos, goal)
  local dis = vector.distance(pos, goal)
  local speed = vector.subtract(goal, pos)
  mesewars.baseteleportpartical[name] = ({
	amount = 25*dis,
  time = 5,
	minpos = pos,
  maxpos = pos,
  minvel = speed,
  maxvel = speed,
  minacc = dir,
	maxacc = dir,
	minexptime = 1,
	maxexptime = 1,
	minsize = 15,
	maxsize = 20,
	collisiondetection = false,
	vertical = false,
	texture = "tnt_smoke.png",
  })
  return mesewars.baseteleportpartical[name]
end

minetest.register_craftitem("mesewars:bridge", {
  description = "Bridge Builder",
  inventory_image = "bridge.png",
  on_use = function(itemstack, user, pointed_thing)
    local name = user:get_player_name()
    local counter = 0
    local lastpos = user:getpos() ; lastpos.y = lastpos.y -1
    local high = lastpos.y
    while counter < 5 do
      counter = counter +1
      lastpos = vector.add(lastpos, user:get_look_dir()) ; lastpos.y = high
      minetest.item_place_node(ItemStack("default:sandstone"), user, {type="node", under=lastpos, above=lastpos})
    end
    itemstack:take_item()
    return itemstack
  end,
})
