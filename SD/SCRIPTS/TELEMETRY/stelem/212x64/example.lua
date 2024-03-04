local shared = ...

function shared.run(event)
  lcd.clear()

  lcd.drawText(0, 0, "You can construct your own", SMLSIZE)
  lcd.drawText(0, 7, "screen versions by adding a", SMLSIZE)
  lcd.drawText(0, 14, "size directory (e.g. 212x64", SMLSIZE)
  lcd.drawText(0, 21, "folder); create your screens", SMLSIZE)
  lcd.drawText(0, 28, "and adding a corresponding", SMLSIZE)
  lcd.drawText(0, 35, "scsList.cfg file", SMLSIZE)
  
  shared.defaultActions(event)


end