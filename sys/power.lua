local awful = require 'awful'
local M = {}

function M.shutdown()
	awful.spawn 'poweroff'
end

function M.reboot()
	awful.spawn 'reboot'
end

function M.logout()
	awesome.quit()
end

function M.sleep()
	awful.spawn 'systemctl suspend'
end

return M
