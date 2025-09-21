local battery = require 'sys.battery'
local naughty = require 'naughty'

local lowNotified = false
local criticalNotified = false

awesome.connect_signal('battery::percentage', function (percent)
    print('battery is at ' .. percent)
    if battery.status() ~= 'Charging' then

        if percent <= 20 and percent >= 11 and not lowNotified then 
            lowNotified = true
            naughty.notify {
                category = 'battery-low',
                title = 'Low Battery',
                text = 'Battery is at ' .. tostring(percent) .. '%, consider charging.'
            }
        end

        if percent <= 10 and not criticalNotified then
            criticalNotified = true
            naughty.notify {
                category = 'battery-critical',
                title = 'Critical Battery',
                text = 'Battery is at ' .. tostring(percent) .. '%, you should really charge now.'
            }
        end
    end
end)

awesome.connect_signal('battery::status', function(status)
    if status == 'Charging' then
        lowNotified = false
        criticalNotified = false
    end
end)
