return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'mekanism.BaseMekanismInputAdapter'

    local EnrichmentChamberInputAdapter = base.mintAdapter('EnrichmentChamberInputAdapter')

    function EnrichmentChamberInputAdapter:beforeRegister ()
        self.prefix = 'mekenrich:'

        self.queries = {
            basic = {
                input_count     = fn():call('getInput'):get('count'):with('unit', 'item'),
                output_count    = fn():call('getOutput'):get('count'):with('unit', 'item'),
                energy_usage    = fn():call('getEnergyUsage'):joulesToFE():energyRate(),
            },
        }
        
        self:withGenericMachineQueries()
            :withRecipeProgressQueries()

        -- getDirection
        -- getRedstoneMode
    end

    return EnrichmentChamberInputAdapter
end