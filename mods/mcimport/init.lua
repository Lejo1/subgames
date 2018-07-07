-- map conversion requires a special water level
minetest.set_mapgen_params({water_level = -2})

-- prevent overgeneration in incomplete chunks, and allow lbms to work
minetest.set_mapgen_params({chunksize = 1})

-- comment the line below if you want to enable mapgen (will destroy things!)
minetest.set_mapgen_params({mgname = "singlenode"})
