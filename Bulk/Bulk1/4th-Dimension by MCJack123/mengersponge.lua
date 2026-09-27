local Pine3D = require "Pine3D"

local floor, abs = math.floor, math.abs

local function flip(t)
    if t.x1 > t.x2 then t.x1, t.x2 = t.x2, t.x1 end
    if t.y1 > t.y2 then t.y1, t.y2 = t.y2, t.y1 end
    if t.z1 > t.z2 then t.z1, t.z2 = t.z2, t.z1 end
    return t
end

local function flipTriangleToNormal(triangle, targetNormal)
    local e1x = triangle.x2 - triangle.x1
    local e1y = triangle.y2 - triangle.y1
    local e1z = triangle.z2 - triangle.z1
    local e2x = triangle.x3 - triangle.x1
    local e2y = triangle.y3 - triangle.y1
    local e2z = triangle.z3 - triangle.z1

    local nx = e1y * e2z - e1z * e2y
    local ny = e1z * e2x - e1x * e2z
    local nz = e1x * e2y - e1y * e2x

    if nx * targetNormal.x + ny * targetNormal.y + nz * targetNormal.z < 0 then
        triangle.x2, triangle.x3 = triangle.x3, triangle.x2
        triangle.y2, triangle.y3 = triangle.y3, triangle.y2
        triangle.z2, triangle.z3 = triangle.z3, triangle.z2
    end

    return triangle
end

local norms = {{x = 1, y = 0, z = 0}, {x = -1, y = 0, z = 0}, {x = 0, y = 1, z = 0}, {x = 0, y = -1, z = 0}, {x = 0, y = 0, z = 1}, {x = 0, y = 0, z = -1}}
local normconv = {
    {5, 5, 3},
    {3, 1, 1},
}

local function sponge(depth)
    local squares = {
        {x1 = 0, y1 = 0, z1 = 0, x2 = 1, y2 = 1, z2 = 0, n = 6},
        {x1 = 0, y1 = 0, z1 = 0, x2 = 1, y2 = 0, z2 = 1, n = 4},
        {x1 = 0, y1 = 0, z1 = 0, x2 = 0, y2 = 1, z2 = 1, n = 2},
        {x1 = 0, y1 = 0, z1 = 1, x2 = 1, y2 = 1, z2 = 1, n = 5},
        {x1 = 0, y1 = 1, z1 = 0, x2 = 1, y2 = 1, z2 = 1, n = 3},
        {x1 = 1, y1 = 0, z1 = 0, x2 = 1, y2 = 1, z2 = 1, n = 1},
    }
    for j = 1, depth do
        local newsquares = {}
        for i, v in ipairs(squares) do
            assert(v.x1 <= v.x2 and v.y1 <= v.y2 and v.z1 <= v.z2, textutils.serialize(v))
            if true then
                local rx, ry, rz = (v.x2 - v.x1) / 3, (v.y2 - v.y1) / 3, (v.z2 - v.z1) / 3
                -- a = "right", b = "down", c = "in"
                local ax, ay, az, bx, by, bz, cx, cy, cz = 0, 0, 0, 0, 0, 0, 0, 0, 0
                if abs(v.x1 - v.x2) < 0.00001 then ay = (v.y2 - v.y1) / 3 bz = (v.z2 - v.z1) / 3 cx = v.n % 2 == 1 and -ay or ay
                elseif abs(v.y1 - v.y2) < 0.00001 then ax = (v.x2 - v.x1) / 3 bz = (v.z2 - v.z1) / 3 cy = v.n % 2 == 1 and -ax or ax
                else ax = (v.x2 - v.x1) / 3 by = (v.y2 - v.y1) / 3 cz = v.n % 2 == 1 and -ax or ax end
                -- front faces
                newsquares[#newsquares+1] = flip{x1 = v.x1,                   y1 = v.y1,                   z1 = v.z1,                   x2 = v.x1 +                   rx, y2 = v.y1 +                   ry, z2 = v.z1 +                   rz, n = v.n, h = v.h}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +     ax,          y1 = v.y1 +     ay,          z1 = v.z1 +     az,          x2 = v.x1 +     ax +          rx, y2 = v.y1 +     ay +          ry, z2 = v.z1 +     az +          rz, n = v.n, h = v.h}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax,          y1 = v.y1 + 2 * ay,          z1 = v.z1 + 2 * az,          x2 = v.x1 + 2 * ax +          rx, y2 = v.y1 + 2 * ay +          ry, z2 = v.z1 + 2 * az +          rz, n = v.n, h = v.h}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +              bx, y1 = v.y1 +              by, z1 = v.z1 +              bz, x2 = v.x1 +              bx + rx, y2 = v.y1 +              by + ry, z2 = v.z1 +              bz + rz, n = v.n, h = v.h}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax +     bx, y1 = v.y1 + 2 * ay +     by, z1 = v.z1 + 2 * az +     bz, x2 = v.x1 + 2 * ax +     bx + rx, y2 = v.y1 + 2 * ay +     by + ry, z2 = v.z1 + 2 * az +     bz + rz, n = v.n, h = v.h}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +          2 * bx, y1 = v.y1 +          2 * by, z1 = v.z1 +          2 * bz, x2 = v.x1 +          2 * bx + rx, y2 = v.y1 +          2 * by + ry, z2 = v.z1 +          2 * bz + rz, n = v.n, h = v.h}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +     ax + 2 * bx, y1 = v.y1 +     ay + 2 * by, z1 = v.z1 +     az + 2 * bz, x2 = v.x1 +     ax + 2 * bx + rx, y2 = v.y1 +     ay + 2 * by + ry, z2 = v.z1 +     az + 2 * bz + rz, n = v.n, h = v.h}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax + 2 * bx, y1 = v.y1 + 2 * ay + 2 * by, z1 = v.z1 + 2 * az + 2 * bz, x2 = v.x1 + 2 * ax + 2 * bx + rx, y2 = v.y1 + 2 * ay + 2 * by + ry, z2 = v.z1 + 2 * az + 2 * bz + rz, n = v.n, h = v.h}
                -- inner faces
                newsquares[#newsquares+1] = flip{x1 = v.x1 +     ax +     bx, y1 = v.y1 +     ay +     by, z1 = v.z1 +     az +     bz, x2 = v.x1 + 2 * ax +     bx + cx, y2 = v.y1 + 2 * ay +     by + cy, z2 = v.z1 + 2 * az +     bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1]}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +     ax +     bx, y1 = v.y1 +     ay +     by, z1 = v.z1 +     az +     bz, x2 = v.x1 +     ax + 2 * bx + cx, y2 = v.y1 +     ay + 2 * by + cy, z2 = v.z1 +     az + 2 * bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1]}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +     ax + 2 * bx, y1 = v.y1 +     ay + 2 * by, z1 = v.z1 +     az + 2 * bz, x2 = v.x1 + 2 * ax + 2 * bx + cx, y2 = v.y1 + 2 * ay + 2 * by + cy, z2 = v.z1 + 2 * az + 2 * bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1] + 1}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax +     bx, y1 = v.y1 + 2 * ay +     by, z1 = v.z1 + 2 * az +     bz, x2 = v.x1 + 2 * ax + 2 * bx + cx, y2 = v.y1 + 2 * ay + 2 * by + cy, z2 = v.z1 + 2 * az + 2 * bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1] + 1}
                -- between faces (hidden)
                newsquares[#newsquares+1] = flip{x1 = v.x1 +              bx, y1 = v.y1 +              by, z1 = v.z1 +              bz, x2 = v.x1 +     ax +     bx + cx, y2 = v.y1 +     ay +     by + cy, z2 = v.z1 +     az +     bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1] + 0, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +              bx, y1 = v.y1 +              by, z1 = v.z1 +              bz, x2 = v.x1 +     ax +     bx + cx, y2 = v.y1 +     ay +     by + cy, z2 = v.z1 +     az +     bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1] + 1, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax +     bx, y1 = v.y1 + 2 * ay +     by, z1 = v.z1 + 2 * az +     bz, x2 = v.x1 + 3 * ax +     bx + cx, y2 = v.y1 + 3 * ay +     by + cy, z2 = v.z1 + 3 * az +     bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1] + 0, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax +     bx, y1 = v.y1 + 2 * ay +     by, z1 = v.z1 + 2 * az +     bz, x2 = v.x1 + 3 * ax +     bx + cx, y2 = v.y1 + 3 * ay +     by + cy, z2 = v.z1 + 3 * az +     bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1] + 1, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +     ax,          y1 = v.y1 +     ay,          z1 = v.z1 +     az,          x2 = v.x1 +     ax +     bx + cx, y2 = v.y1 +     ay +     by + cy, z2 = v.z1 +     az +     bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1] + 0, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +     ax,          y1 = v.y1 +     ay,          z1 = v.z1 +     az,          x2 = v.x1 +     ax +     bx + cx, y2 = v.y1 +     ay +     by + cy, z2 = v.z1 +     az +     bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1] + 1, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +     ax + 2 * bx, y1 = v.y1 +     ay + 2 * by, z1 = v.z1 +     az + 2 * bz, x2 = v.x1 +     ax + 3 * bx + cx, y2 = v.y1 +     ay + 3 * by + cy, z2 = v.z1 +     az + 3 * bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1] + 0, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +     ax + 2 * bx, y1 = v.y1 +     ay + 2 * by, z1 = v.z1 +     az + 2 * bz, x2 = v.x1 +     ax + 3 * bx + cx, y2 = v.y1 +     ay + 3 * by + cy, z2 = v.z1 +     az + 3 * bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1] + 1, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +          2 * bx, y1 = v.y1 +          2 * by, z1 = v.z1 +          2 * bz, x2 = v.x1 +     ax + 2 * bx + cx, y2 = v.y1 +     ay + 2 * by + cy, z2 = v.z1 +     az + 2 * bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1] + 0, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 +          2 * bx, y1 = v.y1 +          2 * by, z1 = v.z1 +          2 * bz, x2 = v.x1 +     ax + 2 * bx + cx, y2 = v.y1 +     ay + 2 * by + cy, z2 = v.z1 +     az + 2 * bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1] + 1, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax + 2 * bx, y1 = v.y1 + 2 * ay + 2 * by, z1 = v.z1 + 2 * az + 2 * bz, x2 = v.x1 + 3 * ax + 2 * bx + cx, y2 = v.y1 + 3 * ay + 2 * by + cy, z2 = v.z1 + 3 * az + 2 * bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1] + 0, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax + 2 * bx, y1 = v.y1 + 2 * ay + 2 * by, z1 = v.z1 + 2 * az + 2 * bz, x2 = v.x1 + 3 * ax + 2 * bx + cx, y2 = v.y1 + 3 * ay + 2 * by + cy, z2 = v.z1 + 3 * az + 2 * bz + cz, n = normconv[1][floor((v.n - 1) / 2) + 1] + 1, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax,          y1 = v.y1 + 2 * ay,          z1 = v.z1 + 2 * az,          x2 = v.x1 + 2 * ax +     bx + cx, y2 = v.y1 + 2 * ay +     by + cy, z2 = v.z1 + 2 * az +     bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1] + 0, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax,          y1 = v.y1 + 2 * ay,          z1 = v.z1 + 2 * az,          x2 = v.x1 + 2 * ax +     bx + cx, y2 = v.y1 + 2 * ay +     by + cy, z2 = v.z1 + 2 * az +     bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1] + 1, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax + 2 * bx, y1 = v.y1 + 2 * ay + 2 * by, z1 = v.z1 + 2 * az + 2 * bz, x2 = v.x1 + 2 * ax + 3 * bx + cx, y2 = v.y1 + 2 * ay + 3 * by + cy, z2 = v.z1 + 2 * az + 3 * bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1] + 0, h = true}
                newsquares[#newsquares+1] = flip{x1 = v.x1 + 2 * ax + 2 * bx, y1 = v.y1 + 2 * ay + 2 * by, z1 = v.z1 + 2 * az + 2 * bz, x2 = v.x1 + 2 * ax + 3 * bx + cx, y2 = v.y1 + 2 * ay + 3 * by + cy, z2 = v.z1 + 2 * az + 3 * bz + cz, n = normconv[2][floor((v.n - 1) / 2) + 1] + 1, h = true}
            end
        end
        squares = newsquares
    end
    local model = {}
    for i, v in ipairs(squares) do
        if not v.h then
            local ax, ay, az, bx, by, bz, norm, c = v.x1, v.y1, v.z1, v.x1, v.y1, v.z1, norms[v.n]
            if abs(v.x1 - v.x2) < 0.00001 then az = v.z2 by = v.y2 c = colors.white
            elseif abs(v.y1 - v.y2) < 0.00001 then az = v.z2 bx = v.x2 c = colors.lightGray
            else ax = v.x2 by = v.y2 c = colors.gray end
            model[#model+1] = flipTriangleToNormal({x1 = v.x1, y1 = v.y1, z1 = v.z1, x2 = ax, y2 = ay, z2 = az, x3 = bx, y3 = by, z3 = bz, c = c}, norm)
            model[#model+1] = flipTriangleToNormal({x1 = v.x2, y1 = v.y2, z1 = v.z2, x2 = bx, y2 = by, z2 = bz, x3 = ax, y3 = ay, z3 = az, c = c}, norm)
        end
    end
    for name, func in pairs(Pine3D.transforms) do
		model[name] = func
	end
	return model
end

local frame = Pine3D.newFrame()
frame:setCamera(-1.25, 1.25, 0, 0, 0, -45)
local obj = frame:newObject(sponge(2):center(), 0, 0, 0, 0, 0, 0)
local p = 0
obj:setVertexShader(function(x, y, z)
    local m = 1 + p
    return x * m, y * m, z * m
end)
parallel.waitForAny(function()
    for i = 0, 10 do
		local ar = i / 10
		local br = 1 - i / 10
		for j = 0, 15 do
			local r, g, b = term.nativePaletteColor(2^j)
			frame.buffer.blitWin.setPaletteColor(2^j, r * ar + br, g * ar + br, b * ar + br)
		end
		sleep(0.05)
	end
    os.pullEvent("trigger")
    local bc = term.nativePaletteColor(colors.black)
	for i = 1, 20 do
		local ar = (1 - i / 20) * (1 - bc)
		for j = 0, 15 do
			local r, g, b = term.nativePaletteColor(2^j)
			frame.buffer.blitWin.setPaletteColor(2^j, r * ar + bc, g * ar + bc, b * ar + bc)
		end
		sleep(0.05)
	end
end, function()
    local t = 0
    while true do
        local start = os.epoch "utc"
        obj:setRot(0, t / 5 * math.pi * 2, (t + 0.1214221) / 8 * math.pi * 2)
        frame:drawObjects{obj}
        frame:drawBuffer()
        sleep(0.05)
        local dt = (start - os.epoch "utc") / 1000
        t = t + dt
        p = p * 0.5
    end
end, function()
    while true do
		os.pullEvent("pulse")
		if p < 0.125 then p = 0.25 end
	end
end)
term.setBackgroundColor(colors.black)
term.clear()

--[=[
local function rendering()
	local frames = 0
	local lastFPSTime = 0
	while true do
		frame:drawObjects{obj}
		frame:drawBuffer()

		--[[frames = frames + 1
		if os.clock() > lastFPSTime + 1 then
			lastFPSTime = os.clock()
			term.setBackgroundColor(colors.black)
			term.setCursorPos(1, 1)
			term.clearLine()
			term.setCursorPos(1, 1)
			term.setTextColor(colors.white)
			term.write("Average FPS: " .. frames)
			frames = 0
		end]]--

		os.queueEvent("FakeEvent")
		os.pullEvent("FakeEvent")
	end
end

local speed = 3
local turnSpeed = 90

local camera = {
	x = 0,
	y = 0,
	z = 0,
	rotX = 0,
	rotY = 0,
	rotZ = 0,
}

local keysDown = {}
local function keyInput()
	while true do
		local event, key = os.pullEventRaw()

		if event == "key" then
			keysDown[key] = true
		elseif event == "key_up" then
			keysDown[key] = nil
		end
	end
end

local function handleCameraMovement(dt)
	local dx, dy, dz = 0, 0, 0 -- will represent the movement per second

	-- handle arrow keys for camera rotation
	if keysDown[keys.left] then
		camera.rotY = (camera.rotY - turnSpeed * dt) % 360
	end
	if keysDown[keys.right] then
		camera.rotY = (camera.rotY + turnSpeed * dt) % 360
	end
	if keysDown[keys.down] then
		camera.rotZ = math.max(-80, camera.rotZ - turnSpeed * dt)
	end
	if keysDown[keys.up] then
		camera.rotZ = math.min(80, camera.rotZ + turnSpeed * dt)
	end

	-- handle wasd keys for camera movement
	if keysDown[keys.w] then
		dx = speed * math.cos(math.rad(camera.rotY)) + dx
		dz = speed * math.sin(math.rad(camera.rotY)) + dz
	end
	if keysDown[keys.s] then
		dx = -speed * math.cos(math.rad(camera.rotY)) + dx
		dz = -speed * math.sin(math.rad(camera.rotY)) + dz
	end
	if keysDown[keys.a] then
		dx = speed * math.cos(math.rad(camera.rotY - 90)) + dx
		dz = speed * math.sin(math.rad(camera.rotY - 90)) + dz
	end
	if keysDown[keys.d] then
		dx = speed * math.cos(math.rad(camera.rotY + 90)) + dx
		dz = speed * math.sin(math.rad(camera.rotY + 90)) + dz
	end

	-- space and left shift key for moving the camera up and down
	if keysDown[keys.space] then
		dy = speed + dy
	end
	if keysDown[keys.leftShift] then
		dy = -speed + dy
	end

	-- update the camera position by adding the offset
	camera.x = camera.x + dx * dt
	camera.y = camera.y + dy * dt
	camera.z = camera.z + dz * dt

	frame:setCamera(camera)
end

local function gameLoop()
	local lastTime = os.clock()

	while true do
		-- compute the time passed since last step
		local currentTime = os.clock()
		local dt = currentTime - lastTime
		lastTime = currentTime

		-- run all functions that need to be run
		handleCameraMovement(dt)

		-- use a fake event to yield the coroutine
		os.queueEvent("gameLoop")
		os.pullEventRaw("gameLoop")
	end
end

parallel.waitForAll(keyInput, gameLoop, rendering)
]=]
