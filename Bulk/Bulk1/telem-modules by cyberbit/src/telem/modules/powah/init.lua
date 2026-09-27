return function (api)
    return {
        input = {
            energyCell      = api.require 'powah.EnergyCellInputAdapter',
            furnator        = api.require 'powah.FurnatorInputAdapter',
            magmator        = api.require 'powah.MagmatorInputAdapter',
            reactor         = api.require 'powah.ReactorInputAdapter',
            solarPanel      = api.require 'powah.SolarPanelInputAdapter',
            thermoGenerator = api.require 'powah.ThermoGeneratorInputAdapter',
        },
    }
end