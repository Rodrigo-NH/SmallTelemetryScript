local shared = ...
local gfx = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/graphics.lua")

function shared.run(event)
  lcd.clear()

  gfx.heartbeat(1, 37, 24, 10, shared)
  gfx.vario(123, 0, 5, 40, shared)
  gfx.attitudeIndicator(78, 0, 45, 39, 70, shared)
  gfx.homeArrow(9, 17, 9, shared)
  gfx.armedIndicator(79, 31, 1, shared)

  local xalign = 31
  lcd.drawText(xalign, 0, "mAh: " .. tostring(shared.tel.batt1mah), SMLSIZE)
  lcd.drawText(xalign, 7, "Alt: " .. tostring(shared.tel.homeAlt), SMLSIZE)
  
  local battvolt = tostring(shared.tel.batt1volt)
  battvolt = string.format("%.2f", battvolt)

  lcd.drawText(xalign, 14, "Volt: " .. battvolt, SMLSIZE)
  lcd.drawText(xalign, 21, "Hdop: " .. tostring(shared.tel.gpsHdopC / 10), SMLSIZE)
  lcd.drawText(xalign, 28, "Nsat: " .. tostring(shared.tel.numSats), SMLSIZE)

  lcd.drawText(80, 40, shared.Frame.flightModes[shared.tel.flightMode], SMLSIZE)
  lcd.drawFilledRectangle(78, 39, 50, 10, GREY_DEFAULT)
  -- -- ALERT MESSAGES --
  lcd.drawText(0, 50, shared.Alertmessages[2], SMLSIZE)
  lcd.drawText(0, 57, shared.Alertmessages[1], SMLSIZE)
  -- -- ALERT MESSAGES --
  lcd.drawText(xalign, 35, "Throt: " .. tostring(shared.tel.throttle), SMLSIZE)
  lcd.drawText(xalign, 42, "RSSI: " .. tostring(shared.tel.RSSI), SMLSIZE)
  lcd.drawText(0, 28, "y:" .. tostring(shared.tel.yaw), SMLSIZE)
  lcd.drawText(0, 0, "h:" .. tostring(shared.tel.homeDist), SMLSIZE)
  lcd.drawLine(0, 48, 77, 48, SOLID, FORCE)



  if event == EVT_VIRTUAL_NEXT or event == 99 then
    shared.CycleScreen(1)
  elseif event == EVT_VIRTUAL_PREV or event == 98 then
    shared.CycleScreen(-1)
  elseif event == EVT_VIRTUAL_ENTER then
    shared.LoadScreen(shared.Configmenu)
  elseif event == 70 then -- Hold Page button
    shared.LoadScreen(shared.Screens[2])
  end
end

