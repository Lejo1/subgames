--denaid mod for minetest 0.4.12
--areas-like protection of areas, with specific rulesets for players and deny permission to enter area

denaid_areas={};

denaid={}

--==API FUNCTIONS==--
--[[
----common functions----
function denaid.get_areas_at(pos)
returns a list of area-ids which are present at the position pos. Only areas with the same, highest priority at the position are returned (this is usually 1 area, but can be more).

----whole area manipulation----
function denaid.add_area(name, owner, fullname, coord1, coord2, priority)
Adds an area. All parameters are required. Area mustn't exist, if it exists, a warning will be printed and nothing will happen. Returns true on success.

function denaid.edit_area(name, owner, fullame, coord1, coord2, priority)
Edits an area. Parameters can be nil, then the previous value is taken. Will show a warning and add the area if it does not exist. Returns true on success.

function denaid.delete_area(name)
Deletes Area with ID. All information is lost then. Will always succeed. Returns true on success.

function denaid.get_area(name)
Returns Area table with ID name, or nil if not existing. Can be used to check whether an area exists, and retrieves the table. There is no setter.

----area option manipulation----
function denaid.set_area_pvp(areaid, pvp)
sets if pvp is enabled in area. Returns true on success.

function denaid.set_area_monsters(areaid, monsters)
sets if monsters are allowed in area. Returns true on success.

function denaid.get_area_options(areaid)
returns pvp, monsters settings of area in this order as 2 return parameters or nil, nil, true if area does not exist.

----area ruleset manipulation----
function denaid.get_rulesets(areaid)
returns all rulesets of an area. should not be used, except to count the rulesets of an area.

function denaid.get_ruleset_by_index(areaid, index)
returns ruleset with specific index of the area. If no index given, return last ruleset.

function denaid.set_ruleset_by_index(areaid, index, ruleset)
sets ruleset to index position. will overwrite, not insert. If no index given, replaces last ruleset. checks for possible identifier conflicts. returns true on success.

function denaid.insert_ruleset_to_index(areaid, ruleset [, index])
inserts ruleset at specified index. checks for identifier conflicts. If no index given, appends as last ruleset. returns true on success.

function denaid.get_ruleset(areaid, identifier)
gets the ruleset with the specific identifier string.

function denaid.set_ruleset(areaid, ruleset)
replaces the ruleset with the same identifier as the one in the passed ruleset by the passed ruleset. will return true on success.

function denaid.set_ruleset_at_index(areaid, identifier, index)
removes the ruleset with identifier from its current position and inserts it at index position. if index is nil, inserts at the end. returns true on success.

function denaid.remove_ruleset_by_index(areaid, index)
removes the ruleset at index. returns the removed ruleset on success. If index is nil, remove last ruleset.

function denaid.remove_ruleset(areaid, identifier)
removes the ruleset that has this identifier. Returns the removed ruleset.

function denaid.clear_rulesets(areaid)
deletes all rulesets of the area. returns a list of all removed rulesets.

area rulesets are represented as tables with the following elements:
------players: string players separated by semicola or spaces, or @a for all players.
------enter: bool may enter
------use:   allow right click on blocks / inventory transactions
------build: allow building/harvesting
------identifier: can be nil, used to identify rulesets.

The user interface offers no way to edit identifiers!

]]--



--==END OF API FUNCTIONS==--

-- Boilerplate to support localized strings if intllib mod is installed.
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	-- If you use insertions, but not insertion escapes this will work:
	S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end

--API stuff implementations(if not further below)
denaid.delete_area=function(name)
	denaid_areas[name]=nil
	return true
end
denaid.get_area=function(name)
	return denaid_areas[name]
end

--

function denaid.set_area_pvp(areaid, pvp)
	if not denaid_areas[areaid] then return false end
	denaid_areas[areaid].pvp=pvp
	return true
end

function denaid.set_area_monsters(areaid, monsters)
	if not denaid_areas[areaid] then return false end
	denaid_areas[areaid].monsters=monsters
	return true
end

function denaid.get_area_options(areaid)
	if not denaid_areas[areaid] then return nil, nil, true end
	return denaid_areas[areaid].pvp, denaid_areas[areaid].monsters
end

----area ruleset manipulation----
function denaid.get_rulesets(areaid)
	if not denaid_areas[areaid] then print("[denaid]No such Area: "..areaid.."!") return false end
	return denaid_areas[areaid].rulesets
end
function denaid.get_ruleset_by_index(areaid, index)
	if not (denaid_areas[areaid] and denaid_areas[areaid].rulesets) then print("[denaid]No such Area: "..areaid.."!") return false end
	return denaid_areas[areaid].rulesets[index or #denaid_areas[areaid].rulesets]
end
function denaid.set_ruleset_by_index(areaid, index, ruleset)
	if not (denaid_areas[areaid] and denaid_areas[areaid].rulesets) then print("[denaid]No such Area: "..areaid.."!") return false end
	if denaid.get_area_ruleset_ident_index(denaid_areas[areaid].rulesets, ruleset.identifier)~=index then
		print("[denaid]Identifier conflict!")
		return false
	end
	denaid_areas[areaid].rulesets[index or #denaid_areas[areaid].rulesets]=ruleset
	return true
end
function denaid.insert_ruleset_to_index(areaid, ruleset, index)
	if not (denaid_areas[areaid] and denaid_areas[areaid].rulesets) then print("[denaid]No such Area: "..areaid.."!") return false end
	if denaid.get_area_ruleset_ident_index(denaid_areas[areaid].rulesets, ruleset.identifier) then
		print("[denaid]Identifier conflict!")
		return false
	end
	table.insert(denaid_areas[areaid].rulesets, ruleset, index)--index will be nil, so no third param.
	return true
end
function denaid.get_ruleset(areaid, identifier)
	if not (denaid_areas[areaid] and denaid_areas[areaid].rulesets) then print("[denaid]No such Area: "..areaid.."!") return false end
	local indx=denaid.get_area_ruleset_ident_index(denaid_areas[areaid].rulesets, identifier)
	if not indx then return nil end
	return denaid_areas[areaid].rulesets[indx]
end
function denaid.set_ruleset(areaid, ruleset)
	if not (denaid_areas[areaid] and denaid_areas[areaid].rulesets) then print("[denaid]No such Area: "..areaid.."!") return false end
	local indx=denaid.get_area_ruleset_ident_index(denaid_areas[areaid].rulesets, ruleset.identifier)
	if not indx then return false end
	denaid_areas[areaid].rulesets[indx]=ruleset
	return true
end
function denaid.set_ruleset_at_index(areaid, identifier, index)
	if not (denaid_areas[areaid] and denaid_areas[areaid].rulesets) then print("[denaid]No such Area: "..areaid.."!") return false end
	local indx=denaid.get_area_ruleset_ident_index(denaid_areas[areaid].rulesets, identifier)
	if not indx then return false end
	local rls=table.remove(denaid_areas[areaid].rulesets, indx)
	denaid.insert_ruleset_to_index(areaid, rls, index)
	return true
end
function denaid.remove_ruleset_by_index(areaid, index)
	if not (denaid_areas[areaid] and denaid_areas[areaid].rulesets) then print("[denaid]No such Area: "..areaid.."!") return false end
	return table.remove(denaid_areas[areaid].rulesets, indx)
end
function denaid.remove_ruleset(areaid, identifier)
	if not (denaid_areas[areaid] and denaid_areas[areaid].rulesets) then print("[denaid]No such Area: "..areaid.."!") return false end
	local indx=denaid.get_area_ruleset_ident_index(denaid_areas[areaid].rulesets, identifier)
	if not indx then return false end
	return table.remove(denaid_areas[areaid].rulesets, indx)
end
function denaid.clear_rulesets(areaid)
	if not (denaid_areas[areaid] and denaid_areas[areaid].rulesets) then print("[denaid]No such Area: "..areaid.."!") return false end
	local rem=denaid_areas[areaid].rulesets
	denaid_areas[areaid].rulesets={}
	return rem
end

--end api implementations




--load initially
denaid.fpath=minetest.get_worldpath().."/denaid_areas"
local file, err = io.open(denaid.fpath, "r")
if not file then
	denaid_areas = denaid_areas or {}
	local er=err or "Unknown Error"
	print("[denaid]Failed loading denaid areas file "..er)
else
	denaid_areas = minetest.deserialize(file:read("*a"))
	if type(denaid_areas) ~= "table" then
		denaid_areas={}
	end
	file:close()
end


denaid.save = function()
	local datastr = minetest.serialize(denaid_areas)
	if not datastr then
		minetest.log("error", "[denaid] Failed to serialize area data!")
		return
	end
	local file, err = io.open(denaid.fpath, "w")
	if err then
		return err
	end
	file:write(datastr)
	file:close()
end



--table, ids are identifier strings.
----name:identifier of area
----fname:full name of area
----owner:player name of owner
----coord1:x/y/z minimum coords
----coord2:x/y/z maximum coords
----priority:number, tells if some area is superior to another
----pvp:boolean if it is enabled
----monsters: alow monster spawning
----rulesets:table
------players: string players separated by semicola, or @a
------enter: bool may enter
------use:   allow richt klick on blocks / inventory transactions
------build: allow building/harvesting
------identifier: can be nil, used by api.

--if no rulesets are applying:no entry, no build, no use

--denaid.check_permission(action, pname, areaids)
--where action is one of "use", "enter", "build"
--areaids should be a ipairable table
--returns: true or (false and a message)

denaid.check_permission=function(action, pname, areaid)
	
	if minetest.check_player_privs(pname, {denaid_bypass=true}) then
		return true
	end
	local action_n=action..""
	--if action=="inv" then
	--	action_n="use"
	--end
	--print("[denaid]checkpermission action="..action.." pname="..pname.." areaids:"..dump(areaids));
	local all_allow=true

	local ar=denaid_areas[areaid];
	if not ar then
		print("[denaid]Area not found:"..areaid);
		return true
	end
	if ar.owner~=pname then
		if not (action_n=="enter" and string.match(areaid, "^_.+") and ar.priority==2) then--this is a self-protected area
			
			if not ar.rulesets then
				ar.rulesets={}
			end
			--if #ar.rulesets==0 then  ---this is useless
			--	return false, string.format(denaid.falsemessages[action], ar.fname).."(no rulesets.)"
			--end
						local applied=false
			for _,rule in ipairs(ar.rulesets) do
				if rule.inv~=true then rule.inv=false end
				if not applied and denaid.rule_applies(rule.players, pname, ar.owner) then
					local allow= rule[action_n]
					all_allow=all_allow and allow
					--goto end
					applied=true
				end
			end
			--if no ruleset applies: deny action
			if not applied then
				all_allow=false
			end
			
		end
		--::end::
	else
		all_allow=true
	end
	return all_allow
end

denaid.rule_applies=function(rulestr, pname, owner)--owner is used to notify when there are misconfigured rulesets (currently it is not possible to produce such things, so it is ignored.)
	--print("[denaid][debug]rule applies: >"..rulestr.."< on >"..pname.."<")
	if rulestr=="@a" then
		return true
	else
		--print("[denaid][debug]rule applies in else: >"..rulestr.."< on >"..pname.."<")
		for str in string.gmatch(rulestr, "([^;%s]+)") do
			--print("[denaid][debug]check partstring: >"..str.."< on >"..pname.."<")
			if(str==pname) then
				--print("[denaid][debug]fit: >"..rulestr.."< part >"..str.."< on >"..pname.."<")
				return true
			end
        end
	end
	return false
end

denaid.get_areas_at=function(pos)
	local last_prior=0
	local list_of_areaids={}
	for ident, area in pairs(denaid_areas) do
		if area then
			--print("[denaid]area chk: "..ident.."->"..dump(area))
			if denaid.area_here(area, pos) then
				--print("[denaid]found area "..ident.." at position")
				if area.priority>last_prior then
					list_of_areaids={}
					list_of_areaids[1]=ident
					last_prior=area.priority
				elseif area.priority==last_prior then
					list_of_areaids[#list_of_areaids+1]=ident
				end
			end
		end
	end
	return list_of_areaids
end

denaid.area_here=function(area, pos)
	local px, py, pz = pos.x, pos.y, pos.z
	local ap1, ap2 = area.coord1, area.coord2
	if px >= ap1.x and px <= ap2.x and
		py >= ap1.y and py <= ap2.y and
		pz >= ap1.z and pz <= ap2.z then
	return true
	end
end

--callbacks

minetest.register_on_prejoinplayer(function(name, ip)
	if name=="_NONAME" then return "Choose another name, this one is used internally." end
end)


--(former) position golbalstep
denaid.save_cntdn=10
minetest.register_globalstep(function(dtime)
		
		--and it will save everything
		if denaid.save_cntdn<=0 then
			denaid.save()
			denaid.save_cntdn=10 --10 seconds interval!
		end
		denaid.save_cntdn=denaid.save_cntdn-dtime
end)



denaid.fs_message=function(pname, msg)
minetest.show_formspec(pname, "denaidmessage", "size[10,1]label[0.2,0.2;"..msg.."]")
end
--[[

name="test",
		owner="orwell",
		fname="Test",
		coord1={x=0, y=0, z=0},
		coord2={x=100, y=100, z=100},
		priority=0,
		pvp=true,
		monsters=false,
		rulesets={
]]

--returns true or false and an error message
denaid.add_area=function(name, owner, fname, coord1, coord2, priority)
	if denaid_areas[name] then
		print("[denaid]Failed adding area "..name..": Name is already given.")
		return false
	end
	if not (name and owner and fname and coord1 and coord2 and priority) then
		print("[denaid]Area not created, because at least one parameter was nil\nParameters were (in order name, owner, fname, coord1, coord2, priority):\n",name, owner, fname, coord1, coord2, priority)
		return false
	end
	denaid_areas[name]={
		name=name,
		owner=owner,
		fname=fname,
		coord1=coord1,
		coord2=coord2,
		priority=priority,
		pvp=true,
		monsters=true,
		rulesets={}
	}
	return true
end

denaid.edit_area=function(name, owner, fname, coord1, coord2, priority)
	if not denaid_areas[name] then
		print("[denaid]Area "..name.." doesn't exist. Will add the area now.")
		return denaid.add_area(name, owner, fname, coord1, coord2, priority)
	end
	local old=denaid_areas[name]
	denaid_areas[name]={
		name=name or old.name,
		owner=owner or old.owner,
		fname=fname or old.fname,
		coord1=coord1 or old.coord1,
		coord2=coord2 or old.coord2,
		priority=priority or lod.priority,
		pvp=old.pvp,
		monsters=old.monsters,
		rulesets=old.rulesets
	}
	return true
end

--commands for the admin

core.register_chatcommand("denaid_info", {
	params = "areaid",
	description = "show info of area",
	privs = {},
	func = function(name, param)
		denaid.show_info_form(name, param)
	end,
})

--these are deprecated as there is a formspec for that.
core.register_chatcommand("denaid_add", {
	params = "areaid:owner:disp-name:x,y,z:x,y,z:priority",
	description = "add area",
	privs = {denaid_admin=true},
	func = function(name, param)
		local name, owner, fname, x1, y1, z1, x2, y2, z2, priority=string.match(param, "([^:]+):([^:]+):([^:]+):([^:,]+),([^:,]+),([^:,]+):([^:,]+),([^:,]+),([^:,]+):([^:]+)")
		if not (name and owner and fname and x1 and y1 and z1 and x2 and x2 and z2 and priority) then
			return true, "Failed, wrong syntax"
		end
		local coord1, coord2={x=x1+0, y=y1+0, z=z1+0}, {x=x2+0, y=y2+0, z=z2+0}

		suc, err=denaid.add_area(name, owner, fname, coord1, coord2, priority)
		if not suc then
			return true, err
		end
		return true, "successful."
	end,
})
core.register_chatcommand("denaid_edit", {
	params = "areaid:owner:disp-name:x,y,z:x,y,z:priority",
	description = "edit area things. write ~ to keep old value",
	privs = {denaid_admin=true},
	func = function(name, param)
		local name, owner, fname, x1, y1, z1, x2, y2, z2, priority=string.match(param, "([^:]+):([^:]+):([^:]+):([^:,]+),([^:,]+),([^:,]+):([^:,]+),([^:,]+),([^:,]+):([^:]+)")
		if not (name and owner and fname and x1 and y1 and z1 and x2 and x2 and z2 and priority) then
			return true, "Failed, wrong syntax"
		end
		local ar=denaid_areas[name]
		if owner~="~" then ar.owner=owner end
		if fname~="~" then ar.fname=fname end
		if priority~="~" then ar.priority=priority end
		if x1~="~" then ar.coord1.x=x1 end
		if y1~="~" then ar.coord1.y=y1 end
		if z1~="~" then ar.coord1.z=z1 end
		if x2~="~" then ar.coord2.x=x2 end
		if y2~="~" then ar.coord2.y=y2 end
		if z2~="~" then ar.coord2.z=z2 end

		return true, "done."
	end,
})

--gui system for the admin stuff(meaning area edit dialog)
denaid.coord_a={}
denaid.coord_b={}
denaid.coord_c={}
denaid.coord_d={}
--tables for setcoord. up to 4 coordinates are saveable.
core.register_chatcommand("denaid_coord_a", {
	params = "",
	description = S("Set coordinate @1", "A"),
	privs = {denaid_admin=true},
	func = function(name, param)
	denaid.coord_a[name]=denaid.roundcoord(minetest.get_player_by_name(name):getpos())
	return true, S("Coordinate @1 has been set to @2", "A", minetest.pos_to_string(denaid.coord_a[name]))
end,
})
core.register_chatcommand("denaid_coord_b", {
	params = "",
	description = S("Set coordinate @1", "B"),
	privs = {denaid_admin=true},
	func = function(name, param)
	denaid.coord_b[name]=denaid.roundcoord(minetest.get_player_by_name(name):getpos())
	return true, S("Coordinate @1 has been set to @2", "B", minetest.pos_to_string(denaid.coord_a[name]))
	end,
})
core.register_chatcommand("denaid_coord_c", {
	params = "",
	description = S("Set coordinate @1", "C"),
	privs = {denaid_admin=true},
	func = function(name, param)
	denaid.coord_c[name]=denaid.roundcoord(minetest.get_player_by_name(name):getpos())
	return true, S("Coordinate @1 has been set to @2", "C", minetest.pos_to_string(denaid.coord_a[name]))
	end,
})
core.register_chatcommand("denaid_coord_d", {
	params = "",
	description = S("Set coordinate @1", "D"),
	privs = {denaid_admin=true},
	func = function(name, param)
	denaid.coord_d[name]=denaid.roundcoord(minetest.get_player_by_name(name):getpos())
	return true, S("Coordinate @1 has been set to @2", "D", minetest.pos_to_string(denaid.coord_a[name]))
end,
})
--main command for admin area management!
core.register_chatcommand("denaid", {
	params = "areaid",
	description = "open edit form",
	privs = {denaid_admin=true},
	func = function(name, param)
	denaid.editorformspec(param, name)
end,
})

minetest.register_privilege("denaid_admin", {
	description = "Admin for denaid-areas."
})

denaid.roundcoord=function(pos)
	return {x=math.floor(pos.x+0.5), y=math.floor(pos.y+0.5), z=math.floor(pos.z+0.5)}
end

--areaid:owner:disp-name:x,y,z:x,y,z:priority
denaid.editorformspec=function(areaid, pname, over_c1, over_c2)
	local c1, c2, owner, disp_name, priority, infotext
	if areaid and denaid_areas[areaid] then
		local ar=denaid_areas[areaid]
		c1=ar.coord1
		c2=ar.coord2
		owner=ar.owner
		disp_name=ar.fname
		priority=ar.priority
		infotext=S("Loaded area @1", areaid)
	else
		infotext=S("An area with this ID does not exist, 'write' will create it.")
		c1={x=0, y=0, z=0}
		c2={x=0, y=0, z=0}
		owner=S("nobody")
		disp_name=S("New Area")
		priority=0
		areaid=""
	end
	if over_c1 then
		c1=over_c1
	end
	if over_c2 then
		c2=over_c2
	end


	minetest.show_formspec(pname, "denaideditor", [[
	size[10,10]
	field[1,2;1,1;c1x;C1 x;]]..c1.x..[[]    field[2,2;1,1;c1y;y;]]..c1.y..[[]    field[3,2;1,1;c1z;z;]]..c1.z..[[]
	button[4,2;1,1;c1a;<a]   button[5,2;1,1;c1b;<b]   button[6,2;1,1;c1c;<c]   button[7,2;1,1;c1d;<d]

	field[1,4;1,1;c2x;c2 x;]]..c2.x..[[]    field[2,4;1,1;c2y;y;]]..c2.y..[[]    field[3,4;1,1;c2z;z;]]..c2.z..[[]
	button[4,4;1,1;c2a;<a]   button[5,4;1,1;c2b;<b]   button[6,4;1,1;c2c;<c]   button[7,4;1,1;c2d;<d]

	field[1,6;5,1;owner;]]..S("Owner")..";"..owner..[[]
	field[1,7;5,1;disp_name;]]..S("Display name")..";"..disp_name..[[]
	field[6,6;3,1;priority;]]..S("Priority")..";"..priority..[[]

	field[1,8;5,1;areaid;]]..S("ID to edit/add/load")..";"..areaid..[[]

	button[1,9;3,1;wri;]]..S("Write").."]"..
	"button[4,9;3,1;get;"..S("Load").."]"..
	"button[7,9;3,1;inf;"..S("Area setup").."]"..
	"button[7,8;3,1;del;"..S("Delete").."]"..
	"label[1,0;"..infotext.."]")
end


denaid.editorformspec_handler=function(pname, fields)
	if minetest.check_player_privs(pname, {denaid_admin=true}) then

		if fields.get then
			denaid.editorformspec(fields.areaid, pname)
			return
		end
		if fields.inf then
			denaid.show_info_form(pname, fields.areaid)
			return
		end
		if fields.del then
			denaid_areas[fields.areaid]=nil
			denaid.fs_message(pname, S("Deleted @1",fields.areaid))
			return
		end
		---abcd stuff.
		--1st: get original coords from fields
		local o1, o2=
		{x=(fields.c1x or 0)+0, y=(fields.c1y or 0)+0, z=(fields.c1z or 0)+0},
		{x=(fields.c2x or 0)+0, y=(fields.c2y or 0)+0, z=(fields.c2z or 0)+0}


		--2nd: actually show it
		if fields.c1a then
			denaid.editorformspec(fields.areaid, pname, denaid.coord_a[pname], o2)
		end
		if fields.c2a then
			denaid.editorformspec(fields.areaid, pname, o1, denaid.coord_a[pname])
		end
		if fields.c1b then
			denaid.editorformspec(fields.areaid, pname, denaid.coord_b[pname], o2)
		end
		if fields.c2b then
			denaid.editorformspec(fields.areaid, pname, o1, denaid.coord_b[pname])
		end
		if fields.c1c then
			denaid.editorformspec(fields.areaid, pname, denaid.coord_c[pname], o2)
		end
		if fields.c2c then
			denaid.editorformspec(fields.areaid, pname, o1, denaid.coord_c[pname])
		end
		if fields.c1d then
			denaid.editorformspec(fields.areaid, pname, denaid.coord_d[pname], o2)
		end
		if fields.c2d then
			denaid.editorformspec(fields.areaid, pname, o1, denaid.coord_d[pname])
		end

		if fields.wri then -- or fields.c1a or fields.c1b or fields.c1c or fields.c1d or fields.c2a or fields.c2b or fields.c2c or fields.c2d then
			--print(dump(denaid_areas))
			denaid.lastareabackup=denaid_areas[fields.areaid]
			if not denaid_areas[fields.areaid] then
				denaid_areas[fields.areaid]={}
				denaid_areas[fields.areaid].rulesets={}
				denaid_areas[fields.areaid].pvp=false
				denaid_areas[fields.areaid].monsters=false
			end

			local sortc1, sortc2=denaid.sort_coords(o1, o2)

			denaid_areas[fields.areaid].owner=fields.owner
			denaid_areas[fields.areaid].priority=fields.priority+0
			denaid_areas[fields.areaid].fname=fields.disp_name
			denaid_areas[fields.areaid].coord1=sortc1
			denaid_areas[fields.areaid].coord2=sortc2
			--print(dump(denaid_areas))
		end


	end
	denaid_areas[""]=nil

end

denaid.sort_coords=function(c1, c2)
	return
		{x=math.min(c1.x, c2.x), y=math.min(c1.y, c2.y), z=math.min(c1.z, c2.z)},
		{x=math.max(c1.x, c2.x), y=math.max(c1.y, c2.y), z=math.max(c1.z, c2.z)}
end

--gui system
--forms:
--[[
denaidinfo_<areaid> :displaying information, edit rulesets.
admin_<areaid> :administration dialog for areas, to set position, name and other stuff.

addarea_<posx1>_<posz1>_<posx2>_<posz2> :area add. for the not yet implemented self-protection.
]]--

local tfback={}
tfback["true"]=true
tfback["false"]=false
tfback[true]=true
tfback[false]=false


denaid.show_info_form=function(player, areaid)
	local areadef=denaid_areas[areaid]
	if not areadef then return end
	if not areadef.rulesets then areadef.rulesets={} end
	local rulesetstr=""
	local first=true
	for _,ruleset in ipairs(areadef.rulesets) do
		
		if ruleset.inv==nil then ruleset.inv=false end--compatibility
		
		local enter, use, build, inv={}, {}, {}, {}
		enter[true], use[true], build[true], inv[true]=S("E"), S("A"), S("B"), S("I")
		enter[false], use[false], build[false], inv[false]="-", "-", "-", "-"
		local rule=enter[ruleset.enter].." "..use[ruleset.use].." "..inv[ruleset.inv].." "..build[ruleset.build].."   "..ruleset.players
		if first then
			rulesetstr=rule
			first=false
		else
			rulesetstr=rulesetstr..","..rule
		end
	end
	local trfa={}
	trfa[true]="true"
	trfa[false]="false"
	local formtext="size[5.5,8]label[0,0;"..areadef.fname.." ("..areaid..")]label[0,0.5;"..minetest.pos_to_string(areadef.coord1).." <-> "..minetest.pos_to_string(areadef.coord2).."]checkbox[0,1;pvp;"..S("PvP")..";"..trfa[areadef.pvp].."]checkbox[0,1.5;monsters;"..S("Allow Mob Spawning")..";"..trfa[areadef.monsters].."]"..
	"label[0,2.5;"..S("Enter Activate Inventory Build   Players").."]textlist[0,3;5,4.5;rulesets;"..rulesetstr..";0;false]"

	if minetest.check_player_privs(player, {denaid_admin=true}) or areadef.owner==player then
		formtext=formtext.."button[0,7.5;2.5,1;addruleset;"..S("Add ruleset").."]button[2.5,7.5;3,1;remruleset;"..S("Remove ruleset").."]"
	end

	minetest.show_formspec(player, "denaidinfo_"..areaid, formtext)
end

denaid.show_ruleset_edit_form=function(player, areaid, ruleindex)
	local areadef=denaid_areas[areaid]
	if not areadef then return end
	if not areadef.rulesets then areadef.rulesets={} end

	local ruleset=areadef.rulesets[ruleindex]
	if not ruleset then return end

	local trfa={}
	trfa[true]="true"
	trfa[false]="false"
	if ruleset.inv==nil then ruleset.inv=false end--compatibility


	local formtext="size[7,6]field[1,1;6,1;players;"..S("Players (separate with spaces, use @1a to address all)", "@")..";"..ruleset.players.."]"..
		"checkbox[0,2;enter;"..S("Allow entering")..";"..trfa[ruleset.enter].."]"..
		"checkbox[0,2.5;use;"..S("Allow right-clicking nodes")..";"..trfa[ruleset.use].."]"..
		"checkbox[0,3;inv;"..S("Allow modifying inventories")..";"..trfa[ruleset.inv].."]"..
		"checkbox[0,3.5;build;"..S("Allow building")..";"..trfa[ruleset.build].."]"..
		"button[0,5;4,1;save;"..S("Save").."]"
	minetest.show_formspec(player, "denaidruleedit_"..areaid..":"..ruleindex, formtext)
end
denaid.show_ruleset_add_form=function(pname, areaid, ruleindex)
	local areadef=denaid_areas[areaid]
	if not areadef then return end
	if not areadef.rulesets then areadef.rulesets={} end
	local rulesetstr=""
	for _,ruleset in ipairs(areadef.rulesets) do
		local enter, use, build, inv={}, {}, {}, {}
		enter[true], use[true], build[true], inv[true]="Z", "A", "B", "I"
		enter[false], use[false], build[false], inv[false]="-", "-", "-", "-"
		local rule=enter[ruleset.enter].." "..use[ruleset.use].." "..inv[ruleset.use].." "..build[ruleset.build].."   "..ruleset.players
		
		rulesetstr=rulesetstr..rule..","
	end
	if rulesetstr=="" then
		table.insert(denaid_areas[areaid].rulesets, {
			players="@a",
			enter=true,
			use=true,
			build=true,
			inv=true
		})
		denaid.show_ruleset_edit_form(pname, areaid, 1)
		return
	else
		rulesetstr=rulesetstr..S("behind all others")
	end
	local trfa={}
	trfa[true]="true"
	trfa[false]="false"
	local formtext="size[5,8]label[0,0;"..areadef.fname.." ("..areaid..")]label[0,1;"..S("Double-click new position").."]"..
	"label[0,2;"..S("Enter Activate Inventory Build   Players").."]textlist[0,3;5,5;rulesets;"..rulesetstr..";0;false]"

	minetest.show_formspec(pname, "denaidruleadd_"..areaid, formtext)
end
denaid.show_ruleset_remove_form=function(player, areaid, ruleindex)
	local areadef=denaid_areas[areaid]
	if not areadef then return end
	if not areadef.rulesets then areadef.rulesets={} end
	local rulesetstr=""
	local first=true
	for _,ruleset in ipairs(areadef.rulesets) do
		local enter, use, build, inv={}, {}, {}, {}
		enter[true], use[true], build[true], inv[true]="Z", "A", "B", "I"
		enter[false], use[false], build[false], inv[false]="-", "-", "-", "-"
		local rule=enter[ruleset.enter].." "..use[ruleset.use].." "..inv[ruleset.use].." "..build[ruleset.build].."   "..ruleset.players
		if first then
			rulesetstr=rule
			first=false
		else
			rulesetstr=rulesetstr..","..rule
		end
	end
	local trfa={}
	trfa[true]="true"
	trfa[false]="false"
	local formtext="size[5,8]label[0,0;"..areadef.fname.." ("..areaid..")]label[0,1;"..S("Double-click entry to delete").."]"..
	"label[0,2;"..S("Enter Activate Inventory Build   Players").."]textlist[0,3;5,5;rulesets;"..rulesetstr..";0;false]"

	minetest.show_formspec(player, "denaidruleremove_"..areaid, formtext)
end

denaid.fields=function(player, formname, fields)
	--print("[denaid] formname "..formname)
	local areaid=string.match(formname, "denaidinfo_(.+)")
	if areaid then
		--print("[denaid] accepting form")
		if denaid_areas[areaid] then
			--fields got send over
			local ar=denaid_areas[areaid]
			local pname=player:get_player_name()

			if minetest.check_player_privs(pname, {denaid_admin=true}) or ar.owner==pname then
				--do anything
				if fields.pvp then
					denaid_areas[areaid].pvp=tfback[fields.pvp]
				end
				if fields.monsters then
					denaid_areas[areaid].monsters=tfback[fields.monsters]
				end
				if fields.rulesets then
					local val=minetest.explode_textlist_event(fields.rulesets)
					if val.type=="DCL" then
						denaid.show_ruleset_edit_form(pname, areaid, val.index)
					end
				end
				if fields.addruleset then
					denaid.show_ruleset_add_form(pname, areaid)
				end
				if fields.remruleset then
					denaid.show_ruleset_remove_form(pname, areaid)
				end
			else
				denaid.fs_message(pname, S("You are not allowed to do this!"))
			end
		end
	end
	areaid=string.match(formname, "denaidruleadd_(.+)")
	if areaid then
		if denaid_areas[areaid] then
			--fields got send over
			local ar=denaid_areas[areaid]
			local pname=player:get_player_name()

			if minetest.check_player_privs(pname, {denaid_admin=true}) or ar.owner==pname then
				--do anything
				if fields.rulesets then
					local val=minetest.explode_textlist_event(fields.rulesets)
					if val.type=="DCL" then
						table.insert(denaid_areas[areaid].rulesets, val.index, {
							players="@a",
							enter=true,
							use=true,
							build=true,
							inv=true
						})
						denaid.show_ruleset_edit_form(pname, areaid, val.index)
					end
				end
			else
				denaid.fs_message(pname, S("You are not allowed to do this!"))
			end
		end
	end
	areaid=string.match(formname, "denaidruleremove_(.+)")
	if areaid then
		if denaid_areas[areaid] then
			--fields got send over
			local ar=denaid_areas[areaid]
			local pname=player:get_player_name()

			if minetest.check_player_privs(pname, {denaid_admin=true}) or ar.owner==pname then
				--do anything
				if fields.rulesets then
					local val=minetest.explode_textlist_event(fields.rulesets)
					if val.type=="DCL" then
						table.remove(denaid_areas[areaid].rulesets, val.index)
						denaid.show_info_form(pname, areaid)
					end
				end
			else
				denaid.fs_message(pname, S("You are not allowed to do this!"))
			end
		end
	end
	local inde
	areaid, inde=string.match(formname, "denaidruleedit_([^:]+):(.+)")
	if areaid then
		local index=inde+0
		if denaid_areas[areaid] then
			--fields got send over
			local ar=denaid_areas[areaid]
			if not ar.rulesets[index] then return end

			local pname=player:get_player_name()

			if minetest.check_player_privs(pname, {denaid_admin=true}) or ar.owner==pname then
				--do anything
				if fields.players then
					denaid_areas[areaid].rulesets[index].players=fields.players
				end
				if fields.enter then
					denaid_areas[areaid].rulesets[index].enter=tfback[fields.enter]
				end
				if fields.use then
					denaid_areas[areaid].rulesets[index].use=tfback[fields.use]
				end
				if fields.inv then
					denaid_areas[areaid].rulesets[index].inv=tfback[fields.inv]
				end
				if fields.build then
					denaid_areas[areaid].rulesets[index].build=tfback[fields.build]
				end
				if fields.save then
					denaid.show_info_form(pname, areaid)
				end
			else
				denaid.fs_message(pname, S("You are not allowed to do this!"))
			end
		end
	end
	
	if formname=="denaideditor" then
		print("[denaid] editor formspec")
		denaid.editorformspec_handler(player:get_player_name(), fields)
	end
	return false
end

minetest.register_on_player_receive_fields(denaid.fields)

--register tyrant integration!
tyrant.register_integration("denaid", {
	get_all_area_ids=function()
		return false, denaid_areas
	end,
	get_is_area_at=function(areaid, pos)
		return denaid.area_here(denaid_areas[areaid], pos)
	end,
	get_area_priority=function(areaid)
		if not denaid_areas[areaid] then error(areaid.." not found") end
		return denaid_areas[areaid].priority
	end,
	check_permission=function(areaid, name, action)
		if not name or name=="" then
			name="_NONAME"
		end
		if action=="enter" or action=="inv" or action=="build" then
			local allow=denaid.check_permission(action, name, areaid)
			return allow
		elseif action=="activate" then
			local allow=denaid.check_permission("use", name, areaid)
			return allow
		elseif action=="pvp" then
			local m=denaid_areas[areaid].pvp
			return m, not m and S("PvP is not allowed here!")
		end
		return true--on action=="punch" and no player in pvp callback
	end,
	get_area_intersects_with=function(areaid, p1, p2)
		local area=denaid_areas[areaid]
		if not area then return false end
		local pos1, pos2 = area.coord1, area.coord2
		if (p1.x <= pos2.x and p2.x >= pos1.x) and
					(p1.y <= pos2.y and p2.y >= pos1.y) and
					(p1.z <= pos2.z and p2.z >= pos1.z) then
			return true
		end
		return false
	end,
	is_hostile_mob_spawning_allowed=function(areaid)
		return denaid_areas[areaid].monsters
	end,
	on_area_info_requested=function(areaid, player_name)
		denaid.show_info_form(player_name, areaid)
	end,
	get_display_name=function(areaid)
		return denaid_areas[areaid].fname
	end
})
