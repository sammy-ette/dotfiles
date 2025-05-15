local awful = require 'awful'
local battery = require 'sys.battery'
local beautiful = require 'beautiful'
local cairo = require 'lgi'.cairo
local colorM = require 'sys.color'
local util = require 'sys.util'
local gears = require 'gears'
local widget = require 'wibox.widget'

local constraint = require 'wibox.container.constraint'
local place = require 'wibox.container.place'
local stack = require 'wibox.layout.stack'

local imagebox = require 'wibox.widget.imagebox'
local icon = require 'ui.widget.icon'

local bat = {mt = {}}

local function new(opts)
	local background = icon {icon = 'battery', size = opts.size, color = beautiful.foregroundSecondary}
	local indicator = widget {
		widget = imagebox,
	}

	local wid = widget {
		layout = constraint,
		strategy = 'exact',
		width = opts.size,
		{
			layout = place,
			{
				layout = stack,
				background,
				indicator
			}
		}
	}

	local tt = awful.tooltip {
		objects = {wid},
		preferred_alignments = {'middle'},
		mode = 'outside',
		margins = util.dpi(4),
		gaps = beautiful.useless_gap / 1.5,
		bg = beautiful.backgroundSecondary,
		fg = beautiful.foreground
	}

	local function handleBattery()
		local state = battery.status()
		local batIcon = 'battery'
		local color = beautiful.foreground

		local time = battery.time()
		if time ~= '' then time = '\n' .. time end
		local text = string.format('%d%% on battery%s', battery.percentage(), time)
		print(state)
		local percentage = state ~= 'None' and battery.percentage() or 100

		if battery.profile() == 'powerSave' then
			--batIcon = 'battery-saver'
			color = colorM.shift(beautiful.color3, 25)
		end

		if battery.percentage() <= 20 then
			--batIcon = 'battery-critical'
			color = beautiful.color1
		end

		if state == 'Charging' then
			--batIcon = 'battery-charging'
			color = beautiful.color2
		elseif state == 'Full' then
			text = 'Full'
		elseif state == 'None' then
			batIcon = 'battery-none'
		end

		if state ~= 'None' then
			tt.text = text
		else
			tt.text = 'No Battery'
		end
	
		local batteryImg = gears.color.recolor_image(string.format('%s/assets/icons/%s.svg', gears.filesystem.get_configuration_dir(), batIcon), color)
		local img = cairo.ImageSurface.create(cairo.Format.ARGB32, batteryImg:get_width(), batteryImg:get_height())
		local cr = cairo.Context(img)
		cr:rectangle(0, batteryImg:get_height() - (batteryImg:get_height() * (percentage / 100)), batteryImg:get_width(), (batteryImg:get_height() * (percentage / 100)))
		cr:clip()
		cr:set_source_surface(batteryImg, 0, 0)
		cr:paint()

		indicator.image = img
	end
	handleBattery()
	awesome.connect_signal('battery::percentage', handleBattery)

	if battery.status() == 'None' then return nil end

	return wid
end

function bat.mt:__call(...)
	return new(...)
end

return setmetatable(bat, bat.mt)
