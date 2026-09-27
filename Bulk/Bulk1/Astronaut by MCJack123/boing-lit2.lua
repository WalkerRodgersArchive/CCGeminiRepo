package.path = package.path .. ";/?.lua"
local Pine3D = require "Pine3D"
local util = require "util"
local fps = jit and config and config.get("clockSpeed") or 20

--local file = fs.open("/cct-64.xpm", "r")
--local img, imgw, imgh = util.loadxpm(file)
--file.close()

--[[local file = fs.open("/uvmap.xpm", "rb")
local img, imgw, imgh = util.loadxpm(file)
file.close()]]

-- palette:
-- 0-3: white dark -> bright
-- 4-7: red dark -> bright
-- 8: light gray
-- 9: dark gray
-- 10: light purple
-- 11: dark purple

local img, imgw, imgh = {}, 16, 8
for y = 1, 8 do
    img[y] = {}
    for x = 1, 16 do img[y][x] = (x + y) % 2 == 0 and 16 or 1 end
end

local w, h = term.getSize()
w, h = w * 2, h * 3
local pi, pi2 = math.pi, math.pi * 2
local floor, ceil, min, max, abs = math.floor, math.ceil, math.min, math.max, math.abs
local function tri(x) local p = x % pi2 if p >= pi then return (pi2 - p) / pi * 2 - 1 else return p / pi * 2 - 1 end end
local frame = Pine3D.newFrame()
frame.buffer.blitWin.setPaletteColor(0x1, 0x404040)
frame.buffer.blitWin.setPaletteColor(0x2, 0x808080)
frame.buffer.blitWin.setPaletteColor(0x4, 0xC0C0C0)
frame.buffer.blitWin.setPaletteColor(0x8, 0xFFFFFF)
frame.buffer.blitWin.setPaletteColor(0x10, 0x400000)
frame.buffer.blitWin.setPaletteColor(0x20, 0x800000)
frame.buffer.blitWin.setPaletteColor(0x40, 0xC00000)
frame.buffer.blitWin.setPaletteColor(0x80, 0xFF0000)
frame.buffer.blitWin.setPaletteColor(0x100, 0x999999)
frame.buffer.blitWin.setPaletteColor(0x200, 0x4C4C4C)
frame.buffer.blitWin.setPaletteColor(0x400, 0xC040C0)
frame.buffer.blitWin.setPaletteColor(0x800, 0x800080)
frame:setCamera(0, 0, 0, 0, 0, 0)
frame:setFoV(60)
frame:setBackgroundColor(0x100)
--frame:setWireFrame(true)
local bg = frame:newObject(Pine3D.models:plane({color = 0x100, size = 5}), 5, 0, 0, 0, 0, -pi / 2)
local obj = frame:newObject(Pine3D.models:sphere({texture = img, texwidth = imgw, texheight = imgh, res = max(floor(w / 10), 15)}), 4, 0, 0, 0, 0, 0)
local obj_shadow = frame:newObject(Pine3D.models:sphere({color = 1, res = max(floor(w / 10), 15)}), 4, 0, 0, 0, 0, 0)
local shadow = frame:newObject(Pine3D.models:sphere({color = 0x200, res = max(floor(w / 10), 15)}):scale(5 / 4), 5, 0, 0, 0, 0, 0)
local list = {bg, shadow, obj_shadow, obj}
local i = 0
local minx, miny = floor(w / 32) * 8, floor(h / 128) * 8
local maxx, maxy = ceil(3 * w / 32) * 8, floor(7 * h / 64) * 8
local maxy2 = floor(31 * h / 256) * 8
local lightpos = vector.new(-5, 5, 0)
bg:setFragmentShader(function(x, y)
    if x >= minx and x <= maxx and y >= miny and y <= maxy and (x % 8 == 0 or y % 8 == 0) then return 0x400 end
    if y > maxy and y <= maxy2 then
        local u, v = floor(w / 2 + (x - w / 2) / (1 + (y - maxy) / (h - maxy))), y
        if u >= minx and u <= maxx and (u % 8 == 0 or v % 8 == 0) then return 0x400 end
    end
    return 0x100
end)
shadow:setVertexShader(function(x, y, z)
    local oy = shadow[2]
    if oy + y < -1 then return x, y + (-1 - (oy + y)) / 2, z end
    return x, y, z
end)
shadow:setFragmentShader(function(x, y)
    if x >= minx and x <= maxx and y >= miny and y <= maxy and (x % 8 == 0 or y % 8 == 0) then return 0x800 end
    return 0x200
end)
local normdat = {}
obj_shadow:setVertexShader(function(x, y, z, poly, n)
    local vx = normdat[poly] or {}
    vx[n] = vector.new(x, y, z)
    normdat[poly] = vx
    if vx[1] and vx[2] and vx[3] then
        local norm = (vx[2] - vx[1]):cross(vx[3] - vx[1]):normalize()
        for v = 1, 3 do
            local key = ("fff"):pack(vx[v].x, vx[v].y, vx[v].z)
            if normdat[key] then normdat[key][#normdat[key]+1] = norm
            else normdat[key] = {norm} end
        end
    end
    frame.buffer.drawTriangle = function() end
    return 0, 0, 0
end)
local compress = 0
obj:setVertexShader(function(x, y, z)
    frame.buffer.drawTriangle = frame.buffer.drawTriangleInterp
    local n = normdat[("fff"):pack(x, y, z)]
    if not n.norm then
        local sum = n[1]
        for i = 2, #n do sum = sum + n[i] end
        n.norm = sum:div(#n):normalize()
        local vx = vector.new(x, y, z)
        n.c = min(max(((lightpos - vx):normalize():dot(n.norm) + 1) / 2, 0), 1)
    end
    return x, y * (1 - compress), z * (1 + compress), {c = n.c}
end)
obj:setFragmentShader(function(x, y, depth, poly, c, interpVars)
    if interpVars.c ~= interpVars.c then return 0x8000 end
    local n = min(max(floor(interpVars.c * 4 + 0.5), 0), 4)
    if n == 0 then return 0x8000 end
    return 2^(n - 1) * c
end)

--obj:setVertexShader(function(x, y, z) local fz = math.sin(2 * math.pi * (z * 20 + i / 2) / 25) / 5 return x, y + fz, z end)
while i < 200 do
    --setmetatable(img, {__index = gif[i % #gif + 1], __len = function() return imgh end})
    --if img.palette then for j = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^j, table.unpack(img.palette[j])) end end
    local rstart = os.epoch "utc"
    local oy, oz = math.abs(math.cos(pi2 * i / 64)) * 1.2 - 0.7, tri(pi2 * i / 90)
    if oy < -0.5 then compress = (-0.5 - oy) / 2 oy = oy + compress else compress = 0 end
    lightpos = vector.new(-5, math.sin(pi2 * i / 50) * 5, math.cos(pi2 * i / 50) * 5)
    obj:setPos(4, oy, oz)
    obj_shadow:setPos(4, oy, oz)
    shadow:setPos(5, oy * 1.25 - 0.2 * math.sin(pi2 * i / 50), oz * 1.25 - 0.2 * math.cos(pi2 * i / 50))
    obj:setRot(-pi / 8, pi / 32 * i, 0)
    obj_shadow:setRot(-pi / 8, pi / 32 * i, 0)
    normdat = {}
    frame:drawObjects(list)
    frame:drawBuffer()
    sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
    i = i + (os.epoch "utc" - rstart) / 50
end
term.setCursorPos(1, 1)