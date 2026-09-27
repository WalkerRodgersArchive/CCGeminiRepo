return function (api)
    local fn = api.vendor.fluent.fn

    local base = api.require 'mekanism.BaseMekanismInputAdapter'

    local LaserTractorBeamInputAdapter = base.mintAdapter('LaserTractorBeamInputAdapter')

    function LaserTractorBeamInputAdapter:beforeRegister ()
        self.prefix = 'mektractorbeam:'

        self.queries = {
            basic = {
                slot_usage  = base.mintSlotUsageQuery('getSlotCount', 'getItemInSlot'),
                slot_count  = fn():call('getSlotCount'),
            }
        }

        -- TODO not sure the energy metrics mean anything to this component

        self:withGenericMachineQueries()
    end

    return LaserTractorBeamInputAdapter
end