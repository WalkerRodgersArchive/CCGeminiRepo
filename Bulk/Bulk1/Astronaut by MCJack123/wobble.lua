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

local floor, min = math.floor, math.min

local function texplane(texture, res, w, h, scale)
    res = res or 32
    w, h = w or #texture[1], h or #texture
    scale = scale or 1
    ---@type Model
    local model = {}
    local resinv = 1 / res
    for y = 0, 0.9999999, resinv do
        for x = 0, 0.9999999, resinv do
            local u1, v1, u2, v2 = floor(x * w + 1), floor(y * h + 1), floor((x + resinv) * w), floor((y + resinv) * h)
            model[#model+1] = newPoly(
                (0.5 - y) * scale, 0, (x - 0.5) * scale,
                (0.5 - y - resinv) * scale, 0, (x - 0.5) * scale,
                (0.5 - y - resinv) * scale, 0, (x + resinv - 0.5) * scale,
                {u1, v1, u1, v2, u2, v2, texture}
            )
            model[#model+1] = newPoly(
                (0.5 - y) * scale, 0, (x + resinv - 0.5) * scale,
                (0.5 - y) * scale, 0, (x - 0.5) * scale,
                (0.5 - y - resinv) * scale, 0, (x + resinv - 0.5) * scale,
                {u2, v1, u1, v1, u2, v2, texture}
            )
        end
    end

    for name, func in pairs(Pine3D.transforms) do
		model[name] = func
	end

	return model
end

local file = fs.open("/saul.gif", "rb")
local gif, pal, gifw, gifh = util.loadgif(file)
file.close()
local bgimg = {}
for i = 0, 11 do term.setPaletteColor(2^i, table.unpack(pal[i])) end

file = fs.open("/sued.xpm", "r")
local img, imgw, imgh = util.loadxpm(file, 12)
file.close()

local frame = Pine3D.newFrame()
frame:setCamera(-1.41 * math.cos(math.rad(30)), 2, -1.41 * math.sin(math.rad(30)), 0, 0, -60)
frame:setFoV(90)
frame:setBackgroundColor(colors.black)
local obj = frame:newObject(texplane(img, 32, imgw, imgh, 1.5), 0, 0, 0, 0, 0, 0)
local bg = frame:newObject(Pine3D.models:plane({texture = bgimg, texwidth = gifw, texheight = gifh, size = 4, sizew = 7}):rotate(0, 0, math.rad(-30)))
local i = 0
obj:setVertexShader(function(x, y, z) return x, y + math.sin(2 * math.pi * (z * 40 + i) / 20) / 20, z end)
while i < 200 do
    local rstart = os.epoch "utc"
    setmetatable(bgimg, {__index = gif[math.floor(i) % #gif + 1], __len = function() return imgh end})
    if img.palette then for j = 0, 11 do frame.buffer.blitWin.setPaletteColor(2^j, table.unpack(img.palette[j])) end end
    bg:setPos(2 * math.cos(math.rad(i * 4)), -4, 2 * math.sin(math.rad(i * 4)))
    bg:setRot(0, math.rad(-i * 4), 0)
    frame:setCamera(-1.41 * math.cos(math.rad(i * 4)), 2, -1.41 * math.sin(math.rad(i * 4)), 0, i * 4, -60)
    frame:drawObjects({obj, bg})
    frame:drawBuffer()
    sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
    i = i + (os.epoch "utc" - rstart) / 50
end
term.setCursorPos(1, 1)
