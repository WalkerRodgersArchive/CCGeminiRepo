return function (api)
    return {
        input = {
            energyDetector          = api.require 'advancedPeripherals.EnergyDetectorInputAdapter',
            environmentDetector     = api.require 'advancedPeripherals.EnvironmentDetectorInputAdapter',
            geoScanner              = api.require 'advancedPeripherals.GeoScannerInputAdapter',
            inventoryManager        = api.require 'advancedPeripherals.InventoryManagerInputAdapter',
            meBridge                = api.require 'advancedPeripherals.MEBridgeInputAdapter',
            playerDetector          = api.require 'advancedPeripherals.PlayerDetectorInputAdapter',
            redstoneIntegrator      = api.require 'advancedPeripherals.RedstoneIntegratorInputAdapter',
            rsBridge                = api.require 'advancedPeripherals.RSBridgeInputAdapter',
        },
    }
end