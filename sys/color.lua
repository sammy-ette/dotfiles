local M = {}

local function clamp(component)
	return math.min(math.max(component, 0), 255)
end

function M.shift(color, percent)
	local num = tonumber(color:sub(2), 16)
	local r = math.floor(num / 0x10000) + percent
	local g = (math.floor(num / 0x100) % 0x100) + percent
	local b = (num % 0x100) + percent

	return string.format('%#x', clamp(r) * 0x10000 + clamp(g) * 0x100 + clamp(b)):gsub('0x', '#')
end

return M
