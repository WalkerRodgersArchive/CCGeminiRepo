
-- Made by Xella#8655

local Pine3D = require("Pine3D")
local noise = require("noise")
local sin, cos, pi, floor = math.sin, math.cos, math.pi, math.floor

local genOptions = {
	seed = 100,
	chunkRows = 2,
	chunkColumns = 2,
	maxHeight = 32,
	relativeSnowHeight = 0.70,
	relativeWaterHeight = 0.4,
	noiseSize = 32,
	terrainSmoothness = 3,
}

local speed = 6
local turnSpeed = 180
local i = 0
local p = 0

local camera = {
	x = 0,
	y = 0,
	z = 0,
	rotX = 0,
	rotY = 0,
	rotZ = 0,
}

local ThreeDFrame = Pine3D.newFrame()
ThreeDFrame:setBackgroundColor(colors.black)
local highRes = true
--ThreeDFrame:setWireFrame(true)
--ThreeDFrame:highResMode(highRes)

local function generateCubemap(objects, target)
	-- generate cubemap
	local camera = ThreeDFrame.camera
	ThreeDFrame:setCamera(target[1], target[2], target[3], 0, 0, 0)
	ThreeDFrame:setFoV(90)
	local ow, oh = ThreeDFrame.buffer.width, ThreeDFrame.buffer.height
	ThreeDFrame.buffer.width, ThreeDFrame.buffer.height = 200, 200
	ThreeDFrame.buffer:clear()
	ThreeDFrame:drawObjects(objects)
	local front = {}
	for y, row in ipairs(ThreeDFrame.buffer.colorValues) do
		local r = {}
		front[y] = r
		for x, c in ipairs(row) do r[x] = c end
	end
	--ThreeDFrame:drawBuffer() sleep(5)

	ThreeDFrame:setCamera(nil, nil, nil, 0, 90, 0)
	ThreeDFrame.buffer:fastClear()
	ThreeDFrame:drawObjects(objects)
	local right = {}
	for y, row in ipairs(ThreeDFrame.buffer.colorValues) do
		local r = {}
		right[y] = r
		for x, c in ipairs(row) do r[x] = c end
	end
	--ThreeDFrame:drawBuffer() sleep(5)

	ThreeDFrame:setCamera(nil, nil, nil, 0, 180, 0)
	ThreeDFrame.buffer:fastClear()
	ThreeDFrame:drawObjects(objects)
	local back = {}
	for y, row in ipairs(ThreeDFrame.buffer.colorValues) do
		local r = {}
		back[y] = r
		for x, c in ipairs(row) do r[x] = c end
	end
	--ThreeDFrame:drawBuffer() sleep(5)

	ThreeDFrame:setCamera(nil, nil, nil, 0, 270, 0)
	ThreeDFrame.buffer:fastClear()
	ThreeDFrame:drawObjects(objects)
	local left = {}
	for y, row in ipairs(ThreeDFrame.buffer.colorValues) do
		local r = {}
		left[y] = r
		for x, c in ipairs(row) do r[x] = c end
	end
	--ThreeDFrame:drawBuffer() sleep(5)

	ThreeDFrame:setCamera(nil, nil, nil, 0, 0, 90)
	ThreeDFrame.buffer:fastClear()
	ThreeDFrame:drawObjects(objects)
	local top = {}
	for y, row in ipairs(ThreeDFrame.buffer.colorValues) do
		local r = {}
		top[y] = r
		for x, c in ipairs(row) do r[x] = c end
	end
	--ThreeDFrame:drawBuffer() sleep(5)

	ThreeDFrame:setCamera(nil, nil, nil, 0, 0, -90)
	ThreeDFrame.buffer:fastClear()
	ThreeDFrame:drawObjects(objects)
	local bottom = {}
	for y, row in ipairs(ThreeDFrame.buffer.colorValues) do
		local r = {}
		bottom[y] = r
		for x, c in ipairs(row) do r[x] = c end
	end
	--ThreeDFrame:drawBuffer() sleep(5)

	ThreeDFrame.buffer.width, ThreeDFrame.buffer.height = ow, oh
	ThreeDFrame.buffer:clear()
	ThreeDFrame.camera = camera
	target.cubemap = {top = top, bottom = bottom, left = left, right = right, front = front, back = back}
end

---@param ThreeDFrame ThreeDFrame
local function generateWorld(ThreeDFrame, genOptions)
	local seed = genOptions.seed
	local rows = genOptions.chunkRows
	local columns = genOptions.chunkColumns
	local maxHeight = genOptions.maxHeight
	local relativeSnowHeight = genOptions.relativeSnowHeight
	local relativeWaterHeight = genOptions.relativeWaterHeight
	local noiseSize = genOptions.noiseSize
	local terrainSmoothness = genOptions.terrainSmoothness

	local polyCount = 0
	local objects = {}

	local colors = colors
	local sqrt = math.sqrt
	local max = math.max

	math.randomseed(seed)
	for chunkX = 0, columns - 1 do
		for chunkZ = 0, rows - 1 do
			local mapNoise1 = noise.createNoise(noiseSize, chunkX, chunkZ, seed, terrainSmoothness)
			local mapNoise2 = noise.createNoise(noiseSize, chunkX + 1, chunkZ, seed, terrainSmoothness)
			local mapNoise3 = noise.createNoise(noiseSize, chunkX, chunkZ + 1, seed, terrainSmoothness)
			local mapNoise4 = noise.createNoise(noiseSize, chunkX + 1, chunkZ + 1, seed, terrainSmoothness)

			local mapA = {}
			local mapB = {}
			for a = 1, noiseSize do
				for b = 1, noiseSize do
					local height1 = mapNoise1[a][b]*maxHeight - 0.5*maxHeight
					local height2 = 0
					if (a < noiseSize) then
						height2 = mapNoise1[a+1][b]*maxHeight - 0.5*maxHeight
					else
						height2 = mapNoise2[1][b]*maxHeight - 0.5*maxHeight
					end
					local height3 = 0
					if (b < noiseSize) then
						height3 = mapNoise1[a][b+1]*maxHeight - 0.5*maxHeight
					else
						height3 = mapNoise3[a][1]*maxHeight - 0.5*maxHeight
					end
					local height4 = 0
					if (a == noiseSize and b == noiseSize) then
						height4 = mapNoise4[1][1]*maxHeight - 0.5*maxHeight
					elseif (a == noiseSize) then
						height4 = mapNoise2[1][b+1]*maxHeight - 0.5*maxHeight
					elseif (b == noiseSize) then
						height4 = mapNoise3[a+1][1]*maxHeight - 0.5*maxHeight
					else
						height4 = mapNoise1[a+1][b+1]*maxHeight - 0.5*maxHeight
					end

					local c1 = colors.lime
					local c2 = colors.green

					local snowHeight = relativeSnowHeight * maxHeight - 0.5*maxHeight
					local waterHeight = relativeWaterHeight * maxHeight - 0.5*maxHeight

					if (height1 >= snowHeight or height2 >= snowHeight or height3 >= snowHeight) then
						c1 = colors.white
					end
					if (height2 >= snowHeight or height3 >= snowHeight or height4 >= snowHeight) then
						c2 = colors.lightGray
					end
					if (height1 <= waterHeight or height2 <= waterHeight or height3 <= waterHeight or height4 <= waterHeight) then
						height1 = max(height1, waterHeight)
						height2 = max(height2, waterHeight)
						height3 = max(height3, waterHeight)
						height4 = max(height4, waterHeight)
						if (height1 <= waterHeight and height2 <= waterHeight and height3 <= waterHeight) then
							c1 = colors.blue
						end
						if (height2 <= waterHeight and height3 <= waterHeight and height4 <= waterHeight) then
							c2 = colors.blue
						end
					end

					local map = mapA
					if b + a > noiseSize+1 then
						map = mapB
					end

					local xOffset = 0
					local zOffset = 0
 					if map == mapA then
						xOffset = -(1/2 + 1) + -noiseSize*0.5
						zOffset = -sqrt(0.75) + -noiseSize * sqrt(0.75) / 3
					else
						xOffset = -(1/2 + 1) + -noiseSize
						zOffset = -sqrt(0.75) + -noiseSize * sqrt(0.75) * 2 / 3
					end

					map[#map+1] = {
						x1 = xOffset + b/2 + a+1, y1 = height2, z1 = zOffset + b*sqrt(0.75),
						x2 = xOffset + b/2 + a, y2 = height1, z2 = zOffset + b*sqrt(0.75),
						x3 = xOffset + b/2 + a+0.5, y3 = height3, z3 = zOffset + (b+1)*sqrt(0.75),
						c = c1,
					}

					if b + a == noiseSize+1 then
						map = mapB

						xOffset = -(1/2 + 1) + -noiseSize
						zOffset = -sqrt(0.75) + -noiseSize * sqrt(0.75) * 2 / 3
					end

					map[#map+1] = {
						x1 = xOffset + b/2 + a+0.5, y1 = height3, z1 = zOffset + (b+1)*sqrt(0.75),
						x2 = xOffset + b/2 + a+1.5, y2 = height4, z2 = zOffset + (b+1)*sqrt(0.75),
						x3 = xOffset + b/2 + a+1, y3 = height2, z3 = zOffset + b*sqrt(0.75),
						c = c2,
					}

					polyCount = polyCount + 2
				end
			end

			objects[#objects+1] = ThreeDFrame:newObject(
				mapA, -- model
				chunkX * noiseSize + chunkZ * noiseSize*0.5, -- X
				0, -- Y
				chunkZ * noiseSize * sqrt(0.75) -- Z
			)

			objects[#objects+1] = ThreeDFrame:newObject(
				mapB, -- model
				chunkX * noiseSize + chunkZ * noiseSize*0.5 + noiseSize*0.5, -- X
				0, -- Y
				chunkZ * noiseSize * sqrt(0.75) + noiseSize * sqrt(0.75)/3 -- Z
			)
		end
	end

	-- skybox
	do
		local file = fs.open("skybox.bmp", "rb")

		--[[local bottom = {}
		for y = 1, 256 do
			file.seek("set", 0x76 + (y - 1) * 512 + 128)
			local l = {}
			bottom[257-y] = l
			for x = 1, 256, 2 do
				local c = file.read()
				l[x], l[x+1] = 2^bit32.rshift(c, 4), 2^bit32.band(c, 15)
			end
		end]]

		local left, front, right, back = {}, {}, {}, {}
		for y = 1, 256 do
			file.seek("set", 0x76 + (y - 1) * 512)
			local l = {}
			left[257-y] = l
			for x = 1, 256, 2 do
				local c = file.read()
				l[x], l[x+1] = 2^bit32.rshift(c, 4), 2^bit32.band(c, 15)
			end
			l = {}
			front[257-y] = l
			for x = 1, 256, 2 do
				local c = file.read()
				l[x], l[x+1] = 2^bit32.rshift(c, 4), 2^bit32.band(c, 15)
			end
			l = {}
			right[257-y] = l
			for x = 1, 256, 2 do
				local c = file.read()
				l[x], l[x+1] = 2^bit32.rshift(c, 4), 2^bit32.band(c, 15)
			end
			l = {}
			back[257-y] = l
			for x = 1, 256, 2 do
				local c = file.read()
				l[x], l[x+1] = 2^bit32.rshift(c, 4), 2^bit32.band(c, 15)
			end
		end

		local top = {}
		for y = 1, 256 do
			file.seek("set", 0x76 + 256 * 512 + (y - 1) * 512 + 128)
			local l = {}
			top[257-y] = l
			for x = 1, 256, 2 do
				local c = file.read()
				l[x], l[x+1] = 2^bit32.rshift(c, 4), 2^bit32.band(c, 15)
			end
		end

		file.close()

		local skybox = {
			ThreeDFrame:newObject(Pine3D.models:plane({texture = front, size = 1000}), 1000, 0, 0, 0, 0, -math.pi / 2),
			ThreeDFrame:newObject(Pine3D.models:plane({texture = back, size = 1000}), -1000, 0, 0, 0, math.pi, math.pi / 2),
			ThreeDFrame:newObject(Pine3D.models:plane({texture = left, size = 1000}), 0, 0, -1000, -math.pi / 2, math.pi / 2, 0),
			ThreeDFrame:newObject(Pine3D.models:plane({texture = right, size = 1000}), 0, 0, 1000, math.pi / 2, -math.pi / 2, 0),
			ThreeDFrame:newObject(Pine3D.models:plane({texture = top, size = 1000}), 0, 1000, 0, 0, 0, math.pi),
			--ThreeDFrame:newObject(Pine3D.models:plane({texture = bottom, size = 1000}), 0, -1000, 0, 0, 0, 0),
		}
		for _, v in ipairs(skybox) do objects[#objects+1] = v end
	end

	local object = ThreeDFrame:newObject(Pine3D.models:icosphere({color = colors.white, res = 3}), math.floor(rows / 2) * noiseSize, 5, math.floor(columns / 2) * noiseSize)
	generateCubemap(objects, object)

	local function convert_xyz_to_cube_uv(x, y, z)
		local absX = math.abs(x);
		local absY = math.abs(y);
		local absZ = math.abs(z);

		local isXPositive = x > 0
		local isYPositive = y > 0
		local isZPositive = z > 0

		local maxAxis, uc, vc, index;

		-- POSITIVE X
		if (isXPositive and absX >= absY and absX >= absZ) then
			-- u (0 to 1) goes from +z to -z
			-- v (0 to 1) goes from -y to +y
			maxAxis = absX;
			uc = z;
			vc = -y;
			index = object.cubemap.front;
		end
		-- NEGATIVE X
		if (not isXPositive and absX >= absY and absX >= absZ) then
			-- u (0 to 1) goes from -z to +z
			-- v (0 to 1) goes from -y to +y
			maxAxis = absX;
			uc = -z;
			vc = -y;
			index = object.cubemap.back;
		end
		-- POSITIVE Y
		if (isYPositive and absY >= absX and absY >= absZ) then
			-- u (0 to 1) goes from -x to +x
			-- v (0 to 1) goes from +z to -z
			maxAxis = absY;
			uc = z;
			vc = x;
			index = object.cubemap.top;
		end
		-- NEGATIVE Y
		if (not isYPositive and absY >= absX and absY >= absZ) then
			-- u (0 to 1) goes from -x to +x
			-- v (0 to 1) goes from -z to +z
			maxAxis = absY;
			uc = z;
			vc = -x;
			index = object.cubemap.bottom;
		end
		-- POSITIVE Z
		if (isZPositive and absZ >= absX and absZ >= absY) then
			-- u (0 to 1) goes from -x to +x
			-- v (0 to 1) goes from -y to +y
			maxAxis = absZ;
			uc = -x;
			vc = -y;
			index = object.cubemap.right;
		end
		-- NEGATIVE Z
		if (not isZPositive and absZ >= absX and absZ >= absY) then
			-- u (0 to 1) goes from +x to -x
			-- v (0 to 1) goes from -y to +y
			maxAxis = absZ;
			uc = x;
			vc = -y;
			index = object.cubemap.left;
		end

		-- Convert range from -1 to 1 to 0 to 1
		local u = 0.5 * (uc / maxAxis + 1.0);
		local v = 0.5 * (vc / maxAxis + 1.0);
		return u, v, index
	end

	--[[local normdat = {}
	object:setVertexShader(function(x, y, z, poly, n)
		local vx = normdat[poly] or {}
		vx[n] = vector.new(x, y, z)
		vx.v = nil
		normdat[poly] = vx
		return x, y, z, {x = x + object[1], y = y + object[2], z = z + object[3]}
	end)]]
	object:setVertexShader(function(x, y, z)
		local m = 1 + p
		return x * m, y * m, z * m
	end)
	object:setFragmentShader(function (x, y, depth, poly, texcolor, interpVars, barycentric)
		local pxcx, pycy = x - barycentric.x3, y - barycentric.y3

		local ba = (barycentric.bycy * pxcx + barycentric.cxbx * pycy) / barycentric.den
		local bb = (barycentric.cyay * pxcx + barycentric.axcx * pycy) / barycentric.den
		local bc = 1 - ba - bb

		local vxx, vxy, vxz =
			ba * poly[1] + bb * poly[4] + bc * poly[7],
			ba * poly[2] + bb * poly[5] + bc * poly[8],
			ba * poly[3] + bb * poly[6] + bc * poly[9]
		local d = 1 + cos(vxy * 20 + i / 2) / 16
		local posx, posy, posz = vxx * d + object[1], vxy * d + object[2], vxz * d + object[3]
		local vxlen = sqrt(vxx*vxx + vxy*vxy + vxz*vxz)
		vxx = vxx / vxlen
		vxy = vxy / vxlen
		vxz = vxz / vxlen

		local axisx, axisz = --vx:cross(vector.new(0, 1, 0)):normalize()
			-vxz, vxx
		local axislen = sqrt(axisx*axisx + axisz*axisz)
		axisx = axisx / axislen
		axisz = axisz / axislen
		local angle = sin(vxy * 20 + i / 2) * pi / 8
		local sangle, cangle = sin(angle), 1 - cos(angle)
		local vax, vay, vaz =
			vxy * axisz * sangle,
            (vxz * axisx - vxx * axisz) * sangle,
            -vxy * axisx * sangle
		local vbx, vby, vbz =
			-axisz * vxy,
            axisz * vxx - axisx * vxz,
            axisx * vxy
		vbx, vby, vbz =
			-axisz * vby * cangle,
			(axisz * vbx - axisx * vbz) * cangle,
			axisx * vby * cangle
		vxx = vxx + vax + vbx
		vxy = vxy + vay + vby
		vxz = vxz + vaz + vbz

		--vx = vx + vx:cross(axis):mul(math.sin(angle)) + axis:cross(axis:cross(vx)):mul(1 - math.cos(angle))

		--local I = (pos - vector.new(ThreeDFrame.camera[1], ThreeDFrame.camera[2], ThreeDFrame.camera[3])):normalize()
		local Ix, Iy, Iz = posx - ThreeDFrame.camera[1], posy - ThreeDFrame.camera[2], posz - ThreeDFrame.camera[3]
		local Ilen = sqrt(Ix*Ix + Iy*Iy + Iz*Iz)
		Ix = Ix / Ilen
		Iy = Iy / Ilen
		Iz = Iz / Ilen
		--local R = (I - vx * (2 * I:dot(vx))):normalize()
		local Ivx = 2 * (Ix * vxx + Iy * vxy + Iz * vxz)
		local Rx, Ry, Rz = Ix - vxx * Ivx, Iy - vxy * Ivx, Iz - vxz * Ivx
		local Rlen = sqrt(Rx*Rx + Ry*Ry + Rz*Rz)
		Rx = Rx / Rlen
		Ry = Ry / Rlen
		Rz = Rz / Rlen
		--print(pos, I, R) sleep(0.05)
		local u, v, tex = convert_xyz_to_cube_uv(Rx * depth, Ry * depth, Rz * depth)
		local r = tex[floor(v * (#tex - 1) + 1)]
		return r[floor(u * (#r - 1) + 1)]
	end)

	objects[#objects+1] = object

	--print("polyCount: " .. polyCount)
	--sleep(0.5)

	return objects
end

local objects = generateWorld(ThreeDFrame, genOptions)

for j = 0, 15 do ThreeDFrame.buffer.blitWin.setPaletteColor(2^j, term.nativePaletteColor(2^j)) end

parallel.waitForAny(function()
	while true do
		if i <= 10 then
			local br = i / 10
			local wr = (1 - i / 10)
			for j = 0, 15 do
				local r, g, b = term.nativePaletteColor(2^j)
				ThreeDFrame.buffer.blitWin.setPaletteColor(2^j, r * br + wr, g * br + wr, b * br + wr)
			end
		end
		ThreeDFrame:setCamera(-3 * math.cos(math.rad(i * 4)) + math.floor(genOptions.chunkRows / 2) * noiseSize, math.cos(i / 40) / 3 + 5, -3 * math.sin(math.rad(i * 4)) + math.floor(genOptions.chunkColumns / 2) * noiseSize, 0, i * 4, math.cos(i / 40) * -10)
		ThreeDFrame:drawObjects(objects)
		ThreeDFrame:drawBuffer()
		i = i + 1
		p = p * 0.5
		sleep(0.05)
	end
end, function()
	while true do
		os.pullEvent("pulse")
		if p < 0.125 then p = 0.25 end
	end
end, function()
	os.pullEvent("trigger")
	for i = 1, 20 do
		local ar = 1 - i / 20
		local br = i / 20
		for j = 0, 15 do
			local r, g, b = term.nativePaletteColor(2^j)
			ThreeDFrame.buffer.blitWin.setPaletteColor(2^j, r * ar + (1 - r) * br, g * ar + (1 - g) * br, b * ar + (1 - b) * br)
		end
		sleep(0.05)
	end
	while true do os.pullEvent() end
end)

