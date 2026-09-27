term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
local bc = term.nativePaletteColor(colors.black)
for i = 0, 15 do term.setPaletteColor(2^i, bc, bc, bc) end

local w, h = term.getSize()
w, h = w * 2, h * 3
local box = require "pixelbox".new(term.current())
local bdf = require "bdf"
local util = require "util"
local file = assert(fs.open("ZenDots/ZenDots-Regular-24.bdf", "r"))
local font = bdf(file.readAll())
file.close()
file = assert(fs.open("krishna.bmp", "rb"))
file.seek("set", 0x36)
local pal = {}
for i = 0, 7 do
    local b, g, r, _ = file.read(), file.read(), file.read(), file.read()
    term.setPaletteColor(2^(i+8), bc, bc, bc)
    pal[i] = {r / 255, g / 255, b / 255}
end
local imgw, imgh = 640, 383
local bg = {}
for y = 1, imgh do
    local line = {}
    bg[imgh-y+1] = line
    for x = 1, imgw, 2 do
        local c = file.read()
        line[x], line[x+1] = 2^bit32.rshift(c, 4) * 256, 2^bit32.band(c, 15) * 256
    end
end
file.close()
bg = util.mode7(bg, 0, 0, 0, 0, w, h, 32768, nil, util.scale(imgw / w, imgh / h, util.base()))
for y = 1, h do assert(bg[y], y) for x = 1, w do assert(bg[y][x], x .. " " .. y) end end

local function drawText(x, y, text, base, fade)
    local img, width = util.drawText(text, font, 1, 2)
    local scaleA = util.mode7(img, width / 2, #text / 2, -(box.width / 2 - width) / 2, -(box.height / 2 - #text) / 2, math.floor(w / 2), math.floor(h / 2), 1, nil, util.scale(width / (box.width / 2) * 1.40, width / (box.width / 2) * 1.40, util.base()))
    local scaleB = util.mode7(img, width / 2, #text / 2, -(box.width / 2 - width) / 2, -(box.height / 2 - #text) / 2, math.floor(w / 2), math.floor(h / 2), 1, nil, util.scale(width / (box.width / 2) * 1.35, width / (box.width / 2) * 1.35, util.base()))
    for yy = 1, h / 2 do
        local l = box.canvas[yy+y-1]
        local la, lb = scaleA[yy], scaleB[yy]
        if l then
            for xx = 1, w / 2 do
                local c = (la[xx] or 1) * (lb[xx] or 1)
                l[xx+x-1] = c > 1 and c * base / 2 or nil
            end
        end
    end
    local bc = 0.25 -- override
    for j = 1, 2 do term.setPaletteColor(2^(j-1) * base, bc, bc, bc) end
    box:render()
    for i = 1, 5 do
        sleep(0.05)
        for j = 1, 2 do
            local wr = (1 - (1 - i / 5)^2) * j / 2 * (1 - bc) + bc
            term.setPaletteColor(2^(j-1) * base, wr * 7/8 + bc * 1/8, wr, wr)
        end
        for j = 1, 2 do
            local wr = (1 - (i / 5)^2) * j / 2 * (1 - bc) + bc
            term.setPaletteColor(2^(j-1) * fade, wr * 7/8 + bc * 1/8, wr, wr)
        end
    end
end

for y = 1, h do box.canvas[y] = setmetatable({}, {__index = bg[y] or function() return 256 end}) end
parallel.waitForAll(function()
    drawText(math.floor(-w / 32), math.floor(-h / 32), "subhetsa to:", 1, 4)
    os.pullEvent("pulse")
end, function()
    for i = 1, 5 do
        sleep(0.05)
        local cr = i / 5 * (1 - bc)
        for j = 0, 7 do term.setPaletteColor(2^(j+8), pal[j][1] * cr + bc, pal[j][2] * cr + bc, pal[j][3] * cr + bc) end
    end
end)

local positions = {[0] = {math.floor(w / 2), 0}, {math.floor(w / 2), math.floor(h / 2 - h / 16)}, {0, math.floor(h / 2)}}
file = assert(fs.open("greetings.txt", "r"))
local i = 0
for line in file.readLine do
    --local c = {}
    --for y = 1, h do c[y] = setmetatable({}, {__index = base[y]}) end
    --box.canvas = c
    drawText(positions[i % 3][1], positions[i % 3][2], line, 4^(i % 3 + 1), 4^((i-1) % 3 + 1))
    local clearx, cleary = positions[(i - 1) % 3][1], positions[(i - 1) % 3][2]
    for y = 1, h / 2 do
        local l = box.canvas[y+cleary]
        for x = 1, w / 2 do
            l[x+clearx] = nil
        end
    end
    os.pullEvent("pulse")
    i = i + 1
end
local clearx, cleary = positions[(i - 1) % 3][1], positions[(i - 1) % 3][2]
for y = 1, h / 2 do
    local l = box.canvas[y+cleary]
    for x = 1, w / 2 do
        l[x+clearx] = nil
    end
end
box:render()
os.pullEvent("trigger")
term.setBackgroundColor(colors.black)
term.clear()
for j = 0, 14 do term.setPaletteColor(2^j, term.nativePaletteColor(2^j)) end
for i = 0, 20 do
    local c = (1 - i / 20)^2 * (1 - bc) + bc
    term.setPaletteColor(colors.black, c, c, c)
    sleep(0.05)
end
