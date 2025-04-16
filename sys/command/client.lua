local command = require 'sys.command'
local gears = require 'gears'

command.add {
	name = 'client:focus',
	action = function(opts)
		local c = opts.extras[1]
		c:activate { raise = true }
	end
}

command.add {
	name = 'client:move',
	action = function(opts)
		local c = opts.extras[1]
		c:activate { raise = true, action = 'mouse_move'  }
	end
}

command.add {
	name = 'client:resize',
	action = function(opts)
		local c = opts.extras[1]
		c:activate { raise = true, action = 'mouse_resize'  }
	end
}

command.add {
	name = 'client:maximize',
	action = function(opts)
		local c = opts.extras[1]
		c.maximized = not c.maximized
		c:raise()
	end
}

command.add {
	name = 'client:minimize',
	action = function(opts)
		local c = opts.extras[1]
		gears.timer.delayed_call(function() c.minimized = true end)
	end
}

command.add {
	name = 'client:close',
	action = function(opts)
		local c = opts.extras[1]
		c:kill()
	end
}

command.add {
	name = 'client:fullscreen',
	action = function(opts)
		local c = opts.extras[1]
		c.fullscreen = not c.fullscreen
		c:raise()
	end
}

for i = 1, 9 do
	command.add {
		name = 'client:move-to-' .. tostring(i),
		action = function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end
	}
end
