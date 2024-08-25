local name = "Stelem"
-- local shared = { }
-- local debugm = "txd"
local debugm = "bt"

-- Create a table with default options
-- Options can be changed by the user from the Widget Settings menu
-- Notice that each line is a table inside { }
local options = {
  -- { "Source", SOURCE, 1 },
  -- -- BOOL is actually not a boolean, but toggles between 0 and 1
  -- { "Boolean", BOOL, 1 },
  -- { "Value", VALUE, 1, 0, 10},
  -- { "Color", COLOR, ORANGE },
  -- { "Text", STRING, "Max8chrs" }
}


local function LoadLua(filename)
	local sc = loadScript(filename, debugm)
	return sc()
end

-- local ld = LoadLua("/SCRIPTS/TELEMETRY/stelem/stelemg.lua")
local main = LoadLua("/SCRIPTS/TELEMETRY/stelem.lua")

local function create(zone, options)
  -- Runs one time when the widget instance is registered
  -- Store zone and options in the widget table for later use
  local widget = {
    zone = zone,
    options = options
  }
  -- Add local variables to the widget table,
  -- unless you want to share with other instances!
  widget.someVariable = 3

--   print(LCD_W)
-- print("ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")

main.getWidget(LCD_W, LCD_H)
  -- main.init()
  -- Return widget table to EdgeTX



  -- return widget
end

local function update(widget, options)
  -- Runs if options are changed from the Widget Settings menu
  -- widget.options = options
  local nothinghere = 0
end

local function background(widget)
  main.background()
end

local function refresh(widget, event, touchState)
  -- Runs periodically only when widget instance is visible
  -- If full screen, then event is 0 or event value, otherwise nil
  lcd.refresh()
  main.background()
  main.run(event)
end

return {
  name = name,
  options = options,
  create = create,
  update = update,
  refresh = refresh,
  background = background
}