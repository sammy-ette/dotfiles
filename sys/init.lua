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

settings.defineType('theme', {
	name = 'harmony',
	type = 'dark'
})

settings.migrate('theme', {
	version = 2,
	migrator = function(conf)
		conf.accent = 'color6'
		--conf.set('accent', 'color6')
	end
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

require 'sys.boot'
require 'sys.theme'

local compositor = require 'sys.compositor'

settings.defineType('compositor', {
	enabled = true
})

local comp = settings.getConfig 'compositor'
if comp.enabled then
	compositor.on()
end

local command = require 'sys.command'
command.defaults()

require 'sys.keys'
require 'sys.layout'
require 'sys.client'
require 'sys.signal'
require 'sys.autostart'
