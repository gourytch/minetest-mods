--[[ trade/init.lua ]]--

base  = minetest.get_modpath("trade") .. "/"
trade = {}
trade.max_distance = 5.0
trade.desk_width = 4
trade.desk_height = 3
trade.desk_size = trade.desk_width * trade.desk_height

-- include all parts of system here
dofile(base .. "common.lua")
dofile(base .. "form_desk.lua")
dofile(base .. "form_request.lua")
dofile(base .. "form_trade.lua")
dofile(base .. "handle_commands.lua")


--[[
trade.states -- состояние системы обмена для каждого игрока
nickname -> TradeState
  owner -- владелец записи (==nickname)
  enabled (true/false) -- разрешен ли приём предложений обмена по умолчанию?
  blocklist = { -- список "неугодных"
    { nickname, -- ник заблокированного
      tstamp,   -- дата и время блокировки
      reason,   -- заметка по поводу причины блокировки
    }
  }
--]]
trade.states = {}

--[[
  trade.history -- история обменов
  {
    {
      tstamp,    -- когда завершена сделка
      proposer,  -- игрок, предложивший обмен
      acceptor,  -- игрок, согласившийся на обмен
      sucess,    -- завершена ли обменом
      given {  -- предлагаемое содержимое (trade-список proposer)
        name = count
      }
      taken {  -- получаемое содержимое (trade-список acceptor)
        name = count
      }
    }
  }
--]]
trade.history = {}

--[[
активные сеансы обмена
формат записи:
{
    starttime,
    player1,
    player2,
    choice1,
    choice2,
}
--]]
trade.active_trades = {}

function trade.distance(a, b)
  return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2 + (a.z - b.z)^2)
end

--[[
запуск процесса обмена между игроками name1 и name2
return: 
--]]
function trade.can_start_trade(name1, name2)
  -- проверяем, не пытается ли игрок тоговать сам с собой
  if name1 == name2 then
    print("can not start trade: player[1] '"..name1..
          "' can not trade with himself")
    return false
  end

  local p1 = minetest.get_player_by_name(name1)
  local p2 = minetest.get_player_by_name(name2)
  -- проверяем, есть ли такие игроки в игре
  if not p1 then
    print("can not start trade: player[1] '"..name1.."' is not in game")
    return false
  end
  if not p2 then
    print("can not start trade: player[2] '"..name2.."' is not in game")
    return false
  end
  -- проверяем, игроки ли это? (чуть-чуть паранойи)
  if not p1:is_player() then
    print("can not start trade: '"..name1.."' is not a player")
    return false
  end
  if not p2:is_player() then
    print("can not start trade: '"..name2.."' is not a player")
    return false
  end
  -- проверяем, живы ли оба игрока?
  if p1:get_hp() <= 0 then
    print("can not start trade: player[1] '"..name1.."' is dead")
    return false
  end
  if p2:get_hp() <= 0 then
    print("can not start trade: player[2] '"..name2.."' is dead")
    return false
  end
  -- проверяем, близко ли они друг от друга
  -- FIXME: добавить проверку прямой видимости, 
  -- иначе можно торговать сквозь стены
  local d = trade.distance(p1:getpos(), p2:getpos())
  if trade.max_distance < d then
    print("can not start trade: players '"..name1..
          "' and '"..name2.."' are too far apart")
    return false
  end

  -- проверяем, не участвует ли уже какой игрок в торговле?
  for _,sess in pairs(trade.desks) do
    if sess.player1 == name1 then
      if sess.player2 == name2 then
        break
      else
        print("can not start trade: player[1] '"..name1..
              "' trades with "..sess.player2)
        return false;
      end
    end
    if sess.player2 == name1 then
      if sess.player1 == name2 then
        break
      else
        print("can not start trade: player[1] '"..name1..
              "' trades with "..sess.player1)
        return false;
      end
    end
    if sess.player1 == name2 then
      print("can not start trade: player[2] '"..name2..
            "' trades with "..sess.player2)
      return false;
    end
    if sess.player2 == name2 then
      print("can not start trade: player[2] '"..name2..
            "' trades with "..sess.player1)
      return false;
    end
  end

  -- всё, что может быть проверено - проверилось без ошибок.
  print("players '"..name1.."' and '"..name2.."' can start trading")
  return true
end -- trade.can_start_trade(name1, name2)

-- начало торговли: создание торгового стола, открытие торговых форм у игроков
function trade.start_trade(name1, name2)
  if not trade.can_start_trade(name1, name2) then
    return false
  end
  -- FIXME BEGIN ATOMIC
  local desk_id = trade.next_desk_id
  trade.next_desk_id = trade.next_desk_id + 1
  -- END ATOMIC
  local desk = {
    { player = name1, 
      choice = 'undefined',
      inv ={},  },
    { player = name2, inv = {}, choice = 'undefined' }
  }
end
