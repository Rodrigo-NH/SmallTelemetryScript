local function CycleScreen(delta, shared)
	shared.CurrentScreen = shared.CurrentScreen + delta
	if shared.CurrentScreen > #shared.Screens then
		shared.CurrentScreen = 1
	elseif shared.CurrentScreen < 1 then
		shared.CurrentScreen = #shared.Screens
	end
	shared.LoadScreen(shared.libsDir .. "wtroom.lua")
end

local function defaultActions(event, shared)
	if event == 70 or event == 1029 or event == 128 then
		shared.goMap = true
		shared.mapSource = true
		shared.LoadScreen(shared.libsDir .. "wtroom.lua")
	elseif event == EVT_VIRTUAL_NEXT then
		CycleScreen(1, shared)
	elseif event == EVT_VIRTUAL_PREV then
		CycleScreen(-1, shared)
	elseif event == EVT_VIRTUAL_ENTER or event == 32 then
		shared.goConf = true
		shared.LoadScreen(shared.libsDir .. "wtroom.lua")
	end
end

return {
	defaultActions = defaultActions,
}
