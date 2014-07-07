--[[ trade/BlockList.lua ]]--
BlockList = {};
BlockList.__index = BlockList;

local function len(v)
    local count = 0;
    for _ in pairs(v) do
        count = count + 1;
    end;
    return count;
end;

function BlockList.create(s)
    local obj = setmetatable({}, BlockList);
    obj.blocklists = {};
    if s ~= nil then
        obj:fromString(s);
    end;
    return obj;
end;


function BlockList:clear()
    self.blocklists = {};
end;


function BlockList:touch(owner)
    if self.blocklists[owner] == nil then
        self.blocklists[owner] = {};
    end;
end;


function BlockList:hasBlock(owner, nickname)
    self.touch(owner);
    local b = self.blocklists[owner][nickname];
    if b == nil and nickname ~= "*" then
        return self:hasGlobalBlock(owner);
    end;
    return true, b;
end;


function BlockList:hasGlobalBlock(owner)
    return self:hasBlock(owner, "*");
end;


function BlockList:setBlock(owner, nickname, reason)
    self:touch(owner);
    self.blocklists[owner][nickname] = {
        ctime = os.date("!%Y-%m-%d %H:%M:%S"),
        reason = reason,
    };
    print("block "..owner..">"..nickname.." added");
end;


function BlockList:setGlobalBlock(owner)
    self:setBlock(owner, '*', '');
end;


function BlockList:removeBlock(owner, nickname)
    self:touch(owner);
    self.blocklists[owner][nickname] = nil;
    if len(self.blocklists[owner]) == 0 then
        self.blocklists[owner] = nil;
    end;
    print("block "..owner..">"..nickname.." removed");
end;


function BlockList:removeGlobalBlock(owner)
    self:removeBlock(owner, "*");
end;


function BlockList:toString()
    local function escape(v)
        return string.gsub(tostring(v), "\"", "\\\"");
    end;
    local function V(v)
        return "\""..escape(v).."\"";
    end;
    local function K(v)
        return "["..V(v).."]";
    end;
    
    local s = "{";
    for owner,blocklist in pairs(self.blocklists) do
        s = s..K(owner).."={";
        for nick, r in pairs(blocklist) do
            s = s..K(nick).."={";
            for k,v in pairs(r) do
                s = s..K(k).."="..V(v)..",";
            end;
            s = s.."},";
        end;
        s = s.."},";
    end;
    s = s.."}";
    return s;
end;


-- FIXME: THIS IS FAST BUT INSECURE!
function BlockList:fromString(s)
    print("restore state from string: "..s);
    self:clear();
    self.blocklists = loadstring("return "..s)();
end;


function BlockList:dump()
    print("blocklist has "..len(self.blocklists).." records");
    for owner,blocklist in pairs(self.blocklists) do
        print("  owner "..owner.." has "..len(blocklist).." blocks");
        for nick, r in pairs(blocklist) do
            print("    "..nick.." blocked at "..r.ctime);
        end;
    end;
end;

