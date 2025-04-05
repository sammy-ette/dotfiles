local beautiful = require 'beautiful'
local gears = require 'gears'
local panels = require 'ui.panels'
local wibox = require 'wibox'
local util = require 'sys.util'

local icon = require 'ui.widget.icon'

local M = {}

function M.create(opts)
	local iconWidget = icon {
		icon = opts.icon,
	}

	local popup = panels.create {
		width = util.dpi(300),
		height = util.dpi(60),
		widget = {
			layout = wibox.layout.fixed.horizontal,
			{
				layout = wibox.container.constraint,
				strategy = 'exact',
				height = util.dpi(60),
				width = util.dpi(60),
				{
					widget = wibox.container.background,
					bg = beautiful.backgroundTertiary,
					{
						layout = wibox.container.margin,
						margins = util.dpi(16),
						iconWidget
					}
				}
			},
			{
				layout = wibox.container.place,
				{
					layout = wibox.container.margin,
					margins = util.dpi(12),
					opts.widget
				}
			}
		},
		attach = 'top_left'
	}

	local displayTimer = gears.timer {
		timeout = 2,
		single_shot = true,
		callback = function()
			popup:off()
		end
	}

	local oldOn = popup.on
	function popup:on()
		if popup.open then
			displayTimer:stop()
		end
		oldOn(popup)
		displayTimer:start()
	end

	function popup:setIcon(name)
		iconWidget.icon = name
	end

	return popup
end

return M
