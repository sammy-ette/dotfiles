local beautiful = require 'beautiful'
local wibox = require 'wibox'
local util = require 'sys.util'

local titlebar = {mt = {}}

function new(opts)
	opts = opts or {}

	local titleText = wibox.widget {
		text = opts.title,
		font = beautiful.fontName .. ' Bold 12',
		widget = wibox.widget.textbox
	}

	local w = wibox.widget {
		widget = wibox.container.constraint,
		strategy = 'exact',
		height = util.dpi(beautiful.titlebarHeight),
		{
			widget = wibox.container.background,
			bg = beautiful.shade2,
			id = 'bg',
			{
				widget = wibox.container.margin,
				top = util.dpi(4), bottom = util.dpi(4),
				left = util.dpi(16), right = util.dpi(16),
				{
					layout = wibox.layout.align.horizontal,
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = util.dpi(8),
						opts.before,
						titleText,
					},
					nil,
					opts.after
				}
			}
		}
	}

	function w:text(t)
		titleText.text = t
	end

	return w, util.dpi(beautiful.titlebarHeight)
end

function titlebar.mt:__call(...)
	return new(...)
end

return setmetatable(titlebar, titlebar.mt)
