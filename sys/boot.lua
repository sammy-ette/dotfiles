local initialized = awesome.get_xproperty 'initialized'
if initialized then return end

local awful = require 'awful'
local gears = require 'gears'
local rubato = require 'libs.rubato'
local wibox = require 'wibox'
local util = require 'sys.util'
local icon = require 'ui.widget.icon'

local scr = screen.primary
local loading = wibox.widget {
	widget = wibox.widget.slider,
	bar_shape = gears.shape.rounded_rect,
	bar_color = '#18181c',
	handle_color = '#ffffff',
	handle_shape = gears.shape.rounded_rect,
	handle_width = util.dpi(scr.geometry.width / 25),
}

local splash = wibox {
	ontop = true,
	visible = true,
	height = scr.geometry.height,
	width = scr.geometry.width,
	bg = '#000000',
	widget = {
		layout = wibox.container.place,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = util.dpi(24),
			icon {
				icon = 'fedora',
				color = '#ffffff',
				size = util.dpi(scr.geometry.width / 12)
			},
			{
				layout = wibox.container.constraint,
				strategy = 'exact',
				height = util.dpi(8),
				width = util.dpi(scr.geometry.width / 8),
				loading
			}
		}
	},
}

local loaderAnimator
local stop = false
loaderAnimator = rubato.timed {
	duration = 1.5,
	rate = 120,
	override_dt = true,
	subscribed = function(pos)
		loading.value = pos
		if stop then return end

		if pos == 100 then
			loaderAnimator.target = 0
		end
		if pos == 0 then
			loaderAnimator.target = 100
		end
	end,
	pos = 1
}
loaderAnimator.target = 100

local opacityAnimator = rubato.timed {
	duration = 1,
	rate = 120,
	subscribed = function(opacity)
		splash.opacity = opacity
		if opacity == 0 then
			splash.visible = false
		end
	end,
	pos = 1
}

awesome.connect_signal('paperbush::initialized', function()
	stop = true
	opacityAnimator.target = 0
end)
