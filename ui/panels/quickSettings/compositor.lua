local gears = require 'gears'
local compositor = require 'sys.compositor'

local M = gears.object {}

awesome.connect_signal('compositor::on', function()
	M:emit_signal('toggle', compositor.running)
end)

awesome.connect_signal('compositor::off', function()
	M:emit_signal('toggle', compositor.running)
end)

function M.toggle()
	return compositor.toggle()
end

function M.init()
	return {
		icon = 'compositor',
		on = compositor.running,
		label = 'Compositor',
	}
end

return M
