local awful = require 'awful'
local beautiful = require 'beautiful'
local gfs = require 'gears.filesystem'
local step = 5
local sounds = {
	notification = 'notify6.wav',
	deviceAdded = 'device-added2.wav',
	deviceRemoved = 'device-removed2.wav',
	startup = 'startup2.wav'
}

local M = {
	volume = 0.9
}

local function spawn(cmd, cb)
	awful.spawn.easy_async(cmd, cb or function() end)
end

function M.play(s)
	-- --property=media.role=event
	-- for some reason causes it not to play audio...
	local cmd = string.format('paplay --property=media.role=event --volume %f %s', M.volume * 65536, gfs.get_configuration_dir() .. 'assets/sounds/' .. (sounds[s] or s .. '.wav'))
	awful.spawn.easy_async(cmd, function(tbl) print(tbl) end)
end

function M.notify()
	M.play 'notification'
end

function M.state(cb)
	spawn('pamixer --get-mute && pamixer --get-volume', function(stdout)
		local mute = stdout:match '([truefalse]+)' == 'true'
		local volume = stdout:match '%d+'

		cb(volume, mute)
	end)
	--[[
	awful.spawn.easy_async('pactl list sinks', function(stdout)
		local mute = stdout:match('Mute:%s+(%a+)')
		local volpercent = stdout:match('%s%sVolume:[%s%a-:%d/]+%s(%d+)%%')

		if mute == 'yes' then
			mute = true
		else
			mute = false
		end

		volpercent = tonumber(volpercent)

		cb(volpercent, mute)
	end)
	]]--
end

local function round(val, roundAmnt)
	return math.floor(val / roundAmnt) * roundAmnt
end

function M.volumeUp()
	M.state(function(vol)
		M.setVolume(round(vol + step, 5))
	end)
end

function M.volumeDown()
	M.state(function(vol)
		M.setVolume(round(vol - step, 5))
	end)
end

function M.setVolume(vol)
	spawn('pactl set-sink-volume @DEFAULT_SINK@ '..vol..'%')
	-- awesome.emit_signal('evil::volume', next_vol, mute)
end

function M.toggleMute()
	spawn('pamixer --toggle-mute')
end

return M
