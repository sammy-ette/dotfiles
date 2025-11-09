local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local util = require 'sys.util'
local wibox = require 'wibox'
local rubato = require 'libs.rubato'

local icon = require 'ui.widget.icon'

local button = {mt = {}}

function button:set_click(fun)
	self._private.click = fun
end

function button:get_click()
	return self._private.click
end

function button:set_type(typ)
	self._private.type = typ
end

function button:get_type(typ)
	return self._private.type
end

function button:set_colors(colors)
	self._private.colors = colors
	self._private.widgets.background.bg = colors.bg
end

function button:get_colors()
	return self._private.colors
end

function button:activate()
	if self._private.click then
		self._private.click(self._private.state)
	end
	self._private.state = not self._private.state

	self:colorize()
end

function button:set_state(state)
	print 'state called, but button'
	print(state)
	self._private.state = state
	self:colorize()
end

function button:colorize()
	if self._private.type == 'toggle' then
		if self.animator then
			self.animator.target = self._private.state and beautiful.radius or 32
		end
		self._private.widgets.background.bg = self._private.state and self._private.colors.active or self._private.colors.bg
	end
end


local function new(args)
	args = args or {}
	local ico = icon {
		icon = args.icon or 'fedora',
		size = args.iconSize
	}

	local background = wibox.container.background()

	local ret = wibox.widget {
		layout = wibox.container.constraint,
		width = args.size or args.width,
		height = args.size or args.height,
		strategy = 'exact',
		{

			layout = background,
			shape = (args.shape or util.rrect)(args.radius or 32),
			{
				layout = wibox.container.place,
				ico
			}
		}
	}

	gears.table.crush(ret, button)
	ret._private.widgets = {
		background = background
	}
	ret._private.state = false

	ret.click = args.click or args.onClick
	ret.type = args.type or 'normal'
	ret.colors = args.style or {
		bg = beautiful.background,
		active = beautiful.accent
	}
	ret.buttons = {
		awful.button({}, 1, function()
			ret:activate()
		end)
	}

	if args.type == 'toggle' then
		ret.animator = rubato.timed {
			duration = 0.2,
			rate = 120,
			override_dt = true,
			subscribed = function(rad)
				ret._private.widgets.background.shape = (args.shape or util.rrect)(rad)
			end,
			pos = args.radius or 32
		}
	end

	return ret
end

function button.mt:__call(args)
    return new(args)
end

return setmetatable(button, button.mt)
