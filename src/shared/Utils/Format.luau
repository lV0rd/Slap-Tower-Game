local Format = {}

function Format.abbreviate(number)
    local absNum = math.abs(number)
    if absNum >= 1e12 then
        return string.format("%.1fT", number / 1e12)
    elseif absNum >= 1e9 then
        return string.format("%.1fB", number / 1e9)
    elseif absNum >= 1e6 then
        return string.format("%.1fM", number / 1e6)
    elseif absNum >= 1e3 then
        return string.format("%.1fK", number / 1e3)
    else
        return tostring(number)
    end
end

function Format.comma(number)
    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

function Format.time(seconds)
    seconds = math.floor(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return string.format("%d:%02d:%02d", h, m, s)
    else
        return string.format("%d:%02d", m, s)
    end
end

return Format