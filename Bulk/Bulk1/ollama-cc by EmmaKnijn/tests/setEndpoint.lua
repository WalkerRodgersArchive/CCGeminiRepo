local ollama = require("../ollama")

return function()
  local oldEndpoint = settings.get("ollama.endpoint")
  ollama.setEndpoint("TESTENDPOINT")
  local ok = false
  local info = "Endpoint was not changed"
  if settings.get("ollama.endpoint") == "TESTENDPOINT" then
    ok = true
    info = "Endpoint was successfully updated"
  end
  ollama.setEndpoint(oldEndpoint) -- Make sure ollama API is aware of the change
  settings.set("ollama.endpoint",oldEndpoint)
  settings.save()
  
  return ok, info
end