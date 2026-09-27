return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'advancedPeripherals.BaseAdvancedPeripheralsInputAdapter'

    local EnergyDetectorInputAdapter = base.mintAdapter('EnergyDetectorInputAdapter')

    function EnergyDetectorInputAdapter:beforeRegister (peripheralName, categories)
        self.prefix = 'apenergy:'

        self.queries = {
            basic = {
                transfer_rate       = fn():call('getTransferRate'):energyRate(),
                transfer_rate_limit = fn():call('getTransferRateLimit'):energyRate(),
            }
        }
    end

    return EnergyDetectorInputAdapter
end