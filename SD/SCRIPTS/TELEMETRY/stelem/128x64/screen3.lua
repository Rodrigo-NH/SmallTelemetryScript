local shared = ...
-- local temporaryvis = 0

function shared.run(event)
  lcd.clear()
  local line = 0
	for i=1,#shared.Messages
	do
		lcd.drawText(0, line, tostring(shared.Messages[i]), SMLSIZE)
		line = line + 8
	end


  shared.defaultActions(event)

  if event == 96 then
    shared.Messages = {}
    shared.MessagesIndex = 1
  end
  
end

