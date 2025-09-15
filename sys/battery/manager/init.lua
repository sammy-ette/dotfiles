local ok, manager = pcall(require, 'sys.battery.manager.system76-power')

if ok then
	return manager
else
	return require 'sys.battery.manager.dummy'
end
