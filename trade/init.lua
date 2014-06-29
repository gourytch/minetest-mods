--[[
команды
/trade help -- подсказка по командам системы обмена
/trade showdesk -- показывает форму с main- и trade- списками инвентаря игрока 
               (чтобы забрать/выложить вещи)
/trade with ник -- предлагает обмен игроку 
/trade disable -- блокирует все предложения обмена
/trade block [ник] [заметка] -- добавляет игрока в личный блоклист
/trade enable -- снимает блокировку с предложений обмена
/trade unblock [ник] -- убирает игрока из личного блоклиста
/trade blocklist -- выдаёт список личных блокировок
/trade status -- выдаёт состояние системы обмена
/trade statistic -- выдаёт статистику системы обмена

идеи:
* у игроков в инвентаре заводим отдельные списки trade
* игрок name1 посылает команду /trade name2
* проверяется, есть ли игроков name1 и name2 возможность торговли
* (есть соответствующие права, не мёртвые ли, нет ли выставленного запрета
  на приём торговли и т.п.)
* у игрока name2 открывается диалоговое окно "игрок name1 предлагает обмен"
  с кнопками "согласиться", "отказаться", "блокировать" и таймер обратного отсчёта
  * при отказе или истечении таймера окно закрывается. конец.
  * при нажатии на "блокировать" окно закрывается, player1 добавляется в ignore-лист у player2. конец.
  * при нажатии на "согласиться" окно закрывается
  * начинается сеанс обмена
  * заводятся флаги accepted у player1 и player2 (сброшены изначально)
  * у player1 открывается форма, где в trade-части слева отображается trade-список инвентаря player1
    а справа read-only trade-список инвентаря player2; кнопка, переключающая accepted-флаг player1,
    main-инвентарь player1
  * у player2 открывается форма, где в trade-части слева отображается trade-список инвентаря player2
    а справа read-only trade-список инвентаря player1; кнопка, переключающая accepted-флаг player2,
    main-инвентарь player2
  * при любом премещении вещей в своей trade-части флаги accepted у player1 и player2 сбрасываются
  * при нажатии игроком кнопки подтверждения взводится флаг accepted (player1 или player2 соответственно)
  * если оба флага accepted взведены, то 
    информация о сделке регистрируется в общем списке и историях игроков
    происходит обмен (swap) содержимым trade-списков player1 и player2
    флаги accepted сбрасываются
  * если при периодической проверке обнаруживается, что 
--]]

trade = {}
trade.max_distance = 5.0

--[[
состояние системы обмена для каждого игрока
nick -> TradeState
  owner -- владелец записи (==nick)
  enabled (true/false) -- разрешен ли приём предложений обмена по умолчанию?
  blocklist = { -- список "неугодных"
    nickname, -- ник заблокированного
    tstamp,   -- дата и время блокировки
    reason,   -- заметка по поводу причины блокировки
  }
--]]
trade.states = {}

--[[
  history = { -- история обменов
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
    proposer,
    acceptor,
    proposer_choice,
    acceptor_choice,
}
--]]
trade.next_desk_id = 1
trade.desks = {}

function trade.find_trade_desk



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
    print("can not start trade: player[1] '"..name1.."' can not trade with himself")
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
  -- FIXME: добавить проверку прямой видимости, иначе можно торговать сквозь стены
  local d = trade.distance(p1:getpos(), p2:getpos())
  if trade,max_distance < d then
    print("can not start trade: players '"..name1.."' and '"..name2.."' are too far apart")
    return false
  end

  -- проверяем, не участвует ли уже какой игрок в торговле?
  for desk_id,desk in pairs(trade.desks) do
    if desk[0].player == name1 or desk[1].player == name1 then
      print("can not start trade: player[1] '"..name1.."' is in trade session "..desk_id)
      return false;
    end
    if desk[0].player == name2 or desk[1].player == name2 then
      print("can not start trade: player[2] '"..name2.."' is in trade session "..desk_id)
      return false;
    end
  end

  -- всё, что может быть проверено - проверилось без ошибок.
  print("players '"..name1.."' and '"..name2.."' can start trading")
  return true
end -- trade.can_start_trade(name1, name2)

--[[

function trade.create_desk_part(desk_id, player_name)
  local dp = minetest.create_detached_inventory("desk"..desk_id..":"..player_name, {
    -- только владелец части торгового стола может двигать вещи 
    allow_move = function (inv, from_list, from_index, to_list, to_index, count, player)
      if player:get_player_name() /= inv.owner then
        return 0
      end
      return count
    end,

    -- только владелец части торгового стола может выставлять вещи
    allow_put = function (inv, listname, index, stack, player)
      if player:get_player_name() /= inv.owner then
        return -1
      end
      return 0
    end,

    -- только владелец части торгового стола может изымать вещи
    allow_take = function (inv, listname, index, stack, player)
      if player:get_player_name() /= inv.owner then
        return -1
      end
      return 0
    end,

    -- при движении вещей на любой из частей торгового стола 
    -- у обеих частей торгового стола сбрасываются флаги согласия
    on_move = func(inv, from_list, from_index, to_list, to_index, count, player)
    end,

    -- при помещении вещи на любую из частей торгового стола 
    -- у обеих частей торгового стола сбрасываются флаги согласия
    on_put = func(inv, listname, index, stack, player)
    end,

    -- при изымании вещи с любой из частей торгового стола 
    -- у обеих частей торгового стола сбрасываются флаги согласия
    on_take = func(inv, listname, index, stack, player)
    end,

    })
  return dp
end -- trade.create_desk_part(desk_id, player_name)

--]]

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

}



minetest.register_chatcommand("tradeform", {
    params = "<playername>",
    description = "show form for trade with other player or NPC",
    privs = {},
    func = function (name, param)
        local name1 = 
        minetest.create_detached_inventory()
    end,
})


function testchest.get_formspec(pos, playername)
    local meta = minetest.get_meta(pos)
    local spos = pos.x .. "," .. pos.y .. "," ..pos.z
    local formspec = "size[8,9]"..
		"list[nodemeta:".. spos .. ";panel_1;0,0;4,4;]"..
		"list[nodemeta:".. spos .. ";panel_2;0,0;4,4;]"..
		"list[current_player;main;0,5;8,4;]"
	return formspec
end
