Folder structure should be serverFolderName/server-data and in the serverFolderName download the latest recomended artifacts file from fivem and dropp everything you downloaded into the serverFolderName next to server-data. Download mariadb and hedisql and setup maria db. Get a license key in the server cfg and set the myssql connection string in server cfg to what you have. Launch the sql file in server-data in hedi. One creates a database and one does not. Use either that will work for you. You also need to edit the runmariaserver.bat and start.bat and add your folder location path. Name the database name to es_extended. Also make sure to use the latest artifacts files.



Things to add example webhooks etc:
    * Look in the screen-shot basic, motel script, npwd, esx-npwd script for any other webhooks needed

    * Other known places:
        * nui-blocker/server/server.lua 1 line -- Webhook
        * nui-blocker/server/server.lua 21 line on the avatar_url = "" -- Img

        * es_extended/config.logs.lua -- Webhook
        * es_extended/server/functions.lua 372 line and 403 -- Img

        * esx_property/config.lua 62 line -- Webhook
        * esx_property/server/main.lua 21 line -- Img

        * Ricky-Report/server/configServer.lua -- Webhook and discord token



The errors img you see and stuff in notes.txt that is inside of the dev folder is not important everything works it's just stuff you can fix if you can and want.



!OBS if you get some database errors for pefcl or player_outfits i changed COLLATE=utf8mb4_unicode_ci in the Serverdatabase.sql from COLLATE=utf8mb4_uca1400_ai_ci to COLLATE=utf8mb4_unicode_ci because it give an error not importing them

If any errors with renzu motel or problems i might delete data wrong the data that was on them before in renzy_motels in database was

hotelmodern3
[{"lock":true,"players":{"char1:35b6bbf1382290f92ead212e72f976ee99b6b4bc":{"duration":1735565272,"name":"Olof Henric"}}},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true}]

pinkcage
[{"lock":true,"players":{"char1:35b6bbf1382290f92ead212e72f976ee99b6b4bc":{"name":"Peter Stephen","duration":1735543785.0}}},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]},{"lock":true,"players":[]}]

yacht
[{"lock":true,"players":{"char1:35b6bbf1382290f92ead212e72f976ee99b6b4bc":{"name":"Olof Henric","duration":1735566522}}},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true}]

sandymotel
[{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true},{"players":[],"lock":true}]