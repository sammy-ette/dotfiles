pcall(require, 'luarocks.loader')

awesome.register_xproperty('initialized', 'boolean')

require 'sys'
require 'ui'

awesome.emit_signal('paperbush::initialized', not awesome.get_xproperty 'initialized')
awesome.set_xproperty('initialized', true)

collectgarbage('setpause', 110)
collectgarbage('setstepmul', 1000)
