--  Delete player accounts if they doesn't earn any money

minetest.register_on_leaveplayer(function(player)
  if player then
    local name = player:get_player_name()
    if money.get_money(name) == INITIAL_MONEY then
      minetest.after(1, function()
        subgames.remove_all_player(name)
      end)
    end
  end
end)
