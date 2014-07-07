#! /usr/bin/env lua

require('BlockList');

b = BlockList.create();
b:dump();

b:setBlock('lolek', 'bolek');
b:dump();
b:setBlock('lolek', 'babaka');
b:dump();
b:setGlobalBlock('babaka');
b:dump();
b:removeBlock('lolek', 'babaka');
b:dump();
b:removeGlobalBlock('babaka');
b:dump();
s = b:toString();
print("s="..s);

c = BlockList.create(s);
c:dump();
print("s="..c:toString());
