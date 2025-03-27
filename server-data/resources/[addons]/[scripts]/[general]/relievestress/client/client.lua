local animDict = "rcmcollect_paperleadinout@"
local animName = "meditiate_idle"

RegisterCommand("meditate", function ()
	local ped = PlayerPedId()
	RequestAnimDict(animDict)
	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(0)
	end

	TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
	SetEntityCollision(ped, false, true)
	FreezeEntityPosition(ped, true)
	Citizen.Wait(9000)

	ESX.ShowNotification("Feeling more relaxed.", "success", 3000)
	TriggerServerEvent('hud:server:RelieveStress', 40)

	ClearPedTasks(ped)
	SetEntityCollision(ped, true, true)
	FreezeEntityPosition(ped, false)
end)