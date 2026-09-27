package.path = package.path .. ";/?.lua"
local Pine3D = require "Pine3D"
local util = require "util"

--local file = fs.open("/cct-64.xpm", "r")
--local img, imgw, imgh = util.loadxpm(file)
--file.close()

--[[local file = fs.open("/uvmap.xpm", "rb")
local img, imgw, imgh = util.loadxpm(file)
file.close()]]
local img, imgw, imgh = {}, 16, 8
for y = 1, 8 do
    img[y] = {}
    for x = 1, 16 do img[y][x] = (x + y) % 2 == 0 and colors.red or colors.white end
end

local w, h = term.getSize()
w, h = w * 2, h * 3
local pi, pi2 = math.pi, math.pi * 2
local floor, ceil = math.floor, math.ceil
local function tri(x) local p = x % pi2 if p >= pi then return (pi2 - p) / pi * 2 - 1 else return p / pi * 2 - 1 end end
local frame = Pine3D.newFrame()
frame.buffer.blitWin.setPaletteColor(colors.purple, 0x800080)
frame.buffer.blitWin.setPaletteColor(colors.magenta, 0xC040C0)
frame:setCamera(0, 0, 0, 0, 0, 0)
frame:setFoV(60)
frame:setBackgroundColor(colors.lightGray)
--frame:setWireFrame(true)
local bg = frame:newObject(Pine3D.models:plane({color = colors.lime, size = 5}), 5, 0, 0, 0, 0, -pi / 2)
local obj = frame:newObject(Pine3D.models:sphere({texture = img, texwidth = imgw, texheight = imgh}), 4, 0, 0, 0, 0, 0)
local shadow = frame:newObject(Pine3D.models:sphere({color = colors.gray}):scale(5 / 4), 5, 0, 0, 0, 0, 0)
local list = {bg, shadow, obj}
local i = 0
local minx, miny = floor(w / 32) * 8, floor(h / 128) * 8
local maxx, maxy = ceil(3 * w / 32) * 8, floor(7 * h / 64) * 8
local maxy2 = floor(31 * h / 256) * 8
bg:setFragmentShader(function(x, y)
    if x >= minx and x <= maxx and y >= miny and y <= maxy and (x % 8 == 0 or y % 8 == 0) then return colors.magenta end
    if y > maxy and y <= maxy2 then
        local u, v = floor(w / 2 + (x - w / 2) / (1 + (y - maxy) / (h - maxy))), y
        if u >= minx and u <= maxx and (u % 8 == 0 or v % 8 == 0) then return colors.magenta end
    end
    return colors.lightGray
end)
shadow:setFragmentShader(function(x, y)
    if x >= minx and x <= maxx and y >= miny and y <= maxy and (x % 8 == 0 or y % 8 == 0) then return colors.purple end
    return colors.gray
end)

--obj:setVertexShader(function(x, y, z) local fz = math.sin(2 * math.pi * (z * 20 + i / 2) / 25) / 5 return x, y + fz, z end)
while i < 200 do
    --setmetatable(img, {__index = gif[i % #gif + 1], __len = function() return imgh end})
    --if img.palette then for j = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^j, table.unpack(img.palette[j])) end end
    local oy, oz = math.abs(math.cos(pi2 * i / 64)) - 0.5, tri(pi2 * i / 90)
    obj:setPos(4, oy, oz)
    shadow:setPos(5, oy * 1.25, oz * 1.25 + 0.2)
    obj:setRot(-pi / 8, pi / 32 * i, 0)
    frame:drawObjects(list)
    frame:drawBuffer()
    sleep(0.05)
    i = i + 1
end
term.setCursorPos(1, 1)