--[[ 
  qb-gangcrafting
  Um sistema de crafting para gangues no QBCore
  
  Desenvolvido por: Guilherme Riguitti
  GitHub: https://github.com/GuilhermeRiguitti
]]--

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Guilherme Riguitti'
description 'Sistema de crafting para gangues no QBCore'
version '1.0.0'

repository 'https://github.com/GuilhermeRiguitti'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
    'shared/shared.lua'
}
client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua'
}

lua54 'yes'

dependencies {
    'qb-core',
    'qb-target',
    'qb-menu',
    'qb-input'
}
