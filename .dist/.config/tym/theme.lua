local oldPackagePath = package.path
local awesomeDir = io.popen [[awesome-client "return require 'gears'.filesystem.get_configuration_dir()"]]:read '*a':match '"(.+)"'
package.path = package.path .. ';' .. awesomeDir .. '/?.lua'

local color = require 'sys.color'
local palettes = require 'sys.theme.palettes'

local f = io.open(os.getenv 'HOME' .. '/.local/share/paperbush/theme.json')
local obj = load('return ' .. f:read '*a':gsub('("[^"]-"):', '[%1]='))()
local themeSettings = obj.data

local thm = palettes[themeSettings.name .. ':' .. themeSettings.type]
local bg = thm.background	
local fg = thm.foreground

local theme = {
	color_background = bg,
	color_foreground = fg,
	color_bold = fg,
	color_cursor = fg,
	color_cursor_foreground = bg,
	color_highlight = fg,
	color_highlight_foreground = bg,
}

for i = 1, 6 do
	theme['color_' .. i] = thm['color' .. i]
	theme['color_' .. i + 8] = color.shift(thm['color' .. i], 25)
end
theme.color_0 = bg
theme.color_7 = fg
theme.color_8 = color.shift(bg, 25)
theme.color_15 = color.shift(fg, 25)

return theme
