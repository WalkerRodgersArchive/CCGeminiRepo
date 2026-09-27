local ollama = require("../ollama")

return function()
  local response = ollama.generate("gemma3","You are an AI model and you are being called in the process of testing an api call. Write a small message under 5 words indicating that you're working properly, you do not need to include any \"\"'s")
  if response and response.response then
    return true, response.response
  elseif not response.response then
    return false, "No message was returned"
  else
    return false, "No data was returned"
  end
end