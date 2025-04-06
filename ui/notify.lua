local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local naughty = require 'naughty'
local util = require 'sys.util'
local sound = require 'sys.sound'

local icon = require 'ui.widget.icon'

local categoryMappings = {
	['drive-removable-media'] = 'usb',
	['system.warning'] = 'warning'
}

local skip = {
	['device.added'] = true,
	['device.removed'] = true,
}

local function categoryToIcon(cat)
	local mapping = categoryMappings[cat]
	return mapping or cat
end

naughty.connect_signal('request::display', function(notification)
	if skip[notification.category] == true then return end

	sound.notify()
	notification.timeout = 5

	-- todo: transform category to icons
	-- i dont want *my* svg icons to match to 
	-- "network.connected" so use a table to map to names in the future
	-- this is used in the harmony codebase and actually conforms to the svg names.
	local category = categoryToIcon(notification.category)
	local notifImage
	if notification.app_icon then
		if notification.app_icon:match 'file://' or notification.app_icon:match '^/' then
			notifImage = notification.app_icon:gsub('file://', '')
		else
			category = categoryToIcon(notification.app_icon)
		end
	end
	if category and not gears.filesystem.file_readable(gears.filesystem.get_configuration_dir() .. '/assets/icons/' .. category .. '.svg') then
		naughty.notification {
			title = 'Missing Icon Mapping',
			text = string.format('Category %s does not have a mapping for notifications.', category),
			category = 'warning'
		}
	end
	
	local icoWidget = icon {
		icon = category or 'notification',
		size = util.dpi(32),
		color = beautiful.foregroundSecondary
	}
	local spacing = util.dpi(16)

	local notifActions = wibox.layout.fixed.horizontal()
	notifActions.spacing = util.dpi(8)
	--[[
	for _, action in ipairs(notification.actions) do
		local btn = w.button {
			text = action.name,
			bg = beautiful.xcolor10,
			font = beautiful.fontName .. ' Medium 12',
			shiftFactor = -25,
			onClick = function()
				action:invoke(notification)
			end,
			margin = util.dpi(4),
			height = util.dpi(28)
		}

		notifActions:add(btn)
	end
	]]--

	if true then
		
		--return
	end

	naughty.layout.box {
		notification = notification,
		border_width = 0,
		bg = '#00000000',
		shape = util.rrect(beautiful.radius / 1.2),
		widget_template = {
			widget = wibox.container.background,
			bg = beautiful.backgroundSecondary,
			shape = util.rrect(beautiful.radius),
			{
				widget = wibox.container.constraint,
				strategy = 'min',
				width = beautiful.notificationWidth,
				height = beautiful.notificationHeight,
				{
					layout = wibox.layout.fixed.horizontal,
					{
						widget = wibox.container.constraint,
						strategy = 'exact',
						width = util.dpi(85),
						height = beautiful.notificationHeight,
						{
							widget = wibox.container.background,
							bg = beautiful.backgroundTertiary,
							{
								layout = wibox.container.place,
								icoWidget
							}
						}
					},
					{
						widget = wibox.container.margin,
						margins = spacing,
						{
							layout = wibox.container.place,
							{
								layout = wibox.layout.fixed.horizontal,
								spacing = util.dpi(16),
								notifImage and {
									widget = wibox.container.place,
									{
										widget = wibox.container.constraint,
										strategy = 'exact',
										width = beautiful.notificationWidth / 5,
										{
											widget = wibox.widget.imagebox,
											clip_shape = helpers.rrect(beautiful.radius / 2),
											image = gears.surface.load_uncached_silently(notifImage)
										}
									}
								} or nil,
								{
									layout = wibox.layout.fixed.vertical,
									spacing = util.dpi(8),
									{
										layout = wibox.layout.fixed.horizontal,
										spacing = util.dpi(4),
										notification.image and {
											widget = wibox.container.place,
											{
												widget = wibox.container.constraint,
												strategy = 'exact',
												width = util.dpi(24),
												--height = beautiful.notificationHeight,
												--[[{
													widget = naughty.widget.icon,
													clip_shape = gears.shape.circle
												}]]--
												{
													widget = wibox.widget.imagebox,
													clip_shape = gears.shape.circle,
													image = notification.image
												}
												--notification.clients[1] and awful.titlebar.widget.iconwidget(notification.clients[1]) or nil,
											}
										} or nil,
										{
											widget = wibox.container.constraint,
											width = beautiful.notificationWidth,
											height = util.dpi(24),
											{
												widget = wibox.widget.textbox,
												markup = notification.title,
												font = beautiful.fontName .. ' Bold 14',
											},
										}
									},
									{
										widget = wibox.container.constraint,
										width = beautiful.notificationWidth,
										height = beautiful.notificationHeight,
										{
											widget = naughty.widget.message,
											font = beautiful.fontName .. ' Regular 14',
										},
									},
									notifActions
								}
							}
						}
					}
				}
			}
		}
	}
end
)
