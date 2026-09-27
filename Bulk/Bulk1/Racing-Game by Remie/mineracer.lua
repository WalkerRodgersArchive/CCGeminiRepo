--[[
terminal 51x18
bonusi 
goida raz v 500kadr
]]
-------
function isInteger(n)
    if type(n) ~= "number" then
        return false
    end
    return n == math.floor(n)
end

function drawInterface()
    term.setBackgroundColor(colors.green)
    term.setCursorPos(1,2)
    term.write(string.rep("@", 51))
    term.setCursorPos(1,18)
    term.write(string.rep("@", 51))
    for i=2, 17, 1 do
        term.setCursorPos(1,i)
        term.write("@")
        term.setCursorPos(51, i)
        term.write("@")
    end
    term.setBackgroundColor(colors.black)
end

function drawPlayer(x, y)
    local playerCar = {
        " o   o",
        "(#=%=#>",
        "|==ROCKET===>",
        "(#=%=#>",
        " o   o"
    }
    term.setTextColor(colors.lightBlue)
    for i, line in ipairs(playerCar) do
        term.setCursorPos(x, y + i - 1)
        term.write(line)
    end
    term.setCursorPos(1, 1)
    term.setTextColor(colors.white)
end

function drawHud(score)
    term.setCursorPos(19,1)
    term.write("Your score: " .. score)
end

function drawEnemy(x, y)
    local enemy = {
        "X-X-X",
        "|###|",
        "|###|",
        "X-X-X",
        " o o "
    }
    term.setBackgroundColor(colors.red)
    term.setTextColor(colors.black)
    for i, line in ipairs(enemy) do
        term.setCursorPos(x, y + i - 1)
        term.write(line)
    end
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end

function deleteEntity(xCord, yCord, xSize, ySize)
    term.setBackgroundColor(colors.black)
    local emptyLine = string.rep(" ", xSize)
    for i=1, ySize do
        term.setCursorPos(xCord, yCord + i - 1)
        term.write(emptyLine)
    end
end

function checkCollision(pX, pY, pW, pH, eX, eY, eW, eH)
    return pX < eX + eW and
    pX + pW > eX and
    pY < eY + eH and
    pY + pH > eY
end
------
local playerWidth = 14
local playerHeight = 5
local enemyWidth = 5
local enemyHeight = 5
------
local spawnRate = 20
local enemies = {}
local lanesY = {3, 8, 13}
------
local startX = 2
local startY = 3
local plCordX = startX
local plCordY = startY
local highScore = 0
------
local tickCounter = 0
local timerDuration = 1/20 --20 ticks
local timerId = os.startTimer(timerDuration)
------
local gameRunning = true
------
term.clear()
drawInterface()
drawPlayer(startX, startY)

while gameRunning do
    local event, buttonPressed, timer = os.pullEvent()
    if event == "key" then
        if buttonPressed == keys.down then
            deleteEntity(plCordX, plCordY, 14, 5)
            drawInterface()
            if plCordY < 13 then
                plCordY = plCordY + 5
                drawPlayer(plCordX, plCordY)
            else drawPlayer(plCordX, plCordY)
            end
            --term.setCursorPos(1,1)
            --term.write("y: " .. plCordY)
        elseif buttonPressed == keys.up then
            deleteEntity(plCordX, plCordY, 14, 5)
            drawInterface()
            if plCordY > 3 then
                plCordY = plCordY - 5 
                drawPlayer(plCordX, plCordY)
            else drawPlayer(plCordX, plCordY)
            end
            --term.setCursorPos(1,1)
            --term.write("y: " .. plCordY)
        elseif buttonPressed == keys.q then
            term.clear()
            term.setCursorPos(1,1)
            print("High Score: " .. highScore)
            print("Press any button...")
            break
        end
    elseif event == "timer" then
        tickCounter = tickCounter + 1
        for i = #enemies, 1, -1 do
            local enemy = enemies[i]
            deleteEntity(enemy.x, enemy.y, enemyWidth, enemyHeight)
            enemy.x = enemy.x - 1
            if enemy.x < 1 then
                table.remove(enemies, i)
            end
        end
        for i, enemy in ipairs(enemies) do
            if checkCollision(plCordX, plCordY, playerWidth, playerHeight, enemy.x, enemy.y, enemyWidth, enemyHeight) then
                gameRunning = false
                break
            end
        end
        if isInteger(tickCounter/20) then
            --term.setCursorPos(1,1)
            --term.write("time= " .. tickCounter/20)
            highScore = highScore + 100
        end
        if tickCounter % spawnRate == 0 then
            local randomLaneIndex = math.random(1, #lanesY)
            local spawnY = lanesY[randomLaneIndex]
            local newEnemy = {
                x = 52,
                y = spawnY
            }
            table.insert(enemies, newEnemy)
        end
        timerId = os.startTimer(timerDuration)
    end  
    for i, enemy in ipairs(enemies) do
        if enemy.x< 52 then
            drawEnemy(enemy.x, enemy.y)
        end
    end
    drawPlayer(plCordX, plCordY)
    drawHud(highScore)   
    drawInterface()  
end

term.clear()
term.setCursorPos(15, 8)
term.setBackgroundColor(colors.red)
term.setTextColor(colors.white)
print("  GAME OVER!  ")
term.setBackgroundColor(colors.black)
term.setCursorPos(15, 10)
print("Your final score: " .. highScore)
term.setCursorPos(15, 12)
print("Press enter to exit.")
read()
term.clear()
term.setCursorPos(1,1)