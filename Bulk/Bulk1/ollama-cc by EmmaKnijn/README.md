# Ollama ComputerCraft Client
This is a basic ComputerCraft client for Ollama. It is intended to be used as a client for unknown and unprivileged ollama endpoints, thus any functions to download, delete, copy, push models are not implemented.
The library is designed to pass a server's response straight through to the user, assuming they will be able to handle the response. The library does provide some useful functions to process responses.

The tests provide reasonable examples on how to use specific functions and are thus a useful reference.

## API reference
### ollama.version()
Returns the ollama version on the server.

### ollama.setEndpoint(endpoint)
Sets the endpoint for ollama-cc to talk to. Needs to be in the format `http://url` without a trailing slash

### ollama.chat(model,messages)
Starts a chat with ollama, messages (including history, optionally) will need to be passed every call.

The format for the messages field is as follows:
```lua
  {
    {
        role = "system",
        content = "This is a system prompt!"
    },
    {
        role = "user",
        content = "This is a test message that the user has entered"
    }
  }
```

This table will need to be passed as a lua table as ollama-cc will handle the conversion to and from json internally.

### ollama.generate(model,prompt)
Generates a response with the specified model and prompt.

### ollama.model.load(model)
Load a model into memory

### ollama.model.unload(model)
Unload a model

### ollama.model.list()
Lists all models available locally

### ollama.model.show(model)
Get information about a particular model

### ollama.model.ps()
Get currently running and loaded models

### ollama.process.reasoning(data)
Split out a message from a reasoning model into what is being reasoned and the message. Data takes a singular string of the input.

Returns the following:
```lua
{think = think_content, message = message}
```

## Contributing
If you'd like to contribute, please run the tests yourself before making a PR, and attach a screenshot of the tests passing.

## Running tests
In order to run the tests, you need to have the gemma3 and qwen3:0.6b models downloaded on your system. The tests will not pass otherwise.
By default, ollama-cc points to localhost for tests, you can change this however by running `set ollama.endpoint (url)`

