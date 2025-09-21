local awful = require 'awful'
local beautiful = require 'beautiful'
local util = require 'sys.util'
local icon = require 'ui.widget.icon'

local volume = {mt = {}}

local function new(opts)
	local icon = icon {icon = 'volume', size = opts.size}
	local tt = awful.tooltip {
		objects = {icon},
		preferred_alignments = {'middle'},
		mode = 'outside',
		margins = util.dpi(4),
		gaps = beautiful.useless_gap / 1.5,
		bg = beautiful.backgroundSecondary,
		fg = beautiful.foreground
	}

	local function setState(volume, muted, init)
		tt.text = string.format('%d%% volume%s', volume, muted and ' (muted)' or '')
		icon.icon = muted and 'volume-muted' or 'volume'
	end

	awesome.connect_signal('sys::volume', setState)

	return icon
end

function volume.mt:__call(...)
	return new(...)
end

return setmetatable(volume, volume.mt)
