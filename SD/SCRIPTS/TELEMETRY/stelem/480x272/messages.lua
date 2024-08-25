local shared = ...
local msglines = 20
msglines = msglines - 1

local function scrollBar(scrollpos, scrollref)
  scrollpos = (scrollpos * (shared.screenH / scrollref))
  -- Enable to watch fun numbers
  --  print(scrollpos)
  if scrollpos < 0 then
    scrollpos = 0
  elseif scrollpos > shared.screenH - 5 then
    scrollpos = shared.screenH - 5
  end
  lcd.drawFilledRectangle(0, 0, 10, shared.screenH, DARKGREY)
  lcd.drawFilledRectangle(0, scrollpos, 10, 5, LIGHTWHITE)
end

shared.scrollIndex = 1

function shared.run(event)
  lcd.clear()
  local line = 0
  local goku = shared.MessagesIndex - msglines + 1 - shared.scrollIndex
  if goku < 0 and shared.MessagesIndex == shared.MessagesBuffSize then
    shared.scrollIndex = shared.scrollIndex - 1
  end
  local scrollpos = shared.MessagesIndex - shared.scrollIndex - msglines + 1
  local scrollref = shared.MessagesBuffSize - msglines
  scrollBar(scrollpos, scrollref)

  local startref = shared.MessagesIndex - msglines + 1 - shared.scrollIndex
  for i = startref, shared.MessagesIndex - shared.scrollIndex + 1
  do
    if shared.Messages[i] ~= nil then
      lcd.drawText(12, line, tostring(shared.Messages[i]), SMLSIZE)
    end
    line = line + 13
  end

  if event == 96 or event == 1540 then
    if shared.scrollIndex > 1 then
      shared.scrollIndex = 1
    else
      shared.CurrentScreen = shared.CurrentScreen + 1
      if shared.CurrentScreen > #shared.Screens then
        shared.CurrentScreen = 1
      end
      shared.LoadScreen(shared.libsDir .. "wtroom.lua")
    end
  elseif event == EVT_VIRTUAL_ENTER then
    shared.tempTimer2 = shared.tempTimer2 + 1
    shared.Messages = {}
    shared.MessagesIndex = 0
    shared.scrollIndex = 1
  elseif event == EVT_VIRTUAL_NEXT or event == 99 then
    shared.scrollIndex = shared.scrollIndex - 1
    if shared.scrollIndex == 0 or shared.MessagesIndex < msglines then
      shared.scrollIndex = 1
    end
  elseif event == EVT_VIRTUAL_PREV or event == 98 then
    if shared.MessagesIndex > msglines then
      shared.scrollIndex = shared.scrollIndex + 1

      if shared.MessagesIndex - msglines + 1 - shared.scrollIndex < 0 then
        shared.scrollIndex = shared.scrollIndex - 1
      end
    end
  end
end
