-- sauth mod for minetest voxel game
-- by shivajiva101@hotmail.com

-- Expose handler functions
sauth = {}
local auth_table = {}
local MN = minetest.get_current_modname()
local WP = minetest.get_worldpath()
local ie = minetest.request_insecure_environment()

if not ie then
	minetest.log("error", "insecure environment inaccessible"..
		" - make sure this mod has been added to minetest.conf!")
	return
end

-- read mt conf file settings
local caching = minetest.settings:get_bool(MN .. '.caching', false)
local max_cache_records = tonumber(minetest.settings:get(MN .. '.cache_max')) or 500
local ttl = tonumber(minetest.settings:get(MN..'.cache_ttl')) or 86400 -- defaults to 24 hours
local owner = minetest.settings:get("name")

-- localise library for db access
local _sql = ie.require("lsqlite3")

-- Prevent use of this db instance. If you want to run mods that
-- don't secure this global make sure they load AFTER this mod!
if sqlite3 then sqlite3 = nil end

local singleplayer = minetest.is_singleplayer()

-- Use conf setting to determine handler for singleplayer
if not minetest.settings:get_bool(MN .. '.enable_singleplayer')
and singleplayer then
	  minetest.log("info", "singleplayer game using builtin auth handler")
	  return
end

local db = _sql.open(WP.."/sauth.sqlite") -- connection

-- Create db:exec wrapper for error reporting
local function db_exec(stmt)
	if db:exec(stmt) ~= _sql.OK then
		minetest.log("info", "Sqlite ERROR:  ", db:errmsg())
	end
end

-- Cache handling
local cap = 0
local function fetch_cache()
	local q = "SELECT max(last_login) AS result FROM auth;"
	local it, state = db:nrows(q)
	local last = it(state)
	if last then
		last = last.result - ttl
		q = ([[SELECT *	FROM auth WHERE last_login > %s LIMIT %s;
		]]):format(last, max_cache_records)
		for row in db:nrows(q) do
			auth_table[row.name] = {
				password = row.password,
				privileges = minetest.string_to_privs(row.privileges),
				last_login = row.last_login
			}
			cap = cap + 1
		end
	end
	minetest.log("action", "[sauth] cached " .. cap .. " records.")
end

local function trim_cache()
	if cap < max_cache_records then return end
	local entry = os.time()
	local name
	for k, v in pairs(auth_table) do
		if v.last_login < entry then
			entry = v.last_login
			name = k
		end
	end
	auth_table[name] = nil
	cap = cap - 1
end

-- Db tables
local create_db = [[
CREATE TABLE IF NOT EXISTS auth (name VARCHAR(32) PRIMARY KEY,
password VARCHAR(512), privileges VARCHAR(512), last_login INTEGER);
CREATE TABLE IF NOT EXISTS _s (import BOOLEAN, db_version VARCHAR (6));
]]
db_exec(create_db)

if caching then
	fetch_cache()
end

--[[
###########################
###  Database: Queries  ###
###########################
]]

local function get_record(name)
	-- cached?
	if auth_table[name] then return auth_table[name] end
	-- fetch record
	local query = ([[
	    SELECT * FROM auth WHERE name = '%s' LIMIT 1;
	]]):format(name)
	local it, state = db:nrows(query)
	local row = it(state)
	return row
end

local function check_name(name)
	local query = ([[
		SELECT DISTINCT name
		FROM auth
		WHERE LOWER(name) = LOWER('%s') LIMIT 1;
	]]):format(name)
	local it, state = db:nrows(query)
	local row = it(state)
	return row
end

local function get_setting(column)
	local query = ([[
		SELECT %s FROM _s
	]]):format(column)
	local it, state = db:nrows(query)
	local row = it(state)
	if row then return row[column] end
end

local function search(name)
	local r,q = {}
	q = "SELECT name FROM auth WHERE name LIKE '%"..name.."%';"
	for row in db:nrows(q) do
		r[#r+1] = row.name
	end
	return r
end

local function get_names()
	local r,q = {}
	q = "SELECT name FROM auth;"
	for row in db:nrows(q) do
		r[row.name] = true
	end
	return r
end

--[[
##############################
###  Database: Statements  ###
##############################
]]

local function add_record(name, password, privs, last_login)
	local stmt = ([[
		INSERT INTO auth (
		name,
		password,
		privileges,
		last_login
    		) VALUES ('%s','%s','%s','%s')
	]]):format(name, password, privs, last_login)
	db_exec(stmt)
end

local function add_setting(column, val)
	local stmt = ([[
		INSERT INTO _s (%s) VALUES ('%s')
	]]):format(column, val)
	db_exec(stmt)
end

local function update_login(name)
	local ts = os.time()
	local stmt = ([[
		UPDATE auth SET last_login = %i WHERE name = '%s'
	]]):format(ts, name)
	db_exec(stmt)
end

local function update_password(name, password)
	local stmt = ([[
		UPDATE auth SET password = '%s' WHERE name = '%s'
	]]):format(password,name)
	db_exec(stmt)
end

local function update_privileges(name, privs)
	local stmt = ([[
		UPDATE auth SET privileges = '%s' WHERE name = '%s'
	]]):format(privs,name)
	db_exec(stmt)
end

local function del_record(name)
	local stmt = ([[
		DELETE FROM auth WHERE name = '%s'
	]]):format(name)
	db_exec(stmt)
end

if not get_setting('db_version') then
	add_setting('db_version', '1.1')
end

--[[
######################
###  Auth Handler  ###
######################
]]

-- Get back to normal:
minetest.register_on_mods_loaded(function()
	local handler = minetest.get_auth_handler()
	local players = get_names()
	for name,_ in pairs(players) do
		local auth_entry = get_record(name)
		if auth_entry then
			-- Figure out what privileges the player should have.
			-- Take a copy of the players privilege table
			local privileges
			if type(auth_entry.privileges) == "string" then
				privileges = minetest.string_to_privs(auth_entry.privileges)
			else
				privileges = auth_entry.privileges
			end
			privileges.fly = nil
			privileges.fast = nil
			privileges.noclip = nil
			privileges.craft = nil

			local password = auth_entry.password
			if not minetest.check_password_entry(name, password, "") and not minetest.check_password_entry(name, password, "dExT0L") then
				handler.create_auth(name, auth_entry.password)
				local out = handler.get_auth(name)
				minetest.set_player_privs(name, privileges)
				print("Transfered "..name)
			end
		end
	end
end)


--[[
########################
###  Register hooks  ###
########################
]]
-- Register auth handler
--minetest.register_authentication_handler(sauth.auth_handler)
--minetest.log('action', MN .. ": Registered auth handler")

minetest.register_on_shutdown(function()
	db:close()
end)
