local ollama = require("../ollama")

return function()
  local data = ollama.model.unload("gemma3")
  if data then
    return true, "unloaded model " .. data.model
  else
    return false, "No data was returned"
  end
end