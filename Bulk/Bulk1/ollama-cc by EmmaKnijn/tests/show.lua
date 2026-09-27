local ollama = require("../ollama")

return function()
  local data = ollama.model.show("gemma3")
  if data then
    return true, "data was returned"
  else
    return false, "No data was returned"
  end
end