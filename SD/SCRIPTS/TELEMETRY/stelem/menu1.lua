local shared = ...
local lasthb = 0
local hbc = 0

function shared.run(event)
  lcd.clear()

  function heartbeat()
    local rx1 = 1
    local ry1 = 37
    local rw = 24
    local rh = 10
    local hstep = rw / 3

    if lasthb ~= telemheartbeat then
      lasthb = telemheartbeat
      hbc = hbc + 1
      if hbc > 3 then
        hbc = 0
      end
    end
    local hb = 0
    hb = hb + 1

    if hbc == 0 then
      lcd.drawFilledRectangle(rx1, ry1, hstep + 1, rh, GREY_DEFAULT)
    end
    lcd.drawRectangle(rx1, ry1, hstep + 1, rh, SOLID)
    if hbc == 1 then
      lcd.drawFilledRectangle(rx1 + hstep, ry1, hstep + 1, rh, GREY_DEFAULT)
    end
    lcd.drawRectangle(rx1 + hstep, ry1, hstep + 1, rh, SOLID)
    if hbc == 2 then
      lcd.drawFilledRectangle(rx1 + hstep * 2, ry1, hstep + 1, rh, GREY_DEFAULT)
    end
    lcd.drawRectangle(rx1 + hstep * 2, ry1, hstep + 1, rh, SOLID)
  end

  function vario()
    local vSClipUp = tonumber(shared.getConfig(3))
    local vSClipDo = vSClipUp * -1

    local vSpeed = telemetry.vSpeed
    local rx1 = 123
    local ry1 = 0
    local rw = 5
    local rh = 40
    local screenH = rh
    local clipUpf = (screenH / 2) / (vSClipUp)
    local clipDof = (screenH / 2) / (math.abs(vSClipDo))
    lcd.drawFilledRectangle(rx1, ry1, rw, rh / 2 - 1, GREY_DEFAULT)
    lcd.drawFilledRectangle(rx1, ry1 + rh / 2, rw, rh / 2 - 1, GREY_DEFAULT)

    local rx2 = rx1 + 1
    local rw2 = rw - 2
    local rh2 = 3

    local vpos = 0
    if vSpeed > 0 then
      vpos = (ry1 + screenH / 2) - clipUpf * vSpeed - (rh2 / 2)
    elseif vSpeed < 0 then
      vpos = (ry1 + screenH / 2) + clipDof * math.abs(vSpeed) - (rh2 / 2)
    elseif vSpeed == 0 then
      vpos = (ry1 + screenH / 2) - rh2 / 2
    end

    if vpos < ry1 then
      vpos = ry1 + 1
    elseif vpos > ry1 + rh - rh2 then
      vpos = (ry1 + rh) - rh2 - 2
    end

    lcd.drawFilledRectangle(rx2, vpos, rw2, rh2, GREY_DEFAULT)    
  end

  function attitudeIndicator()
    -- Get scale value from configurations
    local scaleFactor = tonumber(shared.getConfig(4))

    -- local scaleFactor = 90 -- Value must be between 90 and 180
    local pitch = telemetry.pitch
    local roll = telemetry.roll * -1 -- oops

    if pitch >= scaleFactor / 2 then
      pitch = scaleFactor / 2 - 1
    end

    local retangleXstart = 78
    local retangleYstart = 0
    local retangleWidth = 45
    local retangleHeight = 39
    local crossweight = 2
    local halfX = retangleWidth / 2
    local halfY = retangleHeight / 2
    local pitchFactor = retangleHeight / scaleFactor
    local pitchWeight = pitchFactor * pitch + halfY
    local pitchR = retangleHeight - pitchWeight
    local test1 = halfX * math.tan(math.rad(roll))

    SX1 = retangleXstart + retangleWidth
    SY1 = retangleYstart + pitchWeight - test1
    SX2 = retangleXstart
    SY2 = retangleYstart + pitchWeight + test1

    if test1 > pitchWeight then
      SY1 = retangleYstart
      local delta = (test1 - pitchWeight) / math.tan(math.rad(roll))
      SX1 = (retangleXstart + retangleWidth) - delta
    elseif test1 < 0 and math.abs(test1) > pitchR then
      SY1 = retangleYstart + retangleHeight
      local bzin = test1 - pitchR
      local delta = bzin / math.tan(math.rad(roll))
      SX1 = retangleXstart + delta
    end

    if test1 > pitchR then
      SY2 = retangleYstart + retangleHeight
      local delta = (test1 - pitchR) / math.tan(math.rad(roll))
      SX2 = retangleXstart + delta
    elseif test1 < 0 and math.abs(test1) > pitchWeight then
      SY2 = retangleYstart
      local bzin = test1 - pitchWeight
      local delta = bzin / math.tan(math.rad(roll))
      SX2 = (retangleXstart + retangleWidth) - delta
    end

    SX1 = math.floor(SX1)
    SY1 = math.floor(SY1)
    SX2 = math.floor(SX2)
    SY2 = math.floor(SY2)

    coordsX = { SX1, SX2 }
    coordsY = { SY1, SY2 }

    for i = 1, 2 do
      if coordsX[i] >= retangleXstart + retangleWidth then
        coordsX[i] = retangleXstart + retangleWidth - 3
      end
      if coordsX[i] <= retangleXstart then
        coordsX[i] = retangleXstart + 2
      end
    end

    for i = 1, 2 do
      if coordsY[i] >= retangleYstart + retangleHeight then
        coordsY[i] = retangleYstart + retangleHeight - 1
      end
      if coordsY[i] <= retangleYstart then
        coordsY[i] = retangleYstart + 1
      end
    end

    local ftype = FORCE
    if math.abs(roll) > 90 then
      lcd.drawFilledRectangle(retangleXstart, retangleYstart, retangleWidth, retangleHeight, GREY_DEFAULT)
      ftype = ERASE
    else
      lcd.drawRectangle(retangleXstart, retangleYstart, retangleWidth, retangleHeight, SOLID)
    end

    lcd.drawLine((retangleXstart + halfX) - crossweight, (retangleYstart + halfY) - crossweight,
      (retangleXstart + halfX) + crossweight, (retangleYstart + halfY) + crossweight, SOLID, ftype)
    lcd.drawLine((retangleXstart + halfX) - crossweight, (retangleYstart + halfY) + crossweight,
      (retangleXstart + halfX) + crossweight, (retangleYstart + halfY) - crossweight, SOLID, ftype)

    for i = 1, 2 do
      local kk = i + 1
      lcd.drawLine(retangleXstart + halfX - 1, retangleYstart + pitchWeight, coordsX[i], coordsY[i], DOTTED, ftype)
    end
  end

  --ARROW HOME DIST
  function homeArrow()
    local x = 9
    local y = 17

    local angle = telemetry.homeAngle - telemetry.yaw
    local size = 9

    local x1 = x + size * math.cos(math.rad(angle - 90))
    local y1 = y + size * math.sin(math.rad(angle - 90))
    local x2 = x + size * math.cos(math.rad(angle - 90 + 140))
    local y2 = y + size * math.sin(math.rad(angle - 90 + 140))
    local x3 = x + size * math.cos(math.rad(angle - 90 - 140))
    local y3 = y + size * math.sin(math.rad(angle - 90 - 140))
    local x4 = x + size * 0.1 * math.cos(math.rad(angle - 270))
    local y4 = y + size * 0.1 * math.sin(math.rad(angle - 270))
    --
    lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE)
    lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE)
    lcd.drawLine(x2, y2, x4, y4, SOLID, FORCE)
    lcd.drawLine(x3, y3, x4, y4, SOLID, FORCE)
  end

  function sorted()
    local xalign = 31
    lcd.drawText(xalign, 0, "mAh: " .. tostring(telemetry.batt1mah), SMLSIZE)
    lcd.drawText(xalign, 7, "Alt: " .. tostring(telemetry.homeAlt), SMLSIZE)

    local cellvolt = shared.getConfig(1)
    local dividefactor = 1
    if cellvolt == "True" then
      dividefactor = tonumber(shared.getConfig(2))
    end

    local battvolt = tostring(telemetry.batt1volt / dividefactor)
    battvolt = string.format("%.2f", battvolt)

    lcd.drawText(xalign, 14, "Volt: " .. battvolt, SMLSIZE)
    lcd.drawText(xalign, 21, "Hdop: " .. tostring(telemetry.gpsHdopC / 10), SMLSIZE)
    lcd.drawText(xalign, 28, "Nsat: " .. tostring(telemetry.numSats), SMLSIZE)

    lcd.drawText(80, 40, frame.flightModes[telemetry.flightMode], SMLSIZE)
    lcd.drawFilledRectangle(78, 39, 50, 10, GREY_DEFAULT)
    -- ALERT MESSAGES --
    lcd.drawText(0, 50, alertmessages[2], SMLSIZE)
    lcd.drawText(0, 57, alertmessages[1], SMLSIZE)
    -- ALERT MESSAGES --
    lcd.drawText(xalign, 35, "Throt: " .. tostring(telemetry.throttle), SMLSIZE)
    lcd.drawText(xalign, 42, "RSSI: " .. tostring(telemetry.RSSI), SMLSIZE)
    lcd.drawText(0, 28, "y:" .. tostring(telemetry.yaw), SMLSIZE)
    lcd.drawText(0, 0, "h:" .. tostring(telemetry.homeDist), SMLSIZE)
    lcd.drawLine(0, 48, 77, 48, SOLID, FORCE)
  end

  homeArrow()
  attitudeIndicator()
  vario()
  sorted()
  heartbeat()

  if event == EVT_VIRTUAL_NEXT then
    shared.changeScreen(1)
  elseif event == EVT_VIRTUAL_PREV then
    shared.changeScreen(-1)
  elseif event == EVT_VIRTUAL_ENTER then
    shared.loadConfig()
  end
end
