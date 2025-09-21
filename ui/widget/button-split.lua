local beautiful = require 'beautiful'
local gears = require 'gears'
local shape = require 'ui.shape'
local wibox = require 'wibox'

local util = require 'sys.util'
local button = require 'ui.widget.button'

local splitbutton = {mt = {}}

local function new(args)
	args = args or {}
	args.style = args.style or {
		bg = beautiful.background,
		active = beautiful.accent
	}

	local btn = button {
		icon = args.icon,
		iconSize = args.iconSize,
		style = args.style,
		click = args.click,
		type = 'toggle',
		shape = function (cr, w, h)
			shape.rounded_rect(cr, w, h, {
				tr = util.dpi(4),
				br = util.dpi(4),
				tl = true,
				bl = true
			}, beautiful.radius * 2)
		end
	}

	local arrowBtn = button {
		icon = 'arrow-right',
		width = util.dpi(32),
		style = args.style,
		shape = function (cr, w, h)
			shape.rounded_rect(cr, w, h, {
				tl = util.dpi(4),
				bl = util.dpi(4),
				tr = true,
				br = true
			}, beautiful.radius * 2)
		end,
		click = args.menuClick
	}

	local ret = {
		layout = wibox.layout.align.horizontal,
		nil,
		{
			layout = wibox.layout.margin,
			right = util.dpi(4),
			btn
		},
		arrowBtn
	}

	return ret
end

function splitbutton.mt:__call(...)
	return new(...)
end

return setmetatable(splitbutton, splitbutton.mt)
