local awful = require 'awful'
local gears = require 'gears'
local wibox = require 'wibox'
local settings = require 'sys.settings'

awful.screen.connect_for_each_screen(function(s)
	local configWallpaper = settings.getConfig 'wallpaper'.home.image
	if not gears.filesystem.file_readable(configWallpaper) then
		configWallpaper = gears.filesystem.get_configuration_dir() .. '/assets/lotus-wallpaper.png'
	end

	awful.wallpaper {
		screen = s,
		widget = {
			{
				image = gears.surface.crop_surface {
					surface = gears.surface.load_uncached(configWallpaper),
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

