local libtracc = require "libtracc"
libtracc.interpolation = jit and "linear" or "none"
local loop = require "taskmaster"()

-- preload
require "bdf"
require "pixelbox"
require "Pine3D"
require "util"

local speaker = peripheral.find "speaker"
if not speaker then error("Please attach a speaker.") end
local stereo = peripheral.isPresent("left") and peripheral.isPresent("right") and not _HOST:match "%(Minecraft"
local file = assert(fs.open("4thdim.xm", "rb"))
local xm = libtracc.readXMFile(file)
file.close()
xm.loop = false
xm.midiMacros.fixed[0x20] = function (state, channel)
    os.queueEvent("pulse")
end
xm.midiMacros.parametered[0] = function(state, channel, param)
    os.queueEvent("change_part", param)
end
xm.midiMacros.parametered[1] = function(state, channel, param)
    os.queueEvent("trigger", param)
end
if not stereo then for _, c in ipairs{2, 4, 5, 9, 10, 12, 13, 14, 15, 17, 21} do xm.channels[c].kill = true end end -- improve performance by killing stereo channels
if select(2, ...) and term.getGraphicsMode then _G.USE_GFX = true else _G.USE_GFX = nil end

local function clear()
    term.setCursorPos(1, 1)
    term.setCursorBlink(false)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    for i = 0, 15 do term.setPaletteColor(2^i, term.nativePaletteColor(2^i)) end
end

local function getSpeakers()
    if stereo and peripheral.isPresent("left") and peripheral.isPresent("right") and peripheral.hasType("left", "speaker") and peripheral.hasType("right", "speaker") then
        -- CraftOS-PC hack
        pcall(peripheral.call, "left", "setPosition", 1, 0, 0)
        pcall(peripheral.call, "right", "setPosition", -1, 0, 0)
        return peripheral.wrap "left", peripheral.wrap "right"
    else return peripheral.find "speaker" end
end

local exit = false
local function exitListener()
    repeat local event, key = os.pullEvent() until event == "char" or (event == "key" and key == keys.enter)
    local pal = {}
    for i = 0, 15 do pal[i] = {term.getPaletteColor(2^i)} end
    local bc = term.nativePaletteColor(2^15)
    local gv = _G.PLAYER and _G.PLAYER.globalVolume
    for i = 1, 20 do
        local p = i / 20
        for j = 0, 15 do term.setPaletteColor(2^j, pal[j][1] * (1 - p) + bc * p, pal[j][2] * (1 - p) + bc * p, pal[j][3] * (1 - p) + bc * p) end
        if _G.PLAYER then _G.PLAYER.globalVolume = gv * (1-p)^2 end
        sleep(0.05)
    end
    exit = true
    loop:stop()
end

local function finish()
    for _, v in ipairs{getSpeakers()} do v.stop() end
    if term.getGraphicsMode and term.getGraphicsMode() then term.setGraphicsMode(false) end
    for i = 0, 15 do term.setPaletteColor(2^i, term.nativePaletteColor(2^i)) end
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.blue)
    print("4th Dimension demo (c) 2026 JackMacWindows")
    term.setTextColor(colors.lightBlue)
    print("        Made for PineJam 2026")
    print()
    term.setTextColor(colors.yellow)
    print("Code licensed under GPLv2")
    print("Font licensed under OFL")
    print("3D objects licensed under CC-BY 4.0")
    term.setTextColor(colors.green)
    print("Music: The 4th Dimension by Orange")
    print()
end

local parts = {
    [0] = "intro.lua",
    "fractaltext.lua",
    "tunnelspin.lua",
    "wobblewave.lua",
    "scene.lua",
    "fadetrail.lua",
    "mirrorball.lua",
    "mengersponge.lua",
    "greetings.lua"
}

for k, v in pairs(parts) do parts[k] = loadfile(v, nil, _ENV) end

local start
if ... then start = tonumber(...) end

local playerTask
loop:task(function(task)
    playerTask = task
    _G.PLAYER = xm
    if start then xm.order = start end
    libtracc.play(xm, 1, 2400, getSpeakers())
    os.queueEvent("change_part")
end):task(function()
    local part = -1
    repeat
        local v = parts[part+1]
        if not v then clear() end
        local task = loop:addTask(function() if v then return v() end end)
        _, part = os.pullEvent("change_part")
        task:remove()
    until playerTask.finished or not part
    loop:stop()
end):task(exitListener):run()
if exit then return finish() end

return finish()
