local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local panels = require 'ui.panels'
local util = require 'sys.util'
local settings = require 'sys.settings'
local rubato = require 'libs.rubato'

local icon = require 'ui.widget.icon'
local button = require 'ui.widget.button'
local titlebar = require 'ui.widget.titlebar'

local quickSettingsLayout = wibox.layout.overflow.horizontal()
local animator = rubato.timed {
	duration = 2,
	rate = 60,
	subscribed = function(p)
		quickSettingsLayout:scroll(p)

		if p == 0 then
			--quickSettingsPage.visible = false
		end
	end,
	easing = rubato.quadratic
}

local quickSettingsWidth = util.dpi(460)
local qsBeforeButton = wibox.widget {
	widget = wibox.container.rotate,
	direction = 'west',
	button {
		icon = 'expand-more',
		size = util.dpi(24),
		onClick = function()
			animator.target = -quickSettingsWidth
		end
	}
}

local quickSettingsTitlebar, qstHeight = titlebar {
	title = 'Quick Settings',
	before = qsBeforeButton,
	after = {
		layout = wibox.layout.fixed.horizontal,
		spacing = util.dpi(12),
		button {
			icon = 'edit',
		},
		button {
			icon = 'settings',
		}
	}
}
local quickSettingsHeight = util.dpi(500) + qstHeight
local quickSettingsMargins = util.dpi(16)

quickSettingsLayout.scrollbar_enabled = false
local quickSettingsHome = wibox.widget {
	widget = wibox.container.background,
	shape = gears.shape.rectangle,
	{
		layout = wibox.layout.fixed.vertical,
		spacing = util.dpi(40),
		spacing_widget = {
			widget = wibox.widget.separator,
			thickness = util.dpi(3),
			color = beautiful.backgroundTertiary
		},
		{
			layout = wibox.layout.fixed.horizontal,
			{
				layout = wibox.layout.stack,
				--[[
				{
					widget = wibox.widget.imagebox,
					clip_shape = gears.shape.circle,
					image = gears.surface.load_silently
				}
				]]--
				icon {
					icon = 'person',
					size = util.dpi(80)
				}
			},
			{
				widget = wibox.widget.textbox,
				text = os.getenv 'USER',
				font = beautiful.fontName .. ' Bold 14'
			}
		},
		{
			layout = wibox.layout.grid,
			forced_num_cols = 3,
			homogeneous = true,
			expand = true,
			spacing = util.dpi(16),
			id = 'toggles'
		}
	}
}

local quickSettingsWidget = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	quickSettingsTitlebar,
	{
		layout = wibox.container.margin,
		margins = quickSettingsMargins,
		{
			layout = quickSettingsLayout,
			{
				layout = wibox.container.constraint,
				width = quickSettingsWidth - (quickSettingsMargins * 2),
				height = quickSettingsHeight - (quickSettingsMargins * 2),
				strategy = 'exact',
				quickSettingsHome
			},
			wibox.widget.base.empty_widget(),
		}
	}
}

local function createToggler(args)
	assert(args.name, 'args.name for quick settings toggler is missing')

	local quickSettingsModule = require('ui.panels.quickSettings.' .. args.name)
	assert(quickSettingsModule.init, string.format('quick settings manager "%s" is missing init function', args.name))
	assert(quickSettingsModule.toggle, string.format('quick settings manager "%s" is missing toggle function', args.name))

	local togglerInitOptions = quickSettingsModule.init()
	assert(togglerInitOptions.icon, string.format('quick settings manager "%s" is missing icon', args.name))
	assert(togglerInitOptions.on ~= nil, string.format('quick settings manager "%s" is missing state (true or false, not nil)', args.name))
	assert(togglerInitOptions.label, string.format('quick settings manager "%s" is missing label', args.name))

	local togglerLabel = wibox.widget {
		widget = wibox.widget.textbox,
		font = beautiful.fontName .. ' Regular 12',
		text = togglerInitOptions.label,
		halign = 'center'
	}

	local toggleButton = button {
		icon = togglerInitOptions.icon,
		color = beautiful.background,
		shape = gears.shape.rectangle,
		containerHeight = util.dpi(100),
		size = util.dpi(28),
		onClick = quickSettingsModule.toggle
	}

	local page = togglerInitOptions.page
	if quickSettingsModule.page then
		page = quickSettingsModule.page()
	end
	local quickSettingsPage = wibox.widget {
		layout = wibox.container.constraint,
		width = quickSettingsWidth - (quickSettingsMargins * 2),
		height = quickSettingsHeight - (quickSettingsMargins * 2),
		strategy = 'exact',
		{
			layout = wibox.container.background,
			page
		}
	}

	local open = false
	local togglerPageButton = button {
		icon = 'arrow-right',
		color = beautiful.background,
		shape = gears.shape.rectaxngle,
		containerHeight = util.dpi(100),
		size = util.dpi(20),
		onClick = function()
			quickSettingsLayout:set(2, quickSettingsPage)
			quickSettingsLayout:emit_signal 'widget::layout_changed'
			quickSettingsPage.visible = true
			animator.target = quickSettingsWidth
		end
	}

	local togglerBg = wibox.container.background()
	local function setTogglerBackground(on)
		togglerBg.bg = on and beautiful.accent or beautiful.backgroundTertiary
		toggleButton.color = on and beautiful.background or beautiful.foregroundSecondary
	end
	setTogglerBackground(togglerInitOptions.on)

	local togglerRatio = wibox.layout.ratio.horizontal()
	--togglerRatio.spacing = util.dpi(1)
	local togglerWidget = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = util.dpi(8),
		{
			layout = wibox.container.constraint,
			height = util.dpi(58),
			strategy = 'exact',
			{
				widget = togglerBg,
				shape = util.rrect(beautiful.radius * 2),
				{
					layout = togglerRatio,
					toggleButton,
					page and togglerPageButton or nil
				}
			}
		},
		togglerLabel
	}

	local majorTogglerSize = 0.75
	togglerRatio:adjust_ratio(1, 0, majorTogglerSize, 1 - majorTogglerSize)

	local toggles = quickSettingsHome:get_children_by_id 'toggles'[1]
	toggles:add(togglerWidget)

	quickSettingsModule:connect_signal('toggle', function(_, on)
		setTogglerBackground(on)
	end)
end

local toggles = settings.getConfig 'quickSettings'
for _, toggleName in ipairs(toggles.modules) do
	print(toggleName)
	createToggler({name = toggleName})
end

local quickSettings = panels.create {
	widget = quickSettingsWidget,
	height = quickSettingsHeight,
	width = quickSettingsWidth,
	manage = function(_, open)
		print('qs manage called', open)
		if not open then
			animator.target = -quickSettingsWidth
		end
	end
}

return quickSettings
