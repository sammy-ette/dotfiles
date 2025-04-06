local beautiful = require 'beautiful'
local gears = require 'gears'
local settings = require 'sys.settings'
local palettes = require 'sys.theme.palettes'
local util = require 'sys.util'

local themeSettings = settings.getConfig 'theme'
local palette = palettes[themeSettings.name .. ':' .. themeSettings.type]

local fontName = 'IBM Plex Sans'

beautiful.init(gears.table.crush({
	accent = palette.color6,

	fontName = fontName,
	font = fontName .. ' Regular 12',

	titlebarHeight = 48,
	titlebarBackground = palette.shade2,
	radius = 6,

	barBackground = palette.background,
	panelBackground = palette.backgroundSecondary,
	
	useless_gap = util.dpi(6),

	notificationWidth = util.dpi(340),
	notificationHeight = util.dpi(120)
}, palette))
