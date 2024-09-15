-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

author 'Playboii Driizzyy'
description 'Advanced QBCore Coin Reward and Shop System'
version '1.0.0'

shared_scripts {
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'qb-core',
    'qb-menu',
    'oxmysql'
}

