local shared = { }
shared.stelemScreens = {
	"/SCRIPTS/TELEMETRY/stelem/menu1.lua",
	"/SCRIPTS/TELEMETRY/stelem/menu2.lua",
}
shared.stelemConfigmenu = "/SCRIPTS/TELEMETRY/stelem/cfmenu.lua"
local configFile = "/SCRIPTS/TELEMETRY/stelem/settings.cfg"
local messagesLogDir = "/SCRIPTS/TELEMETRY/stelem/logs/"
local soundsDir = "/SOUNDS/en/SCRIPTS/STELEM/"

shared.stelemMenuItems = {
	{ "Cell voltage",1,"False","True" },
	{ "Number of cells",4,"1","2","3","4","5","6","7","8" },
	{ "Variometer clip val",8,"5","10","15","20","25","30","35","40","45","50","55","60",
		"65","70","75","80","90","100","110","120","130","140","150","160","170","180","190","200" },
	{ "Att. indicator scale",1,"90","100","110","120","130","140","150","160","170","180" },
	{ "Msg log",1,"False","True" },
	{ "Sounds",2,"False","True" },
}

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

shared.stelemHeartbeat = 0

shared.stelemTelem = { }
shared.stelemTelem.flightMode = 0
shared.stelemTelem.roll = 0
shared.stelemTelem.pitch = 0
shared.stelemTelem.yaw = 0
shared.stelemTelem.range = 0
shared.stelemTelem.throttle = 0
shared.stelemTelem.numSats = 0
shared.stelemTelem.gpsHdopC = 0
shared.stelemTelem.gpsAlt = 0
shared.stelemTelem.batt1volt = 0
shared.stelemTelem.homeAlt = 0
shared.stelemTelem.batt1current = 0
shared.stelemTelem.batt1mah = 0
shared.stelemTelem.baroAlt = 0
shared.stelemTelem.homeDist = 0
shared.stelemTelem.homeAngle = 0
shared.stelemTelem.vSpeed = 0
shared.stelemTelem.gpsStatus = 0
shared.stelemTelem.RSSI = 0

shared.stelemMessages = {}
shared.stelemAlertmessages = { "", "" }
shared.stelemMessagesIndex = 1
local msglogfilename = ""
local msglogfile = nil

local function processTelemetry(appId, value, now)
	if appId == 0x5006 then
		shared.stelemTelem.roll = (math.min(bit32.extract(value, 0, 11), 1800) - 900) * 0.2
		shared.stelemTelem.pitch = (math.min(bit32.extract(value, 11, 10), 900) - 450) * 0.2
		shared.stelemTelem.range = bit32.extract(value, 22, 10) * (10 ^ bit32.extract(value, 21, 1)) -- cm
	elseif appId == 0x5005 then                                                   -- VELANDYAW
		shared.stelemTelem.yaw = bit32.extract(value, 17, 11) * 0.2
		shared.stelemTelem.vSpeed = bit32.extract(value, 1, 7) * (10 ^ bit32.extract(value, 0, 1)) *
			(bit32.extract(value, 8, 1) == 1 and -1 or 1)
	elseif appId == 0x5001 then -- AP STATUS
		shared.stelemTelem.flightMode = bit32.extract(value, 0, 5)
		shared.stelemTelem.simpleMode = bit32.extract(value, 5, 2)
		shared.stelemTelem.landComplete = bit32.extract(value, 7, 1)
		shared.stelemTelem.statusArmed = bit32.extract(value, 8, 1)
		shared.stelemTelem.battFailsafe = bit32.extract(value, 9, 1)
		shared.stelemTelem.ekfFailsafe = bit32.extract(value, 10, 2)
		shared.stelemTelem.failsafe = bit32.extract(value, 12, 1)
		shared.stelemTelem.fencePresent = bit32.extract(value, 13, 1)
		shared.stelemTelem.fenceBreached = shared.stelemTelem.fencePresent == 1 and bit32.extract(value, 14, 1) or 0 -- we ignore fence breach if fence is disabled
		shared.stelemTelem.throttle = math.floor(0.5 +
			(bit32.extract(value, 19, 6) * (bit32.extract(value, 25, 1) == 1 and -1 or 1) * 1.58)) -- signed throttle [-63,63] -> [-100,100]
																							  -- IMU temperature: 0 means temp =< 19°,63 means temp => 82°
		shared.stelemTelem.imuTemp = bit32.extract(value, 26, 6) + 19                                  -- C°
	elseif appId == 0x5002 then                                                               -- GPS STATUS
		shared.stelemTelem.numSats = bit32.extract(value, 0, 4)
		shared.stelemTelem.gpsHdopC = bit32.extract(value, 7, 7) * (10 ^ bit32.extract(value, 6, 1))   -- dm
		shared.stelemTelem.gpsAlt = bit32.extract(value, 24, 7) * (10 ^ bit32.extract(value, 22, 2)) *
			(bit32.extract(value, 31, 1) == 1 and -1 or 1)                                    -- dm
		shared.stelemTelem.gpsStatus = bit32.extract(value, 4, 2) + bit32.extract(value, 14, 2)
	elseif appId == 0x5003 then                                                               -- BATT
		shared.stelemTelem.batt1volt = bit32.extract(value, 0, 9) / 10                                 -- dV
		shared.stelemTelem.batt1current = (bit32.extract(value, 10, 7) * (10 ^ bit32.extract(value, 9, 1))) / 10 --dA
		shared.stelemTelem.batt1mah = bit32.extract(value, 17, 15)
	elseif appId == 0x5004 then                                                               -- HOME
		shared.stelemTelem.homeAlt = bit32.extract(value, 14, 10) * (10 ^ bit32.extract(value, 12, 2)) * 0.1 *
			(bit32.extract(value, 24, 1) == 1 and -1 or 1)                                    --m
		shared.stelemTelem.homeDist = bit32.extract(value, 2, 10) * (10 ^ bit32.extract(value, 0, 2))
		shared.stelemTelem.homeAngle = bit32.extract(value, 25, 7) * 3
	elseif appId == 0x50F2 then -- VFR
		shared.stelemTelem.baroAlt = bit32.extract(value, 17, 10) * (10 ^ bit32.extract(value, 15, 2)) * 0.1 *
			(bit32.extract(value, 27, 1) == 1 and -1 or 1)	
	end
	shared.stelemTelem.RSSI = getRSSI()
end

local function crossfirePop()
	local now = getTime()
	local command, data = crossfireTelemetryPop()
	if (command == 0x80 or command == 0x7F) and data ~= nil then
		shared.stelemHeartbeat = shared.stelemHeartbeat + 1
		if shared.stelemHeartbeat > 2 then
			shared.stelemHeartbeat = 0
		end
		if #data >= 7 and data[1] == 0xF0 then
			local app_id = bit32.lshift(data[3], 8) + data[2]
			local value = bit32.lshift(data[7], 24) + bit32.lshift(data[6], 16) + bit32.lshift(data[5], 8) + data[4]
			return 0x00, 0x10, app_id, value
		elseif #data > 4 and data[1] == 0xF1 then
			local severity = data[2]
			local tmessage = ""
			for i = 3, #data
			do
				if data[i] ~= 0 then
					tmessage = tmessage .. string.char(data[i])
				end
			end
			shared.stelemMessages[shared.stelemMessagesIndex] = tmessage
			shared.stelemMessagesIndex = shared.stelemMessagesIndex + 1

			if shared.stelemMessagesIndex == 10 then
				local templist = {}
				for j = 1, 8
				do
					templist[j] = shared.stelemMessages[j + 1]
				end
				shared.stelemMessages = templist
				shared.stelemMessagesIndex = 9
			end

			local playsounds = shared.stelemGetConfig(6)
			if playsounds == "True" then
				if severity < 6 and severity > 3 then
					playFile(soundsDir .. "alarm2.wav")
				elseif severity < 4 then
					playFile(soundsDir .. "alarm1.wav")
				end
			end

			if severity < 6 then
				shared.stelemAlertmessages[2] = shared.stelemAlertmessages[1]
				shared.stelemAlertmessages[1] = tmessage
			end

			if msglogfilename ~= "" then
				io.write(msglogfile, mavSeverity[severity] .. "= " .. tmessage .. "\n")
			end

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

function shared.stelemMessagesLog()
	local msgconf = shared.stelemGetConfig(5)
	if msgconf == "True" then
		local dt = getDateTime()
		msglogfilename = dt["sec"] ..
			"_" ..
			dt["min"] ..
			"_" .. dt["hour"] .. "_" .. dt["day"] .. "_" .. dt["mon"] .. "_" .. dt["year"] .. "_messageLog.txt"
		msglogfile = io.open(messagesLogDir .. msglogfilename, "w")
	end
end

function shared.stelemLoadScreen(screenref)
	shared.stelemCurrentScreen = 0
	local chunk = loadScript(screenref)
	chunk(shared)
end

function shared.stelemGetConfig(confnumber)
	local seloption = tonumber(shared.stelemMenuItems[confnumber][2])
	return shared.stelemMenuItems[confnumber][seloption + 2]
end

function shared.stelemSaveSettings()
	file = io.open(configFile, "w")
	for i = 1, #shared.stelemMenuItems
	do
		local confline = shared.stelemMenuItems[i]
		for j = 1, #confline
		do
			io.write(file, confline[j], ",")
		end
		io.write(file, "\n")
	end
	io.close(file)
end

local function stelemLoadSettings()
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
			shared.stelemMenuItems[archline] = cfgline
			archline = archline + 1
		end
	else
		shared.stelemSaveSettings()
	end
end


function shared.stelemCycleScreen(delta)
  shared.stelemCurrentScreen = shared.stelemCurrentScreen + delta
  if shared.stelemCurrentScreen > #shared.stelemScreens then
    shared.stelemCurrentScreen = 1
  elseif shared.stelemCurrentScreen < 1 then
    shared.stelemCurrentScreen = #shared.stelemScreens
  end
  local chunk = loadScript(shared.stelemScreens[shared.stelemCurrentScreen])
  chunk(shared)
end

local function background()
		local success, sensor_id, frame_id, data_id, value = pcall(crossfirePop)
		if success and frame_id == 0x10 then
			local now = getTime()
			processTelemetry(data_id, value, now)
		end
		
end

function shared.stelemLoadLua(filename)
	local success, f = pcall(loadScript, filename)
	if success then
		local ret = f()
		return ret
	else
		return nil
	end
end

local function init()
	stelemLoadSettings()
  shared.stelemCurrentScreen = 1
  shared.stelemCycleScreen(0)
  shared.stelemFrame = shared.stelemLoadLua("/SCRIPTS/TELEMETRY/stelem/copter.lua")
  shared.stelemMessagesLog()
end

local function run(event)
  shared.run(event)
end

return { run = run, init = init, background=background }