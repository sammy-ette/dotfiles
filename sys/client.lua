local awful = require 'awful'
local gears = require 'gears'
local ruled = require 'ruled'
local extrautils = require 'libs.extrautils'()

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

client.connect_signal('manage', function(c)
	restrictHeight(c)
	if not awesome.startup then awful.client.setslave(c) end

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
end)

client.connect_signal('request::geometry', function(c)
	restrictHeight(c)
	awful.placement.no_offscreen(c)
end)
