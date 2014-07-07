--[[ форма для trade-списка ]]--

function trade.show_desk(name)
  local inv = minetest.get_inventory({type="player", name=name})
--[[
  if inv:get_size("trade") /= trade.desk_size then
    inv:set_size("trade", trade.desk_size)
  end
  if inv:get_width("trade") /= trade.desk_width then
    inv:set_width("trade", trade.desk_width)
  end
--]]
  inv:set_size("trade", trade.desk_size)
  inv:set_width("trade", trade.desk_width)
  minetest.show_formspec(name, "trade:desk", 
    "size[9,9]"..
    "bgcolor[#c0c090;false]"..
    "background[0,0;9,9;bg_desk.png]"..
    "label[1,0;торговый стол]"..
    "list[current_player;trade;0,1;"..
      trade.desk_width..","..trade.desk_height..";]"..
--    "list[current_player;trade;5,1;"..
--      trade.desk_width..","..trade.desk_height..";]"..
    "list[current_player;main;0.5,5;8,4;]"..
    "")
end
