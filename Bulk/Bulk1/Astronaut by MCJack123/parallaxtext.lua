local pixelbox = require "pixelbox"
local util = require "util"
local readBDFFont = require "bdf"
local floor, ceil, min, max, tan, pi = math.floor, math.ceil, math.min, math.max, math.tan, math.pi
local fps = jit and config and config.get("clockSpeed") or 20
local text = table.concat({select(2, ...)}, " ")
local time = tonumber(..., 10)
local start = os.epoch "utc"
local w, h = term.getSize()
local win = window.create(term.current(), 1, 1, w, h)
w, h = w * 2, h * 3
term.clear()
local img = {}
local hw, hh = math.floor(w / 2), math.ceil(h / 2)
local bg, fg, fg2, fg3 = colors.black, colors.blue, colors.cyan, colors.lightBlue
term.setPaletteColor(fg, 0x3366BB)
term.setPaletteColor(fg2, 0x5588DD)
term.setPaletteColor(fg3, 0x7799EE)
for y = 1, h do img[y] = {} for x = 1, w do img[y][x] = bg end end
local r = hh - 7
--[[
local step = math.pi / (4 * r)
local miny = math.huge
for theta = 0, math.pi * 2, step do
    local px, py = r * math.cos(theta), r * math.sin(theta)
    miny = math.min(miny, hh+py)
    img[math.floor(hh+py)][math.floor(hw+px)] = py > -4 and sun2 or sun1
end
for y = miny + 1, h do
    local d = nil
    local a = false
    for x = 1, w do
        if img[y][x] ~= bg then if d and not a then break else d, a = img[y][x], true end
        elseif d then img[y][x], a = d, false end
    end
end
--]]
for i = 1, hh do
    local x, y = math.random(1, w), math.random(1, hh - 1)
    img[y][x] = math.random(0, 2) == 1 and colors.lightGray or colors.gray
end
do
    local y = 7
    local yper = r * 0.5
    while y < hh + 3 and yper >= 0.2 do
        local yy = math.floor(y)
        for x = 1, w do img[yy][x] = bg end
        y = y + yper
        yper = yper * 0.53
    end
end
--local file = assert(fs.open("Dubstep-Blackletter-16.bdf", "r"))
local file = assert(fs.open("badrobotlaser-16.bdf", "r"))
local font = readBDFFont(file.readAll())
file.close()
local scale = max(floor(h / font.size.px / 2), 1)
scale = max(floor((h / 2 + font.bounds.y * scale) / font.size.px), 1)
local fimg = util.drawText(text, font, scale, colors.white)
local scrollpos = w * 2
local fy = ceil((hh - #fimg) / 2) + 1
--time = time - (os.epoch "utc" - start) / 1000
local pix = pixelbox.new(win)
pix.canvas = {}
for y = 1, fy - 1 do pix.canvas[y] = img[y] end
for y = fy, fy + #fimg - 1 do pix.canvas[y] = setmetatable({}, {__index = function(_, x) return fimg[y-fy+1][x-scrollpos] or img[y][x] end}) end
for y = fy + #fimg, h do pix.canvas[y] = img[y] end
local tpi6, h6 = tan(pi / 6), h / 6
local colorlut = {nil, fg, fg, fg2, fg3, fg3}
for i = 1, time * 40, 40 / fps do
    local rstart = os.epoch "utc"
    --start = os.epoch "utc"
    local d, dx = 2, 1
    for y = hh + 3, h do
        local c = colorlut[floor(y / h6)]
        if d == dx then
            for x = 1, w do img[y][x] = c end
            d, dx = d + 1, 1
        else
            local dist = max(floor(tpi6 * (y - hh)), 1)
            local off = floor(dist * i/10)
            local dw = ceil(w / dist) * dist
            for x = 0, w, dist do
                img[y][(hw + x + off - 1) % dw + 1] = c
                img[y][(hw - x + off - 1) % dw + 1] = c
                for n = hw + x + 1, x + dist - 1 do img[y][(n + off - 1) % dw + 1] = bg end
                for n = hw - x - 1, hw - x - dist + 1, -1 do img[y][(n + off - 1) % dw + 1] = bg end
            end
            dx = dx + 1
        end
    end
    scrollpos = floor(w * 2 - i * w / font.size.px / 3 - i * (scale - 1) / 2)
    pix:render()
    --if i % 8 == 0 then mask.hscroll(-1, rs) end
    sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
    if (os.epoch "utc" - start) / 1000 > time then break end
end
term.setBackgroundColor(colors.black)
term.setCursorPos(1, 1)
term.clear()