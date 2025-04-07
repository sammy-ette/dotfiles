local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'

local settings = require 'sys.settings'
local panels = require 'ui.panels'
local util = require 'sys.util'

local workspacesList = wibox.widget {
	layout = wibox.layout.overflow.vertical(),
	spacing = util.dpi(6)
}

local function setupWorkspaceList()
	workspacesList.step = util.dpi(100)
	workspacesList.scrollbar_widget = {
		widget = wibox.widget.separator,
		shape = gears.shape.rounded_bar,
		color = beautiful.accent
	}
	workspacesList.scrollbar_width = util.dpi(10)
end
setupWorkspaceList()

local workspaces = panels.create {
	height = 'screen',
	width = util.dpi(240),
	widget = {
		layout = wibox.container.margin,
		margins = util.dpi(8),
		{
			layout = workspacesList
		}
	},
	attach = 'left'
}

local function createWorkspaceWid(t)
	local configWallpaper = settings.getConfig 'wallpaper'.home.image
	if not gears.filesystem.file_readable(configWallpaper) then
		configWallpaper = gears.filesystem.get_configuration_dir() .. '/assets/lotus-wallpaper.png'
	end

	local height = util.dpi(120)

	return wibox.widget {
		widget = wibox.container.constraint,
		height = height,
		width = util.dpi(240),
		{
			widget = wibox.container.background,
			bg = '#0000000',
			shape = util.rrect(beautiful.radius),
			border_width = util.dpi(2),
			border_color = beautiful.foreground,
			{
				layout = wibox.layout.stack,
				{
					image = gears.surface.crop_surface {
						surface = gears.surface.load_uncached(configWallpaper),
						ratio = util.dpi(240)/height,
					},
					resize = true,
					widget = wibox.widget.imagebox,
				},
				{
					widget = wibox.container.background,
					bg = beautiful.panelBackground .. string.format('%x', math.floor(0.6 * 255))
				}
			}
		}
	}
end

local oldOn = workspaces.on
function workspaces:on(...)
	local scr = awful.screen.focused()
	for _, t in ipairs(scr.tags) do
		local clients = t:clients()
		print(#clients, t.index)
		if #clients == 0 then
			print 'adding workspace'
			local workspaceWid = createWorkspaceWid(t)
			workspacesList:add(workspaceWid)
		end
	end
	
	oldOn(workspaces, ...)
end

return workspaces
