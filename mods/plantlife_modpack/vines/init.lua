vines = {
  name = 'vines',
  recipes = {}
}

dofile( minetest.get_modpath( vines.name ) .. "/functions.lua" )
dofile( minetest.get_modpath( vines.name ) .. "/aliases.lua" )
dofile( minetest.get_modpath( vines.name ) .. "/recipes.lua" )
dofile( minetest.get_modpath( vines.name ) .. "/vines.lua" )
dofile( minetest.get_modpath( vines.name ) .. "/nodes.lua" )
dofile( minetest.get_modpath( vines.name ) .. "/shear.lua" )

print("[Vines] Loaded!")
