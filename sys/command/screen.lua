local awful = require 'awful'
local command = require 'sys.command'

command.add {
	name = 'screen:selection-screenshot',
	action = function()
		awful.spawn.with_shell '~/bin/ss'
	end
}
