local left = 0;
local _username = nil;
local _formname = "tf:form";
local _timeout = 10;

local function update()
    if _username == nil then
        return;
    end;
    print("update. "..left.." frames left");
    minetest.show_formspec(_username, _formname, "size[4,3]"
    .."bgcolor[#404020;false]"
    .."label[1,0; LEFT "..left.." SEC]"
    .."button_exit[0,2;4,1;CLOSE;close form]");
end;

local function hide()
    if _username == nil then
        return;
    end;
    print("hide");
    minetest.show_formspec(_username, _formname, "");
end;

local function tick()
    if left <= 0 then
        return; -- stop time-loop
    end;
    left = left - 1;
    if left <= 0 then
        hide();
        return; -- stop time-loop
    end;
    update();
    minetest.after(1.0, tick);
end;

local function show()
    left = _timeout;
    print("show for "..left.." frames");
    minetest.after(0, tick);
end;

local function handleFields(player, formname, fields)
    print("handleFields('"..player:get_player_name().."', '"..formname.."', "..dump(fields)..")");
    if formname ~= _formname then
        return false;
    end;
    local nick = player:get_player_name();
    local quit = false;
    print("handle form fields");
    for k,v in pairs(fields) do
        print("field ["..k.."] = '"..v.."'");
        if k == 'quit' then
            quit = true;
        end;
    end;
    if quit then
        print("form closed. disable ticker");
        left = 0;
        _username = nil;
    end;
    return true;
end;
minetest.register_on_player_receive_fields(handleFields);

local function handleCommand(name, args)
    _username = name;
    show();
    return true;
end;

local function handleTFTPCommand(name, args)
    _username = name;
    local player = minetest.get_player_by_name(name);
    local pos = player:getpos();
    pos.y = pos.y + 100;
    player:setpos(pos);
    show();
    return true;
end;



minetest.register_chatcommand("tf", {
  params = "",
  description = "show form and hide it by timeout",
  func = handleCommand});
print("chatcommand /tf registered");

minetest.register_chatcommand("tftp", {
  params = "",
  description = "teleport into sky and launch fimeout form (killtest)",
  func = handleTFTPCommand});
print("chatcommand /tftp registered");
