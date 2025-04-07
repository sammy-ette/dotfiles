local awful = require 'awful'
local command = require 'sys.command'

for i = 1, 9 do
	command.add {
		name = 'tag:go-to-' .. tostring(i),
		action = function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end
	}
end
