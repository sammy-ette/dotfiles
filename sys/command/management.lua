local awful = require 'awful'
local command = require 'sys.command'

command.add {
	name = 'layout:next',
	action = function()
		awful.layout.inc(1)
	end
}

command.add {
	name = 'layout:previous',
	action = function()
		awful.layout.inc(-1)
	end
}
