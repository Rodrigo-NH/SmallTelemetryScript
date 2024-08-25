local shared = {}

-- local debugm = "txd"
local debugm = "bt"
shared.rootDir = "/SCRIPTS/TELEMETRY/stelem/"
shared.Mapscreen = shared.rootDir .. "sc_map.lua"
if fstat(shared.rootDir .. "sc_map.luac") == nil then
	loadScript(shared.Mapscreen, debugm)
end
shared.Mapconf = shared.rootDir .. "sc_mapc.lua"
shared.Configmenu = shared.rootDir .. "sc_conf.lua"
shared.configFile = shared.rootDir .. "settings.cfg"
local messagesLogDir = shared.rootDir .. "logs/"
shared.soundsDir = "/SOUNDS/en/SCRIPTS/STELEM/"
shared.libsDir = shared.rootDir .. "libs/"
shared.missionDir = shared.rootDir .. "missions"
shared.isColor = false

shared.missionFile = ""
shared.maxmem = 0
local telem = nil
local firstRun = true

-- shared.isMapLoaded = false
shared.goMap = false
shared.goConf = false
shared.mapScreen = false
shared.mapoptionstable = {}
shared.maphud = true
shared.maphudItems = {}
shared.mapState = { 0 }
-- shared.mapState
-- 1 - zoomscale
-- 2 - ucommand
-- 3 - usroptlist
-- 4 - ucommand2
-- 5 - usroptlist2
shared.mapSource = false
shared.hdgOffset = 0

shared.tcounter = 0
-- To be populated in ini() accordingly user selection screen size
shared.Screens = {}
shared.screenItems = {}
shared.screensFile = ""
shared.screenW = 0
shared.screenH = 0
shared.pixelSize = 0 -- millimeters
shared.coords = {}

shared.gotonav = nil
shared.gotoangle = 0
shared.gotodist = 0
shared.hdgVel = 0
shared.hdgVeltimer = 0
shared.hdgLastPos = { 0, 0 }
shared.autoGotoTimer = 0
shared.gotonavTimer = 0
shared.heartBeatChecker = 0

shared.tempTimer = getTime() + 500
shared.tempTimer2 = 0
shared.tempcounter = 0

-- All config options
local hdgtim = "Hdg vel. time (sec)"
local hdgtim2 = "Heading method"
local hdgtim3 = "Miss. Auto GoTo"
local hdgtim4 = "Hdg vel. min. distance"
local hdgtim5 = "Hdg vel debug sound"
local hdgtyaw = "Yaw"
local hdgtvelocity = "Velocity"
local hdgtmixed = "Mixed"
local hdgttelemetry = "Telemet."
-- local hdgsimul = "Simulate"
local ons = "ON"
local offs = "OFF"
local falses = "False"
local trues = "True"
shared.MenuItems = {
	{ "Screen Size",     1, "128x64", "212x64", "480x272" },
	{ "Msg Buffer size", 1, "9",      "18",     "24",     "48", "96", "192" },
	{ "Cell voltage",    1, falses,   trues },
	{ "Number of cells", 4, "1",      "2",      "3",      "4",  "5",  "6",  "7", "8" },
	{ "Variometer clip val", 8, "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60",
		"65", "70", "75", "80", "90", "100", "110", "120", "130", "140", "150", "160", "170", "180", "190", "200" },
	{ "Att. indicator scale", 1, "1",   "0.8",      "0.6",   "0.4",     "0.3" },
	{ "Msg log",              1, falses,  trues },
	{ "Sounds",               2, falses,  trues },
	{ "Show WP numbers",      1, ons,     offs },
	{ "Show scale",           1, ons,     offs },
	{ hdgtim3,                2, ons,     offs },
	{ "Show Batt.Volt",       2, ons,     offs },
	{ "Show Alt.",            2, ons,     offs },
	{ "Show Home Alt.",       2, ons,     offs },
	{ "Show RSSI",            2, ons,     offs },
	{ "Show Nsat",            2, ons,     offs },
	{ "Show Vspeed",          2, ons,     offs },
	{ "Show Hspeed",          2, ons,     offs },
	{ "Show Throt.",          2, ons,     offs },
	{ "Show TXpow.",          2, ons,     offs },
	{ "Show Batt%",           2, ons,     offs },
	{ "DebMem",               2, ons,     offs },
	-- { hdgsimul,             2, ons,     offs },
	{ hdgtim2,                3, hdgtyaw,  hdgtvelocity, hdgtmixed, hdgttelemetry },
	{ hdgtim4,                4, "0.1",  "1",        "2",     "3",       "5",   "8",   "10" },
	{ hdgtim,                 3, "0.5",  "1",        "2",     "3",       "4",   "5",   "6" },
	{ hdgtim5,                2, ons,    offs },
	{ "CRSF Telemetry",       1, offs,   ons },
	{ "Origin set Upd. Home", 2, ons,    offs },
	-- Telemetry Mapping
	{ "RSS",                  1, "1RSS" },
	{ "TxPower",              1, "TPWR" },
	{ "GPS position",         1, "GPS" },
	{ "GPS speed",            1, "GSpd" },
	{ "Heading",              1, "Hdg" },
	{ "Altitude",             1, "Alt" },
	{ "Number of sats",       1, "Sats" },
	{ "RX batt. volt.",       1, "RxBt" },
	{ "Current",              1, "Curr" },
	{ "Batt.(%)",             1, "Bat%" },
	{ "Pitch",                1, "Ptch" },
	{ "Roll",                 1, "Roll" },
	{ "Yaw",                  1, "Yaw" },
	{ "Flight Mode",          1, "FM" },
}


-- local hdgmeth = shared.GetConfig("Heading method")
-- local hdgtimer = tonumber(shared.GetConfig(hdgtim))
-- local hdgdistance = tonumber(shared.GetConfig(hdgtim4))
-- local hgddebugsound = shared.GetConfig(hdgtim5)


shared.Heartbeat = 0
shared.CurrentScreen = 1

shared.tel = {}
shared.tel.flightMode = ""
shared.tel.roll = 0
shared.tel.pitch = 0
shared.tel.yaw = 0
shared.tel.range = 0
shared.tel.throttle = 0
shared.tel.numSats = 0
shared.tel.gpsHdopC = 0
-- shared.tel.gpsAlt = 0
shared.tel.batt1volt = 0
shared.tel.homeAlt = 0
shared.tel.alt = 0
shared.tel.batt1current = 0
shared.tel.batt1mah = 0
shared.tel.battpercent = 0
-- shared.tel.baroAlt = 0
shared.tel.homeDist = 0
shared.tel.homeAngle = 0
shared.tel.vSpeed = 0
shared.tel.gpsStatus = 0
shared.tel.RSSI = 0
shared.tel.statusArmed = 0
shared.tel.wpNumber = 0
shared.tel.wpDistance = 0
shared.tel.wpXTError = 0
shared.tel.wpBearing = 0
shared.tel.lat = 0
shared.tel.lon = 0
shared.tel.txpower = 0
shared.tel.hSpeed = 0
shared.tel.hdg = 0

-- Last know home (origin set) location lat/long
shared.homeLocation = { 0, 0 }
shared.Messages = {}
shared.Alertmessages = { "", "" }
shared.MessagesIndex = 0
shared.scrollIndex = 1
shared.MessagesBuffSize = 1
shared.msglogfilename = ""
shared.msglogfile = ""

function shared.LoadLua(filename)
	local sc = loadScript(filename, debugm)
	return sc()
end

local setts = shared.LoadLua(shared.libsDir .. "setmgm.lua")
local function compall()
	local luadirs = {
		shared.rootDir .. "libs",
		shared.rootDir .. "128x64",
		shared.rootDir .. "212x64",
		shared.rootDir,
	}
	for t = 1, #luadirs
	do
		local flist = setts.listFiles(luadirs[t], ".lua")
		for f = 1, #flist
		do
			local fullpath = luadirs[t] .. "/" .. flist[f]
			local fpc = fullpath .. "c"
			if fstat(fpc) == nil then
				loadScript(fullpath, debugm)
			end
		end
	end
end
compall()

function shared.LoadScreen(screenref)
	local chunk = nil
	if #shared.Screens == 0 then
		screenref = shared.Configmenu
	end
	chunk = loadScript(screenref, debugm)
	if chunk ~= nil then
		chunk(shared)
	end
end

function shared.GetConfig(confname)
	local confnumber = 0
	for cf = 1, #shared.MenuItems
	do
		local to = shared.MenuItems[cf][1]
		if to == confname then
			confnumber = cf
		end
	end
	local seloption = tonumber(shared.MenuItems[confnumber][2])
	return shared.MenuItems[confnumber][seloption + 2]
end

local function MessagesLog()
	local msgconf = shared.GetConfig("Msg log")
	if msgconf == "True" then
		local dt = getDateTime()
		local msglogfilename = dt["sec"] ..
			"_" ..
			dt["min"] ..
			"_" .. dt["hour"] .. "_" .. dt["day"] .. "_" .. dt["mon"] .. "_" .. dt["year"] .. "_messageLog.txt"
		shared.msglogfilename = io.open(messagesLogDir .. msglogfilename, "w")
	end
end

function shared.nbformat(input, decplaces)
	return string.format("%." .. tostring(decplaces) .. "f", tostring(input))
end

local function hdgcalc(hdgmeth)
	local tempvel = 0
	local hdgdistance = tonumber(shared.GetConfig(hdgtim4))
	local hgddebugsound = shared.GetConfig(hdgtim5)

	if shared.hdgLastPos[1] == 0 and shared.tel.lat ~= 0 then
		shared.hdgLastPos[1] = shared.tel.lat
		shared.hdgLastPos[2] = shared.tel.lon
	elseif shared.tel.lat ~= 0 then
		local t1 = shared.geo.translatePoint(shared.hdgLastPos[1], shared.hdgLastPos[2], 500, 500)
		local t2 = shared.geo.translatePoint(shared.tel.lat, shared.tel.lon, 500, 500)
		local dt = shared.geo.distPoints(shared.hdgLastPos[1], shared.hdgLastPos[2], shared.tel.lat, shared.tel.lon)
		if dt > hdgdistance then
			if hgddebugsound == ons then
				playFile(shared.soundsDir .. "bo.wav")
			end
			tempvel = shared.geo.anglePointsPlane(t1[1], t1[2], t2[1], t2[2])
			shared.hdgLastPos[1] = shared.tel.lat
			shared.hdgLastPos[2] = shared.tel.lon
		end
	end

	if tempvel == 0 and hdgmeth == hdgtmixed then
		tempvel = shared.tel.yaw + shared.hdgOffset
	elseif tempvel == 0 and hdgmeth == hdgtvelocity then
		tempvel = shared.hdgVel
	end
	return tempvel
end

-- SIMULATE
-- local function telefun(message)
-- 	shared.MessagesIndex = shared.MessagesIndex + 1
-- 	shared.Messages[shared.MessagesIndex] = message
-- 	if shared.scrollIndex > 1 then
-- 		shared.scrollIndex = shared.scrollIndex + 1
-- 	end
-- 	if shared.MessagesIndex == shared.MessagesBuffSize + 1 then
-- 		for j = 1, shared.MessagesBuffSize
-- 		do
-- 			shared.Messages[j] = shared.Messages[j+1]
-- 		end
-- 		shared.Messages[#shared.Messages] = nil
-- 		shared.MessagesIndex = shared.MessagesBuffSize				
-- 	end
-- end
-- SIMULATE

local function background(event)
	-- SIMULATE
	-- if  getTime() - shared.tempTimer > 107 then
	-- 	shared.tempTimer = getTime()
	-- 	if firstRun then
	-- 	shared.tel.lat = -49.1855117
	-- 	shared.tel.lon = 70.3391770
	-- 	firstRun = false
	-- 	end
	-- 	-- shared.tempTimer2 = shared.tempTimer2 + 1
	-- 	-- shared.tel.homeAlt = shared.tel.homeAlt + 1
	-- 	-- telefun("Ardupilot Message " .. tostring(shared.tempTimer2))
	-- 	shared.tel.lat =  shared.tel.lat - 0.00002
	-- 	shared.tel.lon =  shared.tel.lon  - 0.0002
	-- end
	-- SIMULATE
	
		-- shared.telekeyDebounce = shared.telekeyDebounce + 1
		-- if shared.telekeyDebounce > 5 then
		-- 	shared.telekeyDebounce = 5
		-- end

	
	-- print(shared.telekeyDebounce)

	if getTime() - shared.gotonavTimer > 51 and shared.gotonav ~= nil and shared.mapSource == false then
		shared.gotonavTimer = getTime()
		shared.geo.translateData(shared, 500, 0, 500, 0)
		shared.geo.gotonav(shared, false)
	end

	local hdgmeth = shared.GetConfig(hdgtim2)
	local hdgtimer = tonumber(shared.GetConfig(hdgtim))

	if hdgmeth == hdgtyaw then
		shared.hdgVel = shared.tel.yaw + shared.hdgOffset
	elseif hdgmeth == hdgttelemetry then
		shared.hdgVel = shared.tel.hdg
	elseif getTime() - shared.hdgVeltimer > hdgtimer * 93 then
		shared.hdgVeltimer = getTime()
		shared.hdgVel = hdgcalc(hdgmeth)
	end

	if shared.GetConfig(hdgtim3) == ons then
		if getTime() - shared.autoGotoTimer > 57 then
			shared.autoGotoTimer = getTime()
			if shared.tel.wpNumber ~= 0 and #shared.coords - 2 >= shared.tel.wpNumber + 1
				and shared.coords[shared.tel.wpNumber + 1][2] ~= 0 then
				shared.mapState[4] = "Go To"
				shared.mapState[5] = { "", shared.tel.wpNumber }
				shared.gotonav = shared.tel.wpNumber
			end
		end
	end
	telem.getTele(shared)
end

local function init()
	-- if shared.GetConfig(hdgsimul) == ons then
		-- shared.tel.lat = -49.1855117
		-- shared.tel.lon = 70.3391770
	-- end
	Batt1volt = 23
	shared.geo = shared.LoadLua(shared.libsDir .. "geo.lua")
	setts.LoadSettings(shared.configFile, shared.MenuItems, shared)
	shared.MessagesBuffSize = tonumber(shared.GetConfig("Msg Buffer size"))
	setts.loadScreens(shared.GetConfig("Screen Size"), shared)
	MessagesLog()
	-- if firstRun then
	if shared.GetConfig("CRSF Telemetry") == ons then
		telem = shared.LoadLua(shared.libsDir .. "crsf.lua")
	else
		telem = shared.LoadLua(shared.libsDir .. "dtele.lua")
	end
		-- firstRun = false
	-- end
	-- shared.goConf = true
	shared.LoadScreen(shared.libsDir .. "wtroom.lua")
	-- shared.LoadScreen(shared.Configmenu)
	-- shared.LoadScreen(shared.Screens[1])
end

local function getWidget(LCD_W, LCD_H)
	if LCD_W > 212 then
		shared.isColor = true
		shared.screenW = LCD_W
		shared.screenH = LCD_H
	end
	local sc = tostring(LCD_W) .. "x" .. tostring(LCD_H)
	print(sc)
	if sc == "480x272" then
		setts.LoadSettings(shared.configFile, shared.MenuItems, shared)
		shared.MenuItems[1][2] = 3
		if tonumber(shared.GetConfig("Msg Buffer size")) < 24 then
			shared.MenuItems[2][2] = 4
		end
		setts.SaveSettings(shared.configFile, shared.MenuItems)
	end
	init()
end

local function run(event)
	shared.run(event)
end

return { run = run, init = init, background = background, getWidget = getWidget }
