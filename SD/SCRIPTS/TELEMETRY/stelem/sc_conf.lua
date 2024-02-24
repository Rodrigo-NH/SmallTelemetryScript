local shared = ...

local optchoice = 1
local isediting = 0

function shared.run(event)
  lcd.clear()

  local function getSettings()
    lcd.clear()
    local linen = 0
    for i = 1, #shared.MenuItems
    do
      local confline = shared.MenuItems[i]
      for j = 1, #confline
      do
        local seloption = tonumber(shared.MenuItems[i][2])
        local actvalue = shared.MenuItems[i][seloption + 2]
        lcd.drawText(0, linen, tostring(shared.MenuItems[i][1]) .. ": ", SMLSIZE)

        if i == optchoice then
          if isediting == 0 then
            lcd.drawText(95, linen, tostring(actvalue), SMLSIZE + INVERS)
          else
            lcd.drawText(95, linen, tostring(actvalue), SMLSIZE + INVERS + BLINK)
          end
        else
          lcd.drawText(95, linen, tostring(actvalue), SMLSIZE)
        end
      end
      linen = linen + 7
    end

    if optchoice == #shared.MenuItems + 1 then
      lcd.drawText(0, 57, "Save and Exit", SMLSIZE + INVERS)
    else
      lcd.drawText(0, 57, "Save and Exit", SMLSIZE)
    end
  end

  getSettings()

  if event == EVT_VIRTUAL_NEXT then
    if isediting == 0 then
      optchoice = optchoice + 1
      if optchoice > #shared.MenuItems + 1 then
        optchoice = optchoice - 1
      end
    else
      local seloption = tonumber(shared.MenuItems[optchoice][2]) + 1
      local optiondata = shared.MenuItems[optchoice][seloption + 2]
      if optiondata ~= nil then
        shared.MenuItems[optchoice][2] = seloption
      end
    end

  elseif event == EVT_VIRTUAL_PREV then
    if isediting == 0 then
      optchoice = optchoice - 1
      if optchoice < 1 then
        optchoice = optchoice + 1
      end
    else
      local seloption = tonumber(shared.MenuItems[optchoice][2]) - 1
      if seloption > 0 then
        shared.MenuItems[optchoice][2] = seloption
      end
    end

  elseif event == EVT_VIRTUAL_ENTER then
    if optchoice == #shared.MenuItems + 1 then
      -- shared.CycleScreen(1)
      shared.LoadScreen(shared.Screens[1])
      shared.SaveSettings()
      shared.MessagesLog()
    else
      if isediting == 0 then
        isediting = 1
      else
        isediting = 0
      end
    end
  end
end
