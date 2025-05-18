local button = require 'ui.widget.button'
local util = require 'sys.util'
local quickSettings = require 'ui.panels.quickSettings'

return button {
	icon = 'quickSettings',
	onClick = function() quickSettings:toggle {
		context = 'mouse'
	} end,
	size = util.dpi(20)
}
