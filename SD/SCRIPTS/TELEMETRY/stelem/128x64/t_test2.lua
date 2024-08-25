local shared = ...

local yalign = 0
local sup = shared.LoadLua(shared.libsDir .. "common.lua")

local function showText(x1, y1, text, value, decplaces)
    lcd.drawText(x1, y1, text .. shared.nbformat(value, decplaces), SMLSIZE)
    yalign = yalign + 8
end

function shared.run(event)
    lcd.clear()
    shared.tel.RSSI = 10.3
    local align = 0
    showText(align, yalign, "gpsStatus ", shared.tel.gpsStatus, 0)
    showText(align, yalign, "batt1volt ", shared.tel.batt1volt, 0)
    showText(align, yalign, "batt1mah ", shared.tel.batt1mah, 1)
    showText(align, yalign, "wpNumber ", shared.tel.wpNumber, 1)
    showText(align, yalign, "bat1curr. ", shared.tel.batt1current, 1)
    showText(align, yalign + 5, "lat ", shared.tel.lat, 6)
    showText(align, yalign + 5, "lon ", shared.tel.lon, 6)


    align = 70
    yalign = 0
    showText(align - 4, yalign, "wpDistance ", shared.tel.wpDistance, 1)
    showText(align - 4, yalign, "wpBearing ", shared.tel.wpBearing, 1)
    showText(align - 4, yalign, "homeDist ", shared.tel.homeDist, 1)
    showText(align - 4, yalign, "homeAngle ", shared.tel.homeAngle, 1)
    showText(align, yalign, "throttle ", shared.tel.throttle, 0)



    yalign = 0

    sup.defaultActions(event, shared)
end
