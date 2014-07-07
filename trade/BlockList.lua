--[[ trade/BlockList.lua ]]--
BlockList = {};
BlockList.__index = BlockList;

function BlockList.create(s)
    local obj = setmetatable({}, BlockList);
    obj.blocklists = {};
    if s ~= nil then
        obj:fromString();
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
    print("block "..owner..">"..nickname.." removed");
end;


function BlockList:removeGlobalBlock(owner)
    self:removeBlock(owner, "*");
end;


function BlockList:toString()
end;


function BlockList:fromString(s)
    self:clear();
    
end;


function BlockList:dump()
    local function len(v)
        local count = 0;
        for _ in pairs(v) do
            count = count + 1;
        end;
        return count;
    end;
    
    print("blocklist has"..len(self.blocklists).." records");
    for owner,blocklist in pairs(self.blocklists) do
        print("  owner "..owner.." has "..len(blocklist).." blocks");
        for nick, r in pairs(blocklist) do
            print("    "..nick.." blocked at "..r.ctime);
        end;
    end;
end;

