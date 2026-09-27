local ollama = require("../ollama")

return function()
   local data = ollama.model.ps()
   if data and #data.models > 0 then
      return true, #data.models .. " models loaded"
   elseif #data.models == 0 then
      return false, "No models loaded"
   else
      return false, "No data was returned"
    end
end