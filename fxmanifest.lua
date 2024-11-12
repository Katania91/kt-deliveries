fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Katania'
description 'kt-deliveries: Delivery Job Script for FiveM multilanguage'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'qb-core',      -- QBCore support (required if using QBCore framework)
    -- 'es_extended', -- Uncomment if using ESX framework
    -- 'ox_core',     -- Uncomment if using OX Core framework
    -- 'qbox-core',   -- Uncomment if using Qbox framework
    -- 'nd-core'      -- Uncomment if using ND Core framework
}
