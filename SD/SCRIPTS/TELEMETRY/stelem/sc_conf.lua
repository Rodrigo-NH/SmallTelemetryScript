local shared = ...

local opt = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/common.lua")
local gfx = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/graphics.lua")

local optchoiceu = 1
local iseditingu = 0
-- local sbs = shared.getSettingsSubSet({ "Sounds", "Att. indicator scale" })
local usrindex = 1
local editpart = 0

local menustruct = {
  { "General settings",      1 },
  { "Nav instrum. settings", 1 },
  { "Telemetry settings",    1 },
  { "Screens",    1 }
}

local usroptmap = { 1 }
local debouncer = 0

local gopt = shared.getSettingsSubSet(shared.MenuItems, {"Screen Size","Msg log","Sounds","Splash Screen"})
local navs = shared.getSettingsSubSet(shared.MenuItems, {"Variometer clip val","Att. indicator scale",})
local tels = shared.getSettingsSubSet(shared.MenuItems, {"Cell voltage","Number of cells",})
local scs = shared.screenItems

function shared.run(event)
  lcd.clear()

  if editpart == 0 then
    local bindex = usrindex
    local exps = gfx.expandOption(usroptmap, menustruct, event, usrindex)
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
        ctr = opt.optionsScreen(gopt, optchoiceu, iseditingu, event)
      elseif editpart == 2 then
        ctr = opt.optionsScreen(navs, optchoiceu, iseditingu, event)
      elseif editpart == 3 then
        ctr = opt.optionsScreen(tels, optchoiceu, iseditingu, event)
      elseif editpart == 4 then
        ctr = opt.optionsScreen(scs, optchoiceu, iseditingu, event)
      end

      if ctr ~= nil then
        iseditingu = ctr[2]
        optchoiceu = ctr[1]
      else
        shared.SaveSettings(shared.configFile, shared.MenuItems)
        shared.SaveSettings(shared.screensFile, shared.screenItems)
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
