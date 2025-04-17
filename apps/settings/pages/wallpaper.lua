local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local settings = require 'sys.settings'
local util = require 'sys.util'
local button = require 'ui.widget.button'

local page = require 'apps.settings.page'
local pageWidgets = require 'apps.settings.pages.widget'
local imageFileExts = {
	'*.jpg', '*.jpeg',
	'*.png'
}

local wallpaper = settings.getConfig 'wallpaper'
local homeWallpaper = wibox.widget {
	widget = wibox.widget.imagebox,
	clip_shape = util.rrect(beautiful.radius),
	image = wallpaper.home.image
}

local lockWallpaper = wibox.widget {
	widget = wibox.widget.imagebox,
	clip_shape = util.rrect(beautiful.radius),
	image = wallpaper.lock.image
}

local function restrict(w)
	return wibox.widget {
		layout = wibox.container.constraint,
		width = util.dpi(280),
		w
	}
end

page.add {
	name = 'Wallpaper',
	icon = 'wallpaper',
	widget = {
		pageWidgets.section('Wallpaper', {
			pageWidgets.subsection('Home', {
				restrict(homeWallpaper),
				button {
					icon = 'wallpaper',
					text = 'Choose Wallpaper',
					click = function()
						awful.spawn.with_line_callback(string.format('zenity --file-selection --file-filter="Images | %s ")', table.concat(imageFileExts, ' ')), {
							stdout = function(out)
								if out:match '^/' then
									homeWallpaper.image = out
									wallpaper.home.image = out
									settings.write 'wallpaper'

									awful.spawn.easy_async(string.format([[ awesome-client "
										local settings = require 'sys.settings'
										local wallpaper = settings.getConfig 'wallpaper'
										wallpaper.home.image = out
										for s in screen do
											--s:emit_signal 'request::wallpaper'
										end
									"]], out), function() 
									end)
								end
							end
						})
					end
				}
			}),
			pageWidgets.subsection('Lock', {
				restrict(lockWallpaper)
			})
		})
	}
}
