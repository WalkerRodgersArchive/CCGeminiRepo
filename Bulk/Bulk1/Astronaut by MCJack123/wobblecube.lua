local Pine3D = require "Pine3D"
local fps = jit and config and config.get("clockSpeed") or 20
local frame = Pine3D.newFrame()
frame:setCamera(0, 5, 0, 0, 25, 0)
frame:setFoV(60)
frame:setBackgroundColor(colors.black)
local obj = frame:newObject(Pine3D.models:cube({color = colors.blue, side = colors.lime, side2 = colors.red}), 10, 5, 5, 0, 0, 60)
local i = 0
obj:setVertexShader(function(x, y, z) local fz = (z + math.sin(2 * math.pi * (z + i) / 20)) return x + math.sin(2 * math.pi * (x + i) / 20), y + math.sin(2 * math.pi * (y + i) / 20), z + math.sin(2 * math.pi * (z + i) / 20) end)
obj:setFragmentShader(function(x, y, z) return 2^math.floor((15 - 1/z) * 1.5 % 16) end)
for j = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^j, (15 - j) / 15, (15 - j) / 15, (15 - j) / 15) end
while i < 100 do
    local rstart = os.epoch "utc"
    frame:drawObjects({obj})
    frame:drawBuffer()
    sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
    i = i + (os.epoch "utc" - rstart) / 50
end
term.setCursorPos(1, 1)
