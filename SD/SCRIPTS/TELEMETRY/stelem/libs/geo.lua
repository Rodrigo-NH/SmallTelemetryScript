-- Rought map reprojection and coordinates normalization for a small screen128scv
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

local function distPoints(lat1, long1, lat2, long2)
    local ER1 = 6378137 -- Earth radius at ecuator meters
    local ER2 = 6356752 -- Earth radius at poles meters
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
    local dist = 0
    if x1 ~= nil and x2 ~= nil and y1 ~= nil and y2 ~= nil then
        dist = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
    end
    return dist
end

local function translatePoint(lat, long, destW, destH)
    local tx = (long + 180) * (destW / 360)
    local mercN = math.log(math.tan((math.pi / 4) + (math.rad(lat) / 2)))
    local ty = (destH / 2) - (destW * mercN / (2 * math.pi))
    return { tx, ty }
end

local function anglePointsPlane(x1, y1, x2, y2)
    local angle = math.atan2((x2 - x1), (y2 - y1) * -1) * (180 / math.pi) % 360
    return angle
end

local function calcDestinationPlane(angle, dist)
    local dx = dist * math.cos(math.rad(angle - 90))
    local dy = dist * math.sin(math.rad(angle - 90))
    return { dx, dy }
end

-- Input any arbitrary X,Y coords and find clipping values to fit space inside x1, y1, x2, y2
local function drawClippingLine(x1, y1, x2, y2, startX, startY, endX, endY, precision, pattern, flags)
    -- local step = 4
    local angle = anglePointsPlane(x1, y1, x2, y2)
    local find1 = false
    local newc = {}
    local totaldist = math.floor(distPointsPlane(x1, y1, x2, y2))
    if totaldist >= precision then
        -- proportional division to reduce iterations 'precision'
        local step = math.floor(math.sqrt(totaldist / precision) * 2.5)
        for d = 1, totaldist, step
        do
            local stepl = calcDestinationPlane(angle, d)
            if x1 + stepl[1] >= startX and x1 + stepl[1] <= endX and y1 + stepl[2] >= startY and y1 + stepl[2] <= endY and find1 == false then
                newc[1] = { x1 + stepl[1], y1 + stepl[2] }
                find1 = true
            end
            if x1 + stepl[1] >= startX and x1 + stepl[1] <= endX and y1 + stepl[2] >= startY and
                y1 + stepl[2] <= endY then
                newc[2] = { x1 + stepl[1], y1 + stepl[2] }
            end
            -- memory leak otherwise
            collectgarbage("collect")
        end
        if find1 == true then
            lcd.drawLine(newc[1][1], newc[1][2], newc[2][1], newc[2][2], pattern, flags)
        end
    end
end

local function calcNav(destinaton, sh)
    local shared = sh
    local destdist = distPoints(shared.tel.lat, shared.tel.lon, shared.coords[destinaton + 1][2],
        shared.coords[destinaton + 1][3])
    local destangle = anglePointsPlane(shared.coords[#shared.coords - 1][5],
        shared.coords[#shared.coords - 1][4],
        shared.coords[destinaton + 1][5], shared.coords[destinaton + 1][4])
    local virtdist = distPointsPlane(shared.coords[#shared.coords - 1][7],
        shared.coords[#shared.coords - 1][6],
        shared.coords[destinaton + 1][7], shared.coords[destinaton + 1][6])
    local posoffset = calcDestinationPlane(destangle, virtdist)

    local res = { destdist, destangle, virtdist, posoffset[1], posoffset[2] }
    return res
end

local function translateData(shared, Xmax, Xmin, Ymax, Ymin)
    if #shared.coords > 0 then
        if shared.tel.lat ~= nil then
            shared.coords[#shared.coords - 1][2] = shared.tel.lat
            shared.coords[#shared.coords - 1][3] = shared.tel.lon
        end

        if shared.homeLocation[1] ~= 0 and tonumber(shared.MenuItems[28][2]) == 1 then
            shared.coords[1][2] = shared.homeLocation[1]
            shared.coords[1][3] = shared.homeLocation[2]
        end
    end
    for t = 1, #shared.coords - 1
    do
        -- Roughtly translates geo lat/long to Lambert conic conformal projection to our "canvas"
        local tpout = translatePoint(shared.coords[t][2], shared.coords[t][3], shared.screenW, shared
            .screenH)
        local tx = tpout[1]
        local ty = tpout[2]
        shared.coords[t][4] = ty
        shared.coords[t][5] = tx
        if shared.coords[t][2] ~= 0 then
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
        end
    end
    return Xmax, Xmin, Ymax, Ymin
end


local function WPsp(shared, xDiff, yDiff, usroptlist, zoomscale, zoomFactor)
    local tt1 = 0
    local tt2 = 0
    local continue = true
    local scaleupdate2 = false
    if usroptlist[2] == #shared.coords - 1 then
        if shared.gotonav == nil then
            continue = false
        else
            tt1 = #shared.coords - 1
            tt2 = shared.gotonav + 1
        end
    else
        tt1 = usroptlist[2] + 1
        tt2 = usroptlist[2] + 2
    end
    if continue then
        if shared.coords[tt2][1] ~= 16 then
            tt2 = usroptlist[2] + 3
        end
        if shared.coords[tt2][1] == 16 then
            local destdis = distPointsPlane(shared.coords[tt1][5], shared.coords[tt1][4],
                shared.coords[tt2][5], shared.coords[tt2][4])
            local destangle = anglePointsPlane(shared.coords[tt1][5], shared.coords[tt1][4],
                shared.coords[tt2][5], shared.coords[tt2][4])
            local newpoint = calcDestinationPlane(destangle, destdis)
            shared.coords[#shared.coords][5] = shared.coords[tt1][5] + newpoint[1] / 2
            shared.coords[#shared.coords][4] = shared.coords[tt1][4] + newpoint[2] / 2
            xDiff = math.abs(shared.coords[tt1][5] - shared.coords[tt2][5])
            yDiff = math.abs(shared.coords[tt1][4] - shared.coords[tt2][4])
        end
    
    
        local x1 = shared.coords[tt1][7]
        local y1 = shared.coords[tt1][6]
        local x2 = shared.coords[tt2][7]
        local y2 = shared.coords[tt2][6]
        if x1 < 2 or x1 > shared.screenW - 2 or y1 < 2 or y1 > shared.screenH - 2
            or x2 < 2 or x2 > shared.screenW - 2 or y2 < 2 or y2 > shared.screenH - 2 then
            scaleupdate2 = true
            zoomscale = zoomscale + (0.1 + zoomFactor)
        end
    end
    return xDiff, yDiff, scaleupdate2, zoomscale
end


local function gotonav(shared, ismapscreen)
    if shared.gotonav ~= nil then
        if shared.tel.lat ~= 0 then
            local posoffset = shared.geo.calcNav(shared.gotonav, shared)

            if ismapscreen then
                local cl = 0
                if shared.isColor then
                    cl = LIGHTBROWN
                end
                shared.geo.drawClippingLine(shared.coords[#shared.coords - 1][7],
                    shared.coords[#shared.coords - 1][6],
                    shared.coords[#shared.coords - 1][7] + posoffset[4],
                    shared.coords[#shared.coords - 1][6] + posoffset[5], 0, 0,
                    shared.screenW, shared.screenH, 4, SOLID, cl)
            end

            shared.gotodist = posoffset[1]
            shared.gotoangle = posoffset[2]
        end
    else
        shared.gotodist = 0
    end
end

return {
    distPoints = distPoints,
    distPointsPlane = distPointsPlane,
    translatePoint = translatePoint,
    anglePointsPlane = anglePointsPlane,
    calcDestinationPlane = calcDestinationPlane,
    drawClippingLine = drawClippingLine,
    calcNav = calcNav,
    translateData = translateData,
    WPsp = WPsp,
    gotonav = gotonav,
    -- drawCopter=drawCopter,
}
