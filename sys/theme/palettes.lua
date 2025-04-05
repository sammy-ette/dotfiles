local themes = {
	['harmony'] = require 'sys.theme.harmony'
}

local M = {}

function copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

for key, theme in pairs(themes) do
	for kk, vars in pairs(theme) do
		if kk ~= 'base' then
			--print(kk)
			local merged = copy(theme.base)
			for themeKey, themeVar in pairs(vars) do
				merged[themeKey] = themeVar
			end
			--print(key .. ':' .. kk)
			M[key .. ':' .. kk] = merged
		end
	end
end

return M
