QBCore = exports['qb-core']:GetCoreObject()
local npcDrivers = {}

RegisterServerEvent('fetchNPCDrivers')
AddEventHandler('fetchNPCDrivers', function()
    local src = source
    TriggerClientEvent('npcDriversData', src, npcDrivers)
end)

RegisterServerEvent('addNPCDriver')
AddEventHandler('addNPCDriver', function()
    local src = source
    local driverId = #npcDrivers + 1
    local driverName = "NPC Driver " .. driverId
    local newDriver = { id = driverId, name = driverName, earnings = 0 }
    table.insert(npcDrivers, newDriver)
    TriggerClientEvent('npcDriverAdded', src, { success = true })
end)

RegisterServerEvent('fireNPCDriver')
AddEventHandler('fireNPCDriver', function(data)
    local src = source
    for i, driver in ipairs(npcDrivers) do
        if driver.id == data.id then
            table.remove(npcDrivers, i)
            break
        end
    end
    TriggerClientEvent('npcDriverFired', src, { success = true })
end)

RegisterServerEvent('t3_taxi:calculateFare')
AddEventHandler('t3_taxi:calculateFare', function(distance)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local fare = math.floor(distance * 0.5)
    TriggerClientEvent('t3_taxi:setFare', src, fare)
    UpdateNPCEarnings(src, fare)
end)

RegisterServerEvent('t3_taxi:completeFare')
AddEventHandler('t3_taxi:completeFare', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local fare = Player.PlayerData.money['cash']
    Player.Functions.AddMoney('cash', fare, "taxi-fare")
    TriggerClientEvent('t3_taxi:notify', src, 'You received $' .. fare .. ' for the fare.')
end)

RegisterServerEvent('t3_taxi:hireDriver')
AddEventHandler('t3_taxi:hireDriver', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local target = QBCore.Functions.GetPlayer(targetId)

    if Player.PlayerData.job.name == Config.JobName then
        if target then
            target.Functions.SetJob('driver')
            TriggerClientEvent('t3_taxi:notify', targetId, 'You have been hired as a Taxi Driver.')
            TriggerClientEvent('t3_taxi:notify', src, 'You have hired a new driver.')
        else
            TriggerClientEvent('t3_taxi:notify', src, 'Target player not found.')
        end
    else
        TriggerClientEvent('t3_taxi:notify', src, 'You do not have permission to hire drivers.')
    end
end)

RegisterServerEvent('t3_taxi:fireDriver')
AddEventHandler('t3_taxi:fireDriver', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local target = QBCore.Functions.GetPlayer(targetId)

    if Player.PlayerData.job.name == Config.JobName then
        if target then
            target.Functions.SetJob('unemployed')
            TriggerClientEvent('t3_taxi:notify', targetId, 'You have been fired from the Taxi job.')
            TriggerClientEvent('t3_taxi:notify', src, 'You have fired a driver.')
        else
            TriggerClientEvent('t3_taxi:notify', src, 'Target player not found.')
        end
    else
        TriggerClientEvent('t3_taxi:notify', src, 'You do not have permission to fire drivers.')
    end
end)

function UpdateNPCEarnings(src, fare)
    TriggerClientEvent('t3_taxi:updateNPCEarnings', -1, src, fare)
end
