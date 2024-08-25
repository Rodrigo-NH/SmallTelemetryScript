local shared = ...
local mapcomp1 = shared.LoadLua(shared.libsDir .. "mapcomp1.lua")
local showScale = tonumber(shared.MenuItems[10][2]) -- "Show scale"
local scalecal = nil
if showScale == 1 then
    scalecal = shared.LoadLua(shared.libsDir .. "scalecal.lua")
end
shared.mapSource = true
local runtime = 0
local navupdate = 0
local align = 0

local debugmem = tonumber(shared.MenuItems[22][2])  -- "DebMem"

local usroptlist = {}
local usroptlist2 = {}
local ucommand = 0
local ucommand2 = 0
local holdPoint = 1
local zoomFactor = 0


local showWPnumbers = tonumber(shared.MenuItems[9][2]) -- "Show WP numbers"

local scale = 0
local zoomscale = 0
shared.gotonav = nil
local lastbaseScale = 0

if shared.mapState[1] == 0 then
    zoomscale = 0.1
    shared.mapState[1] = 0.1
end
zoomscale = shared.mapState[1]
local centeroffsetX = 0
local centeroffsetY = 0

local Xmax = 0
local Xmin = 999999999999999
local Ymax = 0
local Ymin = 999999999999999
function shared.run(event)
    -- "Canvas" = Screen size
    -- print(ucommand)
    if shared.coords ~= {} and #shared.coords > 2 then
        runtime = runtime + 1
        if runtime > 3 then
            runtime = 1
        end

        if runtime == 1 or shared.isColor then
            Xmax, Xmin, Ymax, Ymin = shared.geo.translateData(shared, Xmax, Xmin, Ymax, Ymin)
        end

        if runtime == 2 or shared.isColor then
            local baseScale = 0
            ucommand2, zoomscale, baseScale, centeroffsetX, centeroffsetY = mapcomp1.coordsNorm(centeroffsetX, centeroffsetY, Xmax,Xmin,Ymax,Ymin, ucommand, ucommand2, zoomscale, usroptlist, usroptlist2, zoomFactor, shared)
            if scalecal ~= nil and lastbaseScale ~= baseScale then                
                scale = scalecal.scaleCalc(shared, shared.geo.distPointsPlane, shared.geo.distPoints)
                lastbaseScale = baseScale
            end
        end

        if runtime == 3 or shared.isColor then
            if shared.isColor == false then
                lcd.clear()
            end
            local vstep = 3
            local vstep2 = 3
            local vstep3 = 9
            local vstep4 = 6
            for g = 1, #shared.coords
            do
                local x1 = shared.coords[g][7]
                local y1 = shared.coords[g][6]
                local commandpoint = nil
                local iscopter = false

                if g == 1 then
                    commandpoint = "h"
                    if #shared.coords > 1 and shared.coords[g + 1][1] == 22 then
                        commandpoint = "ht"
                        shared.coords[g + 1][7] = x1
                        shared.coords[g + 1][6] = y1
                    end
                end
                if commandpoint == nil then
                    if shared.coords[g][1] == 21 then
                        commandpoint = "land"
                    elseif shared.coords[g][1] == 99 then
                        commandpoint = "copter"
                        iscopter = true
                    end
                end

                if g + 1 <= #shared.coords and shared.coords[g + 1][1] == 20 then
                    commandpoint = "rtl"
                end
                if x1 <= shared.screenW and y1 <= shared.screenH and x1 >= 0 and y1 >= 0 then
                    vstep = 1
                    vstep3 = 9
                    if shared.isColor then
                        vstep = 2
                        vstep2 = 5
                        vstep3 = 15
                    end

                    -- last 'g' is just the "Snap on" point reference
                    if g ~= #shared.coords and shared.coords[g][1] == 16 then
                        lcd.drawRectangle(x1 - vstep, y1 - vstep, vstep2, vstep2, BLUE)

                        vstep = 6
                        vstep3 = 1.5

                        if shared.isColor then
                            vstep = 15
                        end

                        if showWPnumbers == 1 and commandpoint == nil then
                            lcd.drawText(x1 - vstep, y1 - vstep, tostring(g - 1), SMLSMALL)
                        elseif commandpoint ~= nil then
                            lcd.drawText(x1 - vstep * vstep3, y1 - vstep * vstep3, commandpoint, SMLSMALL)
                        end
                    elseif iscopter then
                        local color = 0
                        if shared.isColor then
                            -- vstep = 6
                            vstep3 = 20
                            color = RED
                        end

                        local ax = x1 + vstep3 * math.cos(math.rad(270 + shared.hdgVel))
                        local ay = y1 + vstep3 * math.sin(math.rad(270 + shared.hdgVel))

                        lcd.drawLine(x1, y1, ax, ay, SOLID, color)
                        lcd.drawRectangle(x1 - vstep, y1 - vstep, vstep2, vstep2, BLACK)

                        -- last 'g' is just the "Snap on" point reference
                    elseif g ~= #shared.coords and shared.coords[g][1] == 16 then
                        lcd.drawRectangle(x1 - vstep, y1 - vstep, vstep2, vstep2, BLUE)

                        vstep = 6
                        vstep3 = 1.5
                        if shared.isColor then
                            vstep = 20
                            vstep3 = 1
                        end
                        if showWPnumbers == 1 and commandpoint == nil then
                            lcd.drawText(x1 - vstep, y1 - vstep, tostring(g - 1), SMLSMALL)
                        elseif commandpoint ~= nil then
                            lcd.drawText(x1 - vstep * vstep3, y1 - vstep * vstep3, commandpoint, SMLSMALL)
                        end
                    end
                end
             
                if g < #shared.coords - 2 and shared.coords[g][1] == 16 and holdPoint < g then
                    shared.geo.drawClippingLine(shared.coords[g][7], shared.coords[g][6], shared.coords[holdPoint][7],
                        shared.coords[holdPoint][6], 0, 0,
                        shared.screenW, shared.screenH, vstep, DOTTED, FORCE)
                end
                if g < #shared.coords - 2 and shared.coords[g][1] == 16 then
                    holdPoint = g
                end

            end
          

            vstep = 3
            vstep2 = 3
            vstep3 = 9
            vstep4 = 6
            if shared.maphud then
                if shared.isColor then
                    vstep = 12
                    vstep4 = 13
                end
                if scale > 0 then
                    align = shared.screenH - 5
                    if showScale == 1 then
                        lcd.drawText(shared.screenW - (#tostring(scale) * vstep4 + 6), align - vstep,
                            "1:" .. tostring(scale))
                    end
                    -- maxmemc()
                end

                local maxcount = 8
                vstep = 7
                if shared.isColor then
                    vstep = 13
                    maxcount = 20
                end
                local ctr = 1

                local telemtab = {
                    shared.tel.batt1volt,
                    shared.tel.alt,
                    shared.tel.homeAlt,
                    shared.tel.RSSI,
                    shared.tel.numSats,
                    shared.tel.vSpeed,
                    shared.tel.hSpeed,
                    shared.tel.throttle,
                    shared.tel.txpower,
                    shared.tel.battpercent,
                }
                for m = 1, #shared.maphudItems
                do
                    if #shared.maphudItems[m] > 0 and ctr < maxcount then
                        align = m * vstep - vstep

                        lcd.drawText(0, ctr * vstep - vstep,
                            shared.maphudItems[m][1] .. shared.nbformat(telemtab[m], shared.maphudItems[m][2]), SMLSIZE)
                        ctr = ctr + 1
                    end
                end


                align = ctr * vstep - vstep * 2
                if shared.gotonav ~= nil then
                    align = align + vstep
                    lcd.drawText(0, align, "d:" .. shared.nbformat(shared.gotodist, 0), SMLSIZE)
                    align = align + vstep
                    lcd.drawText(0, align, "b:" .. shared.nbformat(shared.gotoangle, 0) .. "°", SMLSIZE)
                    align = align + vstep
                end
            end

            if debugmem == 1 then
                lcd.drawText(108, 0, shared.nbformat(collectgarbage("count"), 1), SMLSIZE)
            end
        end

        if navupdate > 5 then
            navupdate = 0
            shared.geo.gotonav(shared, true)
        else
            navupdate = navupdate + 1
        end
    end

    shared.mapState[1] = zoomscale
    ucommand = shared.mapState[2]
    ucommand2 = shared.mapState[4]
    usroptlist = shared.mapState[3]
    usroptlist2 = shared.mapState[5]

    zoomFactor = math.abs(zoomscale/10)
    if event == EVT_VIRTUAL_ENTER or #shared.coords == 0 then
        shared.mapSource = false
        shared.LoadScreen(shared.rootDir .. "sc_mapc.lua")
    elseif event == EVT_VIRTUAL_NEXT then
        zoomscale = zoomscale + (0.1 + zoomFactor)

        if zoomscale > 0.9 then
            zoomscale = 0.9
        end
    elseif event == EVT_VIRTUAL_PREV then
        zoomscale = zoomscale - (0.1 + zoomFactor)
    elseif event == 96 or event == 1540 then
        shared.mapSource = false
        shared.LoadScreen(shared.libsDir .. "wtroom.lua")
    end
end
