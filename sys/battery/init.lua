local upower = require 'lgi'.UPowerGlib
local p = require 'dbus_proxy'

local M = {}

--local battery = upower.Client():get_display_device()
local battery
local devices = upower.Client():get_devices()
for _, dev in ipairs(devices) do
	if dev.is_present and dev.power_supply then
		battery = dev
	end
end

local statusNames = {
	[upower.DeviceState.PENDING_DISCHARGE] = "Discharging",
	[upower.DeviceState.PENDING_CHARGE]    = "Charging",
	[upower.DeviceState.FULLY_CHARGED]     = "Full",
	[upower.DeviceState.EMPTY]             = "N/A",
	[upower.DeviceState.DISCHARGING]       = "Discharging",
	[upower.DeviceState.CHARGING]          = "Charging",
	[upower.DeviceState.UNKNOWN]           = "N/A"
}

local function formatTime(t)
	local hours = math.floor(t/3600)
	local mins = math.floor(t/60 - (hours*60))
	local secs =  math.floor(t - hours*3600 - mins *60)

	local entries = {}
	if hours > 0 then table.insert(entries, string.format('%d hour%s', hours, hours > 2 and 's' or '')) end
	if mins > 0 then table.insert(entries, string.format('%d minute%s', mins, mins > 2 and 's' or '')) end
	--if secs > 0 then table.insert(entries, string.format('%d seconds', secs)) end

	return table.concat(entries, ', ')
end

local oldStates = {}
local function updateStats()
	local state = statusNames[battery.state]
	local percentage = math.floor(battery.percentage)
	local time
	if state == 'Charging' then
		time = formatTime(battery.time_to_full) .. ' until full'
	else
		time = formatTime(battery.time_to_empty) .. ' left'
	end
	if percentage == 100 then
		state = 'Full'
	end

	if state ~= oldStates.status then
		awesome.emit_signal('battery::status', state)
		awesome.emit_signal('battery::percentage', percentage)
		awesome.emit_signal('battery::time', time)
	end
	if percentage ~= oldStates.percentage then
		awesome.emit_signal('battery::percentage', percentage)
	end
	if time ~= oldStates.time then
		awesome.emit_signal('battery::time', time, state == 'Charging' and battery.time_to_full or battery.time_to_empty)
	end

	oldStates.percentage = percentage
	oldStates.status = state
end

if battery then
	updateStats()
	battery.on_notify = updateStats
end

function M.status()
	if not battery then return 'None' end

	if M.percentage() == 100 then return 'Full' end

	return statusNames[battery.state]
end

function M.percentage()
	return battery and battery.percentage or 0
end

function M.time()
	if not battery then return '' end

	local state = M.status()

	if state == 'Charging' then
		if battery.time_to_full == 0 then return 'Calculating time...' end
		return formatTime(battery.time_to_full) .. ' until full'
	else
		if battery.time_to_empty == 0 then return 'Calculating time...' end
		return formatTime(battery.time_to_empty) .. ' left'
	end
end

local manager = require 'sys.battery.manager'
print(manager)
function M.setProfile(profile)
	--[[
	if profile == 'powerSave' then
		settings.noAnimate = true
	else
		settings.noAnimate = false
	end
	]]--
	manager[profile .. 'Profile']()
end

function M.profile()
	return manager.profile()
end

--if M.profile() == 'powerSave' then settings.noAnimate = true end

function M.history(updater)
	--[[
	local sparkline = p.Proxy:new {
		bus = p.Bus.SESSION,
		name = 'party.sammyette.Sparkline',
		interface = 'party.sammyette.Sparkline',
		path = '/party/sammyette/Sparkline'
	}

	local historyRaw = sparkline:Collect(battery:get_object_path())
	local history = {}

	for k, hist in pairs(historyRaw) do
		table.insert(history, hist[1])
		table.sort(history, function(a, b) return a > b end)
	end

	sparkline:connect_signal(function(_, data)
		local percent = data[1]
		updater(percent)
	end, 'Update')

	return history
	]]--

	return {}
end

return M
