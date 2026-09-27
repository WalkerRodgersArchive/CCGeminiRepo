local Pine3D = require "Pine3D"

local min, max, floor, sqrt = math.min, math.max, math.floor, math.sqrt
local lightningX, lightningZ = 12.383, -0.13473
local lightningXO, lightningZO = 12.383, -0.13473

local function multinum(n, ...) if n then return tonumber(n), multinum(...) end end

local frame = Pine3D.newFrame()
local scene = frame:newObject(Pine3D.loadModel("models/scene"), 0, 0, 0, 0, 0, 0)
local sceneNormals = {}
do
    local n = Pine3D.loadModel("models/scene.vn")
    for i, v in ipairs(n) do
        sceneNormals[i] = {
            v.x1, v.y1, v.z1,
            v.x2, v.y2, v.z2,
            v.x3, v.y3, v.z3
        }
    end
end
--for _, v in ipairs(scene[7]) do v[11] = 2^math.random(0, 15) end
local polyNum = 1
scene:setVertexShader(function(x, y, z, poly, n)
    if n == 1 then
        --poly.index = polyNum
        poly.normals = sceneNormals[polyNum]
        --poly.modelPoly = scene[7][polyNum]
        polyNum = polyNum + 1
    end
    -- if n == 3 then
    --     local a, b, c = poly[21], poly[22], vector.new(x, y, z)
    --     local norm = (b - a):cross(c - a):normalize()
    --     poly[11] = 2^(15-min(max(floor(norm:dot(-vector.new(x - lightningX, 0, z - lightningZ):normalize()) * 15), 0), 15))
    -- else poly[n+20] = vector.new(x, y, z) end
    return x, y, z
end)
local light = 0
local fragdata = {}
for y = 1, frame.height do
    local l = {}
    fragdata[y] = l
    for x = 1, frame.width do l[x] = {} end
end
scene:setFragmentShader(function (x, y, depth, poly, texcolor, interpVars, barycentric)
    local l = fragdata[y][x]
    l[1] = poly
    l[2] = barycentric
    return 1
end)
--local ptime
local function processPixels()
    --local start = os.epoch "utc"
    local canvas = frame.buffer.colorValues
    for y, line in ipairs(fragdata) do
        local cl = canvas[y]
        for x, v in ipairs(line) do
            local poly, barycentric = v[1], v[2]
            local vn = poly.normals
            --local poly = poly.modelPoly
            local den = barycentric.den
            local pxcx, pycy = x - barycentric.x3, y - barycentric.y3
            local ba = (barycentric.bycy * pxcx + barycentric.cxbx * pycy) / den
            local bb = (barycentric.cyay * pxcx + barycentric.axcx * pycy) / den
            local bc = 1 - ba - bb
            local vxx, vxy, vxz =
                ba * poly[1] + bb * poly[4] + bc * poly[7],
                ba * poly[2] + bb * poly[5] + bc * poly[8],
                ba * poly[3] + bb * poly[6] + bc * poly[9]
            local normx, normy, normz =
                ba * vn[1] + bb * vn[4] + bc * vn[7],
                ba * vn[2] + bb * vn[5] + bc * vn[8],
                ba * vn[3] + bb * vn[6] + bc * vn[9]
            local dirx, diry, dirz = vxx - lightningXO, vxy - 3, vxz - lightningZO
            local dirlen = -sqrt(dirx*dirx + diry*diry + dirz*dirz)
            dirx = dirx / dirlen
            diry = diry / dirlen
            dirz = dirz / dirlen
            local intensity = normx * dirx + normy * diry + normz * dirz
            cl[x] = 2^(15-min(max(floor(intensity * 10 + light), 0), 15))
        end
    end
    --ptime = os.epoch "utc" - start
end
--[=[
scene:setBakedFragmentShader [[
    local n = (0.5 / zInv)
    n = n - n % 1
    if n < 0 then n = 0 end
    if n > 15 then n = 15 end
    color = 2^(n)
]]
--]=]

local lightning = frame:newObject(Pine3D.loadModel("models/lightning"), 0, 0, 0, 0, 0, 0)
local yl = {}
for _, v in ipairs(lightning[7]) do
    v[11] = 1
    yl[v[2]] = true
    yl[v[5]] = true
    yl[v[8]] = true
end
local yl2 = {}
for k in pairs(yl) do yl2[#yl2+1] = k end
table.sort(yl2)
table.remove(yl2, 1)
yl2[#yl2] = nil
local lightningOffset = {}
local didFrag = false
lightning:setVertexShader(function (x, y, z, poly, vn)
    if not didFrag then processPixels() didFrag = true end
    local o = lightningOffset[y] or {0, 0}
    return x + o[1], y, z + o[2]
end)

local file = assert(fs.open("scene.anim", "r"))
file.readLine() -- header
local f = 1
parallel.waitForAny(function()
    local start = os.epoch "utc"
    for line in file.readLine do
        if f <= 10 then
            local wr = 1 - f / 10
            for i = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^(15-i), (i / 15)^2 * (1 - wr) + wr, (i / 15)^2 * (1 - wr) + wr, (i / 15) * (1 - wr) + wr) end
        end
        if os.epoch "utc" - start <= (f) * 50 then
            local x, y, z, rx, ry, rz, fov = multinum(line:match(("([^,]+),"):rep(6) .. "([^,]+)"))
            frame:setCamera(x, y, z, -math.deg(rx), -math.deg(ry), math.deg(rz))
            frame:setFoV(fov)
            polyNum = 1
            didFrag = false
            for _, v in ipairs(yl2) do lightningOffset[v] = {(math.random() - 0.5), (math.random() - 0.5)} end
            lightningXO, lightningZO = lightningX + lightningOffset[yl2[2]][1], lightningZ + lightningOffset[yl2[2]][2]
            frame:drawObjects{scene, lightning}
            frame:drawBuffer()
            --term.setCursorPos(1, 1) print(ptime)
            sleep(0.05)
        end
        f = f + 1
        light = light * 0.65
    end
end, function()
    while true do
        os.pullEvent("pulse")
        light = 4
    end
end, function()
    os.pullEvent("trigger")
    for f = 9, 0, -0.5 do
        local wr = 1 - f / 10
        for i = 0, 15 do frame.buffer.blitWin.setPaletteColor(2^(15-i), (i / 15)^2 * (1 - wr) + wr, (i / 15)^2 * (1 - wr) + wr, (i / 15) * (1 - wr) + wr) end
        sleep(0.05)
    end
    while true do os.pullEvent() end
end)
file.close()
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)