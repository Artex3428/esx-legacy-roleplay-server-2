OpenGangInfo = function(source)
    -- ESX.TriggerServerCallback('c-gangs:getInfo', function(info)
    for k,v in pairs(Config.Gangs) do
        local elements = {
            {unselectable = true, icon = "fas fa-question-circle", title = "Organization info"},
            {unselectable = true, icon = "fas fa-question", title = "Organization job: "..ESX.PlayerData.job.label.." - "..ESX.PlayerData.job.grade_label},
            {icon = "fas fa-credit-card", title = "Society Money", value = 'society_money'},
        }

        ESX.OpenContext("right", elements, function(menu,element)
            local data = {current = element}
            local action = data.current.value

            if action == "society_money" then
                ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
                    ESX.ShowNotification('Your organization has  $' .. money)
                end)
            end
        end)
    end
end

OpenShopMenu = function()
    for k, v in pairs(Config.Gangs) do
        local elements = {
            {unselectable = true, icon = "fas fa-shopping-basket", title = "Items"},
        }

        for i = 1, #v.ItemShop, 1 do
            table.insert(elements, {
                icon = "fas fa-cubes", 
                title = v.ItemShop[i].label, -- Correctly indexing the label
                value = v.ItemShop[i].value -- Correctly indexing the value
            })
        end

        ESX.OpenContext("right", elements, function(menu, element)
            if element.value then -- Ensure the selected item has a value
                ESX.ShowNotification("Item was given", "success", 3000)
                TriggerServerEvent('c-gangs:getItem', GetPlayerServerId(NetworkGetEntityOwner(GetPlayerPed(-1))), element.value)
            else
                ESX.ShowNotification("Invalid item selection", "error", 3000)
            end
        end)
    end
end

OpenClothesMenu = function()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'clothes', {
        title = 'Skin',
        align = 'right',
        elements = {
            {label = 'Cambiarse de ropa', value  = 'skin'}
        }
    }, function(data, menu)

        if data.current.value == 'skin' then
            menu.close()
            local config = {
                ped = true,
                headBlend = true,
                faceFeatures = true,
                headOverlays = true,
                components = true,
                props = true,
            }

            exports['illenium-appearance']:startPlayerCustomization(function (appearance)
                if (appearance) then
                print('Saved')
                else
                print('Canceled')
                end
            end, config)
        end
    end, function(data, menu)
        menu.close()
    end)
end