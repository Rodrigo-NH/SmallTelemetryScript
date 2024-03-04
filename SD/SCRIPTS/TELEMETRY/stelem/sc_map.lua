-- Rought map reprojection and coordinates normalization for a small screen
-- Author: Rodrigo Nascimento Hernandez, https://github.com/Rodrigo-NH
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY, without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, see <http://www.gnu.org/licenses>.

local shared = ...

local coords = { }
local missionFNs = { }
local usrindex = 1
local usroptmap = {  }
local ucommand = ""
local centeroffsetX = 0
local centeroffsetY = 0
local zoom = 10
local zoomupdate = 2
local thisopt = nil
local showWPnumbers = shared.GetConfig("Show WP numbers")
local showScale = shared.GetConfig("Show scale")
local scale = 0
local scalebump = 0
local groundScaleDistance = 0

local function distPoints(lat1, long1, lat2, long2)
    local ER1 = 6378137       -- Earth radius at ecuator meters
    local ER2 = 6356752       -- Earth radius at poles meters
    local N = math.rad(lat1)
    local M = math.rad(long1)
    local Q = math.rad(lat2)
    local P = math.rad(long2)

    local ER = math.sqrt(((ER1 ^ 2 * math.cos(N)) ^ 2 + (ER2 ^ 2 * math.sin(N)) ^ 2) /
    ((ER1 * math.cos(N)) ^ 2 + (ER2 * math.sin(N)) ^ 2))

    local xA = math.cos(M) * math.cos(N)
    local yA = math.sin(M) * math.cos(N)
    local zA = math.sin(N)
    local xB = math.cos(P) * math.cos(Q)
    local yB = math.sin(P) * math.cos(Q)
    local zB = math.sin(Q)

    -- straight distance
    local D1 = ER * math.sqrt((xB - xA) ^ 2 + (yB - yA) ^ 2 + (zB - zA) ^ 2)

    -- great circle distance
    -- local D2 = ER * math.acos(xA*xB+yA*yB+zA*zB)

    return D1
  end

local function distPointsPlane(x1, y1, x2, y2)
    local dist = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
    return dist
end

local function translatePoint(lat, long, destW, destH)
    local tx = (long + 180) * (destW/360) 
    local mercN = math.log(math.tan((math.pi/4)+(math.rad(lat)/2)))
    local ty = (destH/2)-(destW*mercN/(2*math.pi))
    -- print("====: " .. tostring(tx))
    -- print("####: " .. tostring(ty))
    return {tx, ty}
end

local function anglePointsPlane(x1, y1, x2, y2)
    local angle = math.atan2((x2 - x1), (y2 - y1) * -1) * (180 / math.pi)
    if angle < 0 then
        angle = angle + 360
    end
    return angle
end

local function resetTable()
    thisopt = {
        { "Center on", 2,
            {
                { "Copter - once",   1 },
                { "Copter - sticky", 1 },
                { "Home",            1 },
                { "Center map",      1 },
                { "WayPoint", 2,
                    {
                        -- to be filled with actual waypoints
                        -- {"wp1",1 },
                    }
                },
            }
        },
        { "Reset scale", 1 },
        -- { "Map options", 1 },
        { "Load mission from SD card", 2,
            {
                -- to be filled with mission files from /missions/ directory
            }
        }
    }
    collectgarbage("collect")

    local y = 1
for fname in dir("/SCRIPTS/TELEMETRY/stelem/missions") do
    local fnameU = string.upper(fname)        
            if string.find(fnameU, ".TXT") then
                thisopt[3][3][y] = { fname, 1 }
                missionFNs[y] = fname
                -- lcd.drawText(5,y, fname, TEXT_COLOR)
                y = y + 1
            end
end
end

resetTable()

local function loadMission()
    resetTable()
    zoom = 10
    centeroffsetX = 0
    centeroffsetY = 0
    ucommand = ""
    coords = {}
    collectgarbage("collect")
    local ctr3 = 1
    inimem = collectgarbage("count")
    local info = fstat(shared.missionFile)
    local size = info.size
    file = io.open(shared.missionFile, "r")
    iomem = collectgarbage("count")
    local str = io.read(file, size)
    io.close(file)
    iomem2 = collectgarbage("count")
    local sl = string.len(str)
    local line = ""
    local WPnumbers = 1
    for t = 1, sl
    do
        local charc = string.sub(str, t, t)
        if charc ~= "\n" then
            line = line .. charc
        else
            local itagout = {}
            local ctr2 = 1
            for itag in string.gmatch(line, "(.-)\t") do
                if itag ~= nil then
                    itagout[ctr2] = itag
                    ctr2 = ctr2 + 1
                end
            end
            local tcoords = {}
            if ctr2 > 1 then
                tcoords[1] = itagout[1]
                tcoords[2] = itagout[2]
                tcoords[3] = itagout[3]
                tcoords[4] = itagout[4]
                tcoords[5] = itagout[9]
                tcoords[6] = itagout[10]
                coords[ctr3] = tcoords
                if tonumber(itagout[9]) ~= 0 then
                    local wpname = "WP-" .. tostring(ctr3 - 1)
                    thisopt[1][3][5][3][WPnumbers] = { wpname, 1 }
                    WPnumbers = WPnumbers + 1
                end

                ctr3 = ctr3 + 1
            end
            line = ""
            collectgarbage("collect")
        end
    end
    -- Creates a 'slot' to insert/update drone actual position
    local scoords = {}
    for s = 1, 6
    do
        scoords[s] = 0
    end
    scoords[4] = 99 -- arbitrary value (not used by MP?) to indicate its drone element
    coords[#coords + 1] = scoords

    scalebump = 2
    if coords[2][4] ~= 16 then -- Check wp1 is relative to command (dont contain coordinates)
        scalebump = 3
    end
    groundScaleDistance = distPoints(coords[1][5], coords[1][6], coords[scalebump][5], coords[scalebump][6])
end

if shared.missionFile ~= "" then
    loadMission()
else 
        usroptmap = { 1 }
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


local cm = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/libs/opexpand.lua")

local home = {
    { 0, 0, 1, 0, 1,  },
    { 0, 0, 1, 1, 1,  },
    { 1, 1, 1, 0, 1,  },
    { 1, 0, 1, 0, 0,  },
    { 1, 1, 1, 0, 0,  }
}

  local rtl = {
    { 0, 1, 1, 0, 1, 1, 1, 0, 0,  },
    { 0, 1, 0, 1, 0, 1, 0, 1, 0,  },
    { 0, 1, 1, 0, 0, 1, 0, 1, 0,  },
    { 1, 1, 0, 1, 0, 1, 0, 1, 1,  },
    { 1, 0, 1, 0, 0, 0, 0, 0, 0,  },
    { 1, 1, 1, 0, 0, 0, 0, 0, 0,  }
}

  local hometakeoff = {
    { 0, 0, 1, 0, 1, 1, 1, 1,  },
    { 0, 0, 1, 1, 1, 0, 1, 0,  },
    { 1, 1, 1, 0, 1, 0, 1, 0,  },
    { 1, 0, 1, 0, 0, 0, 0, 0,  },
    { 1, 1, 1, 0, 0, 0, 0, 0,  }
}

    local land = {
        { 0, 0, 1, 0,  },
        { 0, 0, 1, 0,  },
        { 1, 1, 1, 1,  },
        { 1, 0, 1, 0,  },
        { 1, 1, 1, 0,  }
    }

    local copter = {
        { 1, 0, 0, 0, 1,  },
        { 0, 1, 0, 1, 0,  },
        { 0, 0, 1, 0, 0,  },
        { 0, 1, 0, 1, 0,  },
        { 1, 0, 0, 0, 1,  }
 }


local function scaleCalc()
    if zoomupdate ~= 0 then
        zoomupdate = zoomupdate - 1
        local screenDistance = distPointsPlane(coords[1][10], coords[1][9], coords[scalebump][10], coords[scalebump][9]) *
            shared.pixelSize /
            1000 -- meters
            print("wp: " .. tostring(coords[2][1]))
            local angle = anglePointsPlane(coords[2][8], coords[2][7], coords[3][8], coords[3][7])
            print(angle)
        scale = math.floor(groundScaleDistance / screenDistance)
        if screenDistance > 0 then
            scale = scale
        else
            scale = 0
        end

    end
    if showScale == "ON" and scale > 0 then
        local align = shared.screenH - 5
        drawSmallNumbers(0, align, 1)
        drawSmallNumbers(3, align, ":")
        drawSmallNumbers(5, align, scale)
    end
end


function shared.run(event)
    lcd.clear()

    -- lcd.drawText(0,50,tostring(collectgarbage("count")))

        -- "Canvas" = Screen size
        local destW = shared.screenW
        local destH = shared.screenH
        local Xmax = 0
        local Xmin = 999999999999999
        local Ymax = 0
        local Ymin = 999999999999999



    local function procMap()

        if shared.tel.lat ~= nil then
            coords[#coords][5] = shared.tel.lat
            coords[#coords][6] = shared.tel.lon
        end
    
        if shared.homeLocation[1] ~= 0 then
            coords[1][5] = shared.homeLocation[1]
            coords[1][6] = shared.homeLocation[2]
        end
        
        for t=1,#coords
        do
            mc2 = collectgarbage("count")
            -- Roughtly translates geo lat/long to Lambert conic conformal projection to our "canvas"
            local tpout = translatePoint(coords[t][5], coords[t][6], destW, destH)
            local tx = tpout[1]
            local ty = tpout[2]
            coords[t][7] = ty
            coords[t][8] = tx

            if tonumber(coords[t][5]) ~= 0 then
                if tx > Xmax then
                    Xmax = tx
                end
                if tx < Xmin then
                    Xmin = tx
                end
                if ty > Ymax then
                    Ymax = ty
                end
                if ty < Ymin then
                    Ymin = ty
                end
                -- ctr = ctr + 8
            end
        end
        
        -- coordinates normalization
        local xDiff = Xmax - Xmin
        local yDiff = Ymax - Ymin        
    
        local xScale = xDiff / destW
        local yScale = yDiff / destH
    
        local baseScaleX = (destW - zoom) / xDiff
        local baseScaleY = (destH - zoom) / yDiff
    
        if yScale > xScale then
            baseScale = baseScaleY
        else
            baseScale = baseScaleX
        end
    
        -- center point group in screen
        local centerY = math.floor((destH - (yDiff * baseScale)) / 2)
        local centerX = math.floor((destW - (xDiff * baseScale)) / 2)
    
        -- Translate to screen    
        for t=1, #coords
        do
    
            local destX = math.floor(((coords[t][8] - Xmin) * baseScale) + centerX)
            local destY = math.floor(((coords[t][7] - Ymin) * baseScale) + centerY)
    
            
            local function centerOffset()
                local sw = 128
                local sh = 64
                local wref = sw / 2
                local href = sh / 2
                centeroffsetX = wref - destX
                centeroffsetY = href - destY
                -- scaleCalc()
            end   
    
            if #ucommand == 2 and ucommand[1] == "WP" and t == ucommand[2] then
                centerOffset()
            elseif t == 1 and ucommand == "Home" then
                centerOffset()
            elseif ucommand == "Center map" then
                centeroffsetX = 0
                centeroffsetY = 0
            elseif ucommand == "Copter - sticky" and t == #coords and coords[t][5] ~= 0 then
                centerOffset()
            elseif ucommand == "Copter - once" and t == #coords and coords[t][5] ~= 0 then
                centerOffset()
                ucommand = ""
            elseif ucommand == "Reset scale" then
                zoom = 10
                zoomupdate = 2
                centeroffsetX = 0
                centeroffsetY = 0
                ucommand = ""
                -- scaleCalc()
            end    
    
            coords[t][10] = destX + centeroffsetX
            coords[t][9] = destY + centeroffsetY

            
        end

        scaleCalc()

        for g = 1, #coords
        do
            local wpn = coords[g][1] -- waypoint number
            local x1 = coords[g][10]
            local y1 = coords[g][9]
    
            local commandpoint = nil
            local ptype = {1, 3} -- x,y, pixel correction (offset) in commone for home,hometakeoff,land
            local iscopter = false
    
            if tonumber(coords[g][2]) == 1 then
                -- lcd.drawText(x1, y1, "h", SMALL)
                commandpoint = home
                if #coords > 1 and tonumber(coords[g+1][4]) == 22 then
                commandpoint = hometakeoff
                coords[g+1][10] = x1
                coords[g+1][9] = y1
                -- same ptype
                end
            end
            
            if commandpoint == nil then        
                if tonumber(coords[g][4]) == 21 then
                    commandpoint = land
                elseif tonumber(coords[g][4]) == 99 then
                    commandpoint = copter
                    ptype = {2, 2}
                    iscopter = true
                end
            end
    
            if g + 1 <= #coords and tonumber(coords[g+1][4]) == 20 then
                commandpoint = rtl
                ptype = {1, 4}
            end
    
            if x1 <= destW and y1 <= destH and x1 > 0 and y1 > 0 then
                if commandpoint ~= nil then
                    drawPattern(x1 - ptype[1], y1 - ptype[2], commandpoint)
                    if iscopter then
                        local ax = x1 + 9 * math.cos(math.rad(270+shared.tel.yaw))
                        local ay = y1 + 9 * math.sin(math.rad(270+shared.tel.yaw))
                        lcd.drawLine(x1, y1, ax, ay, SOLID, FORCE)
                    end
                    -- pattern = {x1 - 1, y1 - 3, commandpoint}
                else
                    lcd.drawRectangle(x1 - 1, y1 - 1, 3, 3, INVERS)
                    if showWPnumbers == "ON" then
                        drawSmallNumbers(x1 + 2, y1 + 4, coords[g][1])
                    end
                    -- pointrect = {x1 - 1, y1 - 1, 3, 3, INVERS}    
                end            
                if g > 1 then
                    local wpn2 = coords[g - 1][1]
                    local x2 = coords[g - 1][10]
                    local y2 = coords[g - 1][9]
                    if wpn - wpn2 == 1 and x2 > 0 and y2 > 0 then 
                        lcd.drawLine(x1, y1, x2, y2, DOTTED, FORCE)
                        -- lcd.drawLine(x1, y1, x2, y2, FORCE, FORCE)
                        -- pline = {x1, y1, x2, y2, DOTTED, 0}
                    end
                end
                end
        end                     
    end

    if #coords ~= 0 then
        procMap()
    end


    if #usroptmap ~= 0 then
        local fag = cm.expandOption(usroptmap, thisopt, event, usrindex)
        usroptmap = fag[3]
        usrindex = fag[4]
        if fag[1] ~= nil then
            -- print(fag[1]) -- Command type
            -- print(fag[2]) -- Command data
            if fag[1] == 1 then
                ucommand = fag[2]
                    local cmu = string.upper(ucommand)
                    if string.find(cmu, ".TXT") then
                        for f=1, #missionFNs
                        do
                            if missionFNs[f] == ucommand then
                                shared.missionFile = "/SCRIPTS/TELEMETRY/stelem/missions/" .. missionFNs[f]
                            end
                        end                        
                        loadMission()                        
                    end

                local isWP = nil
                if string.find(ucommand, "WP-") then
                    for str in string.gmatch(ucommand, '([^WP-]+)')
                    do
                        isWP = tonumber(str)
                    end
                    ucommand = { "WP", isWP + 1}
                end
            end
        end
    elseif #usroptmap == 0 then
        if shared.missionFile == "" then
            shared.LoadScreen(shared.Screens[shared.CurrentScreen])
        elseif event == EVT_VIRTUAL_ENTER then
            usroptmap = { 1 }
        elseif event == 96 then
            shared.LoadScreen(shared.Screens[shared.CurrentScreen])
        end
    end


    if event == EVT_VIRTUAL_NEXT  then
        if #usroptmap == 0 then
            zoom = zoom + 8
            zoomupdate = 1
            if zoom > destH then
                zoom = destH
            end
        end
    elseif event == EVT_VIRTUAL_PREV  then
        if #usroptmap == 0 then
            zoomupdate = 1
            zoom = zoom - 8
        end
    end
end

