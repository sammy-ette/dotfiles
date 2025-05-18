local gears = require 'gears'
local wibox = require 'wibox'

local M = gears.object {
	class = {
		on = true
	}
}

function M.toggle()
	M.on = not M.on
	M:emit_signal('toggle', M.on)

	return M.on
end

function M.init()
	return {
		icon = 'fedora',
		on = M.on,
		label = 'Label',
		page = wibox.widget {
			layout = wibox.container.place,
			{
				widget = wibox.widget.textbox,
				text = 'Hello World!'
			}
		}
	}
end

return M
