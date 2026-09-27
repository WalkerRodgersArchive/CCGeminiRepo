local ollama = require("../ollama")

return function()
  local response = ollama.chat("gemma3",{{role = "user", content = "You are an AI model and you are being called in the process of testing an api call. Write a small message under 5 words indicating that you're working properly, you do not need to include any \"\"'s"}})
  if response and response.message.content then
    return true, response.message.content
  elseif not response.message.content then
    return false, "No message was returned"
  else
    return false, "No data was returned"
  end
end