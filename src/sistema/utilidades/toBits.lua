local function toBits(num)
    -- returns a table of bits, least significant first.
    local t = {} -- will contain the bits
    while num > 0 do
        local rest = math.fmod(num, 2)
        t[#t + 1] = rest
        num = (num - rest) / 2
    end

    return t
end

return toBits
