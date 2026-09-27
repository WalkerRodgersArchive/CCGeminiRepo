return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'mekanism.BaseMekanismInputAdapter'

    local OredictionificatorInputAdapter = base.mintAdapter('OredictionificatorInputAdapter')

    function OredictionificatorInputAdapter:beforeRegister ()
        self.prefix = 'mekoredict:'

        self.queries = {
            basic = {
                input_count     = fn():call('getInputItem'):get('count'):with('unit', 'item'),
                output_count    = fn():call('getOutputItem'):get('count'):with('unit', 'item'),
            },
        }
    end

    return OredictionificatorInputAdapter
end