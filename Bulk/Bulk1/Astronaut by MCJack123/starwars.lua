local pixelbox = require "pixelbox"
local util = require "util"
local readBDFFont = require "bdf"
local fast = config and not config.get("standardsMode")

local file = assert(fs.open(..., "r"))
local font = readBDFFont(file.readAll())
file.close()
file = assert(fs.open(select(2, ...), "r"))
local img, imgw, imgh = util.drawText(file.readAll(), font, 4, colors.yellow)
file.close()

local px = pixelbox.new(term.current())
local w, h = px.width, px.height

local bgimg = {}
local hw, hh = math.floor(w / 2), math.ceil(h / 2)
local bg, fg, fg2, fg3 = colors.black, colors.blue, colors.cyan, colors.lightBlue
term.setPaletteColor(fg, 0x3366BB)
term.setPaletteColor(fg2, 0x5588DD)
term.setPaletteColor(fg3, 0x7799EE)
for y = 1, h do bgimg[y] = {} for x = 1, w do bgimg[y][x] = bg end end
local r = hh - 7
for i = 1, h do
    local x, y = math.random(1, w), math.random(1, h)
    bgimg[y][x] = math.random(0, 2) == 1 and colors.lightGray or colors.gray
end
do
    local y = 7
    local yper = r * 0.5
    while y < hh + 3 and yper >= 0.2 do
        local yy = math.floor(y)
        for x = 1, w do bgimg[yy][x] = bg end
        y = y + yper
        yper = yper * 0.53
    end
end

--[[local tpi6, h6 = math.tan(math.pi / 6), h / 6
local colorlut = {nil, fg, fg, fg2, fg3, fg3}
local d, dx = 2, 1
for y = hh + 3, h do
    local c = colorlut[math.floor(y / h6)]
    if d == dx then
        for x = 1, w do bgimg[y][x] = c end
        d, dx = d + 1, 1
    else
        local dist = math.max(math.floor(tpi6 * (y - hh)), 1)
        local off = 0
        local dw = math.ceil(w / dist) * dist
        for x = 0, w, dist do
            bgimg[y][(hw + x + off - 1) % dw + 1] = c
            bgimg[y][(hw - x + off - 1) % dw + 1] = c
            for n = hw + x + 1, x + dist - 1 do bgimg[y][(n + off - 1) % dw + 1] = bg end
            for n = hw - x - 1, hw - x - dist + 1, -1 do bgimg[y][(n + off - 1) % dw + 1] = bg end
        end
        dx = dx + 1
    end
end]]

local start = os.epoch "utc"
for i = 1, imgh + h * imgw * 2 / w + 10 * math.sqrt(h / imgh) + 1, (fast and 10 or 25) * math.sqrt(h / imgh) do
    px.canvas = util.mode7(img, (imgw - w) / 2 + w / 2, i, (imgw - w) / 2, i - h, w, h, colors.black, function(y, dx, dy, a, b, c, d) if y < h / 3 then return dx, dy, 1, 0, 0, 0, 0 end local l = h * imgw / w / y return dx, dy, 1, a * l, b * l, c * l, d * l end, util.base())
    for y, line in ipairs(px.canvas) do for x = 1, #line do if line[x] == 32768 then line[x] = bgimg[y][x] end end end
    px:render()
    sleep(fast and 0.02 or 0.05)
end
--print(os.epoch "utc" - start)
