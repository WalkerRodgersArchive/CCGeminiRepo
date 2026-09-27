local Pine3D = require "Pine3D"

local floor, min, max = math.floor, math.min, math.max

---@param sides number
---@param segments number
---@param colors (number|function|table)[]
---@return Model
local function makeTunnel(sides, segments, colors)
    local w = 1 / segments
    local polys = {}
    for i = 1, sides do
        local ax, ay = math.cos(2 * math.pi * (i - 1) / sides) / 2, math.sin(2 * math.pi * (i - 1) / sides) / 2
        local bx, by = math.cos(2 * math.pi * i / sides) / 2, math.sin(2 * math.pi * i / sides) / 2
        polys[#polys+1] = {x1 = -.5, y1 = ay, z1 = ax, x2 = -.5, y2 = by, z2 = bx, x3 = w-.5, y3 = by, z3 = bx, c = colors[(i) % #colors + 1]}
        polys[#polys+1] = {x1 = -.5, y1 = ay, z1 = ax, x2 = w-.5, y2 = by, z2 = bx, x3 = w-.5, y3 = ay, z3 = ax, c = colors[(i - 1) % #colors + 1]}
    end
    for i = 1, segments - 1 do
        for j = 1, sides * 2 do
            local p = polys[j]
            local cidx = (j % 2 == 0 and (j - 2) / 2 or (j + 1) / 2) - i
            polys[i*sides*2 + j] = {x1 = p.x1 + i * w, y1 = p.y1, z1 = p.z1, x2 = p.x2 + i * w, y2 = p.y2, z2 = p.z2, x3 = p.x3 + i * w, y3 = p.y3, z3 = p.z3, c = colors[cidx % #colors + 1]}
        end
    end
    for name, func in pairs(Pine3D.transforms) do
		polys[name] = func
	end
    return polys
end

local frame = Pine3D.newFrame()
local ar, ag, ab = 191 / 255, 138 / 255, 32 / 255
local br, bg, bb = 204 / 255, 119 / 255, 44 / 255
local bc = term.nativePaletteColor(colors.black)
--frame:setCamera(-1.41 * math.cos(math.rad(30)), 2, -1.41 * math.sin(math.rad(30)), 0, 0, -60)
frame:setFoV(90)
frame:setBackgroundColor(2^13)
--frame:setWireFrame(true)
local obj = frame:newObject(makeTunnel(10, 16, {2^0, 2^1}):scale(100, 3, 3), 3)
local pulse = 0
obj:setVertexShader(function(x, y, z)
    local d = 2*((pulse % 5) / 10)^2 + 1
    return x, y * d, z * d
end)
-- obj:setFragmentShader(function(x, y, depth, poly, texcolor, interpVars)
--     -- if not poly.n then
--     --     local a, b, c = vector.new(poly[1], poly[2], poly[3]), vector.new(poly[4], poly[5], poly[6]), vector.new(poly[7], poly[8], poly[9])
--     --     poly.n = (b - a):cross(c - a):normalize()
--     -- end
--     local n = (0.5 / depth)
--     n = n - n % 1
--     if n < 0 then n = 0 end
--     if n > 7 then n = 7 end
--     return texcolor * 2^(n*2)
-- end)
obj:setBakedFragmentShader[[
    local n = (0.5 / zInv)
    n = n - n % 1
    if n < 0 then n = 0 end
    if n > 6 then n = 6 end
    color = c * 2^(n*2)
]]
local ship = frame:newObject(Pine3D.loadModel("/models/ship"):scale(0.075, 0.075, 0.075), -12.5, -1, 0, 0, math.pi, 0)
local objlist = {obj, ship}
local particles = {}
local np = floor(math.sqrt(frame.width * frame.height) / 3)
for i = 1, np do
    local r, t = math.random() * 0.75, math.random() * 2 * math.pi
    particles[i] = vector.new(-(i / 8 + 12 + math.random() / 2), r * math.sin(t), r * math.cos(t))
end
frame:setCamera(-15, 0, 0, 0, 0, -15)
parallel.waitForAny(function()
    for i = 1, 20000 do
        if i <= 10 then
            local cr = i / 10
            local wr = 1 - cr
            for j = 0, 6 do
                local r = ((6 - j) / 16 + 0.5) * cr
                frame.buffer.blitWin.setPaletteColor(2^(j*2), ar * r + wr, ag * r + wr, ab * r + wr)
                frame.buffer.blitWin.setPaletteColor(2^(j*2+1), br * r + wr, bg * r + wr, bb * r + wr)
            end
            frame.buffer.blitWin.setPaletteColor(2^15, 0.6 * cr + wr, 0.5 * cr + wr, 0.4 * cr + wr)
            local b = bc * cr + wr
            frame.buffer.blitWin.setPaletteColor(2^14, b, b, b)
        end
        obj:setRot(math.rad(i * 10), 0, 0)
        if i >= 200 then ship:setPos(-12.5, -0.8, 0)
        else ship:setPos(-12.5, math.sin(i / 20 * 2 * math.pi) / -8 - 0.8, math.sin(i / 40 * 2 * math.pi) / 2) end
        ship:setRot(math.cos(i / 40 * 2 * math.pi) * math.pi / -8, math.pi, 0)
        frame:setCamera(-15 + i / 110, 0, 0, 0, 0, -15 - i / 6)
        frame:setFoV(90 - 90*math.min(i / 200, 0.99)^2)
        frame:drawObjects(objlist)
        local j = 1
        while j <= #particles do
            local p = particles[j]
            local x, y, d = frame:map3dTo2d(p.x, p.y, p.z)
            --print(d) sleep(0.05)
            if d >= 0.0001 then
                local n = (2 * d)
                n = n - n % 1
                if n < 0 then n = 0 end
                if n > 7 then n = 7 end
                frame.buffer:setPixel(x, y, 32768, false)
                p.x = p.x - 0.5
                j = j + 1
            else table.remove(particles, j) end
        end
        while #particles < np do
            local r, t = math.random() * 0.75, math.random() * 2 * math.pi
            particles[#particles+1] = vector.new(-((32 - #particles) / 8 + 12 + math.random() / 2), r * math.sin(t), r * math.cos(t))
        end
        frame:drawBuffer()
        if pulse > 0 then pulse = pulse - 1 end
        sleep(0.05)
    end
end, function()
    while true do
        os.pullEvent("pulse")
        pulse = 5
    end
end)
term.setCursorPos(1, 1)
