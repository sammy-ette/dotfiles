local awful = require 'awful'
local beautiful = require 'beautiful'
local compositor = require 'modules.compositor'
local settings = require 'conf.settings'
local naughty = require 'naughty'
local sound = require 'sys.sound'

local programs = {
	'gnome-keyring-daemon',
	'udiskie',
	'pactl load-module module-role-ducking trigger_roles=phone,event',
	'pactl load-module module-bluetooth-discover',
	'pactl load-module module-bluetooth-policy',
	'pactl load-module module-switch-on-connect',
	'libinput-gestures-setup start',
	'tym --daemon',
	'xplugd',
	'unclutter',
--	[[xss-lock awesome-client "require 'ui.lockscreen'.lock()"]],
	'/usr/libexec/polkit-gnome-authentication-agent-1 &',
	string.format('gsettings set org.gnome.desktop.interface color-scheme prefer-%s', beautiful.dark and 'dark' or 'light')
}

if settings.picom then
	-- toggle
	compositor.on()
else
	--compositor.off()
end


awesome.connect_signal('paperbush::initialized', function(first)
	if not first then return end

	for _, p in ipairs(programs) do
		awful.spawn.easy_async('pgrep ' .. (p:match '^%w+' or p), function(output)
			if output == '' then
				awful.spawn.easy_async(p, function() end)
			end
		end)
	end

	awful.spawn.easy_async('dex-autostart --environment Awesome --autostart', function() end)
	sound.play 'startup'
end)

