local shared = ...

local cm = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/libs/opscreen.lua")
local op = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/libs/opexpand.lua")

local optchoiceu = 1
local iseditingu = 0
-- local sbs = shared.getSettingsSubSet({ "Sounds", "Att. indicator scale" })
local usrindex = 1
local editpart = 0

local menustruct = {
  { "General settings",      1 },
  { "Nav instrum. settings", 1 },
  { "Telemetry settings",    1 },
  { "Screens",    1 },
  { "Map options", 1}
}

local usroptmap = { 1 }
local debouncer = 0

local gopt = shared.getSettingsSubSet(shared.MenuItems, {"Screen Size","Msg log","Sounds","Splash Screen"})
local navs = shared.getSettingsSubSet(shared.MenuItems, {"Variometer clip val","Att. indicator scale",})
local tels = shared.getSettingsSubSet(shared.MenuItems, {"Cell voltage","Number of cells",})
local maps = shared.getSettingsSubSet(shared.MenuItems, {"Show WP numbers","Show scale"})



shared.loadScreens()

function shared.run(event)
  lcd.clear()
  local scs = shared.screenItems

  if editpart == 0 then
    local bindex = usrindex
    local exps = op.expandOption(usroptmap, menustruct, event, usrindex)
    usroptmap = exps[3]
    usrindex = exps[4]
    if exps[1] ~= nil then
      if exps[2] == "General settings" then
        editpart = 1
      elseif exps[2] == "Nav instrum. settings" then
        editpart = 2
      elseif exps[2] == "Telemetry settings" then
        editpart = 3
      elseif exps[2] == "Screens" then
        editpart = 4
      elseif exps[2] == "Map options" then
        editpart = 5
      end
      event = 0
      usroptmap = { 1 }
      usrindex = bindex
    end
  end

  if editpart ~= 0 then
    debouncer = debouncer + 1
    if debouncer > 2 then
      local ctr = nil
      if editpart == 1 then
        ctr = cm.optionsScreen(gopt, optchoiceu, iseditingu, event)
      elseif editpart == 2 then
        ctr = cm.optionsScreen(navs, optchoiceu, iseditingu, event)
      elseif editpart == 3 then
        ctr = cm.optionsScreen(tels, optchoiceu, iseditingu, event)
      elseif editpart == 4 then        
        ctr = cm.optionsScreen(scs, optchoiceu, iseditingu, event)
      elseif editpart == 5 then        
        ctr = cm.optionsScreen(maps, optchoiceu, iseditingu, event)
      end

      if ctr ~= nil then
        iseditingu = ctr[2]
        optchoiceu = ctr[1]
      else
        shared.SaveSettings(shared.configFile, shared.MenuItems)
        shared.SaveSettings(shared.screensFile, shared.screenItems)
        shared.loadScreens()  
        editpart = 0
      end
    end
  end
 
  if #usroptmap == 0 then
    shared.loadScreens()
    if #shared.Screens < shared.CurrentScreen then
      shared.CurrentScreen = 1
    end
    if #shared.Screens ~= 0 then
      shared.LoadScreen(shared.Screens[shared.CurrentScreen])
    else
      usroptmap = { 1 }
    end
  end

end
