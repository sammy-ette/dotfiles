local tym = require 'tym'
local thm = dofile(tym.get_theme_path())

-- todo: watch config file and autoreload

tym.set('font', 'Monaspace Neon Medium 12')
tym.set_config {
	title = 'Tym',
	padding_horizontal = 20,
	padding_vertical = 16,
	cursor_shape = 'ibeam',
	color_window_background = thm.color_background,
	shell = [[hilbish -Sic "os.setenv('SHLVL', tostring(tonumber(os.getenv 'SHLVL') - 1))"]]
}

tym.set_hooks({
  title = function(t)
	if t:match 'cmus' then
		tym.set_config {
			padding_vertical = 0
		}
		return true -- this is needed to cancenl default title application
	end
  end,
})

tym.set_hook('selected', function ()
	tym.copy_selection()
end)
