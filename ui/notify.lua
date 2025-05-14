local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local naughty = require 'naughty'

local icon = require 'ui.widget.icon'
local panels = require 'ui.panels'
local rubato = require 'libs.rubato'
local sound = require 'sys.sound'
local util = require 'sys.util'
local textbox = require 'ui.widget.textbox'

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

local briefTimeout = 4.5
local briefInitSize = util.dpi(32)
local scr = awful.screen.focused()
local briefNotifMaxSize = scr.geometry.width / 3.5
local briefNotifFullSize = briefInitSize

local briefIcon = icon {
	color = beautiful.panelBackground,
	size = briefInitSize,
}

local briefTitle = wibox.widget {
	widget = textbox,
	font = beautiful.fontName .. ' Bold',
	text = '',
	opacity = 0,
	id = 'title'
}
local briefMessage = wibox.widget {
	widget = textbox,
	ellipsize = 'middle',
	text = '',
	opacity = 0,
	id = 'message'
}

local briefMargins = util.dpi(5)
local briefSpacing = util.dpi(6)
local briefNotif = panels.create {
	shape = gears.shape.rounded_bar,
	fakeShape = util.rrect(14),
	width = briefInitSize,
	height = briefInitSize,
	method = 'pos',
	widget = {
		widget = wibox.container.margin,
		--margins = util.dpi(6),
		id = 'margins',
		{
			layout = wibox.container.place,
			halign = 'left',
			valign = 'center',
			{
				layout = wibox.layout.fixed.horizontal,
				--spacing = -briefSpacing / 2,
				{
					layout = wibox.container.background,
					bg = beautiful.accent,
					shape = gears.shape.circle,
					{
						widget = wibox.container.margin,
						margins = util.dpi(2),
						briefIcon
					}
				},
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = briefSpacing,
					{
						widget = wibox.container.constraint,
						width = briefNotifMaxSize / 2.5,
						briefTitle
					},
					briefMessage
				}
			}
		}
	},
	attach = 'top'
}
local briefMargin = briefNotif.widget:get_children_by_id 'margins'[1]
local briefNotifAnimator = rubato.timed {
	duration = 0.5,
	rate = 120,
	override_dt = true,
	subscribed = function(w)
		local scale = (math.max(0, w - briefInitSize)/math.max(1, briefNotifFullSize - briefInitSize))
		briefNotif.width = w
		briefMargin.margins = briefMargins * scale
		briefTitle.opacity = scale
		briefMessage.opacity = scale
		briefNotif:align(true)
	end,
	pos = briefInitSize,
	easing = rubato.easing.quadratic
}

function briefNotif:revealed()
	local briefTitleW = math.min(briefTitle:get_preferred_size(awful.screen.focused().index), briefNotifMaxSize / 2.5)
	local briefMessageW = briefMessage:get_preferred_size(awful.screen.focused().index)

	local briefNotifPreferredSize = briefMargins + briefInitSize + briefSpacing + briefTitleW + briefSpacing + briefMessageW + briefSpacing + briefMargins
	briefNotifFullSize = math.min(briefNotifMaxSize, briefNotifPreferredSize)
	briefNotifAnimator.target = briefNotifFullSize
end

local fullHideTimer = gears.timer {
	timeout = briefTimeout + 0.5,
	single_shot = true,
	callback = function()
		briefNotif:off()
	end
}
local displayTimer = gears.timer {
	timeout = briefTimeout,
	single_shot = true,
	callback = function()
		briefNotifAnimator.target = briefInitSize
	end
}

local function briefNotify()
	if displayTimer.started then
		displayTimer:stop()
		fullHideTimer:stop()
	end

	displayTimer:start()
	fullHideTimer:start()
	briefNotif:on()
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

	local fullscreenClient = false
	for _, c in ipairs(awful.screen.focused().selected_tag:clients()) do
		if c.fullscreen then
			fullscreenClient = true
		end
	end

	if fullscreenClient then
		briefIcon.icon = category or 'notification'
		briefTitle.text = notification.title
		briefMessage.text = notification.text:gsub('(.+)%.(.+)%.(.+)\n\n', ''):gsub('\n', ' ')
		briefNotify()
		return
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
											clip_shape = util.rrect(beautiful.radius / 2),
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
