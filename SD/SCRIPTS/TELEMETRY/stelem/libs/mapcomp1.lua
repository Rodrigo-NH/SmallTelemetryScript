
local function coordsNorm(centeroffsetX, centeroffsetY, Xmax,Xmin,Ymax,Ymin, ucommand, ucommand2, zoomscale, usroptlist, usroptlist2, zoomFactor, shared)
    -- coordinates normalization
    local xDiff = Xmax - Xmin
    local yDiff = Ymax - Ymin

    local xScale = xDiff / shared.screenW
    local yScale = yDiff / shared.screenH

    local baseScaleX = shared.screenW / xDiff
    local baseScaleY = shared.screenH / yDiff

    local baseScale = 0
    if yScale > xScale then
        baseScale = baseScaleY
    else
        baseScale = baseScaleX
    end

    baseScale = baseScale - (baseScale * zoomscale)


    local centerY = math.floor((shared.screenH - (yDiff * baseScale)) / 2)
    local centerX = math.floor((shared.screenW - (xDiff * baseScale)) / 2)

    -- Translate to screen
    for t = 1, #shared.coords
    do
        local destX = ((shared.coords[t][5] - Xmin) * baseScale) + centerX
        local destY = ((shared.coords[t][4] - Ymin) * baseScale) + centerY

        local function centerOffset()
            centeroffsetX = shared.screenW / 2 - destX
            centeroffsetY = shared.screenH / 2 - destY
        end

        if ucommand2 == 1 then
            shared.gotonav = usroptlist2[2]
            ucommand2 = 0
        elseif ucommand2 == 2 then
            shared.gotonav = nil
        end

        local scaleupdate = false
        if ucommand == 2 and usroptlist[2] == t then
            centerOffset()
        elseif ucommand == 3 and t == #shared.coords then
            xDiff, yDiff, scaleupdate, zoomscale = shared.geo.WPsp(shared, xDiff, yDiff, usroptlist, zoomscale, zoomFactor)
            if scaleupdate then
                centerOffset()
            end
        elseif t == 1 and ucommand == 6 then
            centerOffset()
        elseif ucommand == 7 then
            centeroffsetX = 0
            centeroffsetY = 0
        elseif ucommand == 8 and t == #shared.coords - 1 and shared.coords[t][2] ~= 0 then
            centerOffset()
        elseif ucommand == 9 and t == #shared.coords - 1 and shared.coords[t][2] ~= 0 then
            centerOffset()
            shared.mapState[2] = 0
        elseif ucommand == 4 then
            zoomscale = 0.1
            centeroffsetX = 0
            centeroffsetY = 0
            shared.mapState[2] = 0
        elseif ucommand == 1 and t == #shared.coords then
            xDiff, yDiff, scaleupdate, zoomscale = shared.geo.WPsp(shared, xDiff, yDiff, usroptlist, zoomscale, zoomFactor)
            centerOffset()
            zoomscale = 0.1
            shared.mapState[2] = 3
        end
        shared.coords[t][7] = destX + centeroffsetX
        shared.coords[t][6] = destY + centeroffsetY
    end

    return ucommand2, zoomscale, baseScale, centeroffsetX, centeroffsetY

end


return {
    coordsNorm=coordsNorm,
}