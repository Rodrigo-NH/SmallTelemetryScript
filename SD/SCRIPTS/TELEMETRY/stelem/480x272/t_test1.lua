local shared = ...

local yalign = 0
local sup = shared.LoadLua(shared.libsDir .. "common.lua")

local function showText(x1,y1,text,value,decplaces)    
    lcd.drawText(x1, y1, text .. shared.nbformat(value, decplaces) , SMLSIZE)
    yalign = yalign + 20
end

function shared.run(event)
    lcd.clear()
    shared.tel.RSSI = 10.3
    local align = 0
    showText(align,yalign,"RSSI ",shared.tel.RSSI,0)
    showText(align,yalign,"txpower ",shared.tel.txpower,0)
    showText(align,yalign,"alt ",shared.tel.alt,1)
    showText(align,yalign,"homeAlt ",shared.tel.homeAlt,1)
    showText(align,yalign,"battpercent ",shared.tel.battpercent,1)
    showText(align,yalign,"roll ",shared.tel.roll,1)
    showText(align,yalign,"pitch ",shared.tel.pitch,1)
    showText(align,yalign,"yaw ",shared.tel.yaw,1)
    showText(align,yalign,"hdg ",shared.tel.hdg,1)
    showText(align,yalign,"hdgVel ",shared.hdgVel,1)
    showText(align,yalign,"vSpeed ",shared.tel.vSpeed,1)
    showText(align,yalign,"statusArmed ",shared.tel.statusArmed,1)
    
    
    align = 150
    yalign = 0
    showText(align,yalign,"hSpeed ",shared.tel.hSpeed,1)
    showText(align,yalign,"vSpeed ",shared.tel.vSpeed,1)
    showText(align,yalign,"numSats ",shared.tel.numSats,0)
    showText(align,yalign,"gpsHdopC ",shared.tel.gpsHdopC,1)
    showText(align,yalign,"gpsStatus ",shared.tel.gpsStatus,0)
    showText(align,yalign,"batt1volt ",shared.tel.batt1volt,0)    
    showText(align,yalign,"batt1mah ",shared.tel.batt1mah,1)    
    showText(align,yalign,"wpNumber ",shared.tel.wpNumber,1)
    showText(align,yalign,"wpDistance ",shared.tel.wpDistance,1)
    showText(align,yalign,"wpBearing ",shared.tel.wpBearing,1)
    showText(align,yalign,"batt1current ",shared.tel.batt1current,1)
    showText(align,yalign,"throttle ",shared.tel.throttle,1)


    align = 280
    yalign = 0
    showText(align,yalign,"homeDist ",shared.tel.homeDist,1)
    showText(align,yalign,"homeAngle ",shared.tel.homeAngle,1)
    showText(align,yalign,"lat ",shared.tel.lat,6)
    showText(align,yalign,"lon ",shared.tel.lon,6)
    

    yalign = 0

    sup.defaultActions(event, shared)
end