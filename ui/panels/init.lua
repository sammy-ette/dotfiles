local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local util = require 'sys.util'
local settings = require 'sys.settings'
local rubato = require 'libs.rubato'
local focus = require 'sys.focus'

local M = {}

-- @tparam[opt={}] table args
-- @tparam[opt] string args.attach Where the panel should be attached (position wise), either mouse, or top_right, bottom_left, etc.
-- @tparam[opt] table args.widget
-- @tparam[opt] string args.bg Color to use for the panel background
-- @tparam[opt] function args.shape Shape of the panel window
-- @tparam[opt] number args.radius Radius for rounded rectangle shape
-- @tparam[opt] boolean args.growHeight Should height be grown in animation or stay constant?
-- @tparam[opt] boolean args.growWidth Should width be grown in animation or stay constant?
-- @tparam[opt] boolean args.growPosition Where does the animation start from (relative to the panel's position).
function M.create(args)
	local function accumBars(position)
		local out = 0

		for _, bar in ipairs(awful.screen.focused().bar) do
			if position == bar.position then
				out = out + (bar.height or bar.width)
			end
		end

		return out
	end

	args.attach = args.attach or 'mouse'
	args.growHeight = args.growHeight == nil and true or args.growHeight
	args.growPosition = args.growPosition or 'auto'
	--args.invertShrink = true

	local panel = wibox {
		shape = args.fakeShape or util.rrect(args.radius or beautiful.radius),
		ontop = true,
		visible = false,
		--bg = args.bg or beautiful.panelBackground,
		bg = '#00000000',
		widget = wibox.widget {
			layout = wibox.container.constraint,
			strategy = 'exact',
			height = args.height,
			{
				layout = wibox.container.background,
				bg = args.bg or beautiful.panelBackground,
				shape = args.shape or util.rrect(args.radius),
				args.widget
			}
		},
		height = args.height ~= 'screen' and args.height or 1,
		width = args.width ~= 'screen' and args.width or 1,
		open = false,
	}

	function panel:resize()
		if args.height == 'screen' then
			local scr = awful.screen.focused()
			if args.fullscreen then
				panel.height = scr.geometry.height
			else
				panel.height = scr.geometry.height - (beautiful.useless_gap * 2) - accumBars 'top' - accumBars 'bottom'
			end
		end

		if args.width == 'screen' then
			local scr = awful.screen.focused()
			if args.fullscreen then
				panel.width = scr.geometry.width
			else
				panel.width = scr.geometry.width - (beautiful.useless_gap * 2) - accumBars 'left' - accumBars 'right'
			end
		end
	end

	local scr = awful.screen.focused()
	local function locateQuadrant(x, y)
		local isTop = y < (scr.geometry.height / 3)
		local isLeft = x < (scr.geometry.width / 3)
		local isCenterY = y > (scr.geometry.height / 3) and y < ((scr.geometry.height / 3) * 2)
		local isCenterX = x > (scr.geometry.width / 3) and x < ((scr.geometry.width / 3) * 2)
		--print 'center y, centerx, y, x'
		--print(isCenterY, isCenterX, y, x)
		local vertAlign = (isTop and 'top' or 'bottom')
		local horizAlign = (isLeft and 'left' or 'right')

		local alignTable = {vertAlign, horizAlign}
		if isCenterY then
			vertAlign = nil
			alignTable = {horizAlign}
		end
		if isCenterX then
			horizAlign = nil
			alignTable = {vertAlign}
		end

		return table.concat(alignTable, '_'), vertAlign, horizAlign
	end

	local function parseAlignments()
		local alignment, vert, horiz
		if args.attach == 'mouse' then
			local mc = mouse.coords()
			alignment, vert, horiz = locateQuadrant(mc.x, mc.y)
		else
			alignment = args.attach
			vert = args.attach:match '([%w]+)'
			horiz = args.attach:match '_([%w]+)'
		end

		return alignment, vert, horiz
	end

	function panel:align(reposition)
		if reposition then
		elseif args.method == 'pos' and panel.revealHeight then
			return
		end

		local alignment, vert = parseAlignments()
		awful.placement.align(panel, {
			position = alignment,
			margins = {
				left = beautiful.useless_gap + accumBars 'left',
				right = beautiful.useless_gap + accumBars 'right',
				top = beautiful.useless_gap + accumBars 'top',
				bottom = beautiful.useless_gap + accumBars 'bottom'
			},
			-- honor_workarea = true,
			-- honor_padding = true
		})
		panel.alignment = alignment

		if args.method == 'pos' then
			if alignment == 'left' then
				local buffer = 0
				local scr = awful.screen.focused()
				for _, bar in ipairs(scr.bar) do
					if bar.position == 'top' or bar.position == 'bottom' then
						buffer = buffer + bar.height
					end
				end
				panel.y = beautiful.useless_gap
			end

			local buffer = barIdx and scr.bar[barIdx].height or 0
			--local hideHeight, revealHeight
			if vert == 'top' then
				panel.hideHeight = -args.height
				panel.revealHeight = beautiful.useless_gap + buffer
			elseif vert == 'bottom' then
				panel.hideHeight = scr.geometry.height - beautiful.useless_gap - buffer
				panel.revealHeight = scr.geometry.height - args.height - beautiful.useless_gap - buffer
			end

			if alignment == 'left' then
				panel.hideWidth = -args.width
				panel.revealWidth = beautiful.useless_gap + buffer
			end

			if vert == 'bottom' and panel.open then
				--panel.y = panel.hideHeight
			end
		end
	end

	function panel:animator()
		if args.method == 'pos' then
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

		local scr = awful.screen.focused()
		local gears = require 'gears'
		local _, vert = parseAlignments()
		return rubato.timed {
			duration = 0.4,
			rate = 120,
			override_dt = true,
			subscribed = function(p)
				local shape = args.fakeShape or util.rrect(args.radius or beautiful.radius)
				panel.shape = function(cr, w, h)
					-- so, overriding the shape variable causes the draw to lag behind the shape anim.. for some reason
					-- so it has to be local.
					if (args.growPosition == 'auto' and vert == 'bottom') or args.growPosition == 'bottom' then
						local shape = gears.shape.transform(shape):scale(1, -1):translate(0, -h)
						shape(cr, args.growWidth and w * (p/100) or w, args.growHeight and h * (p/100) or h)
					else
						shape(cr, args.growWidth and w * (p/100) or w, args.growHeight and h * (p/100) or h)
					end
					panel:emit_signal 'widget::redraw_needed'
				end

				if p == 0 then
					panel.visible = false
				end

				if panel.open and p == panel.revealHeight and panel.revealed then
					panel:revealed()
				end
			end,
			pos = panel.open and 0 or 100
		}
	end

	function panel:toggle(opts)
		--if panel.screen ~= awful.screen.focused() then panel.open = false end
		if panel.open then
			panel:off(opts)
		else
			panel:on(opts)
		end
		panel.screen = awful.screen.focused()
	end

	function panel:on(opts)
		opts = opts or {}
		panel.open = true
		local oldHeight = panel.height
		panel:resize()
		if args.attach == 'mouse' then
			if opts.context and opts.context == 'mouse' then
				panel:align()
			end
		else
			panel:align()
		end

		if args.manage then
			args.manage(panel, panel.open)
		end

		local animator = panel:animator()
		if args.method == 'pos' then
			animator.target = panel.revealHeight and panel.revealHeight or panel.revealWidth
		else
			animator.target = 100
		end
		panel.visible = true
	end

	function panel:off()
		panel.open = false
		--panel:resize()
		--panel:align()

		if args.manage then
			args.manage(panel, panel.open)
		end

		local animator = panel:animator()
		if args.method == 'pos' then
			animator.target = panel.hideHeight and panel.hideHeight or panel.hideWidth
		else
			animator.target = 0
		end
	end

	focus.autoHide(function()
		if panel.open then
			panel:off()
		end
	end)

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
