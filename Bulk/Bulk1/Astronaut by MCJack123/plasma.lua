local pixelbox = require "pixelbox"
local util = require "util"
local time = tonumber(...)
local start = os.epoch "utc"
local w, h = term.getSize()
w, h = w * 2, h * 3
local fps = jit and config and config.get("clockSpeed") or 20
local map = {{}}
local cr = math.max(math.floor(w / 8), 12)
local min, max = 0, math.sqrt(math.floor(cr / 2)^2 * 2)
for y = 1, cr + 1 do
    map[y] = {}
    for x = 1, cr + 1 do
        map[y][x] = math.sqrt((x-cr/2-1)^2 + (y-cr/2-1)^2)
    end
end
util.tile(map, cr+1, cr+1)
term.clear()
term.setCursorPos(1, 1)
for i = 0, 15 do term.setPaletteColor(2^i, i / 15, i / 15, i / 15) end
local range = 16 / (max - min)
local pix = pixelbox.new(term.current())
local buf = pix.canvas
_G.PLASMA_BUFF = 0
local i = 1
while i <= time * 20 do
    local rstart = os.epoch "utc"
    for j = 0, 15 do
        local xx = (i / 50 + j / 16) % 1
        --[[
        local r = (math.max(math.abs(3.0*xx - 1.5) - 0.5, 0.0)) * intensity + base
        local g = (math.max(1 - math.abs(3.0*xx - 1), 0.0)) * intensity + base
        local b = (math.max(1 - math.abs(3.0*xx - 2), 0.0)) * intensity + base
        --[=[]]
        local r = (math.sin(2 * math.pi * xx) + 1) / 2
        local g, b = r / 2, (1 - r) / 4
        --]=]
        if PLASMA_BUFF > 0 then
            r, g, b = math.min(r + PLASMA_BUFF, 1), math.min(g + PLASMA_BUFF, 1), math.min(b + PLASMA_BUFF, 1)
        end
        term.setPaletteColor(2^j, r, g, b)
    end
    if PLASMA_BUFF > 0 then _G.PLASMA_BUFF = PLASMA_BUFF - 0.05 end
    for y = 1, h do
        local c = buf[y]
        map[y] = map[y] or {}
        local ty = math.floor(y + i - math.sin(2 * math.pi * (y + 2*i) / 30) * (cr / 16))
        local ymod = math.cos(2 * math.pi * (y + 3*i) / h) * (cr / 2)
        for x = 1, w do
            local tx = math.floor(x + ymod - i - math.cos(2 * math.pi * (x) / 30) * (cr / 16))
            c[x] = 2^(math.max(math.min(math.floor(((map[ty] and map[ty][tx] or (min + max) / 2) - min) * range), 15), 0))
        end
    end
    pix:render()
    sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
    if (os.epoch "utc" - start) / 1000 > time then break end
    i = i + (os.epoch "utc" - rstart) / 50
end
for i = 0, 15 do term.setPaletteColor(2^i, term.nativePaletteColor(2^i)) end
term.setBackgroundColor(colors.black)
term.setCursorPos(1, 1)
term.clear()