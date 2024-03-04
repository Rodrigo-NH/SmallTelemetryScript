-- local shared = ...
-- local bitmaps = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/bitmaps.lua")

local function heartbeat(rx1, ry1, rw, rh, sh)
    local shared = sh
    local hstep = rw / 3
    hbc = shared.Heartbeat
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

  local function vario(rx1, ry1, rw, rh, sh)
    local shared = sh
    local vSClipUp = tonumber(shared.GetConfig("Variometer clip val"))
    local vSClipDo = vSClipUp * -1

    local vSpeed = shared.tel.vSpeed

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
  

  local function attitudeIndicator(retangleXstart, retangleYstart, retangleWidth, retangleHeight, crossweight, sh)
    local shared = sh
    -- Get scale value from configurations
    local scaleFactor = tonumber(shared.GetConfig("Att. indicator scale"))

    -- local scaleFactor = 90 -- Value must be between 90 and 180
    local pitch = shared.tel.pitch
    local roll = shared.tel.roll * -1 -- oops (fix wrong, inverted, assumption about roll signal +/- )

    if pitch >= scaleFactor / 2 then
      pitch = scaleFactor / 2 - 1
    end

    local halfX = retangleWidth / 2
    local halfY = retangleHeight / 2

    local creference = 0
    if retangleWidth < retangleHeight then
      creference = retangleWidth
    else
      creference = retangleHeight
    end
    crossweight = creference / 2 * (crossweight / 100)

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

    -- SX1 = math.floor(SX1)
    -- SY1 = math.floor(SY1)
    -- SX2 = math.floor(SX2)
    -- SY2 = math.floor(SY2)

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

    for i = 1, 2 do
      local kk = i + 1
      lcd.drawLine(retangleXstart + halfX - 1, retangleYstart + pitchWeight, coordsX[i], coordsY[i], DOTTED, ftype)
    end

    -- A. indicator fixed roll reference
    roll = roll * -1     -- (de)oops
    roll = roll + 90     -- Initial reference, perpendicular to roll
    local cdts = { { (roll + 120), crossweight }, { (roll - 120), crossweight } }
    local centerY = retangleYstart + halfY
    local centerX = retangleXstart + halfX
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

  local function homeArrow(x, y, size, sh)
    local shared = sh
    local angle = shared.tel.homeAngle - shared.tel.yaw   

    local x1 = x + size * math.cos(math.rad(angle - 90))
    local y1 = y + size * math.sin(math.rad(angle - 90))
    local x2 = x + size * math.cos(math.rad(angle - 90 + 140))
    local y2 = y + size * math.sin(math.rad(angle - 90 + 140))
    local x3 = x + size * math.cos(math.rad(angle - 90 - 140))
    local y3 = y + size * math.sin(math.rad(angle - 90 - 140))
    local x4 = x + size * 0.1 * math.cos(math.rad(angle - 270))
    local y4 = y + size * 0.1 * math.sin(math.rad(angle - 270))

    lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE)
    lcd.drawLine(x1, y1, x3, y3, SOLID, FORCE)
    lcd.drawLine(x2, y2, x4, y4, SOLID, FORCE)
    lcd.drawLine(x3, y3, x4, y4, SOLID, FORCE)
  end

local function armedIndicator(x, y, size, sh)
  -- size = 1 or 2
  local shared = sh
  local ftype = SMLSIZE
  if shared.tel.statusArmed == 1 then
    -- local tsize = SMLSIZE
    if size == 2 then
      ftype = 0
    end
    lcd.drawText(x, y, "A", ftype + INVERS)
  end
end


local function drawPattern(x, y, pattern)
  local sx = x
  local sy = y

  for line=1, #pattern
    do
      local sline = pattern[line]      
      for column=1, #sline
      do
        if sline[column] == 1 then
          lcd.drawPoint(sx, sy)
        end        
        sx = sx + 1
      end
      sx = x
      sy = sy + 1
    end
end


local function drawSmallNumbers(x, y, number)
  local numbers = {
    {
        { 0, 1, 0, 0,  },
        { 1, 0, 1, 0,  },
        { 1, 0, 1, 0,  },
        { 0, 1, 0, 0,  }
    },
    {
        { 0, 1, 0,  },
        { 1, 1, 0,  },
        { 0, 1, 0,  },
        { 0, 1, 0,  }
    },
    {
        { 1, 1, 0,  },
        { 0, 1, 0,  },
        { 1, 0, 0,  },
        { 1, 1, 0,  }
    },
    {
        { 1, 1, 0,  },
        { 0, 1, 0,  },
        { 1, 1, 0,  },
        { 0, 1, 0,  },
        { 1, 1, 0,  }
    },
    {
        { 1, 0, 1, 0,  },
        { 1, 1, 1, 0,  },
        { 0, 0, 1, 0,  },
        { 0, 0, 1, 0,  },
    },
    {
        { 1, 1, 0,  },
        { 1, 0, 0,  },
        { 0, 1, 0,  },
        { 1, 1, 0,  }
    },
    {
        { 1, 0, 0,  },
        { 1, 0, 0,  },
        { 1, 1, 0,  },
        { 1, 1, 0,  }
    },
    {
        { 1, 1, 0,  },
        { 0, 1, 0,  },
        { 0, 1, 0,  },
        { 0, 1, 0,  }
    },
    {
        { 0, 1, 0, 0,  },
        { 1, 0, 1, 0,  },
        { 0, 1, 0, 0,  },
        { 1, 0, 1, 0,  },
        { 0, 1, 0, 0,  },
    },
    {
        { 1, 1, 0,  },
        { 1, 1, 0,  },
        { 0, 1, 0,  },
        { 0, 1, 0,  },
    },
    -- colon
    { 
      { 0,0},
      { 1,0 },
      { 0,0 },
      { 1,0 }
    }
  }

  local str = tostring(number)
  if str == ":" then
    drawPattern(x, y, numbers[11])
  else
    for t = 1, #str
    do
      local alg = tonumber(string.sub(str, t, t)) + 1
      local rec = #numbers[alg][1]
      drawPattern(x, y, numbers[alg])
      x = x + rec
    end
  end
end


  return { 
    heartbeat=heartbeat,
    vario=vario,
    attitudeIndicator=attitudeIndicator,
    homeArrow=homeArrow,
    armedIndicator=armedIndicator,
    drawPattern=drawPattern,
    drawSmallNumbers=drawSmallNumbers,


 }