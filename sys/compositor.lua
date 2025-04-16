local awful = require 'awful'
local beautiful = require 'beautiful'

awesome.register_xproperty('picomPid', 'number')

local M = {
	running = false,
	awesomeKill = false,
	pid = awesome.get_xproperty 'picomPid'
}


awful.spawn.easy_async('pgrep picom', function(output)
	if output ~= '' then
		M.running = true
	end
end)

function M.state()
	return M.running
end

function M.on()
	awesome.emit_signal 'compositor::on'
	local pid = awful.spawn.easy_async(string.format('picom', os.getenv 'USER', beautiful.picom_conf), function()
		if M.awesomeKill then
			awesome.emit_signal 'compositor::off'
			M.awesomeKill = false
			return
		end
		M.on(true)
	end)
	M.running = true
	M.setPid(pid)

	return true
end

function M.off()
	M.awesomeKill = true
	if M.pid and M.pid ~= -1 then
		awful.spawn.easy_async(string.format('kill %d', M.pid), function() end)
		M.running = false
		M.setPid(-1)
	end

	return false
end

function M.toggle(on)
	if not M.running or on then
		return M.on()
	else
		return M.off()
	end
end

function M.setPid(pid)
	if pid ~= -1 then
		awesome.set_xproperty('picomPid', pid)
	end
	M.pid = pid
end

awesome.connect_signal('exit', M.off)

return M
