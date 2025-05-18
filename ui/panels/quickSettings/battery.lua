local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local battery = require 'sys.battery'

local icon = require 'ui.widget.icon'
local textbox = require 'ui.widget.textbox'
local linegraph = require 'ui.widget.linegraph'
local util = require 'sys.util'

local M = gears.object {
	class = {
		on = true
	}
}

local percentText = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.fontName .. ' Bold 36',
	text = string.format('%d%%', math.floor(battery.percentage())),
	valign = 'bottom',
}

local statusText = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.fontName .. ' Medium 14',
	text = 'Not Charging',
	valign = 'top'
}

local percentBar = wibox.widget {
	widget = wibox.widget.progressbar,
	background_color = beautiful.backgroundTertiary,
	color = beautiful.accent,
	shape = gears.shape.rounded_rect,
	forced_height = util.dpi(16),
	value = battery.percentage(),
	max_value = 100
}

local function setStatus(s)
	if s == 'Discharging' then
		statusText.text = 'Not Charging'
	else
		statusText.text = s
	end

	if s == 'Charging' then
		percentBar.color = beautiful.color2
	elseif s == 'Full' then
		percentBar.color = beautiful.color4
	elseif battery.percentage() > 20 then
		percentBar.color = beautiful.foreground
	else
		percentBar.color = beautiful.color1
	end
end
setStatus(battery.status())

awesome.connect_signal('battery::status', setStatus)
awesome.connect_signal('battery::percentage', function(percent)
	percentText.text = string.format('%d%%', math.floor(percent))
	percentBar.value = math.floor(battery.percentage())
end)

local time = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.fontName .. ' Medium 12',
	--text = battery.time(),
	valign = 'top'
}

awesome.connect_signal('battery::time', function(t, timeNum)
	if timeNum == 0 or battery.status() == 'Full' then
		if battery.status() == 'Full' then
			time.text = ''
		else
			time.text = 'Calculating time...'
		end

		return
	end

	time.text = t
end)

local powerProfile = wibox.widget {
	layout = wibox.layout.align.horizontal,
	{
		widget = wibox.layout.fixed.vertical,
		{
			widget = wibox.widget.textbox,
			font = beautiful.fontName .. ' Bold 14',
			text = 'Power Profile'
		},
		{
			widget = textbox,
			text = 'Which power profile to use',
			font = beautiful.fontName .. ' Normal 12',
			color = beautiful.foregroundSecondary
		}
	},
	nil,
	{
		widget = wibox.layout.fixed.horizontal,
		{
			widget = textbox,
			text = battery.profile(true),
			font = beautiful.fontName .. ' SemiBold 12',
			color = beautiful.foregroundSecondary
		},
		icon {
			icon = 'expand-more',
			color = beautiful.foregroundSecondary,
			size = util.dpi(24)
		}
	}
}

local batteryGraph = linegraph {
	color = beautiful.backgroundTertiary,
	fill_color = beautiful.color4 .. 80,
	max = 100,
	min = 0,
	fill = true
}
batteryGraph:set_values(battery.history(function(p)
	batteryGraph:add_value(p)
end))

function M.init()
	return {
		icon = 'battery',
		on = true,
		label = 'Battery',
		page = wibox.widget {
			layout = wibox.layout.fixed.vertical,
			spacing = util.dpi(40),
			spacing_widget = {
				widget = wibox.widget.separator,
				thickness = util.dpi(3),
				color = beautiful.backgroundTertiary
			},
			{
				layout = wibox.layout.fixed.vertical,
				spacing = util.dpi(16),
				{
					layout = wibox.layout.fixed.vertical,
					percentText,
					statusText
				},
				percentBar,
				time
			},
			{
				layout = wibox.layout.fixed.vertical,
				spacing = util.dpi(16),
				powerProfile,
				{
					layout = wibox.layout.fixed.vertical,
					{
						widget = wibox.widget.textbox,
						text = 'Battery Graph',
						font = beautiful.fontName .. ' SemiBold 14',
					},
					{
						widget = textbox,
						text = 'Usage since last full charge',
						font = beautiful.fontName .. ' SemiNormal 12',
						color = beautiful.foregroundSecondary
					}
				},
				{
					layout = wibox.layout.fixed.horizontal,
					{
						widget = wibox.widget.separator,
						thickness = util.dpi(3),
						color = beautiful.backgroundTertiary,
						orientation = 'vertical',
						forced_width = util.dpi(3)
					},
					{layout = wibox.layout.fixed.vertical,
					{
						layout = wibox.container.margin,
						margins = util.dpi(8),
						batteryGraph,
					}},
					
						{
							widget = wibox.widget.separator,
							thickness = util.dpi(3),
							color = beautiful.backgroundTertiary,
							forced_height = util.dpi(3)
						},
				}
			}
		}
	}
end

function M.toggle() end
return M
