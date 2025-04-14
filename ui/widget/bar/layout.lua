local awful = require 'awful'
local wibox = require 'wibox'
local util = require 'sys.util'

return function(scr)
	return wibox.widget {
		layout = wibox.container.constraint,
		strategy = 'exact',
		width = util.dpi(16),
		{
			layout = wibox.container.place,
			awful.widget.layoutbox(scr)
		}
	}
end
