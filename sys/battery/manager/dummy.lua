local M = {}

function M.performanceProfile()
end

function M.powerSaveProfile()
end

function M.balancedProfile()
end

function M.profile(pretty)
	if pretty then
		return 'None'
	end

	return 'none'
end

return M
