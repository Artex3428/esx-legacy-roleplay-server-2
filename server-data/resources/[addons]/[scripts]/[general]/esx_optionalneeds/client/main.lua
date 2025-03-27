local IsAlreadyDrunk = false
local DrunkLevel = -1

function Drunk(level, start)
    CreateThread(function()
        local playerPed = PlayerPedId()

        if start then
            DoScreenFadeOut(800)
            Wait(1000)
        end

        if level == 0 then
            RequestAnimSet("move_m@drunk@slightlydrunk")
            while not HasAnimSetLoaded("move_m@drunk@slightlydrunk") do
                Wait(0)
            end
            SetPedMovementClipset(playerPed, "move_m@drunk@slightlydrunk", true)
        elseif level == 1 then
            RequestAnimSet("move_m@drunk@moderatedrunk")
            while not HasAnimSetLoaded("move_m@drunk@moderatedrunk") do
                Wait(0)
            end
            SetPedMovementClipset(playerPed, "move_m@drunk@moderatedrunk", true)
        elseif level == 2 then
            RequestAnimSet("move_m@drunk@verydrunk")
            while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
                Wait(0)
            end
            SetPedMovementClipset(playerPed, "move_m@drunk@verydrunk", true)
        end

        SetTimecycleModifier("spectator5")
        SetPedMotionBlur(playerPed, true)
        SetPedIsDrunk(playerPed, true)

        if start then
            DoScreenFadeIn(800)
        end
    end)
end

function Reality()
    CreateThread(function()
        local playerPed = PlayerPedId()

        DoScreenFadeOut(800)
        Wait(1000)

        ClearTimecycleModifier()
        ResetScenarioTypesEnabled()
        ResetPedMovementClipset(playerPed, 0)
        SetPedIsDrunk(playerPed, false)
        SetPedMotionBlur(playerPed, false)

        DoScreenFadeIn(800)
    end)
end

-- Register the drunk status
AddEventHandler('esx_status:loaded', function(status)
    TriggerEvent('esx_status:registerStatus', 'drunk', 0, '#8F15A5',
        function(status)
            return status.val > 0
        end,
        function(status)
            status.remove(1500)
        end
    )
end)

-- Monitor the drunk status dynamically
CreateThread(function()
    while true do
        Wait(1000) -- Check every second

        TriggerEvent('esx_status:getStatus', 'drunk', function(status)
            if status.val > 0 then
                local start = not IsAlreadyDrunk
                local level = 0

                if status.val <= 250000 then
                    level = 0
                elseif status.val <= 500000 then
                    level = 1
                else
                    level = 2
                end

                if level ~= DrunkLevel then
                    Drunk(level, start)
                end

                IsAlreadyDrunk = true
                DrunkLevel = level
            else
                if IsAlreadyDrunk then
                    Reality()
                end

                IsAlreadyDrunk = false
                DrunkLevel = -1
            end
        end)
    end
end)