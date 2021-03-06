--[[ ldecNumberPerf.lua
*  Lua wrapper for decNumber -- performance testing
*  created September 7, 2006 by e
*
* Copyright (c) 2006 Doug Currie, Londonderry, NH
* All rights reserved.
* 
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, and/or sell copies of the Software, and to permit persons
to whom the Software is furnished to do so, provided that the above
copyright notice(s) and this permission notice appear in all copies of
the Software and that both the above copyright notice(s) and this
permission notice appear in supporting documentation.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF THIRD PARTY RIGHTS. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
HOLDERS INCLUDED IN THIS NOTICE BE LIABLE FOR ANY CLAIM, OR ANY SPECIAL
INDIRECT OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING
FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION
WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*********************************************************************]]--

require "ldecNumber"
require "bit" --[[ http://luaforge.net/projects/bit/ ]]--
require "lperformance"

ctx = decNumber.getcontext()
ctx:setdefault (decNumber.INIT_DECIMAL128)
ctx:setdigits (69)

local pt = performance.new()
local tm

tm = pt:lap()

for i = 1,10000
do
    -- nothing
end

tm = pt:lap()

print(string.format("Empty loop: %s s", tm))

local n1,n2,n3,n4

tm = pt:lap()

n1 = decNumber.tonumber "2"
n2 = decNumber.tonumber "123456789"
n3 = decNumber.tonumber "987654321"
n4 = decNumber.tonumber "123456789.987654321"

for i = 1,10000
do
    n1 = n1+n3/n2+n4/(n4:squareroot())
    n2 = (n1/(n1-1)):exp()
    n3 = n2:ln()
    n4 = n1:remainder(n2)
end

tm = pt:lap()

print(string.format("Math loop: %s s", tm))

print(n1,n2,n3,n4)

n2 = decNumber.tonumber "3"
n3 = decNumber.tonumber "5"

tm = pt:lap()

for i = 1,100000
do
    n1 = n2+n3
end

tm = pt:lap()

print(string.format("Add loop: %s s", tm))

print(n1)
