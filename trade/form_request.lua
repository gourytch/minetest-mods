--[[ форма для запроса обмена ]]--

trade.FORM_REQUEST_MESSAGE = "%s предлагает вам обмен";
trade.FORM_REQUEST_ACCEPT = "Согласиться";
trade.FORM_REQUEST_REJECT = "Отказаться";

trade.MSG_REQUEST_NOT_INITIATED_PLAYER_NOT_FOUND = "игрока '%s' нет или он не в игре";
trade.MSG_REQUEST_NOT_INITIATED_YOU_ARE_BUSY = "вы предложили обмен %s и ждёте от него ответа";
trade.MSG_REQUEST_NOT_INITIATED_PLAYER_IS_BUSY = "%s сейчас занят";

trade.MSG_REQUEST_ACCEPTED = "%s согласился на обмен";
trade.MSG_REQUEST_REJECTED = "%s отказался от обмена";

trade.update_forms_interval = 1.0;
trade.request_timeout = 30;

function trade.get_trade_request_formspec(name_from)
  return
    "size[8,3]"
    .."bgcolor[#404020;false]"
--    .."background[0,0;9,9;bg_desk.png]"
    .."label[1,0; "
    ..minetest.formspec_escape(
      string.format(trade.FORM_REQUEST_MESSAGE, name_from))
    .."]"
    .."button_exit[1,2;3,1;tradeAccept;"
    ..minetest.formspec_escape(
      string.format(trade.FORM_REQUEST_ACCEPT, name_from))
    .."]"
    .."button_exit[4,2;3,1;tradeReject;"
    ..minetest.formspec_escape(
      string.format(trade.FORM_REQUEST_REJECT, name_from))
    .."]";
end


function trade.update_forms()
  print("trade.update_forms");
  minetest.after(trade.update_forms_interval, trade.update_forms);
end
minetest.after(0, trade.update_forms);


function trade.initiate_trade_request(name_from, name_to)
  print("trade.show_request("..name_from..", "..name_to..")");
  -- TODO вынести все проверки в отдельную функцию --
  local p2 = minetest.get_player_by_name(name_to);
  if not p2 then
    minetest.chat_send_player(name_from,
      string.format(trade.MSG_REQUEST_NOT_INITIATED_PLAYER_NOT_FOUND, name_to));
    return false;
  end;
  if trade.is_busy(name_from) then
    local other = trade.get_other_hand(name_from);
    minetest.chat_send_player(name_from, 
      string.format(trade.MSG_REQUEST_NOT_INITIATED_PLAYER_IS_BUSY, other));
    return false;
  end;
  if trade.is_busy(name_to) then
    minetest.chat_send_player(name_from, "player '"..name_to.."' is busy");
    return false;
  end;
  trade.add_pair(name_from, name_to);
  minetest.show_formspec(name_to, "trade:request", 
    trade.get_trade_request_formspec(name_from));
end;


-- initialize handler
minetest.register_on_player_receive_fields(function(player, formname, fields)
  local nick1 = player:get_player_name();
  local nick2 = trade.get_other_hand(nick1);
  print("trade:request handler. player='"..nick1
    .."', formname='"..formname
    .."', fields="..dump(fields));
  if formname ~= "trade:request" then
    return false;
  end;
  local accepted = false;
  for k,v in pairs(fields) do
    if k == 'tradeAccept' then
      print("trade request from '"..nick2.."' to '"..nick1.."' accepted");
      accepted = true;
      break;
    end;
    if k == 'tradeRejected' then
      print("trade request from '"..nick2.."' to '"..nick1.."' rejected");
      break;
    end;
    if k == 'quit' then
      print("trade request from '"..nick2.."' to '"..nick1.."' not confirmed");
      break;
    end;
  end;
  if accepted then
    print("initiate trade between '"..nick2.."' and '"..nick1.."'");
    minetest.chat_send_player(nick2, string.format(trade.MSG_REQUEST_ACCEPTED, nick1));
  else
    minetest.chat_send_player(nick2, string.format(trade.MSG_REQUEST_REJECTED, nick1));
    trade.remove_pair(nick1);
  end;
  return true;
end);
print("trade:request handler registered");


-- test command for trade request form
minetest.register_chatcommand("ttrq", {
  params = "",
  description = "show trade:request form",
  func = function(name, param)
    if param == "" then
      trade.initiate_trade_request(name, name);
    else
      trade.initiate_trade_request(name, param);
    end;
    return true;
  end});
print("chatcommand /ttrq registered");
