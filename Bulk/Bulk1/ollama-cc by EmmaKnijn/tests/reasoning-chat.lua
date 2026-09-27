local ollama = require("../ollama")

return function()
  local response = ollama.chat("qwen3:0.6b",{{role = "user", content = "You are an AI model and you are being called in the process of testing an api call. Write a small message under 5 words indicating that you're working properly, you do not need to include any \"\"'s"}})
  local messageProcessed = ollama.process.reasoning(response.message.content)
  if response and messageProcessed.message and messageProcessed.think then
    return true, messageProcessed.message
  elseif not messageProcessed.message then
    return false, "No message in processed message"
  elseif not messageProcessed.think then
    return false, "No reasoning in processed message"
  else
    return false, "No data was returned"
  end
end