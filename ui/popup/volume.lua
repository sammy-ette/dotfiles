local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local popup = require 'ui.popup'
local util = require 'sys.util'

local textbox = require 'ui.widget.textbox'
local volumeMeter = wibox.widget {
	widget = wibox.widget.slider,
	bar_color = beautiful.backgroundTertiary,
	bar_active_color = beautiful.accent,
	bar_shape = gears.shape.rounded_rect,
	handle_shape = gears.shape.rounded_rect,
	handle_color = beautiful.accent,
	handle_width = util.dpi(10),
	forced_height = util.dpi(6)
}
local volumeText = wibox.widget {
	widget = textbox,
	color = beautiful.foreground,
}

local volume = popup.create {
	icon = 'volume',
	widget = {
		layout = wibox.layout.fixed.horizontal,
		spacing = util.dpi(6),
		volumeText,
		{
			layout = wibox.container.place,
			{
				layout = wibox.container.constraint,
				height = util.dpi(6),
				strategy = 'exact',
				volumeMeter
			}
		},
	}
}

awesome.connect_signal('sys::volume', function(vol, muted, init)
	volume:setIcon(muted and 'volume-muted' or 'volume')
	volumeMeter.value = vol
	volumeText.text = string.format('%d%%', vol)

	if not init then volume:on() end
end)
