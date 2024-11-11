local QBCore = nil
local ESX = nil

if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

RegisterNetEvent('kt-deliveries:riceviPagamento')
AddEventHandler('kt-deliveries:riceviPagamento', function(amount)
    local xPlayer = nil

    -- Fetch the player based on the selected framework
    if Config.Framework == 'qbcore' then
        xPlayer = QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'esx' then
        xPlayer = ESX.GetPlayerFromId(source)
    end

    -- Ensure the player object is valid
    if not xPlayer then return end

    -- Validate the amount within expected bounds
    amount = tonumber(amount)
    if amount and amount > 0 and amount <= Config.RewardMax then
        if Config.Framework == 'qbcore' then
            xPlayer.Functions.AddMoney('cash', amount)
        elseif Config.Framework == 'esx' then
            xPlayer.addMoney(amount)
        end
    else
        print(('kt-deliveries: Payment failed for %s: invalid amount (%s)'):format(xPlayer.getName(), tostring(amount)))
    end
end)
