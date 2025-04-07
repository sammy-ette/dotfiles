local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'

local workspacePanel = require 'ui.panels.workspaces'
local util = require 'sys.util'

return function(scr)
	local t = scr.selected_tag
	local indicator = wibox.widget {
		widget = wibox.widget.textbox,
	}
	local w = wibox.widget {
		widget = wibox.container.background,
		shape = util.rrect(beautiful.dpi),
		bg = beautiful.backgroundTertiary,
		{
			layout = wibox.container.margin,
			margins = util.dpi(6),
			indicator
		}
	}
	w.buttons = {
		awful.button({}, 1, function()
			workspacePanel:toggle()
		end)
	}

	local function updateText()
		indicator.text = t.name ~= tostring(t.index) and string.format('Workspace %d (%s)', t.index, t.name) or string.format('Workspace %d', t.index)
	end
	updateText()

	tag.connect_signal('property::selected', updateText)
	return w
end
