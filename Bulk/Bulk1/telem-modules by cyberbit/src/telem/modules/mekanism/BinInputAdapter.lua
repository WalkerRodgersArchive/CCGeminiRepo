return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'mekanism.BaseMekanismInputAdapter'

    local BinInputAdapter = base.mintAdapter('BinInputAdapter')

    function BinInputAdapter:beforeRegister ()
        self.prefix = 'mekbin:'

        self.queries = {
            basic = {
                stored      = fn():call('getStored'):get('count'):with('unit', 'item'),
                capacity    = fn():call('getCapacity'):with('unit', 'item'),
            },
        }

        self.storageQueries = {
            fn():call('getStored'):transform(function (v)
                if v.count == 0 then
                    return {}
                end
                
                return { api.Metric{ name = v.name, value = v.count, unit = 'item' } }
            end)
        }

        -- getComparatorLevel
        -- getDirection
        
        -- TODO only supports comparator and direction
        -- self:withGenericMachineQueries()
    end

    return BinInputAdapter
end