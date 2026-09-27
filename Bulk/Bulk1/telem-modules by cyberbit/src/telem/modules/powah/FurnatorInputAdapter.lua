return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'powah.BasePowahInputAdapter'

    local FurnatorInputAdapter = base.mintAdapter('FurnatorInputAdapter')

    function FurnatorInputAdapter:beforeRegister ()
        self.prefix = 'powahfurnator:'

        self.queries = {
            basic = {
                burning = fn():call('isBurning'):toFlag(),
                carbon  = fn():call('getCarbon'):with('unit', '%'),
            }
        }
        
        self:withEnergyQueries()

        -- TODO getInventory seems to always return nil (this is fixed in a later AP version)

        -- getName
        -- getInventory
    end

    return FurnatorInputAdapter
end