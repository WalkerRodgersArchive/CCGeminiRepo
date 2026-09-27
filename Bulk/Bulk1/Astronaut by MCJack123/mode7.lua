local pixelbox = require "pixelbox"
local util = require "util"
local fps = jit and config and config.get("clockSpeed") or 20

local pi, pi2 = math.pi, math.pi * 2
local floor, sin, cos = math.floor, math.sin, math.cos

local sel = tonumber(...) or 1
local file = fs.open(sel == 8 and "worksonmymachine.xpm" or "cct-64.xpm", "r")
local img, imgw, imgh = util.loadxpm(file)
file.close()

util.tile(img, imgw, imgh)
local px = pixelbox.new(term.current())
local w, h = px.width, px.height

local sx = 0
local i = 1
while i <= 4001 do
    local rstart = os.epoch "utc"
    local th = 2 * math.pi * i / 200
    --px.canvas = mode7(img, w / 2, h / 2, i, i, w, h, nil, cos(th) * 2, sin(th), -sin(th), cos(th) * 2)
    if sel == 1 then px.canvas = util.mode7(img, w / 2 + i, h / 2 + i, i, i, w, h, colors.black, nil, util.rotate(th, util.scale(sin(th * 1.5) + 2, sin(th * 1.5) + 2, util.base())))
    elseif sel == 2 then px.canvas = util.mode7(img, w / 2 + sx, h / 2 + i, sx, i, w, h, colors.black, nil, util.shear((sin(th * 1.5) + 0) * 1.5, 0, util.base()))
    elseif sel == 3 then px.canvas = util.mode7(img, w / 2 + i, h + i, i, i, w, h, colors.black, function(y, dx, dy, a, b, c, d) if y < h / 4 then return dx, dy, 1, 0, 0, 0, 0 end local l = h * 2 / y return dx, dy, 1, a * l, b * l, c * l, d * l end, util.rotate(th, util.scale((sin(th * 1.5) + 2) / 5, (sin(th * 1.5) + 2) / 5, util.base())))
    elseif sel == 4 then px.canvas = util.mode7(img, w / 2, h / 2 + i, 0, i, w, h, colors.black, function(y, dx, dy, a, b, c, d) return dx + sin(6 * pi * y / h) * 20, dy, 1, a, b, c, d end, util.base())
    elseif sel == 5 then px.canvas = util.mode7(img, w / 2, h - (sin(th) + 1) * h / 2, 0, -(sin(th) + 1) * h / 2, w, h, colors.black, function(y, dx, dy, a, b, c, d) if math.abs(y - (sin(th) + 1) * h / 3 - h / 6) >= h / 6 then return dx, dy, 1, 0, 0, 0, 0 end return dx, dy, 1, util.scale(1 - cos((y - (sin(th) + 1) * h / 3 - h / 6) * pi / (h / 3)) / 10, 1, a, b, c, d) end, util.base())
    elseif sel == 6 then
        px.canvas = util.mode7(img, w / 2, h + sx, 0, sx, w, h, colors.black, function(y, dx, dy, a, b, c, d) if math.abs(y - (sin(th) + 1) * h / 3 - h / 6) >= h / 6 then return dx, dy, 0, 0, 0, 0 end return dx, dy, 1, util.scale(1 - cos((y - (sin(th) + 1) * h / 3 - h / 6) * pi / (h / 3)) / 10, 1, a, b, c, d) end, util.base())
        sx = sx - cos(th) * pi2
    elseif sel == 7 then
        px.canvas = util.mode7(img, w / 2, h + sx, 0, sx, w, h, colors.blue, function(y, dx, dy, a, b, c, d) if math.abs(y - (sin(th) + 1) * h / 3 - h / 6) >= h / 6 then return dx, dy, 0, 0, 0, 0 end return dx, dy, 1, util.scale(1 - cos((y - (sin(th) + 1) * h / 3 - h / 6) * pi / (h / 3)) / 10, 1, a, b, c, d) end, util.base())
        if cos(th) > 0 then sx = sx + 1 - cos(th) else sx = sx - cos(th) * h / 36 + 1 end
    elseif sel == 8 then
        px.canvas = util.mode7(img, w / 2 + sin(th / 2.5) * w, h + sx, sin(th / 2.5) * w, sx, w, h, 1, function(y, dx, dy, a, b, c, d)
            if math.abs(y - (sin(th) + 1) * h / 3 - h / 6) < h / 6 then return dx, dy, 1, util.scale(1 - cos((y - (sin(th) + 1) * h / 3 - h / 6) * pi / (h / 3)) / 10, 1, a, b, c, d)
            elseif y >= h / 3 then local l = h * 2 / y return dx, dy, 2^floor((1 - math.min(math.max((y - (h / 3)) / (h / 3), 0), 1)) * 15), a * l, b * l, c * l, d * l
            else return dx, dy, 1, 0, 0, 0, 0 end
        end, util.base())
        if cos(th) > 0 then sx = sx + 1 - cos(th) else sx = sx - cos(th) * h / 36 + 1 end
    end
    px:render()
    sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
    i = i + (os.epoch "utc" - rstart) / 10
end
