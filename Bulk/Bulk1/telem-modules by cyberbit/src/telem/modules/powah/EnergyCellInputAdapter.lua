return function (api)
    local base = api.require 'powah.BasePowahInputAdapter'

    local EnergyCellInputAdapter = base.mintAdapter('EnergyCellInputAdapter')

    function EnergyCellInputAdapter:beforeRegister ()
        self.prefix = 'powahcell:'

        self.queries = {
            -- mixins cover everything
        }
        
        self:withEnergyQueries()

        -- getName
    end

    return EnergyCellInputAdapter
end