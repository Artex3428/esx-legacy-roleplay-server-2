LoadAnimDict = function(Dict)
    if not DoesAnimDictExist(Dict) then return print('message from ' .. GetInvokingResource() or GetCurrentResourceName() .. ' ' .. Dict .. ' is not a valid animation dictionary') end
    RequestAnimDict(Dict)

    while not HasAnimDictLoaded(Dict) do
        Wait(10)
    end
end

Handsup = false

RegisterKeyMapping('handsup', "handsup", 'keyboard', "X")
RegisterCommand("handsup", function ()
    local Player = PlayerPedId()
    local isProne = exports['crouch_crawl']:IsPlayerProne()
    local isCrawling = exports['crouch_crawl']:IsPlayerCrawling()

    if isProne or isCrawling then
        DisableControlAction(0, 73, true)
    else
        ClearPedTasks(Player)
    end

    if not IsControlEnabled(0, 73) then
        return
    end

    if not IsPedInAnyVehicle(Player, false) and not GetIsTaskActive(Player, 1) then
        if Handsup then
            ClearPedTasks(Player)
            test = false
            Handsup = false
            sleep = 500
        else
            LoadAnimDict('random@mugging3')
            test = true
            TaskPlayAnim(Player, 'random@mugging3', 'handsup_standing_base', 2.0, -1.0, -1, 49, 0, 0, 0, 0)
            Handsup = true
        end
    else
        ClearPedTasks(Player)
    end
end)

Citizen.CreateThread(function ()
    while true do
        local sleep = 500
        if IsPedActiveInScenario(PlayerPedId()) then
            sleep = 0
            DisableControlAction(0, 73, true)
        end
        Wait(sleep)
    end
end)