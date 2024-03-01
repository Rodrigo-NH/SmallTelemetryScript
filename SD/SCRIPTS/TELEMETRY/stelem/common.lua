

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

function drawSelectBox (startx, starty, maxelements, uoption, obox)
  -- maxelements = max menu options before sreen scroll (to adjust to other screen sizes)
  local interval = nil
  local itr = maxelements

      if #obox <= maxelements then
          itr = #obox - 1
      end

      interval = { 1, itr + 1 }

      if uoption >= itr then
          interval = { uoption - itr + 1, uoption + 1 }
      end

      if uoption == #obox then
          interval = { uoption - itr, uoption }
          if #obox - 1 > itr or #obox == maxelements + 1 then  
              interval = { uoption - itr + 1, uoption }
          end
      end   

  local acc = starty
  local odata = { }
  local maxx = 0   
  for p = interval[1], interval[2]
  do
      if uoption ~= p then
          odata[p] = { startx + 3, acc, obox[p], SMLSIZE }
          lcd.drawText(startx + 3, acc, obox[p], SMLSIZE)
      else
          lcd.drawText(startx + 3, acc, obox[p], SMLSIZE + INVERS)
          odata[p] = { startx + 3, acc, obox[p], SMLSIZE + INVERS }
      end
      acc = acc + 8
      lp = lcd.getLastRightPos()
      if lp > maxx then
          maxx = lp
      end
  end
-- maxx = maxx - startx
local larg = 129 - startx
lcd.drawFilledRectangle(startx-1, starty - 3, larg, acc - starty + 4, FORCE)
lcd.drawFilledRectangle(startx-1, starty - 3, larg, acc - starty + 4)
for t=interval[1], interval[2]
do
      lcd.drawText(odata[t][1],odata[t][2],odata[t][3],odata[t][4])
end
lcd.drawRectangle(startx, starty - 2, larg, acc - starty + 2, FORCE)
end

-- expandOption Auto menu generator
function expandOption(optmap, menuoptions, uevent, currindex)
    -- expandOption rules:
    -- It includes event grabbers for EVT_VIRTUAL_NEXT, EVT_VIRTUAL_PREV, EVT_VIRTUAL_ENTER & event == 96 (RTN button)
    -- Outputs in the format { commandtype, commandData, optmap, currindex}
    -- Update your local optionsmap (optmap) and userindex (currindex) from the function output
    -- Flip 'optmap = { 1 }' to initiate menu
    -- ENTER key selects menu options and final choices
    -- RET (event 96) key step back menu options
    -- If command type return is not null (user final choice), it returns optmap = { } (initial state menu not activate)
    

    -- Menuoptions example
    -- Return type 1-> Command, 3-> Options list
  --   local menuoptions = {
  --     { "exit", 1 },
  --     { "Menu 3", 2,
  --         {
  --             { "Sub 1", 2,
  --                 {
  --                     { "Sub1_1", 3, { "opt1", "opt2" }, },
  --                     { "Sub1_2", 1 }
  --                 }
  --             },
  --             { "Sub2", 1 }, { "Sub3", 1}, { "Sub4", 1}, { "Sub5", 1}, { "Sub6", 1}, { "Sub7", 1},{ "Sub8", 1},{ "Sub9", 1},{ "Sub10", 1}, { "Sub11", 1}, { "Sub12", 1}, { "Sub13", 1}
  --             --   
  --             --  
  --         }
  --     },
  --     { "Go to", 2,
  --         {
  --             { "Drone", 1 },
  --             { "Drone2", 2,
  --             {
  --                 { "D1", 1 },
  --                 { "D2", 3, {"D2_1","D2_2"} },
  --             }
  --             }
  --         }
  --     },
  --     { "Salva tudo", 3, {"opta","optb","optc"} }
  -- }

  if uevent == EVT_VIRTUAL_NEXT then
      currindex = currindex + 1
  elseif uevent == EVT_VIRTUAL_PREV then
      currindex = currindex - 1
  elseif uevent == EVT_VIRTUAL_ENTER then
      optmap[#optmap] = currindex
      optmap[#optmap + 1] = 1
      currindex = 1
  elseif uevent == 96 then
    currindex = optmap[#optmap-1]
    if currindex == nil then
      currindex = 1
    end
    local tp = {}
    for i = 1, #optmap - 1
    do
        tp[i] = optmap[i]
    end
    optmap = tp

  uevent = 0
  end
  local scs = {}
  local act = nil
  for e = 1, #optmap
  do
      if e == 1 then
          local sct = {}
          for o = 1, #menuoptions
          do
              sct[#sct + 1] = menuoptions[o][1]
          end
          scs[#scs + 1] = sct
      elseif e == 2 then
          act = menuoptions[optmap[1]]
          if act[2] == 2 then
              local sct = {}
              act = act[3]
              for o = 1, #act
              do
                  sct[#sct + 1] = act[o][1]
              end
              scs[#scs + 1] = sct
          end
      elseif e == 3 then
          act = menuoptions[optmap[1]][3][optmap[2]]
          if act[2] == 2 then
              local sct = {}
              act = act[3]
              for o = 1, #act
              do
                  sct[#sct + 1] = act[o][1]
              end
              scs[#scs + 1] = sct
          end
      end
  end

  local act2 = nil
  if #optmap == 2 then
      act2 = menuoptions[optmap[1]]
  elseif #optmap == 3 then
      act2 = menuoptions[optmap[1]][3][optmap[2]]
  elseif #optmap == 4 then
      act2 = menuoptions[optmap[1]][3][optmap[2]][3][optmap[3]]
  end

  local commandtype = nil
  local commandData = nil
  if act2 ~= nil then
      if act2[2] == 1 then
        commandtype = 1 -- Command
        commandData = act2[1]
      elseif act2[2] == 3 then
        commandtype = 3 -- Options list
        commandData = act2[3]
      end
  end

      if #scs > 0 then
          local rec1 = 2
          local rec2 = 4
          for e = 1, #scs
          do                
              if e < #scs then
                  drawSelectBox(rec1, rec2, 6, optmap[e], scs[e])
              else
                  if currindex < 1 then
                      currindex = 1
                  elseif currindex > #scs[e] then
                      currindex = #scs[e]
                  end
                  drawSelectBox(rec1, rec2, 6, currindex, scs[e])
              end
              rec1 = rec1 + 5
              rec2 = rec2 + 5
          end
      end

      if commandtype ~= nil then
        optmap = {}
      end

      return { commandtype, commandData, optmap, currindex }
end

  return {
    optionsScreen=optionsScreen,
    modalBox=modalBox,
    drawSelectBox=drawSelectBox,
    expandOption=expandOption,

  }