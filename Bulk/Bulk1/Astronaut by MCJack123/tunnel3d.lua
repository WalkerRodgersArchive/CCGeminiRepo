package.path = package.path .. ";/Pine3D/?.lua"
local Pine3D = require "Pine3D"
local util = require "util"
local time = tonumber(...)
local fps = config and config.get("clockSpeed") or 20
local start = os.epoch "utc"
do
    local gr, gg, gb = term.nativePaletteColor(colors.lightGray)
    local br, bg, bb = term.nativePaletteColor(colors.lightBlue)
    for i = 0, 7 do
        local r = i / 14 + 0.5
        term.setPaletteColor(2^i, gr * r, gg * r, gb * r)
        term.setPaletteColor(2^(i+8), br * r, bg * r, bb * r)
    end
end
local frame = Pine3D.newFrame()
local object = frame:newObject(util.loadCompressedModel("/tunnel.cob"), 0, -1, 0)
local floor, min, max = math.floor, math.min, math.max
object:setFragmentShader(function(x, y, depth, poly, color)
    return 2^(7 - min(max(floor(5 / depth), 0), 7) + (color == 8 and 8 or 0))
end)
frame:setBackgroundColor(colors.black)
frame:setCamera(0, -1, -1, 180, 180, 0)
frame:setFoV(90)
frame:drawObjects({object})
frame:drawBuffer()
local pos = {-1, 0, -1}
local var = {"y", "x", "z"}
local look = {180, 180, 0}
local veca = vector.new()
local istart, jstart
for _ = 1, 2 do
    for i = 1, 6 do
        local s, ls = (i % 3 ~= 1 and -1 or 1), (i == 6 and 1 or -1)
        local lidx = i % 3 == 1 and 2 or 3
        local newlook = {look[1], look[2], look[3]}
        local j = 0
        while j < 15 do
            local rstart = os.epoch "utc"
            if os.epoch "utc" - start >= time * 1000 then
                term.setBackgroundColor(colors.black)
                term.setCursorPos(1, 1)
                term.clear()
                return
            end
            local t = math.pi / 2 * j/15 * s
            local newpos = {pos[1], pos[2] * math.cos(t) + pos[3] * math.sin(t), pos[3] * math.cos(t) - pos[2] * math.sin(t)}
            newlook[lidx] = look[lidx] + 90 * ls * math.sin(t)
            if i % 3 == 0 then newlook[1] = look[1] + (i == 3 and -90 or 90) * ls * math.sin(t) end
            veca[var[1]] = newpos[1]
            veca[var[2]] = newpos[2]
            veca[var[3]] = newpos[3]
            frame:setCamera(veca.x, veca.y, veca.z, newlook[1], newlook[2], newlook[3])
            frame:drawObjects({object})
            --frame.buffer.blittleWindow.setPaletteColor(colors.lightBlue, term.getPaletteColor(colors.lightBlue))
            frame:drawBuffer()
            sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
            j = j + (os.epoch "utc" - rstart) / 50
        end
        pos = {pos[3] * s, -pos[2] * s, pos[1]}
        var = {var[2], var[3], var[1]}
        look[lidx] = (look[lidx] + 90 * ls * s) % 360
        if i % 3 == 0 then look[1] = (look[1] + (i == 3 and -90 or 90) * ls * s) % 360 end
        -- fix gimbal lock
        if i == 2 then
            look[1] = (look[1] - 90) % 360
            look[2] = (look[2] + 90) % 360
        elseif i == 5 then
            look[1] = (look[1] - 90) % 360
            look[2] = (look[2] - 90) % 360
        end
        if TUNNEL_BACKWARDS then istart = i break end
    end
    look = {(look[1] + 180) % 360, (look[2] + 180) % 360, (look[3] + 180) % 360}
    if TUNNEL_BACKWARDS then break end
end
local h, sat, v = 223, 0.37, 0.95 -- lightBlue
local function hsvtorgb()
	if s == 0 then
		-- achromatic (grey)
		return v, v, v
    end

	local h = h / 60
	local i = math.floor(h)
	local f = h - i
	local p = v * (1 - sat)
	local q = v * (1 - sat * f)
	local t = v * (1 - sat * (1 - f))

    if i == 0 then return v, t, p
    elseif i == 1 then return q, v, p
    elseif i == 2 then return p, v, t
    elseif i == 3 then return p, q, v
    elseif i == 4 then return t, p, v
    else return v, p, q end
end
local spread, fade = 0.005, 1
local mult = 20 / fps
--_G.TUNNEL_WIREFRAME = true
for run = 1, 6 do
    if run == 5 then
        object:setVertexShader(function(x, y, z, poly, vn)
            return x + math.random() * spread - spread / 2, y + math.random() * spread - spread / 2, z + math.random() * spread - spread / 2
        end)
    end
    look = {(look[1] - 180) % 360, (look[2] - 180) % 360, (look[3] - 180) % 360}
    for i = istart or 6, 1, -1 do
        -- fix gimbal lock
        if i == 2 then
            look[1] = (look[1] + 90) % 360
            look[2] = (look[2] - 90) % 360
        elseif i == 5 then
            look[1] = (look[1] + 90) % 360
            look[2] = (look[2] + 90) % 360
        end
        local s, ls = (i % 3 ~= 1 and -1 or 1), (i == 6 and 1 or -1)
        local lidx = i % 3 == 1 and 2 or 3
        pos = {pos[3], -pos[2] * s, pos[1] * s}
        var = {var[3], var[1], var[2]}
        look[lidx] = (look[lidx] - 90 * ls * s) % 360
        if i % 3 == 0 then look[1] = (look[1] - (i == 3 and -90 or 90) * ls * s) % 360 end
        local newlook = {look[1], look[2], look[3]}
        local j = 14.95
        while j >= 0 do
            local rstart = os.epoch "utc"
            if TUNNEL_WIREFRAME then
                --frame:setWireFrame(true)
                --[[object:setFragmentShader(function(x, y, depth, poly)
                    local m = (2 * x + 3 * y + 5 * x * y / 2 + 7 * h) % 11
                    local a = 0
                    if m > 9 then a = 1
                    elseif m < 3 then a = -1 end
                    return 2^(7 - min(max(floor(5 / depth) + a, 0), 7) + (poly[11] == 8 and 8 or 0))
                end)]]
                local brickTexture = {
                    {8192, 8192, 8192, 4, 8192, 8192, 8192, 4, 8192},
                    {8192, 8192, 8192, 4, 8192, 8192, 8192, 4, 8192},
                    {4, 4, 4, 4, 4, 4, 4, 4, 4},
                    {8192, 4, 8192, 8192, 8192, 4, 8192, 8192, 8192},
                    {8192, 4, 8192, 8192, 8192, 4, 8192, 8192, 8192},
                    {4, 4, 4, 4, 4, 4, 4, 4, 4},
                    {8192, 8192, 8192, 4, 8192, 8192, 8192, 4, 8192},
                    {8192, 8192, 8192, 4, 8192, 8192, 8192, 4, 8192},
                    {4, 4, 4, 4, 4, 4, 4, 4, 4},
                    {8192, 4, 8192, 8192, 8192, 4, 8192, 8192, 8192},
                    {8192, 4, 8192, 8192, 8192, 4, 8192, 8192, 8192},
                    {4, 4, 4, 4, 4, 4, 4, 4, 4},
                    {8192, 8192, 8192, 4, 8192, 8192, 8192, 4, 8192},
                }
                object:setFragmentShader(function(x, y, depth, poly, color)
                    if color == 8192 then return 2^(7 - min(max(floor(5 / depth), 0), 7) + 8)
                    else return 2^(2 - min(max(floor(2 / depth), 0), 2)) end
                end)
                term.clear()
                term.setCursorPos(1, 1)
                for k, poly in ipairs(object[7]) do
                    local l12, l23, l31 =
                        math.sqrt((poly[4] - poly[1])^2 + (poly[5] - poly[2])^2 + (poly[6] - poly[3])^2),
                        math.sqrt((poly[7] - poly[4])^2 + (poly[8] - poly[5])^2 + (poly[9] - poly[6])^2),
                        math.sqrt((poly[1] - poly[7])^2 + (poly[2] - poly[8])^2 + (poly[3] - poly[9])^2)
                    if l12 > l23 and l12 > l31 then
                        if math.abs(poly[2] - poly[8]) < 0.01 then poly[11] = {1, 1, 9, 13, 9, 1, brickTexture}
                        else poly[11] = {1, 1, 9, 13, 1, 13, brickTexture} end
                    elseif l23 > l31 and l23 > l12 then poly[11] = {9, 1, 1, 1, 9, 13, brickTexture}
                    else
                        if math.abs(poly[5] - poly[8]) < 0.01 then poly[11] = {1, 1, 1, 13, 9, 13, brickTexture}
                        else poly[11] = {1, 1, 9, 1, 9, 13, brickTexture} end
                    end
                end
                _G.TUNNEL_WIREFRAME = nil
            end
            if os.epoch "utc" - start >= time * 1000 then
                term.setBackgroundColor(colors.black)
                term.setCursorPos(1, 1)
                term.clear()
                return
            end
            local t = math.pi / 2 * j/15 * s
            local newpos = {pos[1], pos[2] * math.cos(t) + pos[3] * math.sin(t), pos[3] * math.cos(t) - pos[2] * math.sin(t)}
            newlook[lidx] = look[lidx] + 90 * ls * math.sin(t)
            if i % 3 == 0 then newlook[1] = look[1] + (i == 3 and -90 or 90) * ls * math.sin(t) end
            veca[var[1]] = newpos[1]
            veca[var[2]] = newpos[2]
            veca[var[3]] = newpos[3]
            frame:setCamera(veca.x, veca.y, veca.z, newlook[1], newlook[2], newlook[3])
            frame:drawObjects({object})
            frame:drawBuffer()
            do
                if TUNNEL_BREAKDOWN then
                    local c, d = term.nativePaletteColor(colors.lightGray), term.nativePaletteColor(colors.black)
                    sat, v = math.max(0.37 * fade, 0), d + math.max((0.95 - d) * fade, 0)
                    c = math.max((c - d) * fade, 0)
                    local r, g, b = hsvtorgb()
                    for k = 0, 7 do
                        local m = k / 14 + 0.5
                        term.setPaletteColor(2^k, d + c * m, d + c * m, d + c * m)
                        term.setPaletteColor(2^(k+8), d + (r - d) * m, d + (g - d) * m, d + (b - d) * m)
                    end
                    fade = math.max(fade - 0.0075*mult, 0)
                else
                    if run > 2 then sat = 0.37 + 0.3 * (-math.cos(((i - 1) / 6 + j / (15*6)) * 2 * math.pi) + 1) end
                    local r, g, b = hsvtorgb()
                    for k = 0, 7 do
                        local m = k / 14 + 0.5
                        term.setPaletteColor(2^(k+8), r * m, g * m, b * m)
                    end
                end
                h = (h + 5*mult) % 360
            end
            if TUNNEL_BREAKDOWN then spread = spread*1.04^mult end
            sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
            mult = (os.epoch "utc" - rstart) / 50
            j = j - mult
        end
        istart, jstart = nil
    end
end
term.setBackgroundColor(colors.black)
term.setCursorPos(1, 1)
term.clear()