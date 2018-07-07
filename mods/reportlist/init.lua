--[[This is a mod that contains a player register with the count of the reports.
          Mod created by Lejo!]]
report = {
	report_on_cheat = {
		enable = true,
		only_one_report_per_cheat = false,
		report_count_on_cheat = 1,
		player_message_on_report_cheat = true,
		global_chat_message_on_report_cheat = false,
	},
	autoban = false,
	autotempban = false,
	ban_notification_in_chat = false,
	time_played_to_report = 3600, --  in seconds  Only needed when useing playtime
}
reportfunc = {}

function reportfunc.set_count(name, amount)
	local e = xban.find_entry(name)
	e.reported = amount
	reportfunc.check_ban(name)
end

function reportfunc.get_count(name)
	local e = xban.find_entry(name)
	if e and e.reporter then
		return e.reported
	else return 0
	end
end

function reportfunc.is_reporter(name, reportername)
	local reporterentry = xban.find_entry(reportername)
	local e = xban.find_entry(name)
	if e.reporter and reporterentry.names then
		for testi,value in ipairs(e.reporter) do
			if reporterentry.names[value] then
				return true
			end
		end
	end
end

function reportfunc.add_reporter(name, reportername)
	local reportertable = xban.find_entry(name)
	if not table.contains(reportertable.reporter, reportername) then
		table.insert(reportertable.reporter, reportername)
	end
end

--Create player acout if there is no
minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
	local e = xban.find_entry(name)
  if e and not e.reported then
		e.reported = 0
		e.reporter = {}
	end
	reportfunc.check_ban(name)
end)

--  Auto ban players
function reportfunc.check_ban(name)
	if reportfunc.get_count(name) >= 20 and report.autoban == true then
		xban.ban_player(name, "Reportmod", nil, "You have been reported 20 times or cheated to much! Make sure you are useing an orginal minetest client.")
		minetest.log("action", "Player "..name.." has been baned after he got reported 20 times.")
		if report.ban_notification_in_chat == true then
			minetest.chat_send_all("Player "..name.." has been baned, because he has been reported 20 times or cheated to much!")
		end
	elseif reportfunc.get_count(name) >= 10 and report.autotempban == true and not xban.get_record(name) then
		xban.ban_player(name, "Reportmod", os.time()+259200, "You have been reported 10 times or cheated to much!")
		minetest.log("action", "Player "..name.." has been baned for three days after he got reported 10 times.")
		if report.ban_notification_in_chat == true then
			minetest.chat_send_all("Player "..name.." has been baned for three days, because he has been reported 10 times or cheated to much!")
		end
	end
end

--  May report players on cheat
if report.report_on_cheat["enable"] == true then
	minetest.register_on_cheat(function(player, cheat)
		local name = player:get_player_name()
		if cheat.type == "dug_unbreakable" or cheat.type == "dug_too_fast" then
			local reporthim = true
			if report.report_on_cheat["only_one_report_per_cheat"] == true then
				if reportfunc.is_reporter(name, cheat.type) == true then
					reporthim = false
				else reportfunc.add_reporter(name, cheat.type)
				end
			end
			if reporthim == true then
				local count = report.report_on_cheat["report_count_on_cheat"]
				reportfunc.set_count(name, reportfunc.get_count(name)+count)
				if report.report_on_cheat["player_message_on_report_cheat"] == true then
					minetest.chat_send_player(name, "Are you hacking/cheating?   Stop it!")
				end
				if report.report_on_cheat["global_chat_message_on_report_cheat"] == true then
					minetest.chat_send_all(name.." is maybe hacking: "..cheat.type.." ! Have a look at him.")
				end
				minetest.log("action", "Player "..name.." has been reported automaticly by cheating with: "..cheat.type)
			end
		end
	end)
end

--  Add the report Command
minetest.register_chatcommand("report", {
  privs = {shout=true},
  params = "<name>",
  description = "Use it to report players, if they are hacking, cheating...",
  func = function(name, param)
    local reportcount = 1
    if minetest.get_player_privs(name).ban then
      reportcount = 10
    elseif minetest.get_player_privs(name).kick then
      reportcount = 5
    end
		local ename = xban.find_entry(name)
		local eparam = xban.find_entry(param)
    if ename and eparam then
			if name ~= param and ename ~= eparam then
				if minetest.get_player_by_name(param) then
					if minetest.get_player_information(name).connection_uptime >= 480 then
						if not playtime or playtime.get_total_playtime(name) >= report.time_played_to_report then
							if reportfunc.is_reporter(param, name) ~= true then
      					reportfunc.set_count(param, reportfunc.get_count(param)+reportcount)
								reportfunc.add_reporter(param, name)
      					minetest.chat_send_player(name, param.." has been reported!")
								minetest.log("action", "Player "..param.." has been reported by "..name)
							else minetest.chat_send_player(name, "You have already have reported "..param.." or somebody out of his ip-Group!")
							end
						else minetest.chat_send_player(name, "You have to play longer to report a player!")
						end
					else minetest.chat_send_player(name, "You have to play longer to report a player!")
					end
				else minetest.chat_send_player(name, "The Player "..param.." is not online!")
				end
			else minetest.chat_send_player(name, "You can't report yourself or somebody out of you ip-Group.")
			end
    else minetest.chat_send_player(name, "The Player "..param.." don't exist.")
    end
  end,
})

--  Add a chat command to get the report counter
minetest.register_chatcommand("report_get", {
	privs = {ban=true},
	params = "<name>",
	description = "Use it to get the report count of a player.",
	func = function(name, param)
		local count = reportfunc.get_count(param)
		if count ~= "" then
			minetest.chat_send_player(name, "The Player "..param.." has a reportcount of "..count.."!")
		else minetest.chat_send_player(name, "The Player "..param.." don't exist.")
		end
	end,
})

--  Add a chat command to set the report counter
minetest.register_chatcommand("report_set", {
	privs = {ban=true},
	params = "<name> <amount>",
	description = "Use it to set the report count of a player.",
	func = function(name, param)
		local pname, amount1 = param:match("(%S+)%s+(.+)")
		local amount = tonumber(amount1)
		local count = reportfunc.get_count(pname)
		if count ~= "" and tonumber(amount) then
			reportfunc.set_count(pname, amount)
			minetest.chat_send_player(name, "The reportcount of the Player "..pname.." has been setted!")
		else minetest.chat_send_player(name, "The Player don't exist.")
		end
	end,
})
