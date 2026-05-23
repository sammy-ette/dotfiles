local command = require 'sys.command'
local sound = require 'sys.sound'
local music = require 'sys.signal.music'

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

command.add {
	name = 'audio:toggle-mute',
	action = function()
		sound.toggleMute()
	end
}

command.add {
	name = 'audio:toggle-play',
	action = function()
		music.togglePlay()
	end
}

command.add {
	name = 'audio:next',
	action = function()
		music.next()
	end
}

command.add {
	name = 'audio:previous',
	action = function()
		music.previous()
	end
}
