

local function optionsScreen(options, optchoice, isediting, event)
    
    if event == EVT_VIRTUAL_NEXT then
      if isediting == 0 then
        optchoice = optchoice + 1
        if optchoice > #options then
          optchoice = #options
        end
      else
        local seloption = tonumber(options[optchoice][2]) + 1
        local optiondata = options[optchoice][seloption + 2]
        if optiondata ~= nil then
          options[optchoice][2] = seloption
        end
      end
    elseif event == EVT_VIRTUAL_PREV then
      if isediting == 0 then
        optchoice = optchoice - 1
        if optchoice < 1 then
          optchoice = optchoice + 1
        end
      else
        local seloption = tonumber(options[optchoice][2]) - 1
        if seloption > 0 then
          options[optchoice][2] = seloption
        end
      end
    elseif event == EVT_VIRTUAL_ENTER then
      if isediting == 0 then
        isediting = 1
      else
        isediting = 0
      end
    elseif event == 96 then
      return nil
    end


    local maxelements = 6
    local initelement = 1


    if optchoice > maxelements then
        initelement = optchoice - maxelements + 1
    end

    local endelement = initelement + maxelements
    if endelement > #options then
        endelement = #options
    end

    local linen = 0
    for i = initelement, endelement
    do
      local confline = options[i]
      for j = 1, #confline
      do
        local seloption = tonumber(options[i][2])
        local actvalue = options[i][seloption + 2]
        lcd.drawText(0, linen, tostring(options[i][1]) .. ": ")
        local lp = lcd.getLastRightPos()

        if i == optchoice then
          if isediting == 0 then
            lcd.drawText(lp, linen, tostring(actvalue),  INVERS)
          else
            lcd.drawText(lp, linen, tostring(actvalue),  INVERS + BLINK)
          end
        else
          lcd.drawText(lp, linen, tostring(actvalue))
        end
        lcd.drawLine(0, linen+9, 128, linen+9, DOTTED, FORCE)
      end
      linen = linen + 11
    end
    return { optchoice, isediting }
  end







  return {
    optionsScreen=optionsScreen,

  }