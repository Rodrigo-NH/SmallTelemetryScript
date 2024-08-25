local shared = ...
local cm = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/libs/opexpand.lua")
local optb = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/libs/opttable.lua")
local setts = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/libs/setmgm.lua")
local mapoptionstable = optb.getOptTable()
local usroptmap = { 1 }

-- local function deepcopy(orig)
--     local orig_type = type(orig)
--     local copy
--     if orig_type == 'table' then
--         copy = {}
--         for orig_key, orig_value in next, orig, nil do
--             copy[deepcopy(orig_key)] = deepcopy(orig_value)
--         end
--         setmetatable(copy, deepcopy(getmetatable(orig)))
--     else -- number, string, boolean, etc
--         copy = orig
--     end
--     return copy
-- end

local function loadMission2()
    shared.coords = {}
    local ctr3 = 1
    local info = fstat(shared.missionFile)
    local size = info.size
    local fi = io.open(shared.missionFile, "r")
    local str = io.read(fi, size)
    io.close(fi)
    local sl = string.len(str)
    local line = ""
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
                if tonumber(itagout[4]) == 19 then
                    itagout[4] = 16
                end
                
                tcoords[1] = tonumber(itagout[4])
                tcoords[2] = tonumber(itagout[9])
                tcoords[3] = tonumber(itagout[10])
                shared.coords[ctr3] = tcoords
                ctr3 = ctr3 + 1
            end
            line = ""
        end
    end
    -- Creates 'slots' to insert/update drone actual position and extra point for 'Snap on segment' reference point
    shared.coords[#shared.coords + 1] = {}
    shared.coords[#shared.coords + 1] = {}
    for s = 1, 8
    do
        shared.coords[#shared.coords][s] = 0
        shared.coords[#shared.coords - 1][s] = 0
    end
    shared.coords[#shared.coords - 1][1] = 99
    shared.coords[#shared.coords][1] = 100
end

local ep = { "empty", 1 }
local function getFNS(fls)
    local missionFNs = {}
    for t = 1, #fls
    do
        mapoptionstable[6][3][t] = { fls[t], 1 }
        missionFNs[t] = fls[t]
    end

    if #fls == 0 then
        mapoptionstable[6][3][1] = ep
    end

    return missionFNs
end

local usrindex = 0
local missionFNs = {}

local function loadMapHud()
    if shared.maphud then
        shared.maphudItems = {}
        local tmap = {
            { shared.GetConfig("Show Batt.Volt"), "V:",  2 },
            { shared.GetConfig("Show Alt."),      "A:",  0 },
            { shared.GetConfig("Show Home Alt."), "A.:", 0 },
            { shared.GetConfig("Show RSSI"),      "R:",  0 },
            { shared.GetConfig("Show Nsat"),      "N:",  0 },
            { shared.GetConfig("Show Vspeed"),    "V:",  0 },
            { shared.GetConfig("Show Hspeed"),    "V.:", 0 },
            { shared.GetConfig("Show Throt."),    "T:",  0 },
            { shared.GetConfig("Show TXpow."),    "T.:", 0 },
            { shared.GetConfig("Show Batt%"),     "B%",  0 },
        }
        for m = 1, #tmap
        do
            if tmap[m][1] == "ON" then
                shared.maphudItems[m] = { tmap[m][2], tmap[m][3] }
            else
                shared.maphudItems[m] = {}
            end
        end
    else
        shared.maphudItems = {}
    end
end

local function lMission()
    loadMission2()
    shared.mapState = { 0 }
    shared.gotonav = nil
    shared.mapScreen = true
    loadMapHud()
    shared.LoadScreen(shared.libsDir .. "wtroom.lua")
end

local function sortWP(commanddata)
    local isWP
    if commanddata == "Home" then
        isWP = 0
    else
        isWP = tonumber(commanddata)
    end
    return isWP
end

missionFNs = getFNS(setts.listFiles(shared.missionDir, ".txt"))

if #shared.coords ~= 0 then
    local WPnumbers = 1
    for c = 1, #shared.coords
    do
        if tonumber(shared.coords[c][2]) ~= 0 then
            local wpname = tostring(c - 1)
            if c == 1 then
                wpname = "Home"
            end
            if c ~= #shared.coords - 1 then
                mapoptionstable[1][3][5][3][WPnumbers] = { wpname, 6 }
                mapoptionstable[4][3][WPnumbers] = { wpname, 5 }
            end
            if c ~= #shared.coords - 2 then
                mapoptionstable[2][3][2][3][WPnumbers] = { wpname, 4 }
            end
            WPnumbers = WPnumbers + 1
        end
    end
else
    mapoptionstable[1][3][5][3][1] = ep
    mapoptionstable[4][3][1] = ep
    mapoptionstable[2][3][2][3][1] = ep
end

function shared.run(event)
    lcd.clear()
    local fag = {}
    if #shared.coords ~= 0 and shared.mapSource == true then
        shared.mapScreen = true
        loadMapHud()
        shared.LoadScreen(shared.libsDir .. "wtroom.lua")
    else
        if #usroptmap ~= 0 then
            fag = cm.expandOption(usroptmap, mapoptionstable, event, usrindex, nil, shared.isColor)
            usroptmap = fag[3]
            usrindex = fag[4]
            -- print(fag[2])
            -- print(fag[1])
            -- print("=====================")
            if fag[1] ~= nil then
                if fag[1] == 1 then
                    local ucommand = fag[2]
                    shared.mapState[2] = ucommand
                    if string.find(string.upper(ucommand), ".TXT") then
                        for f = 1, #missionFNs
                        do
                            if missionFNs[f] == ucommand then
                                shared.missionFile = shared.missionDir .. "/" .. missionFNs[f]
                            end
                        end
                        lMission()

                    else
                       -- usroptlist = shared.mapState[3] = { <number>, coords }
                    -- number:
                    -- 0 - nil
                    -- 1 - not used
                    -- 2 - "WP"
                    -- 3 - "WPs"
                    -- ucommand = shared.mapState[2]
                    -- 0 - Prepare "WPs"
                    -- 1 - not used
                    -- 2 - "WPc"
                    -- 3 - "WPs"
                    -- 4 - "Reset Scale"
                    -- 5 - not used
                    -- 6 - "Home"
                    -- 7 - "Center map"
                    -- 8 - "Vehicle - sticky"
                    -- 9 - "Vehicle - once"
                    -- ucommand2 = shared.mapState[4]
                    -- 0 - nil
                    -- 1- "Go To"
                    -- 2 - "Abort Go To"
                    -- usroptlist2 = shared.mapState[5] = { <number>, coords }
                    -- 0 - nil
                    -- 1 - "Go To"

                        if ucommand == "Home" then
                            shared.mapState[2] = 6
                        elseif ucommand == "Center map" then
                            shared.mapState[2] = 7
                        elseif ucommand == "Vehicle - sticky" then
                            shared.mapState[2] = 8
                        elseif ucommand == "Vehicle - once" then
                            shared.mapState[2] = 9
                        elseif ucommand == "Reset scale" then
                            shared.mapState[2] = 4
                        end
                    end

                elseif fag[1] == 4 then  
                    shared.mapState[2] = 1
                    shared.mapState[3] = { 1, sortWP(fag[2]) }
                elseif fag[1] == 5 then
                    shared.mapState[4] = 1
                    shared.mapState[5] = { 0, sortWP(fag[2]) }
                    shared.LoadScreen(shared.Mapscreen)
                elseif fag[1] == 6 then        
                    -- local ucommand2 = "WPc"
                    shared.mapState[2] = 2
                    shared.mapState[3] = { 2, sortWP(fag[2]) + 1 }
                elseif fag[1] == 7 then                    
                    shared.mapState[4] = 2
                    shared.gotoangle = 0
                elseif fag[1] == 8 then
                    if shared.maphud == true then
                        shared.maphud = false
                    else
                        shared.maphud = true
                        loadMapHud()
                    end
                elseif fag[1] == 9 then
                    if shared.gotonav ~= nil then
                        shared.mapState[2] = 1
                        shared.mapState[3] = { 1, #shared.coords - 1 }
                    end
                end
            end
        end

        if (event == 96 or event == 1540) and fag[1] == nil and #usroptmap == 0 then
            if #shared.coords == 0 then
                shared.LoadScreen(shared.libsDir .. "wtroom.lua")
            else
                shared.mapScreen = true
                loadMapHud()
                shared.LoadScreen(shared.libsDir .. "wtroom.lua")
            end
        elseif fag[1] ~= nil then
            shared.mapScreen = true
            shared.LoadScreen(shared.libsDir .. "wtroom.lua")
        end
    end
end
