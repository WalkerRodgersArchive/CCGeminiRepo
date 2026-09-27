package.path = package.path .. ";/?.lua"
local Pine3D = require "Pine3D"
local util = require "util"
local start = os.epoch "utc"
local frame = Pine3D.newFrame()
frame:setBackgroundColor(colors.black)
frame:setFoV(60)
local obj = frame:newObject(util.loadCompressedModel("/models/Shuttle"), 0, 0, 0)
local obj2 = frame:newObject(util.loadCompressedModel("/models/ship"), 0, 3, 0)
local function moveShip(x, y, z, rotX, rotY, rotZ)
    obj2:setPos(x, y, z)
    obj2:setRot(rotX, rotY, -rotZ)
    --[[local camX, camY, camZ = -15 * math.cos(math.pi / 6), 15 * math.sin(math.pi / 6), 0
    camX, camY, camZ =
        1 * camX + 0 * camY + 0 * camZ,
        0 * camX + math.cos(rotX) * camY - math.sin(rotX) * camZ,
        0 * camX + math.sin(rotX) * camY + math.cos(rotX) * camZ
    camX, camY, camZ =
        math.cos(-rotY) * camX + 0 * camY - math.sin(-rotY) * camZ,
        0 * camX + 1 * camY + 0 * camZ,
        math.sin(-rotY) * camX + 0 * camY + math.cos(-rotY) * camZ
    camX, camY, camZ =
        math.cos(-rotZ) * camX - math.sin(-rotZ) * camY + 0 * camZ,
        math.sin(-rotZ) * camX + math.cos(-rotZ) * camY + 0 * camZ,
        0 * camX + 0 * camY + 1 * camZ
    frame:setCamera(camX + x, camY + y, camZ + z, math.deg(-rotX), math.deg(-rotY) - 30 * math.sin(rotX), math.deg(-rotZ) - 30 * math.cos(rotX))]]
    local camX, camY, camZ = -15, 0, 0
    camX, camY, camZ =
        math.cos(-rotY) * camX + 0 * camY - math.sin(-rotY) * camZ,
        0 * camX + 1 * camY + 0 * camZ,
        math.sin(-rotY) * camX + 0 * camY + math.cos(-rotY) * camZ
    camX, camY, camZ =
        math.cos(rotZ) * camX - math.sin(rotZ) * camY + 0 * camZ,
        math.sin(rotZ) * camX + math.cos(rotZ) * camY + 0 * camZ,
        0 * camX + 0 * camY + 1 * camZ
    camX, camY, camZ =
        1 * camX + 0 * camY + 0 * camZ,
        0 * camX + math.cos(-rotX) * camY - math.sin(-rotX) * camZ,
        0 * camX + math.sin(-rotX) * camY + math.cos(-rotX) * camZ
    local dX, dY, dZ = camX, camY, camZ
    frame:setCamera(camX + x, camY + y, camZ + z, 0, math.deg(math.atan2(dZ, dX)) + 180, math.deg(math.acos(dY / math.sqrt(dX^2 + dY^2 + dZ^2))) - 90)
    frame:drawObjects{obj, obj2}
    frame:drawBuffer()
end

for i = 0, 2 * math.pi, math.pi / 12 do
    moveShip(3, 6, 9, i, 0, 0)
    sleep(0.1)
end
for i = 0, 2 * math.pi, math.pi / 12 do
    moveShip(3, 6, 9, 0, i, 0)
    sleep(0.1)
end
for i = 0, 2 * math.pi, math.pi / 12 do
    moveShip(3, 6, 9, 0, 0, i)
    sleep(0.1)
end

local points = {
    vector.new(0, 3, 0),
    vector.new(10, 0, 0),
    vector.new(0, -5, 0),
    vector.new(-10, 0, 0),
    vector.new(0, 3, 0)
}

local bezierPoints = {
    vector.new(10, 3, 0),
    vector.new(10, -5, 0),
    vector.new(-10, -5, 0),
    vector.new(-10, 3, 0)
}

local lp = points[1] - vector.new(1, 0, 0)
for i = 1, #points - 1 do
    for t = 0, 0.999, 0.0625 do
        local p = points[i] * (1-t)^2 + bezierPoints[i] * (2 * (1 - t) * t) + points[i+1] * t^2
        local dir = p - lp
        moveShip(p.x, p.y, p.z, 0, math.atan2(dir.z, dir.x) + math.pi, math.acos(dir.y / math.sqrt(dir.x^2 + dir.y^2 + dir.z^2)))
        sleep(0.1)
        lp = p
    end
end
--read()
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)