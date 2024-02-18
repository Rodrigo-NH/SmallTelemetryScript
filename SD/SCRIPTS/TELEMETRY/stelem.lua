local shared = {}
shared.screens = {
	"/SCRIPTS/TELEMETRY/stelem/menu1.lua",
	"/SCRIPTS/TELEMETRY/stelem/menu2.lua",
}
shared.configmenu = "/SCRIPTS/TELEMETRY/stelem/cfmenu.lua"
local configFile = "/SCRIPTS/TELEMETRY/stelem/settings.cfg"
local messagesLogDir = "/SCRIPTS/TELEMETRY/stelem/logs/"
local libBasePath = "/SCRIPTS/TELEMETRY/stelem/"
local soundsDir = "/SOUNDS/en/SCRIPTS/STELEM/"

menuItems = {
	{ "Cell voltage",1,"False","True" },
	{ "Number of cells",4,"1","2","3","4","5","6","7","8" },
	{ "Variometer clip val",16,"5","10","15","20","25","30","35","40","45","50","55","60",
		"65","70","75","80","90","100","110","120","130","140","150","160","170","180","190","200" },
	{ "Att. indicator scale",1,"90","100","110","120","130","140","150","160","170","180" },
	{ "Msg log",1,"False","True" },
	{ "Sounds",2,"False","True" },
}

globalargs = {}
globalargs.counter = 0
ardumessages = {}
alertmessages = { "", "" }
ardumessagesIndex = 1
msglogfilename = ""
msglogfile = nil

-- EMR,ALR,CRT,ERR,WRN,NOT,INF,DBG
local mavSeverity = {
	[0] = "EMR", -- Emergency - System is unusable
	[1] = "ALR", -- Alert - Should be corrected immediately
	[2] = "CRT", -- Critical - Critical conditions
	[3] = "ERR", -- Error - Error conditions
	[4] = "WRN", -- Warning - May indicate that an error will occur if action is not taken.
	[5] = "NOT", -- Notice - Events that are unusual,but not error conditions.
	[6] = "INF", -- Informational - Normal operational messages that require no action.
	[7] = "DBG", -- Debug - Information useful to developers for debugging the application.
}

-- OUTROS
-- globalargs.lastSoundTime = 0
telemheartbeat = 0
-- frame = {}

local function doLibrary(filename)
	local success, f = pcall(loadScript, libBasePath .. filename .. ".lua")
	if success then
		local ret = f()
		-- doGarbageCollect()
		return ret
	else
		-- doGarbageCollect()
		return nil
	end
end


telemetry = {}
telemetry.flightMode = 0
telemetry.roll = 0
telemetry.pitch = 0
telemetry.yaw = 0
telemetry.range = 0
telemetry.throttle = 0
telemetry.numSats = 0
telemetry.gpsHdopC = 0
telemetry.gpsAlt = 0
telemetry.batt1volt = 0
telemetry.homeAlt = 0
telemetry.batt1current = 0
telemetry.batt1mah = 0
telemetry.baroAlt = 0
telemetry.homeDist = 0
telemetry.homeAngle = 0
telemetry.vSpeed = 0
telemetry.gpsStatus = 0
telemetry.RSSI = 0

local telemetryPop = nil

function shared.loadConfig()
	shared.current = 0
	local chunk = loadScript(shared.configmenu)
	chunk(shared)
end

function shared.changeScreen(delta)
	shared.current = shared.current + delta
	if shared.current > #shared.screens then
		shared.current = 1
	elseif shared.current < 1 then
		shared.current = #shared.screens
	end
	local chunk = loadScript(shared.screens[shared.current])
	chunk(shared)
end

local function processTelemetry(appId, value, now)
	if appId == 0x5006 then
		telemetry.roll = (math.min(bit32.extract(value, 0, 11), 1800) - 900) * 0.2
		telemetry.pitch = (math.min(bit32.extract(value, 11, 10), 900) - 450) * 0.2
		telemetry.range = bit32.extract(value, 22, 10) * (10 ^ bit32.extract(value, 21, 1)) -- cm
	elseif appId == 0x5005 then                                                   -- VELANDYAW
		telemetry.yaw = bit32.extract(value, 17, 11) * 0.2
		telemetry.vSpeed = bit32.extract(value, 1, 7) * (10 ^ bit32.extract(value, 0, 1)) *
			(bit32.extract(value, 8, 1) == 1 and -1 or 1)
	elseif appId == 0x5001 then -- AP STATUS
		telemetry.flightMode = bit32.extract(value, 0, 5)
		telemetry.simpleMode = bit32.extract(value, 5, 2)
		telemetry.landComplete = bit32.extract(value, 7, 1)
		telemetry.statusArmed = bit32.extract(value, 8, 1)
		telemetry.battFailsafe = bit32.extract(value, 9, 1)
		telemetry.ekfFailsafe = bit32.extract(value, 10, 2)
		telemetry.failsafe = bit32.extract(value, 12, 1)
		telemetry.fencePresent = bit32.extract(value, 13, 1)
		telemetry.fenceBreached = telemetry.fencePresent == 1 and bit32.extract(value, 14, 1) or 0 -- we ignore fence breach if fence is disabled
		telemetry.throttle = math.floor(0.5 +
			(bit32.extract(value, 19, 6) * (bit32.extract(value, 25, 1) == 1 and -1 or 1) * 1.58)) -- signed throttle [-63,63] -> [-100,100]
																							  -- IMU temperature: 0 means temp =< 19°,63 means temp => 82°
		telemetry.imuTemp = bit32.extract(value, 26, 6) + 19                                  -- C°
	elseif appId == 0x5002 then                                                               -- GPS STATUS
		telemetry.numSats = bit32.extract(value, 0, 4)
		telemetry.gpsHdopC = bit32.extract(value, 7, 7) * (10 ^ bit32.extract(value, 6, 1))   -- dm
		telemetry.gpsAlt = bit32.extract(value, 24, 7) * (10 ^ bit32.extract(value, 22, 2)) *
			(bit32.extract(value, 31, 1) == 1 and -1 or 1)                                    -- dm
		telemetry.gpsStatus = bit32.extract(value, 4, 2) + bit32.extract(value, 14, 2)
	elseif appId == 0x5003 then                                                               -- BATT
		telemetry.batt1volt = bit32.extract(value, 0, 9) / 10                                 -- dV
		telemetry.batt1current = (bit32.extract(value, 10, 7) * (10 ^ bit32.extract(value, 9, 1))) / 10 --dA
		telemetry.batt1mah = bit32.extract(value, 17, 15)
	elseif appId == 0x5004 then                                                               -- HOME
		telemetry.homeAlt = bit32.extract(value, 14, 10) * (10 ^ bit32.extract(value, 12, 2)) * 0.1 *
			(bit32.extract(value, 24, 1) == 1 and -1 or 1)                                    --m
		telemetry.homeDist = bit32.extract(value, 2, 10) * (10 ^ bit32.extract(value, 0, 2))
		telemetry.homeAngle = bit32.extract(value, 25, 7) * 3
	elseif appId == 0x50F2 then -- VFR
		telemetry.baroAlt = bit32.extract(value, 17, 10) * (10 ^ bit32.extract(value, 15, 2)) * 0.1 *
			(bit32.extract(value, 27, 1) == 1 and -1 or 1)	
	end
	telemetry.RSSI = getRSSI()
end

local function crossfirePop()
	local now = getTime()
	local command, data = crossfireTelemetryPop()
	if (command == 0x80 or command == 0x7F) and data ~= nil then
		telemheartbeat = telemheartbeat + 1
		if telemheartbeat > 500 then
			telemheartbeat = 0
		end
		if #data >= 7 and data[1] == 0xF0 then
			local app_id = bit32.lshift(data[3], 8) + data[2]
			local value = bit32.lshift(data[7], 24) + bit32.lshift(data[6], 16) + bit32.lshift(data[5], 8) + data[4]
			return 0x00, 0x10, app_id, value
		elseif #data > 4 and data[1] == 0xF1 then
			local severity = data[2]

			local playsounds = shared.getConfig(6)
			if playsounds == "True" then
				if severity < 6 and severity > 3 then
					playFile(soundsDir .. "alarm2.wav")
				elseif severity < 4 then
					playFile(soundsDir .. "alarm1.wav")
				end
			end

			local tmessage = ""
			for i = 3, #data
			do
				if data[i] ~= 0 then
					tmessage = tmessage .. string.char(data[i])
				end
			end
			ardumessages[ardumessagesIndex] = tmessage
			ardumessagesIndex = ardumessagesIndex + 1

			if ardumessagesIndex == 10 then
				local templist = {}
				for j = 1, 8
				do
					templist[j] = ardumessages[j + 1]
				end
				ardumessages = templist
				ardumessagesIndex = 9
			end

			if msglogfilename ~= "" then
				io.write(msglogfile, mavSeverity[severity] .. "= " .. tmessage .. "\n")
			end

			if severity < 6 then
				alertmessages[2] = alertmessages[1]
				alertmessages[1] = tmessage
			end

			doGarbageCollect()
		elseif #data >= 8 and data[1] == 0xF2 then
			-- passthrough array
			local app_id, value
			for i = 0, math.min(data[2] - 1, 9)
			do
				app_id = bit32.lshift(data[4 + (6 * i)], 8) + data[3 + (6 * i)]
				value = bit32.lshift(data[8 + (6 * i)], 24) + bit32.lshift(data[7 + (6 * i)], 16) +
					bit32.lshift(data[6 + (6 * i)], 8) + data[5 + (6 * i)]
				processTelemetry(app_id, value, now)
			end
		end
	end
end

local function background()
	local now = getTime()
	for i = 1, 7
	do
		local success, sensor_id, frame_id, data_id, value = pcall(telemetryPop)
		if success and frame_id == 0x10 then
			processTelemetry(data_id, value, now)
		end
	end
end

function shared.saveSettings()
	file = io.open(configFile, "w")
	local linen = 0
	for i = 1, #menuItems
	do
		local confline = menuItems[i]
		for j = 1, #confline
		do
			io.write(file, confline[j], ",")
		end
		io.write(file, "\n")
	end
	io.close(file)
end

function loadSettings()
	local cfg = io.open(configFile, "r")
	if cfg ~= nil then
		local str = io.read(cfg, 500)
		io.close(cfg)
		local archline = 1
		for strout in string.gmatch(str, "([^" .. "%\n" .. "]+)") do
			local ctr = 1
			local cfgline = {}
			for tentry in string.gmatch(strout, '([^,]+)') do
				cfgline[ctr] = tentry
				ctr = ctr + 1
			end
			menuItems[archline] = cfgline
			archline = archline + 1
		end
	else
		shared.saveSettings()
	end
end

function shared.messagesLog()
	local msgconf = shared.getConfig(5)
	if msgconf == "True" then
		local dt = getDateTime()
		msglogfilename = dt["sec"] ..
			"_" ..
			dt["min"] ..
			"_" .. dt["hour"] .. "_" .. dt["day"] .. "_" .. dt["mon"] .. "_" .. dt["year"] .. "_messageLog.txt"
		msglogfile = io.open(messagesLogDir .. msglogfilename, "w")
	end
end

function shared.getConfig(confnumber)
	local seloption = tonumber(menuItems[confnumber][2])
	return menuItems[confnumber][seloption + 2]
end

local function init()
	loadSettings()
	shared.current = 4
	shared.changeScreen(0)
	telemetryPop = crossfirePop
	frame = doLibrary("copter")
	shared.messagesLog()
end

local function run(event)
	shared.run(event)
end

return { run = run, background = background, init = init }
