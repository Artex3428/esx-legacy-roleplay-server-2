Citizen.CreateThread(function()
    ESX.PlayerData = ESX.GetPlayerData()
    SpawnNPC()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        exports['artex-3dtextui']:StartText3d("Pack", true, {46}, "Press [~g~E~w~] to take starter pack", vector3(Config.TextCoords.x, Config.TextCoords.y, Config.TextCoords.z), 3.0, 1.0, false, false, function(pressedKey)
            if pressedKey == 46 then
                ESX.TriggerServerCallback('apx_starterpack:server:checkIfUsed', function(hasChecked)
                    if hasChecked then
                        ESX.ShowNotification('You have already received your pack')
                        Citizen.Wait(50000)
                    else
                        Menu()
                    end
                end)
            end
        end)
    end
end)