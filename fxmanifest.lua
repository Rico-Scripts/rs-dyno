fx_version 'cerulean'
game 'gta5'
author 'Rico Scripts'
description 'Standalone motorcycle dyno for Moto Workshop'
version '2.0.0'
lua54 'yes'
ui_page 'nui/index.html'
shared_scripts { '@ox_lib/init.lua', 'config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
files { 'nui/index.html', 'nui/style.css', 'nui/app.js' }
dependencies { 'rs-bikemechanic', 'ox_lib', 'ox_target', 'oxmysql' }
