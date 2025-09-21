local util = require 'sys.util'
local M = {}

function M.up()
    util.spawn('light -A 10')
end

function M.down()
    util.spawn('light -U 10')
end

return M
