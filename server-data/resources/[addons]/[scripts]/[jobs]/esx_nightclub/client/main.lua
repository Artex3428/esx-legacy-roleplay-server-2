local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData              = {}
local Blips                   = {}

local isBarman                = false

function IsJobTrue()
    if PlayerData ~= nil then
        local IsJobTrue = false
        if PlayerData.job ~= nil and PlayerData.job.name == 'nightclub' then
            IsJobTrue = true
        end
        return IsJobTrue
    end
end

function IsGradeBoss()
    if PlayerData ~= nil then
        local IsGradeBoss = false
        if PlayerData.job.grade_name == 'boss' or PlayerData.job.grade_name == 'viceboss' then
            IsGradeBoss = true
        end
        return IsGradeBoss
    end
end

function SetVehicleMaxMods(vehicle)

  local props = {
    modEngine       = 0,
    modBrakes       = 0,
    modTransmission = 0,
    modSuspension   = 0,
    modTurbo        = false,
  }

  ESX.Game.SetVehicleProperties(vehicle, props)

end

CreateThread(function()
  while ESX == nil do
      Wait(100) -- Wait for ESX to be initialized
  end

  while ESX.GetPlayerData().job == nil do
      Wait(100) -- Wait for the player's job to be loaded
  end

  PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)


function cleanPlayer(playerPed)
  ClearPedBloodDamage(playerPed)
  ResetPedVisibleDamage(playerPed)
  ClearPedLastWeaponDamage(playerPed)
  ResetPedMovementClipset(playerPed, 0)
end

function setClipset(playerPed, clip)
  RequestAnimSet(clip)
  while not HasAnimSetLoaded(clip) do
    Citizen.Wait(0)
  end
  SetPedMovementClipset(playerPed, clip, true)
end

function setUniform(job, playerPed)
  TriggerEvent('skinchanger:getSkin', function(skin)

    if skin.sex == 0 then
      if Config.Uniforms[job].male ~= nil then
        TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
      else
        ESX.ShowNotification(_U('no_outfit'))
      end
      if job ~= 'citizen_wear' and job ~= 'barman_outfit' then
        setClipset(playerPed, "MOVE_M@POSH@")
      end
    else
      if Config.Uniforms[job].female ~= nil then
        TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].female)
      else
        ESX.ShowNotification(_U('no_outfit'))
      end
      if job ~= 'citizen_wear' and job ~= 'barman_outfit' then
        setClipset(playerPed, "MOVE_F@POSH@")
      end
    end

  end)
end

function OpenCloakroomMenu()

  local playerPed = GetPlayerPed(-1)

  local elements = {
    {unselectable = true, icon = "fas fa-table", title = "Clothes"},
    {icon = "fas fa-user-secret", title = "Civilian clothes", value = 'citizen_wear'},
    {icon = "fas fa-user-secret", title = "Barman outfit", value = 'barman_outfit'},
    {icon = "fas fa-user-secret", title = "Dancer outfit 1", value = 'dancer_outfit_1'},
    {icon = "fas fa-user-secret", title = "Dancer outfit 2", value = 'dancer_outfit_2'},
    {icon = "fas fa-user-secret", title = "Dancer outfit 3", value = 'dancer_outfit_3'},
    {icon = "fas fa-user-secret", title = "Dancer outfit 4", value = 'dancer_outfit_4'},
    {icon = "fas fa-user-secret", title = "Dancer outfit 5", value = 'dancer_outfit_5'},
    {icon = "fas fa-user-secret", title = "Dancer outfit 6", value = 'dancer_outfit_6'},
    {icon = "fas fa-user-secret", title = "Dancer outfit 7", value = 'dancer_outfit_7'},
  }
  
  ESX.OpenContext("right", elements, function(menu,element)
      local data = {current = element}
      local action = data.current.value
  
      isBarman = false
      cleanPlayer(playerPed)

      if action == "citizen_wear" then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
          TriggerEvent('skinchanger:loadSkin', skin)
        end)
      elseif action == 'barman_outfit' then
        setUniform(data.current.value, playerPed)
        isBarman = true
      elseif action == 'dancer_outfit_1' or
             action == 'dancer_outfit_2' or
             action == 'dancer_outfit_3' or
             action == 'dancer_outfit_4' or
             action == 'dancer_outfit_5' or
             action == 'dancer_outfit_6' or
             action == 'dancer_outfit_7' then
        setUniform(data.current.value, playerPed)
      end
  end)
end

function OpenVaultMenu()
  if Config.EnableVaultManagement then
    local elements = {
      {unselectable = true, icon = "fas fa-cogs", title = _U('vault')},
      {icon = "fas fa-check", title = _U('get_weapon'), value = "get_weapon"},
      {icon = "fas fa-check", title = _U('put_weapon'), value = "put_weapon"},
      {icon = "fas fa-check", title = _U('get_object'), value = "get_stock"},
      {icon = "fas fa-check", title = _U('put_object'), value = "put_stock"},
    }

    ESX.OpenContext("right", elements, function(menu,element)
      if element.value == 'get_weapon' then
        OpenGetWeaponMenu()
      end

      if element.value == 'put_weapon' then
        OpenPutWeaponMenu()
      end

      if element.value == 'put_stock' then
        OpenPutStocksMenu()
      end

      if element.value == 'get_stock' then
        OpenGetStocksMenu()
      end
    end)
  end
end

function OpenFridgeMenu()
  local elements = {
    {unselectable = true, icon = "fas fa-thermometer-full", title = "Fridge"},
    {icon = "fas fa-arrow-right", title = _U('get_object'), value = 'get_stock'},
    {icon = "fas fa-arrow-right", title = _U('put_object'), value = 'put_stock'},
  }

  ESX.OpenContext("right", elements, function(menu,element)
      local data = {current = element}
      local action = data.current.value

      if action == "get_stock" then
        OpenPutFridgeStocksMenu()
      elseif action == "put_object" then
        OpenGetFridgeStocksMenu()
      end
  end)
end

function OpenVehicleSpawnerMenu()
  local vehicles = Config.Zones.Vehicles

  ESX.UI.Menu.CloseAll()

  if Config.EnableSocietyOwnedVehicles then

    local elements = {
      {unselectable = true, icon = "fas fa-cogs", title = _U('vehicle_menu')},
    }

    ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(garageVehicles)

      for i=1, #garageVehicles, 1 do
        table.insert(elements, {icon = "fas fa-check", title = GetDisplayNameFromVehicleModel(garageVehicles[i].model) .. ' [' .. garageVehicles[i].plate .. ']', value = garageVehicles[i]})
      end

      ESX.OpenContext("right", elements, function(menu,element)
        local vehicleProps = element.value
        ESX.Game.SpawnVehicle(vehicleProps.model, vehicles.SpawnPoint, vehicles.Heading, function(vehicle)
            ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
            local playerPed = GetPlayerPed(-1)
            --TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)  -- teleport into vehicle
        end)            

        TriggerServerEvent('esx_society:removeVehicleFromGarage', 'nightclub', vehicleProps)
      end)
    end, 'nightclub')

  else

    local elements = {
      {unselectable = true, icon = "fas fa-cogs", title = _U('vehicle_menu')},
    }

    for i=1, #Config.AuthorizedVehicles, 1 do
      local vehicle = Config.AuthorizedVehicles[i]
      table.insert(elements, {icon = "fas fa-check", title = vehicle.label, value = vehicle.name})
    end

    ESX.OpenContext("right", elements, function(menu,element)
      local model = data.current.value

      local vehicle = GetClosestVehicle(vehicles.SpawnPoint.x,  vehicles.SpawnPoint.y,  vehicles.SpawnPoint.z,  3.0,  0,  71)

      if not DoesEntityExist(vehicle) then

        local playerPed = GetPlayerPed(-1)

        if Config.MaxInService == -1 then

          ESX.Game.SpawnVehicle(model, {
            x = vehicles.SpawnPoint.x,
            y = vehicles.SpawnPoint.y,
            z = vehicles.SpawnPoint.z
          }, vehicles.Heading, function(vehicle)
            --TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1) -- teleport into vehicle
            SetVehicleMaxMods(vehicle)
            SetVehicleDirtLevel(vehicle, 0)
          end)

        else

          ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)

            if canTakeService then

              ESX.Game.SpawnVehicle(model, {
                x = vehicles[partNum].SpawnPoint.x,
                y = vehicles[partNum].SpawnPoint.y,
                z = vehicles[partNum].SpawnPoint.z
              }, vehicles[partNum].Heading, function(vehicle)
                --TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)  -- teleport into vehicle
                SetVehicleMaxMods(vehicle)
                SetVehicleDirtLevel(vehicle, 0)
              end)

            else
              ESX.ShowNotification(_U('service_max') .. inServiceCount .. '/' .. maxInService)
            end

          end, 'etat')
        end

      else
        ESX.ShowNotification(_U('vehicle_out'))
      end
    end)
  end
end

function OpenSocietyActionsMenu()
  local elements = {
    {unselectable = true, icon = "fas fa-bars", title = "Job actions"},
  }

  table.insert(elements, {icon = "fas fa-credit-card", title = _U('billing'), value = "billing"})
  if (isBarman or IsGradeBoss()) then
    table.insert(elements, {icon = "fas fa-hourglass-half", title = _U('crafting'), value = "menu_crafting"})
  end

  ESX.OpenContext("right", elements, function(menu,element)
      local data = {current = element}
      local action = data.current.value

      if action == "billing" then
        OpenBillingMenu()
      elseif data.current.value == "menu_crafting" then
    
        local elements2 = {
          {unselectable = true, icon = "fas fa-hourglass-half", title = "Job actions"},
          {icon = "fas fa-beer", title = _U('jagerbomb'), value = "jagerbomb"},
          {icon = "fas fa-beer", title = _U('golem'), value = "golem"},
          {icon = "fas fa-beer", title = _U('whiskycoca'), value = "whiskycoca"},
          {icon = "fas fa-beer", title = _U('vodkaenergy'), value = "vodkaenergy"},
          {icon = "fas fa-beer", title = _U('vodkafruit'), value = "vodkafruit"},
          {icon = "fas fa-beer", title = _U('rhumfruit'), value = "rhumfruit"},
          {icon = "fas fa-beer", title = _U('teqpaf'), value = "teqpaf"},
          {icon = "fas fa-beer", title = _U('rhumcoca'), value = "rhumcoca"},
          {icon = "fas fa-beer", title = _U('mojito'), value = "mojito"},
          {icon = "fas fa-beer", title = _U('mixapero'), value = "mixapero"},
          {icon = "fas fa-beer", title = _U('metreshooter'), value = "metreshooter"},
          {icon = "fas fa-beer", title = _U('jagercerbere'), value = "jagercerbere"},
        }

        ESX.OpenContext("right", elements2, function(menu2,element2)
          local data2 = {current = element2}

          TriggerServerEvent('esx_nightclubjob:craftingCoktails', data2.value)
          animsAction({ lib = "mini@drinking", anim = "shots_barman_b" })
      end)
      end
  end)
end

function OpenBillingMenu()
  ESX.UI.Menu.Open(
    'dialog', GetCurrentResourceName(), 'billing',
    {
      title = _U('billing_amount')
    },
    function(data, menu)

      local amount = tonumber(data.value)
      local player, distance = ESX.Game.GetClosestPlayer()

      if player ~= -1 and distance <= 3.0 then

        menu.close()
        if amount == nil or amount < 0 then
            ESX.ShowNotification(_U('amount_invalid'))
        else
            TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_nightclub', _U('billing'), amount)
        end

      else
        ESX.ShowNotification(_U('no_players_nearby'))
      end

    end,
    function(data, menu)
        menu.close()
    end
  )
end

function OpenGetStocksMenu()
  ESX.TriggerServerCallback('esx_nightclubjob:getStockItems', function(items)

    print(json.encode(items))

    local elements = {
      {unselectable = true, icon = "fas fa-cogs", title = _U('nightclub_stock')},
    }
    for i=1, #items, 1 do
      table.insert(elements, {icon = "fas fa-check", title = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
    end

    ESX.OpenContext("right", elements, function(menu,element)
      local itemName = element.value

      ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
        {
          title = _U('quantity')
        },
        function(data2, menu2)

          local count = tonumber(data2.value)

          if count == nil then
            ESX.ShowNotification(_U('invalid_quantity'))
          else
            menu2.close()
            OpenGetStocksMenu()

            TriggerServerEvent('esx_nightclubjob:getStockItem', itemName, count)
          end

        end,
        function(data2, menu2)
          menu2.close()
        end)
    end)
  end)
end

function OpenPutStocksMenu()
  ESX.TriggerServerCallback('esx_nightclubjob:getPlayerInventory', function(inventory)

    local elements = {
      {unselectable = true, icon = "fas fa-cogs", title = _U('inventory')},
  }

    for i=1, #inventory.items, 1 do

      local item = inventory.items[i]

      if item.count > 0 then
        table.insert(elements, {icon = "fas fa-check", title = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
      end

    end

    ESX.OpenContext("right", elements, function(menu,element)
      local itemName = element.value

      ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
        {
          title = _U('quantity')
        },
        function(data2, menu2)

          local count = tonumber(data2.value)

          if count == nil then
            ESX.ShowNotification(_U('invalid_quantity'))
          else
            menu2.close()
            menu.close()
            OpenPutStocksMenu()

            TriggerServerEvent('esx_nightclubjob:putStockItems', itemName, count)
          end

        end,
        function(data2, menu2)
          menu2.close()
        end)
    end)
  end)
end

function OpenGetFridgeStocksMenu()

  ESX.TriggerServerCallback('esx_nightclubjob:getFridgeStockItems', function(items)

    print(json.encode(items))

    local elements = {
      {unselectable = true, icon = "fas fa-cogs", title = _U('nightclub_fridge_stock')},
    }

    for i=1, #items, 1 do
      table.insert(elements, {icon = "fas fa-check", title = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
    end

    ESX.OpenContext("right", elements, function(menu,element)
      local itemName = element.value

      ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'fridge_menu_get_item_count',
        {
          title = _U('quantity')
        },
        function(data2, menu2)

          local count = tonumber(data2.value)

          if count == nil then
            ESX.ShowNotification(_U('invalid_quantity'))
          else
            menu2.close()
            menu.close()
            OpenGetStocksMenu()

            TriggerServerEvent('esx_nightclubjob:getFridgeStockItem', itemName, count)
          end

        end,
        function(data2, menu2)
          menu2.close()
      end)
    end)
  end)
end

function OpenPutFridgeStocksMenu()

  ESX.TriggerServerCallback('esx_nightclubjob:getPlayerInventory', function(inventory)
    local elements = {
      {unselectable = true, icon = "fas fa-cogs", title = _U('fridge_inventory')},
    }

    for i=1, #inventory.items, 1 do
      local item = inventory.items[i]

      if item.count > 0 then
        table.insert(elements, {icon = "fas fa-check", title = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
      end
    end

    ESX.OpenContext("right", elements, function(menu,element)
      local itemName = element.value

      ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'fridge_menu_put_item_count',
        {
          title = _U('quantity')
        },
        function(data2, menu2)

          local count = tonumber(data2.value)

          if count == nil then
            ESX.ShowNotification(_U('invalid_quantity'))
          else
            menu2.close()
            menu.close()
            OpenPutFridgeStocksMenu()

            TriggerServerEvent('esx_nightclubjob:putFridgeStockItems', itemName, count)
          end

        end,
        function(data2, menu2)
          menu2.close()
      end)
    end)
  end)
end

function OpenGetWeaponMenu()

  ESX.TriggerServerCallback('esx_nightclubjob:getVaultWeapons', function(weapons)

    local elements = {
      {unselectable = true, icon = "fas fa-cogs", title = _U('get_weapon_menu')},
    }

    for i=1, #weapons, 1 do
      if weapons[i].count > 0 then
        table.insert(elements, {icon = "fas fa-check", title = 'x' .. weapons[i].count .. ' ' .. ESX.GetWeaponLabel(weapons[i].name), value = weapons[i].name})
      end
    end

    ESX.OpenContext("right", elements, function(menu,element)
      ESX.TriggerServerCallback('esx_nightclubjob:removeVaultWeapon', function()
        OpenGetWeaponMenu()
      end, element.value)
    end)
  end)
end

function OpenPutWeaponMenu()
  local elements = {
    {unselectable = true, icon = "fas fa-cogs", title = _U('put_weapon_menu')},
  }
  local playerPed  = GetPlayerPed(-1)
  local weaponList = ESX.GetWeaponList()

  for i=1, #weaponList, 1 do

    local weaponHash = GetHashKey(weaponList[i].name)

    if HasPedGotWeapon(playerPed,  weaponHash,  false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
      local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
      table.insert(elements, {icon = "fas fa-check", title = weaponList[i].label, value = weaponList[i].name})
    end

  end

  ESX.OpenContext("right", elements, function(menu,element)
    ESX.TriggerServerCallback('esx_nightclubjob:addVaultWeapon', function()
      OpenPutWeaponMenu()
    end, element.value)
  end)
end

function OpenShopMenu(zone)
  local elements = {
    {unselectable = true, icon = "fas fa-shopping-basket", title = _U('shop')},
  }

  for i=1, #Config.Zones[zone].Items, 1 do
    local item = Config.Zones[zone].Items[i]

    table.insert(elements, {
        icon = "fas fa-tags",
        title = item.label .. " - <span style='color: green;'>$" .. item.price .. "</span>",
        realLabel = item.label,
        value = item.name,
        price = item.price,
    })
  end

  ESX.OpenContext("right", elements, function(menu,element)
      local data = {current = element}

      TriggerServerEvent('esx_nightclubjob:buyItem', data.current.value, data.current.price, data.current.realLabel)
  end)
end

function animsAction(animObj)
    Citizen.CreateThread(function()
        if not playAnim then
            local playerPed = GetPlayerPed(-1);
            if DoesEntityExist(playerPed) then -- Check if ped exist
                dataAnim = animObj

                -- Play Animation
                RequestAnimDict(dataAnim.lib)
                while not HasAnimDictLoaded(dataAnim.lib) do
                    Citizen.Wait(0)
                end
                if HasAnimDictLoaded(dataAnim.lib) then
                    local flag = 0
                    if dataAnim.loop ~= nil and dataAnim.loop then
                        flag = 1
                    elseif dataAnim.move ~= nil and dataAnim.move then
                        flag = 49
                    end

                    TaskPlayAnim(playerPed, dataAnim.lib, dataAnim.anim, 8.0, -8.0, -1, flag, 0, 0, 0, 0)
                    playAnimation = true
                end

                -- Wait end animation
                while true do
                    Citizen.Wait(0)
                    if not IsEntityPlayingAnim(playerPed, dataAnim.lib, dataAnim.anim, 3) then
                        playAnim = false
                        TriggerEvent('ft_animation:ClFinish')
                        break
                    end
                end
            end -- end ped exist
        end
    end)
end

local playerInService = false

-- Create blips
Citizen.CreateThread(function()
  local blipMarker = Config.Blips.Blip
  local blipCoord = AddBlipForCoord(blipMarker.Pos.x, blipMarker.Pos.y, blipMarker.Pos.z)

  SetBlipSprite (blipCoord, blipMarker.Sprite)
  SetBlipDisplay(blipCoord, blipMarker.Display)
  SetBlipScale  (blipCoord, blipMarker.Scale)
  SetBlipColour (blipCoord, blipMarker.Colour)
  SetBlipAsShortRange(blipCoord, true)

  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(_U('map_blip'))
  EndTextCommandSetBlipName(blipCoord)
end)


exports('getIsInServiceNightclub', function()
  return playerInService
end)

Citizen.CreateThread(function ()
  while true do
    Citizen.Wait(0)

    if IsJobTrue() then
      if not Config.EnableESXService then
      elseif playerInService then
        exports['artex-3dtextui']:StartText3d("Cloakrooms", true, {46}, "Press [~g~E~w~] to open cloakroom", vector3(Config.Zones.Cloakrooms.Pos.x, Config.Zones.Cloakrooms.Pos.y, Config.Zones.Cloakrooms.Pos.z), 2.0, 0.5, false, false, function(pressedKey)
          if pressedKey == 46 then
            OpenCloakroomMenu()
            SetCursorLocation(0.85, 0.5)
          end
        end)

        exports['artex-3dtextui']:StartText3d("Fridge", true, {46}, "Press [~g~E~w~] to open fridge", vector3(Config.Zones.Fridge.Pos.x, Config.Zones.Fridge.Pos.y, Config.Zones.Fridge.Pos.z), 2.0, 0.5, false, false, function(pressedKey)
          if pressedKey == 46 then
            OpenFridgeMenu()
            SetCursorLocation(0.85, 0.5)
          end
        end)

        exports['artex-3dtextui']:StartText3d("Boss actions", true, {46}, "Press [~g~E~w~] to open boss actions", vector3(Config.Zones.BossActions.Pos.x, Config.Zones.BossActions.Pos.y, Config.Zones.BossActions.Pos.z), 2.0, 0.5, false, false, function(pressedKey)
          if pressedKey == 46 then
            local options = {
              wash = Config.EnableMoneyWash,
            }

            ESX.UI.Menu.CloseAll()

            TriggerEvent('esx_society:openBossMenu', 'nightclub', function(data, menu)
            end,options)
          end
        end)

        exports['artex-3dtextui']:StartText3d("Shop", true, {46}, "Press [~g~E~w~] to open shop", vector3(Config.Zones.Shop.Pos.x, Config.Zones.Shop.Pos.y, Config.Zones.Shop.Pos.z), 2.0, 0.5, false, false, function(pressedKey)
          if pressedKey == 46 then
            OpenShopMenu("Shop")
            SetCursorLocation(0.85, 0.5)
          end
        end)

        -- exports['artex-3dtextui']:StartText3d("Vault", true, {46}, "Press [~g~E~w~] to open vault", vector3(Config.Zones.Vaults.Pos.x, Config.Zones.Vaults.Pos.y, Config.Zones.Vaults.Pos.z), 2.0, 0.5, false, false, function(pressedKey)
        --   if pressedKey == 46 then
        --     OpenVaultMenu()
        --   end
        -- end)

        -- exports['artex-3dtextui']:StartText3d("Garage", true, {46}, "Press [~g~E~w~] to open garage", vector3(Config.Zones.Vehicles.Pos.x, Config.Zones.Vehicles.Pos.y, Config.Zones.Vehicles.Pos.z), 2.0, 0.5, false, false, function(pressedKey)
        --   if pressedKey == 46 then
        --     OpenVehicleSpawnerMenu()
        --   end
        -- end)
  
        -- exports['artex-3dtextui']:StartText3d("Store vehicle", true, {46}, "Press [~g~E~w~] to store vehicle", vector3(Config.Zones.VehicleDeleters.Pos.x, Config.Zones.VehicleDeleters.Pos.y, Config.Zones.VehicleDeleters.Pos.z), 2.0, 0.5, false, false, function(pressedKey)
        --   if pressedKey == 46 then
        --     local vehicle = GetVehiclePedIsIn(PlayerPedId(),  false)
        --     if Config.EnableSocietyOwnedVehicles then
        --       local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
        --       TriggerServerEvent('esx_society:putVehicleInGarage', 'nightclub', vehicleProps)
        --     else
        --       if
        --         GetEntityModel(vehicle) == GetHashKey('rentalbus')
        --       then
        --         TriggerServerEvent('esx_service:disableService', 'nightclub')
        --       end
        --     end
        --   end
        -- end)

        for k,v in pairs(Config.TeleportZones) do
          exports['artex-3dtextui']:StartText3d("Enter", true, {46}, "Press [~g~E~w~] to enter", vector3(v.Pos.x, v.Pos.y, v.Pos.z), 2.0, 0.5, false, false, function(pressedKey)
            if pressedKey == 46 then
              TriggerEvent('esx_nightclubjob:teleportMarkers', v.Teleport)
            end
          end)
        end

        exports['artex-3dtextui']:StartText3d("Storage", true, {46}, "Press [~g~E~w~] to open key storage", vector3(92.90491485595705, -1291.673095703125, 29.2687702178955), 3.0, 1.0, false, false, function(pressedKey)
          if pressedKey == 46 then
            local elements = {
              {unselectable = true, icon = "fas fa-shopping-basket", title = "Items"},
              {icon = "fas fas fa-cubes", title = "Get key", value = "key_nightclub"},
            }

            ESX.OpenContext("right", elements, function(menu, element)
              local data = {current = element}

              if data.current.value == 'key_nightclub' then
                ESX.ShowNotification("Item was given", "success", 3000)
                TriggerServerEvent('nightclub-item:getItem', GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1))), "key_nightclub")
              end
            end)
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

Citizen.CreateThread(function ()
  while true do
    Citizen.Wait(0)

    if Config.EnableESXService then
      exports['artex-3dtextui']:StartText3d("Service", true, {46}, "Press [~g~E~w~] to toggle service", vector3(107.39527130126952, -1306.216552734375, 28.76877403259277), 3.0, 1.0, false, false, function(pressedKey)
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

                      TriggerServerEvent('esx_service:notifyAllInService', notification, 'nightclub')
                      ESX.ShowNotification(TranslateCap('service_in'))
                    end
                  end, 'nightclub')
                else
                  playerInService = true

                  local notification = {
                    title    = TranslateCap('service_anonunce'),
                    subject  = '',
                    msg      = TranslateCap('service_in_announce', GetPlayerName(PlayerId())),
                    iconType = 1
                  }

                  TriggerServerEvent('esx_service:notifyAllInService', notification, 'nightclub')
                  ESX.ShowNotification(TranslateCap('service_in'))
                end
            end, 'nightclub')
          else
            playerInService = false

            local notification = {
              title    = TranslateCap('service_anonunce'),
              subject  = '',
              msg      = TranslateCap('service_out_announce', GetPlayerName(PlayerId())),
              iconType = 1
            }

            TriggerServerEvent('esx_service:notifyAllInService', notification, 'nightclub')
            TriggerServerEvent('esx_service:disableService', 'nightclub')
            ESX.ShowNotification(TranslateCap('service_out'))
          end
        end
      end)
    else
      Citizen.Wait(500)
    end
  end
end)

RegisterCommand("opensocietynightclub", function ()
  if IsJobTrue() then
    OpenSocietyActionsMenu()
    SetCursorLocation(0.85, 0.5)
  end
end)

RegisterKeyMapping('opensocietynightclub', 'Open Nightclub Menu', 'keyboard', 'f6')

-----------------------
----- TELEPORTERS -----

AddEventHandler('esx_nightclubjob:teleportMarkers', function(position)
  SetEntityCoords(GetPlayerPed(-1), position.x, position.y, position.z)
end)