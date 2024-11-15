local Translations = {}
local isInDelivery = false
local currentDeliveryIndex = 1
local deliveryBlip = nil
local furgone = nil
local michaelNPC = nil
local playerOriginalOutfit = nil
local isHoldingPackage = false
local deliveryPeds = {}
local deliveryStartTime = nil
local pedModels = { `a_m_y_hipster_01`, `a_f_y_hipster_01`, `a_m_m_socenlat_01`, `a_f_y_genhot_01`, `a_m_m_soucent_01`, `a_f_m_soucent_01`, `a_m_m_prolhost_01`, `a_f_y_tourist_02`, `a_m_y_polynesian_01`, `a_f_y_indian_01` }

-- Create the blip at Michael's position
CreateThread(function()
    local michaelBlip = AddBlipForCoord(Config.MichaelCoords)
    SetBlipSprite(michaelBlip, 501)
    SetBlipDisplay(michaelBlip, 4)
    SetBlipScale(michaelBlip, 0.9)
    SetBlipColour(michaelBlip, 5)
    SetBlipAsShortRange(michaelBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Translations.blip_name)
    EndTextCommandSetBlipName(michaelBlip)
end)

-- Function to shuffle the delivery locations randomly
local function shuffleDeliveries(deliveries)
    for i = #deliveries, 2, -1 do
        local j = math.random(i)
        deliveries[i], deliveries[j] = deliveries[j], deliveries[i]
    end
    return deliveries
end

-- Load translations
local function loadLocale(locale)
    local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. locale .. '.lua')
    if localeFile then
        local func, err = load(localeFile)
        if func then
            func()
            Translations = Locales[locale] or {}
        else
            print("kt-deliveries: Error loading language file: " .. err)
        end
    else
        print("kt-deliveries: Translation file not found for language: " .. locale)
    end
end
loadLocale(Config.Locale)

-- Shuffle delivery locations
Config.DeliveryLocations = shuffleDeliveries(Config.DeliveryLocations)

-- Function to attach package to player and limit movement
local function attachPackageToPlayer()
    ExecuteCommand("e box")
    isHoldingPackage = true
end

-- Limit player movement while holding the package
CreateThread(function()
    while true do
        Wait(0)
        if isHoldingPackage then
            DisableControlAction(0, 21, true)  -- Disable running (Shift)
            DisableControlAction(0, 22, true)  -- Disable jumping (Space)
            DisableControlAction(0, 140, true) -- Disable melee attack (R)
        else
            Wait(500)
        end
    end
end)

-- Function to spawn a random ped at each delivery location
local function spawnDeliveryPed(coords)
    local pedModel = pedModels[math.random(#pedModels)]
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do Wait(0) end
    local deliveryPed = CreatePed(4, pedModel, coords.x, coords.y, coords.z - 1.0, 0.0, false, true)
    FreezeEntityPosition(deliveryPed, true)
    SetEntityInvincible(deliveryPed, true)
    SetBlockingOfNonTemporaryEvents(deliveryPed, true)
    exports.ox_target:addLocalEntity(deliveryPed, {
        {
            name = 'dropOffPackage',
            label = Translations.label_deliver_package,
            icon = 'fa-solid fa-box',
            event = 'deliveries:dropOffPackage',
            canInteract = function()
                return isHoldingPackage
            end
        }
    })
    table.insert(deliveryPeds, deliveryPed)
end

-- Function to make the ped walk away and delete it after 10 seconds
local function deleteDeliveryPed(ped)
    if DoesEntityExist(ped) then
        exports.ox_target:removeLocalEntity(ped, { 'dropOffPackage' })
        
        -- Unfreeze the ped in case it was frozen
        FreezeEntityPosition(ped, false)
        
        -- Generate a random direction for the ped to walk
        local xOffset = math.random(-10, 10) * 1.0
        local yOffset = math.random(-10, 10) * 1.0
        local pedCoords = GetEntityCoords(ped)
        local targetCoords = vector3(pedCoords.x + xOffset, pedCoords.y + yOffset, pedCoords.z)
        
        -- Make the ped walk to the random position
        TaskGoStraightToCoord(ped, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, -1, 0.0, 0.0)

        -- Set a timer to delete the ped after 10 seconds
        CreateThread(function()
            Wait(10000) -- Wait 10 seconds
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end)
    end
end

-- Function to delete all delivery peds
local function deleteAllDeliveryPeds()
    for _, ped in ipairs(deliveryPeds) do
        deleteDeliveryPed(ped)
    end
    deliveryPeds = {}
end

-- Set GPS route back to Michael after all deliveries are done
local function setReturnGPS()
    if deliveryBlip then RemoveBlip(deliveryBlip) end 
    deliveryBlip = AddBlipForCoord(Config.MichaelCoords.x, Config.MichaelCoords.y, Config.MichaelCoords.z)
    SetBlipRoute(deliveryBlip, true)  
    SetBlipRouteColour(deliveryBlip, 5)  
end

-- Complete delivery mission and set GPS back to Michael
local function completeDeliveryMission()
    exports['ox_lib']:notify({ type = 'success', description = Translations.all_deliveries_done, duration = 5000, position = Config.NotificationPosition })
    deleteAllDeliveryPeds()
    setReturnGPS()
end

-- Spawn Michael and set up interaction
local function spawnMichael()
    RequestModel(Config.MichaelModel)
    while not HasModelLoaded(Config.MichaelModel) do Wait(0) end
    michaelNPC = CreatePed(4, Config.MichaelHash, Config.MichaelCoords.x, Config.MichaelCoords.y, Config.MichaelCoords.z, Config.MichaelHeading, false, true)
    FreezeEntityPosition(michaelNPC, true)
    SetEntityInvincible(michaelNPC, true)
    SetBlockingOfNonTemporaryEvents(michaelNPC, true)
    exports.ox_target:addLocalEntity(michaelNPC, {
        {
            name = 'startJob',
            label = Translations.label_talk_michael,
            icon = 'fa-solid fa-user',
            event = 'deliveries:beginMission',
            canInteract = function()
                return not isInDelivery
            end
        },
        {
            name = 'endJob',
            label = Translations.label_end_job,
            icon = 'fa-solid fa-user-slash',
            event = 'deliveries:endJob',
            canInteract = function()
                return isInDelivery
            end
        }
    })
end

-- Apply work outfit based on player's model
local function applyWorkOutfit()
    local playerPed = PlayerPedId()
    local pedModel = GetEntityModel(playerPed)
    local isMale = (pedModel == GetHashKey("mp_m_freemode_01"))
    local outfit = Config.Outfit[isMale and 'Male' or 'Female']
    if outfit then
        SetPedComponentVariation(playerPed, 11, outfit.torso.drawable, outfit.torso.texture, 2)
        SetPedComponentVariation(playerPed, 4, outfit.legs.drawable, outfit.legs.texture, 2)
        SetPedComponentVariation(playerPed, 6, outfit.shoes.drawable, outfit.shoes.texture, 2)
        SetPedComponentVariation(playerPed, 8, outfit.top.drawable, outfit.top.texture, 2)
        SetPedComponentVariation(playerPed, 3, outfit.arms.drawable, outfit.arms.texture, 2)
    else
        print("kt-deliveries: Error: outfit not found.")
    end
end


-- Save player's original outfit for later restoration
local function savePlayerOutfit()
    local playerPed = PlayerPedId()
    playerOriginalOutfit = {
        torso = { drawable = GetPedDrawableVariation(playerPed, 11), texture = GetPedTextureVariation(playerPed, 11) },
        legs = { drawable = GetPedDrawableVariation(playerPed, 4), texture = GetPedTextureVariation(playerPed, 4) },
        shoes = { drawable = GetPedDrawableVariation(playerPed, 6), texture = GetPedTextureVariation(playerPed, 6) },
        top = { drawable = GetPedDrawableVariation(playerPed, 8), texture = GetPedTextureVariation(playerPed, 8) },
        arms = { drawable = GetPedDrawableVariation(playerPed, 3), texture = GetPedTextureVariation(playerPed, 3) }
    }
end

-- Restore player's original outfit
local function restorePlayerOutfit()
    if not playerOriginalOutfit then return end
    local playerPed = PlayerPedId()
    SetPedComponentVariation(playerPed, 11, playerOriginalOutfit.torso.drawable, playerOriginalOutfit.torso.texture, 2)
    SetPedComponentVariation(playerPed, 4, playerOriginalOutfit.legs.drawable, playerOriginalOutfit.legs.texture, 2)
    SetPedComponentVariation(playerPed, 6, playerOriginalOutfit.shoes.drawable, playerOriginalOutfit.shoes.texture, 2)
    SetPedComponentVariation(playerPed, 8, playerOriginalOutfit.top.drawable, playerOriginalOutfit.top.texture, 2)
    SetPedComponentVariation(playerPed, 3, playerOriginalOutfit.arms.drawable, playerOriginalOutfit.arms.texture, 2)

end

-- Function to check if the spawn area for the van is free
local function isSpawnAreaFree(coords, radius)
    return #lib.getNearbyVehicles(coords, radius, true) == 0
end

-- Spawn loaded delivery van
local function spawnDeliveryVan()
    -- Deduct deposit from player
    if not lib.callback.await('kt-deliveries:deductDeposit', false) then return false end

    RequestModel(Config.VanModel)
    while not HasModelLoaded(Config.VanModel) do Wait(0) end
    furgone = CreateVehicle(Config.VanModel, Config.VanSpawnCoords.x, Config.VanSpawnCoords.y, Config.VanSpawnCoords.z, Config.VanSpawnHeading, true, false)
    SetVehicleOnGroundProperly(furgone)
    SetVehicleEngineOn(furgone, false, false, false)
    exports.ox_target:addLocalEntity(furgone, {
        {
            name = 'takePackage',
            label = Translations.label_load_package,
            icon = 'fa-solid fa-box',
            event = 'deliveries:takePackage',
            canInteract = function()
                return not isHoldingPackage and currentDeliveryIndex <= Config.TotalPackages
            end
        }
    })

    if Config.Framework == "qb-core" then TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', string.gsub(GetVehicleNumberPlateText(furgone), '^%s*(.-)%s*$', '%1'), true) end -- for qb only
    return true
end

-- Start the next delivery by updating the current location
local function startNextDelivery()
    if currentDeliveryIndex <= Config.TotalPackages then
        local deliveryLocation = Config.DeliveryLocations[currentDeliveryIndex]

        if deliveryBlip then RemoveBlip(deliveryBlip) end
        deliveryBlip = AddBlipForCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z)
        SetBlipRoute(deliveryBlip, true)

        exports['ox_lib']:notify({
            type = 'info',
            description = Translations.go_to_next_delivery,
            duration = 5000,
            position = Config.NotificationPosition
        })

        spawnDeliveryPed(deliveryLocation)
    else
        completeDeliveryMission()
    end
end

-- Start the delivery mission
RegisterNetEvent('deliveries:beginMission', function()
    if isInDelivery then 
        exports['ox_lib']:notify({ type = 'error', description = Translations.already_in_service, duration = 5000, position = Config.NotificationPosition })
        return
    end

    if not isSpawnAreaFree(Config.VanSpawnCoords, 6.0) then
        exports['ox_lib']:notify({ type = 'error', description = Translations.area_occupied, duration = 5000, position = Config.NotificationPosition })
        return
    end

    if not spawnDeliveryVan() then
        exports['ox_lib']:notify({ type = 'error', description = Translations.not_enough_money, duration = 5000, position = Config.NotificationPosition })
        return
    end

    exports['ox_lib']:notify({ type = 'info', description = Translations.start_job, duration = 5000, position = Config.NotificationPosition })

    savePlayerOutfit()
    applyWorkOutfit()

    isInDelivery = true
    startNextDelivery()
end)

-- Take a package from the van
RegisterNetEvent('deliveries:takePackage', function()
    if isInDelivery and not isHoldingPackage then
        if currentDeliveryIndex > Config.TotalPackages then
            exports['ox_lib']:notify({ type = 'error', description = Translations.no_more_packages, duration = 5000, position = Config.NotificationPosition })
            return
        end
        deliveryStartTime = GetGameTimer()
        attachPackageToPlayer()
    end
end)

-- Drop off package at the delivery location
RegisterNetEvent('deliveries:dropOffPackage', function()
    if isHoldingPackage then
        local timeTaken = GetGameTimer() - deliveryStartTime
        local payment = math.random(Config.RewardMin, Config.RewardMax)
        if timeTaken > Config.MaxDeliveryTime then
            payment = payment * (Config.ReducedPaymentPercentage / 100)
            exports['ox_lib']:notify({ type = 'warning', description = Translations.package_late_warning, duration = 5000, position = Config.NotificationPosition })
        end
        exports['ox_lib']:progressBar({ duration = 2000, label = Translations.load_package, useWhileDead = false, canCancel = false, disable = { move = true, car = true } })
        TriggerServerEvent('kt-deliveries:riceviPagamento', payment)
        isHoldingPackage = false
        ClearPedTasks(PlayerPedId())
        ExecuteCommand("e c")
        deleteDeliveryPed(deliveryPeds[currentDeliveryIndex])
        currentDeliveryIndex = currentDeliveryIndex + 1
        startNextDelivery()
    end
end)

-- End job and restore player's original outfit
RegisterNetEvent('deliveries:endJob', function()
    if currentDeliveryIndex > Config.TotalPackages then
        exports['ox_lib']:notify({ type = 'success', description = Translations.thank_you_message, duration = 7000, position = Config.NotificationPosition })
    end

    restorePlayerOutfit()
    exports['ox_lib']:notify({ type = 'info', description = Translations.job_finished, duration = 5000, position = Config.NotificationPosition })
    if DoesEntityExist(furgone) then DeleteEntity(furgone) end
    if deliveryBlip then RemoveBlip(deliveryBlip) end
    deleteAllDeliveryPeds()
    isInDelivery = false
    currentDeliveryIndex = 1

    -- Return the deposit when job ends
    TriggerServerEvent('kt-deliveries:returnDeposit')
end)

-- At startup, spawn Michael
CreateThread(function()
    spawnMichael()
end)
