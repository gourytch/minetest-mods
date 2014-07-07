--[ trade/Trade.lua ]--
Trade = {};
Trade.__index = Trade;

local next_id = {};
local active_trades = {};
local timer_value = 0;

local timer_interval = 1.0;
local max_distance = 5;

function Trade.find(name)
    for _,v = pairs(active_trades) do
        if v.initiator == name or v.acceptor == name then
            return v;
        end;
    end;
    return nil;
end;

-- проверяем возможность обмена
function Trade.canTrade(name1, name2)
    local t = Trade.find(name1);
    if t ~= nil then
        if t:opposite(name1) ~= name2 then
            return false, name1.." is busy";
        end;
    end;
    t = Trade.find(name2);
    if t ~= nil then
        if t:opposite(name2) ~= name1 then
            return false, name2.." is busy";
        end;
    end;
    local p1 = minetest.get_player_by_name(name1);
    local p2 = minetest.get_player_by_name(name2);
    if p1 == nil then
        return false, name1.." not found";
    end;
    if p2 == nil then
        return false, name2.." not found";
    end;
    if hasGlobalBlock(name2) then
        return false, name2.." do not want to trade";
    end;
    if hasBlock(name2, name1) then
        return false, name1.." in "..name2.."'s blocklist";
    end;
    if p1:get_hp() <= 0 then
        return false, name1.." is dead";
    end;
    if p2:get_hp() <= 0 then
        return false, name2.." is dead";
    end;
    local v1 = p1:getpos();
    local v2 = p1:getpos();
    local dv = vector.subtract(v1, v2);
    local dd = vector.distance(dv);
    if max_distance < dd then
        return false, name1.." and "..name2.." are too far apart";
    end;
end;

-- обработка всех шевелящихся таймаутов в системе обмена
local function timer_callback()
    for _,obj = pairs(active_trades) do
        for name,cb = pairs(obj.cbs_timer) do
            cb(obj);
--            if not pcall(cb, obj) then
--                print("PCALL FAILED FOR Trade#"..obj.id
--                  .." callback '"..name.."'");
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
    active_trades[obj.id] = obj;
    obj.initiator = initiator;
    obj.acceptor  = acceptor;
    obj.stage     = '?'; -- request | propose | confirm | finish | cancel
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
    active_trades[obj.id] = nil;
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


--[[ рёбра графа переходов между состояниями
 ?       -> request
 request -> cancel
 request -> propose
 propose -> cancel
 propose -> confirm
 confirm -> cancel
 confirm -> propose
 confirm -> finish
]]

-- 0. создать окно ожидания обмена у initiator-а
-- 1. создать окно запроса обмена от initiator-а к acceptor-у
--
function Trade:setStageRequest()
    assert(self.stage == '?', "bad stage:"..self.stage);
    
    self.stage = 'request';
end;

--
-- 0. создать окно разблокированного обмена у initiator-а
-- 1. создать окно разблокированного обмена у acceptor-а
--
function Trade:setStagePropose()
    self.stage = 'propose';
end;

--
-- 0. создать окно подтверждения обмена у initiator-а
-- 1. создать окно подтверждения обмена у acceptor-а
--
function Trade:setStageConfirm()
    self.stage = 'confirm';
end;

--
-- 0. зарегистрировать успешный обмен в журнал
-- 1. обменять содержимое trade-списков
-- 2. создать окно лотка у initiator-а
-- 3. создать окно лотка у acceptor-а
--
function Trade:setStageFinish()
    self.memorize();
    self.swap();
    self.stage = 'finish';
    trade.show_desk(self.initiator);
    trade.show_desk(self.acceptor);
end;


function Trade:setStageCancel()
    self.stage = 'cancel';
    trade.show_desk(self.initiator);
    trade.show_desk(self.acceptor);
end;


function Trade:memorize()
    local p0 = minetest.get_player_by_name(self.initiator);
    local p1 = minetest.get_player_by_name(self.acceptor);
    local v0 = p0:get_inventory_list('trade');
    local v1 = p1:get_inventory_list('trade');
    --
end;

function Trade:swap()
    local p0 = minetest.get_player_by_name(self.initiator);
    local p1 = minetest.get_player_by_name(self.acceptor);
    local v0 = p0:get_inventory_list('trade');
    local v1 = p1:get_inventory_list('trade');
    --
end;
