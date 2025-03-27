local ragdoll = false

RegisterKeyMapping('ragdoll', "ragdoll", 'keyboard', "U")

RegisterCommand("ragdoll", function ()
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        if ragdoll then
            ragdoll = false
        else
            ragdoll = true
			while ragdoll do
				Wait(0)
				SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
			end
        end

        if IsPlayerDead(PlayerId()) and ragdoll == true then
            ragdoll = false
        end

        if ragdoll then
            SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
        end
    end

end)