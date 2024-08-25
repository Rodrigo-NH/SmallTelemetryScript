function drawSelectBox(startx, starty, uoption, obox, isColor)
    -- maxelements = max menu options before sreen scroll (to adjust to other screen sizes)
    local interval = nil
    local maxelements = 6 -- Max elements before scroll

    if isColor then
        maxelements = 13
    end
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
    local odata = {}
    local desloc = 8
    if isColor then
        desloc = 19
    end
    for p = interval[1], interval[2]
    do
        if uoption ~= p then
            odata[p] = { startx + 3, acc, obox[p], SMLSIZE }
            lcd.drawText(startx + 3, acc, obox[p], SMLSIZE)
        else
            lcd.drawText(startx + 3, acc, obox[p], SMLSIZE + INVERS)
            odata[p] = { startx + 3, acc, obox[p], SMLSIZE + INVERS }
        end
        acc = acc + desloc
    end

    local larg = 129 - startx
    local rtag = FORCE
    if isColor then
        larg = 200
        rtag = WHITE
    end

    lcd.drawFilledRectangle(startx - 1, starty - 3, larg, acc - starty + 4, rtag)

    if isColor ~= true then
        lcd.drawFilledRectangle(startx - 1, starty - 3, larg, acc - starty + 4)
    end

    for t = interval[1], interval[2]
    do
        lcd.drawText(odata[t][1], odata[t][2], odata[t][3], odata[t][4])
    end
    lcd.drawRectangle(startx, starty - 2, larg, acc - starty + 2, LIGHTBROWN)
end

-- expandOption Auto menu generator
function expandOption(optmap, menuoptions, uevent, currindex, extraopt, isColor)
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
    elseif uevent == 96 or uevent == 1540 then
        currindex = optmap[#optmap - 1]
        if currindex == nil then
            currindex = 1
        end
        local tp = {}
        for i = 1, #optmap - 1
        do
            tp[i] = optmap[i]
        end
        optmap = tp
    end
    local scs = {}
    local act = nil

    if extraopt ~= nil and #optmap == 4 then
        menuoptions[optmap[1]][3][optmap[2]] = extraopt[2]
    end

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

                if extraopt ~= nil then
                    act = extraopt[2]
                else
                    act = act[3]
                end

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
        if extraopt ~= nil and extraopt[1] == 3 then
            act2 = extraopt[2][optmap[3]]
        else
            act2 = menuoptions[optmap[1]][3][optmap[2]][3][optmap[3]]
        end

    end

    local commandtype = nil
    local commandData = nil
    if act2 ~= nil then
        if act2[2] == 1 then
            commandtype = act2[2] -- Command
            commandData = act2[1]
        elseif act2[2] == 3 then
            commandtype = act2[2] -- Options list
            commandData = act2[3]
        elseif act2[2] ~= 2 then
            commandtype = act2[2]
            commandData = act2[1]
        end
    end


    if #scs > 0 then
        local rec1 = 2
        local rec2 = 4
        for e = 1, #scs
        do
            if e < #scs then
                if commandtype == nil
                then
                    drawSelectBox(rec1, rec2, optmap[e], scs[e], isColor)
                end
            else
                if currindex < 1 then
                    currindex = 1
                elseif currindex > #scs[e] then
                    currindex = #scs[e]
                end
                if commandtype == nil
                then
                    drawSelectBox(rec1, rec2, currindex, scs[e], isColor)
                end
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
    drawSelectBox = drawSelectBox,
    expandOption = expandOption,

}
