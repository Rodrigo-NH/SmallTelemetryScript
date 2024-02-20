local shared = ...
local gfx = shared.stelemLoadLua("/SCRIPTS/TELEMETRY/stelem/graphics.lua")

function shared.run(event)
  lcd.clear()

  gfx.heartbeat(1, 37, 24, 10, shared)
  gfx.vario(123, 0, 5, 40, shared)
  gfx.attitudeIndicator(78, 0, 45, 39, 70, shared)
  gfx.homeArrow(9, 17, 9, shared)

  local xalign = 31
  lcd.drawText(xalign, 0, "mAh: " .. tostring(shared.stelemTelem.batt1mah), SMLSIZE)
  lcd.drawText(xalign, 7, "Alt: " .. tostring(shared.stelemTelem.homeAlt), SMLSIZE)

  local cellvolt = shared.stelemGetConfig(1)
  local dividefactor = 1
  if cellvolt == "True" then
    dividefactor = tonumber(shared.stelemGetConfig(2))
  end

  local battvolt = tostring(shared.stelemTelem.batt1volt / dividefactor)
  battvolt = string.format("%.2f", battvolt)

  lcd.drawText(xalign, 14, "Volt: " .. battvolt, SMLSIZE)
  lcd.drawText(xalign, 21, "Hdop: " .. tostring(shared.stelemTelem.gpsHdopC / 10), SMLSIZE)
  lcd.drawText(xalign, 28, "Nsat: " .. tostring(shared.stelemTelem.numSats), SMLSIZE)

  lcd.drawText(80, 40, shared.stelemFrame.flightModes[shared.stelemTelem.flightMode], SMLSIZE)
  lcd.drawFilledRectangle(78, 39, 50, 10, GREY_DEFAULT)
  -- -- ALERT MESSAGES --
  lcd.drawText(0, 50, shared.stelemAlertmessages[2], SMLSIZE)
  lcd.drawText(0, 57, shared.stelemAlertmessages[1], SMLSIZE)
  -- -- ALERT MESSAGES --
  lcd.drawText(xalign, 35, "Throt: " .. tostring(shared.stelemTelem.throttle), SMLSIZE)
  lcd.drawText(xalign, 42, "RSSI: " .. tostring(shared.stelemTelem.RSSI), SMLSIZE)
  lcd.drawText(0, 28, "y:" .. tostring(shared.stelemTelem.yaw), SMLSIZE)
  lcd.drawText(0, 0, "h:" .. tostring(shared.stelemTelem.homeDist), SMLSIZE)
  lcd.drawLine(0, 48, 77, 48, SOLID, FORCE)



  if event == EVT_VIRTUAL_NEXT then
    shared.stelemCycleScreen(1)
  elseif event == EVT_VIRTUAL_PREV then
    shared.stelemCycleScreen(-1)
  elseif event == EVT_VIRTUAL_ENTER then
    shared.stelemLoadScreen(shared.stelemConfigmenu)
  end
end

