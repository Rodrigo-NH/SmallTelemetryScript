local function scaleCalc(sh, distPointsPlane, distPoints)
    local shared = sh
    local scale = 0
    local groundScaleDistance = 0
    if #shared.coords > 3 and groundScaleDistance == 0 then
        if shared.coords[2][1] ~= 16 then     -- Check wp1 is relative to command (dont contain coordinates)
            scalebump = 3
        else
            scalebump = 2
        end
        groundScaleDistance = distPoints(shared.coords[1][2], shared.coords[1][3], shared.coords[scalebump][2],
            shared.coords[scalebump][3])
    end
    if #shared.coords > 3 then
        local screenDistance = distPointsPlane(shared.coords[1][7], shared.coords[1][6], shared.coords[scalebump][7],
            shared.coords[scalebump][6]) * shared.pixelSize / 1000     -- meters
        scale = math.floor(groundScaleDistance / screenDistance)
        if screenDistance > 0 then
            scale = scale
        else
            scale = 0
        end
    end
    return scale
end

return {
    scaleCalc = scaleCalc,
}
