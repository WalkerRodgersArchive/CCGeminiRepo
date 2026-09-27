local ollama = require("../ollama")

return function()
   local version = ollama.version()
   if version then
      return true, "The version is " .. version
   else
      return false, "No version was returned"
    end
end