-- Starting Functions --

SpawnNPC = function()
    Citizen.CreateThread(function()

        RequestModel(GetHashKey(Config.Ped))
        while not HasModelLoaded(GetHashKey(Config.Ped)) do
            Wait(1)
        end
        CreateNPC()
    end)
end

CreateNPC = function()
    created_ped = CreatePed(5, GetHashKey(Config.Ped) , Config.Coords.x, Config.Coords.y, Config.Coords.z, Config.Coords.rotation, false, true)
    FreezeEntityPosition(created_ped, true)
    SetEntityInvincible(created_ped, true)
    SetBlockingOfNonTemporaryEvents(created_ped, true)
    TaskStartScenarioInPlace(created_ped, Config.PedAnim, 0, true)
end

Menu = function()
    if Config.UseMenuDefault then
        SetCursorLocation(0.85, 0.5)
        local elements = {
            {unselectable = true, icon = "fas fa-user", title = "Starter Pack"},
            {icon = "fas fa-check ", title = "Accept Reward", value = "accept"},
            {icon = "fas fa-times-circle ", title = "Decline", value = "decline"},
        }

        ESX.OpenContext("right", elements, function(menu,element)
            if element.value == "accept" then
                TriggerServerEvent("apx_starterpack:server:markAsUsed")
            elseif element.value == "decline" then
                ESX.CloseContext()
            end
        end)
    elseif Config.UseContext then
        local data = {}
        table.insert(data, {text = "Accept Reward", toDo = [[ TriggerEvent("esx:showNotification", "You claimed your reward") TriggerServerEvent("apx_starterpack:server:markAsUsed")  SetFollowPedCamViewMode(1) FreezeEntityPosition(PlayerPedId(), false)]]})
        table.insert(data, {text = "Decline", toDo = [[SetFollowPedCamViewMode(1) FreezeEntityPosition(PlayerPedId(), false) TriggerEvent("guille_cont:close")]]})
        TriggerEvent("guille_cont:client:open", "Starter Pack", data, false)
    end
end