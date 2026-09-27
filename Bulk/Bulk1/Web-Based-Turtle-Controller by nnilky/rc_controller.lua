
function fuel()
	if turtle.getFuelLevel() <= 100 then
		if turtle.refuel() == false then
			ws.send(textutils.serializeJSON({err = "fuel"}))
		end
	end
end

function inspectSurrounding(ws, x, y, z)
	
	hasSeenBlock, blockInfo = turtle.inspectDown()
	if hasSeenBlock then
		ws.send(textutils.serializeJSON({operation = "appendWorldInfo", xCoord = x, yCoord = y-1, zCoord = z, blockData = blockInfo}))
	end
end


term.setCursorPos(1,2)
term.clear()

--Orienting the turtle to face East.
gpsXOld, gpsYOld, gpsZOld = gps.locate()
turtle.forward()
gpsXNew, gpsYNew, gpsZNew = gps.locate()
turtle.back()

if (gpsXNew-gpsXOld) == 1 then     --Facing North [Z-]
elseif (gpsXOld-gpsXNew) == 1 then --Facing South [Z+]
	turtle.turnRight()
	turtle.turnRight()
elseif (gpsZNew-gpsZOld) == 1 then --Facing East [X+]
	turtle.turnLeft()
	turtle.turnLeft()
else 							   --Facing West [X-]
	turtle.turnRight()
end

ws, err = http.websocket("ws://localhost:5656")
if err then
	print(string.format("Error: %s",err))
else
	--== This is the logic of the program. ==--
	print("VoxOS RC Turtle Controller vAlpha")
	
	while true do
		fuel()
		local message = ws.receive()
		if message then
			local deserializedMessage = textutils.unserializeJSON(message)
			if deserializedMessage.operation == "locate" then
				coordinates = {gps.locate()}
				ws.send(textutils.serializeJSON({operation = "sending", xPos = coordinates[1], yPos = coordinates[2], zPos = coordinates[3]}))				
			elseif deserializedMessage.operation == "moving" then
				curX, curY, curZ = gps.locate()
				desX = tonumber(deserializedMessage.xPos) == nil and curX or tonumber(deserializedMessage.xPos) ~= nil and deserializedMessage.xPos
				desY = tonumber(deserializedMessage.yPos) == nil and curY or tonumber(deserializedMessage.yPos) ~= nil and deserializedMessage.yPos
				desZ = tonumber(deserializedMessage.zPos) == nil and curZ or tonumber(deserializedMessage.zPos) ~= nil and deserializedMessage.zPos
				--(That feels like a very scuffed ternary function.)
				returnNormal = true
				if (curX-desX) > 0 then --Moving East [X+]
					turtle.turnLeft()
					turtle.turnLeft()
					for i=1, math.abs(curX-desX) do
						if turtle.forward() == false then
							ws.send(textutils.serializeJSON({operation = "error", xPos = (curX+i-1), yPos = curY, zPos = curZ}))
							returnNormal = false
							break
						end
						inspectSurrounding(ws, curX+i, curY, curZ)
					end
					turtle.turnLeft()
					turtle.turnLeft()
				elseif (curX-desX) == 0 then
				--This is slightly more energy efficient.
				else -- Moving West [X-]
					for i=1, math.abs(curX-desX) do
						if turtle.forward() == false then
							ws.send(textutils.serializeJSON({operation = "error", xPos = (curX-i+1), yPos = curY, zPos = curZ}))
							returnNormal = false
							break
						end
						inspectSurrounding(ws, curX+i, curY, curZ)
					end					
				end
				
				if (curZ-desZ) > 0 then --Moving North [Z+]
					turtle.turnLeft()
					for i=1, math.abs(curZ-desZ) do
						if turtle.forward() == false then
							ws.send(textutils.serializeJSON({operation = "error", xPos = desX, yPos = curY, zPos = (curZ-i+1)}))
							returnNormal = false
							break
						end
						inspectSurrounding(ws, desX, curY, curZ-i)
					end
					turtle.turnRight()
				elseif (curZ-desZ) == 0 then
				--This is slightly more energy efficient.
				else -- Moving South [Z-]
					turtle.turnRight()
					for i=1, math.abs(curZ-desZ) do
						if turtle.forward() == false then
							ws.send(textutils.serializeJSON({operation = "error", xPos = desX, yPos = curY, zPos = (curZ+i-1)}))
							returnNormal = false
							break
						end
						inspectSurrounding(ws, desX, curY, curZ+i)
					end
					turtle.turnLeft()
				end
				if (curY-desY) > 0 then
					for i=1, math.abs(curY-desY) do
						if turtle.down() == false then
							ws.send(textutils.serializeJSON({operation = "error", xPos = desX, yPos = (curY-i+1), zPos = desZ}))
							returnNormal = false
							break
						end
						inspectSurrounding(ws, desX, curY-i, desZ)
					end
				elseif (curY-desY) == 0 then
				--This is slightly more energy efficient.
				else
					for i=1, math.abs(curY-desY) do
						if turtle.up() == false then
							ws.send(textutils.serializeJSON({operation = "error", xPos = desX, yPos = (curY+i-1), zPos = desZ}))
							returnNormal = false
							break
						end
						inspectSurrounding(ws, desX, curY+i, desZ)
					end
				end
				if returnNormal == true then
					ws.send(textutils.serializeJSON({operation = "done", xPos = desX, yPos = desY, zPos = desZ}))
				end
			end
		end
	end
	ws.close()
end
