local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local util = require 'sys.util'

local icon = require 'ui.widget.icon'
local textbox = require 'ui.widget.textbox'

local M = {
	pages = {},
	pageIndexes = {},
	active = '',
	widget = wibox.widget.base.empty_widget()
}

function M.add(opts)
	opts.icon = opts.icon or 'settings'
	assert(opts.name, 'name for settings page is required')
	assert(opts.widget, 'page widget is required')

	table.insert(M.pages, opts)
	M.pageIndexes[opts.name] = #M.pages
end

function M.switch(name)
	local page = M.pages[M.pageIndexes[name]]
	assert(page, 'attempt to switch to an unknown page')

	M.widget = page.widget
	M.active = name
	awesome.emit_signal 'page::update'
	print 'switching'
	print(M.active)
	print(M.widget)
	awesome.emit_signal 'page::update'
end

function M.generateList()
	local list = wibox.layout.overflow.vertical()
	list.step = util.dpi(100)
	list.scrollbar_widget = {
		widget = wibox.widget.separator,
		shape = gears.shape.rounded_bar,
		color = beautiful.accent
	}
	list.scrollbar_width = util.dpi(10)

	for _, page in pairs(M.pages) do
		print 'gen layout'
		print(page.name, M.active)
		local label = wibox.widget {
			widget = textbox,
			text = page.name
		}

		local pageActivator = wibox.widget {
			layout = wibox.container.background,
			shape = util.rrect(12),
			--bg = M.active == page.name and '#ffae23' or beautiful.backgroundSecondary,
			{
				layout = wibox.container.margin,
				margins = util.dpi(8),
				{

					layout = wibox.layout.fixed.horizontal,
					spacing = util.dpi(6),
					icon {
						icon = page.icon,
						size = util.dpi(24)
					},
					label
				}
			}
		}
		awesome.connect_signal('page::update', function()
			if M.active == page.name then
				pageActivator.bg = beautiful.accent
				--label.color = beautiful.accent
			else
				pageActivator.bg = beautiful.backgroundSecondary
				--label.color = beautiful.foreground
			end
		end)
		pageActivator.buttons = {
			awful.button({}, 1, function()
				M.switch(page.name)
			end)
		}

		list:add(pageActivator)
	end

	return list
end
return M
