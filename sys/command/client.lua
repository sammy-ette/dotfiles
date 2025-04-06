local command = require 'sys.command'
local gears = require 'gears'

command.add {
	name = 'client:focus',
	action = function(c)
		c:activate { raise = true }
	end
}

command.add {
	name = 'client:move',
	action = function(c)
		c:activate { raise = true, action = 'mouse_move'  }
	end
}

command.add {
	name = 'client:resize',
	action = function(c)
		c:activate { raise = true, action = 'mouse_resize'  }
	end
}

command.add {
	name = 'client:maximize',
	action = function(c)
		c.maximized = not c.maximized
		c:raise()
	end
}

command.add {
	name = 'client:minimize',
	action = function(c)
		gears.timer.delayed_call(function() c.minimized = true end)
	end
}

command.add {
	name = 'client:close',
	action = function(c)
		c:kill()
	end
}

command.add {
	name = 'client:fullscreen',
	action = function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end
}
