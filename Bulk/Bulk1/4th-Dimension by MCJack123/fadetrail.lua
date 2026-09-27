local Pine3D = require "Pine3D"
local sin, pi, random, sqrt, min, max, floor = math.sin, math.pi, math.random, math.sqrt, math.min, math.max, math.floor
local frame = Pine3D.newFrame()
frame:setBackgroundColor(1)
local model = Pine3D.loadModel("models/blob"):center():scale(0.2)
local objs, objlist = {}, {}
local p = 0
local function vs(cx, cy, cz, poly, n)
    if n == 3 then
        local a, b = poly[21], poly[22]
        local ax, ay, az = a[1], a[2], a[3]
        local bx, by, bz = b[1], b[2], b[3]
        local bax, bay, baz = bx - ax, by - ay, bz - az
        local cax, cay, caz = cx - ax, cy - ay, cz - az
        local normx, normy, normz =
            bay * caz - baz * cay,
            baz * cax - bax * caz,
            bax * cay - bay * cax
        local normlen = sqrt(normx*normx + normy*normy + normz*normz)
        normy = normy / normlen
        poly[11] = 2^(13+min(max(floor(normy * 4), 0), 2))
    else poly[n+20] = {cx, cy, cz} end
    local m = 1 + p * 2
    return cx * m, cy * m, cz * m
end
for i = 1, 20 do
    local obj = frame:newObject(model, 0, 0, 0, 0, 0, 0)
    obj:setVertexShader(vs)
    objlist[i] = obj
    objs[i] = {
        obj = obj,
        xfreq  = 2 * pi / random(50, 150),
        yfreq  = 2 * pi / random(50, 150),
        zfreq  = 2 * pi / random(50, 150),
        rxfreq = 2 * pi / random(50, 150),
        ryfreq = 2 * pi / random(50, 150),
        rzfreq = 2 * pi / random(50, 150),
        xpha  = random() * 2 * pi,
        ypha  = random() * 2 * pi,
        zpha  = random() * 2 * pi,
        rxpha = random() * 2 * pi,
        rypha = random() * 2 * pi,
        rzpha = random() * 2 * pi,
    }
end
local lastFrame = {}
for y = 1, frame.height do lastFrame[y] = {} end
local bc = term.nativePaletteColor(colors.black)
local trig
parallel.waitForAny(function()
    for i = 1, math.huge do
        if trig == true then trig = i end
        if i <= 10 then
            local br = i / 10 * (1 - bc)
            local wr = (1 - i / 10) * (1 - bc) + bc
            for j = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^j, j / 15 * br + wr, j / 22 * br + wr, j / 32 * br + wr) end
        elseif trig then
            if i - trig <= 10 then
                local br = (trig + 10 - i) / 10 * (1 - bc)
                local wr = (1 - (trig + 10 - i) / 10) * (1 - bc) + bc
                for j = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^j, j / 15 * br + wr, j / 22 * br + wr, j / 32 * br + wr) end
            end
        else
            local b = bc + p / 4
            local br = (1 - b)
            local wr = b
            for j = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^j, j / 15 * br + wr, j / 22 * br + wr, j / 32 * br + wr) end
        end
        p = p * 0.5
        for _, v in ipairs(objs) do
            v.obj:setPos(sin(v.xfreq * i + v.xpha) * 2.5 + 5, sin(v.yfreq * i + v.ypha) * 1.25, sin(v.zfreq * i + v.zpha) * 2.5)
            v.obj:setRot(sin(v.rxfreq * i + v.rxpha) * 2 * pi, sin(v.ryfreq * i + v.rypha) * 2 * pi, sin(v.rzfreq * i + v.rzpha) * 2 * pi)
        end
        frame:drawObjects(objlist)
        for y, line in ipairs(frame.buffer.colorValues) do
            local l = lastFrame[y]
            for x, c in ipairs(line) do
                if c == 1 then c = (l[x] or 1) / 8 end
                if c < 1 then c = 1 end
                l[x] = c
                line[x] = c
            end
        end
        frame:drawBuffer()
        sleep(0.05)
    end
end, function()
    while true do
        os.pullEvent("pulse")
        p = 0.5
    end
end, function()
    while true do
        os.pullEvent("trigger")
        trig = true
    end
end)