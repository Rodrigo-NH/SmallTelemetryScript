local function locate(table, value)
  for i = 1, #table do
    if table[i][1] == value then
      print(value .. ' found')
      return i
    end
  end
  print(value .. ' not found')
  return false
end

local function getSettingsSubSet(localCopy, list)
  local subs = {}
  for e = 1, #list
  do
    local elem = list[e]
    subs[#subs + 1] = localCopy[locate(localCopy, elem)]
  end
  return subs
end


local menurefs = {
  { "RSS","TxPower","GPS position","GPS speed","Heading", "Altitude", "Number of sats","RX batt. volt.","Current","Batt.(%)","Pitch","Roll","Yaw","Flight Mode"},
  {"Screen Size","Msg log","Sounds", "Msg Buffer size", "Splash Screen"},
  {"Variometer clip val","Att. indicator scale"},
  {"Cell voltage","Number of cells", "CRSF Telemetry", "Tel.polling interval", "Heading method","Hdg vel. min. distance","Hdg vel. time (sec)", "Hdg vel debug sound"},
  {"Show WP numbers","Show scale", "Miss. Auto GoTo","Origin set Upd. Home", "Show Batt.Volt", "Show Alt.","Show Home Alt.",
  "Show RSSI", "Show Nsat","Show Vspeed","Show Hspeed","Show Throt.","Show TXpow.","Show Batt%","DebMem" }
}

local menustruct = {
  { "General settings",      1 },
  { "Nav instrum. settings", 1 },
  { "Telemetry settings",    1 },
  { "Screens",               1 },
  { "Map options",           1 },
  { "Telemetry mapping",     1 }
}


return {
  locate = locate,
  getSettingsSubSet = getSettingsSubSet,
  menurefs = menurefs,
  menustruct = menustruct,
}
