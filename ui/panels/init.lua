local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local util = require 'sys.util'
local settings = require 'sys.settings'
local rubato = require 'libs.rubato'

local M = {}

-- @tparam[opt={}] table args
-- @tparam[opt] string args.attach Where the panel should be attached (position wise), either mouse, or top_right, bottom_left, etc.
-- @tparam[opt] string args.widget
-- @tparam[opt] string args.bg Color to use for the panel background
-- @tparam[opt] string args.shape Shape of the panel window
-- @tparam[opt] string args.radius Radius for rounded rectangle shape
function M.create(args)
	--local panel = M.wibox(args)
	--panel:setup(args.widget)
	--TODO: handle margins and positions properly for bars on left/right
	args.attach = args.attach or 'mouse'
	local panel = wibox {
		shape = args.fakeShape or util.rrect(args.radius or beautiful.radius),
		ontop = true,
		visible = false,
		--bg = args.bg or beautiful.panelBackground,
		bg = '#00000000',
		widget = wibox.widget {
			layout = wibox.container.background,
			bg = args.bg or beautiful.panelBackground,
			shape = args.shape or util.rrect(args.radius),
			args.widget
		},
		height = args.height ~= 'screen' and args.height or 1,
		width = args.width,
		open = false,
	}

	function panel:resize()
		if args.height == 'screen' then
			local buffer = 0
			local scr = awful.screen.focused()
			for _, bar in ipairs(scr.bar) do
				buffer = buffer + bar.height
			end
			panel.height = scr.geometry.height - beautiful.useless_gap - beautiful.useless_gap - buffer
		end
	end

	function panel:align(barIdx, reposition)
		if reposition then
		elseif panel.revealHeight then
			return
		end

		local scr = awful.screen.focused()
		local function locateQuadrant(x, y)
			local isTop = y < (scr.geometry.height / 2)
			local isLeft = x < (scr.geometry.width / 2)
			local vertAlign = (isTop and 'top' or 'bottom')
			local horizAlign = (isLeft and 'left' or 'right')

			return vertAlign .. '_' .. horizAlign, vertAlign, horizAlign
		end

		local alignment, vert
		if args.attach == 'mouse' then
			local mc = mouse.coords()
			alignment, vert = locateQuadrant(mc.x, mc.y)
		else
			alignment = args.attach
			vert = args.attach:match '([%w]+)'
		end
		awful.placement.align(panel, {
			position = alignment,
			margins = {
				left = beautiful.useless_gap,
				right = beautiful.useless_gap,
				top = beautiful.useless_gap,
				bottom = beautiful.useless_gap
			},
			--honor_workarea = true,
			--honor_padding = true
		})
		if alignment == 'left' then
			--[[
			local buffer = 0
			local scr = awful.screen.focused()
			for _, bar in ipairs(scr.bar) do
				if bar.position == 'top' or bar.position == 'bottom' then
					buffer = buffer + bar.height
				end
			end
			]]--
			panel.y = beautiful.useless_gap
		end

		local buffer = barIdx and scr.bar[barIdx].height or 0
		--local hideHeight, revealHeight
		if vert == 'top' then
			panel.hideHeight = -args.height
			panel.revealHeight = beautiful.useless_gap + buffer
		elseif vert == 'bottom' then
			panel.hideHeight = scr.geometry.height
			panel.revealHeight = scr.geometry.height - args.height - beautiful.useless_gap - buffer
		end

		if alignment == 'left' then
			panel.hideWidth = -args.width
			panel.revealWidth = beautiful.useless_gap + buffer
		end

		if vert == 'bottom' and panel.open then
			panel.y = panel.hideHeight
		end
	end

	function panel:animator(barIdx)
		return rubato.timed {
			duration = 0.25,
			rate = 120,
			override_dt = true,
			subscribed = function(p)
				if panel.hideWidth then
					panel.x = p
				else
					panel.y = p
				end

				if panel.hideHeight and p == panel.hideHeight then
					panel.visible = false
				elseif panel.hideWidth and p == panel.hideWidth then
					panel.visible = false
				end

				if panel.open and p == panel.revealHeight and panel.revealed then
					panel:revealed()
				end
			end,
			pos = panel.open and (panel.hideHeight and panel.hideHeight or panel.hideWidth) or (panel.revealHeight and panel.revealHeight or panel.revealWidth)
		}
	end

	function panel:toggle(barIdx)
		if panel.open then
			panel:off(barIdx)
		else
			panel:on(barIdx)
		end
	end

	function panel:on(barIdx)
		panel.open = true
		local oldHeight = panel.height
		panel:resize()
		panel:align(barIdx, oldHeight)

		if panel.manage then
			panel:manage(panel.open)
		end

		local animator = panel:animator()
		animator.target = panel.revealHeight and panel.revealHeight or panel.revealWidth
		panel.visible = true
	end

	function panel:off(barIdx)
		panel.open = false
		panel:align(barIdx)

		if panel.manage then
			panel:manage(panel.open)
		end

		local animator = panel:animator()
		animator.target = panel.hideHeight and panel.hideHeight or panel.hideWidth
	end

	return panel
end

function M.wibox(opts)
	local bg = opts.bg

	opts.bg = '#00000000'
	if opts.radius then
		opts.bg = bg
		opts.shape = util.rrect(opts.radius / 1.3)
	end

	local wbx = wibox(opts)
	wbx.popup = opts.popup

	local oldSetup = wbx.setup
	function wbx:setup(wid)
		local setupWidget = wibox.widget {
			widget = wibox.container.background,
			shape = util.rrect(opts.radius),
			forced_height = wbx.height,
			forced_width = wbx.width,
			wid
		}
		oldSetup(wbx, {
			layout = wibox.container.place,
			setupWidget
		})
	end
	return wbx
end

return M
