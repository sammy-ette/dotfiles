local awful = require 'awful'
local gears = require 'gears'
local ruled = require 'ruled'
local extrautils = require 'libs.extrautils'()
local compositor = require 'sys.compositor'
local beautiful = require 'beautiful'

ruled.client.connect_signal('request::rules', function()
	ruled.client.append_rule {
		id = 'global',
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen,
		}
	}

	ruled.client.append_rule {
		id = 'titlebar',
		rule_any = {
			type = {
				'normal',
				'dialog'
			}
		},
		properties = {
			titlebars_enabled = true
		}
	}
end)

local function restrictHeight(c)
	if c:geometry().height > c.screen.workarea.height and not c.fullscreen then
		c:geometry {
			height = c.screen.workarea.height
		}
	end
end

function setShape(c, doShape)
	if not doShape then
		c.shape = nil
	elseif beautiful.clientShape then
		c.shape = beautiful.clientShape
	end
end

client.connect_signal('manage', function(c)
	restrictHeight(c)
	if not awesome.startup then awful.client.setslave(c) end

	if c.sticky then
		c.floating = true
		c.focusable = false
		c.ontop = true
		--c.above = true
	end

	if not c.maximized and not c.fullscreen then
		awful.placement.centered(c, {parent = c.transient_for or c.screen or awful.screen.focused()})
	end

	if c.maximized and not c.fullscreen then
		awful.placement.maximize(c, {
			honor_padding = true,
			honor_workarea = true,
			--margins = beautiful.useless_gap * beautiful.dpi(2)
		})
	end

	local cairo = require('lgi').cairo
	local default_icon = extrautils.apps.lookup_icon 'application-x-executable'
	if c and c.valid and not c.icon then
		local s = gears.surface(default_icon)
		local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s:get_width(), s:get_height())
		local cr = cairo.Context(img)
		cr:set_source_surface(s, 0, 0)
		cr:paint()
		c.icon = img._native
	end

	setShape(c, not compositor.running)
	
end)

client.connect_signal('request::geometry', function(c)
	restrictHeight(c)
	awful.placement.no_offscreen(c)

	local scr = c.screen
	if not scr then return end

	local geom = c:geometry()
	if geom.width >= scr.geometry.width and geom.height >= scr.geometry.height then
		setShape(c, false)
	end
end)

awesome.connect_signal('compositor::off', function()
	for _, c in ipairs(client.get()) do
		if not c.fullscreen then
			c.shape = beautiful.clientShape
		end
	end
end)

awesome.connect_signal('compositor::on', function()
	for _, c in ipairs(client.get()) do
		c.shape = nil
	end
end)

client.connect_signal('property::fullscreen', function(c)
	if c.fullscreen then
		c.shape = nil
	else
		c.shape = compositor.state() and nil or beautiful.clientShape
	end
end)
