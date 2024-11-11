Config = {}

-- Specify the framework in use: 'qbcore' or 'esx'
Config.Framework = 'qbcore' -- Change to 'esx' for ESX compatibility

-- Server language
Config.Locale = 'es'

Config.NotificationPosition = 'center-right' -- Change to 'top-right', 'center-right', or any other position supported by ox_lib

-- Coordinates and settings for Michael (NPC)
Config.MichaelCoords = vector3(133.0, 96.30, 82.50) 
Config.MichaelHeading = 155.0
Config.MichaelModel = `s_m_m_postal_02`
Config.MichaelHash = 0x7367324F

-- Settings for the delivery vehicle
Config.VanModel = `boxville2`
Config.VanSpawnCoords = vector3(116.0, 95.0, 81.0)
Config.VanSpawnHeading = 250.0

-- Delivery locations
Config.DeliveryLocations = {
    vector3(318.255371, 562.251221, 154.539261),
    vector3(-17.561855, -296.779327, 45.757820),
    vector3(414.994629, -217.169327, 59.910404),
    vector3(318.100800, 562.209534, 154.538971),
    vector3(128.132416, 566.274719, 183.959518),
    vector3(-537.020874, 477.386536, 103.193657),
    vector3(-819.639160, 268.003418, 86.395882),
    vector3(-1200.346191, -156.699402, 40.085796),
    vector3(-201.075424, 186.354111, 80.324028),
    vector3(-197.631866, 85.965767, 69.756218),
    vector3(-41.386677, -58.607708, 63.659588),
    vector3(-115.948196, -372.883972, 38.039867),
    vector3(-311.021790, -278.240936, 31.716949),
    vector3(-1016.435425, -265.780640, 39.040359),
    vector3(-1555.155640, -290.246094, 48.269753),
    vector3(-1215.631104, 343.152527, 71.150002),
    vector3(-232.585388, 588.483948, 190.536240),
    vector3(-445.678833, 685.651917, 152.951141),
    vector3(-658.732178, 897.840210, 229.244034),
    vector3(-595.440186, 780.762878, 189.110886),
    vector3(-765.342163, 650.477600, 145.700150)
    -- Add more destinations as desired
}

-- Number of packages and rewards
Config.TotalPackages = 10
Config.RewardMin = 100
Config.RewardMax = 125

-- Time limit and reduced payment percentage for delayed deliveries
Config.MaxDeliveryTime = 300000       -- Max delivery time in milliseconds (5 minutes)
Config.ReducedPaymentPercentage = 50  -- Reduced payment percentage for late deliveries (50%)

-- Postman outfits for male and female peds
Config.Outfit = {
    Male = {
        torso = { component = 0, drawable = 241, texture = 0 },
        legs = { component = 0, drawable = 63, texture = 0 },
        shoes = { component = 0, drawable = 24, texture = 0 },
        top = { component = 0, drawable = 15, texture = 0 },
        arms = { component = 0, drawable = 0, texture = 0}
    },
    Female = {
        torso = { component = 0, drawable = 359, texture = 2 },
        legs = { component = 0, drawable = 129, texture = 0 },
        shoes = { component = 0, drawable = 24, texture = 0 },
        top = { component = 0, drawable = 15, texture = 0 },
        arms = { component = 0, drawable = 9, texture = 0}
    }
}
