local battery = require 'ui.widget.volume'
local util = require 'sys.util'

return battery {
	size = util.dpi(20)
}
