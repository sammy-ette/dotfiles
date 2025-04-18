local gfs = require 'gears.filesystem'
local settings = require 'sys.settings'
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
			center = {},
			right = {
				'systray',
				'capslock',
				'time',
				'layout'
			}
		}
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
	end
	require 'sys.keys'
	require 'sys.layout'
	require 'sys.client'
	require 'sys.autostart'
	require 'sys.signal'

	local apps = require 'sys.apps'
	apps.register 'settings'
end

local command = require 'sys.command'
command.defaults()


