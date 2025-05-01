fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'QB Gang Crafting System'
version '1.0.0'
author 'QBCore Framework'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
    'shared/shared.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

dependencies {
    'qb-core',
    'qb-target',
    'qb-menu',
    'qb-input'
}
