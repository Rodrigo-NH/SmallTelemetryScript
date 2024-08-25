local shared = ...

local cm = shared.LoadLua(shared.libsDir .. "opscreen.lua")
local op = shared.LoadLua(shared.libsDir .. "opexpand.lua")
local setts = shared.LoadLua(shared.libsDir .. "setmgm.lua")
local subs = shared.LoadLua(shared.libsDir .. "sc_confs.lua")

local optchoiceu = 1
local iseditingu = 0
local usrindex = 1
local editpart = 0

local listsensors = false
local usroptmap = { 1 }
local debouncer = 0


local screensize = "Screen Size"
setts.loadScreens(shared.GetConfig(screensize), shared)

local function updateSensors(telemSensors)
  local allSensors = {}
  for t = 1, 50
  do
    local sensor = model.getSensor(t - 1)
    if sensor ~= nil then
      if sensor.name ~= "" then
        allSensors[#allSensors + 1] = sensor.name

        shared.Messages[#shared.Messages + 1] = sensor.name
      end
    end
  end

  for s = 1, #telemSensors
  do
    for ns = 1, #allSensors
    do
      if telemSensors[s][3] ~= allSensors[ns] then
        telemSensors[s][#telemSensors[s] + 1] = allSensors[ns]
      end
    end
  end
  listsensors = true
end

local menupart = nil
local ctr = nil
function shared.run(event)
  lcd.clear()


  if editpart == 0 then
    local bindex = usrindex
    local exps = op.expandOption(usroptmap, subs.menustruct, event, usrindex, nil, shared.isColor)
    usroptmap = exps[3]
    usrindex = exps[4]
    if exps[1] ~= nil then
      if exps[2] == subs.menustruct[1][1] then
        menupart = subs.getSettingsSubSet(shared.MenuItems, subs.menurefs[2])
        editpart = 1
      elseif exps[2] == subs.menustruct[2][1] then
        menupart = subs.getSettingsSubSet(shared.MenuItems, subs.menurefs[3])
        editpart = 2
      elseif exps[2] == subs.menustruct[3][1] then
        menupart = subs.getSettingsSubSet(shared.MenuItems, subs.menurefs[4])
        editpart = 3
      elseif exps[2] == subs.menustruct[4][1] then
        editpart = 4
      elseif exps[2] == subs.menustruct[5][1] then
        menupart = subs.getSettingsSubSet(shared.MenuItems, subs.menurefs[5])
        editpart = 5
      elseif exps[2] == subs.menustruct[6][1] then
        menupart = subs.getSettingsSubSet(shared.MenuItems, subs.menurefs[1])
        updateSensors(menupart)
        editpart = 6
      end
      event = 0
      usroptmap = { 1 }
      usrindex = bindex
    end
  end

  if editpart ~= 0 then
    debouncer = debouncer + 1
    if debouncer > 2 then
      ctr = nil
      if editpart == 1 then
        ctr = cm.optionsScreen(menupart, optchoiceu, iseditingu, event, shared.isColor)
      elseif editpart == 2 then
        ctr = cm.optionsScreen(menupart, optchoiceu, iseditingu, event, shared.isColor)
      elseif editpart == 3 then
        ctr = cm.optionsScreen(menupart, optchoiceu, iseditingu, event, shared.isColor)
      elseif editpart == 4 then
        ctr = cm.optionsScreen(shared.screenItems, optchoiceu, iseditingu, event, shared.isColor)
      elseif editpart == 5 then
        ctr = cm.optionsScreen(menupart, optchoiceu, iseditingu, event, shared.isColor)
      elseif editpart == 6 then
        ctr = cm.optionsScreen(menupart, optchoiceu, iseditingu, event, shared.isColor)
      end
      if ctr ~= nil then
        iseditingu = ctr[2]
        optchoiceu = ctr[1]
      else
        optchoiceu = 1
        iseditingu = 0
        if listsensors then
          for ni = 1, #subs.menurefs[1]
          do
            local tl = shared.GetConfig(subs.menurefs[1][ni])
            for i = 1, #shared.MenuItems
            do
              local reg = shared.MenuItems[i][1]
              if reg == subs.menurefs[1][ni] then
                shared.MenuItems[i] = { reg, 1, tl }
              end
            end
          end
        end
        setts.SaveSettings(shared.configFile, shared.MenuItems)
        setts.SaveSettings(shared.screensFile, shared.screenItems)
        setts.loadScreens(shared.GetConfig(screensize), shared)
        editpart = 0
      end
    end
  end

  if #usroptmap == 0 then
    setts.loadScreens(shared.GetConfig(screensize), shared)
    if #shared.Screens < shared.CurrentScreen then
      shared.CurrentScreen = 1
    end
    if #shared.Screens ~= 0 then
      -- if shared.GetConfig("Simulate") == "ON" then
      --   -- SIMULATE
      --   shared.tel.lat = -49.1855117
      --   shared.tel.lon = 70.3391770
      --   -- SIMULATE
      -- end
      shared.LoadScreen(shared.libsDir .. "wtroom.lua")
    else
      usroptmap = { 1 }
    end
  end
end
