local HasAlreadyEnteredMarker, LastZone = false, nil
local CurrentAction, CurrentActionMsg, CurrentActionData = nil, '', {}
local CurrentlyTowedVehicle, Blips, NPCOnJob, NPCTargetTowable, NPCTargetTowableZone = nil, {}, false, nil, nil
local NPCHasSpawnedTowable, NPCLastCancel, NPCHasBeenNextToTowable, NPCTargetDeleterZone = false, GetGameTimer() - 5 * 60000, false, false
local isDead, isBusy = false, false
local playerInService = false
PlacedObjects = {}

function SelectRandomTowable()
	local index = GetRandomIntInRange(1, #Config.Towables)

	for k, v in pairs(Config.Zones) do
		if v.Pos.x == Config.Towables[index].x and v.Pos.y == Config.Towables[index].y and v.Pos.z == Config.Towables[index].z then
			return k
		end
	end
end

exports('getIsInServiceMechanic', function()
    return playerInService
end)

CreateThread(function ()
    while true do
        Wait(0)
        if Config.EnableESXService then
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
                exports['artex-3dtextui']:StartText3d("Service", true, {46}, "Press [~g~E~w~] to toggle service", vector3(-343.13739013671875, -122.3833999633789, 39.00960540771484), 3.0, 1.0, false, false, function(pressedKey)
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
	
												TriggerServerEvent('esx_service:notifyAllInService', notification, 'mechanic')
												ESX.ShowNotification(TranslateCap('service_in'))
											end
										end, 'mechanic')
									else
										playerInService = true
	
										local notification = {
											title    = TranslateCap('service_anonunce'),
											subject  = '',
											msg      = TranslateCap('service_in_announce', GetPlayerName(PlayerId())),
											iconType = 1
										}
	
										TriggerServerEvent('esx_service:notifyAllInService', notification, 'mechanic')
										ESX.ShowNotification(TranslateCap('service_in'))
									end
							end, 'mechanic')
						else
							playerInService = false
	
							local notification = {
								title    = TranslateCap('service_anonunce'),
								subject  = '',
								msg      = TranslateCap('service_out_announce', GetPlayerName(PlayerId())),
								iconType = 1
							}
	
							TriggerServerEvent('esx_service:notifyAllInService', notification, 'mechanic')
							TriggerServerEvent('esx_service:disableService', 'mechanic')
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

function StartNPCJob()
	NPCOnJob = true

	NPCTargetTowableZone = SelectRandomTowable()
	local zone = Config[NPCTargetTowableZone]

	Blips['NPCTargetTowableZone'] = AddBlipForCoord(zone.Pos.x, zone.Pos.y, zone.Pos.z)
	SetBlipRoute(Blips['NPCTargetTowableZone'], true)

	ESX.ShowNotification(TranslateCap('drive_to_indicated'))
end

function StopNPCJob(cancel)
	if Blips['NPCTargetTowableZone'] then
		RemoveBlip(Blips['NPCTargetTowableZone'])
		Blips['NPCTargetTowableZone'] = nil
	end

	if Blips['NPCDelivery'] then
		RemoveBlip(Blips['NPCDelivery'])
		Blips['NPCDelivery'] = nil
	end

	Config.Zones.VehicleDelivery.Type = -1

	NPCOnJob                          = false
	NPCTargetTowable                  = nil
	NPCTargetTowableZone              = nil
	NPCHasSpawnedTowable              = false
	NPCHasBeenNextToTowable           = false

	if cancel then
		ESX.ShowNotification(TranslateCap('mission_canceled'), "error")
	else
		--TriggerServerEvent('esx_mechanicjob:onNPCJobCompleted')
	end
end

function OpenMechanicActionsMenu()
	local elements = {
		{ unselectable = true,   icon = "fas fa-gear",                   title = TranslateCap('mechanic') },
		{ icon = "fas fa-car",   title = TranslateCap('vehicle_list'),   value = 'vehicle_list' },
		{ icon = "fas fa-shirt", title = TranslateCap('work_wear'),      value = 'cloakroom' },
		{ icon = "fas fa-shirt", title = TranslateCap('civ_wear'),       value = 'cloakroom2' },
		{ icon = "fas fa-box",   title = TranslateCap('deposit_stock'),  value = 'put_stock' },
		{ icon = "fas fa-box",   title = TranslateCap('withdraw_stock'), value = 'get_stock' },
		{icon = "fas fas fa-cubes", title = "Get key", value = "key_mechanic"},
	}

	if Config.EnablePlayerManagement and ESX.PlayerData.job and ESX.PlayerData.job.grade_name == 'boss' then
		elements[#elements + 1] = {
			icon = 'fas fa-boss',
			title = TranslateCap('boss_actions'),
			value = 'boss_actions'
		}
	end

	ESX.OpenContext("right", elements, function(menu, element)
		if element.value == 'vehicle_list' then
			if Config.EnableSocietyOwnedVehicles then
				local elements2 = {
					{ unselectable = true, icon = "fas fa-car", title = TranslateCap('service_vehicle') }
				}

				ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(vehicles)
					for i = 1, #vehicles, 1 do
						elements2[#elements2 + 1] = {
							icon = 'fas fa-car',
							title = GetDisplayNameFromVehicleModel(vehicles[i].model) .. ' [' .. vehicles[i].plate .. ']',
							value = vehicles[i]
						}
					end

					ESX.OpenContext("right", elements2, function(menu2, element2)
						ESX.CloseContext()
						local vehicleProps = element2.value

						ESX.Game.SpawnVehicle(vehicleProps.model, Config.Zones.VehicleSpawnPoint.Pos, 270.0,
							function(vehicle)
								ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
								local playerPed = PlayerPedId()
								TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
							end)

						TriggerServerEvent('esx_society:removeVehicleFromGarage', 'mechanic', vehicleProps)
					end)
				end, 'mechanic')
			else
				local elements2 = {
					{ unselectable = true,   icon = "fas fa-car",               title = TranslateCap('service_vehicle') },
					{ icon = "fas fa-truck", title = TranslateCap('flat_bed'),  value = 'flatbed' },
					{ icon = "fas fa-truck", title = TranslateCap('tow_truck2'), value = 'towtruck2' },
					{ icon = "fas fa-truck", title = TranslateCap('tow_truck'), value = 'towtruck' },
				}

				if Config.EnablePlayerManagement and ESX.PlayerData.job and (ESX.PlayerData.job.grade_name == 'boss' or ESX.PlayerData.job.grade_name == 'chief' or ESX.PlayerData.job.grade_name == 'experimente') then
					elements2[#elements2 + 1] = {
						icon = 'fas fa-truck',
						title = 'Slamvan',
						value = 'slamvan3'
					}
				end

				ESX.OpenContext("right", elements2, function(menu2, element2)
					if Config.MaxInService == -1 then
						ESX.CloseContext()
						ESX.Game.SpawnVehicle(element2.value, Config.Zones.VehicleSpawnPoint.Pos, 90.0, function(vehicle)
							local playerPed = PlayerPedId()
							TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
						end)
					else
						ESX.TriggerServerCallback('esx_service:enableService',
							function(canTakeService, maxInService, inServiceCount)
								if canTakeService then
									ESX.CloseContext()
									ESX.Game.SpawnVehicle(element2.value, Config.Zones.VehicleSpawnPoint.Pos, 90.0,
										function(vehicle)
											local playerPed = PlayerPedId()
											TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
										end)
								else
									ESX.ShowNotification(TranslateCap('service_full') ..
										inServiceCount .. '/' .. maxInService)
								end
							end, 'mechanic')
					end
				end)
			end
		elseif element.value == 'cloakroom' then
			ESX.CloseContext()
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_male)
				else
					TriggerEvent('skinchanger:loadClothes', skin, jobSkin.skin_female)
				end
			end)
		elseif element.value == 'cloakroom2' then
			ESX.CloseContext()
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
				TriggerEvent('skinchanger:loadSkin', skin)
			end)
		elseif Config.OxInventory and (element.value == 'put_stock' or element.value == 'get_stock') then
			exports.ox_inventory:openInventory('stash', 'society_mechanic')
			return ESX.CloseContext()
		elseif element.value == 'put_stock' then
			OpenPutStocksMenu()
		elseif element.value == 'get_stock' then
			OpenGetStocksMenu()
		elseif element.value == "key_mechanic" then
			ESX.ShowNotification("Item was given", "success", 3000)
			TriggerServerEvent('mechanic-item:getItem', GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1))), "key_mechanic")
		elseif element.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'mechanic', function(data, menu)
				ESX.CloseContext()
			end)
		end
	end)
end

function OpenMechanicHarvestMenu()
	if Config.EnablePlayerManagement and ESX.PlayerData.job and ESX.PlayerData.job.grade_name ~= 'recrue' then
		local elements = {
			{ unselectable = true,  icon = "fas fa-gear",                    title = "Mechanic Harvest Menu" },
			{ icon = "fas fa-gear", title = TranslateCap('gas_can'),         value = 'gaz_bottle' },
			{ icon = "fas fa-gear", title = "Ramp",                          value = 'ramp' },
			{ icon = "fas fa-gear", title = "Rope",                          value = 'rope' },
			{ icon = "fas fa-gear", title = TranslateCap('repair_tools'),    value = 'fix_tool' },
			{ icon = "fas fa-gear", title = TranslateCap('body_work_tools'), value = 'caro_tool' }
		}

		ESX.OpenContext("right", elements, function(menu, element)
			if element.value == 'gaz_bottle' then
				TriggerServerEvent('esx_mechanicjob:startHarvest')
			elseif element.value == 'fix_tool' then
				TriggerServerEvent('esx_mechanicjob:startHarvest2')
			elseif element.value == 'caro_tool' then
				TriggerServerEvent('esx_mechanicjob:startHarvest3')
			elseif element.value == 'ramp' then
				TriggerServerEvent('esx_mechanicjob:startHarvest4')
			elseif element.value == 'rope' then
				TriggerServerEvent('esx_mechanicjob:startHarvest5')
			end
		end)
	else
		ESX.ShowNotification(TranslateCap('not_experienced_enough'))
	end
end

function OpenMechanicCraftMenu()
	if Config.EnablePlayerManagement and ESX.PlayerData.job and ESX.PlayerData.job.grade_name ~= 'recrue' then
		local elements = {
			{ unselectable = true,  icon = "fas fa-gear",               title = "Mechanic Craft Menu" },
			{ icon = "fas fa-gear", title = TranslateCap('blowtorch'),  value = 'blow_pipe' },
			{ icon = "fas fa-gear", title = TranslateCap('repair_kit'), value = 'fix_kit' },
			{ icon = "fas fa-gear", title = TranslateCap('body_kit'),   value = 'caro_kit' }
		}

		ESX.OpenContext("right", elements, function(menu, element)
			if element.value == 'blow_pipe' then
				TriggerServerEvent('esx_mechanicjob:startCraft')
			elseif element.value == 'fix_kit' then
				TriggerServerEvent('esx_mechanicjob:startCraft2')
			elseif element.value == 'caro_kit' then
				TriggerServerEvent('esx_mechanicjob:startCraft3')
			end
		end)
	else
		ESX.ShowNotification(TranslateCap('not_experienced_enough'))
	end
end

function OpenMobileMechanicActionsMenu()
	local elements = {
		{ unselectable = true,  icon = "fas fa-gear",                  title = TranslateCap('mechanic') },
		{ icon = "fas fa-gear", title = TranslateCap('billing'),       value = 'billing' },
		{ icon = "fas fa-gear", title = TranslateCap('hijack'),        value = 'hijack_vehicle' },
		{ icon = "fas fa-gear", title = TranslateCap('repair'),        value = 'fix_vehicle' },
		{ icon = "fas fa-gear", title = TranslateCap('clean'),         value = 'clean_vehicle' },
		{ icon = "fas fa-gear", title = TranslateCap('imp_veh'),       value = 'del_vehicle' },
		{ icon = "fas fa-gear", title = TranslateCap('place_objects'), value = 'object_spawner' }
	}

	ESX.OpenContext("right", elements, function(menu, element)
		if isBusy then return end

		if element.value == "billing" then
			local elements2 = {
				{ unselectable = true,          icon = "fas fa-scroll", title = element.title },
				{ title = "Amount",             input = true,           inputType = "number", inputMin = 1, inputMax = 250000, inputPlaceholder = "Amount to bill.." },
				{ icon = "fas fa-check-double", title = "Confirm",      value = "confirm" }
			}

			ESX.OpenContext("right", elements2, function(menu2, element2)
				local amount = tonumber(menu2.eles[2].inputValue)

				if amount == nil or amount < 0 then
					ESX.ShowNotification(TranslateCap('amount_invalid'), "error")
				else
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(TranslateCap('no_players_nearby'), "error")
					else
						ESX.CloseContext()
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_mechanic',
							TranslateCap('mechanic'), amount)
					end
				end
			end)
		elseif element.value == "hijack_vehicle" then
			local playerPed = PlayerPedId()
			local vehicle = ESX.Game.GetVehicleInDirection()
			local coords = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification(TranslateCap('inside_vehicle'))
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
				CreateThread(function()
					Wait(10000)

					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification(TranslateCap('vehicle_unlocked'))
					isBusy = false
				end)
			else
				ESX.ShowNotification(TranslateCap('no_vehicle_nearby'))
			end
		elseif element.value == "fix_vehicle" then
			local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification(TranslateCap('inside_vehicle'))
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
				CreateThread(function()
					Wait(20000)

					SetVehicleFixed(vehicle)
					SetVehicleDeformationFixed(vehicle)
					SetVehicleUndriveable(vehicle, false)
					SetVehicleEngineOn(vehicle, true, true)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification(TranslateCap('vehicle_repaired'))
					isBusy = false
				end)
			else
				ESX.ShowNotification(TranslateCap('no_vehicle_nearby'))
			end
		elseif element.value == "clean_vehicle" then
			local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification(TranslateCap('inside_vehicle'))
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
				CreateThread(function()
					Wait(10000)

					SetVehicleDirtLevel(vehicle, 0)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification(TranslateCap('vehicle_cleaned'))
					isBusy = false
				end)
			else
				ESX.ShowNotification(TranslateCap('no_vehicle_nearby'))
			end
		elseif element.value == "del_vehicle" then
			local playerPed = PlayerPedId()

			if IsPedSittingInAnyVehicle(playerPed) then
				local vehicle = GetVehiclePedIsIn(playerPed, false)

				if GetPedInVehicleSeat(vehicle, -1) == playerPed then
					ESX.ShowNotification(TranslateCap('vehicle_impounded'))
					ESX.Game.DeleteVehicle(vehicle)
				else
					ESX.ShowNotification(TranslateCap('must_seat_driver'))
				end
			else
				local vehicle = ESX.Game.GetVehicleInDirection()

				if DoesEntityExist(vehicle) then
					ESX.ShowNotification(TranslateCap('vehicle_impounded'))
					ESX.Game.DeleteVehicle(vehicle)
				else
					ESX.ShowNotification(TranslateCap('must_near'))
				end
			end
		elseif element.value == "object_spawner" then
			local playerPed = PlayerPedId()

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowNotification(TranslateCap('inside_vehicle'))
				return
			end

			local elements2 = {
				{ unselectable = true,    icon = "fas fa-object", title = TranslateCap('objects') },
				{icon = "fas fa-cone", title = TranslateCap('roadcone'), model = 'prop_roadcone02a'},
				{ icon = "fas fa-object", title = TranslateCap('toolbox'),  model = 'prop_toolchest_01' }
			}

			ESX.OpenContext("right", elements2, function(menuObj, elementObj)
				local data2 = {current = elementObj}
				local coords, forward = GetEntityCoords(PlayerPedId()), GetEntityForwardVector(PlayerPedId())
				local objectCoords = (coords + forward * 1.0)

				ESX.Game.SpawnObject(data2.current.model, objectCoords, function(obj)
					Wait(100)
					SetEntityHeading(obj, GetEntityHeading(PlayerPedId()))
					PlaceObjectOnGroundProperly(obj)
					table.insert(PlacedObjects, { entity = obj })
				end)
			end)
		end
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('esx_mechanicjob:getStockItems', function(items)
		local elements = {
			{ unselectable = true, icon = "fas fa-box", title = TranslateCap('mechanic_stock') }
		}

		for i = 1, #items, 1 do
			elements[#elements + 1] = {
				icon = 'fas fa-box',
				title = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			}
		end

		ESX.OpenContext("right", elements, function(menu, element)
			local itemName = element.value

			local elements2 = {
				{ unselectable = true,          icon = "fas fa-box", title = element.title },
				{ title = "Amount",             input = true,        inputType = "number", inputMin = 1, inputMax = 100, inputPlaceholder = "Amount to withdraw.." },
				{ icon = "fas fa-check-double", title = "Confirm",   value = "confirm" }
			}

			ESX.OpenContext("right", elements2, function(menu2, element2)
				local count = tonumber(menu2.eles[2].inputValue)

				if count == nil then
					ESX.ShowNotification(TranslateCap('invalid_quantity'))
				else
					ESX.CloseContext()
					TriggerServerEvent('esx_mechanicjob:getStockItem', itemName, count)

					Wait(1000)
					OpenGetStocksMenu()
				end
			end)
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('esx_mechanicjob:getPlayerInventory', function(inventory)
		local elements = {
			{ unselectable = true, icon = "fas fa-box", title = TranslateCap('inventory') }
		}

		for i = 1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				elements[#elements + 1] = {
					icon  = 'fas fa-box',
					title = item.label .. ' x' .. item.count,
					type  = 'item_standard',
					value = item.name
				}
			end
		end

		ESX.OpenContext("right", elements, function(menu, element)
			local itemName = element.value

			local elements2 = {
				{ unselectable = true,          icon = "fas fa-box", title = element.title },
				{ title = "Amount",             input = true,        inputType = "number", inputMin = 1, inputMax = 100, inputPlaceholder = "Amount to deposit.." },
				{ icon = "fas fa-check-double", title = "Confirm",   value = "confirm" }
			}

			ESX.OpenContext("right", elements2, function(menu2, element2)
				local count = tonumber(menu2.eles[2].inputValue)

				if count == nil then
					ESX.ShowNotification(TranslateCap('invalid_quantity'))
				else
					ESX.CloseContext()
					TriggerServerEvent('esx_mechanicjob:putStockItems', itemName, count)

					Wait(1000)
					OpenPutStocksMenu()
				end
			end)
		end)
	end)
end

RegisterNetEvent('esx_mechanicjob:onHijack')
AddEventHandler('esx_mechanicjob:onHijack', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = ESX.Game.GetClosestVehicle(coords)
		end

		local chance = math.random(100)
		local alarm  = math.random(100)

		if DoesEntityExist(vehicle) then
			if alarm <= 33 then
				SetVehicleAlarm(vehicle, true)
				StartVehicleAlarm(vehicle)
			end

			TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)

			CreateThread(function()
				Wait(10000)
				if chance <= 66 then
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)
					ESX.ShowNotification(TranslateCap('veh_unlocked'))
				else
					ESX.ShowNotification(TranslateCap('hijack_failed'))
					ClearPedTasksImmediately(playerPed)
				end
			end)
		end
	end
end)

RegisterNetEvent('esx_mechanicjob:onCarokit')
AddEventHandler('esx_mechanicjob:onCarokit', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = ESX.Game.GetClosestVehicle(coords)
		end

		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_HAMMERING', 0, true)
			CreateThread(function()
				Wait(10000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				ClearPedTasksImmediately(playerPed)
				ESX.ShowNotification(TranslateCap('body_repaired'))
			end)
		end
	end
end)

RegisterNetEvent('esx_mechanicjob:onFixkit')
AddEventHandler('esx_mechanicjob:onFixkit', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = ESX.Game.GetClosestVehicle(coords)
		end

		if DoesEntityExist(vehicle) then
			TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
			CreateThread(function()
				Wait(20000)
				SetVehicleFixed(vehicle)
				SetVehicleDeformationFixed(vehicle)
				SetVehicleUndriveable(vehicle, false)
				ClearPedTasksImmediately(playerPed)
				ESX.ShowNotification(TranslateCap('veh_repaired'))
			end)
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

AddEventHandler('esx_mechanicjob:hasEnteredMarker', function(zone)
	if zone == 'VehicleDelivery' then
		NPCTargetDeleterZone = true
	end
end)

AddEventHandler('esx_mechanicjob:hasExitedMarker', function(zone)
	if zone == 'VehicleDelivery' then
		NPCTargetDeleterZone = false
	end

	CurrentAction = nil
	ESX.CloseContext()
	ESX.HideUI()
end)


AddEventHandler('esx_mechanicjob:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' and not IsPedInAnyVehicle(playerPed, false) then
		for _, placedObject in ipairs(PlacedObjects) do
			if placedObject.entity == entity then
				CurrentAction     = 'remove_entity'
				CurrentActionMsg  = TranslateCap('press_remove_obj')
				CurrentActionData = { entity = entity }
				ESX.TextUI(CurrentActionMsg)
			end
		end
	end
end)

AddEventHandler('esx_mechanicjob:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
	ESX.HideUI()
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name       = TranslateCap('mechanic'),
		number     = 'mechanic',
		base64Icon =
		'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAA4BJREFUWIXtll9oU3cUx7/nJA02aSSlFouWMnXVB0ejU3wcRteHjv1puoc9rA978cUi2IqgRYWIZkMwrahUGfgkFMEZUdg6C+u21z1o3fbgqigVi7NzUtNcmsac40Npltz7S3rvUHzxQODec87vfD+/e0/O/QFv7Q0beV3QeXqmgV74/7H7fZJvuLwv8q/Xeux1gUrNBpN/nmtavdaqDqBK8VT2RDyV2VHmF1lvLERSBtCVynzYmcp+A9WqT9kcVKX4gHUehF0CEVY+1jYTTIwvt7YSIQnCTvsSUYz6gX5uDt7MP7KOKuQAgxmqQ+neUA+I1B1AiXi5X6ZAvKrabirmVYFwAMRT2RMg7F9SyKspvk73hfrtbkMPyIhA5FVqi0iBiEZMMQdAui/8E4GPv0oAJkpc6Q3+6goAAGpWBxNQmTLFmgL3jSJNgQdGv4pMts2EKm7ICJB/aG0xNdz74VEk13UYCx1/twPR8JjDT8wttyLZtkoAxSb8ZDCz0gdfKxWkFURf2v9qTYH7SK7rQIDn0P3nA0ehixvfwZwE0X9vBE/mW8piohhl1WH18UQBhYnre8N/L8b8xQvlx4ACbB4NnzaeRYDnKm0EALCMLXy84hwuTCXL/ExoB1E7qcK/8NCLIq5HcTT0i6u8TYbXUM1cAyyveVq8Xls7XhYrvY/4n3gC8C+dsmAzL1YUiyfWxvHzsy/w/dNd+KjhW2yvv/RfXr7x9QDcmo1he2RBiCCI1Q8jVj9szPNixVfgz+UiIGyDSrcoRu2J16d3I6e1VYvNSQjXpnucAcEPUOkGYZs/l4uUhowt/3kqu1UIv9n90fAY9jT3YBlbRvFTD4fw++wHjhiTRL/bG75t0jI2ITcHb5om4Xgmhv57xpGOg3d/NIqryOR7z+r+MC6qBJB/ZB2t9Om1D5lFm843G/3E3HI7Yh1xDRAfzLQr5EClBf/HBHK462TG2J0OABXeyWDPZ8VqxmBWYscpyghwtTd4EKpDTjCZdCNmzFM9k+4LHXIFACJN94Z6FiFEpKDQw9HndWsEuhnADVMhAUaYJBp9XrcGQKJ4qFE9k+6r2+MG3k5N8VQ22TVglbX2ZwOzX2VvNKr91zmY6S7N6zqZicVT2WNLyVSehESaBhxnOALfMeYX+K/S2yv7wmMAlvwyuR7FxQUyf0fgc/jztfkJr7XeGgC8BJJgWNV8ImT+AAAAAElFTkSuQmCC'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

-- Pop NPC mission vehicle when inside area
CreateThread(function()
	while true do
		local Sleep = 1500

		if NPCTargetTowableZone and not NPCHasSpawnedTowable then
			Sleep        = 0
			local coords = GetEntityCoords(PlayerPedId())
			local zone   = Config[NPCTargetTowableZone]

			if #(coords - zone.Pos) < Config.NPCSpawnDistance then
				local model = Config.Vehicles[GetRandomIntInRange(1, #Config.Vehicles)]

				ESX.Game.SpawnVehicle(model, zone.Pos, 0, function(vehicle)
					NPCTargetTowable = vehicle
				end)

				NPCHasSpawnedTowable = true
			end
		end

		if NPCTargetTowableZone and NPCHasSpawnedTowable and not NPCHasBeenNextToTowable then
			Sleep        = 500
			local coords = GetEntityCoords(PlayerPedId())
			local zone   = Config[NPCTargetTowableZone]

			if #(coords - zone.Pos) < Config.NPCNextToDistance then
				Sleep = 0
				ESX.ShowNotification(TranslateCap('please_tow'))
				NPCHasBeenNextToTowable = true
			end
		end
		Wait(Sleep)
	end
end)

-- Create Blips
CreateThread(function()
	local blip = AddBlipForCoord(Config.MechanicActions.Pos.x, Config.MechanicActions.Pos.y, Config.MechanicActions.Pos.z)

	SetBlipSprite(blip, 446)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, 5)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(TranslateCap('mechanic'))
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
CreateThread(function()
	while true do
		local Sleep = 2000

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
			Sleep = 500
			local coords, letSleep = GetEntityCoords(PlayerPedId()), true

			for k, v in pairs(Config.Zones) do
				if v.Type ~= -1 and #(coords - v.Pos) < Config.DrawDistance then
					Sleep = 0
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, true, true, 2, true, nil, nil, false)
					letSleep = false
				end
			end
		end
		Wait(Sleep)
	end
end)


Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)
		
		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
			if not Config.EnableESXService then
				exports['artex-3dtextui']:StartText3d("Crafting", true, {46}, "Press [~g~E~w~] to open crafting", Config.Craft.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenMechanicCraftMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)
		
				exports['artex-3dtextui']:StartText3d("Harvest", true, {46}, "Press [~g~E~w~] to open harvesting", Config.Harvesting.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenMechanicHarvestMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)
		
				exports['artex-3dtextui']:StartText3d("Actions", true, {46}, "Press [~g~E~w~] to open actions", Config.MechanicActions.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenMechanicActionsMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)
		
				exports['artex-3dtextui']:StartText3d("Mission", true, {46}, "Press [~g~E~w~] to start mission", Config.NPCJobTargetTowable.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						local playerPed = PlayerPedId()
						if NPCOnJob then
							if GetGameTimer() - NPCLastCancel > 5 * 60000 then
								StopNPCJob(true)
								NPCLastCancel = GetGameTimer()
							else
								ESX.ShowNotification(TranslateCap('wait_five'), "error")
							end
						else
							if IsPedInAnyVehicle(playerPed, false) and IsVehicleModel(GetVehiclePedIsIn(playerPed, false), `flatbed`) then
								StartNPCJob()
							else
								ESX.ShowNotification(TranslateCap('must_in_flatbed'), "error")
							end
						end
					end
				end)
		
				exports['artex-3dtextui']:StartText3d("Mechanic Garage", true, {46}, "Press [~g~E~w~] to store vehicle", Config.VehicleDeleter.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						if IsPedInAnyVehicle(PlayerPedId(), false) then
							local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
							if Config.EnableSocietyOwnedVehicles then
								local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
								TriggerServerEvent('esx_society:putVehicleInGarage', 'mechanic', vehicleProps)
								ESX.Game.DeleteVehicle(vehicle)
							else
								local entityModel = GetEntityModel(vehicle)
			
								if entityModel == `flatbed` or entityModel == `towtruck2` or entityModel == `towtruck` then
									TriggerServerEvent('esx_service:disableService', 'mechanic')
									ESX.Game.DeleteVehicle(vehicle)
								end
							end
						end
					end
				end)
			elseif playerInService then
				exports['artex-3dtextui']:StartText3d("Crafting", true, {46}, "Press [~g~E~w~] to open crafting", Config.Craft.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenMechanicCraftMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)
		
				exports['artex-3dtextui']:StartText3d("Harvest", true, {46}, "Press [~g~E~w~] to open harvesting", Config.Harvesting.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenMechanicHarvestMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)
		
				exports['artex-3dtextui']:StartText3d("Actions", true, {46}, "Press [~g~E~w~] to open actions", Config.MechanicActions.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						OpenMechanicActionsMenu()
						SetCursorLocation(0.85, 0.5)
					end
				end)
		
				exports['artex-3dtextui']:StartText3d("Mission", true, {46}, "Press [~g~E~w~] to start mission", Config.NPCJobTargetTowable.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						local playerPed = PlayerPedId()
						if NPCOnJob then
							if GetGameTimer() - NPCLastCancel > 5 * 60000 then
								StopNPCJob(true)
								NPCLastCancel = GetGameTimer()
							else
								ESX.ShowNotification(TranslateCap('wait_five'), "error")
							end
						else
							if IsPedInAnyVehicle(playerPed, false) and IsVehicleModel(GetVehiclePedIsIn(playerPed, false), `flatbed`) then
								StartNPCJob()
							else
								ESX.ShowNotification(TranslateCap('must_in_flatbed'), "error")
							end
						end
					end
				end)
		
				exports['artex-3dtextui']:StartText3d("Mechanic Garage", true, {46}, "Press [~g~E~w~] to store vehicle", Config.VehicleDeleter.Pos, 3.0, 1.0, false, false, function(pressedKey)
					if pressedKey == 46 then
						if IsPedInAnyVehicle(PlayerPedId(), false) then
							local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
							if Config.EnableSocietyOwnedVehicles then
								local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
								TriggerServerEvent('esx_society:putVehicleInGarage', 'mechanic', vehicleProps)
								ESX.Game.DeleteVehicle(vehicle)
							else
								local entityModel = GetEntityModel(vehicle)
			
								if entityModel == `flatbed` or entityModel == `towtruck2` or entityModel == `towtruck` then
									TriggerServerEvent('esx_service:disableService', 'mechanic')
									ESX.Game.DeleteVehicle(vehicle)
								end
							end
						end
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

-- Enter / Exit marker events
CreateThread(function()
	while true do
		local Sleep = 500

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
			local coords = GetEntityCoords(PlayerPedId())
			local isInMarker = false
			local currentZone = nil

			for k, v in pairs(Config.Zones) do
				if (#(coords - v.Pos) < v.Size.x) then
					Sleep       = 0
					isInMarker  = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('esx_mechanicjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_mechanicjob:hasExitedMarker', LastZone)
			end
		end
		Wait(Sleep)
	end
end)

CreateThread(function()
	local trackedEntities = {
		'prop_roadcone02a',
		'prop_toolchest_01'
	}

	while true do
		Wait(500)

		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		local closestDistance = -1
		local closestEntity = nil

		for i = 1, #trackedEntities, 1 do
			local object = GetClosestObjectOfType(coords, 3.0, joaat(trackedEntities[i]), false, false, false)

			if DoesEntityExist(object) then
				local objCoords = GetEntityCoords(object)
				local distance  = #(coords - objCoords)

				if closestDistance == -1 or closestDistance > distance then
					closestDistance = distance
					closestEntity   = object
				end
			end
		end

		if closestDistance ~= -1 and closestDistance <= 3.0 then
			if LastEntity ~= closestEntity then
				TriggerEvent('esx_mechanicjob:hasEnteredEntityZone', closestEntity)
				LastEntity = closestEntity
			end
		else
			if LastEntity then
				TriggerEvent('esx_mechanicjob:hasExitedEntityZone', LastEntity)
				LastEntity = nil
			end
		end
	end
end)

-- Key Controls
CreateThread(function()
	while true do
		local sleep = 500
		if CurrentAction then
			sleep = 0
			if IsControlJustReleased(0, 38) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
				if CurrentAction == 'remove_entity' then
					if not Config.EnableESXService then
						DeleteEntity(CurrentActionData.entity)
					elseif playerInService then
						DeleteEntity(CurrentActionData.entity)
					end
				end

				CurrentAction = nil
			end
		end
		Wait(sleep)
	end
end)

RegisterCommand('mechanicMenu', function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
		if not Config.EnableESXService then
			OpenMobileMechanicActionsMenu()
			SetCursorLocation(0.85, 0.5)
		elseif playerInService then
			OpenMobileMechanicActionsMenu()
			SetCursorLocation(0.85, 0.5)
		end
	end
end, false)

RegisterKeyMapping('mechanicMenu', 'Open Mechanic Menu', 'keyboard', Config.Controls.mechanicMenu)

AddEventHandler('esx:onPlayerDeath', function(data) isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)
