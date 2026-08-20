fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'jms_crafting'
author 'JuiceMan Studios'
description 'ESX + Overextended crafting system'
version '0.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/items.lua',
    'shared/locales.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/bridge_esx.lua',
    'server/database.lua',
    'server/progression.lua',
    'server/blueprints.lua',
    'server/crafting.lua',
    'server/benches.lua',
    'server/portable_benches.lua',
    'server/admin.lua',
    'server/commands.lua',
    'server/exports.lua'
}

client_scripts {
    'client/main.lua',
    'client/benches.lua',
    'client/crafting.lua',
    'client/placement.lua',
    'client/admin.lua',
    'client/nui.lua'
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*'
}

dependencies {
    'ox_lib',
    'oxmysql',
    'ox_inventory',
    'es_extended'
}
