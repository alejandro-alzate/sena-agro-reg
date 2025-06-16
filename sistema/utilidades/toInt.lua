local function toInt(bin)
	if type(bin) ~= "string" then
		error("Invalid input type")
	end

	bin = string.reverse(bin)
	local sum = 0
	local num = 0

	for i = 1, string.len(bin) do
		num = string.sub(bin, i,i) == "1" and 1 or 0
---@diagnostic disable-next-line: deprecated
		sum = sum + num * math.pow(2, i-1)
	end
	return sum
end

return toInt
