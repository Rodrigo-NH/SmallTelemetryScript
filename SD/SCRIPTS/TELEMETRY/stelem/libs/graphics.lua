local function heartbeat(rx1, ry1, rw, rh, shared)
  lcd.drawFilledRectangle(rx1 + shared.Heartbeat * rw / 3, ry1, rw / 3, rh, LIGHTGREY)
  lcd.drawRectangle(rx1 + shared.Heartbeat * rw / 3, ry1, rw / 3, rh, SOLID)
  lcd.drawRectangle(rx1, ry1, rw, rh, SOLID)

end

local function vario(rx1, ry1, rw, rh, shared)
  local vSClipUp = tonumber(shared.GetConfig("Variometer clip val"))
  local vSClipDo = vSClipUp * -1

  local vSpeed = shared.tel.vSpeed

  local screenH = rh
  local clipUpf = (screenH / 2) / (vSClipUp)
  local clipDof = (screenH / 2) / (math.abs(vSClipDo))
  lcd.drawFilledRectangle(rx1, ry1, rw, rh / 2 - 3, BLACK)
  lcd.drawFilledRectangle(rx1, ry1 + rh / 2, rw, rh / 2, BLACK)

  local rx2 = rx1 + 1
  local rw2 = rw - 1
  local rh2 = 2

  local vpos = 0
  if vSpeed > 0 then
    vpos = (ry1 + screenH / 2) - clipUpf * vSpeed - (rh2 / 2)
  elseif vSpeed < 0 then
    vpos = (ry1 + screenH / 2) + clipDof * math.abs(vSpeed) - (rh2 / 2)
  elseif vSpeed == 0 then
    vpos = (ry1 + screenH / 2) - rh2 / 2
  end
  vpos = vpos - 1
  if vpos < ry1 then
    vpos = ry1 + 1
  elseif vpos > ry1 + rh - rh2 then
    vpos = (ry1 + rh) - rh2 - 2
  end

  local bt = BLACK
  if shared.isColor then
    bt = WHITE
  end

  lcd.drawFilledRectangle(rx2, vpos, rw2, rh2, bt)
end

local function attitudeIndicator(retangleXstart, retangleYstart, retangleWidth, retangleHeight, crossweight, shared)
  -- Get scale value from configurations
  local scaleFactor = tonumber(shared.GetConfig("Att. indicator scale"))
  local pitcha = (shared.tel.pitch * -1) * scaleFactor
  -- shared.tel.pitch = -85 * scaleFactor
  local halfX = retangleWidth / 2
  local halfY = retangleHeight / 2
  local centerY = retangleYstart + halfY
  local centerX = retangleXstart + halfX

  local creference = retangleWidth
  if retangleWidth < retangleHeight then
    creference = retangleHeight
  end
  crossweight = creference / 2 * (crossweight / 100)
  local lmax = creference * math.sqrt(2)
  -- if pitcha == 0 then
    -- pitcha = 1
  -- end
  local pitchcomp = centerY - ((retangleHeight / 60) * pitcha)
  local ftype = FORCE
  if shared.isColor then
    ftype = DARKBLUE
  end
  local refang = { 90, 270 }

  for t = 1, #refang
  do
    local gangle = (shared.tel.roll + refang[t]) % 360
    local dest = shared.geo.calcDestinationPlane(gangle, lmax / 2)
    shared.geo.drawClippingLine(centerX, pitchcomp, centerX + dest[1], pitchcomp + dest[2], retangleXstart,
      retangleYstart,
      retangleXstart + retangleWidth, retangleYstart + retangleHeight, 12, DOTTED, ftype)
  end
  -- if math.abs(shared.tel.pitch) > 90 then
  --   lcd.drawFilledRectangle(retangleXstart, retangleYstart, retangleWidth, retangleHeight, GREY_DEFAULT)
  --   ftype = ERASE
  -- else
    lcd.drawRectangle(retangleXstart, retangleYstart, retangleWidth, retangleHeight, SOLID)
  -- end

  local troll = shared.tel.roll + 90
  local cdts = { { (troll + 120), crossweight }, { (troll - 120), crossweight } }

  local Tpoints = {}
  for i = 1, #cdts
  do
    local xtan = math.cos(math.rad(cdts[i][1]))
    xtan = xtan * cdts[i][2]
    local ytan = math.sin(math.rad(cdts[i][1]))
    ytan = ytan * cdts[i][2]
    local destPointX = retangleXstart + halfX - xtan
    local destPointY = centerY - ytan
    lcd.drawLine(centerX, centerY, destPointX, destPointY, SOLID, ftype)
    Tpoints[i] = { destPointX, destPointY }
  end
  lcd.drawLine(Tpoints[1][1], Tpoints[1][2], Tpoints[2][1], Tpoints[2][2], SOLID, ftype)
end

local function homeArrow(x, y, size, shared)
  local angle = shared.tel.homeAngle - shared.tel.yaw
  local ftype = SOLID
  if shared.isColor then
    ftype = DARKGREEN
  end

  local x1 = x + size * math.cos(math.rad(angle - 90))
  local y1 = y + size * math.sin(math.rad(angle - 90))
  local x2 = x + size * math.cos(math.rad(angle - 90 + 140))
  local y2 = y + size * math.sin(math.rad(angle - 90 + 140))
  local x3 = x + size * math.cos(math.rad(angle - 90 - 140))
  local y3 = y + size * math.sin(math.rad(angle - 90 - 140))
  local x4 = x + size * 0.1 * math.cos(math.rad(angle - 270))
  local y4 = y + size * 0.1 * math.sin(math.rad(angle - 270))

  lcd.drawLine(x1, y1, x2, y2, SOLID, ftype)
  lcd.drawLine(x1, y1, x3, y3, SOLID, ftype)
  lcd.drawLine(x2, y2, x4, y4, SOLID, ftype)
  lcd.drawLine(x3, y3, x4, y4, SOLID, ftype)
end

local function armedIndicator(x, y, size, shared)
  local ftype = SMLSIZE
  if shared.tel.statusArmed == 1 then
    if size == 2 then
      ftype = 0
    end
    lcd.drawText(x, y, "A", ftype + INVERS)
  end
end


-- local function drawPattern(x, y, pattern)
--   local sx = x
--   local sy = y
--   for line = 1, #pattern
--   do
--     local sline = pattern[line]
--     for column = 1, #sline
--     do
--       if sline[column] == 1 then
--         lcd.drawPoint(sx, sy)
--       end
--       sx = sx + 1
--     end
--     sx = x
--     sy = sy + 1
--   end
-- end

local function compass(x1, y1, size, YAW, gotoangle, shared)
  local offset = 5
  local offset2 = 5
  local offset3 = 2.5
  local cl = 0
  if shared.isColor then
    offset = 12
    offset2 = 16
    offset3 = 4
    cl = LIGHTBROWN
  end
  local ftype = FORCE
  if shared.isColor then
    ftype = RED
  end

  YAW = 360 - YAW
  lcd.drawRectangle(x1, y1, size * 2 + offset, size * 2 + offset2, SOLID)
  local ccenter = shared.geo.calcDestinationPlane(135, size * math.sqrt(2))
  local xd1 = x1 + ccenter[1] + offset3
  local yd1 = y1 + ccenter[2] + offset3
  local dest2 = shared.geo.calcDestinationPlane(YAW, size - 2.5)
  lcd.drawText(xd1 + dest2[1] - 2.3, yd1 + dest2[2] - 2.3, "N", SMLSIZE)
  local tracesize = size - size * 0.3
  local dest2_1 = shared.geo.calcDestinationPlane(YAW + 45, tracesize + tracesize * 0.3)
  local dest2_2 = shared.geo.calcDestinationPlane(YAW + 45, tracesize)
  lcd.drawLine(xd1 + dest2_1[1], yd1 + dest2_1[2], xd1 + dest2_2[1], yd1 + dest2_2[2], DOTTED, ftype)

  local dest3 = shared.geo.calcDestinationPlane(YAW + 90, size - 2.5)
  lcd.drawText(xd1 + dest3[1] - 2.3, yd1 + dest3[2] - 2.3, "E", SMLSIZE)

  local dest3_1 = shared.geo.calcDestinationPlane(YAW + 135, tracesize + tracesize * 0.3)
  local dest3_2 = shared.geo.calcDestinationPlane(YAW + 135, tracesize)
  lcd.drawLine(xd1 + dest3_1[1], yd1 + dest3_1[2], xd1 + dest3_2[1], yd1 + dest3_2[2], DOTTED, ftype)

  local dest4 = shared.geo.calcDestinationPlane(YAW + 180, size - 2.5)
  lcd.drawText(xd1 + dest4[1] - 2.3, yd1 + dest4[2] - 2.3, "S", SMLSIZE)

  local dest4_1 = shared.geo.calcDestinationPlane(YAW + 225, tracesize + tracesize * 0.3)
  local dest4_2 = shared.geo.calcDestinationPlane(YAW + 225, tracesize)
  lcd.drawLine(xd1 + dest4_1[1], yd1 + dest4_1[2], xd1 + dest4_2[1], yd1 + dest4_2[2], DOTTED, ftype)

  local dest5 = shared.geo.calcDestinationPlane(YAW + 270, size - 2.5)
  lcd.drawText(xd1 + dest5[1] - 2.3, yd1 + dest5[2] - 2.3, "W", SMLSIZE)


  local dest5_1 = shared.geo.calcDestinationPlane(YAW + 315, tracesize + tracesize * 0.3)
  local dest5_2 = shared.geo.calcDestinationPlane(YAW + 315, tracesize)
  lcd.drawLine(xd1 + dest5_1[1], yd1 + dest5_1[2], xd1 + dest5_2[1], yd1 + dest5_2[2], DOTTED, ftype)



  if shared.gotonav ~= nil then
    local dest = shared.geo.calcDestinationPlane(gotoangle, size - 7)
    local destx = xd1 + dest[1]
    local desty = yd1 + dest[2]
    lcd.drawLine(xd1, yd1, xd1 + dest[1], yd1 + dest[2], SOLID, cl)

    xd1 = destx + 5 * math.cos(math.rad(gotoangle + 50))
    yd1 = desty + 5 * math.sin(math.rad(gotoangle + 50))
    lcd.drawLine(destx, desty, xd1, yd1, SOLID, cl)

    xd1 = destx + 5 * math.cos(math.rad(gotoangle + 125))
    yd1 = desty + 5 * math.sin(math.rad(gotoangle + 125))
    lcd.drawLine(destx, desty, xd1, yd1, SOLID, cl)
  end

  lcd.drawLine(x1 + (size * 2 + 5) / 2 - 3, y1, x1 + (size * 2 + 5) / 2, y1 + 3, SOLID, FORCE)
  lcd.drawLine(x1 + (size * 2 + 5) / 2 + 3, y1, x1 + (size * 2 + 5) / 2, y1 + 3, SOLID, FORCE)
end

local function smoothNeedle(param, destiny)
  local distan = ((param - destiny) + 180) % 360 - 180
  local hdgstep = math.floor(math.abs(distan / 10))
  if hdgstep == 0 then
    hdgstep = 1
  end

  if param ~= destiny and math.abs(distan) > 0.5 then
    if distan < 0 then
      param = param + hdgstep
    else
      param = param - hdgstep
    end
    param = param % 360
  else
    param = destiny
  end

  return param
end

return {
  heartbeat = heartbeat,
  vario = vario,
  attitudeIndicator = attitudeIndicator,
  homeArrow = homeArrow,
  armedIndicator = armedIndicator,
  -- drawPattern = drawPattern,
  compass = compass,
  smoothNeedle = smoothNeedle,

}
