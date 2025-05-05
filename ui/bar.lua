local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local settings = require 'sys.settings'
local util = require 'sys.util'
local startMenu = require 'ui.panels.startMenu'
local rubato = require 'libs.rubato'
local icon = require 'ui.widget.icon'
local cairo = require 'lgi'.cairo

local bars = settings.getConfig 'bars'

for idx, barSetup in ipairs(bars) do
	local function moduleWidgets(position, barIdx, screen)
		local widgets = {}
		local startMenuActivator = icon {
			icon = 'fedora',
			size = util.dpi(barSetup.height),
			color = beautiful.accent
		}
		startMenuActivator.buttons = {
			awful.button({}, 1, function()
				startMenu:toggle(barIdx)
				--startMenu:toggle()
			end)
		}
		local moduleList = {
			startMenu = startMenuActivator,
			time = require 'ui.widget.bar.time',
			capslock = require 'ui.widget.bar.capslock',
			apps = require 'ui.widget.bar.apps'(screen),
			workspace = require 'ui.widget.bar.workspace'(screen),
			systray = require 'ui.widget.bar.systray'(screen),
			layout = require 'ui.widget.bar.layout'(screen),
			music = require 'ui.widget.bar.music'
		}
		for _, moduleName in ipairs(barSetup.modules[position]) do
			local module = moduleList[moduleName]
			if not module then
				-- TODO: warning notification
				return
			end

			table.insert(widgets, module)
		end

		return {
			layout = wibox.layout.fixed.horizontal,
			spacing = util.dpi(barSetup.modules[position].spacing or beautiful.spacing),
			table.unpack(widgets)
		}
	end
	

	local function createBarWidget(idx, screen)
		return {
			widget = wibox.container.background,
			bg = beautiful.barBackground,
			--shape = barSetup.shape
			{
				widget = wibox.container.margin,
				margins = util.dpi(8),
				{
					layout = (barSetup.position == 'bottom' or barSetup.position == 'top')
					and wibox.layout.align.horizontal or wibox.layout.align.vertical,
					expand = 'none',
					moduleWidgets('left', idx, screen),
					moduleWidgets('center', idx, screen),
					moduleWidgets('right', idx, screen),
				}
			}
		}
	end

	if barSetup.screen == 'all' then
		awful.screen.connect_for_each_screen(function(s)
			local revealerBar
			if barSetup.autohide then
				local revealerHeight = util.dpi(1)
				local img = cairo.ImageSurface(cairo.Format.A1, s.geometry.width, revealerHeight)
				img:finish()
				local revealerBar = awful.wibar {
					screen = s,
					position = barSetup.position,
					height = revealerHeight,
					bg = '#00000000',
					restrict_workarea = false,
					ontop = true,
					--shape_input = img._native
				}
				revealerBar:setup {layout = wibox.container.place}
			end

			if not s.bar then s.bar = {} end
			local bar = awful.wibar {
				screen = s,
				position = barSetup.position,
				height = util.dpi(barSetup.height),
				bg = '#00000000',
				margins = {
					--top = barSetup.position == 'bottom' and beautiful.useless_gap
				},
				visible = false
				--restrict_workarea = false
			}
			s.bar[idx] = bar
			bar:setup(createBarWidget(idx, s))

			awesome.connect_signal('paperbush::initialized', function()
				bar.visible = true
			end)

			if barSetup.autohide then
				local hideHeight = bar.y + bar.height
				local revealHeight = bar.y
				local barAnimator = rubato.timed {
					duration = 0.1,
					rate = 120,
					override_dt = true,
					subscribed = function(y)
						bar.y = y
						if y == hideHeight then
							--bar.visible = false
						end
					end,
					pos = bar.y
				}

				local function showBar()
					bar.restrict_workarea = true
					barAnimator.target = revealHeight
				end
				local function hideBar()
					bar.restrict_workarea = false
					barAnimator.target = hideHeight
				end

				local hideTimer = gears.timer {
					autostart = true,
					timeout = 2,
					single_shot = true,
					callback = function()
						hideBar()
					end
				}

				revealerBar:connect_signal('mouse::enter', function()
					showBar()
					print 'revealing the details'
				end)
				bar:connect_signal('mouse::enter', function()
					hideTimer:stop()
				end)
				bar:connect_signal('mouse::leave', function()
					hideTimer:start()
				end)
			end
		end)
	end
end
