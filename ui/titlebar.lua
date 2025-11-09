local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local util = require 'sys.util'
local button = require 'ui.widget.button'
local icon = require 'ui.widget.icon'
local command = require 'sys.command'

client.connect_signal('request::titlebars', function(c)
	if c.requests_no_titlebar then
		return
	end

	local buttons = gears.table.join(
		awful.button({}, 1, function()
			command.perform('client:move', {extras = {c}})
		end),
		awful.button({}, 3, function()
			command.perform('client:resize', {extras = {c}})
		end)
	)

	local buttonSize = util.dpi(20)
	local minimize = button {
		icon = 'minimize',
		onClick = function()
			command.perform('client:minimize', {extras = {c}})
		end,
		size = buttonSize,
		style = {
			bg = beautiful.titlebarBackground
		}
	}
	local maximize = button {
		icon = 'expand-less',
		onClick = function()
			command.perform('client:maximize', {extras = {c}})
		end,
		size = buttonSize,
		style = {
			bg = beautiful.titlebarBackground
		}
	}
	local close = button {
		icon = 'close',
		onClick = function()
			command.perform('client:close', {extras = {c}})
		end,
		size = buttonSize,
		style = {
			bg = beautiful.titlebarBackground
		}
	}

	local spacing = util.dpi(4)

	awful.titlebar(c, {
		size = util.dpi(beautiful.titlebarHeight),
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
				spacing = spacing,
				{
					layout = wibox.container.margin,
					margins = util.dpi(6),
					awful.titlebar.widget.iconwidget(c),
				},
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
				--width = util.dpi((18 * 3) + (spacing * 2)),
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
