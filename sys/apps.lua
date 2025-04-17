local awful = require 'awful'
local gears = require 'gears'

local M = {
	names = {}
}

function M.register(name)
	table.insert(M.names, name)
end

function M.run(name)
	if not M.names[name] then
		error(string.format('app %s is not registered', name))
	end

	local confDir = gears.filesystem.get_configuration_dir()
	awful.spawn.easy_async(string.format('%slibs/awexygen/awexygen %sapps/%s/init.lua', confDir, name, confDir), function() end)
end

function M.init()
	awesome.__isPaperbushApp = true
	awesome.conffile = io.popen [[ awesome-client 'return awesome.conffile' ]]:read '*a':match('"(.+)"')
	require 'sys'
end

return M
