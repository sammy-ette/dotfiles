local awful = require 'awful'
local wibox = require 'wibox'
local settings = require 'sys.settings'

awful.wallpaper {
	screen = s,
	widget = {
		{
			image = settings.getConfig 'wallpaper'.home.image,
			resize = true,
			widget = wibox.widget.imagebox
		},
		valign = 'center',
		halign = 'center',
		tiled = false,
		widget = wibox.container.tile
	}
}
