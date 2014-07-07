--[[ trade/init.lua ]]--

base  = minetest.get_modpath("trade") .. "/"
trade = {}
trade.max_distance = 5.0
trade.desk_width = 4
trade.desk_height = 3
trade.desk_size = trade.desk_width * trade.desk_height

-- include all parts of system here
dofile(base .. "BlockList.lua")
dofile(base .. "Trade.lua")
dofile(base .. "common.lua")
dofile(base .. "form_desk.lua")
dofile(base .. "form_request.lua")
dofile(base .. "form_trade.lua")
dofile(base .. "handle_commands.lua")

