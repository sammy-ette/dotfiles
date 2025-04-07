local gfs = require 'gears.filesystem'
local settings = require 'sys.settings'
require 'awful.autofocus'

-- Initialize settings stores
settings.defineType('wallpaper', {
	home = {
		tiled = false,
		acrossScreens = false,
		image = gfs.get_configuration_dir() .. 'wallpapers/aster.png'
	},
	lock = {
		tiled = false,
		acrossScreens = false,
		image = gfs.get_configuration_dir() .. 'wallpapers/aster.png'
	},
})

settings.defineType('theme', {
	name = 'harmony',
	type = 'dark'
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
				'workspace'
			},
			center = {},
			right = {
				'capslock',
				'time'
			}
		}
	}
})

require 'sys.theme'
require 'sys.boot'

local command = require 'sys.command'
command.defaults()

require 'sys.keys'
require 'sys.layout'
require 'sys.client'
require 'sys.signal'
require 'sys.autostart'
