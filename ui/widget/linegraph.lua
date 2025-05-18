-- thanks delta!
-- https://git.twoexem.com/delta/dots.git/tree/.config/awesome/ui/statusbar/panel/widgets/linegraph.lua

local gcolor = require 'gears.color'
local gtable = require 'gears.table'
local wibox = require 'wibox'

local linegraph = { mt = {} }

function linegraph:fit(_, width, height)
    if #self._private.values < 2 then
        return 0, 0
    end
    return width, height
end

function linegraph:draw(_, cr, width, height)
    if #self._private.values < 2 then
        return
    end
    local line_width = self._private.line_width
    local values = self._private.values

    local max, min = self._private.max or 0, self._private.min or 0
    if not (self._private.max and self._private.min) then
        for _, value in ipairs(values) do
            if not self._private.max then
                max = max < value and value or max
            end
            if not self._private.min then
                min = min > value and value or min
            end
        end
    end

    local usable_height = height - line_width
    local min_abs = math.abs(min)
    local h_factor = usable_height / (min_abs + max)

    local function transform(value)
        return usable_height - math.floor((value + min_abs) * h_factor) + line_width / 2
    end

    local graph_values = {}
    for i = 1, #values, math.ceil(#values / width) do
        table.insert(graph_values, transform(values[i]))
    end

    if self._private.draw_bg then
        cr:save()
        self._private.draw_bg(cr, width, height, min, max, transform)
        cr:restore()
    end

    cr:set_line_width(line_width)
    cr:set_source(gcolor(self.color))
    cr:move_to(line_width / 2, graph_values[1])
    for i = 2, #graph_values do
        cr:line_to((width - line_width / 2) / (#graph_values - 1) * (i - 1), graph_values[i])
    end

    if self._private.fill then
        cr:line_to(width - line_width / 2, transform(min))
        cr:line_to(line_width / 2, transform(min))
        cr:line_to(line_width / 2, graph_values[1])
        cr:stroke_preserve()
        cr:set_source(gcolor(self.fill_color))
        cr:fill()
    else
        cr:stroke()
    end
end

function linegraph:set_values(values)
    self._private.values = values
    self:emit_signal 'widget::redraw_needed'
end

function linegraph:add_value(value)
    table.insert(self._private.values, value)
    self:emit_signal 'widget::redraw_needed'
end

function linegraph:get_values()
    return self._private.values
end

function linegraph:set_draw_bg(draw_bg)
    self._private.draw_bg = draw_bg
    self:emit_signal 'widget::redraw_needed'
end

function linegraph:get_draw_bg()
    return self._private.draw_bg
end

function linegraph:set_max(max)
    self._private.max = max
    self:emit_signal 'widget::redraw_needed'
end

function linegraph:get_max()
    return self._private.max
end

function linegraph:set_min(min)
    self._private.max = min
    self:emit_signal 'widget::redraw_needed'
end

function linegraph:get_min()
    return self._private.min
end

function linegraph:set_line_width(line_width)
    self._private.line_width = line_width
    self:emit_signal 'widget::redraw_needed'
end

function linegraph:set_color(color)
    self._private.color = color
    self:emit_signal 'widget::redraw_needed'
end

function linegraph:get_color()
    return self._private.color
end

function linegraph:set_fill_color(fill_color)
    self._private.fill_color = fill_color
    self:emit_signal 'widget::redraw_needed'
end

function linegraph:get_fill_color()
    return self._private.fill_color
end

function linegraph:set_fill(fill)
    self._private.fill = fill
    self:emit_signal 'widget::redraw_needed'
end

function linegraph:get_fill()
    return self._private.fill
end

local function new(args)
    args = args or {}
    local ret = wibox.widget.base.make_widget(nil, nil, { enable_properties = true })
    gtable.crush(ret, linegraph, true)

    ret.line_width = args.line_width or 1
    ret.color = args.color or '#ffffff'
    ret.fill_color = args.fill_color or '#000000'
    ret.fill = args.fill or false

    return ret
end

function linegraph.mt:__call(args)
    return new(args)
end

return setmetatable(linegraph, linegraph.mt)
