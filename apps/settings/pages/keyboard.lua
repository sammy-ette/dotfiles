local wibox = require 'wibox'
local settings = require 'sys.settings'
local util = require 'sys.util'
local command = require 'sys.command'

local page = require 'apps.settings.page'
local pageWidgets = require 'apps.settings.pages.widget'

local keyConfig = settings.getConfig 'keys'
local keyWidgets = {}

for _, def in ipairs(keyConfig) do
    if def.action == 'system:right-click-menu' then goto continue end
    local cmd = command.get(def.action)
    print(cmd, def.action)

    table.insert(keyWidgets, wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = util.dpi(8),
        {
            widget = wibox.widget.textbox,
            text = cmd and (cmd.prettyName or cmd.name) or def.action
        }
    })

    ::continue::
end

page.add {
    name = 'Keys',
    icon = 'keyboard',
    widget = {
        pageWidgets.section('Keyboard Shortcuts', keyWidgets)
    }
}
