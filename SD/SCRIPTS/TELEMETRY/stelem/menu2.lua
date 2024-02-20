local shared = ...
ardumessagesCursor = 1

function shared.run(event)
  lcd.clear()
  local line = 0
	for i=1,#shared.stelemMessages
	do
		lcd.drawText(0, line, tostring(shared.stelemMessages[i]), SMLSIZE)
		line = line + 8
	end
  
  -- https://doc.open-tx.org/opentx-2-3-lua-reference-guide/part_iii_-_opentx_lua_api_reference/constants/key_events
  if event == EVT_VIRTUAL_NEXT then
    shared.stelemCycleScreen(1)
  elseif event == EVT_VIRTUAL_PREV then
    shared.stelemCycleScreen(-1)
  elseif event == EVT_VIRTUAL_ENTER then

    shared.stelemMessages = { }
	ardumessagesCursor = 1
	shared.stelemMessagesIndex = 1
  end
end

