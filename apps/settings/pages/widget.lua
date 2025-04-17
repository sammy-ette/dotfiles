local beautiful = require 'beautiful'
local wibox = require 'wibox'
local util = require 'sys.util'

local M = {}

function M.titleWidget(text)
	return wibox.widget {
		widget = wibox.widget.textbox,
		font = beautiful.fontName .. ' Semibold 24',
		text = text
	}
end

function M.section(title, widgets)
	return wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = util.dpi(10),
		M.titleWidget(title),
		{
			layout = wibox.layout.fixed.vertical,
			spacing = util.dpi(15),
			table.unpack(widgets)
		}
	}
end

function M.subsection(title, widgets)
	return wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = util.dpi(3),
		title and {
			widget = wibox.widget.textbox,
			font = beautiful.fontName .. ' Semibold 16',
			--markup = helpers.colorize_text(title or '', beautiful.fg_sec),
			text = title
		} or nil,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = util.dpi(7),
			table.unpack(widgets)
		}
	}
end

return M
