--[[				Getip
			Minetest Mod from Lejo
	Use it to get always the last ip of a player, if he isn't online.
]]

getip = {}

local ip = {}

--Add the Privileg.
minetest.register_privilege("ip", "Player can get ip's from other players")

--create new data for a player if it doesn't exist.
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local players_ip = minetest.get_player_ip(name)
	ip[name] = players_ip	
end)

--Creat the Command /getip.
minetest.register_chatcommand("getip", {
	params = "<player>",
	description = "Show other ips.",
	privs = {ip=true},
	func = function(name, player)
		if not minetest.get_player_by_name(player) then
			minetest.chat_send_player(name, "The Player is not online")
			if ip[player] then
				minetest.chat_send_player(name, "His last ip was: \""..ip[player].."\".")
			else minetest.chat_send_player(name, "There is no ip saved for this player.")
			end
		else	
			minetest.chat_send_player(name, "The IP is \""..minetest.get_player_ip(player).."\".")
		end
	end,
})
