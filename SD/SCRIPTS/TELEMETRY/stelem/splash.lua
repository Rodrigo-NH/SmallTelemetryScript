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
    local coords1 = {
        { 1, 1, -20.093206, -44.569377 },
        { 2, 1, -20.093307, -44.568478 },
        { 3, 1, -20.094027, -44.567756 },
        { 4, 1, -20.094932, -44.567165 },
        { 5, 1, -20.095915, -44.566975 },
        { 6, 1, -20.096988, -44.567256 },
        { 7, 1, -20.097825, -44.568036 },
        { 8, 1, -20.098801, -44.568613 },
        { 9, 1, -20.098934, -44.56997 },
        { 10, 1, -20.09833, -44.571064 },
        { 11, 1, -20.097687, -44.572026 },
        { 12, 1, -20.096605, -44.572605 },
        { 13, 1, -20.09525, -44.572662 },
        { 15, 1, -20.094356, -44.572205 },
        { 16, 1, -20.093622, -44.571333 },
        { 17, 1, -20.093149, -44.5703 },
        { 18, 1, -20.0971, -44.571021 },
        { 19, 1, -20.0979, -44.569461 },
        { 20, 1, -20.095549, -44.571526 },
        { 21, 1, -20.094235, -44.570365 },
        { 22, 1, -20.095292, -44.568985 },
        { 23, 1, -20.0965, -44.568366 },
        
        
        -- ================================================
        { 1, 2, -20.095835, -44.569921 },
        { 2, 2, -20.095835, -44.569872 },
        { 3, 2, -20.095819, -44.56986 },
        { 4, 2, -20.095819, -44.569949 },
        { 5, 2, -20.095835, -44.56996 },
        { 6, 2, -20.095852, -44.569951 },
        { 7, 2, -20.095852, -44.569905 },
        { 8, 2, -20.095857, -44.569953 },
        { 9, 2, -20.095885, -44.569972 },
        { 10, 2, -20.095885, -44.569895 },
        { 11, 2, -20.095902, -44.569885 },
        { 12, 2, -20.095869, -44.569864 },
        { 13, 2, -20.095841, -44.56988 },
        { 15, 2, -20.09585, -44.569861 },
        { 16, 2, -20.095834, -44.569851 },
        { 17, 2, -20.095834, -44.569804 },
        { 18, 2, -20.095869, -44.569785 },
        { 19, 2, -20.095902, -44.569807 },
        { 20, 2, -20.095885, -44.569818 },
        { 21, 2, -20.095863, -44.569818 },
        { 22, 2, -20.095856, -44.569812 },
        { 23, 2, -20.095863, -44.56982 },
        { 24, 2, -20.095886, -44.56982 },
        { 25, 2, -20.095886, -44.56984 },
        { 26, 2, -20.095863, -44.56984 },
        { 27, 2, -20.095856, -44.569833 },
        { 28, 2, -20.095863, -44.569842 },
        { 29, 2, -20.095886, -44.569842 },
        { 30, 2, -20.095886, -44.569863 },
        { 32, 2, -20.095859, -44.569779 },
        { 33, 2, -20.095881, -44.569793 },
        { 34, 2, -20.095886, -44.569787 },
        { 35, 2, -20.095886, -44.569747 },
        { 36, 2, -20.095902, -44.569738 },
        { 37, 2, -20.095871, -44.569718 },
        { 38, 2, -20.095874, -44.569724 },
        { 39, 2, -20.095834, -44.569742 },
        { 40, 2, -20.095834, -44.569793 },
        { 41, 2, -20.095851, -44.569786 },
        { 42, 2, -20.095851, -44.569763 },
        { 44, 2, -20.09587, -44.569723 },
        { 45, 2, -20.095818, -44.569718 },
        { 46, 2, -20.095818, -44.569687 },
        { 47, 2, -20.095869, -44.569692 },
        { 48, 2, -20.095869, -44.569672 },
        { 49, 2, -20.095819, -44.569668 },
        { 50, 2, -20.095819, -44.569638 },
        { 51, 2, -20.095869, -44.569642 },
        { 52, 2, -20.095869, -44.569614 },
        { 53, 2, -20.095887, -44.569629 },
        { 54, 2, -20.095887, -44.569668 },
        { 56, 2, -20.095874, -44.569669 },
        { 57, 2, -20.095886, -44.569678 },
        { 58, 2, -20.095886, -44.569717 },
        { 60, 2, -20.095973, -44.569953 },
        { 61, 2, -20.095926, -44.569949 },
        { 62, 2, -20.095923, -44.569943 },
        { 63, 2, -20.095923, -44.569965 },
        { 64, 2, -20.095906, -44.569974 },
        { 65, 2, -20.095906, -44.569862 },
        { 66, 2, -20.095924, -44.569875 },
        { 67, 2, -20.095924, -44.569905 },
        { 68, 2, -20.095929, -44.569899 },
        { 69, 2, -20.095975, -44.569902 },
        { 70, 2, -20.095975, -44.56995 },
        { 72, 2, -20.095928, -44.569878 },
        { 73, 2, -20.095939, -44.569885 },
        { 74, 2, -20.095939, -44.569896 },
        { 75, 2, -20.095975, -44.569879 },
        { 76, 2, -20.095975, -44.569848 },
        { 77, 2, -20.09599, -44.56984 },
        { 78, 2, -20.095967, -44.56982 },
        { 79, 2, -20.095956, -44.569835 },
        { 80, 2, -20.095955, -44.569864 },
        { 81, 2, -20.095954, -44.569836 },
        { 82, 2, -20.09594, -44.569827 },
        { 83, 2, -20.095923, -44.569837 },
        { 84, 2, -20.095923, -44.569868 },
        { 86, 2, -20.095957, -44.569823 },
        { 87, 2, -20.095905, -44.569821 },
        { 88, 2, -20.095905, -44.56979 },
        { 89, 2, -20.095958, -44.569792 },
        { 90, 2, -20.095958, -44.569768 },
        { 91, 2, -20.095974, -44.569778 },
        { 92, 2, -20.095974, -44.56982 },
        { 94, 2, -20.095927, -44.569758 },
        { 95, 2, -20.095938, -44.569766 },
        { 96, 2, -20.095938, -44.569776 },
        { 97, 2, -20.095973, -44.569759 },
        { 98, 2, -20.095973, -44.569728 },
        { 99, 2, -20.095989, -44.569721 },
        { 100, 2, -20.095966, -44.569701 },
        { 101, 2, -20.095955, -44.569716 },
        { 102, 2, -20.095954, -44.569745 },
        { 103, 2, -20.095953, -44.569717 },
        { 104, 2, -20.095939, -44.569708 },
        { 105, 2, -20.095922, -44.569718 },
        { 106, 2, -20.095922, -44.569749 },
        { 108, 2, -20.09594, -44.569704 },
        { 109, 2, -20.095924, -44.569695 },
        { 110, 2, -20.095924, -44.569647 },
        { 111, 2, -20.095959, -44.569629 },
        { 112, 2, -20.095992, -44.56965 },
        { 113, 2, -20.095976, -44.569662 },
        { 114, 2, -20.095954, -44.569662 },
        { 115, 2, -20.095946, -44.569655 },
        { 116, 2, -20.095954, -44.569663 },
        { 117, 2, -20.095976, -44.569663 },
        { 118, 2, -20.095976, -44.569683 },
        { 119, 2, -20.095953, -44.569683 },
        { 120, 2, -20.095946, -44.569676 },
        { 121, 2, -20.095954, -44.569685 },
        { 122, 2, -20.095976, -44.569685 },
        { 123, 2, -20.095976, -44.569706 },
        
        
        
     }

local zoom = 64
local factor = 8
local splashlock = 0
local splashwait = getTime()
local offX = 0
local offY = 0

function shared.run(event)
  lcd.clear()
    
   
  local function splash(coords)
    local destW = 128
    local destH = 64

    local Xmax = 0
    local Xmin = 999999999999999
    local Ymax = 0
    local Ymin = 999999999999999
    local ctr = 0
    for t=1,#coords
    do
              local tx = ((coords[t][4]) + 180) * (destW/360)
        local latRad = (coords[t][3]) * math.pi / 180
        local mercN = math.log(math.tan((math.pi/4)+(latRad/2)))
        local ty = (destH/2)-(destW*mercN/(2*math.pi))        
        coords[t][7] = ty
        coords[t][8] = tx

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

    local centerY = math.floor((destH - (yDiff * baseScale)) / 2)
    local centerX = math.floor((destW - (xDiff * baseScale)) / 2)

    offX = offX - 1
    offY = offY + 4
    if offX < -4 then
        offX = -4
    end
    if offY > 43 then
       offY = 43 
    end

    ctr = 0
    for t=1, #coords
    do
        local destX = math.floor(((coords[t][8] - Xmin) * baseScale) + centerX + offX)
        local destY = math.floor(((coords[t][7] - Ymin) * baseScale) + centerY + offY)
        ctr = ctr + 8
        coords[t][10] = destX
        coords[t][9] = destY
    end

    for g = 1, #coords
    do
        local wpn = coords[g][1] 
        local x1 = coords[g][10]
        local y1 = coords[g][9]

        if x1 <= destW and y1 <= destH and x1 > 0 and y1 > 0 then
            if coords[g][2] == 1 then
            lcd.drawRectangle(x1 - 1, y1 - 1, 3, 3, INVERS)
            end
            if g > 1 then
                local wpn2 = coords[g - 1][1]
                local x2 = coords[g - 1][10]
                local y2 = coords[g - 1][9]
                if wpn - wpn2 == 1 and x2 > 0 and y2 > 0 then
                    if coords[g][2] == 1 then
                        local ha = 0
                        -- lcd.drawLine(x1, y1, x2, y2, DOTTED, FORCE)
                    else
                        lcd.drawLine(x1, y1, x2, y2, SOLID, FORCE)
                    end
                end
            end
        end
    end
end

if splashlock == 0 then
    zoom = zoom - factor
end
    factor = factor + 16
if zoom < -1700 then
    splashlock = 1
    zoom = -1700
end

if getTime() - splashwait > 450 then
    shared.LoadScreen(shared.Screens[1])
end

splash(coords1)

  if event == EVT_VIRTUAL_ENTER then
    shared.LoadScreen(shared.Screens[1])
  end
end

