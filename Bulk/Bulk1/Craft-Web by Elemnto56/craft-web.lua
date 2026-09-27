if arg[1] ~= nil then
    if arg[1] ~= "nil" then shell.run("window-launch " .. arg[1] .. " true") end
end

-- Constants
local function tobool(text)
    if text == "true" then
        return true
    elseif text == "false" then
        return false
    end

    return false
end 

local function trimWhitespace(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

local DEVICE_WIDTH, DEVICE_HEIGHT = term.getSize()

-- PixelUI Generated Code
local PixelUI = require("pixelui")
PixelUI.init()
term.clear()

-- Create main container
local main = PixelUI.container({
    width = DEVICE_WIDTH,
    height = DEVICE_HEIGHT
})

-- Showing tip instead of an error
local tipOnURLFormat = PixelUI.notificationToast({
    message = "Format: cw://[RTS id]?[dir]",
    type = "info",
    x = 1, y = 18,
    duration = 5 * 1000,

    animateIn = true, animateOut = true
})

local noAntennaErr = PixelUI.notificationToast({
    message = "Make sure to add the Radio Antenna!",
    type = "error",
    x = 1, y = 18,
    duration = 5 * 1000,

    animateIn = true, animateOut = true
})

local notAModem = PixelUI.notificationToast({
    message = "The back peripheral was not a modem!",
    type = "error",
    x = 1, y = 18,
    duration = 5 * 1000,

    animateIn = true, animateOut = true
})

local fileNotFound = PixelUI.notificationToast({
    message = "The file could not be found on the RTC.",
    type = "error",
    x = 1, y = 18,
    duration = 5 * 1000,

    animateIn = true, animateOut = true
})


local reqTimeout = PixelUI.notificationToast({
    message = "The request to RTC timed out.",
    type = "error",
    x = 1, y = 18,
    duration = 5 * 1000,

    animateIn = true, animateOut = true
})

main:addChild(PixelUI.textBox({
    x = 8, y = 1, width = DEVICE_WIDTH - (DEVICE_WIDTH - 38),
    placeholder = "Address Bar",
    enabled = true,
    onEnter = function(self, text)
        local protocol = text:match("^(%w+)://.+")

        if protocol == "cw" then
            local port, path, extras = text:match("^cw://(%d+)%?([^@&]+)([@&]?.*)$")
            
            -- flags
            local include = false
            if extras:match("&(.+)") == "include" then include = true end

            if peripheral.isPresent("back") then
                local x = ""; x, _ = peripheral.getType("back");
                if x ~= "modem" then notAModem:show() end
                rednet.open("back") -- Register it to rednet

                if extras:match("^@POST") then
                    local clientPath = extras:match("%:(.+)")
                    
                    if not fs.exists(clientPath) then PixelUI.notificationToast({message = clientPath .. " does not exist", type = "error", x = 1, y = 18,duration = 5 * 1000, animateIn = true, animateOut = true}):show() else 
                        local file = fs.open(clientPath, "r")

                        local postInfo = {
                            content = file.readAll(),
                            serverPath = extras:match("(/.+)$")
                        }
                        file.close()
                        rednet.send(tonumber(port), textutils.serialize(postInfo, {compact = true}), "POST")
                        local _, allGood, _ = rednet.receive("200", 5)
                        
                        if allGood == nil then PixelUI.notificationToast({message = "Response from server timed out", type = "error", x = 1, y = 18,duration = 5 * 1000, animateIn = true, animateOut = true}):show() else 

                            PixelUI.notificationToast({message = allGood, type = "success", x = 1, y = 18,duration = 5 * 1000, animateIn = true, animateOut = true}):show()
                            if not include then fs.delete(clientPath) end
                        end
                    end
                elseif extras:match("^@DELETE") then
                    rednet.send(tonumber(port), path, "DELETE")

                    local _, successMsg, status = rednet.receive(nil, 5)

                    if status == "404" then
                        PixelUI.notificationToast({message = successMsg, type = "error", x = 1, y = 18,duration = 5 * 1000, animateIn = true, animateOut = true}):show()
                    elseif status == "200" then
                        PixelUI.notificationToast({message = successMsg, type = "success", x = 1, y = 18,duration = 5 * 1000, animateIn = true, animateOut = true}):show()
                    end
                else
                    rednet.send(tonumber(port), path, "GET")
                    local _, fileContent, status = rednet.receive(nil, 3)

                    if fileContent == nil or status == nil then reqTimeout:show()
                    elseif tonumber(status) == 404 then fileNotFound:show() 
                    else
                        local grabbedFile = path:match("(%w+%.cml)")
                        local tmp = fs.open(grabbedFile, "w")
                        tmp.write(fileContent)
                        tmp.close()

                        shell.run("window-launch " .. grabbedFile .. " true")
                        if not include then fs.delete(grabbedFile) end
                    end
                end
            elseif peripheral.isPresent("top") then
                local freq = math.random(1, 6400)
                local ant = peripheral.wrap("top")

                if port == nil or path == nil then tipOnURLFormat:show()end 
                if ant == nil then noAntennaErr:show() end

                ant.setFrequency(0)
                ant.broadcast("GET" .. " " .. tostring(port).. " " .. path .. " " .. freq)
                ant.setFrequency(freq)
                local _, _, content, _ = os.pullEvent("radio_message")
                
                local grabbedFile = path:match("(%w+%.cml)")
                local tmp = fs.open(grabbedFile, "w")
                tmp.write(content)
                tmp.close()

                if not include then fs.delete(grabbedFile) end

                shell.run("window-launch " .. grabbedFile .. " true")
            end
        elseif protocol == "http" or protocol == "https" then
            term.setTextColor(colors.white)
            term.write("got here")
            local valid, _ = http.checkURL(trimWhitespace(text))
            local cont = true

            if not tobool(valid) then PixelUI.notificationToast({ message = "The following URL was invalid", type = "error", x = 1, y = 18, duration = 5 * 1000, animateIn = true, animateOut = true}):show() end

            local posFile = http.get({url = trimWhitespace(tostring(text))})
            if posFile == nil then PixelUI.notificationToast({ message = "Could not correctly fetch file", type = "error", x = 1, y = 18, duration = 5 * 1000, animateIn = true, animateOut = true}):show(); cont = false; end

            if cont then
                local file = fs.open("tmp.cml", "w+") 
                file.write(posFile.readAll())
                file.close()

                if not include then fs.delete("tmp.cml") end

                shell.run("window-launch tmp.cml true " .. text)
            end
        end
    end 
}))

local tabContent = PixelUI.container({
    width=DEVICE_WIDTH, height=DEVICE_HEIGHT,
})

tabContent:addChild(
PixelUI.label({
    x = 16, y = 3,
    text = "Welcome to Craft-Web!",
    color = colors.black,
    background = colors.white
}))


tabContent:addChild(
    PixelUI.richTextBox({
        x = 7, y = 6, width = DEVICE_WIDTH - 11, height = DEVICE_HEIGHT - 9,
        lines = {"To start, either call craft-web with the",  "arg of your .cml file, or connect to a ", "network via address bar"},
        wordWrap = true
    })
)
-- To start, either call craft-web with the arg of your cml file, or connect to a network via address bar

-- TabControl element
local element1 = PixelUI.tabControl({
    x = 1, y = 2,
    width = DEVICE_WIDTH, height = DEVICE_HEIGHT,

    tabs = {{text = "Main", content = tabContent}},
    background = colors.white
})

main:addChild(element1)

-- Button element
local element2 = PixelUI.button({
    x = 48,
    y = 1,
    width = DEVICE_WIDTH - 47,
    height = DEVICE_HEIGHT - 18,
    text = "Exit",
    onClick = function(self)
        PixelUI.clear()
        os.queueEvent("terminate")
        if arg[2] == "true" then os.queueEvent("terminate"); os.queueEvent("terminate"); end
    end,
    background = colors.red
})
main:addChild(element2)

-- Start the UI
PixelUI.run()