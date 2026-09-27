local libtracc = require "libtracc"
local loop = require "taskmaster"()

local speaker = peripheral.find "speaker"
if not speaker then error("Please attach a speaker.") end
local stereo = jit and fs.exists("risk98.xm") and peripheral.isPresent("left") and peripheral.isPresent("right")
local file = fs.open(stereo and "risk98.xm" or "risk98_mono.xm_squash.xm", "rb")
local xm = libtracc.readXMFile(file)
file.close()

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

loop:task(function()
    libtracc.play(xm, 1, 4800, getSpeakers())
end):task(function()
    clear()
    local task = loop:addTask(function() shell.run("intro.lua") end)
    local beep = false
    while xm.order < 2 do
        sleep(0.25)
        if xm.row >= 0x38 and not beep then
            speaker.playNote("bit", 1, 24)
            beep = true
        end
    end
    term.setTextColor(colors.yellow)
    term.setCursorPos(1, 1)
    textutils.slowPrint("AstrOS 1.0", 10)
    textutils.slowWrite("A:\\> ", 20)
    term.setCursorBlink(true)
    term.setTextColor(colors.white)
    sleep(1.5)
    textutils.slowPrint("start demo", 5)
    sleep(0.5)
    loop:addTask(function()
        sleep(0.2)
        for _ = 1, 23 do
            speaker.playNote("hat", 1, 12)
            sleep(0.1)
        end
    end)
    write("STARTING UP...")
    term.setTextColor(colors.white)
    sleep(1.5)
    term.setTextColor(colors.green)
    write("\nLOADING RESOURCES...")
    term.setTextColor(colors.white)
    sleep(1)
    term.setTextColor(colors.cyan)
    write("\nRETICULATING SPLINES...")
    term.setTextColor(colors.white)
    while xm.order < 3 do sleep(0.25) end
    --xm.order = 15
    task = loop:addTask(function() shell.run("parallaxtext.lua 20 INTRODUCING A NEW COMPUTERCRAFT DEMO.....\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0\xA0MADE WITH HACKS BY JACKMACWINDOWS IN 2024.....") end)
    while xm.order < 5 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("logo.lua") end)
    while xm.order < 6 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("matrix.lua") end)
    while xm.order < 7 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("interference.lua") end)
    while xm.order < 8 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("plasma.lua 100") end)
    while xm.row < 48 do sleep(0.1) end
    xm.channels[7].noteHook = function() _G.PLASMA_BUFF = 0.2 end
    while xm.order < 9 do sleep(0.25) end
    xm.channels[7].noteHook = nil
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("mode7.lua 3") end)
    while xm.order < 10 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("mandelbrot.lua") end)
    while xm.order < 11 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("mode7.lua 8") end)
    while xm.order < 12 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("Pine3D/texture.lua", jit and "/catjam3.gif" or "/catjam.gif") end)
    while xm.order < 13 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("Pine3D/wobble.lua") end)
    while xm.order < 14 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("Pine3D/boing-lit2.lua") end)
    while xm.order < 15 do sleep(0.25) end
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("tunnel3d.lua 200") end)
    while xm.order < 16 do sleep(0.25) end
    _G.TUNNEL_BACKWARDS = true -- ew
    while xm.order < 17 do sleep(0.25) end
    _G.TUNNEL_WIREFRAME = true -- ew
    _G.TUNNEL_BACKWARDS = nil
    --task:remove()
    --clear()
    --xm.order = 18
    while xm.order < 18 do sleep(0.25) end
    _G.TUNNEL_WIREFRAME = nil
    _G.TUNNEL_BREAKDOWN = true
    while xm.order < 19 do sleep(0.25) end
    _G.TUNNEL_BREAKDOWN = nil
    task:remove()
    clear()
    task = loop:addTask(function() shell.run("starwars.lua CraftOS-Normal-9.bdf greetings.txt") end)
    while xm.order < 21 do sleep(0.25) end
    task:remove()
    clear()
    term.setTextColor(colors.lightBlue)
    write("SYNCING DISKS...")
    term.setTextColor(colors.white)
    term.setCursorBlink(true)
    sleep(1)
    term.setTextColor(colors.orange)
    write("\nSHUTTING DOWN...")
    term.setTextColor(colors.white)
    sleep(2)
    term.setCursorBlink(false)
    local br, bg, bb = term.getPaletteColor(colors.black)
    for n = 0.98, 0, -0.02 do
        for i = 0, 15 do
            local r, g, b = term.getPaletteColor(2^i)
            term.setPaletteColor(2^i, (r-br)*n+br, (g-bg)*n+bg, (b-bb)*n+bb)
        end
        sleep(0.1)
    end
    clear()
end):run()

for i = 0, 15 do term.setPaletteColor(2^i, term.nativePaletteColor(2^i)) end
term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.orange)
print("Thank you for experiencing this ONE OF A KIND demo for ComputerCraft !!")
term.setTextColor(colors.green)
print("I hope you enjoyed it :-)")
term.setTextColor(colors.yellow)
print("This was my second demo, and it was fun to try some new things with Mode7 and Pine3D, especially shaders and lighting.")
print()
term.setTextColor(colors.blue)
print("Astronaut demo (c) 2024-2025 JackMacWindows")
print("Code licensed under GPLv2")
print("Fonts licensed under OFL")
print("Music: risk98.xm by ANiMAL.SaC")
local t = term.current()
require("redrun").start(function()
    for _ = 1, 5 do
        t.setPaletteColor(colors.blue, term.nativePaletteColor(colors.black))
        sleep(0.5)
        t.setPaletteColor(colors.blue, term.nativePaletteColor(colors.blue))
        sleep(0.5)
    end
end)
os.queueEvent("HUP")
