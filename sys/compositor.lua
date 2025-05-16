local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'

awesome.register_xproperty('picomPid', 'number')

local M = {
	running = false,
	awesomeKill = false,
	pid = awesome.get_xproperty 'picomPid'
}

if M.pid then
	M.running = true
end

function M.on()
	local pid = awful.spawn.easy_async(string.format('picom --config %s.dist/picom.conf', gears.filesystem.get_configuration_dir()), function()
		if M.awesomeKill then
			awesome.emit_signal 'compositor::off'
			M.awesomeKill = false
			return
		end
		M.on()
	end)
	M.running = true
	M.setPid(pid)
	awesome.emit_signal 'compositor::on'

	return true
end

function M.off()
	M.awesomeKill = true
	if M.pid then
		awful.spawn.easy_async(string.format('kill %d', M.pid), function() end)
		M.running = false
		M.setPid(nil)
	end

	return false
end

function M.toggle(on)
	if not M.running then
		print 'turning on compositor'
		return M.on()
	else
		print 'turning off compositor'
		return M.off()
	end
end

function M.setPid(pid)
	if pid then
		awesome.set_xproperty('picomPid', pid)
	end
	M.pid = pid
end

awesome.connect_signal('exit', M.off)

return M
