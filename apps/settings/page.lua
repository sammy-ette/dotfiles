local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local util = require 'sys.util'

local icon = require 'ui.widget.icon'

local M = {
	pages = {},
	pageIndexes = {},
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
	awesome.emit_signal 'page::update'
	print 'switching'
	print(M.widget)
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
		local pageActivator = wibox.widget {
			layout = wibox.layout.fixed.horizontal,
			spacing = util.dpi(6),
			icon {
				icon = page.icon,
				size = util.dpi(24)
			},
			{
				widget = wibox.widget.textbox,
				text = page.name
			}
		}
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
