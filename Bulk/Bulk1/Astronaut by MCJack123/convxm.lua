local input = assert(fs.open(..., "rb"))
local output = assert(fs.open(... .. "_squash.xm", "wb"))
output.write(input.read(60))
local fileHeaderSize = ("<I4"):unpack(input.read(4))
output.write(("<I4"):pack(fileHeaderSize))
output.write(input.read(6))
local nPats, nInsts = ("<I2I2"):unpack(input.read(4))
output.write(("<I2I2"):pack(nPats, nInsts))
output.write(input.read(fileHeaderSize - 14))
print(nPats, nInsts)
for _ = 1, nPats do
    local patHeaderSize = ("<I4"):unpack(input.read(4))
    output.write(("<I4"):pack(patHeaderSize))
    output.write(input.read(3))
    local size = ("<I2"):unpack(input.read(2))
    output.write(("<I2"):pack(size))
    if patHeaderSize > 9 then output.write(input.read(patHeaderSize - 9)) end
    print(size)
    output.write(input.read(size))
end
for _ = 1, nInsts do
    local instHeaderSize = ("<I4"):unpack(input.read(4))
    output.write(("<I4"):pack(instHeaderSize))
    output.write(input.read(23))
    local nSamps = ("<I2"):unpack(input.read(2))
    print(instHeaderSize, nSamps)
    if nSamps > 0 then
        local sampHeaderSize = ("<I4"):unpack(input.read(4))
        output.write(("<I2I4"):pack(nSamps, sampHeaderSize))
        output.write(input.read(instHeaderSize - 33))
        for _ = 1, nSamps do
            local size = ("<I4"):unpack(input.read(4))
            print(size)
            local header = input.read(10) .. string.char(bit32.bor(input.read(), 0x80)) .. input.read(sampHeaderSize - 15)
            local last = 0
            local wavetable = {}
            for k = 1, size do
                local d = input.read()
                if d > 0x7F then d = d - 256 end
                last = last + d
                while last > 127 do last = last - 256 end
                while last < -128 do last = last + 256 end
                wavetable[k] = last
            end
            local encoder = require "cc.audio.dfpwm".make_encoder()
            local enc = ""
            local pos = 1
            while pos <= #wavetable do
                if wavetable[pos+1] == wavetable[pos] then
                    local k = pos + 1
                    while k <= #wavetable and wavetable[k] == wavetable[k-1] and k - pos < 0x80 do k = k + 1 end
                    enc = enc .. ("Bb"):pack(0x80 + (k - pos - 1), wavetable[pos])
                    pos = k
                else
                    local k = pos
                    while k <= #wavetable and wavetable[k] ~= wavetable[k+1] and k - pos < 0x80 do k = k + 1 end
                    if k - pos < 8 then
                        for i = pos, math.min(k - 1, #wavetable) do
                            enc = enc .. ("Bb"):pack(0x80, wavetable[i])
                        end
                    else
                        local len = math.min(k - pos, #wavetable - pos)
                        local max = 0
                        for i = pos, pos + len - 1 do max = math.max(max, math.abs(wavetable[i])) end
                        enc = enc .. string.char(len - 1, max)
                    end
                    pos = k
                end
            end
            output.write(("<I4"):pack(#enc))
            output.write(header)
            output.write(enc)
        end
    else
        output.write("\0\0")
        if instHeaderSize > 29 then output.write(input.read(instHeaderSize - 29)) end
    end
end