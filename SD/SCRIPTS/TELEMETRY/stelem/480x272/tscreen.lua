local shared = ...
local gfx = shared.LoadLua(shared.libsDir .. "graphics.lua")
local sup = shared.LoadLua(shared.libsDir .. "common.lua")


local hdgsmooth = shared.hdgVel
local needlesmooth = 0

-- SIMULATE
-- shared.tel.statusArmed = 1
-- shared.tel.flightMode = "STAB"
-- local pifactor = 2
-- local rollfactor = 2
-- local hafactor = 3
-- local function variatePitch()
--   shared.Heartbeat = shared.Heartbeat + 1
--     if shared.Heartbeat > 2 then
--       shared.Heartbeat = 0
--     end

--   shared.tel.yaw = shared.tel.yaw + 1
--   if shared.tel.yaw > 359 then
--     shared.tel.yaw = 0
--   end

--   if shared.tel.pitch >= 1 then
--     shared.tel.vSpeed = shared.tel.vSpeed + 1
--   elseif shared.tel.pitch <= 0 then
--     shared.tel.vSpeed = shared.tel.vSpeed - 1
--   end
--       if shared.tel.vSpeed > 20 then
--       shared.tel.vSpeed = 20
--     end

--   if shared.tel.vSpeed > 20 then
--     hafactor = -1
--   elseif shared.tel.vSpeed < -120 then
--     hafactor = 1
--   end
--   if shared.tel.homeAngle > 120 then
--     hafactor = -1
--   elseif shared.tel.homeAngle < -120 then
--     hafactor = 1
--   end
--   if shared.tel.roll > 30 then
--     rollfactor = -1
--   elseif shared.tel.roll < -30 then
--     rollfactor = 1
--   end
--   if shared.tel.pitch > 20 then
--     pifactor = -1
--   elseif shared.tel.pitch < -20 then
--     pifactor = 1
--   end
--   shared.tel.pitch = shared.tel.pitch + pifactor
--   shared.tel.roll = shared.tel.roll + rollfactor
--   shared.tel.homeAngle = (shared.tel.homeAngle + hafactor) % 360
--   shared.hdgVel = shared.hdgVel + 1
-- end
-- shared.tel.lat = -49.1874117
-- shared.tel.lon = 70.3271770

-- SIMULATE

function shared.run(event)
  -- lcd.clear()
  -- SIMULATE
  -- variatePitch()

  local needle = 0
  if shared.gotonav ~= nil then
    needle = shared.gotoangle - shared.hdgVel
    needle = needle % 360
  end
  hdgsmooth = gfx.smoothNeedle(hdgsmooth, shared.hdgVel)
  needlesmooth = gfx.smoothNeedle(needlesmooth, needle)
  gfx.compass(354, 0, 57, hdgsmooth, needlesmooth, shared)

  gfx.attitudeIndicator(10, 10, 120, 120, 40, shared)
  gfx.vario(0, 10, 11, 120, shared)
  gfx.heartbeat(0, 0, 130, 11, shared)
  gfx.homeArrow(69, 25, 10, shared)
  gfx.armedIndicator(119, 110, 1, shared)

  lcd.drawText(12, 110, shared.tel.flightMode, SMLSIZE + INVERS)

  local xalign = 140
  lcd.drawText(xalign, 0, "Voltage:" .. shared.nbformat(shared.tel.batt1volt, 2), SMLSIZE + INVERS)
  lcd.drawText(xalign, 18, "Nsat: " .. tostring(shared.tel.numSats), SMLSIZE)
  lcd.drawText(xalign, 36, "Altitude:" .. shared.nbformat(shared.tel.alt, 1), SMLSIZE + INVERS)
  lcd.drawText(xalign, 54, "Home Alt." .. shared.nbformat(shared.tel.homeAlt, 1), SMLSIZE)
  lcd.drawText(xalign, 72, "Throttle:" .. tostring(shared.tel.throttle), SMLSIZE + INVERS)
  lcd.drawText(xalign, 90, "RSSI:" .. tostring(shared.tel.RSSI), SMLSIZE)
  lcd.drawText(xalign, 108, "Current:" .. shared.nbformat(shared.tel.batt1current, 1), SMLSIZE + INVERS)

  lcd.drawText(xalign, 135, "Total curr:" .. shared.nbformat(shared.tel.batt1mah, 1), SMLSIZE)

  xalign = 240
  lcd.drawText(xalign, 0, "V. speed:" .. shared.nbformat(shared.tel.vSpeed, 1), SMLSIZE + INVERS)
  lcd.drawText(xalign, 18, "H. speed: " .. shared.nbformat(shared.tel.hSpeed, 1), SMLSIZE)
  lcd.drawText(xalign, 36, "HDOP:" .. shared.nbformat(shared.tel.gpsHdopC, 1), SMLSIZE + INVERS)
  lcd.drawText(xalign, 54, "Heading." .. shared.nbformat(shared.hdgVel, 1), SMLSIZE)
  lcd.drawText(xalign, 72, "H. distance:" .. shared.nbformat(shared.tel.homeDist, 1), SMLSIZE + INVERS)
  lcd.drawText(xalign, 90, "Home angle:" .. tostring(shared.tel.homeAngle), SMLSIZE)
  lcd.drawText(xalign, 108, "GPS Status:" .. shared.nbformat(shared.tel.gpsStatus, 1), SMLSIZE + INVERS)

  lcd.drawText(xalign, 135, "TXpower:" .. shared.nbformat(shared.tel.txpower, 1), SMLSIZE)

  lcd.drawText(356, 118, "WP: " .. tostring(shared.tel.wpNumber), SMLSIZE + INVERS)
  lcd.drawText(354, 135, "Distance: " .. shared.nbformat(shared.gotodist, 1), SMLSIZE)
  lcd.drawText(354, 149, "Bearing: " .. shared.nbformat(shared.gotoangle, 1) .. "°", SMLSIZE)
  lcd.drawLine(0, 170, 480, 170, SOLID)

  xalign = 0
  lcd.drawText(xalign, 135, "Lat: " .. tostring(shared.tel.lat), SMLSIZE)
  lcd.drawText(xalign, 149, "Lon: " .. tostring(shared.tel.lon), SMLSIZE)

  local yalign = 245

  for t = #shared.Messages - 5, #shared.Messages
  do
    if t > 0 then
      lcd.drawText(xalign, yalign, shared.Messages[t], SMLSIZE)
      yalign = yalign - 14
    end
  end

  sup.defaultActions(event, shared)
end
