function Start()
 while true do
  local keyEvent = {os.pullEvent("key")};
  print((tostring(keys.getName(keyEvent[2])).." held=")..tostring(keyEvent[3]))
 end
end
Start()