local settings = require 'sys.settings'
settings.defineType('theme', {
	name = 'harmony',
	type = 'dark'
})

settings.migrate('theme', {
	version = 2,
	migrator = function(conf)
		conf.accent = 'color6'
	end
})

require 'sys.theme.beautiful'
