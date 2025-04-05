local command = require 'sys.command'
local sound = require 'sys.sound'

command.add {
	name = 'audio:decrease-volume',
	action = function()
		sound.volumeDown()
	end
}

command.add {
	name = 'audio:increase-volume',
	action = function()
		sound.volumeUp()
	end
}
