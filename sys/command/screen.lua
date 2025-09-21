local awful = require 'awful'
local command = require 'sys.command'

local brightness = require 'sys.brightness'

command.add {
	name = 'screen:selection-screenshot',
	action = function()
		awful.spawn.with_shell '~/bin/ss'
	end
}

command.add {
	name = 'screen:window-screenshot',
	action = function()
		awful.spawn.with_shell '~/bin/ss window'
	end
}

command.add {
	name = 'screen:all-screenshot',
	action = function()
		awful.spawn.with_shell '~/bin/ss screen'
	end
}

command.add {
	name = 'screen:increase-brightness',
	action = brightness.up
}

command.add {
	name = 'screen:decrease-brightness',
	action = brightness.down
}
