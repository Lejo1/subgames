mapblocks = {}

subgames.register_on_dignode(function(pos, oldnode, digger, lobby)
	if lobby == "mesewars" then
		if oldnode.name ~= "mesewars:mese1" and oldnode.name ~= "mesewars:mese2" and oldnode.name ~= "mesewars:mese3" and oldnode.name ~= "mesewars:mese4" then
			for nubsave, savepos in ipairs(mapblocks) do
	    	if savepos == minetest.pos_to_string(pos) then
	      	table.remove(mapblocks, nubsave)
	    	end
	  	end
		end
	end
end)

subgames.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing, lobby)
	if lobby == "mesewars" then
    table.insert(mapblocks, minetest.pos_to_string(pos))
	end
end)

function areas.mesewars.dig(pos, node, digger)
	local player = digger:get_player_name()
  local is_block = false
	if node.name ~= "mesewars:mese1" and node.name ~= "mesewars:mese2" and node.name ~= "mesewars:mese3" and node.name ~= "mesewars:mese4" then
  	for nubsave, savepos in ipairs(mapblocks) do
    	if savepos == minetest.pos_to_string(pos) then
      	return true
    	end
  	end
	else return true
	end
end

function areas.mesewars.place(itemstack, placer, pointed_thing, param2)
	if itemstack:get_name() == "tnt:tnt_burning" or itemstack:get_name() == "default:sandstone" or itemstack:get_name() == "default:obsidian" or itemstack:get_name() == "default:glass" or itemstack:get_name() == "default:steelblock" or itemstack:get_name() == "default:chest" then
		return true
	else return false
	end
end

subgames.register_on_blast(function(pos, intensity, lobby)
	if lobby == "mesewars" then
		local nodename = minetest.get_node(pos).name
		if nodename == "default:sandstone" or nodename == "default:obsidian" or nodename == "default:glass" or nodename == "default:steelblock" or nodename == "default:chest" then
			for nubsave, savepos in ipairs(mapblocks) do
		    if savepos == minetest.pos_to_string(pos) then
		      table.remove(mapblocks, nubsave)
		    end
		  end
			return true
		else return false
		end
	end
end)
