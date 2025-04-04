local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local util = require 'sys.util'
local button = require 'ui.widget.button'
local icon = require 'ui.widget.icon'

client.connect_signal('request::titlebars', function(c)
	if c.requests_no_titlebar then
		return
	end

	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal('request::activate', 'titlebar', {raise = true})
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal('request::activate', 'titlebar', {raise = true})
			awful.mouse.client.resize(c)
		end)
	)

	local minimize = button {
		icon = 'minimize',
	}
	local maximize = button {
		icon = 'expand-less',
	}
	local close = button {
		icon = 'close',
	}

	local spacing = util.dpi(8)

	awful.titlebar(c, {
		height = util.dpi(beautiful.titlebarHeight),
		bg_normal = beautiful.titlebarBackground,
		bg_focus = beautiful.titlebarBackground
	}):setup {
		layout = wibox.container.margin,
		left = spacing, right = spacing,
		{
			layout = wibox.layout.align.horizontal,
			{
				layout = wibox.layout.fixed.horizontal,
				buttons = buttons,
				spacing = spacing / 2,
				awful.titlebar.widget.iconwidget(c),
				{
					widget = awful.titlebar.widget.titlewidget(c),
					font = beautiful.fontName .. ' Medium 12',
				}
			},
			{
				buttons = buttons,
				layout = wibox.container.place
			},
			{
				widget = wibox.container.constraint,
				strategy = 'exact',
				width = util.dpi((18 * 3) + (spacing * 2)),
				{
					layout = wibox.layout.fixed.horizontal,
					minimize,
					maximize,
					close
				}
			}
		}
	}
end)
