local pixelbox = require "pixelbox"
local readBDFFont = require "bdf"
local util = require "util"
local fps = jit and config and config.get("clockSpeed") or 20

local pi, pi2 = math.pi, math.pi * 2
local floor, sin, cos = math.floor, math.sin, math.cos

local syntaxmap = {
    ["and"] = "\x12and\x10",
    ["break"] = "\x12break\x10",
    ["do"] = "\x12do\x10",
    ["else"] = "\x12else\x10",
    ["elseif"] = "\x12elseif\x10",
    ["end"] = "\x12end\x10",
    ["false"] = "\x1bfalse\x10",
    ["for"] = "\x12for\x10",
    ["function"] = "\x12function\x10",
    ["goto"] = "\x12goto\x10",
    ["if"] = "\x12if\x10",
    ["in"] = "\x12in\x10",
    ["local"] = "\x1blocal\x10",
    ["nil"] = "\x1bnil\x10",
    ["not"] = "\x12not\x10",
    ["or"] = "\x12or\x10",
    ["repeat"] = "\x12repeat\x10",
    ["return"] = "\x12return\x10",
    ["then"] = "\x12then\x10",
    ["true"] = "\x1btrue\x10",
    ["until"] = "\x12until\x10",
    ["while"] = "\x12while\x10",
}

local file = assert(fs.open(..., "r"))
local font = readBDFFont(file.readAll())
file.close()
file = assert(fs.open(select(2, ...), "r"))
local img = util.drawText(file.read(4096):gsub("%f[a-z][a-z]+%f[^a-z]", syntaxmap):gsub("%-%-[^\n]+", "\x1d%0\x10"):gsub("['\"][^'\"]*['\"]", "\x1e%0\x10"):gsub("%-?%d+%.?%d*", "\x13%0\x10"):gsub("([a-zA-Z_][a-zA-Z0-9_]*)%(", "\x14%1\x10("), font, 4)
file.close()
util.tile(img, #img[1], #img)

local px = pixelbox.new(term.current())
local w, h = px.width, px.height

local sx = 0
for i = 1, 4001, 100 / fps do
    local rstart = os.epoch "utc"
    local th = 2 * math.pi * i / 200
    --px.canvas = util.mode7(img, w / 2 + i, h / 2 + i, i, i, w, h, colors.black, nil, util.scale(2, 2, util.base()))
    -- [[
    px.canvas = util.mode7(img, w * 1.5 + sin(th / 2.5) * w, h + sx, w + sin(th / 2.5) * w, sx, w, h, 32768, function(y, dx, dy, a, b, c, d)
        if math.abs(y - (sin(th) + 1) * h / 3 - h / 6) < h / 6 then return dx, dy, 1, util.scale(1 - cos((y - (sin(th) + 1) * h / 3 - h / 6) * pi / (h / 3)) / 10, 1, a, b, c, d)
        elseif y >= h / 3 then local l = h * 2 / y return dx, dy, 1, a * l, b * l, c * l, d * l
        else return dx, dy, 1, 0, 0, 0, 0 end
    end, util.base())
    if cos(th) > 0 then sx = sx + 1 - cos(th) else sx = sx - cos(th) * h / 36 + 1 end
    --]]
    px:render()
    sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
end
