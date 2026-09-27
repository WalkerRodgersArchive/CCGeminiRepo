term.clear()
local w, h = term.getSize()
local wins = {}
for x = 1, w do wins[x] = window.create(term.current(), x, 1, 1, h) wins[x].chars = 0 end
local i = 0
--local col = math.random(1, w)
for k = 1, 2000 do
    for col = 1, w do
        local sel = math.random(1, 8)
        if sel < 3 then
            -- do nothing
        else
            if sel == 5 then wins[col].scroll(-1) end
            if sel == 4 then wins[col].setCursorPos(1, math.floor(math.sqrt(math.random(1, (h/4)^2))))
            else wins[col].setCursorPos(1, select(2, wins[col].getCursorPos()) + 1) end
            wins[col].setTextColor(2^i)
            local c = math.random(0, 255 + wins[col].chars * 8)
            wins[col].write(string.char(c <= 255 and c or 0))
            wins[col].chars = c < 256 and wins[col].chars + 1 or 0
        end
    end
    for j = 0, 14 do
        term.setPaletteColor(2^((i + j) % 15), j == 14 and 0.5 or 0, j / 16, j == 14 and 0.5 or 0)
    end
    i = (i + 1) % 15
    sleep(0.1)
end
for j = 0, 15 do term.setPaletteColor(2^j, term.nativePaletteColor(2^j)) end
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)
