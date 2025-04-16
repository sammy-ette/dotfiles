local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'

local lgi = require 'lgi'
local Gio = lgi.Gio

local util = require 'sys.util'
local power = require 'sys.power'
local command = require 'sys.command'
local extrautils = require 'libs.extrautils'()
local fzy = require 'fzy'

local titlebar = require 'ui.widget.titlebar'
local panels = require 'ui.panels'
local textbox = require 'ui.widget.textbox'
local button = require 'ui.widget.button'
local icon = require 'ui.widget.icon'
local startMenu

local apps = {}
local appsIndexes = {}
local appList = wibox.widget {
	layout = wibox.layout.overflow.vertical()
}

-- [[ App search ]] --
local searchInputPlaceholder = wibox.widget {
	widget = textbox,
	text = 'Search...',
	font = beautiful.fontName .. ' Bold',
	color = beautiful.foregroundSecondary
}

local function handleSearch(input)
	appList:scroll(-9999)

	local matchIdx = 1
	appsIndexes = {}
	for idx, appName in ipairs(apps) do
		local wid = appList.children[idx]
		if wid == nil then return end

		if input ~= '' then
			local match = fzy.has_match(input, appName)
			if match then
				wid.visible = true
				matchIdx = matchIdx + 1
				table.insert(appsIndexes, idx)
			else
				wid.visible = false
				appList:emit_signal 'widget::redraw_needed'
			end
		else
			wid.visible = true
			appList:emit_signal 'widget::redraw_needed'
		end
	end
end

local searchInput
local function resetSearch()
	handleSearch ''
	searchInput.widget.text = ''
	searchInputPlaceholder.visible = true
	awful.keygrabber.stop()
end

searchInput = awful.widget.prompt {
	prompt = '',
	autoexec = true,
	exe_callback = function()
		local wid = appList.children[appsIndexes[1]]
		wid:launch()
	end,
	changed_callback = handleSearch,
	done_callback = resetSearch,
	highlighter = function(before, after)
		return '<b>' .. util.colorizeText(before, beautiful.foregroundSecondary), util.colorizeText(after, beautiful.foregroundSecondary) .. '</b>'
	end,
	bg = '#00000000'
}


searchInput:connect_signal('button::press', function(_, _, _, button)
	if button == 1 then
		print 'running search'
		searchInputPlaceholder.visible = false
		searchInput:run()
	end
end)

-- [[ App search done ]] --

local function setupAppList()
	-- setting spacing makes it have a wack amount of space
	-- because awesome handles not visible widgets in a layout in a dumb way
	--appList.spacing = util.dpi(1)
	appList.step = util.dpi(100)
	appList.scrollbar_widget = {
		widget = wibox.widget.separator,
		shape = gears.shape.rounded_bar,
		color = beautiful.accent
	}
	appList.scrollbar_width = util.dpi(10)
end

local function fetchApps()
	local collision = {}

	setupAppList()
	local allApps = extrautils.apps.get_all()
	local function pairsByKeys(t, f)
		local a = {}
		for m, n in pairs(t) do
			table.insert(a, m, n)
		end
		table.sort(a, f)
		local i = 0
		local iter = function()
			i = i + 1
			if a[i] == nil then
				return nil
			else
				return a[i], t[a[i]]
			end
		end
		return iter
	end

	local first = true
	for app, t in pairsByKeys(allApps, function(a, b)
		return string.lower(a.name) < string.lower(b.name)
	end) do
		local name = app.name
		if collision[name] or not app.show then
			goto continue
		end

		collision[name] = true
		table.insert(apps, app.name)

		local appWid = wibox.widget {
			widget = wibox.container.margin,
			right = util.dpi(8),
			id = app.name,
			{
				widget = wibox.container.background,
				bg = beautiful.panelBackground,
				shape = util.rrect(beautiful.radius),
				id = 'bg',
				{
					widget = wibox.container.margin,
					margins = util.dpi(8),
					top = util.dpi(first and -4 or 8),
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = util.dpi(8),
						{
							widget = wibox.container.place,
							{
								{
									widget = wibox.widget.imagebox,
									image = gears.surface.load_uncached_silently(
										app.icon,
										extrautils.apps.lookup_icon 'application-x-executable'
									),
									clip_shape = util.rrect(2)
								},
								widget = wibox.container.constraint,
								strategy = 'exact',
								width = util.dpi(32),
								height = util.dpi(32)
							}
						},
						{
							widget = wibox.container.place,
							{
								layout = wibox.layout.fixed.vertical,
								{
									text = name,
									font = beautiful.fontName .. ' Medium 12',
									widget = wibox.widget.textbox
								},
								app.description and {
									layout = wibox.container.place,
									halign = 'left',
									forced_width = util.dpi(360),
									forced_height = util.dpi(22),
									{
										widget = textbox,
										color = beautiful.foregroundSecondary,
										text = app.description
									}
								} or nil
							}
						}
					}
				}
			}
		}
		first = false

		appWid.buttons = {
			awful.button({}, 1, function()
				appWid:launch()
			end)
		}

		function appWid:launch()
			startMenu:off()
			app.launch()
			resetSearch()
		end

		--helpers.displayClickable(appWid, {bg = bgcolor})
		appList:add(appWid)

		::continue::
	end
end

fetchApps()

local menuHeight = util.dpi(580)
local menuWidth = util.dpi(460)
local searchHeight = util.dpi(32)
startMenu = panels.create {
	widget = {
		layout = wibox.layout.fixed.vertical,
		titlebar {
			title = 'Apps'
		},
		{
			widget = wibox.container.margin,
			margins = util.dpi(16),
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = util.dpi(16),
				{
					widget = wibox.container.background,
					shape = util.rrect(beautiful.radius),
					--bg = beautiful.backgroundTertiary,
					{
						layout = wibox.layout.stack,
						{
							layout = wibox.container.place,
							halign = 'center',
							valign = 'top',
							icon {
								icon = 'fedora',
								size = util.dpi(32),
							}
						},
						{
							layout = wibox.container.place,
							halign = 'center',
							valign = 'bottom',
							{
								layout = wibox.layout.fixed.vertical,
								spacing = util.dpi(8),
								button {
									icon = 'sleep',
									size = util.dpi(32),
									click = power.sleep
								},
								button {
									icon = 'logout',
									size = util.dpi(32),
									click = power.logout
								},
								button {
									icon = 'restart',
									size = util.dpi(32),
									click = power.reboot
								},
								button {
									icon = 'power2',
									size = util.dpi(32),
									click = power.shutdown
								}
							}
						}
					}
				},
				{
					layout = wibox.layout.stack,
					{
						layout = wibox.container.margin,
						bottom = searchHeight,
						{
							layout = wibox.layout.stack,
							{
								layout = wibox.container.place,
								halign = 'right',
								forced_width = util.dpi(10),
								{
									widget = wibox.container.constraint,
									width = util.dpi(10),
									{
										widget = wibox.container.margin,
										{
											widget = wibox.widget.separator,
											color = beautiful.backgroundTertiary,
											shape = gears.shape.rounded_bar,
										}
									}
								}
							},
							appList,
						}
					},
					{
						layout = wibox.container.margin,
						right = util.dpi(12),
						{
							widget = wibox.container.background,
							bg = {
								type  = 'linear',
								from  = {menuWidth, 0},
								to = {menuWidth, menuHeight - (searchHeight / 1.5) - util.dpi(beautiful.titlebarHeight)},
								stops = {
									{0, beautiful.panelBackground .. '00'},
									{0.8, beautiful.panelBackground .. '00'},
									{0.88, beautiful.panelBackground .. 'cc'},
									{0.9, beautiful.panelBackground},
								}
							}
						}
					},
					{
						layout = wibox.container.place,
						valign = 'bottom',
						halign = 'center',
						{
							layout = wibox.container.constraint,
							strategy = 'exact',
							height = searchHeight,
							width = menuWidth,
							{
								layout = wibox.layout.stack,
								searchInputPlaceholder,
								searchInput,
							}
						}
					}
				}
			}
		}
	},
	manage = function(panel, open)
		if not open then
			resetSearch()
		end
	end,
	height = menuHeight,
	width = menuWidth,
	growPosition = 'top',
	attach = 'bottom_left'
}

command.add {
	name = 'system:start-menu',
	action = function()
		startMenu:toggle()
	end
}

return startMenu
