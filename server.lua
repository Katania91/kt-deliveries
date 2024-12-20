local QBCore = nil
local ESX = nil
local ox = nil
local NDCore = nil

-- Initialize framework based on Config
if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'ox' then
    ox = exports['ox_core']:getSharedObject()
elseif Config.Framework == 'qbox' then
    QBCore = exports['qbox-core']:GetCoreObject()
elseif Config.Framework == 'nd' then
    NDCore = exports['nd-core']:getCoreObject()
end

local activeDeliveries = {}

-- Event to start a delivery job
RegisterNetEvent('kt-deliveries:startJob')
AddEventHandler('kt-deliveries:startJob', function()
    local src = source
    if activeDeliveries[src] then return end

    activeDeliveries[src] = {
        deliveriesCompleted = 0,
        depositPaid = true
    }
end)

-- Event to deduct the $300 deposit at the start of the job
lib.callback.register('kt-deliveries:deductDeposit', function(source)
    local xPlayer = nil
    local depositAmount = 300

    -- Fetch the player object based on the framework
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        xPlayer = QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'esx' or Config.Framework == 'ox' then
        xPlayer = ESX.GetPlayerFromId(source)
    elseif Config.Framework == 'nd' then
        xPlayer = NDCore.Functions.GetPlayer(source)
    end

    if not xPlayer then return false end

    local result = false
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        result = xPlayer.Functions.GetMoney('cash') >= depositAmount
        if result then xPlayer.Functions.RemoveMoney('cash', depositAmount) end
    elseif Config.Framework == 'esx' then
        result = xPlayer.getMoney() >= depositAmount
        if result then xPlayer.removeMoney(depositAmount) end
    elseif Config.Framework == 'nd' then
        result = xPlayer.deductMoney("cash", depositAmount, "Job deposit")
    elseif Config.Framework == 'ox' then
        result = false -- not sure what is
    end

    return result
end)

    -- Deduct the deposit from the player
    local success = false
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        success = xPlayer.Functions.RemoveMoney('cash', depositAmount)
    elseif Config.Framework == 'esx' or Config.Framework == 'ox' then
        success = xPlayer.removeMoney(depositAmount)
    elseif Config.Framework == 'nd' then
        success = xPlayer.removeCurrency('cash', depositAmount)
    end

    if success then
        activeDeliveries[source] = { deliveriesCompleted = 0, depositPaid = true }
        return true
    end

    return false
end)

-- Event to handle payment per delivery
RegisterNetEvent('kt-deliveries:riceviPagamento')
AddEventHandler('kt-deliveries:riceviPagamento', function(amount)
    local src = source
    local playerData = activeDeliveries[src]
    if not playerData then return end

    local xPlayer = nil

    -- Fetch the player object based on the framework
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        xPlayer = QBCore.Functions.GetPlayer(src)
    elseif Config.Framework == 'esx' or Config.Framework == 'ox' then
        xPlayer = ESX.GetPlayerFromId(src)
    elseif Config.Framework == 'nd' then
        xPlayer = NDCore.Functions.GetPlayer(src)
    end

    if not xPlayer then return end

    -- Validate the amount within expected bounds
    amount = tonumber(amount)
    if amount and amount > 0 and amount <= Config.RewardMax then
        if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
            xPlayer.Functions.AddMoney('cash', amount)
        elseif Config.Framework == 'esx' or Config.Framework == 'ox' then
            xPlayer.addMoney(amount)
        elseif Config.Framework == 'nd' then
            xPlayer.addCurrency('cash', amount)
        end
        playerData.deliveriesCompleted = playerData.deliveriesCompleted + 1
    else
        print(('kt-deliveries: Payment failed for %s: invalid amount (%s)'):format(xPlayer.getName(), tostring(amount)))
    end
end)

-- Event to return the deposit when the job ends
RegisterNetEvent('kt-deliveries:returnDeposit')
AddEventHandler('kt-deliveries:returnDeposit', function()
    local src = source
    local playerData = activeDeliveries[src]
    if not playerData or not playerData.depositPaid then return end

    local xPlayer = nil
    local depositAmount = 300

    -- Fetch the player object based on the framework
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        xPlayer = QBCore.Functions.GetPlayer(src)
    elseif Config.Framework == 'esx' or Config.Framework == 'ox' then
        xPlayer = ESX.GetPlayerFromId(src)
    elseif Config.Framework == 'nd' then
        xPlayer = NDCore.Functions.GetPlayer(src)
    end

    if not xPlayer then return end

    -- Refund the deposit to the player
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        xPlayer.Functions.AddMoney('cash', depositAmount)
    elseif Config.Framework == 'esx' or Config.Framework == 'ox' then
        xPlayer.addMoney(depositAmount)
    elseif Config.Framework == 'nd' then
        xPlayer.addCurrency('cash', depositAmount)
    end

    activeDeliveries[src] = nil
end)

-- Clean up when a player disconnects
AddEventHandler('playerDropped', function()
    local src = source
    activeDeliveries[src] = nil
end)
