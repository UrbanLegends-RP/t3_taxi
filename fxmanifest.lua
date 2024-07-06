fx_version 'cerulean'
game 'gta5'

author 'T3'
description 'T3 Taxi Job Script'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/css/light-style.css',
    'html/css/dark-style.css',
    'html/css/bootstrap-night.css',
    'html/panel.js'
}

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}
