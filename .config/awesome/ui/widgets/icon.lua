local beautiful = require 'beautiful'
local gtable = require 'gears.table'
local makeup = require 'ui.makeup'
local helpers = require 'helpers'

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

	self._private.imagebox.image = beautiful.config_path .. '/images/icons/' .. name .. '.svg'
end

function icon:set_color(color)
	self._private.color = color
	self._private.imagebox.stylesheet = string.format([[
		* {
			fill: %s;
		}
	]], helpers.beautyVar(color))
	self._private.imagebox:emit_signal 'widget::redraw_needed'
end

function icon:set_makeup(v)
	self._private.makeup = v
end

function icon:set_size(size)
	self.height = size
	self.width = size
end

local function new(ico, args)
	if type(ico) == 'string' then
		args.icon = ico
	elseif type(ico) == 'table' then
		args = ico
	end
	args.size = args.size or beautiful.dpi(18)

	local ib = imagebox()
	local ret = place(constraint(ib, args.size_strategy or 'exact', args.size, args.size))
	gtable.crush(ret, icon, true)

	ret._private.imagebox = ib

	ret:set_icon(args.icon)
	ret:set_color(args.color or 'fg_normal')

	awesome.connect_signal('makeup::put_on', function() ret:set_color(ret._private.makeup or ret._private.color) end)

	return ret
end

function icon.mt:__call(...)
	return new(...)
end

return setmetatable(icon, icon.mt)
