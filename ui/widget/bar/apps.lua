local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'

local command = require 'sys.command'
local rubato = require 'libs.rubato'
local util = require 'sys.util'

return function(screen)
		local baseClientIndicator = {
		height = util.dpi(3),
		width = util.dpi(3)
	}
	local clientIndicatorShift = util.dpi(14)
	
	return awful.widget.tasklist {
		screen = screen,
		filter = function(c, scr)
			local cur = awful.widget.tasklist.filter.currenttags(c, scr)
			if cur then
				return c.focusable
			end

			return false
		end,
		buttons = gears.table.join(
			awful.button({}, 1, function (c)
				if c == client.focus then
					command.perform('client:minimize', c)
				else
					command.perform('client:focus', c)
				end
			end)
		),
		layout = {
			layout = wibox.layout.fixed.horizontal,
			spacing = util.dpi(8)
		},
		style = setmetatable({}, {
			__index = function(_, k)
				local styles = {
					bg_normal = beautiful.shade3,
					bg_focus = beautiful.accent,
					bg_minimize = beautiful.shade1,
					shape = util.rrect(6)
				}

				return styles[k]
			end
		}),
		widget_template = {
			widget = wibox.container.place,
			{
				layout = wibox.layout.fixed.vertical,
				spacing = util.dpi(4),
				{
					layout = wibox.container.constraint,
					strategy = 'exact',
					width = util.dpi(26.5),
					{
						layout = wibox.container.place,
						{
							awful.widget.clienticon,
							id = 'clienticon',
							--margins = util.dpi(4),
							widget = wibox.container.margin
						},
					},
				},
				{
					layout = wibox.container.margin,
					bottom = -4,
					{
						layout = wibox.container.place,
						{
							wibox.widget.base.make_widget(),
							id = 'background_role',
							forced_width = baseClientIndicator.width,
							forced_height = baseClientIndicator.height,
							widget = wibox.container.background,
						}
					}
				},
			},
			create_callback = function(self, c)
				self:connect_signal('mouse::enter', function()
					awesome.emit_signal('bling::task_preview::visibility', s, true, c)
				end)
				self:connect_signal('mouse::leave', function()
					awesome.emit_signal('bling::task_preview::visibility', s, false, c)
				end)

				local bgW = self:get_children_by_id 'background_role'[1]
				local animator = rubato.timed {
					intro = 0.02,
					duration = 0.25,
					override_dt = false,
					pos = baseClientIndicator.width,
					subscribed = function(w)
						bgW.forced_width = w
					end
				}

				function self.update()
					if client.focus == c then
						animator.target = baseClientIndicator.width + clientIndicatorShift
					else
						animator.target = baseClientIndicator.width
					end
				end

				self.update()
			end,
			update_callback = function(self)
				self.update()
			end
			}
	}
end
