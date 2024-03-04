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

local function modalBox(txt, control, sh, event)
  -- Use example
  -- local shared = ...
  -- local cm = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/common.lua")
  -- local control = { 1 }
  -- local mdebounce = true
  -- function shared.run(event)
  --   lcd.clear()
  --   if #control >= 1 then
  --     mdebounce = false
  --     control = cm.modalBox("This is\na test", control, shared, event)
  --   else
  --     mdebounce = true
  --   end
  --   if event == EVT_VIRTUAL_ENTER and mdebounce then
  --     shared.LoadScreen(shared.Configmenu)
  --   end
  -- end
  local shared = sh
  if #control >= 1 then
      local grablastpos = {}
      local txtpart = {}
      local ctr = 5
      local cr = 1

      if #control == 1 then
          for strout in string.gmatch(txt, "([^" .. "%\n" .. "]+)") do
              txtpart[cr] = strout
              lcd.drawText(5, ctr, strout, SMLSIZE)
              grablastpos[cr] = lcd.getLastRightPos()
              ctr = ctr + 7
              cr = cr + 1
          end
          control = { txtpart, grablastpos }
      end

      if #control >= 2 then
          txtpart = control[1]
          grablastpos = control[2]
          local offY = (shared.screenW - ctr) / #txtpart / 2 - 5
          ctr = offY
          for t = 1, #txtpart
          do
              local offX = (shared.screenW - grablastpos[t]) / 2
              lcd.drawText(offX, ctr, txtpart[t], SMLSIZE)
              ctr = ctr + 7
          end

          lcd.drawRectangle(1, 1, shared.screenW - 2, shared.screenH - 2, SOLID)
          lcd.drawRectangle(3, 3, shared.screenW - 5, shared.screenH - 5, SOLID)
      end
  end
  if event == EVT_VIRTUAL_ENTER then
      control = { }
      -- event = 0 
  end
  return control
end


return {
    optionsScreen=optionsScreen,
    modalBox=modalBox,
  }