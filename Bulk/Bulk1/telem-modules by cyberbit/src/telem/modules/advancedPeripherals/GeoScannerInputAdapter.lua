return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'advancedPeripherals.BaseAdvancedPeripheralsInputAdapter'

    local GeoScannerInputAdapter = base.mintAdapter('GeoScannerInputAdapter')

    function GeoScannerInputAdapter:beforeRegister (peripheralName, categories)
        self.prefix = 'apgeo:'

        self.queries = {
            basic = {},
        }

        -- TODO no unit? intentional?? meh???
        self.storageQueries = {
            fn():callElse('chunkAnalyze', {})
                :orElse({}) -- catch case where scan is on cooldown
                :map(function (k, v) return api.Metric{ name = k, value = v } end)
                :values()
        }

        -- scan
    end

    return GeoScannerInputAdapter
end