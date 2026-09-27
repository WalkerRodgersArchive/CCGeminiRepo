local box = require "pixelbox".new(term.current())
local bdf = require "bdf"
local util = require "util"
local canvas = box.canvas
local pal = {}
for i = 0, 15, 2 do
    pal[i] = {math.random() * 360, math.random() * 0.2 + 0.4, math.random() * 0.3 + 0.2}  -- hsv
    pal[i+1] = {pal[i][1], pal[i][2], pal[i][3] + 0.4}  -- hsv
end
local bc = term.nativePaletteColor(colors.black)
for i = 0, 15 do term.setPaletteColor(2^i, bc, bc, bc) end
local file = assert(fs.open("ZenDots/ZenDots-Regular-24.bdf", "r"))
local font = bdf(file.readAll())
file.close()

local movement, fadeup = 0
local textFrame
do
    local text, width = util.drawText("Let's explore a new dimension together...", font, 1, 2)
    textFrame = util.mode7(text, 0, 0, 0, 0, math.floor(width * box.height / #text / 1.25), box.height, 1, nil, util.scale(#text / box.height * 1.25, #text / box.height * 1.25, util.base()))
end
local textPos = box.width
parallel.waitForAny(function()
    for j = 1, 1000 do
        local r, t = math.sin(j / 17) * 0.25 + 0.7885, j / 10
        local cx, cy, R = math.cos(t) * r, math.sin(t) * r, 2
        local Rmx, Rmy, Ro, R2 = R / (box.width - 1), R / (box.height - 1), R / 2, R^2
        local ox, oy = math.cos(t * (1 + movement)) * movement / 2, math.sin(t * (1 + movement)) * movement / 2

        for y = 0, box.height-1 do
            local textline = textFrame[y+1] or {}
            local line = canvas[y+1]
            local zxo, zyo = ox - Ro, y * Rmy - Ro + oy
            local zy2o = zyo*zyo
            for x = 1, box.width do
                local zx, zy, zx2, zy2, i = zxo, zyo, zxo*zxo, zy2o, 0
                while zx2 + zy2 < R2 and i < 14 do
                    local ytemp = 2 * zx * zy
                    zx = zx2 - zy2 + cx
                    zy = ytemp + cy
                    zx2 = zx*zx
                    zy2 = zy*zy
                    i = i + 1
                end
                line[x] = 2^(i - i % 2) * (textline[x-textPos] or 1)
                zxo = zxo + Rmx
            end
        end
        box:render()

        if fadeup == true then fadeup = j end
        for i = 0, 15 do
            local c = pal[i][2] * pal[i][3]
            local h = (pal[i][1] + j) % 360 / 60
            local x = c * (1 - math.abs(h % 2 - 1))
            local r, g, b
            if h >= 5 then r, g, b = c, 0, x
            elseif h >= 4 then r, g, b = x, 0, c
            elseif h >= 3 then r, g, b = 0, x, c
            elseif h >= 2 then r, g, b = 0, c, x
            elseif h >= 1 then r, g, b = x, c, 0
            else r, g, b = c, x, 0 end
            local m = pal[i][3] - c
            r, g, b = r + m, g + m, b + m
            if j <= 10 then term.setPaletteColor(2^i, r * j / 10 + bc * (1 - j / 10), g * j / 10 + bc * (1 - j / 10), b * j / 10 + bc * (1 - j / 10))
            elseif fadeup then
                local wr = math.min((j - fadeup) / 10, 1)^2
                term.setPaletteColor(2^i, r * (1 - wr) + wr, g * (1 - wr) + wr, b * (1 - wr) + wr)
            else term.setPaletteColor(2^i, r, g, b) end
        end
        if movement > 0 then movement = movement + 0.02 end
        textPos = textPos - math.floor(box.width / 20)
        sleep(0.05)
    end
end, function()
    while true do
        local _, trigger = os.pullEvent("trigger")
        if trigger == 0 then movement = 0.02
        elseif trigger == 1 then fadeup = true end
    end
end)