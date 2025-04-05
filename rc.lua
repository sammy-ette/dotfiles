pcall(require, 'luarocks.loader')

awesome.register_xproperty('initialized', 'boolean')

require 'sys'
require 'ui'

if awesome.get_xproperty 'initialized' then
	awesome.emit_signal('paperbush::initialized')
else
	awesome.emit_signal('paperbush::hideSplash')
end
awesome.set_xproperty('initialized', true)

collectgarbage('setpause', 110)
collectgarbage('setstepmul', 1000)
