local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local icon = require 'ui.widget.icon'
local textbox = require 'ui.widget.textbox'
local util = require 'sys.util'
local capslock = require 'sys.signal.capslock'

local w = wibox.widget {
	widget = wibox.container.margin,
	top = util.dpi(2), bottom = util.dpi(2),
	{
		widget = wibox.container.background,
		bg = util.invertColor(beautiful.background),
		shape = util.rrect(beautiful.radius),
		{
			widget = wibox.container.margin,
			margins = util.dpi(6),
			{
				layout = wibox.layout.fixed.horizontal,
				icon {
					icon = 'caps-on',
					color = util.invertColor(beautiful.foreground)
				},
				--[[
				{
					widget = textbox,
					color = util.invertColor(beautiful.foreground),
					text = 'Caps is on'
				}
				]]
			}
		}
	}
}
w.visible = false

capslock.state(function(state)
	w.visible = state
end)

awesome.connect_signal('caps::state', function(on)
	w.visible = on
end)

return w
