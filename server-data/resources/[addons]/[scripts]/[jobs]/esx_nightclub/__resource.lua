resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Nightclub Job'

version '1.0.0'

shared_script '@es_extended/imports.lua'

client_scripts {
  '@es_extended/locale.lua',
  'locales/en.lua',
  'locales/de.lua',
  'config.lua',
  'client/main.lua'
}

server_scripts {
  '@es_extended/locale.lua',
  'locales/en.lua',
  'locales/de.lua',
  'config.lua',
  'server/main.lua'
}
