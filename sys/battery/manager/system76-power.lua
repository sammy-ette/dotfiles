local p = require 'dbus_proxy'
local proxy = p.Proxy:new {
	bus = p.Bus.SYSTEM,
	name = 'com.system76.PowerDaemon',
	interface = 'com.system76.PowerDaemon',
	path = '/com/system76/PowerDaemon'
}
local M = {}

function M.performanceProfile()
	proxy:Performance()
end

function M.powerSaveProfile()
	proxy:Battery()
end

function M.balancedProfile()
	proxy:Balanced()
end

function M.profile(pretty)
	local profile = proxy:GetProfile()
	if pretty then
		return profile == 'Battery' and 'Power Saver' or profile
	end

	if profile == 'Battery' then return 'powerSave' end
	if profile == 'Balanced' then return 'balanced' end
	if profile == 'Performance' then return 'performance' end
end

return M
