local lgi = require 'lgi'
local Gio = lgi.Gio
local GLib = lgi.GLib
local gears = require 'gears'
local json = require 'libs.json'

local baseConfigDir = gears.filesystem.get_xdg_data_home() .. 'paperbush/'
Gio.File.new_for_path(baseConfigDir):make_directory()

local M = {
	confs = {
		--[[
			fields are:
			- fileHandle
			- config
		]]
	}
}

function M.defineType(name, schema)
	local configPath = baseConfigDir .. name .. '.json'
	local file = Gio.File.new_for_path(configPath)
	local config

	if not gears.filesystem.file_readable(configPath) then
		config = schema
		file:create_async(Gio.FileCreateFlags.NONE, GLib.PRIORITY_DEFAULT, nil, function(_, res)
			local stream = file:create_finish(res)
			local encoded = json.encode(schema)
			stream:write_async(encoded, GLib.PRIORITY_DEFAULT, nil, function(_, res) stream:write_finish(res) end)
		end)
	else
		local content = file:load_contents()
		config = json.decode(content)
	end

	if not config.__version then
		config.__version = 1
	end

	M.confs[name] = {
		fileHandle = file,
		config = config
	}
end

function M.write(configName)
	local file = M.confs[configName].fileHandle
	file:replace_contents_bytes_async(GLib.Bytes(json.encode(M.confs[configName].config)), nil, false, Gio.FileCreateFlags.REPLACE_DESTINATION, nil, function(_, res)
		file:replace_contents_finish(res)
	end)
end

function M.set(configName, key, val, write)
	M.confs[configName].config[key] = val
	if write then M.write(configName) end
end


function M.getConfig(configName)
	local conf = M.confs[configName].config
	local confWrap = {}
	setmetatable(confWrap, {
		__index = function(_, k)
			return conf[k]
		end,
		__newindex = function(_, k, v)
			M.set(configName, k, v)
		end
	})

	return confWrap
end

function M.get(configName, key)
	return M.confs[configName].config[key]
end

-- to migrate to the latest config schema
function M.migrate(configName, opts)
	local conf = M.getConfig(configName)
	if conf.__version > opts.version or conf.__version == opts.version then return end

	print(string.format('migrating %s from ver %d to %d', configName, conf.__version, opts.version))
	opts.migrator(conf)
	conf.__version = opts.version
	M.write(configName)
end

return M
