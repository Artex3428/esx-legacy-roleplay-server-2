Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if DoesEntityExist(veh) and not IsEntityDead(veh) then
            local model = GetEntityModel(veh)
            local roll = GetEntityRoll(veh) -- Gets the roll angle of the vehicle
            
            -- Check if the vehicle is off the ground or upside down
            if not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model) then
                if IsEntityInAir(veh) or roll > 75.0 or roll < -75.0 then
                    DisableControlAction(0, 59) -- leaning left/right
                    DisableControlAction(0, 60) -- leaning up/down
                else
                    Citizen.Wait(1500)
                end
            else
                Citizen.Wait(1500)
            end
        else
            Citizen.Wait(1500)
        end
    end
end)

RegisterCommand("flipvehicle", function()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local closestVehicle = nil
    local closestDistance = 10.0 -- Max distance to find vehicles

    for vehicle in EnumerateVehicles() do
        local vehiclePos = GetEntityCoords(vehicle)
        local distance = #(playerPos - vehiclePos)
        local roll = GetEntityRoll(vehicle)

        -- Check if the vehicle is upside down and within the distance
        if roll > 75.0 or roll < -75.0 then
            if distance < closestDistance then
                TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)

                -- Wait for 5 seconds to simulate the animation duration
                Citizen.Wait(5000)
    
                -- Clear the animation
                ClearPedTasksImmediately(playerPed)
                closestDistance = distance
                closestVehicle = vehicle
            end
        end
    end

    if closestVehicle then
        -- Flip the vehicle upright
        SetEntityRotation(closestVehicle, 0.0, 0.0, GetEntityHeading(closestVehicle), 2, true)
        SetVehicleOnGroundProperly(closestVehicle)
    end
end)

-- Function to enumerate all vehicles in the world
function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        if not handle or not vehicle then
            EndFindVehicle(handle)
            return
        end

        local success
        repeat
            coroutine.yield(vehicle)
            success, vehicle = FindNextVehicle(handle)
        until not success

        EndFindVehicle(handle)
    end)
end