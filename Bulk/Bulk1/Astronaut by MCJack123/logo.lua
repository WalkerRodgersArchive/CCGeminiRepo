local start = os.epoch "utc"
local w, h = term.getSize()
local path
if h >= 76 and fs.exists("/astronaut-4x.32v") then path = "/astronaut-4x.32v"
elseif h >= 38 and fs.exists("/astronaut-2x.32v") then path = "/astronaut-2x.32v"
else path = "/astronaut-1x.32v" end

-- 32vid-player-mini from sanjuuni
-- Licensed under the MIT license

local bit32_band, bit32_lshift, bit32_rshift, math_frexp = bit32.band, bit32.lshift, bit32.rshift, math.frexp
local function log2(n) local _, r = math_frexp(n) return r-1 end
local file = assert(fs.open(path, "rb"))

if file.read(4) ~= "32VD" then file.close() error("Not a 32Vid file") end
local width, height, fps, nstreams, flags = ("<HHBBH"):unpack(file.read(8))
--print(width, height, fps, nstreams, flags)
if nstreams ~= 1 then file.close() error("Separate stream files not supported by this tool") end
if bit32_band(flags, 1) == 0 then file.close() error("DEFLATE or no compression not supported by this tool") end
local _, nframes, ctype = ("<IIB"):unpack(file.read(9))
if ctype ~= 0x0C then file.close() error("Stream type not supported by this tool") end
local padX, padY = math.floor((w - width) / 2), math.floor((h - height) / 2)

local function readDict(size)
    local retval = {}
    for i = 0, size - 1, 2 do
        local b = file.read()
        retval[i] = bit32.rshift(b, 4)
        retval[i+1] = bit32.band(b, 15)
    end
    return retval
end
local init, read
if bit32_band(flags, 3) == 1 then
    local decodingTable, X, readbits, isColor
    function init(c)
        isColor = c
        local R = file.read()
        local L = 2^R
        local Ls = readDict(c and 24 or 32)
        if R == 0 then
            decodingTable = file.read()
            X = nil
            return
        end
        local a = 0
        for i = 0, #Ls do Ls[i] = Ls[i] == 0 and 0 or 2^(Ls[i]-1) a = a + Ls[i] end
        assert(a == L, a)
        decodingTable = {R = R}
        local x, step, next, symbol = 0, 0.625 * L + 3, {}, {}
        for i = 0, #Ls do
            next[i] = Ls[i]
            for _ = 1, Ls[i] do
                while symbol[x] do x = (x + 1) % L end
                x, symbol[x] = (x + step) % L, i
            end
        end
        for x = 0, L - 1 do
            local s = symbol[x]
            local t = {s = s, n = R - log2(next[s])}
            t.X, decodingTable[x], next[s] = bit32_lshift(next[s], t.n) - L, t, 1 + next[s]
        end
        local partial, bits, pos = 0, 0, 1
        function readbits(n)
            if not n then n = bits % 8 end
            if n == 0 then return 0 end
            while bits < n do pos, bits, partial = pos + 1, bits + 8, bit32_lshift(partial, 8) + file.read() end
            local retval = bit32_band(bit32_rshift(partial, bits-n), 2^n-1)
            bits = bits - n
            return retval
        end
        X = readbits(R)
    end
    function read(nsym)
        local retval = {}
        if X == nil then
            for i = 1, nsym do retval[i] = decodingTable end
            return retval
        end
        local i = 1
        local last = 0
        while i <= nsym do
            local t = decodingTable[X]
            if isColor and t.s >= 16 then
                local l = 2^(t.s - 15)
                for n = 0, l-1 do retval[i+n] = last end
                i = i + l
            else retval[i], last, i = t.s, t.s, i + 1 end
            X = t.X + readbits(t.n)
        end
        --print(X)
        return retval
    end
else
    error("Unimplemented!")
end

local blitColors = {[0] = "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
local frames = {}
local timeTarget = 14
local f = 1
term.setBackgroundColor(colors.black)
term.clear()
for n = 1, nframes do
    local size, ftype = ("<IB"):unpack(file.read(5))
    --print(size, ftype, file.seek())
    if ftype == 0 then
        --if os.epoch "utc" - lastyield > 50 then sleep(0) lastyield = os.epoch "utc" end
        local dcstart = os.epoch "utc"
        --print("init screen", vframe, file.seek())
        init(false)
        --print("read screen", vframe, file.seek())
        local screen = read(width * height)
        --print("init colors", vframe, file.seek())
        init(true)
        --print("read bg colors", vframe)
        local bg = read(width * height)
        --print("read fg colors", vframe)
        local fg = read(width * height)
        --local dctime = os.epoch "utc" - dcstart
        --while os.epoch "utc" < start + vframe * 1000 / fps do end
        local texta, fga, bga = {}, {}, {}
        for y = 0, height - 1 do
            local text, fgs, bgs = "", "", ""
            for x = 1, width do
                text = text .. string.char(128 + screen[y*width+x])
                fgs = fgs .. blitColors[fg[y*width+x]]
                bgs = bgs .. blitColors[bg[y*width+x]]
            end
            texta[y+1], fga[y+1], bga[y+1] = text, fgs, bgs
        end
        frames[n] = {texta = texta, fga = fga, bga = bga, palette = {}}
        for i = 0, 15 do
            local r, g, b = file.read() / 255, file.read() / 255, file.read() / 255
            if i == 15 then r, g, b = term.nativePaletteColor(colors.black) end
            frames[n].palette[i] = {r, g, b}
            if f > 0 then
                r, g, b = r + (1 - r) * f * f, g + (1 - g) * f * f, b + (1 - b) * f * f
            elseif f < -timeTarget then
                local ii = (f+timeTarget+2)/2
                local m = math.max(ii*ii, 0)
                r, g, b = r*m, g*m, b*m
            end
            term.setPaletteColor(2^i, r, g, b)
        end
        f = f - 0.1
        for y = 1, height do
            term.setCursorPos(1 + padX, y + padY)
            term.blit(texta[y], fga[y], bga[y])
        end
        --term.setCursorPos(1, height + 1)
        --term.clearLine()
        --print("Frame decode time:", dctime, "ms")
        sleep(0.05 - (os.epoch "utc" - dcstart) / 1000)
    else file.close() error("Unknown frame type " .. ftype) end
end
file.close()

for _ = 1, 2 do
    for _, frame in ipairs(frames) do
        for y = padY + 1, padY + height do
            term.setCursorPos(padX + 1, y)
            term.blit(frame.texta[y-padY], frame.fga[y-padY], frame.bga[y-padY])
        end
        for i = 0, 15 do
            local r, g, b = table.unpack(frame.palette[i], 1, 3)
            if f > 0 then
                r, g, b = r + (1 - r) * f * f, g + (1 - g) * f * f, b + (1 - b) * f * f
            elseif f < -timeTarget then
                local ii = (f+timeTarget+2)/2
                local m = math.max(ii*ii, 0)
                r, g, b = r*m, g*m, b*m
            end
            term.setPaletteColor(2^i, r, g, b)
        end
        f = f - 0.1
        if f < -timeTarget - 2 then break end
        sleep(0.05)
    end
    if f < -18 then break end
end

for i = 0, 15 do term.setPaletteColor(2^i, term.nativePaletteColor(2^i)) end
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.setCursorPos(1, 1)
term.clear()
