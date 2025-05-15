local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local button = require 'ui.widget.button'
local icon = require 'ui.widget.icon'
local util = require 'sys.util'
local rubato = require 'libs.rubato'

--    baseSize = iconSize     + margins * 2 (left and right)
local baseSize = util.dpi(18) + (util.dpi(6) * 2)
return function(scr)
	local systray = wibox.widget.systray()
	local expandIcon = icon {
		icon = 'expand-more',
	}

	systray:set_base_size(util.dpi(18))
	local open = false
	local w = wibox.widget {
		widget = wibox.container.constraint,
		strategy = 'exact',
		height = util.dpi(18),
		{
			widget = wibox.container.background,
			bg = beautiful.backgroundTertiary,
			shape = util.rrect(beautiful.radius),
			{
				widget = wibox.container.margin,
				margins = util.dpi(6),
				{
					layout = wibox.layout.stack,
					{
						layout = wibox.container.place,
						halign = 'left',
						systray,
					},
					{
						layout = wibox.container.place,
						halign = 'right',
						{
							widget = wibox.container.rotate,
							direction = 'east',
							expandIcon,
						}
					},
				}
			}
		}
	}

	systray.visible = true

	local animator = rubato.timed {
		duration = 0.5,
		pos = baseSize,
		easing = rubato.easing.quadratic,
		subscribed = function(wi)
			w.width = wi
			if wi == baseSize then
				systray.visible = false
			end
		end
	}

	systray.visible = true

	local iconSize = util.dpi(18)
	local function setWidgetSize()
		if awesome.systray() ~= 0 then
			local expandWidth = baseSize + (iconSize * awesome.systray()) + (beautiful.systray_icon_spacing * awesome.systray())
			systray.forced_width = expandWidth
			animator.target = expandWidth
		end
	end

	systray:connect_signal('widget::layout_changed', function()
		if open then
			setWidgetSize()
		end
	end)

	w.buttons = {
		awful.button({}, 1, function()
			--systray:emit_signal 'systray::update'
			print(awesome.systray())
			if not open then
				systray.forced_height = util.dpi(18)
				setWidgetSize()
				systray.visible = true
				expandIcon.icon = 'expand-less'
			else
				animator.target = baseSize
				expandIcon.icon = 'expand-more'
			end
			open = not open
		end)
	}

	return w
end
