require 'ui.wallpaper'
require 'ui.bar'
require 'ui.titlebar'
require 'ui.popup.all'
require 'ui.notify'

local menu = require 'ui.menu'
local m = menu.create {}
m:setItems({
	menu.entries {
		{
			icon = 'fedora',
			text = 'Test Item'
		},
		{
			icon = 'fedora',
			text = 'Test Item 2'
		}
	}
})

local command = require 'sys.command'
command.add {
	name = 'system:right-click-menu',
	action = function()
		m:show()
	end
}

