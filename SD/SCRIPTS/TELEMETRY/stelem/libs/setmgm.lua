local function SaveSettings(configFile, localCopy)
	file = io.open(configFile, "w")
	for i = 1, #localCopy
	do
		local confline = localCopy[i]
		for j = 1, #confline
		do
			io.write(file, confline[j], ",")
		end
		io.write(file, "\n")
	end
	io.close(file)
end

local function LoadSettings(configFile, localCopy, shared)
	local cfg = io.open(configFile, "r")
	if cfg ~= nil then
		local info = fstat(configFile)
		local size = info.size
		local str = io.read(cfg, size)
		io.close(cfg)
		local archline = 1
		for strout in string.gmatch(str, "([^" .. "%\n" .. "]+)") do
			local ctr = 1
			local cfgline = {}
			for tentry in string.gmatch(strout, '([^,]+)') do
				cfgline[ctr] = tentry
				ctr = ctr + 1
			end
			localCopy[archline] = cfgline
			archline = archline + 1
		end
	else
		SaveSettings(shared.configFile, shared.MenuItems)
	end
end

local function loadScreens(screensize, shared)
	local screensDir = "/SCRIPTS/TELEMETRY/stelem/" .. screensize
	shared.screensFile = shared.rootDir .. screensize .. "/scsList.cfg"
	local screenparams = {}
	LoadSettings(shared.rootDir .. screensize .. "/params.cfg", screenparams)
	if shared.isColor == false then
		shared.screenW = tonumber(screenparams[1][2])
		shared.screenH = tonumber(screenparams[2][2])
	end
	shared.pixelSize = tonumber(screenparams[3][2])
	shared.hdgOffset = tonumber(screenparams[4][2])

	shared.screenItems = {}
	LoadSettings(shared.screensFile, shared.screenItems)
	shared.Screens = {}
	local act = 1
	for t = 1, #shared.screenItems
	do
		if shared.screenItems[t][2] == "1" then
			shared.Screens[act] = screensDir .. "/" .. shared.screenItems[t][1] .. ".lua"
			act = act + 1
		end
	end
end

local function listFiles(dirin, extension)
	local y = 1
	local files = {}
	extension = string.upper(extension)
	for fname in dir(dirin) do
		local fnameU = string.upper(fname)
		if string.find(fnameU, extension) and string.sub(fnameU, -4) == extension then
			files[#files + 1] = fname
			y = y + 1
		end
	end
	return files
end

return {
	SaveSettings = SaveSettings,
	LoadSettings = LoadSettings,
	loadScreens = loadScreens,
	listFiles = listFiles
}
