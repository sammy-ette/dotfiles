local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local popup = require 'ui.popup'
local util = require 'sys.util'

local volumeMeter = wibox.widget {
	widget = wibox.widget.slider,
	bar_color = beautiful.backgroundTertiary,
	bar_active_color = beautiful.accent,
	bar_shape = gears.shape.rounded_rect,
	handle_shape = gears.shape.rounded_rect,
	handle_color = beautiful.accent,
	handle_width = util.dpi(10)
}

local volume = popup.create {
	icon = 'volume',
	widget = {
		layout = wibox.container.constraint,
		height = util.dpi(6),
		volumeMeter
	}
}

awesome.connect_signal('sys::volume', function(vol, muted, init)
	volume.icon = muted and 'volume-muted' or 'volume'
	volumeMeter.value = vol

	if vol >= 100 then
		volumeMeter.bar_color = beautiful.accent
	else
		volumeMeter.bar_color = beautiful.backgroundTertiary
	end

	if not init then volume:on() end
end)
