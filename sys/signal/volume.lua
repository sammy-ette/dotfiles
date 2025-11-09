local awful = require 'awful'

local volume_old = -1
local muted_old = false
local function emit_volume_info(init)
    awful.spawn.easy_async_with_shell(
        'pamixer --get-volume && printf \'muted: \' && pamixer --get-mute',
        function(stdout)
            local volume = stdout:match('%d+')
            local muted = stdout:match('muted:%s+(%w+)') == 'true'
            local volume_int = tonumber(volume)
            if not volume_int then return end

            if volume_int ~= volume_old or muted ~= muted_old then
                awesome.emit_signal('sys::volume', volume_int, muted, init)
                volume_old = volume_int
                muted_old = muted
            end
        end)
end

--emit_volume_info()

-- Sleeps until pactl detects an event (volume up/down/toggle mute)
local volume_script = [[
    bash -c "
    LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on sink\"
    "]]

-- Kill old pactl subscribe processes
local pid = awful.spawn.with_line_callback(volume_script, {
	stdout = function(line) emit_volume_info() end
})

awesome.register_xproperty('pactlPid', 'number')
local oldPid = awesome.get_xproperty('pactlPid')

if oldPid then
	awesome.kill(oldPid, awesome.unix_signal.SIGTERM)
end
awesome.set_xproperty('pactlPid', pid)

emit_volume_info(true)
