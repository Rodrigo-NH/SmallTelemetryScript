local shared = ...
local temporaryvis = 0

function shared.run(event)
  lcd.clear()
  local line = 0
	for i=1,#shared.Messages
	do
		lcd.drawText(0, line, tostring(shared.Messages[i]), SMLSIZE)
		line = line + 8
	end

  if event == 70 then
    temporaryvis = 1
  end

  if event ~= 70 and temporaryvis == 1 then
    shared.LoadScreen(shared.Screens[1])
  end  

    if event == EVT_VIRTUAL_NEXT or event == 99 then
      shared.CycleScreen(1)
    elseif event == EVT_VIRTUAL_PREV or event == 98 then
      shared.CycleScreen(-1)
    elseif event == EVT_VIRTUAL_ENTER then
      shared.Messages = { }
      shared.MessagesIndex = 1
    end
end

