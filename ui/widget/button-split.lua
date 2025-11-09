local beautiful = require 'beautiful'
local gears = require 'gears'
local shape = require 'ui.shape'
local wibox = require 'wibox'

local util = require 'sys.util'
local button = require 'ui.widget.button'

local splitbutton = {mt = {}}

function splitbutton:set_state(state)
	print 'state called'
	print(state)
	self.btn.state = state
	self.arrowBtn.state = state
end

local function new(args)
	args = args or {}
	args.style = args.style or {
		bg = beautiful.background,
		active = beautiful.accent
	}

	local ret
	local btn = button {
		icon = args.icon,
		iconSize = args.iconSize,
		style = args.style,
		click = function (state)
				ret.arrowBtn.state = state
			if args.click then
				args.click(state)
			end
		end,
		radius = args.radius,
		shape = function (rad)
			return function (cr, w, h)
				shape.rounded_rect(cr, w, h, {
					tr = util.dpi(4),
					br = util.dpi(4),
					tl = true,
					bl = true
				}, rad)
			end
		end
	}

	local arrowBtn = button {
		icon = 'arrow-right',
		width = util.dpi(32),
		style = args.style,
		radius = args.radius,
		shape = function (rad)
			return function (cr, w, h)
				shape.rounded_rect(cr, w, h, {
					tl = util.dpi(4),
					bl = util.dpi(4),
					tr = true,
					br = true
				}, rad)
			end
		end,
		click = args.menuClick
	}

	ret = {
		layout = wibox.layout.align.horizontal,
		nil,
		{
			layout = wibox.container.margin,
			right = util.dpi(4),
			btn
		},
		arrowBtn
	}

	gears.table.crush(ret, splitbutton)
	ret.btn = btn
	ret.arrowBtn = arrowBtn

	return ret
end

function splitbutton.mt:__call(...)
	return new(...)
end

return setmetatable(splitbutton, splitbutton.mt)
