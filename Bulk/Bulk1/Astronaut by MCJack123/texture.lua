package.path = package.path .. ";/?.lua"
local Pine3D = require "Pine3D"
local util = require "util"
local fps = jit and config and config.get("clockSpeed") or 20

--local file = fs.open("/cct-64.xpm", "r")
--local img, imgw, imgh = util.loadxpm(file)
--file.close()

local file = fs.open(..., "rb")
local gif, pal, imgw, imgh = util.loadgif(file)
file.close()
local img = {}

local frame = Pine3D.newFrame()
for i = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^i, table.unpack(pal[i])) end
frame:setCamera(0, 0, 0, 0, 0, 0)
frame:setFoV(60)
frame:setBackgroundColor(colors.black)
--frame:setWireFrame(true)
local obj = frame:newObject(Pine3D.models:cube({texture = img, texwidth = imgw, texheight = imgh}), 3, 0, 0, 0, 0, 0)
local i = 0
obj:setVertexShader(function(x, y, z) local fz = math.sin(2 * math.pi * (z * 20 + i / 2) / 25) / 5 return x, y + fz, z end)
while i < 200 do
    local rstart = os.epoch "utc"
    setmetatable(img, {__index = gif[math.floor(i) % #gif + 1], __len = function() return imgh end})
    if img.palette then for j = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^j, table.unpack(img.palette[j])) end end
    obj:setRot(0, math.pi / 32 * i, math.pi / 32 * i)
    frame:drawObjects({obj})
    frame:drawBuffer()
    sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
    i = i + (os.epoch "utc" - rstart) / 50
end
term.setCursorPos(1, 1)