local shape = {}

function shape.rounded_rect(cr, width, height, corners, rad)
    rad = rad or 10
    if width / 2 < rad then
        rad = width / 2
    end

    if height / 2 < rad then
        rad = height / 2
    end

    -- In case there is already some other path on the cairo context:
    -- Make sure the close_path() below goes to the right position.
    cr:new_sub_path()

    -- Top left
    if corners.tl then
        local crad
        if type(corners.tl) == 'number' then
            crad = corners.tl
        else
            crad = rad
        end
        cr:arc( crad, crad, crad, math.pi, 3*(math.pi/2))
    else
        cr:move_to(0,0)
    end

    -- Top right
    if corners.tr then
        local crad
        if type(corners.tr) == 'number' then
            crad = corners.tr
        else
            crad = rad
        end
        cr:arc( width-crad, crad, crad, 3*(math.pi/2), math.pi*2)
    else
        cr:line_to(width, 0)
    end

    -- Bottom right
    if corners.br then
        local crad
        if type(corners.br) == 'number' then
            crad = corners.br
        else
            crad = rad
        end
        cr:arc( width-crad, height-crad, crad, math.pi*2 , math.pi/2)
    else
        cr:line_to(width, height)
    end

    -- Bottom left
    if corners.bl then
        local crad
        if type(corners.bl) == 'number' then
            crad = corners.bl
        else
            crad = rad
        end
        cr:arc( crad, height-crad, crad, math.pi/2, math.pi)
    else
        cr:line_to(0, height)
    end

    cr:close_path()
end

return shape
