-- Palette from pywal (~/.cache/wal/colors, one hex per line, color0..color15).
-- The static values are only a fallback for when the cache is missing.
local fallback = {
    "#0f1e25", "#483C64", "#634C65", "#BC5422",
    "#9B5E61", "#D17560", "#C79252", "#c3c6c8",
    "#5f6d74", "#483C64", "#634C65", "#BC5422",
    "#9B5E61", "#D17560", "#C79252", "#c3c6c8",
}

local palette = {}
local f = io.open(os.getenv("HOME") .. "/.cache/wal/colors", "r")
if f then
    for line in f:lines() do
        if line:match("^#%x%x%x%x%x%x$") then
            palette[#palette + 1] = line
        end
    end
    f:close()
end
if #palette < 16 then
    palette = fallback
end

for i = 1, 16 do
    _G["color" .. (i - 1)] = palette[i]
end
