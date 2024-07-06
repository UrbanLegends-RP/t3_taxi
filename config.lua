Config = {}

Config.PickupLocations = {
    vector3(-1013.2, -2695.5, 13.97),
    vector3(228.57, -806.31, 30.54),
    -- Add more locations as needed
}

Config.DropOffLocations = {
    vector3(200.0, -1000.0, 30.0),
    vector3(300.0, -1200.0, 40.0),
    -- Add more locations as needed
}

Config.MenuLocation = vector3(903.21, -175.53, 74.08)

Config.VehicleModels = {
    ["taxi"] = {
        label = "Taxi",
        price = 5000,
        fuelCapacity = 100
    }
}

Config.JobName = 'taxowner' -- Job name to check for access to management features
