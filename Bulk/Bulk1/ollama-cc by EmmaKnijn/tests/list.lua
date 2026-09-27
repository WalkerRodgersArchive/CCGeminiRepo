local ollama = require("../ollama")

return function()
  local data = ollama.model.list()
  if data then
    return true, "Data was returned"
  else
    return false, "No data was returned"
  end
end