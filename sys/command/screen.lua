local awful = require 'awful'
local command = require 'sys.command'

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
