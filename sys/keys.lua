local awful = require 'awful'
local settings = require 'sys.settings'
local command = require 'sys.command'

-- Define default keybinds
-- TODO: Command palette system like Lite XL, get description
-- from command definitions if one for a keybind isnt given (so basically all of them)
local keyTable = {
	{
		group = 'system',
		key = 'M-S-/',
		action = 'system:display-keys'
	},
	{
		group = 'screen',
		key = 'XF86MonBrightnessDown',
		action = 'screen:decrease-brightness'
	},
	{
		group = 'screen',
		key = 'XF86MonBrightnessUp',
		action = 'screen:increase-brightness'
	},
	{
		group = 'audio',
		key = 'XF86AudioMute',
		action = 'audio:mute'
	},
	{
		group = 'audio',
		key = 'XF86AudioLowerVolume',
		action = 'audio:decrease-volume'
	},
	{
		group = 'audio',
		key = 'XF86AudioRaiseVolume',
		action = 'audio:increase-volume'
	},
	{
		group = 'management',
		key = 'M-Left',
		action = 'client:focus-left'
	},
	{
		group = 'management',
		key = 'M-Right',
		action = 'client:focus-right'
	},
	{
		group = 'management',
		key = 'M-S-Left',
		action = 'client:move-master-left'
	},
	{
		group = 'management',
		key = 'M-S-Right',
		action = 'client:move-master-right'
	},
	{
		group = 'management',
		key = 'M-A-Left',
		action = 'client:move-left'
	},
	{
		group = 'management',
		key = 'M-S-Right',
		action = 'client:move-right'
	},
	{
		group = 'management',
		key = 'M-S-Up',
		action = 'client:move-up'
	},
	{
		group = 'management',
		key = 'M-S-Down',
		action = 'client:move-down'
	},
	{
		group = 'management',
		key = 'M-Tab',
		action = 'tag:next'
	},
	{
		group = 'management',
		key = 'M-S-Tab',
		action = 'tag:previous'
	},
	{
		group = 'management',
		key = 'M-space',
		action = 'layout:next'
	},
	{
		group = 'management',
		key = 'M-S-space',
		action = 'layout:previous'
	},
	{
		group = 'system',
		key = 'M-l',
		action = 'screen:lock'
	},
	{
		group = 'screen',
		key = 'C-Print',
		action = 'screen:selection-screenshot'
	},
	{
		group = 'screen',
		key = 'Print',
		action = 'screen:window-screenshot'
	},

	{
		group = 'utility',
		key = 'M-t',
		action = 'utility:open-terminal'
	},

	-- Client Mouse Binds
	{
		group = 'client',
		key = 'LeftMouse',
		action = 'client:focus',
	},
	{
		group = 'client',
		key = 'M-LeftMouse',
		action = 'client:move',
	},
	{
		group = 'client',
		key = 'M-RightMouse',
		action = 'client:resize',
	},

	-- Client Keybinds
	{
		group = 'client',
		key = 'M-f',
		action = 'client:fullscreen'
	},
	{
		group = 'client',
		key = 'M-m',
		action = 'client:maximize'
	},
	{
		group = 'client',
		key = 'M-n',
		action = 'client:minimize'
	},
	{
		group = 'client',
		key = 'M-S-c',
		action = 'client:close'
	},
	{
		group = 'client',
		key = 'M-space',
		action = 'client:toggle-floating'
	}
}

for i = 1, 9 do
	table.insert(keyTable, {
		group = 'tag',
		key = 'M-' .. tostring(i),
		action = 'tag:go-to-' .. tostring(i)
	})
end

settings.defineType('keys', keyTable)

local function parseKey(keyList)
	local adjustKey = {
		['LeftMouse'] = 1,
		['MiddleMouse'] = 2,
		['RightMouse'] = 3
	}
	local modifiersMapping = {
		['M'] = 'Mod4', -- Super/Windows Key
		['C'] = 'Control', -- Ctrl
		['A'] = 'Mod1', -- Alt
		['S'] = 'Shift', -- Shift
	}

	local modifiers = {}
	for key in string.gmatch(keyList, '([^-]+)') do
		local modifierKey = modifiersMapping[key]
		if modifierKey then
			table.insert(modifiers, modifierKey)
		else
			local isMouseKey = false
			if key:match '[mM][oO][uU][sS][eE]' then
				isMouseKey = true
			end
			return modifiers, adjustKey[key] or key, isMouseKey
		end
	end
end

local keyDefs = settings.getConfig 'keys'
local clientMouseBinds = {}
local clientKeyBinds = {}

for _, def in ipairs(keyDefs) do
	local modifiers, key, mouse = parseKey(def.key)
	local keyHandler = function(...)
		print(def.action)
		local success = command.perform(def.action, ...)
		print(success)
	end
	local awfulKey = awful.key(modifiers, key, keyHandler, {
		description = def.description or (command.get(def.action) and command.get(def.action) or {}).description,
		group = def.group
	})

	if def.group == 'client' then
		if mouse then
			table.insert(clientMouseBinds, awful.button(modifiers, key, keyHandler))
		else
			table.insert(clientKeyBinds, awfulKey)
		end
	else
		awful.keyboard.append_global_keybindings {
			awfulKey
		}
	end
end

client.connect_signal('request::default_mousebindings', function()
	awful.mouse.append_client_mousebindings(clientMouseBinds)
end)

client.connect_signal('request::default_keybindings', function()
	awful.keyboard.append_client_keybindings(clientKeyBinds)
end)
