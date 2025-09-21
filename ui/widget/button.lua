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

function button:set_style(style)
	self._private.style = style
	self._private.widgets.background.bg = style.bg
end

function button:activate()
	self._private.click()
	self._private.state = not self._private.state

	if self._private.type == 'normal' then return end
	if self._private.type == 'toggle' then
		if self.animator then
			self.animator.target = self._private.state and beautiful.radius or 32
		end
		self._private.widgets.background.bg = self._private.state and self._private.style.active or self._private.style.bg
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
			shape = args.shape or util.rrect(32),
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
	ret.style = args.style or {
		bg = '#00000000',
		active = beautiful.accent
	}
	ret.buttons = {
		awful.button({}, 1, function()
			ret:activate()
		end)
	}

	if args.type == 'toggle' and not args.shape then
		ret.animator = rubato.timed {
			duration = 0.2,
			rate = 120,
			override_dt = true,
			subscribed = function(rad)
				ret._private.widgets.background.shape = util.rrect(rad)
			end,
			pos = 32
		}
	end

	return ret
end

function button.mt:__call(args)
    return new(args)
end

return setmetatable(button, button.mt)
