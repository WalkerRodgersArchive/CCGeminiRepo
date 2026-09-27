local ollama = require("../ollama")

return function()
   local data = ollama.model.load("gemma3")
   if data then
      return true, "loaded model " .. data.model
   else
      return false, "No data was returned"
    end
end