local settings = require 'sys.settings'
local gfs = require 'gears.filesystem'
require 'awful.autofocus'

-- Initialize settings stores
settings.defineType('wallpaper', {
	home = {
		tiled = false,
		acrossScreens = false,
		image = gfs.get_configuration_dir() .. 'wallpapers/meadows.jpg'
	},
	lock = {
		tiled = false,
		acrossScreens = false,
		image = gfs.get_configuration_dir() .. 'wallpapers/meadows.jpg'
	},
})

settings.defineType('bars', {
	{
		screen = 'all',
		height = 48,
		position = 'bottom',
		shape = 'rectangle',
		modules = {
			left = {
				'startMenu',
				'workspace',
				'apps'
			},
			center = {
				'music'
			},
			right = {
				'battery',
				'systray',
				'capslock',
				'quickSettings',
				'time',
				'layout'
			}
		}
	}
})

settings.defineType('quickSettings', {
	modules = {
		--'wifi',
		--'bluetooth'
		'battery',
		'compositor'
	}
})

require 'sys.theme'

if not awesome.__isPaperbushApp then
	require 'sys.boot'
	local compositor = require 'sys.compositor'

	settings.defineType('compositor', {
		enabled = true
	})

	local comp = settings.getConfig 'compositor'
	if comp.enabled then
		compositor.on()
	else
		compositor.off()
	end
	require 'sys.keys'
	require 'sys.layout'
	require 'sys.client'
	require 'sys.autostart'
	require 'sys.signal'
	require 'sys.battery'
	require 'sys.focus'

	local apps = require 'sys.apps'
	apps.register 'settings'
end

local command = require 'sys.command'
command.defaults()
