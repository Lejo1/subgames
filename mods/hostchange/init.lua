local info = [[The host has changed! The server is not down you can find it on the serverlist, just serach for "Subgames for all!" Have fun with the new lag free server. Der server hoster wurde geändert! Der server ist immer noch online, du kannst ihn auf der serverliste finden suche einfach nach: "Subgames for all!" Der server wird weniger laggen. :)]]

minetest.register_on_prejoinplayer(function(_, ip)
	return info
end)
