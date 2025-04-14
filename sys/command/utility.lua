local awful = require 'awful'
local command = require 'sys.command'

command.add {
	name = 'utility:open-terminal',
	action = function()
		-- TODO: make this configurable
		awful.spawn 'tym'
	end
}
