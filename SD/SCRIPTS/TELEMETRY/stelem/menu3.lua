local shared = ...
local gfx = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/graphics.lua")

function shared.run(event)
  lcd.clear()

  gfx.attitudeIndicator(0, 4, 39, 35, 40, shared)
  gfx.vario(0, 5, 5, 34, shared)
  gfx.heartbeat(1, 0, 38, 5, shared)
  gfx.homeArrow(20, 11, 5, shared)
  gfx.armedIndicator(6, 31, 1, shared)

  local xalign = 41
  local battvolt = tostring(shared.tel.batt1volt)
  battvolt = string.format("%.2f", battvolt)
  lcd.drawText(xalign, 0, "V:" .. battvolt, SMLSIZE + INVERS)
  lcd.drawText(xalign, 8, "Ns: " .. tostring(shared.tel.numSats), SMLSIZE)
  lcd.drawText(xalign, 16, "A:" .. tostring(shared.tel.homeAlt), SMLSIZE + INVERS)
  lcd.drawText(xalign, 24, "T:" .. tostring(shared.tel.throttle), SMLSIZE)
  lcd.drawText(xalign, 32, "R:" .. tostring(shared.tel.RSSI), SMLSIZE + INVERS)

  xalign = 0
  lcd.drawText(xalign, 40, "Hd:" .. tostring(shared.tel.homeDist), SMLSIZE)
  lcd.drawText(xalign, 48, "Yaw:" .. tostring(shared.tel.yaw), SMLSIZE)
  lcd.drawText(xalign, 56, "Hdop:" .. tostring(shared.tel.gpsHdopC / 10), SMLSIZE)
  lcd.drawLine(70, 0, 70, 64, SOLID, FORCE)

  lcd.drawText(71, 57, shared.Frame.flightModes[shared.tel.flightMode], SMLSIZE + INVERS )

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

