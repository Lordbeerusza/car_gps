fx_version 'cerulean'
game 'gta5'

author 'Lordbeerusza'
description 'Standalone Live Vehicle Tracker System'
version '2.0.0'

-- Ensure qb-core and oxmysql load before your script
dependencies {
    'qb-core',
    'oxmysql'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}
