local function optionsScreen(options, optchoice, isediting, event, isColor)
  collectgarbage("collect")
  local seloption = nil
  local optiondata = nil
  local maxelements = 6
  local initelement = 1
  local actvalue = nil
  local linen = 0
  local linenstep = 11

  if isColor then
    maxelements = 13
    linenstep = 20
  end
  local endelement = nil
  local lp = nil

  if event == EVT_VIRTUAL_NEXT then
    if isediting == 0 then
      optchoice = optchoice + 1
      if optchoice > #options then
        optchoice = #options
      end
    else
      seloption = tonumber(options[optchoice][2]) + 1
      optiondata = options[optchoice][seloption + 2]
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
      seloption = tonumber(options[optchoice][2]) - 1
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
  elseif event == 96 or event == 1540 then
    return nil
  end

  if optchoice > maxelements then
    initelement = optchoice - maxelements + 1
  end

  endelement = initelement + maxelements
  if endelement > #options then
    endelement = #options
  end

  local confline = nil
  for i = initelement, endelement
  do
    confline = options[i]
    for j = 1, #confline
    do
      seloption = tonumber(options[i][2])
      actvalue = options[i][seloption + 2]

      lcd.drawText(0, linen, tostring(options[i][1]) .. ": ")

      lp = 300
      if isColor == false then
        lp = lcd.getLastRightPos()
      end

      if i == optchoice then
        if isediting == 0 then
          lcd.drawText(lp, linen, tostring(actvalue), INVERS)
        else
          lcd.drawText(lp, linen, tostring(actvalue), INVERS + BLINK)
        end
      else
        lcd.drawText(lp, linen, tostring(actvalue))
      end
      lcd.drawLine(0, linen + linenstep - 2, 128, linen + linenstep - 2, DOTTED, FORCE)
    end
    linen = linen + linenstep
  end
  return { optchoice, isediting }
end

-- local function modalBox(txt, control, shared, event)
--   -- Use example
--   -- local shared = ...
--   -- local cm = shared.LoadLua("/SCRIPTS/TELEMETRY/stelem/libs/opscreen.lua")
--   -- local control = { 1 }
--   -- local mdebounce = true
--   -- function shared.run(event)
--   --   lcd.clear()
--   --   if #control >= 1 then
--   --     mdebounce = false
--   --     control = cm.modalBox("This is\na test", control, shared, event)
--   --   else
--   --     mdebounce = true
--   --   end
--   --   if event == EVT_VIRTUAL_ENTER and mdebounce then
--   --     shared.LoadScreen(shared.Configmenu)
--   --   end
--   -- end
--   if #control >= 1 then
--       local grablastpos = {}
--       local txtpart = {}
--       local ctr = 5
--       local cr = 1

--       if #control == 1 then
--           for strout in string.gmatch(txt, "([^" .. "%\n" .. "]+)") do
--               txtpart[cr] = strout
--               lcd.drawText(5, ctr, strout, SMLSIZE)
--               grablastpos[cr] = lcd.getLastRightPos()
--               ctr = ctr + 7
--               cr = cr + 1
--           end
--           control = { txtpart, grablastpos }
--       end

--       if #control >= 2 then
--           txtpart = control[1]
--           grablastpos = control[2]
--           local offY = (shared.screenW - ctr) / #txtpart / 2 - 5
--           ctr = offY
--           for t = 1, #txtpart
--           do
--               local offX = (shared.screenW - grablastpos[t]) / 2
--               lcd.drawText(offX, ctr, txtpart[t], SMLSIZE)
--               ctr = ctr + 7
--           end

--           lcd.drawRectangle(1, 1, shared.screenW - 2, shared.screenH - 2, SOLID)
--           lcd.drawRectangle(3, 3, shared.screenW - 5, shared.screenH - 5, SOLID)
--       end
--   end
--   if event == EVT_VIRTUAL_ENTER then
--       control = { }
--       -- event = 0
--   end
--   return control
-- end

return {
  optionsScreen = optionsScreen,
  -- modalBox=modalBox,
}
