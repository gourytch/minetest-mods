--[[ trade/handle_commands.lua ]]--

function trade.handle_help(name, param)
  local arg = string.match(param, "^([^ ]+)")
  if not arg then
    arg = ""
  end
  if arg == "" then
    minetest.chat_send_player(name,
      "/trade ("..
      "help [cmd]|status|desk/showdesk|enable|disable|"..
      "with/request <nick>|block <nick>|unblock <nick>|blocklist)")
    return true
  end
  if arg == "help" then
    minetest.chat_send_player(name,
      "/trade help [command] -- show quick help on command or command list")
    return true
  end
  if arg == "status" then
    minetest.chat_send_player(name,
      "/trade status -- show current status of trade system")
    return true
  end
  if arg == "desk" or arg == "showdesk" then
    minetest.chat_send_player(name,
      "/trade desk|showdesk -- shows your trade desk")
    return true
  end
  if arg == "enable" then
    minetest.chat_send_player(name,
      "/trade enable -- shows incoming trade proposals from other players")
    return true  
  end
  if arg == "disable" then
    minetest.chat_send_player(name,
      "/trade disable -- auto-reject all incoming trade proposals")
    return true
  end
  if arg == "with" or arg == "request" then
    minetest.chat_send_player(name,
      "/trade with|request <nickname> -- request trade with player")
    return true
  end
  if arg == "block" then
    minetest.chat_send_player(name,
      "/trade block <nickname> [reason] -- add to blocklist (with note)")
    return true
  end
  if arg == "unblock" then
    minetest.chat_send_player(name,
      "/trade unblock <nickname> -- remove from blocklist")
    return true
  end
  if arg == "blocklist" then
    minetest.chat_send_player(name,
      "/trade blocklist -- shows your blocklist")
    return true
  end
end


function trade.handle_status(name)
  return false,"NIY"
end -- trade.handle_status()


function trade.handle_showdesk(name)
  return false,"NIY"
end -- trade.handle_showdesk()


function trade.handle_enable(name)
  return false,"NIY"
end -- trade.handle_enable()


function trade.handle_disable(name)
  return false,"NIY"
end -- trade.handle_disable()


function trade.handle_request(name, param)
  return false,"NIY"
end -- trade.handle_request(nick)


function trade.handle_block(name, nick, reason)
  return false,"NIY"
end  -- trade.handle_block(nick, reason)


function trade.handle_unblock(name, nick)
  return false,"NIY"
end -- trade.handle_unblock(nick)


function trade.handle_blocklist(name)
  return false,"NIY"
end -- trade.handle_blocklist()


function trade.handle_chatcommand(name, param)
  local cmd, args = string.match(param, "^([^ ]+) *(.*)")
  if not cmd then
    cmd = ""
  end
  if not args then
    args = ""
  end
  -- /trade | /trade help [command]
  if cmd == "help" or cmd == "" then
    return false,trade.handle_help(name, args)
  end
  if cmd == "desk" or cmd == "showdesk" then
    return trade.handle_showdesk(name, args)
  end
  return false, "unhandled /trade command '"..cmd.."'"
end -- trade.handle_chatcommand(name, param)


minetest.register_chatcommand("trade", {
    params = "trade command [...options]",
    description = "trade with other players. /trade help for complete info",
    privs = {},
    func = trade.handle_chatcommand
})

print("/trade command was registered")
