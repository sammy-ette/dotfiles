local awful = require 'awful'
local gears = require 'gears'
local xr = require 'beautiful.xresources'

local M = {}

M.dpi = xr.apply_dpi

function M.rrect(rad)
	return function(c, width, height)
		gears.shape.rounded_rect(c, width, height, rad)
	end
end

function M.colorizeText(text, color)
	return '<span foreground="' .. color ..'">' .. text .. '</span>'
end

function M.findWidgetInWibox(widget, wb)
	local function find_widget_in_hierarchy(h, widget)
		if h:get_widget() == widget then
		return h
		end
		local result
		for _, ch in ipairs(h:get_children()) do
		result = result or find_widget_in_hierarchy(ch, widget)
		end
		return result
	end

	local w = wb._drawable._widget_hierarchy and find_widget_in_hierarchy(wb._drawable._widget_hierarchy, widget)
	if not w then return 0, 0 end

	local bx, by, width, height = w:get_matrix_to_device():transform_rectangle(0, 0, w:get_size())
	return bx, by, width, height
end

local function clamp(component)
	return math.min(math.max(component, 0), 255)
end

function M.invertColor(color, bw)
	local num = tonumber(color:sub(2), 16)
	local r = math.floor(num / 0x10000)
	local g = (math.floor(num / 0x100) % 0x100)
	local b = (num % 0x100)

	if bw then
		return (r * 0.299 + g * 0.587 + b * 0.114) > 186 and '#000000' or '#ffffff'
	end

	r = 0xff - math.floor(num / 0x10000)
	g = 0xff - (math.floor(num / 0x100) % 0x100)
	b = 0xff - (num % 0x100)

	return string.format('%#x', clamp(r) * 0x10000 + clamp(g) * 0x100 + clamp(b)):gsub('0x', '#')
end

function M.beautyVar(var)
	local beautiful = require 'beautiful'

	if type(var) == 'string' then
		return var:match '^#' and var or beautiful[var]
	end

	return var
end

function M.shiftColor(color, percent)
	local num = tonumber(color:sub(2), 16)
	local r = math.floor(num / 0x10000) + percent
	local g = (math.floor(num / 0x100) % 0x100) + percent
	local b = (num % 0x100) + percent

	return string.format('%#x', clamp(r) * 0x10000 + clamp(g) * 0x100 + clamp(b)):gsub('0x', '#')
end

function M.displayClickable(widget, opts)
	opts = opts or {}
	opts.shiftFactor = opts.shiftFactor or 15
	local bgWid = widget:get_children_by_id 'bg'[1]

	widget:connect_signal('mouse::enter', function ()
		bgWid.bg = M.shiftColor(opts.bg, opts.shiftFactor)
	end)

	widget:connect_signal('mouse::leave', function ()
		bgWid.bg = opts.bg
	end)
end

function M.spawn(cmd, cb)
	awful.spawn.easy_async(cmd, cb or function() end)
end

return M
