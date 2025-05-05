local bling = require 'libs.bling'
local playerctl = bling.signal.playerctl.lib {
	metadata_v2 = true
}

playerctl:connect_signal('metadata', function(a, metadata, art, new, playerName)
	awesome.emit_signal('paperbush::music', metadata, art, playerName)
end)

playerctl:connect_signal('no_players', function(a, metadata, art, new, playerName)
	awesome.emit_signal('paperbush::musicDone')
end)

playerctl:connect_signal('playback_status', function(a, playing)
	awesome.emit_signal('paperbush::musicPlayingState', playing)
end)

local M = {}

function M.togglePlay()
	playerctl:play_pause()
end

return M
