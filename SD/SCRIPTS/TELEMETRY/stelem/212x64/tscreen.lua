local shared = ...
local gfx = shared.LoadLua(shared.libsDir .. "graphics.lua")
local sup = shared.LoadLua(shared.libsDir .. "common.lua")

local hdgsmooth = shared.hdgVel
local needlesmooth = 0

--SIMULATE
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
--SIMULATE


function shared.run(event)
  lcd.clear()
  -- SIMULATE
  -- variatePitch()

  local needle = 0
  if shared.gotonav ~= nil then
    needle = shared.gotoangle - shared.hdgVel
    needle = needle % 360
  end
  hdgsmooth = gfx.smoothNeedle(hdgsmooth, shared.hdgVel)
  needlesmooth = gfx.smoothNeedle(needlesmooth, needle)
  gfx.compass(89, 0, 17, hdgsmooth, needlesmooth, shared)

  gfx.attitudeIndicator(5, 4, 33, 35, 50, shared)
  gfx.vario(0, 5, 5, 34, shared)
  gfx.heartbeat(0, 0, 38, 5, shared)
  gfx.homeArrow(22, 11, 5, shared)
  gfx.armedIndicator(6, 31, 1, shared)

  local xalign = 39
  lcd.drawText(xalign, 0, "V:" .. shared.nbformat(shared.tel.batt1volt, 2), SMLSIZE + INVERS)
  lcd.drawText(xalign, 8, "Ns:" .. tostring(shared.tel.numSats), SMLSIZE)
  lcd.drawText(xalign, 16, "A:" .. shared.nbformat(shared.tel.alt, 0), SMLSIZE + INVERS)
  lcd.drawText(xalign, 24, "HA:" .. tostring(shared.tel.homeAlt), SMLSIZE)
  lcd.drawText(xalign, 32, "T:" .. tostring(shared.tel.throttle), SMLSIZE + INVERS)

  lcd.drawText(xalign, 40, "Hd:" .. shared.nbformat(shared.tel.homeDist, 0), SMLSIZE)

  lcd.drawText(90, 40, "d:" .. shared.nbformat(shared.gotodist, 0), SMLSIZE)

  lcd.drawText(65, 0, "WP:" .. tostring(shared.tel.wpNumber), SMLSIZE + INVERS)
  lcd.drawText(63, 8, "B:" .. shared.nbformat(shared.gotoangle, 0) .. "°", SMLSIZE)
  lcd.drawText(68, 16, "v:" .. shared.nbformat(shared.tel.hSpeed, 0), SMLSIZE + INVERS)
  lcd.drawText(62, 32, "R:" .. tostring(shared.tel.RSSI), SMLSIZE + INVERS)

  lcd.drawLine(0, 47, 128, 47, SOLID, FORCE)
  lcd.drawText(0, 49, shared.Alertmessages[1], SMLSIZE)
  lcd.drawText(0, 56, shared.Alertmessages[2], SMLSIZE)

  xalign = 60
  lcd.drawText(0, 40, shared.tel.flightMode, SMLSIZE + INVERS)

  if event == 101 then
    shared.tel.wpNumber = shared.tel.wpNumber + 1
  end

  sup.defaultActions(event, shared)
end
