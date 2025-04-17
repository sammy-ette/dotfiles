local awful = require 'awful'
local beautiful = require 'beautiful'
local gtable = require 'gears.table'
local gears = require 'gears'
local shape = require 'gears.shape'
local util = require 'sys.util'

local fixed = require 'wibox.layout.fixed'
local margin = require 'wibox.container.margin'
local place = require 'wibox.container.place'

local background = require 'wibox.container.background'
local constraint = require 'wibox.container.constraint'
local icon = require 'ui.widget.icon'
local imagebox = require 'wibox.widget.imagebox'
local textbox = require 'wibox.widget.textbox'
local widget = require 'wibox.widget'

return function(icon, opts)
	local opts = opts or {}
	if type(icon) == 'table' then
		opts = icon
	else
		opts.icon = icon
	end

	opts.color = opts.color or 'foreground'

	local focused = false
	local ico = widget {
		layout = constraint,
		height = opts.height,
		width = opts.height,
		strategy = 'exact',
		{
			id = 'bg',
			--widget = makeup.putOn(background, {bg = opts.bgcolor or opts.bg}, {wibox = opts.parentWibox}),
			widget = background,
			shape = opts.shape or (opts.text and util.rrect(6) or gears.shape.circle),
			{
				widget = margin,
				margins = opts.margin or opts.margins or util.dpi(2),
				{
					layout = place,
					halign = opts.align or 'center',
					{
						layout = fixed.horizontal,
						spacing = util.dpi(4),
						(opts.icon ~= '' and opts.icon ~= nil) and {
							layout = place,
							valign = 'center',
							halign = 'center',
							align = 'center',
							{
								widget = constraint,
								width = opts.size and opts.size + 2 or util.dpi(18),
								{
									widget = imagebox,
									stylesheet = string.format([[
										* {
											fill: %s;
										}
									]], util.beautyVar(opts.makeup or opts.color)),
									image = gears.filesystem.get_configuration_dir() .. '/assets/icons/' .. opts.icon .. '.svg',
									id = 'icon'
								},
							},
						} or nil,
						{
							widget = textbox,
							markup = util.colorizeText(opts.text or '', util.beautyVar(opts.textColor or opts.color)),
							font = opts.font or beautiful.font:gsub('%d+$', opts.fontSize or 14),
							id = 'textbox',
							valign = 'center'
						}
					}
				}
			}
		}
	}
	--util.displayClickable(ico, opts)

	local function setupIcon()
		--ico:get_children_by_id'icon'[1].image = gears.color.recolor_image(ico:get_children_by_id'icon'[1].image, focused and beautiful.fg_normal .. 55 or beautiful.fg_normal)
		ico:emit_signal 'widget::redraw_needed'
	end

	ico:connect_signal('mouse::enter', function()
		focused = true
		setupIcon()
	end)
	ico:connect_signal('mouse::leave', function()
		focused = false
		setupIcon()
	end)

	ico.visible = true
	local realWid
	realWid = setmetatable({}, {
		__index = function(_, k)
			return ico[k]
		end,
		__newindex = function(_, k, v)
			if k == 'icon' then
				ico:get_children_by_id'icon'[1].image = gears.color.recolor_image(gears.filesystem.get_configuration_dir() .. '/assets/icons/' .. v .. '.svg', beautiful.fg_normal)
				ico:emit_signal 'widget::redraw_needed'
			elseif k == 'color' then
				local icon = ico:get_children_by_id'icon'[1]
				opts.color = v
				if icon then
					icon.stylesheet = string.format([[
						* {
							fill: %s;
						}
					]], util.beautyVar(opts.iconColor or opts.color))
					ico:emit_signal 'widget::redraw_needed'
				end
			elseif k == 'text' then
				ico:get_children_by_id'textbox'[1].markup = util.colorizeText(v, util.beautyVar(opts.textColor or opts.color))
			elseif (k == 'onClick' or k == 'click') and type(v) == 'function' then
				realWid.buttons = {
					awful.button({}, 1, function()
						v(realWid)
					end),
				}
			elseif k == 'makeup' then
				opts.makeup = v
			end
			ico[k] = v
		end
	})
	realWid.buttons = {
		awful.button({}, 1, function()
			if opts.onClick then opts.onClick(realWid) end
			if opts.click then opts.click(realWid) end
		end),
	}

	return realWid
end
