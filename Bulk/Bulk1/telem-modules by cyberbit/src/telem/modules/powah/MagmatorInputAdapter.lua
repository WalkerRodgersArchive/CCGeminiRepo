return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'powah.BasePowahInputAdapter'

    local MagmatorInputAdapter = base.mintAdapter('MagmatorInputAdapter')

    function MagmatorInputAdapter:beforeRegister ()
        self.prefix = 'powahmagmator:'

        self.queries = {
            basic = {
                burning         = fn():call('isBurning'):toFlag(),
                fluid           = fn():call('getFluidInTank'):div(1000):fluid(),
                fluid_capacity  = fn():call('getTankCapacity'):div(1000):fluid(),
            }
        }
        
        self:withEnergyQueries()

        -- TODO getInventory seems to always return nil (this is fixed in a later AP version)

        -- getName
        -- getInventory
    end

    return MagmatorInputAdapter
end