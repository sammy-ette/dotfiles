local command = require 'sys.command'
local switcher = require 'libs.switcher'

command.add {
	name = 'system:app-switcher',
	action = function(opts)
		switcher.switch( 1, opts.modifiers[1], 'Alt_L', 'Shift', opts.key)
	end
}
