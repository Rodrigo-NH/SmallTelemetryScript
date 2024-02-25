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
local file = io.open("/SCRIPTS/TELEMETRY/stelem/mission.txt", "r")
local strout = ""
local ctr = 0
local ctr3 = 1
local coords = { }


-- memory monitor
local mc1 = 0
local mc2 = 0

lcd.clear()

    -- Extract data from mission planner TXT file
  while ctr ~= nil
  do
    lcd.drawText(0, 0, "Loading M. planner TXT file", SMLSIZE + INVERS)
    local mc = collectgarbage("count")
    if mc > mc1 then
        mc1 = mc
    end
      local charc = io.read(file, 1)
      ctr = string.byte(charc)
      if charc ~= "\n" and ctr ~= nil then
          strout = strout .. charc
          
      else
          local itagout = {}
          local ctr2 = 1
          for itag in string.gmatch(strout, "(.-)\t") do
              if itag ~= nil then
                  itagout[ctr2] = itag
                  ctr2 = ctr2 + 1
              end
          end
          local tcoords = {}
          if ctr2 > 1 then
            print(itagout[1] .. " -> " .. itagout[9])  
              tcoords[1] = itagout[1]
              tcoords[2] = itagout[2]
              tcoords[3] = itagout[3]
              tcoords[4] = itagout[4]
              tcoords[5] = itagout[9]
              tcoords[6] = itagout[10]
              coords[ctr3] = tcoords
              ctr3 = ctr3 + 1
          end
          strout = ""
      end
  end
  io.close(file)

  -- Creates a 'slot' to insert/update drone actual position
  local scoords = {}
  for s=1, 6
  do
    scoords[s] = 0
  end
  scoords[4] = 99 -- arbitrary value (not used by MP?) to indicate its drone element
  coords[#coords+1] = scoords

local gfx = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/graphics.lua")
local bitmaps = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/bitmaps.lua")

-- Display zoom
local zoom = 10


  mc1 = string.format("%.1f", mc1)


function shared.run(event)
    lcd.clear()
    -- lcd.drawText(0, 0, mc1, SMLSIZE)
    mc2 = string.format("%.3f", mc2)
    -- lcd.drawText(0, 57, mc2, SMLSIZE)
    lcd.drawText(95, 0, "Map WIP", SMLSIZE + INVERS)
    -- lcd.drawText(0, 30, "Rottary", SMLSIZE)
    -- lcd.drawText(0, 38, "zoom", SMLSIZE)
    lcd.drawText(0, 50, "ENTER", SMLSIZE)
    lcd.drawText(0, 57, "exit", SMLSIZE)

    if shared.tel.lat ~= nil then
        coords[#coords][5] = shared.tel.lat
        coords[#coords][6] = shared.tel.lon
    end

    if shared.homeLocation[1] ~= 0 then
        coords[1][5] = shared.homeLocation[1]
        coords[1][6] = shared.homeLocation[2]
    end

    -- "Canvas" = Screen size
    local destW = 128
    local destH = 64

    local Xmax = 0
    local Xmin = 999999999999999
    local Ymax = 0
    local Ymin = 999999999999999
    local ctr = 0
    for t=1,#coords
    do
        mc2 = collectgarbage("count")
        -- Roughtly translates geo lat/long to Lambert conic conformal projection to our "canvas"
        local tx = ((coords[t][6]) + 180) * (destW/360)
        local latRad = coords[t][5] * math.pi / 180
        local mercN = math.log(math.tan((math.pi/4)+(latRad/2)))
        local ty = (destH/2)-(destW*mercN/(2*math.pi))        
        coords[t][7] = ty
        coords[t][8] = tx

        -- if tonumber(coords[t][5]) == 0 then
        -- print("ZEEEEEEEERo")
        -- end


        if tonumber(coords[t][5]) ~= 0 then
            -- print("ZEEEEEEEERo")
            -- Sort max min values
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
            ctr = ctr + 8
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
    ctr = 0
    for t=1, #coords
    do
        local destX = math.floor(((coords[t][8] - Xmin) * baseScale) + centerX)
        local destY = math.floor(((coords[t][7] - Ymin) * baseScale) + centerY)
        ctr = ctr + 8
        coords[t][10] = destX
        coords[t][9] = destY
    end

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
            commandpoint = bitmaps.home
            if #coords > 1 and tonumber(coords[g+1][4]) == 22 then
            commandpoint = bitmaps.hometakeoff
            coords[g+1][10] = x1
            coords[g+1][9] = y1
            -- same ptype
            end
        end
        
        if commandpoint == nil then        
            if tonumber(coords[g][4]) == 21 then
                commandpoint = bitmaps.land
            elseif tonumber(coords[g][4]) == 99 then
                commandpoint = bitmaps.copter
                ptype = {2, 2}
                iscopter = true
            end
        end

        if g + 1 <= #coords and tonumber(coords[g+1][4]) == 20 then
            commandpoint = bitmaps.rtl
            ptype = {1, 4}
        end

        if x1 <= destW and y1 <= destH and x1 > 0 and y1 > 0 then
            if commandpoint ~= nil then
                gfx.drawPattern(x1 - ptype[1], y1 - ptype[2], commandpoint)
                if iscopter then
                    local ax = x1 + 9 * math.cos(math.rad(270+shared.tel.yaw))
                    local ay = y1 + 9 * math.sin(math.rad(270+shared.tel.yaw))
                    lcd.drawLine(x1, y1, ax, ay, SOLID, FORCE)
                end
                -- pattern = {x1 - 1, y1 - 3, commandpoint}
            else
                lcd.drawRectangle(x1 - 1, y1 - 1, 3, 3, INVERS)
                gfx.drawSmallNumbers(x1+2,y1+4,coords[g][1])
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


  if event == EVT_VIRTUAL_NEXT or event == 99 then
    zoom = zoom + 8
    if zoom > destH then
        zoom = destH
    end
  elseif event == EVT_VIRTUAL_PREV or event == 98 then
    zoom = zoom - 8
  elseif event == EVT_VIRTUAL_ENTER then
    shared.CurrentScreen = 1
    shared.LoadScreen(shared.Screens[1])
  end
end

