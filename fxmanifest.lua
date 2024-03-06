fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script {
    
    '@qb-core/shared/locale.lua',
    'locales/*.lua',
    'config.lua'
}

client_script {
    
    'client/main.lua'
}
server_script {
    
    'server/main.lua'
}
