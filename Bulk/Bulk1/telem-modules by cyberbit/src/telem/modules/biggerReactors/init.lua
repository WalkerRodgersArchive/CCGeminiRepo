return function (api)
    return {
        input = {
            reactor = api.require 'biggerReactors.ReactorInputAdapter',
            turbine = api.require 'biggerReactors.TurbineInputAdapter',
        },
    }
end