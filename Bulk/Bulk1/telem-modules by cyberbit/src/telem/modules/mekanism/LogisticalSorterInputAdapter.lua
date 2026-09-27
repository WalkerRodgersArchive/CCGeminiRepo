return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'mekanism.BaseMekanismInputAdapter'

    local LogisticalSorterInputAdapter = base.mintAdapter('LogisticalSorterInputAdapter')

    function LogisticalSorterInputAdapter:beforeRegister ()
        self.prefix = 'meklogsorter:'

        self.queries = {
            basic = {
                comparator_level    = fn():call('getComparatorLevel'),
            },
        }
    end

    return LogisticalSorterInputAdapter
end