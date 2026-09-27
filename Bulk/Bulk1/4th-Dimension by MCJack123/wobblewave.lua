package.path = package.path .. ";/?.lua"
local Pine3D = require "Pine3D"
local util = require "util"
local fps = jit and config and config.get("clockSpeed") or 20

local function newPoly(x1, y1, z1, x2, y2, z2, x3, y3, z3, c)
	---@type Polygon
	local poly = {
		x1 = x1,
		y1 = y1,
		z1 = z1,
		x2 = x2,
		y2 = y2,
		z2 = z2,
		x3 = x3,
		y3 = y3,
		z3 = z3,
		c = c,
	}
	return poly
end

local floor, min, max, sin, cos, sqrt, abs, rad = math.floor, math.min, math.max, math.sin, math.cos, math.sqrt, math.abs, math.rad

local function multiplane(res, scale, c)
    res = res or 32
    --w, h = w or #texture[1], h or #texture
    scale = scale or 1
    ---@type Model
    local model = {}
    local resinv = 1 / res
    for y = 0, 0.9999999, resinv do
        for x = 0, 0.9999999, resinv do
            --local u1, v1, u2, v2 = floor(x * w + 1), floor(y * h + 1), floor((x + resinv) * w), floor((y + resinv) * h)
            model[#model+1] = newPoly(
                (0.5 - y) * scale, 0, (x - 0.5) * scale,
                (0.5 - y - resinv) * scale, 0, (x - 0.5) * scale,
                (0.5 - y - resinv) * scale, 0, (x + resinv - 0.5) * scale,
                c
            )
            model[#model+1] = newPoly(
                (0.5 - y) * scale, 0, (x + resinv - 0.5) * scale,
                (0.5 - y) * scale, 0, (x - 0.5) * scale,
                (0.5 - y - resinv) * scale, 0, (x + resinv - 0.5) * scale,
                c
            )
        end
    end

    for name, func in pairs(Pine3D.transforms) do
		model[name] = func
	end

	return model
end

local bc = term.nativePaletteColor(colors.black)
local rev, revdir = 0, -1
local fadeup
local function hsv(h, s, v)
    local c = s * v
    local h2 = h % 360 / 60
    local x = c * (1 - abs(h2 % 2 - 1))
    local r, g, b
    if h2 >= 5 then r, g, b = c, 0, x
    elseif h2 >= 4 then r, g, b = x, 0, c
    elseif h2 >= 3 then r, g, b = 0, x, c
    elseif h2 >= 2 then r, g, b = 0, c, x
    elseif h2 >= 1 then r, g, b = x, c, 0
    else r, g, b = c, x, 0 end
    local m = v - c
    local fr, br = (1 - rev / 10) * (1 - bc), rev / 10 * (1 - bc)
    local rr, gg, bb = r + m, g + m, b + m
    return min(rr * fr + (1 - rr) * br + bc, 1), min(gg * fr + (1 - gg) * br + bc, 1), min(bb * fr + (1 - bb) * br + bc, 1)
end

local i, t, u, v, p = 0, 0, 0, 0, 0
local vm = {}
local function vs(x, y, z, poly, n)
    local k = z*100+x
    local o = vm[k] or (.25 * sin(sqrt((sqrt(100 * x^2 + v) - v)^2 + (sqrt(100 * z^2 + u) - u)^2) + t))
    vm[k] = o
    if n == 3 then
        local a, b = poly[21], poly[22]
        local ax, ay, az = a[1], a[2], a[3]
        local bx, by, bz = b[1], b[2], b[3]
        local cx, cy, cz = x, y + o, z
        local bax, bay, baz = bx - ax, by - ay, bz - az
        local cax, cay, caz = cx - ax, cy - ay, cz - az
        local normx, normy, normz =
            bay * caz - baz * cay,
            baz * cax - bax * caz,
            bax * cay - bay * cax
        local normlen = sqrt(normx*normx + normy*normy + normz*normz)
        normy = normy / normlen
        poly[11] = 2^(15-min(max(floor(normy * 15), 0), 15))
    else poly[n+20] = {x, y + o, z} end
    local m = 1 + p * 2
    return x * m, y + o * m, z * m
end

local frame = Pine3D.newFrame()
frame:setCamera(-1.41 * cos(rad(30)), 1, -1.41 * sin(rad(30)), 0, 0, -45)
frame:setFoV(90)
frame:setBackgroundColor(colors.black)
local obj = frame:newObject(multiplane(jit and 48 or 32, 5), 0, 0, 0, 0, 0, 0)
obj:setVertexShader(vs)

parallel.waitForAny(function()
    while true do
        t = i * .3
        u = (sin(i / 27) + 1) * 10
        v = (sin(i / 43) + 1) * 10
        p = p * 0.5
        vm = {}
        local h, sp = i * 4, frame.buffer.blitWin.setPaletteColor
        if i <= 20 then local r = i / 20 for j = 0, 15 do sp(2^j, hsv(h, 0.5, r * (15-j) / 15)) end
        elseif fadeup then local r = min(fadeup / 10, 1)^2 for j = 0, 15 do sp(2^j, hsv(h, 0.5 - r / 2, (1 - r) * (15-j) / 15 + r)) end fadeup = fadeup + 1
        else for j = 0, 15 do sp(2^j, hsv(h, 0.5, (15-j) / 15)) end end
        if rev > 0 and rev < 10 then rev = rev + revdir end
        --local rstart = os.epoch "utc"
        frame:setCamera(-1.41 * cos(rad(i * 4)), cos(i / 40) / 6 + 0.866, -1.41 * sin(rad(i * 4)), 0, i * 4, cos(i / 40) * -15 - 30)
        frame:drawObjects({obj})
        frame:drawBuffer()
        --term.setCursorPos(1, 1) term.write(os.epoch "utc" - rstart)
        -- sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
        -- i = i + (os.epoch "utc" - rstart) / 50
        sleep(0.05)
        i = i + 1
    end
end, function()
    while true do
        os.pullEvent("pulse")
        if p < 0.125 then p = 0.25 end
    end
end, function()
    while true do
        local _, trigger = os.pullEvent("trigger")
        if trigger == 0 then
            revdir = -revdir
            rev = rev + revdir
        elseif trigger == 1 then
            fadeup = 0
        else
            obj = frame:newObject(multiplane(trigger, 5), 0, 0, 0, 0, 0, 0)
            obj:setVertexShader(vs)
        end
    end
end)
