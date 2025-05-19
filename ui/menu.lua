local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local util = require 'sys.util'
local button = require 'ui.widget.button'

local rubato = require 'libs.rubato'

local M = {}

function M.create(args)
	args.items = args.items or {}

	local menuItemLayout = wibox.layout.fixed.vertical()

	local panel = wibox.widget {
		layout = wibox.container.background,
		bg = args.bg or beautiful.background,
		shape = util.rrect(beautiful.radius),
		{
			layout = wibox.container.margin,
			margins = util.dpi(6),
			{
				layout = menuItemLayout,
				spacing = util.dpi(20),
				spacing_widget = {
					widget = wibox.container.margin,
					top = util.dpi(9), bottom = util.dpi(9),
					{
						widget = wibox.widget.separator,
						shape = gears.shape.rounded_bar,
						color = args.separator or beautiful.backgroundTertiary,
					}
				},
				table.unpack(args.items)
			}
		},
	}

	local menu = awful.popup {
		widget = panel,
		placement = awful.placement.top_left,
		visible = false,
		shape = util.rrect(beautiful.radius / 1.1),
		ontop = true,
		preferred_positions = 'bottom'
	}

	menu.items = args.items

	local shaper = util.rrect(beautiful.radius)
	local animator = rubato.timed {
		duration = 0.5,
		rate = 60,
		subscribed = function(p)
			menu.shape = function(cr, w, h)
				util.rrect(beautiful.radius / 1.1)(cr, w, h * (p / 100))
			end

			if p == 0 then
				menu.visible = false
			end
		end
	}

	function menu:show()
		if mouse.current_wibox then
			menu.bg = args.bg
		else
			menu.bg = '#00000000'
		end

		if args.parent then
			print(args.parent)
			local cb
			local wbx = mouse.current_wibox
			cb = function(b)
				print('from cur wibox visible signal')
				if not b.visible then
					menu:hide()
				end
				wbx:disconnect_signal('property::visible', cb)

				cb = nil
				wbx = nil

				collectgarbage()
				collectgarbage()
			end
			wbx:connect_signal('property::visible', cb)
			menu.x = wbx.x + mouse.current_widget_geometry.x - (menu.width * 0.25)
			menu.y = wbx.y + mouse.current_widget_geometry.y + mouse.current_widget_geometry.height
			awful.placement.no_offscreen(menu, {
				margins = beautiful.useless_gap + util.dpi(6)
			})
		else
			awful.placement.next_to_mouse(menu)
		end
		animator.target = 100
		menu.visible = true
		menu.open = true
	end

	function menu:hide()
		animator.target = 0
		menu.open = false
	end

	function menu:toggle()
		if not menu.open then
			print 'show menu'
			menu:show()
		else
			menu:hide()
		end
	end

	function menu:setItems(list)
		menuItemLayout:reset()
		menu.items = list

		for _, w in ipairs(list) do
			print('menu set item', w)
			menuItemLayout:add(w)
		end
	end

	return menu
end

function M.entry(args)
	args.align = 'left'
	return button(args)
end

function M.entries(list)
	local entryWidgets = wibox.layout.fixed.vertical()
	entryWidgets.spacing = util.dpi(4)

	for _, entry in ipairs(list) do
		print(entry.icon, entry.text)
		entryWidgets:add(M.entry {
			icon = entry.icon,
			text = entry.text,
			onClick = entry.onClick
		})
	end

	return entryWidgets
end

return M
