local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'

local apps = require 'sys.apps'
local util = require 'sys.util'

apps.init()

require 'apps.settings.pages'
local page = require 'apps.settings.page'

local realPageWidget = wibox.widget {
	widget = wibox.container.background,
	bg = beautiful.backgroundTertiary,
	shape = util.rrect(beautiful.radius),
	page.widget
}

local root = wibox.widget {
	layout = wibox.layout.ratio.horizontal,
	spacing = util.dpi(16),
	{
		widget = wibox.container.background,
		bg = beautiful.backgroundSecondary,
		shape = util.rrect(beautiful.radius),
		{
			layout = wibox.container.margin,
			margins = util.dpi(12),
			page.generateList()
		}
	},
	realPageWidget,
}

awesome.connect_signal('page::update', function()
	local overflowLayout = wibox.layout.overflow.vertical()
	overflowLayout.scrollbar_width = util.dpi(10)

	realPageWidget.children = {
		wibox.widget {
			layout = wibox.container.margin,
			left = util.dpi(16), right = util.dpi(16),
			top = util.dpi(6), bottom = util.dpi(6),
			{
				widget = overflowLayout,
				step = util.dpi(150),
				spacing = util.dpi(16),
				table.unpack(page.widget)
			}
		}
	}

	overflowLayout.scrollbar_widget = {
		widget = wibox.widget.separator,
		shape = gears.shape.rounded_bar,
		color = beautiful.accent
	}
end)
local sideAmnt = 0.25
root:adjust_ratio(1, 0, sideAmnt, 1 - sideAmnt)
page.switch('Theme')

local box = wibox {
	width = 683,
	height = 384,
	bg = beautiful.background,
	widget = {
		widget = wibox.container.margin,
		margins = util.dpi(16),
		root
	},
	visible = true,
	decorated = true,
	resizable = true,
	title = 'Settings',
}

box:connect_signal('property::visible', function()
	require 'awexygen'.app.request_exit()
end)
