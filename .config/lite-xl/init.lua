local core = require 'core'
local config = require 'core.config'
local style = require 'core.style'
local RootView = require 'core.rootview'
local StatusView = require 'core.statusview'
local DocView = require 'core.docview'

local fontconfig = require 'plugins.fontconfig'
local lspconfig = require 'plugins.lsp.config'
local lspkind = require 'plugins.lspkind'

config.ignore_files = {'^%.git$'}
local function ignoreExt(...)
	local exts = {...}
	for i in ipairs(exts) do
		table.insert(config.ignore_files, '[%w-.]+.' .. exts[i])
	end
end
ignoreExt('png')
fontconfig.use_blocking {
	font = {
		group = {
			'SF Pro Display:style=Regular',
			'VictorMono Nerd Font Mono:style=Medium',
			'Segoe UI Emoji'
		},
		size = 12 * SCALE
	},
	code_font = {
		group = {
			'VictorMono Nerd Font Mono:style=Medium',
			'Segoe UI Emoji'
		},
		size = 12 * SCALE
	}
}

lspkind.setup {}
core.reload_module 'colors.awesomewm'

config.tab_type = 'hard'
config.indent_size = 4
config.scroll_past_end = false
config.plugins.toolbarview = false
--config.plugins.trimwhitespace = true
config.plugins.lsp.stop_unneeded_servers = false
config.lint.lens_style = 'solid'

local bigCodeFont = style.code_font:copy((16 * 1.6) * SCALE)
if not core.status_view:get_item 'icon:heart' then
	core.status_view:add_item(core.active_view:is(DocView),
	'icon:heart', StatusView.Item.RIGHT, function()
		return {
			style.color1, bigCodeFont, ''
		}
	end, nil, -1, "<3")
end
core.status_view:hide_items {'doc:line-ending', 'command:files'}
core.status_view:move_item('doc:position', 3, StatusView.Item.RIGHT)

lspconfig.gopls.setup {}
lspconfig.sumneko_lua.setup {
	command = {
		HOME .. '/.local/share/lite-xl/lsp/lua-language-server/bin/lua-language-server',
		'-E',
		HOME .. '/.local/share/lite-xl/lsp/lua-language-server/main.lua',
	},
	settings = {
		Lua = {
			workspace = {
				library = {
					[DATADIR] = true
				}
			},
			diagnostics = {
				neededFileStatus = {
					['lowercase-global'] = 'None'
				}
			}
		}
	}
}
