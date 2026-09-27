local pixelbox = require "pixelbox"
local fps = jit and config and config.get("clockSpeed") or 20
for i = 0, 7 do term.setPaletteColor(2^i, 0, 0, i / 15) end
for i = 8, 15 do term.setPaletteColor(2^i, (i - 8) / 7, (i - 8) / 7, i / 15) end
local pix = pixelbox.new(term.current())
local w, h = pix.width, pix.height
local max_iteration = 64
local cx = 0
local cy = 1
for z = 1, 1000, 100 / fps do
    local rstart = os.epoch "utc"
    for py = 1, pix.height do
        local line = pix.canvas[py]
        for px = 1, w do
            local x0 = ((px - w/2 - 1) / w * 4.94) / 2^(z / 25) - cx
            local y0 = ((py - h/2 - 1) / h * 4.48) / 2^(z / 25) - cy
            local x2, y2, ww = 0, 0, 0
            local iteration = 0
            while x2 + y2 <= 4 and iteration < max_iteration do
                local x = x2 - y2 + x0
                local y = ww - x2 - y2 + y0
                x2 = x * x
                y2 = y * y
                local xy = x + y
                ww = xy * xy
                iteration = iteration + 1
            end
            line[px] = 2^(iteration % 16)
        end
    end
    pix:render()
    sleep(math.max(1 / fps - (os.epoch "utc" - rstart) / 1000, 0))
end
