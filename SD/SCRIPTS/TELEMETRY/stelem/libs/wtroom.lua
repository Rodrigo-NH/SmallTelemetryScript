local shared = ...
local step = 0

function shared.run(event)
    lcd.clear()
    collectgarbage("collect")
    step = step + 1
    if step > 3 then
        if shared.goMap then
            shared.goMap = false
            shared.LoadScreen(shared.Mapconf)
        elseif shared.goConf then
            shared.goConf = false
            shared.LoadScreen(shared.Configmenu)
        elseif shared.mapScreen then
            shared.mapScreen = false
            shared.LoadScreen(shared.Mapscreen)
        else
            shared.LoadScreen(shared.Screens[shared.CurrentScreen])
        end
    end
end
