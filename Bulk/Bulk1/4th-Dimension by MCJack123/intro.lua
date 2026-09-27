term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
local bc = term.nativePaletteColor(colors.black)
for i = 0, 4 do term.setPaletteColor(2^i, bc + (1 - (1 - i / 8)^2), bc + (1 - (1 - i / 8)^2), bc + (1 - (1 - i / 6)^2)) end

local box = require "pixelbox".new(term.current())
local bdf = require "bdf"
local util = require "util"
local file = assert(fs.open("ZenDots/ZenDots-Regular-24.bdf", "r"))
local font = bdf(file.readAll())
file.close()

local text, width = util.drawText("WELCOME TO THE", font, 1, 2)
local text2, width2 = util.drawText("4TH DIMENSION", font, 1, 2)
local offset = math.floor((width - width2) / 2)
for y = 1, #text do
    local l, s = {}, text2[y]
    for x = 1, width2 do l[x+offset] = s[x] end
    text[#text+1] = l
end

local textFrameA = util.mode7(text, width / 2, #text / 2, -(box.width - width) / 2, -(box.height - #text) / 2, box.width, box.height, 1, nil, util.scale(width / box.width * 1.40, width / box.width * 1.40, util.base()))
local textFrameB = util.mode7(text, width / 2, #text / 2, -(box.width - width) / 2, -(box.height - #text) / 2, box.width, box.height, 1, nil, util.scale(width / box.width * 1.35, width / box.width * 1.35, util.base()))
local textFrameC = util.mode7(text, width / 2, #text / 2, -(box.width - width) / 2, -(box.height - #text) / 2, box.width, box.height, 1, nil, util.scale(width / box.width * 1.30, width / box.width * 1.30, util.base()))
local textFrameD = util.mode7(text, width / 2, #text / 2, -(box.width - width) / 2, -(box.height - #text) / 2, box.width, box.height, 1, nil, util.scale(width / box.width * 1.25, width / box.width * 1.25, util.base()))
local defaultLine = {}
for i = 1, box.width do defaultLine[i] = 1 end
local overrideB, overrideC, overrideD = defaultLine, defaultLine, defaultLine

local z = 10
local frame = setmetatable({}, {__index = function(_, y)
    local lA, lB, lC, lD =
        textFrameA[y-math.floor(z/4+z/8)] or defaultLine,
        overrideB or textFrameB[y-math.floor(z/8)] or defaultLine,
        overrideC or textFrameC[y+math.floor(z/8)] or defaultLine,
        overrideD or textFrameD[y+math.floor(z/4+z/8)] or defaultLine
    return setmetatable({}, {__index = function(_, x) return lA[x] * lB[x] * lC[x] * lD[x] end})
end})
box.canvas = frame

box:render()
sleep(0.2)
overrideB = nil
box:render()
sleep(0.2)
overrideC = nil
box:render()
sleep(0.2)
overrideD = nil
box:render()
sleep(0.5)

for i = 1, 40 do
    z = i * (box.height / -160)
    box:render()
    sleep(0.05)
    if i > 30 then
        local r = (40 - i) / 10
        for j = 0, 4 do term.setPaletteColor(2^j, bc + (1 - (1 - j / 8)^2) * r, bc + (1 - (1 - j / 8)^2) * r, bc + (1 - (1 - j / 6)^2) * r) end
    end
end