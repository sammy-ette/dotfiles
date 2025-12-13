local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
-- local pam = require 'liblua_pam'
local settings = require 'sys.settings'
local util = require 'sys.util'
local wibox = require 'wibox'
local panels = require 'ui.panels'
local textbox = require 'ui.widget.textbox'

local locked = false
local ls
local M = {}

local scr = awful.screen.focused()
local lockscreenEntry = wibox {
	width = scr.geometry.width,
	height = scr.geometry.height,
	ontop = true,
	visible = false
}

local lockscreen = wibox {
	width = scr.geometry.width,
	height = scr.geometry.height,
	ontop = true,
	visible = false
}

-- local passwordInput = inputbox {
-- 	password_mode = true,
-- 	mouse_focus = true,
-- 	fg = beautiful.fg_normal,
-- 	font = beautiful.fontName .. ' Medium 14',
-- 	text_hint = 'Password'
-- }

local passwordInputPlaceholder = wibox.widget {
	widget = textbox,
	text = 'Password',
	-- font = beautiful.fontName .. ' Bold',
	color = beautiful.foregroundSecondary
}

local passwordPrompt = awful.widget.prompt {
	prompt = '',
	autoexec = true,
	exe_callback = function(pw)
		
	end,
	--changed_callback = handleSearch,
	--done_callback = resetSearch,
	highlighter = function(before, after)
        print(before, after)
		return '<b>' .. util.colorizeText(('*'):rep(before:len()), beautiful.foregroundSecondary), util.colorizeText(('*'):rep(after:len()), beautiful.foregroundSecondary) .. '</b>'
	end,
	bg = '#00000000'
}

passwordPrompt:connect_signal('button::press', function(_, _, _, button)
	if button == 1 then
		passwordInputPlaceholder.visible = false
		passwordPrompt:run()
	end
end)

local passwordInput = wibox.widget {
    layout = wibox.layout.stack,
    passwordPrompt,
    passwordInputPlaceholder,
}

local kg = awful.keygrabber {
	keypressed_callback = function(_, mod, key)
		if key ~= ' ' then return end

		ls:off()
	end
}

-- local oldPwKeygrabber = passwordInput.start_keygrabber
-- function passwordInput:start_keygrabber()
-- 	kg:stop()
-- 	oldPwKeygrabber(self)
-- end

-- local oldPwUnfocus = passwordInput.unfocus
-- function passwordInput:unfocus()
-- 	kg:start()
-- 	oldPwUnfocus(self)
-- end

local function decToHex(dec)
	return string.format('%0x', math.floor(dec * 255))
end

local function makeGradient(geo, solid, transparent)
    return {
        type  = 'linear' ,
        from  = {
            0,
            geo.height
        },
        to = {
            geo.width,
            geo.height
        },
        stops = {
            {
                0,
                solid .. decToHex(0.9)
            },
            {
                0.4,
                solid .. decToHex(0.6)
            },
            {
                0.6,
                solid .. decToHex(0.6)
            },
            {
                0.9,
                solid .. decToHex(0.7)
            },
            {
                1,
                solid .. decToHex(0.9)
            }
        }
    }
end

local bottomInfo = wibox.widget {
	layout = wibox.layout.align.horizontal,
	expand = 'none',
	{
		layout = wibox.layout.fixed.horizontal,
		-- w.button {
		-- 	icon = 'power2',
		-- 	onClick = function() end,
		-- 	size = util.dpi(36)
		-- }
	},
	nil,
	{
		layout = wibox.layout.fixed.horizontal,
		spacing = util.dpi(8),
		{
			layout = wibox.layout.fixed.horizontal,
			--w.wifi { size = util.dpi(36) }
		},
		{
			layout = wibox.layout.fixed.horizontal,
			--w.battery { size = util.dpi(36) }
		},
		--w.icon {icon = 'notification', size = util.dpi(36)}
	}
}

local incorrectPass = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.fontName .. ' Medium Italic 12',
	markup = 'Incorrect Password',
	visible = false
}

local entryContentsLayout = wibox.layout.align.vertical()
entryContentsLayout.visible = false

local function unlock()
	locked = false

	lockscreenEntry.visible = false
	entryContentsLayout.visible = false
	incorrectPass.visible = false
	--passwordInput:unfocus()
	--passwordInput:set_text('')

	lockscreen:off()
	--root.keys(globalkeys)
end

lockscreenEntry:setup {
	layout = wibox.layout.stack,
	{
		widget = wibox.widget.imagebox,
		horizontal_fit_policy = 'cover',
		vertical_fit_policy = 'cover',
		valign = 'center',
		halign = 'center',
		image = gears.surface.load_uncached(settings.getConfig 'wallpaper'.lock.image, gears.filesystem.get_configuration_dir() .. '/assets/lotus-wallpaper.png'),
	},
	{
		widget = wibox.container.background,
		bg = makeGradient(scr.geometry, '#000000'),
		{
			widget = wibox.container.margin,
			margins = util.dpi(100),
			{
				layout = entryContentsLayout,
				expand = 'none',
				nil,
				{
					layout = wibox.layout.fixed.vertical,
					spacing = util.dpi(16),
					{
						layout = wibox.container.place,
						{
							-- w.imgwidget('avatar.jpg', {
							-- 	clip_shape = gears.shape.circle
							-- }),
							widget = wibox.container.constraint,
							strategy = 'exact',
							width = util.dpi(120),
							height = util.dpi(120)
						},
					},
					{
						layout = wibox.container.place,
						{
							layout = wibox.layout.fixed.vertical,
							{
								layout = wibox.layout.fixed.horizontal,
								{	
									widget = wibox.container.constraint,
									strategy = 'exact',
									width = util.dpi(250),
									{
										widget = wibox.container.background,
										bg = beautiful.backgroundSecondary,
										shape = util.rrect(beautiful.radius / 2),
										{
											widget = wibox.container.margin,
											margins = util.dpi(8),
											passwordInput
										}
									}
								},
								{
									widget = wibox.container.rotate,
									direction = 'east',
									-- w.button {
									-- 	icon = 'expand-more',
									-- 	bg = '#00000000',
									-- 	onClick = function()
									-- 		local authenticated = pam.auth_current_user(passwordInput:get_text())
									-- 		if authenticated then
									-- 			unlock()
									-- 		else
									-- 			incorrectPass.visible = true
									-- 		end
									-- 	end,
									-- 	size = util.dpi(32)
									-- }
								}
							},
							{
								widget = wibox.container.margin,
								left = util.dpi(8),
								incorrectPass
							}
						}
					}
				},
				bottomInfo
			}
		}
	}
}

-- helpers.slidePlacement(lockscreen, {
-- 	placement = function() end,
-- 	heights = {
-- 		hide = scr.geometry.height,
-- 		reveal = 0
-- 	},
-- 	invert = true,
-- 	open = false
-- })

ls = panels.create {
    widget = {
        layout = wibox.layout.stack,
        {
            widget = wibox.widget.imagebox,
            horizontal_fit_policy = 'cover',
            vertical_fit_policy = 'cover',
            valign = 'center',
            halign = 'center',
            image = gears.surface.load_uncached(settings.getConfig 'wallpaper'.lock.image, gears.filesystem.get_configuration_dir() .. '/assets/lotus-wallpaper.png'),
        },
        {
            widget = wibox.container.background,
            bg = makeGradient(scr.geometry, '#000000'),
            {
                widget = wibox.container.margin,
                margins = util.dpi(100),
                {
                    layout = wibox.layout.align.vertical,
                    expand = 'none',
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = util.dpi(8),
                        {
                            -- w.imgwidget('avatar.jpg', {
                            -- 	clip_shape = gears.shape.circle
                            -- }),
                            widget = wibox.container.constraint,
                            strategy = 'exact',
                            width = util.dpi(48),
                            height = util.dpi(48)
                        },
                        {
                            widget = wibox.widget.textbox,
                            -- markup = helpers.colorize_text(('roseberry'):gsub('(%a)([%w_\']*)', function(a, b) return a:upper() .. b:lower() end), beautiful.fg_normal),
                            font = beautiful.fontName .. ' Semibold 16'
                        }
                    },
                    {
                        layout = wibox.layout.fixed.vertical,
                        {
                            widget = wibox.widget.textclock,
                            format = '%-I:%M %p',
                            font = beautiful.fontName .. ' Bold 52',
                        },
                        {
                            widget = wibox.widget.textclock,
                            format = '%B %e',
                            font = beautiful.fontName .. ' Bold 52',
                        },
                        {
                            widget = wibox.widget.textclock,
                            -- format = helpers.colorize_text('%A', beautiful.fg_tert),
                            font = beautiful.fontName .. ' Bold 36',
                        }
                    },
                    bottomInfo
                }
            }
        }
    },
    height = 'screen',
    width = 'screen',
    attach = 'top',
    fullscreen = true
}

function M.locked()
	return locked
end

function M.lock()
	if locked then return end

    
	root.keys = {}
	locked = true
	lockscreenEntry.visible = true
	ls:on()
	entryContentsLayout.visible = true
	kg:start()
end

return M
