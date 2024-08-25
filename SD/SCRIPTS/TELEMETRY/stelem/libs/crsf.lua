local flightModes = {}
-- copter flight modes
flightModes[1] = "STAB"
flightModes[2] = "ACRO"
flightModes[3] = "ALTH"
flightModes[4] = "AUTO"
flightModes[5] = "GUID"
flightModes[6] = "LOIT"
flightModes[7] = "RTL"
flightModes[8] = "CIRC"
flightModes[9] = ""
flightModes[10] = "Land"
flightModes[11] = ""
flightModes[12] = "DRIF"
flightModes[13] = ""
flightModes[14] = "SPORT"
flightModes[15] = "FLIP"
flightModes[16] = "AUTOT"
flightModes[17] = "POSH"
flightModes[18] = "BRAKE"
flightModes[19] = "THROW"
flightModes[20] = "A.ADSB"
flightModes[21] = "G.NOGPS"
flightModes[22] = "SRTL"
flightModes[23] = "FLOWH"
flightModes[24] = "FOLLOW"
flightModes[25] = "ZZAG"
flightModes[26] = "SYSID"
flightModes[27] = "A.ROT"
flightModes[28] = "A.RTL"
flightModes[29] = "TURTL"

local function standardTele(shared)
	local gps = getValue(shared.MenuItems[31][3])
	if gps ~= 0 then
		shared.tel.lat = gps.lat
		shared.tel.lon = gps.lon
		-- shared.MenuItems[24][2] = 2
	end	
	shared.tel.RSSI = getValue(shared.MenuItems[29][3])
	shared.tel.txpower = getValue(shared.MenuItems[30][3])
	shared.tel.alt = getValue(shared.MenuItems[34][3])
	shared.tel.battpercent = getValue(shared.MenuItems[38][3])
	shared.tel.hdg = getValue(shared.MenuItems[33][3])
end

local function processTelemetry(appId, value, shared)
	standardTele(shared)

	if appId == 0x5006 then
		shared.tel.roll = (math.min(bit32.extract(value, 0, 11), 1800) - 900) * 0.2
		shared.tel.pitch = (math.min(bit32.extract(value, 11, 10), 900) - 450) * 0.2
		-- shared.tel.range = bit32.extract(value, 22, 10) * (10 ^ bit32.extract(value, 21, 1)) -- cm
	elseif appId == 0x5005 then -- VELANDYAW
		shared.tel.yaw = bit32.extract(value, 17, 11) * 0.2
		shared.tel.vSpeed = bit32.extract(value, 1, 7) * (10 ^ bit32.extract(value, 0, 1)) *
			(bit32.extract(value, 8, 1) == 1 and -1 or 1)
		shared.tel.hSpeed = bit32.extract(value, 10, 7) * (10 ^ bit32.extract(value, 9, 1)) -- dm/s
	elseif appId == 0x5001 then                                                       -- AP STATUS
		-- local fm = bit32.extract(value, 0, 5)
		-- if fm == 0 then
		-- 	shared.tel.flightMode = ""
		-- else
		-- 	shared.tel.flightMode = flightModes[bit32.extract(value, 0, 5)]
		-- end
		shared.tel.flightMode = flightModes[bit32.extract(value, 0, 5)]

		-- shared.tel.simpleMode = bit32.extract(value, 5, 2)
		-- shared.tel.landComplete = bit32.extract(value, 7, 1)
		shared.tel.statusArmed = bit32.extract(value, 8, 1)
		-- shared.tel.battFailsafe = bit32.extract(value, 9, 1)
		-- shared.tel.ekfFailsafe = bit32.extract(value, 10, 2)
		-- shared.tel.failsafe = bit32.extract(value, 12, 1)
		-- shared.tel.fencePresent = bit32.extract(value, 13, 1)
		-- shared.tel.fenceBreached = shared.tel.fencePresent == 1 and bit32.extract(value, 14, 1) or 0                                                                                      -- we ignore fence breach if fence is disabled
		shared.tel.throttle = math.floor(0.5 +
			(bit32.extract(value, 19, 6) * (bit32.extract(value, 25, 1) == 1 and -1 or 1) * 1.58)) -- signed throttle [-63,63] -> [-100,100]
		-- IMU temperature: 0 means temp =< 19°,63 means temp => 82°
		-- shared.tel.imuTemp = bit32.extract(value, 26, 6) + 19                                 -- C°
	elseif appId == 0x5002 then
		shared.tel.numSats = bit32.extract(value, 0, 4)
		shared.tel.gpsHdopC = bit32.extract(value, 7, 7) * (10 ^ bit32.extract(value, 6, 1)) -- dm
		if shared.tel.alt == 0 then
			local yaalt = (bit32.extract(value, 24, 7) * (10 ^ bit32.extract(value, 22, 2)) *
				(bit32.extract(value, 31, 1) == 1 and -1 or 1)) / 10 -- m (telemetry.gpsAlt)
			if yaalt ~= 0 then
				shared.tel.alt = yaalt
			end
		end
		shared.tel.gpsStatus = bit32.extract(value, 4, 2) + bit32.extract(value, 14, 2)
	elseif appId == 0x5003 then -- BATT
		local dividefactor = tonumber(1)
		if tonumber(shared.MenuItems[3][2]) == 2 then
			dividefactor = tonumber(shared.GetConfig("Number of cells"))
		end
		shared.tel.batt1volt = (bit32.extract(value, 0, 9) / 10) / dividefactor
		shared.tel.batt1current = (bit32.extract(value, 10, 7) * (10 ^ bit32.extract(value, 9, 1))) / 10 --dA
		shared.tel.batt1mah = bit32.extract(value, 17, 15)
	elseif appId == 0x500D then                                                                    -- WAYPOINTS @1Hz
		shared.tel.wpNumber = bit32.extract(value, 0, 11)                                          -- wp index
		shared.tel.wpDistance = bit32.extract(value, 13, 10) * (10 ^ bit32.extract(value, 11, 2))  -- meters
		shared.tel.wpBearing = bit32.extract(value, 23, 7) * 3
	elseif appId == 0x5004 then                                                                    -- HOME
		shared.tel.homeAlt = bit32.extract(value, 14, 10) * (10 ^ bit32.extract(value, 12, 2)) * 0.1 *
			(bit32.extract(value, 24, 1) == 1 and -1 or 1)                                         --m
		shared.tel.homeDist = bit32.extract(value, 2, 10) * (10 ^ bit32.extract(value, 0, 2))
		shared.tel.homeAngle = bit32.extract(value, 25, 7) * 3
		-- elseif appId == 0x50F2 then -- VFR
		-- 	shared.tel.baroAlt = bit32.extract(value, 17, 10) * (10 ^ bit32.extract(value, 15, 2)) * 0.1 *
		-- 		(bit32.extract(value, 27, 1) == 1 and -1 or 1)
	end
end

local function getTele(sh)
	local shared = sh
	local tmessage = ""
	-- local now = getTime()
	local command, data = crossfireTelemetryPop()
	if (command == 0x80 or command == 0x7F) and data ~= nil then
		shared.Heartbeat = shared.Heartbeat + 1
		if shared.Heartbeat > 2 then
			shared.Heartbeat = 0
		end
		if #data >= 7 and data[1] == 0xF0 then
			local app_id = bit32.lshift(data[3], 8) + data[2]
			local value = bit32.lshift(data[7], 24) + bit32.lshift(data[6], 16) + bit32.lshift(data[5], 8) + data[4]
			processTelemetry(app_id, value, shared)
			-- return 0x00, 0x10, app_id, value
		elseif #data > 4 and data[1] == 0xF1 then
			local severity = data[2]

			for i = 3, #data
			do
				if data[i] ~= 0 then
					tmessage = tmessage .. string.char(data[i])
				end
			end

			shared.MessagesIndex = shared.MessagesIndex + 1
			shared.Messages[shared.MessagesIndex] = tmessage
			if shared.scrollIndex > 1 then
				shared.scrollIndex = shared.scrollIndex + 1
			end
			if shared.MessagesIndex == shared.MessagesBuffSize + 1 then
				for j = 1, shared.MessagesBuffSize
				do
					shared.Messages[j] = shared.Messages[j + 1]
				end
				shared.Messages[#shared.Messages] = nil
				shared.MessagesIndex = shared.MessagesBuffSize
			end

			if shared.msglogfilename ~= "" then
				io.write(shared.msglogfilename, tostring(severity) .. "=" .. tmessage .. "\n")
			end

			local soundfile = ""
			-- origin set
			if string.match(tmessage, "igin set") then
				shared.homeLocation = { shared.tel.lat, shared.tel.lon }
				soundfile = "os.wav"
			end
			local sev = false
			if severity < 6 and severity > 3 then
				soundfile = "a2.wav"
				sev = true
			elseif severity < 4 then
				soundfile = "a1.wav"
				sev = true
			end
			-- GPS Glitch
			if string.match(tmessage, "S Glit") then
				soundfile = "gl.wav"
				-- Glitch cleared
			elseif string.match(tmessage, "ch cleare") then
				soundfile = "gc.wav"
			end
			-- local playsounds = shared.GetConfig("Sounds")
			if tonumber(shared.MenuItems[8][2]) == 2 then
				playFile(shared.soundsDir .. soundfile)
			end

			if sev then
				shared.Alertmessages[1] = shared.Alertmessages[2]
				shared.Alertmessages[2] = tmessage
			end
		elseif #data >= 8 and data[1] == 0xF2 then
			-- passthrough array
			local app_id, value
			for i = 0, math.min(data[2] - 1, 9)
			do
				app_id = bit32.lshift(data[4 + (6 * i)], 8) + data[3 + (6 * i)]
				value = bit32.lshift(data[8 + (6 * i)], 24) + bit32.lshift(data[7 + (6 * i)], 16) +
					bit32.lshift(data[6 + (6 * i)], 8) + data[5 + (6 * i)]
				processTelemetry(app_id, value, shared)
			end
		else

		end
	else

	end
end

return {
	getTele = getTele
}
