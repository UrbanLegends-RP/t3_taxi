QBCore = exports['qb-core']:GetCoreObject()

local activeDrivers = {}
local npcDriverNames = {"John Doe", "Jane Smith", "Michael Johnson", "Emily Davis"} -- Sample names for NPC drivers
local assignedNPCDrivers = {}

RegisterNetEvent('t3_taxi:setFare')
AddEventHandler('t3_taxi:setFare', function(fare)
    local src = source
    TriggerEvent('t3_taxi:notify', 'Fare calculated: $' .. fare)
end)

RegisterNetEvent('t3_taxi:spawnVehicle')
AddEventHandler('t3_taxi:spawnVehicle', function()
    local model = `taxi`
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    local vehicle = CreateVehicle(model, 903.21, -175.53, 74.08, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    table.insert(activeDrivers, {vehicle = vehicle, npc = false})
end)

RegisterNetEvent('t3_taxi:pickupPassenger')
AddEventHandler('t3_taxi:pickupPassenger', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestPed, closestPedDistance = GetClosestPed(coords)

    if closestPed and closestPedDistance < 2.5 then
        local destination = Config.DropOffLocations[math.random(#Config.DropOffLocations)]
        TaskEnterVehicle(closestPed, GetVehiclePedIsIn(playerPed, false), -1, 2, 1.0, 1, 0)
        SetNewWaypoint(destination.x, destination.y)
        TriggerEvent('t3_taxi:notify', 'Drive the passenger to the destination.')
        local distance = #(coords - vector3(destination.x, destination.y, destination.z))
        TriggerServerEvent('t3_taxi:calculateFare', distance)
    end
end)

RegisterNetEvent('t3_taxi:dropOffPassenger')
AddEventHandler('t3_taxi:dropOffPassenger', function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestPed, closestPedDistance = GetClosestPed(coords)

    if closestPed and closestPedDistance < 2.5 then
        TaskLeaveVehicle(closestPed, GetVehiclePedIsIn(playerPed, false), 0)
        TriggerEvent('t3_taxi:notify', 'You have dropped off the passenger.')
        TriggerServerEvent('t3_taxi:completeFare')
    end
end)

RegisterNetEvent('t3_taxi:notify')
AddEventHandler('t3_taxi:notify', function(message)
    QBCore.Functions.Notify(message)
end)

RegisterNetEvent('t3_taxi:hiringMenu')
AddEventHandler('t3_taxi:hiringMenu', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.job.name ~= Config.JobName then
        TriggerEvent('t3_taxi:notify', 'You do not have access to this menu.')
        return
    end

    local menu = {
        {
            header = "Taxi Management",
            isMenuHeader = true,
        },
        {
            header = "Hire Driver",
            txt = "Hire a new driver",
            params = {
                event = "t3_taxi:hireDriver"
            }
        },
        {
            header = "Fire Driver",
            txt = "Fire an existing driver",
            params = {
                event = "t3_taxi:fireDriver"
            }
        },
        {
            header = "Manage NPC Drivers",
            txt = "Manage NPC drivers",
            params = {
                event = "t3_taxi:manageNPCDrivers"
            }
        },
        {
            header = "Upgrade Vehicle",
            txt = "Upgrade a vehicle",
            params = {
                event = "t3_taxi:upgradeVehicle"
            }
        },
        {
            header = "Close Menu",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }
    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent('t3_taxi:hireDriver')
AddEventHandler('t3_taxi:hireDriver', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 3.0 then
        TriggerServerEvent('t3_taxi:hireDriver', GetPlayerServerId(player))
    else
        TriggerEvent('t3_taxi:notify', 'No players nearby to hire.')
    end
end)

RegisterNetEvent('t3_taxi:fireDriver')
AddEventHandler('t3_taxi:fireDriver', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 3.0 then
        TriggerServerEvent('t3_taxi:fireDriver', GetPlayerServerId(player))
    else
        TriggerEvent('t3_taxi:notify', 'No players nearby to fire.')
    end
end)

RegisterNetEvent('t3_taxi:manageNPCDrivers')
AddEventHandler('t3_taxi:manageNPCDrivers', function()
    local npcMenu = {
        {
            header = "Manage NPC Drivers",
            isMenuHeader = true,
        }
    }

    for i, driver in ipairs(assignedNPCDrivers) do
        table.insert(npcMenu, {
            header = driver.name,
            txt = "Earnings: $" .. driver.earnings,
            params = {
                event = "t3_taxi:removeNPCDriver",
                args = {driver.ped}
            }
        })
    end

    table.insert(npcMenu, {
        header = "Add NPC Driver",
        txt = "Add a new NPC driver",
        params = {
            event = "t3_taxi:addNPCDriver"
        }
    })

    table.insert(npcMenu, {
        header = "Back",
        params = {
            event = "t3_taxi:hiringMenu"
        }
    })

    exports['qb-menu']:openMenu(npcMenu)
end)

RegisterNetEvent('t3_taxi:addNPCDriver')
AddEventHandler('t3_taxi:addNPCDriver', function()
    local model = `taxi`
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local npcDriver = CreatePed(4, GetHashKey('a_m_m_business_01'), 903.21, -175.53, 74.08, 90.0, true, false)
    local vehicle = CreateVehicle(model, 903.21, -175.53, 74.08, true, false)
    TaskEnterVehicle(npcDriver, vehicle, -1, 2, 1.0, 1, 0)

    local driverName = npcDriverNames[math.random(#npcDriverNames)]
    local blip = AddBlipForEntity(vehicle)
    SetBlipSprite(blip, 280)
    SetBlipColour(blip, 0) -- Black color
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(driverName)
    EndTextCommandSetBlipName(blip)

    table.insert(assignedNPCDrivers, {ped = npcDriver, vehicle = vehicle, name = driverName, blip = blip, earnings = 0})
    TriggerEvent('t3_taxi:notify', 'NPC driver ' .. driverName .. ' added.')
end)

RegisterNetEvent('t3_taxi:removeNPCDriver')
AddEventHandler('t3_taxi:removeNPCDriver', function(npcPed)
    for i, driver in ipairs(assignedNPCDrivers) do
        if driver.ped == npcPed then
            RemoveBlip(driver.blip)
            DeleteEntity(driver.ped)
            DeleteEntity(driver.vehicle)
            TriggerEvent('t3_taxi:notify', 'NPC driver ' .. driver.name .. ' removed.')
            table.remove(assignedNPCDrivers, i)
            break
        end
    end
end)

RegisterNetEvent('t3_taxi:upgradeVehicle')
AddEventHandler('t3_taxi:upgradeVehicle', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle ~= 0 then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 11, 2, false) -- Engine
        SetVehicleMod(vehicle, 12, 2, false) -- Brakes
        SetVehicleMod(vehicle, 13, 2, false) -- Transmission
        SetVehicleMod(vehicle, 15, 3, false) -- Suspension
        SetVehicleWindowTint(vehicle, 1) -- Windows
        ToggleVehicleMod(vehicle, 18, true) -- Turbo
        TriggerEvent('t3_taxi:notify', 'Vehicle upgraded.')
    else
        TriggerEvent('t3_taxi:notify', 'You are not in a vehicle.')
    end
end)

Citizen.CreateThread(function()
    for _, location in pairs(Config.PickupLocations) do
        local blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, 280)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 5)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Passenger Pickup")
        EndTextCommandSetBlipName(blip)
    end

    -- Add a blip for the menu location
    local menuBlip = AddBlipForCoord(Config.MenuLocation.x, Config.MenuLocation.y, Config.MenuLocation.z)
    SetBlipSprite(menuBlip, 280)
    SetBlipDisplay(menuBlip, 4)
    SetBlipScale(menuBlip, 1.0)
    SetBlipColour(menuBlip, 5)
    SetBlipAsShortRange(menuBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Taxi Management")
    EndTextCommandSetBlipName(menuBlip)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local distance = #(coords - Config.MenuLocation)

        if distance < 5.0 then
            DrawText3D(Config.MenuLocation.x, Config.MenuLocation.y, Config.MenuLocation.z + 1.0, '[E] Open Taxi Management')
            if IsControlJustReleased(0, 38) then -- E key
                TriggerEvent('t3_taxi:hiringMenu')
                Citizen.Wait(1000) -- To prevent multiple triggers
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local scale = 0.35

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end)
