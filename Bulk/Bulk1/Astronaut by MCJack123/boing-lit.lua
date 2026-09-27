package.path = package.path .. ";/?.lua"
local Pine3D = require "Pine3D"

local w, h = term.getSize()
w, h = w * 2, h * 3
local fps = jit and config and config.get("clockSpeed") or 20
local pi, pi2 = math.pi, math.pi * 2
local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max
local function tri(x) local p = x % pi2 if p >= pi then return (pi2 - p) / pi * 2 - 1 else return p / pi * 2 - 1 end end
local frame = Pine3D.newFrame()
for j = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^j, 1 - j / 15, 1 - j / 15, 1 - j / 15) end
frame:setCamera(0, 0, 0, 0, 0, 0)
frame:setFoV(60)
frame:setBackgroundColor(colors.black)
--frame:setWireFrame(true)
local obj = frame:newObject(Pine3D.models:icosphere({colors = {0, 8}, colorsFractal = true, res = 2}), 4, 0, 0, 0, 0, 0)
local obj_shadow = frame:newObject(Pine3D.models:icosphere({color = colors.white, res = 2}), 4, 0, 0, 0, 0, 0)
local lightpos = vector.new(-5, 5, 0)
local list = {obj_shadow, obj}
local i = 0
local normdat = {}
obj_shadow:setVertexShader(function(x, y, z, poly, n)
    local vx = normdat[poly] or {}
    vx[n] = vector.new(x, y, z)
    normdat[poly] = vx
    if vx[1] and vx[2] and vx[3] then
        local norm = (vx[2] - vx[1]):cross(vx[3] - vx[1]):normalize()
        for v = 1, 3 do
            local found = false
            for _, n in ipairs(normdat) do
                if math.abs((n.vertex - vx[v]):length()) < 0.00001 then
                    n[#n+1] = norm
                    found = true
                    break
                end
            end
            if not found then normdat[#normdat+1] = {vertex = vx[v], norm} end
        end
    end
    return 0, 0, 0
end)
obj:setVertexShader(function(x, y, z)
    --[[]]
    local vx = vector.new(x, y, z)
    for _, n in ipairs(normdat) do
        if math.abs((n.vertex - vx):length()) < 0.001 then
            if not n.norm then
                local sum = n[1]
                for i = 2, #n do sum = sum + n[i] end
                n.norm = sum:div(#n):normalize()
                n.c = min(max(((lightpos - vx):normalize():dot(n.norm) + 1) / 2, 0), 1)
            end
            return x, y, z, {c = n.c}
        end
    end
    return x, y, z
end)
obj:setFragmentShader(function(x, y, depth, poly, c, interpVars)
    return 2^min(max(floor((1 - interpVars.c) * 15) + c, 0), 15)
end)

--obj:setVertexShader(function(x, y, z) local fz = math.sin(2 * math.pi * (z * 20 + i / 2) / 25) / 5 return x, y + fz, z end)
while i < 200 do
    --setmetatable(img, {__index = gif[i % #gif + 1], __len = function() return imgh end})
    --if img.palette then for j = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^j, table.unpack(img.palette[j])) end end
    local oy, oz = math.abs(math.cos(pi2 * i / 64)) - 0.5, tri(pi2 * i / 90)
    lightpos = vector.new(-5, math.sin(pi2 * i / 50) * 5, math.cos(pi2 * i / 50) * 5)
    obj:setPos(4, oy, oz)
    obj:setRot(-pi / 8, pi / 32 * i, 0)
    obj_shadow:setPos(4, oy, oz)
    obj_shadow:setRot(-pi / 8, pi / 32 * i, 0)
    normdat = {}
    frame:drawObjects(list)
    frame:drawBuffer()
    sleep(1 / fps)
    i = i + 1
end
term.setCursorPos(1, 1)