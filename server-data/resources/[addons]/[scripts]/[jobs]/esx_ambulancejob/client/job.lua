local isBusy, deadPlayers, deadPlayerBlips, isOnDuty = false, {}, {}, false
isInShopMenu = false
local playerInService = false

exports('getIsInServiceAmbulance', function()
    return playerInService
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)


function OpenAmbulanceActionsMenu()
	local elements = {
		{ unselectable = true, icon = "fas fa-shirt", title = TranslateCap('ambulance') },
		{ icon = "fas fa-shirt", title = TranslateCap('cloakroom'), value = 'cloakroom' }
	}

	if Config.EnablePlayerManagement and ESX.PlayerData.job.grade_name == 'boss' then
		elements[#elements + 1] = {
			icon = "fas fa-ambulance",
			title = TranslateCap('boss_actions'),
			value = 'boss_actions'
		}
	end

	ESX.OpenContext("right", elements, function(menu, element)
		if element.value == 'cloakroom' then
			OpenCloakroomMenu()
			SetCursorLocation(0.85, 0.5)
		elseif element.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'ambulance', function(data, menu)
				menu.close()
			end, { wash = false })
		end
	end)
end

function OpenMobileAmbulanceActionsMenu()
	local elements = {
		{ unselectable = true, icon = "fas fa-ambulance", title = TranslateCap('ambulance') },
		{ icon = "fas fa-syringe", title = TranslateCap('ems_menu_revive'), value = "revive" },
		{ icon = "fas fa-bandage", title = TranslateCap('ems_menu_small'), value = "small" },
		{ icon = "fas fa-bandage", title = TranslateCap('ems_menu_big'), value = "big" },
		{ icon = "fas fa-car", title = TranslateCap('ems_menu_putincar'), value = "put_in_vehicle" },
		{ icon = "fas fa-syringe", title = TranslateCap('ems_menu_search'), value = "search" },
	}

	ESX.OpenContext("right", elements, function(menu, element)
		ESX.OpenContext("right", elements, function(menu, element)
			if isBusy then return end
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

			if element2.value == 'search' then
				TriggerServerEvent('esx_ambulancejob:svsearch')
			elseif closestPlayer == -1 or closestDistance > 1.0 then
				ESX.ShowNotification(TranslateCap('no_players'))
			else
				if element2.value == 'revive' then
					revivePlayer(closestPlayer)
				elseif element2.value == 'small' then
					ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
						if quantity > 0 then
							local closestPlayerPed = GetPlayerPed(closestPlayer)
							local health = GetEntityHealth(closestPlayerPed)

							if health > 0 then
								local playerPed = PlayerPedId()

								isBusy = true
								ESX.ShowNotification(TranslateCap('heal_inprogress'))
								TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
								Wait(10000)
								ClearPedTasks(playerPed)

								TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
								TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'small')
								ESX.ShowNotification(TranslateCap('heal_complete', GetPlayerName(closestPlayer)))
								isBusy = false
							else
								ESX.ShowNotification(TranslateCap('player_not_conscious'))
							end
						else
							ESX.ShowNotification(TranslateCap('not_enough_bandage'))
						end
					end, 'bandage')

				elseif element2.value == 'big' then
					ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
						if quantity > 0 then
							local closestPlayerPed = GetPlayerPed(closestPlayer)
							local health = GetEntityHealth(closestPlayerPed)

							if health > 0 then
								local playerPed = PlayerPedId()

								isBusy = true
								ESX.ShowNotification(TranslateCap('heal_inprogress'))
								TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
								Wait(10000)
								ClearPedTasks(playerPed)

								TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
								TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(closestPlayer), 'big')
								ESX.ShowNotification(TranslateCap('heal_complete', GetPlayerName(closestPlayer)))
								isBusy = false
							else
								ESX.ShowNotification(TranslateCap('player_not_conscious'))
							end
						else
							ESX.ShowNotification(TranslateCap('not_enough_medikit'))
						end
					end, 'medikit')
				elseif element2.value == 'put_in_vehicle' then
					TriggerServerEvent('esx_ambulancejob:putInVehicle', GetPlayerServerId(closestPlayer))
				end
			end
		end)
	end)
end

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)

		for hospitalNum, hospital in pairs(Config.Hospitals) do
			-- Fast Travels (Prompt)
			for k, v in ipairs(hospital.FastTravelsPrompt) do
				exports['artex-3dtextui']:StartText3d("Elevator", true, {46}, "Press [~g~E~w~] to use elevator", v.From, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						FastTravel(v.To.coords, v.To.heading)
					end
				end)
			end
		end
	end
end)

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
			if not Config.EnableESXService then
				exports['artex-3dtextui']:StartText3d("Ambulance Actions", true, {46}, "Press [~g~E~w~] to open ambulance actions", vector3(Config.Hospitals.CentralLosSantos.AmbulanceActions.Pos.x, Config.Hospitals.CentralLosSantos.AmbulanceActions.Pos.y, Config.Hospitals.CentralLosSantos.AmbulanceActions.Pos.z), 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenAmbulanceActionsMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)

				exports['artex-3dtextui']:StartText3d("Pharmacy", true, {46}, "Press [~g~E~w~] to open pharmacy", vector3(Config.Hospitals.CentralLosSantos.Pharmacies.Pos.x, Config.Hospitals.CentralLosSantos.Pharmacies.Pos.y, Config.Hospitals.CentralLosSantos.Pharmacies.Pos.z), 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenPharmacyMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)

				exports['artex-3dtextui']:StartText3d("Ambulance Garage", true, {46}, "Press [~g~E~w~] to open ambulance garage", vector3(Config.Hospitals.CentralLosSantos.Vehicles.Spawner.x, Config.Hospitals.CentralLosSantos.Vehicles.Spawner.y, Config.Hospitals.CentralLosSantos.Vehicles.Spawner.z), 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						for k, v in ipairs(Config.Hospitals.CentralLosSantos.Vehicles) do
							currentPartNum1 = k
						end
						OpenVehicleSpawnerMenu('car', "CentralLosSantos", 'Vehicles', 1)
						SetCursorLocation(0.85, 0.5)
					end
				end)

				exports['artex-3dtextui']:StartText3d("Helicopter Garage", true, {46}, "Press [~g~E~w~] to open helicopter garage", vector3(Config.Hospitals.CentralLosSantos.Helicopters.Spawner.x, Config.Hospitals.CentralLosSantos.Helicopters.Spawner.y, Config.Hospitals.CentralLosSantos.Helicopters.Spawner.z), 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						for k, v in ipairs(Config.Hospitals.CentralLosSantos.Helicopters) do
							currentPartNum2 = k
						end
						OpenVehicleSpawnerMenu('helicopter', "CentralLosSantos", 'Helicopters', 1)
						SetCursorLocation(0.85, 0.5)
					end
				end)
			elseif playerInService then
				exports['artex-3dtextui']:StartText3d("Ambulance Actions", true, {46}, "Press [~g~E~w~] to open ambulance actions", vector3(Config.Hospitals.CentralLosSantos.AmbulanceActions.Pos.x, Config.Hospitals.CentralLosSantos.AmbulanceActions.Pos.y, Config.Hospitals.CentralLosSantos.AmbulanceActions.Pos.z), 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenAmbulanceActionsMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)

				exports['artex-3dtextui']:StartText3d("Pharmacy", true, {46}, "Press [~g~E~w~] to open pharmacy", vector3(Config.Hospitals.CentralLosSantos.Pharmacies.Pos.x, Config.Hospitals.CentralLosSantos.Pharmacies.Pos.y, Config.Hospitals.CentralLosSantos.Pharmacies.Pos.z), 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenPharmacyMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)

				exports['artex-3dtextui']:StartText3d("Ambulance Garage", true, {46}, "Press [~g~E~w~] to open ambulance garage", vector3(Config.Hospitals.CentralLosSantos.Vehicles.Spawner.x, Config.Hospitals.CentralLosSantos.Vehicles.Spawner.y, Config.Hospitals.CentralLosSantos.Vehicles.Spawner.z), 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenVehicleSpawnerMenu('car', "CentralLosSantos", 'Vehicles', 1)
						SetCursorLocation(0.85, 0.5)
					end
				end)

				exports['artex-3dtextui']:StartText3d("Helicopter Garage", true, {46}, "Press [~g~E~w~] to open helicopter garage", vector3(Config.Hospitals.CentralLosSantos.Helicopters.Spawner.x, Config.Hospitals.CentralLosSantos.Helicopters.Spawner.y, Config.Hospitals.CentralLosSantos.Helicopters.Spawner.z), 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenVehicleSpawnerMenu('helicopter', "CentralLosSantos", 'Helicopters', 1)
						SetCursorLocation(0.85, 0.5)
					end
				end)
			else
				Citizen.Wait(500)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

CreateThread(function ()
    while true do
        Wait(0)
        if Config.EnableESXService then
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' then
                exports['artex-3dtextui']:StartText3d("Service", true, {46}, "Press [~g~E~w~] to toggle service", vector3(262.08709716796875, -1360.056640625, 24.53777885437011), 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						if not playerInService then
							-- Check if player is already in service
							ESX.TriggerServerCallback('esx_service:isInService', function(isInService)
	
									if Config.MaxInService ~= -1 then
										ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)
											if not canTakeService then
												ESX.ShowNotification(TranslateCap('service_max', inServiceCount, maxInService))
											else
												playerInService = true
	
												local notification = {
													title    = TranslateCap('service_anonunce'),
													subject  = '',
													msg      = TranslateCap('service_in_announce', GetPlayerName(PlayerId())),
													iconType = 1
												}
	
												TriggerServerEvent('esx_service:notifyAllInService', notification, 'ambulance')
												ESX.ShowNotification(TranslateCap('service_in'))
											end
										end, 'ambulance')
									else
										playerInService = true
	
										local notification = {
											title    = TranslateCap('service_anonunce'),
											subject  = '',
											msg      = TranslateCap('service_in_announce', GetPlayerName(PlayerId())),
											iconType = 1
										}
	
										TriggerServerEvent('esx_service:notifyAllInService', notification, 'ambulance')
										ESX.ShowNotification(TranslateCap('service_in'))
									end
							end, 'ambulance')
						else
							playerInService = false
	
							local notification = {
								title    = TranslateCap('service_anonunce'),
								subject  = '',
								msg      = TranslateCap('service_out_announce', GetPlayerName(PlayerId())),
								iconType = 1
							}
	
							TriggerServerEvent('esx_service:notifyAllInService', notification, 'ambulance')
							TriggerServerEvent('esx_service:disableService', 'ambulance')
							ESX.ShowNotification(TranslateCap('service_out'))
						end
					end
                end)
            else
                Wait(1500)
            end
        else
            Wait(1500)
        end
    end
end)

function revivePlayer(closestPlayer)
	isBusy = true

	ESX.TriggerServerCallback('esx_ambulancejob:getItemAmount', function(quantity)
		if quantity > 0 then
			local closestPlayerPed = GetPlayerPed(closestPlayer)

			if IsPedDeadOrDying(closestPlayerPed, 1) then
				local playerPed = PlayerPedId()
				local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
				ESX.ShowNotification(TranslateCap('revive_inprogress'))

				for i = 1, 15 do
					Wait(900)

					ESX.Streaming.RequestAnimDict(lib, function()
						TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
						RemoveAnimDict(lib)
					end)
				end

				TriggerServerEvent('esx_ambulancejob:removeItem', 'medikit')
				TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(closestPlayer))
			else
				ESX.ShowNotification(TranslateCap('player_not_unconscious'))
			end
		else
			ESX.ShowNotification(TranslateCap('not_enough_medikit'))
		end
		isBusy = false
	end, 'medikit')
end

function FastTravel(coords, heading)
	local playerPed = PlayerPedId()

	DoScreenFadeOut(800)

	while not IsScreenFadedOut() do
		Wait(500)
	end

	ESX.Game.Teleport(playerPed, coords, function()
		DoScreenFadeIn(800)

		if heading then
			SetEntityHeading(playerPed, heading)
		end
	end)
end

RegisterCommand("ambulance", function(src)
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'ambulance' and not ESX.PlayerData.dead then
		if not Config.EnableESXService then
			OpenMobileAmbulanceActionsMenu()
			SetCursorLocation(0.85, 0.5)
		elseif playerInService then
			OpenMobileAmbulanceActionsMenu()
			SetCursorLocation(0.85, 0.5)
		else
			ESX.ShowNotification(TranslateCap('service_not'))
		end
	end
end)

RegisterKeyMapping("ambulance", "Open Ambulance Actions Menu", "keyboard", "F6")

RegisterNetEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function()
	local playerPed = PlayerPedId()
	local vehicle, distance = ESX.Game.GetClosestVehicle()

	if vehicle and distance < 5 then
		local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

		for i = maxSeats - 1, 0, -1 do
			if IsVehicleSeatFree(vehicle, i) then
				freeSeat = i
				break
			end
		end

		if freeSeat then
			TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
		end
	end
end)

function OpenCloakroomMenu()
	local elements = {
		{ unselectable = true, icon = "fas fa-shirt", title = TranslateCap('cloakroom') },
		{ icon = "fas fa-shirt", title = TranslateCap('ems_clothes_civil'), value = "citizen_wear" },
		{ icon = "fas fa-shirt", title = TranslateCap('ems_clothes_ems'), value = "ambulance_wear" },
	}

	ESX.OpenContext("right", elements, function(menu, element)
		if element.value == "citizen_wear" then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('skinchanger:loadSkin', skin)
				isOnDuty = false

				for playerId, v in pairs(deadPlayerBlips) do
					RemoveBlip(v)
					deadPlayerBlips[playerId] = nil
				end
				deadPlayers = {}
				if Config.Debug then
					print("[^2INFO^7] Off Duty")
				end
			end)
		elseif element.value == "ambulance_wear" then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
				else
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
				end

				isOnDuty = true
				ESX.TriggerServerCallback('esx_ambulancejob:getDeadPlayers', function(_deadPlayers)
					TriggerEvent('esx_ambulancejob:setDeadPlayers', _deadPlayers)
				end)
				if Config.Debug then
					print("[^2INFO^7] Player Sex |^5" .. tostring(skin.sex) .. "^7")
					print("[^2INFO^7] On Duty")
				end
			end)
		end
	end)
end

function OpenPharmacyMenu()
	local elements = {
		{ unselectable = true, icon = "fas fa-pills", title = TranslateCap('pharmacy_menu_title') }
	}

	for k, v in pairs(Config.PharmacyItems) do
		elements[#elements + 1] = {
			icon = "fas fa-pills",
			title = v.title,
			item = v.item
		}
	end

	ESX.OpenContext("right", elements, function(menu, element)
		local elements2 = {
			{ unselectable = true, icon = "fas fa-pills", title = element.title },
			{ title = "Amount", input = true, inputType = "number", inputMin = 1, inputMax = 100,
				inputPlaceholder = "Amount to buy.." },
			{ icon = "fas fa-check-double", title = "Confirm", val = "confirm" }
		}

		ESX.OpenContext("right", elements2, function(menu2, element2)
			local amount = menu2.eles[2].inputValue
			if Config.Debug then
				print("[^2INFO^7] Attempting to Give Item - ^5" .. tostring(element.item) .. "^7")
			end
			TriggerServerEvent('esx_ambulancejob:giveItem', element.item, amount)
		end, function(menu)
			OpenPharmacyMenu()
		end)
	end)
end

RegisterNetEvent('esx_ambulancejob:heal')
AddEventHandler('esx_ambulancejob:heal', function(healType, quiet)
	local playerPed = PlayerPedId()
	local maxHealth = GetEntityMaxHealth(playerPed)

	if healType == 'small' then
		local health = GetEntityHealth(playerPed)
		local newHealth = math.min(maxHealth, math.floor(health + maxHealth / 8))
		SetEntityHealth(playerPed, newHealth)
	elseif healType == 'big' then
		SetEntityHealth(playerPed, maxHealth)
	end

	if Config.Debug then
		print("[^2INFO^7] Healing Player - ^5" .. tostring(healType) .. "^7")
	end
	if not quiet then
		ESX.ShowNotification(TranslateCap('healed'))
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	if isOnDuty and job.name ~= 'ambulance' then
		for playerId, v in pairs(deadPlayerBlips) do
			if Config.Debug then
				print("[^2INFO^7] Removing dead blip - ^5" .. tostring(playerId) .. "^7")
			end
			RemoveBlip(v)
			deadPlayerBlips[playerId] = nil
		end

		isOnDuty = false
	end
end)

RegisterNetEvent('esx_ambulancejob:PlayerDead')
AddEventHandler('esx_ambulancejob:PlayerDead', function(Player)
	if Config.Debug then
		print("[^2INFO^7] Player Dead | ^5" .. tostring(Player) .. "^7")
	end
	deadPlayers[Player] = "dead"
end)

RegisterNetEvent('esx_ambulancejob:PlayerNotDead')
AddEventHandler('esx_ambulancejob:PlayerNotDead', function(Player)
	if deadPlayerBlips[Player] then
		RemoveBlip(deadPlayerBlips[Player])
		deadPlayerBlips[Player] = nil
	end
	if Config.Debug then
		print("[^2INFO^7] Player Alive | ^5" .. tostring(Player) .. "^7")
	end
	deadPlayers[Player] = nil
end)

RegisterNetEvent('esx_ambulancejob:setDeadPlayers')
AddEventHandler('esx_ambulancejob:setDeadPlayers', function(_deadPlayers)
	deadPlayers = _deadPlayers

	if isOnDuty then
		for playerId, v in pairs(deadPlayerBlips) do
			RemoveBlip(v)
			deadPlayerBlips[playerId] = nil
		end

		for playerId, status in pairs(deadPlayers) do
			if Config.Debug then
				print("[^2INFO^7] Player Dead | ^5" .. tostring(playerId) .. "^7")
			end
			if status == 'distress' then
				if Config.Debug then
					print("[^2INFO^7] Creating Distress Blip for Player - ^5" .. tostring(playerId) .. "^7")
				end
				local player = GetPlayerFromServerId(playerId)
				local playerPed = GetPlayerPed(player)
				local blip = AddBlipForEntity(playerPed)

				SetBlipSprite(blip, 303)
				SetBlipColour(blip, 1)
				SetBlipFlashes(blip, true)
				SetBlipCategory(blip, 7)

				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(TranslateCap('blip_dead'))
				EndTextCommandSetBlipName(blip)

				deadPlayerBlips[playerId] = blip
			end
		end
	end
end)


RegisterNetEvent('esx_ambulancejob:PlayerDistressed')
AddEventHandler('esx_ambulancejob:PlayerDistressed', function(playerId, playerCoords)
	deadPlayers[playerId] = 'distress'

	if isOnDuty then
		if Config.Debug then
			print("[^2INFO^7] Player Distress Recived - ID:^5" .. tostring(playerId) .. "^7")
		end
		ESX.ShowNotification(TranslateCap('unconscious_found'), "error", 10000)
		deadPlayerBlips[playerId] = nil

		local blip = AddBlipForCoord(playerCoords.x, playerCoords.y, playerCoords.z)
		SetBlipSprite(blip, Config.DistressBlip.Sprite)
		SetBlipColour(blip, Config.DistressBlip.Color)
		SetBlipScale(blip, Config.DistressBlip.Scale)
		SetBlipFlashes(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(TranslateCap('blip_dead'))
		EndTextCommandSetBlipName(blip)

		deadPlayerBlips[playerId] = blip
	end
end)
