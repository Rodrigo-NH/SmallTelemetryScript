local function HBcheck(telemvalue, shared)
	if telemvalue ~= nil and telemvalue ~= 0 then
		shared.heartBeatChecker = shared.heartBeatChecker + telemvalue
	end
end

local function getTele(shared)
	local lastHB = shared.heartBeatChecker
	shared.heartBeatChecker = 100

	shared.tel.RSSI = getValue(shared.GetConfig("RSS"))
	HBcheck(shared.tel.RSSI, shared)

	local gps = getValue(shared.GetConfig("GPS position"))
	if gps ~= 0 then
		shared.tel.lat = gps.lat
		shared.tel.lon = gps.lon
		HBcheck(shared.tel.lon, shared)
	end
	local gpsnsat = getValue(shared.GetConfig("Number of sats"))
	if gpsnsat ~= 0 then
		shared.tel.numSats = gpsnsat
	end

	shared.tel.yaw = getValue(shared.GetConfig("Yaw"))
	HBcheck(shared.tel.yaw, shared)
	shared.tel.yaw = math.deg(shared.tel.yaw)
	if shared.tel.yaw < 0 then
		shared.tel.yaw = shared.tel.yaw + 360
	end

	shared.tel.pitch = getValue(shared.GetConfig("Pitch"))
	shared.tel.pitch = math.deg(shared.tel.pitch)
	HBcheck(shared.tel.pitch, shared)

	shared.tel.roll = getValue(shared.GetConfig("Roll"))
	shared.tel.roll = math.deg(shared.tel.roll)
	HBcheck(shared.tel.roll, shared)

	local dividefactor = 1
	if shared.MenuItems[3][2] == 2 then
		dividefactor = tonumber(shared.GetConfig("Number of cells"))
	end
	-- shared.tel.batt1volt = getValue(shared.GetConfig("RX batt. volt.")) / dividefactor
	shared.tel.batt1volt = 10 / dividefactor
	HBcheck(shared.tel.batt1volt, shared)

	shared.tel.batt1current = getValue(shared.GetConfig("Current"))
	HBcheck(shared.tel.batt1current, shared)

	shared.tel.flightMode = getValue(shared.GetConfig("Flight Mode"))
	if shared.tel.flightMode == 0 then
		shared.tel.flightMode = ""
	end

	shared.tel.txpower = getValue(shared.GetConfig("TxPower"))
	shared.tel.hSpeed = getValue(shared.GetConfig("GPS speed"))
	HBcheck(shared.tel.hSpeed, shared)
	shared.tel.alt = getValue(shared.GetConfig("Altitude"))
	shared.tel.battpercent = getValue(shared.GetConfig("Batt.(%)"))
	shared.tel.hdg = getValue(shared.GetConfig("Heading"))


	if shared.heartBeatChecker ~= lastHB then
		shared.Heartbeat = shared.Heartbeat + 1
		if shared.Heartbeat > 2 then
			shared.Heartbeat = 0
		end
	end


end

return {
	getTele = getTele
}
