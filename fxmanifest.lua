fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Katania'
description 'Script per consegna pacchi multilingua'
version '1.0.0'

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
    'qb-core'
}
