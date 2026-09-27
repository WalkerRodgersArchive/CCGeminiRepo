-- Constants
local DEVICE_WIDTH, DEVICE_HEIGHT = term.getSize()

local function trimWhitespace(s)
    return s:gsub("^%s*(.-)%s*$", "%1")
end

local function parseCML(text)
    local result = {}
    local i = 1

    while i <= #text do
        -- Check if we're at a color tag
        if text:sub(i, i) == "[" then
            -- Find the closing bracket
            local closeBracket = text:find("]", i, true)
            if closeBracket then
                -- Extract the entire tag including brackets
                local tag = text:sub(i, closeBracket)
                table.insert(result, tag)
                i = closeBracket + 1
            else
                -- No closing bracket found, treat as regular text
                i = i + 1
            end
        else
            -- Extract a word (non-whitespace characters)
            local word = ""
            while i <= #text and not text:sub(i, i):match("%s") and text:sub(i, i) ~= "[" do
                word = word .. text:sub(i, i)
                i = i + 1
            end

            if #word > 0 then
                table.insert(result, word)
            end

            -- Capture whitespace as a separate token
            local whitespace = ""
            while i <= #text and text:sub(i, i):match("%s+") do
                whitespace = whitespace .. text:sub(i, i)
                i = i + 1
            end

            if #whitespace > 0 then
                table.insert(result, whitespace)
            end
        end
    end

    return result
end

--UI/UX
local to_write = arg[1]
local PixelUI = require("pixelui")
PixelUI.init()
term.clear()

local tooBig = PixelUI.notificationToast({
    message = "Some text was truncated W:1",
    type = "warning",
    duration = 2000
})

local topBar = PixelUI.container({
    x = 1, y = 1, width = DEVICE_WIDTH, height = 2,
    background = colors.lightGray
})

topBar:addChild(PixelUI.label({
    x = 1, y = 1, text = to_write, background = colors.lightGray
}))

topBar:addChild(PixelUI.button({
    x = 1, y = 2, text = "Return to Craft-Web", width = DEVICE_WIDTH / 2, background = colors.blue, height = 1
}))

topBar:addChild(PixelUI.button({
    x = DEVICE_WIDTH / 2, y = 2, text ="Exit", width = DEVICE_WIDTH / 2 + 4, background = colors.red, height = 1,
    onClick = function()
        term.clear()
        os.queueEvent("terminate")
        if arg[2] == "true" or arg[2] == true then os.queueEvent("terminate"); sleep(1) end
        sleep(1)
    end
}))

-- Reset to write
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.setCursorPos(1, 4)
-- arg[2] will be debug. It'll run on booleans.
if #arg ~= 0 then
    local cmlTable = {}
    local cmlParsedTable = {}

    local raw_str = ""

    local index = 0
    local x = 0
    local y = 0

    for line in io.lines(trimWhitespace(arg[1])) do
        if string.sub(line, 1, 2) == "--" then
            goto continue
        end
        cmlTable[#cmlTable+1] = line
        ::continue::
    end

    for _, value in ipairs(cmlTable) do
        raw_str = raw_str .. value
    end

    local sentence = false
    cmlParsedTable = parseCML(raw_str)
    while index < #cmlParsedTable do
        local word = cmlParsedTable[index + 1]
        x, y = term.getCursorPos()

        if string.match(word, "%[/?[A-Za-z]+%]") ~= nil then
            local color = string.match(word, "/?[A-Za-z]+")
            if string.sub(color, 1,1) == "/" then
                term.setTextColor(colors.white)
                index = index + 1
                goto continue
            else
                term.setTextColor(colors[color])
            end
        else

            if x + #word > DEVICE_WIDTH then
                term.setCursorPos(1, y + 1);
            end

            term.write(word)
            if #cmlParsedTable >= 258 then sleep(0.04) end
        end

        index = index + 1
        ::continue::
    end

end

PixelUI.run()

--[[
while true do
  local event, second, third, fourth = os.pullEventRaw()

  if event == "terminate" then
    term.clear()
    os.queueEvent("terminate")
    sleep(1)
  

  elseif event == "key" then
    if keys.getName(second) == "H" then paintutils.drawFilledBox(2, 3, 30, 7, colors.red) end
    sleep(1)
  end

  sleep(1)
end
]]
