-- For development/tests
-- https://doc.open-tx.org/opentx-2-3-lua-reference-guide/part_iii_-_opentx_lua_api_reference/constants/key_events
local shared = ...

-- Testing function to test key event mapping. Discovered event numbers commented bellow
-- Not mapped event numbers:
    -- TX12:
        -- 'TELE' button:
            -- press = 102
            -- long press = 134
        -- 'PAGE>':
            -- press = 99
        -- 'PAGE<':
            -- press = 98
        -- 'RTN':
            -- press = 96
function shared.run(event)  
  local function evt2str(event)
    local txt = ""
    local numb = event
    if event == EVT_VIRTUAL_PREV then txt = "EVT_VIRTUAL_PREV" -- 4099
    elseif event == EVT_VIRTUAL_NEXT then txt = "EVT_VIRTUAL_NEXT" -- 4100
    elseif event == EVT_VIRTUAL_DEC then txt = "EVT_VIRTUAL_DEC"
    elseif event == EVT_VIRTUAL_INC then txt = "EVT_VIRTUAL_INC"
    elseif event == EVT_VIRTUAL_PREV_PAGE then txt = "EVT_VIRTUAL_PREV_PAGE"
    elseif event == EVT_VIRTUAL_NEXT_PAGE then txt = "EVT_VIRTUAL_NEXT_PAGE"
    elseif event == EVT_VIRTUAL_MENU then txt = "EVT_VIRTUAL_MENU" -- 37
    elseif event == EVT_VIRTUAL_ENTER then txt = "EVT_VIRTUAL_ENTER" -- 33
    elseif event == EVT_VIRTUAL_MENU_LONG then txt = "EVT_VIRTUAL_MENU_LONG"
    elseif event == EVT_VIRTUAL_ENTER_LONG then txt = "EVT_VIRTUAL_ENTER_LONG" -- 129
    elseif event == EVT_VIRTUAL_ENTER then txt = "EVT_VIRTUAL_EXIT" -- 32
    elseif event == EVT_VIRTUAL_EXIT then txt = "EVT_VIRTUAL_EXIT" -- 32
    elseif event == EVT_TOUCH_FIRST then txt = "EVT_TOUCH_FIRST"
    elseif event == EVT_TOUCH_BREAK then txt = "EVT_TOUCH_BREAK"
    elseif event == EVT_TOUCH_TAP then txt = "EVT_TOUCH_TAP" 
    elseif event == EVT_TOUCH_SLIDE then txt = "EVT_TOUCH_SLIDE"
    elseif event == EVT_MENU_BREAK then txt = "EVT_MENU_BREAK"
    elseif event == EVT_PAGE_BREAK then txt = "EVT_PAGE_BREAK"
    elseif event == EVT_PAGE_LONG then txt = "EVT_PAGE_LONG"
    elseif event == EVT_ENTER_BREAK then txt = "EVT_ENTER_BREAK"
    elseif event == EVT_ENTER_LONG then txt = "EVT_ENTER_LONG"
    elseif event == EVT_EXIT_BREAK then txt = "EVT_EXIT_BREAK"
    elseif event == EVT_PLUS_BREAK then txt = "EVT_PLUS_BREAK"
    elseif event == EVT_MINUS_BREAK then txt = "EVT_MINUS_BREAK"
    elseif event == EVT_PLUS_FIRST then txt = "EVT_PLUS_FIRST"
    elseif event == EVT_MINUS_FIRST then txt = "EVT_MINUS_FIRST"
    elseif event == EVT_PLUS_REPT then txt = "EVT_PLUS_REPT"
    elseif event == EVT_MINUS_REPT then txt = "EVT_MINUS_REPT"
    elseif event == EVT_ROT_BREAK then txt = "EVT_ROT_BREAK"
    elseif event == EVT_ROT_LONG then txt = "EVT_ROT_LONG"
    elseif event == EVT_ROT_LEFT then txt = "EVT_ROT_LEFT"
    elseif event == EVT_ROT_RIGHT then txt = "EVT_ROT_RIGHT"
    elseif event == EVT_VIRTUAL_NEXT_REPT then txt = "EVT_VIRTUAL_NEXT_REPT"
    elseif event == EVT_VIRTUAL_PREV_REPT then txt = "EVT_VIRTUAL_PREV_REPT"
    elseif event == EVT_VIRTUAL_DEC_REPT then txt = "EVT_VIRTUAL_DEC_REPT"
    else 
        txt = "NONE"   
    end
        return { txt, numb }
  end

  if event ~= 0 then
    lcd.clear()
    local evt = evt2str(event)
    lcd.drawText(0, 0, tostring(evt[1]), SMALL)
    lcd.drawText(0, 10, tostring(evt[2]), SMALL)
  end

end

