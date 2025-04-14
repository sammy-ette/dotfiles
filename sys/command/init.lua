local naughty = require 'naughty'
local M = {
	list = {}
}

function M.add(args)
	assert(args.name, 'Name is required for a command')
	assert(args.action, 'Action callback is required for a command')

	M.list[args.name] = args
end

function M.perform(name, ...)
	local cmd = M.list[name]
	if cmd then
		--return pcall(cmd.action)
		cmd.action(...)
	else
		naughty.notify {
			title = name,
			text = 'attempt to perform unknown command',
			category = 'warning'
		}
	end
end
function M.get(name)
	return M.list[name]
end

function M.defaults()
	for _, name in ipairs {
		'audio',
		'client',
		'management',
		'tag',
		'utility'
	} do
		require('sys.command.' .. name)
	end
end

return M
