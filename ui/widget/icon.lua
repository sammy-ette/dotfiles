local beautiful = require 'beautiful'
local gears = require 'gears'
local gtable = require 'gears.table'
local util = require 'sys.util'

local constraint = require 'wibox.container.constraint'
local place = require 'wibox.container.place'

local imagebox = require 'wibox.widget.imagebox'

local icon = {mt = {}}

function icon:set_icon(name)
	self._private.icon = icon
	if not name then
		self._private.imagebox.image = nil
		return
	end

	self._private.imagebox.image = gears.filesystem.get_configuration_dir() .. '/assets/icons/' .. name .. '.svg'
end

function icon:set_color(color)
	self._private.color = color
	self._private.imagebox.stylesheet = string.format([[
		* {
			fill: %s;
		}
	]], util.beautyVar(color))
	self._private.imagebox:emit_signal 'widget::redraw_needed'
end

function icon:set_shape(shape)
	if shape then
		self._private.imagebox.clip_shape = shape
	end
end
function icon:set_makeup(v)
	self._private.makeup = v
end

function icon:set_size(size)
end

local function new(ico, args)
	if type(ico) == 'string' then
		args.icon = ico
	elseif type(ico) == 'table' then
		args = ico
	end
	args.size = args.size or util.dpi(18)

	local ib = imagebox()
	local ret = constraint(place(ib), 'exact', args.size, args.size)
	gtable.crush(ret, icon, true)

	ret._private.imagebox = ib

	ret:set_icon(args.icon)
	ret:set_shape(args.shape)
	ret:set_color(args.color or 'foreground')

	awesome.connect_signal('makeup::put_on', function() ret:set_color(ret._private.makeup or ret._private.color) end)

	return ret
end

function icon.mt:__call(...)
	return new(...)
end

return setmetatable(icon, icon.mt)
