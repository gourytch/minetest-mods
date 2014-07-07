--[ trade/Trade.lua ]--
Trade = {};
Trade.__index = Trade;

local next_id = {};
local all_trades = {};
local timer_value = 0;
local timer_interval = 1.0;


function Trade.find(name)
    for _,v = pairs(all_trades) do
        if v.initiator == name or v.acceptor == name then
            return v;
        end;
    end;
    return nil;
end;


local function timer_callback()
    for _,obj = pairs(all_trades) do
        for name,cb = pairs(obj.cbs_timer) do
            cb(obj);
--            if not pcall(cb, obj) then
--                print("PCALL FAILED FOR Trade#"..obj.id.." callback '"..name.."'");
--                obj:addTimerCallback(name, nil);
--            end;
        end;
    end;
    minetest.after(timer_interval, timer_callback);
end;
minetest.after(0, timer_callback);


function Trade.create(initiator, acceptor)
    local obj = setmetatable({}, Trade);
    obj.id        = next_id;
    next_id       = next_id + 1;
    all_trades[obj.id] = obj;
    obj.initiator = initiator;
    obj.acceptor  = acceptor;
    obj.stage     = 'init'; -- init | request | propose | confirm | finish
    obj.lock1     = false; -- lock from initiator
    obj.lock2     = false; -- lock from acceptor
    obj.cbs_timer = {};
    obj.cbs_close = {};
    obj.resetTime();
    return obj;
end;


function Trade:destroy()
    for _,cb = pairs(self.cbs_close) do
        cb(self);
    end;
    all_trades[obj.id] = nil;
end;


function Trade:opposite(name)
    if self.initiator == name then
        return self.acceptor;
    end;
    if self.acceptor == name then
        return self.initiator;
    end;
    return nil;
end;


function Trade:resetTime()
    obj.timestart = timer_value;
end;


function Trade:getElapsedTime()
    return trade.current_tick - timer_value;
end;

-- callback(TradeRef)
function Trade:addTimerCallback(name, callback)
    self.cbs_timer[name] = callback;
end;

-- callback(TradeRef)
function Trade:addCloseCallback(name, callback)
    self.cbs_close[name] = callback;
end;


--
-- 0. создать окно ожидания обмена у initiator-а
-- 1. создать окно запроса обмена от initiator-а к acceptor-у
--
function Trade:setStageRequest()
    self.stage = 'request';
end;

--
-- 0. создать окно разблокированного обмена у initiator-а
-- 1. создать окно разблокированного обмена у acceptor-а
--
function Trade:setStagePropose()
    self.stage = 'request';
end;

--
-- 0. создать окно подтверждения обмена у initiator-а
-- 1. создать окно подтверждения обмена у acceptor-а
--
function Trade:setStageConfirm()
    self.stage = 'confirm';
end;

--
-- 0. создать окно лотка у initiator-а
-- 2. создать окно лотка у acceptor-а
--
function Trade:setStageFinish()
    self.stage = 'finish';
end;
