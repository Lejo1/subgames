
local dyes = {
	{"white",      "White",      nil},
	{"grey",       "Grey",       "basecolor_grey"},
	{"black",      "Black",      "basecolor_black"},
	{"red",        "Red",        "basecolor_red"},
	{"yellow",     "Yellow",     "basecolor_yellow"},
	{"green",      "Green",      "basecolor_green"},
	{"cyan",       "Cyan",       "basecolor_cyan"},
	{"blue",       "Blue",       "basecolor_blue"},
	{"magenta",    "Magenta",    "basecolor_magenta"},
	{"orange",     "Orange",     "excolor_orange"},
	{"violet",     "Violet",     "excolor_violet"},
	{"brown",      "Brown",      "unicolor_dark_orange"},
	{"pink",       "Pink",       "unicolor_light_red"},
	{"dark_grey",  "Dark Grey",  "unicolor_darkgrey"},
	{"dark_green", "Dark Green", "unicolor_dark_green"},
}

-- Register carpets
for _, row in ipairs(dyes) do
	local name = row[1]
	local desc = row[2]
	
	-- Node Definition
	minetest.register_node("carpet:" .. name, {
		description = desc .. " Carpet",
		tiles = {"wool_" .. name .. ".png"},
		is_ground_content = true,
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5,  0.5, -0.57+2/16, 0.5},
			},
		},
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 3, flammable = 3, carpet = 1, attached_node = 1},
		sounds = default.node_sound_defaults(),
	})
end
