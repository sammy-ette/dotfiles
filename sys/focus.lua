local awful = require 'awful'
local gears = require 'gears'

local M = {
	client = nil,
	panels = {}
}

M.timer = gears.timer {
	timeout = 100,
	autostart = false,
	callback = function()
		M.client = nil
	end
}

local function startFocus(c)
	print 'setting focus'
	M.client = c
	if M.timer.started then
		M.timer:stop()
	end
	M.timer:start()
end

client.disconnect_signal('request::activate', awful.permissions.activate)
client.connect_signal('button::press', startFocus)
client.connect_signal('mouse::move', startFocus)

client.connect_signal('request::activate', function(c, context, hints)
	if (context == 'rules') then
		print 'activate from rule'
		print(M.timer.started, (M.client and M.client.valid or true))
		if not M.timer.started or (M.client and not M.client.valid) then
			print 'activated'
			awful.permissions.activate(c, context, hints)
		else
			--awful.permissions.urgent(c, true)
		end
		startFocus(c)
	else
		print ('activate from something else: ' .. (context or 'no context'))
		awful.permissions.activate(c, context, hints)
	end
end)

function M.open(opts)
	assert(opts.attachment, 'panel attachment is required')
	assert(opts.closer, 'closer function is required')

	
	local currentPanel = M.panels[opts.attachment]
	if currentPanel then
		currentPanel.closer()
	end

	M.panels[opts.attachment] = opts
end

function M.close(opts)
	assert(opts.attachment, 'panel attachment is required')
	M.panels[opts.attachment] = nil
end

function M.autoHide(hider)
	client.connect_signal('button::press', hider)
	awful.mouse.append_global_mousebinding(awful.button {
		button = awful.button.names.LEFT,
		on_click = hider
	})
end

return M
