--local Pine3D = require "Pine3D"
local readBDFFont = require "bdf"
local util = {}

local hsidx = 1
local k1, k2, k3
if _HOST >= "ComputerCraft 1.106" then k1, k2, k3 = 1, 2, 3
else k1, k2, k3 = "text", "textColor", "backgroundColor" end
function util.hscroller(win)
    local k, tLines = debug.getupvalue(win.getLine, hsidx)
    while k ~= "tLines" do
        hsidx = hsidx + 1
        k, tLines = debug.getupvalue(win.getLine, hsidx)
    end
    function win.hscroll(cols, rs)
        cols = math.floor(cols)
        if not rs then
            local fg, bg = win.getTextColor(), win.getBackgroundColor()
            local a, b, c = (" "):rep(math.abs(cols)), ("%x"):format(select(2, math.frexp(fg))+1):rep(math.abs(cols)), ("%x"):format(select(2, math.frexp(bg))+1):rep(math.abs(cols))
            rs = {}
            for y = 1, #tLines do rs[y] = {a, b, c} end
        end
        if cols >= 1 then
            for y = 1, #tLines do
                tLines[y][k1] = tLines[y][k1]:sub(cols + 1) .. rs[y][1]
                tLines[y][k2] = tLines[y][k2]:sub(cols + 1) .. rs[y][2]
                tLines[y][k3] = tLines[y][k3]:sub(cols + 1) .. rs[y][3]
            end
            win.redraw()
        elseif cols <= -1 then
            for y = 1, #tLines do
                tLines[y][k1] = rs[y][1] .. tLines[y][k1]:sub(1, cols - 1)
                tLines[y][k2] = rs[y][2] .. tLines[y][k2]:sub(1, cols - 1)
                tLines[y][k3] = rs[y][3] .. tLines[y][k3]:sub(1, cols - 1)
            end
            win.redraw()
        end
    end
    local oldscroll = win.scroll
    function win.scroll(...)
        oldscroll(...)
        k, tLines = debug.getupvalue(win.getLine, hsidx)
    end
    function win.setAllLines(img)
        for y = 1, #img do tLines[y] = img[y] end
    end
    return win
end

local parentidx, internalBlitidx, redrawidx, redrawLine_internalBlitidx, redrawLine_redrawidx, redrawLine_clearLineidx = 1, 1, 1, 1, 1, 1
function util.maskwin(win, mask)
    local k, tLinesMask, tLinesWin, parent, internalBlit, redraw
    k, tLinesMask = debug.getupvalue(mask.getLine, hsidx)
    while k ~= "tLines" do
        hsidx = hsidx + 1
        k, tLinesMask = debug.getupvalue(mask.getLine, hsidx)
    end
    k, tLinesWin = debug.getupvalue(win.getLine, hsidx)
    k, parent = debug.getupvalue(mask.reposition, parentidx)
    while k ~= "parent" do
        parentidx = parentidx + 1
        k, parent = debug.getupvalue(mask.reposition, parentidx)
    end
    local nX, nY = mask.getPosition()

    local function redrawLine(n)
        local tLine = tLinesMask[n]
        local tLineWin = tLinesWin[n]
        parent.setCursorPos(nX, nY + n - 1)
        parent.blit(
            tLine[k1]:gsub("()%z+()", function(x, y) return tLineWin[k1]:sub(x, y-1) end),
            tLine[k2]:gsub("()%z+()", function(x, y) return tLineWin[k2]:sub(x, y-1) end)
                :gsub("()\1+()", function(x, y) return tLineWin[k3]:sub(x, y-1) end),
            tLine[k3]:gsub("()%z+()", function(x, y) return tLineWin[k3]:sub(x, y-1) end))
    end
    -- Now we go fishing for all redrawLine upvalues
    k, internalBlit = debug.getupvalue(mask.blit, internalBlitidx)
    while k ~= "internalBlit" do
        internalBlitidx = internalBlitidx + 1
        k, internalBlit = debug.getupvalue(mask.blit, internalBlitidx)
    end
    k = debug.getupvalue(internalBlit, redrawLine_internalBlitidx)
    while k ~= "redrawLine" do
        redrawLine_internalBlitidx = redrawLine_internalBlitidx + 1
        k = debug.getupvalue(internalBlit, redrawLine_internalBlitidx)
    end
    debug.setupvalue(internalBlit, redrawLine_internalBlitidx, redrawLine)
    k, internalBlit = debug.getupvalue(win.blit, internalBlitidx)
    debug.setupvalue(internalBlit, redrawLine_internalBlitidx, redrawLine)

    k, redraw = debug.getupvalue(mask.clear, redrawidx)
    while k ~= "redraw" do
        redrawidx = redrawidx + 1
        k, redraw = debug.getupvalue(mask.clear, redrawidx)
    end
    k = debug.getupvalue(redraw, redrawLine_redrawidx)
    while k ~= "redrawLine" do
        redrawLine_redrawidx = redrawLine_redrawidx + 1
        k = debug.getupvalue(redraw, redrawLine_redrawidx)
    end
    debug.setupvalue(redraw, redrawLine_redrawidx, redrawLine)
    k, redraw = debug.getupvalue(win.clear, redrawidx)

    k = debug.getupvalue(mask.clearLine, redrawLine_clearLineidx)
    while k ~= "redrawLine" do
        redrawLine_clearLineidx = redrawLine_clearLineidx + 1
        k = debug.getupvalue(mask.clearLine, redrawLine_clearLineidx)
    end
    debug.setupvalue(mask.clearLine, redrawLine_clearLineidx, redrawLine)
    debug.setupvalue(win.clearLine, redrawLine_clearLineidx, redrawLine)

    local oldscrollmask = mask.scroll
    function mask.scroll(...)
        oldscrollmask(...)
        k, tLinesMask = debug.getupvalue(mask.getLine, hsidx)
    end
    local oldscrollwin = win.scroll
    function win.scroll(...)
        oldscrollwin(...)
        k, tLinesWin = debug.getupvalue(win.getLine, hsidx)
    end
end

function util.loadCompressedModel(path)
    local Pine3D = require "Pine3D"
    local file = assert(fs.open(path, "rb"))
    assert(file.read(4) == "P3Dm")
    local npolys = ("<I4"):unpack(file.read(4))
    local t = {}
    for i = 1, npolys do
        local o = {}
        t[i] = o
        o.c, o.x1, o.y1, o.z1, o.x2, o.y2, o.z2, o.x3, o.y3, o.z3 = ("<Bfffffffff"):unpack(file.read(37))
        o.forceRender = bit32.btest(o.c, 0x80)
        o.c = 2^bit32.band(o.c, 0x0F)
    end
    file.close()
    if not Pine3D.transforms then
        local idx = 1
        local k, transforms = debug.getupvalue(Pine3D.loadModel, idx)
        while k ~= "transforms" do
            idx = idx + 1
            k, transforms = debug.getupvalue(Pine3D.loadModel, idx)
        end
        Pine3D.transforms = transforms
    end
    for name, func in pairs(Pine3D.transforms) do
        t[name] = func
    end
    return t
end

local floor, sin, cos, min, max = math.floor, math.sin, math.cos, math.min, math.max

function util.mode7(canvas, ox, oy, dx, dy, w, h, col, mod, a, b, c, d)
    local retval = {}
    for y = 1, h do
        local l = {}
        retval[y] = l
        local mx, my, mv, ma, mb, mc, md = dx, dy, 1, a, b, c, d
        if mod then mx, my, mv, ma, mb, mc, md = mod(y, dx, dy, a, b, c, d) end
        if ma == 0 and mb == 0 and mc == 0 and md == 0 then
            for x = 1, w do l[x] = col or 32768 end
        else
            for x = 1, w do
                local cx, cy = x + mx - ox, y + my - oy
                local nx = floor(ma * cx + mb * cy + ox)
                local ny = floor(mc * cx + md * cy + oy)
                local cl = canvas[ny]
                l[x] = floor(min(max((cl and cl[nx] or col or 32768) / mv, 1), 32768))
            end
        end
    end
    return retval
end

function util.matmul(x, y, z, w, a, b, c, d) return x * a + y * c, x * b + y * d, z * a + w * c, z * b + w * d end
function util.base() return 1, 0, 0, 1, -1 end
function util.scale(xres, yres, a, b, c, d) return util.matmul(a, b, c, d, xres, 0, 0, yres) end
function util.rotate(th, a, b, c, d)
    local si, co = sin(th), cos(th)
    return util.matmul(a, b, c, d, co, si, -si, co)
end
function util.shear(xres, yres, a, b, c, d) return util.matmul(a, b, c, d, 1, xres, yres, 1) end
function util.reflectX(a, b, c, d) return util.matmul(a, b, c, d, -1, 0, 0, 1) end
function util.reflectY(a, b, c, d) return util.matmul(a, b, c, d, 1, 0, 0, -1) end
function util.reflectLine(th, a, b, c, d)
    local x, y = cos(th), sin(th)
    return util.matmul(a, b, c, d, x^2 - y^2, 2 * x * y, 2 * x * y, y^2 - x^2)
end

function util.tile(canvas, w, h)
    for y = 1, h do
        if not canvas[y] then canvas[y] = {} end
        setmetatable(canvas[y], {__index = function(self, idx) return rawget(self, (idx - 1) % w + 1) end})
    end
    return setmetatable(canvas, {__index = function(self, idx) return rawget(self, (idx - 1) % h + 1) end})
end

local xpmmap = {[" "] = 1, ["."] = 2, ["+"] = 4, ["@"] = 8, ["#"] = 16, ["$"] = 32, ["%"] = 64, ["&"] = 128, ["*"] = 256, ["="] = 512, ["-"] = 1024, [";"] = 2048, [">"] = 4096, [","] = 8192, ["'"] = 16384, [")"] = 32768}
local xpmmap_alpha = {["."] = 1, ["+"] = 2, ["@"] = 4, ["#"] = 8, ["$"] = 16, ["%"] = 32, ["&"] = 64, ["*"] = 128, ["="] = 256, ["-"] = 512, [";"] = 1024, [">"] = 2048, [","] = 4096, ["'"] = 8192, [")"] = 16384, ["!"] = 32768}

function util.loadxpm(file, poff)
    poff = poff or 0
    assert(file.readLine() == "/* XPM */")
    file.readLine()
    local width, height, npal, _ = file.readLine():match('"(%d+) (%d+) (%d+) (%d+)",')
    width, height, npal = tonumber(width), tonumber(height), tonumber(npal)
    assert(width)
    local map = xpmmap
    if npal == 17 then
        map = xpmmap_alpha
        npal = npal - 1
        file.readLine()
    end
    for i = 1, npal do
        local rgb = file.readLine():match('".\tc #(%x%x%x%x%x%x)",')
        term.setPaletteColor(2^(i-1+poff), tonumber(rgb, 16))
    end
    local img = {}
    for y = 1, height do
        local ll = {}
        for x, c in file.readLine():sub(2, width + 1):gmatch "()(.)" do ll[x] = map[c] * 2^poff end
        img[y] = ll
    end
    return img, width, height
end

--[[
LZW adapted from code by Rochet2

MIT License

Copyright (c) 2016 Rochet2

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local char = string.char
local type = type
local sub = string.sub
local tconcat = table.concat
local byte = string.byte

local function dictAddB(str, dict, n)
    dict[n] = str
    n = n+1
    return dict, n
end

local function decompress(file)
    local codesize = file.read()
    local len = file.read()

    local basedictdecompress = {}
    for i = 0, 2^codesize-1 do
        local ic = char(i)
        basedictdecompress[i] = ic
    end

    local nbits, buf, nbuf = codesize + 1, 0, 0
    local function readCode()
        while nbuf < nbits do
            if len == 0 then
                len = file.read()
            end
            buf = buf + file.read() * 2^nbuf
            len = len - 1
            nbuf = nbuf + 8
        end
        local res = buf % 2^nbits
        buf = floor(buf / 2^nbits)
        nbuf = nbuf - nbits
        return res
    end

    local dict = {}
    local a = 2^codesize + 2

    local result = {}
    local n = 1
    local last
    repeat
        last = readCode()
        if not last or last == 2^codesize + 1 then return {} end
        if last == 2^codesize then nbits, a, dict = codesize + 1, 2^codesize + 2, {}
        else
            result[n] = basedictdecompress[last] or dict[last]
            n = n+1
        end
    until n > 1
    while true do
        local code = readCode()
        if not code or code == 2^codesize + 1 then break end
        if code == 2^codesize then nbits, a, dict = codesize + 1, 2^codesize + 2, {}
        else
            local lastStr = basedictdecompress[last] or dict[last]
            if not lastStr then
                return nil, "could not find last from dict. Invalid input?"
            end
            local toAdd = basedictdecompress[code] or dict[code]
            if toAdd then
                result[n] = toAdd
                n = n+1
                dict, a = dictAddB(lastStr..sub(toAdd, 1, 1), dict, a)
            else
                local tmp = lastStr..sub(lastStr, 1, 1)
                result[n] = tmp
                n = n+1
                dict, a = dictAddB(tmp, dict, a)
            end
            if a == 2^nbits then
                --if #res % nbits ~= 0 then res = res .. ("\0"):rep(nbits - (#res % nbits)) end
                local bits = nbuf % 8
                if bits ~= 0 then
                    buf = floor(buf / 2^bits)
                    nbuf = nbuf - bits
                end
                nbits = nbits + 1
            end
            last = code
        end
    end
    return tconcat(result)
end

function util.loadgif(file)
    assert(file.read(3) == "GIF")
    file.read(3)
    local width, height, hflag, bgidx, par = ("<I2I2BBB"):unpack(file.read(7))
    local pal = {}
    if bit32.btest(hflag, 0x80) then
        for i = 0, 2^(bit32.band(hflag, 7)+1)-1 do
            pal[i] = {file.read() / 255, file.read() / 255, file.read() / 255}
        end
    end
    local frames = {}
    while true do
        repeat
            local c = file.read()
            if c == 0x21 then
                file.read()
                repeat
                    local sz = file.read()
                    file.seek("cur", sz)
                until sz == 0
            elseif c == 0x3b then return frames, pal, width, height
            elseif c ~= 0x2c then error("Unsupported image " .. c) end
        until c == 0x2c
        local frame = {}
        frames[#frames+1] = frame
        local sx, sy, fw, fh, fflag = ("<I2I2I2I2B"):unpack(file.read(9))
        if bit32.btest(fflag, 0x80) then
            frame.palette = {}
            for i = 0, 2^(bit32.band(fflag, 7)+1)-1 do
                frame.palette[i] = {file.read() / 255, file.read() / 255, file.read() / 255}
            end
        end
        local decomp = assert(decompress(file))
        assert(file.read() == 0)
        for y = 1, fh do
            local l = {}
            frame[y+sy] = l
            for x = 1, fw do
                l[x+sx] = 2^decomp:byte((y - 1) * fw + x)
            end
        end
    end
end

local ceil, min, max = math.ceil, math.min, math.max

function util.drawText(text, font, scale, color)
    local direction = font.slant ~= "R"
    local overall = {lbearing = 0, rbearing = 0, width = 0, ascent = 0, descent = 0}
    for c in string.gmatch(text, ".") do if c:byte() >= 0x20 and font.chars[c] then
        local fch = font.chars[c]
        overall.ascent = floor(max(overall.ascent, fch.bounds.y + fch.bounds.height))
        overall.descent = floor(min(overall.descent, fch.bounds.y))
        overall.lbearing = floor(min(overall.lbearing, fch.bounds.x + overall.width))
        overall.rbearing = floor(max(overall.rbearing, fch.bounds.x + fch.bounds.width + overall.width))
        overall.width = floor(overall.width + fch.device_width.x)
    end end
    local err, ascent, descent = direction, overall.ascent, overall.descent
    local fimg = {}
    local maxx = 0
    do
        local x, y = 1, 1
        for c in string.gmatch(text, ".") do
            if c == "\n" then
                x, y = 1, y + font.bounds.height
            elseif c:byte() >= 0x10 and c:byte() < 0x20 then
                color = 2^(c:byte() - 0x10)
            else
                local fc = font.chars[c]
                for py = 1, fc.bounds.height do for px = 1, fc.bounds.width do if fc.bitmap[py][px] then
                    local ax, ay = x + px + fc.bounds.x, y + py - fc.bounds.y - fc.bounds.height + ascent - descent
                    for yy = 1, scale do
                        fimg[(ay-1)*scale+yy] = fimg[(ay-1)*scale+yy] or {}
                        for xx = 1, scale do
                            fimg[(ay-1)*scale+yy][(ax-1)*scale+xx] = color
                        end
                    end
                    maxx = max(maxx, ax*scale)
                end end end
                x = x + fc.device_width.x + 1
            end
        end
    end
    if fimg[0] then
        local miny = 0
        while fimg[miny] do miny = miny - 1 end
        for y = #fimg - miny, 1, -1 do fimg[y] = fimg[y+miny] end
    end
    maxx = ceil(maxx / 2) * 2
    for y = 1, ceil(table.maxn(fimg) / 3) * 3 do fimg[y] = fimg[y] or {} end
    return fimg, maxx, #fimg
end

return util