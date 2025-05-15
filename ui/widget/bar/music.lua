local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local rubato = require 'libs.rubato'
local util = require 'sys.util'
local icon = require 'ui.widget.icon'

local infoText = wibox.widget {
	widget = wibox.widget.textbox,
	text = 'Artist - Title '
}

local wid = wibox.widget {
	layout = wibox.container.background,
	bg = beautiful.backgroundTertiary,
	shape = function(cr, w, h)
		local s = util.rrect(beautiful.radius)
		return s(cr, w / 2, h)
	end,
	visible = false,
	{
		layout = wibox.container.margin,
		margins = util.dpi(4),
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = util.dpi(4),
			icon {
				icon = 'music'
			},
			infoText
		}
	}
}

local animator = rubato.timed {
	duration = 0.6,
	rate = 120,
	override_dt = true,
	subscribed = function(p)
		--print 'sex'
		local shape = util.rrect(beautiful.radius)
		wid.shape = function(cr, w, h)
			print(w, h)
			shape(cr, w * (p/100), h)
		end

		if p == 0 then
			wid.visible = false
		end
	end,
}

local function reveal()
	print 'revealing'
	wid.visible = true
	wid:emit_signal 'widget::redraw_needed'
	animator.target = 100
end

local function hide()
	print 'hiding'
	animator.target = 0
end

awesome.connect_signal('paperbush::music', function(metadata)
	infoText.markup = string.format('%s — %s ', metadata.artist, metadata.title)
	if not wid.visible then
		reveal()
	end
end)

awesome.connect_signal('paperbush::musicDone', function()
	if wid.visible then
		hide()
	end
end)

local inactiveTimer = gears.timer {
	--timeout = 5 * 60, -- 5 minutes to seconds
	timeout = 2,
	single_shot = true,
	callback = function()
		hide()
	end
}
awesome.connect_signal('paperbush::musicPlayingState', function(playing)
	print(playing)
	if playing then
		inactiveTimer:stop()
		if not wid.visible then
			reveal()
		end
	else
		inactiveTimer:start()
	end
end)

return wibox.widget {
	layout = wibox.container.constraint,
	--width = util.dpi(256),
	wid
}
