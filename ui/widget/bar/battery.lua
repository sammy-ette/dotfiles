local battery = require 'ui.widget.battery'
local util = require 'sys.util'

return battery {
	size = util.dpi(20)
}
