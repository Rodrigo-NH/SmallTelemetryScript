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
    showText(align, yalign, "YAW ", shared.tel.yaw, 0)
    showText(align, yalign, "HDG ", shared.tel.hdg, 0)
    showText(align, yalign, "HDGV ", shared.hdgVel, 1)
    showText(align, yalign, "goto ", shared.gotoangle, 1)

    yalign = 0

    sup.defaultActions(event, shared)
end
