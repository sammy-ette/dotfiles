local awful = require 'awful'
local gears = require 'gears'
local wibox = require 'wibox'
local settings = require 'sys.settings'

screen.connect_signal('request::wallpaper', function(s)
	awful.wallpaper {
		screen = s,
		widget = {
			{
				image = gears.surface.crop_surface {
					surface = gears.surface.load_uncached(settings.getConfig 'wallpaper'.home.image, gears.filesystem.get_configuration_dir() .. '/assets/lotus-wallpaper.png'),
					ratio = s.geometry.width/s.geometry.height,
				},
				resize = true,
				widget = wibox.widget.imagebox
			},
			valign = 'center',
			halign = 'center',
			tiled = settings.getConfig 'wallpaper'.home.tiled,
			widget = wibox.container.tile
		}
	}
end)

