--[[ trade/common.lua ]]--

base  = minetest.get_modpath("trade") .. "/"
trade.max_distance = 5.0
trade.desk_width = 4
trade.desk_height = 3
trade.desk_size = trade.desk_width * trade.desk_height

local trades = {}


function trade.find_trade(name)
  for _,t in ipairs(trades) do
    if t.initiator == name or t.acceptor == name then
      return t;
    end;
  end;
  return nil;
end;


function trade.get_initiator(a)
  for _,t in ipairs(trades) do
    if a == k or a == v then
      return k;
    end;
  end;
  return nil;
end;


function trade.get_other_hand(a)
  for k,v in pairs(trade_pairs) do
    if a == k then
      return v;
    end;
    if a == v then
      return k;
    end;
  end;
  return nil;
end;


function trade.remove_pair(a)
  local k = trade.get_initiator(a);
  if k then  
    print("trade.remove_pair("..a.."): remove pair ("
      ..k..", "..trade_pairs[k]..")");
    trade_pairs[k] = nil;
  end;
end;


function trade.is_busy(a)
  return trade.get_initiator(a) ~= nil;
end;


function trade.add_pair(a, b)
  if trade.is_busy(a) then
    print("trade.add_pair("..a..","..b..") error: busy1")
    return false;
  end;
  if trade.is_busy(b) then
    print("trade.add_pair("..a..","..b..") error: busy2")
    return false;
  end;
  trade_pairs[a] = b;
  print("trade.add_pair("..a..","..b..") pair added")
  trade.interaction_data[a] = {}
end;


function trade.hide_formspec(player)
  minetest.show_formspec(player, "", "");
end
