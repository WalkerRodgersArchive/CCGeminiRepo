local ollama = {}

local baseUrl = settings.get("ollama.endpoint") or error("No endpoint has been set. Please set an endpoint with `set ollama.endpoint`.")

local function getRequest(endpoint)
  local h, err = http.get(baseUrl .. "/api/" .. endpoint)
  if not h then
    error("HTTP error: " .. err)
  end
  local result = textutils.unserialiseJSON(h.readAll())
  return result
end

local function postRequest(endpoint,body)
  local h, err = http.post(baseUrl .. "/api/" .. endpoint,body)
  if not h then
    error("HTTP error: " .. err)
  end
  local result = textutils.unserialiseJSON(h.readAll())
  return result
end


-- api implementation
ollama.version = function()
  return getRequest("version").version
end

ollama.setEndpoint = function(endpoint)
  settings.set("ollama.endpoint",endpoint)
  settings.save()
  baseUrl = endpoint
end

ollama.chat = function(model,messages)
  local body = {}
  body.model = model
  body.messages = messages
  if not body.messages then error("Messages must be passed") end
  
  body.stream = false

  return postRequest("chat",textutils.serialiseJSON(body))
end

ollama.generate = function(model,prompt)
  local body = {}
  body.model = model
  body.prompt = prompt
  if not body.prompt then error("Prompt must be passed") end
  
  body.stream = false

  return postRequest("generate",textutils.serialiseJSON(body))
end

ollama.model = {}
ollama.model.load = function(model)
  return postRequest("generate",textutils.serialiseJSON({model = model}))
end

ollama.model.unload = function(model)
  return postRequest("generate",textutils.serialiseJSON({model = model, keep_alive = 0}))
end

ollama.model.list = function()
  return getRequest("tags")
end

ollama.model.show = function(model)
  return postRequest("show",textutils.serialiseJSON({name = model}))
end

ollama.model.ps = function()
  return getRequest("ps")
end

ollama.process = {}
ollama.process.reasoning = function(data)
    local think_content, after_think = string.match(data, "<think>%s*(.-)%s*</think>%s*(.*)")
    return {think = think_content, message = after_think}
end


return ollama