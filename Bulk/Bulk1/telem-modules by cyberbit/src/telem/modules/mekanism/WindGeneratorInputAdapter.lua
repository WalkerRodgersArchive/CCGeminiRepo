return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'mekanism.BaseMekanismInputAdapter'

    local WindGeneratorInputAdapter = base.mintAdapter('WindGeneratorInputAdapter')

    function WindGeneratorInputAdapter:beforeRegister ()
        self.prefix = 'mekwindgen:'

        self.queries = {
            basic = {
                blacklisted_dimension   = fn():call('isBlacklistedDimension'):toFlag(),
            },
        }
        
        self:withGenericMachineQueries()
            :withGeneratorQueries()

        -- getDirection
        -- getRedstoneMode
    end

    return WindGeneratorInputAdapter
end