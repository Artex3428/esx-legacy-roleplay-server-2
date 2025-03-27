ESX.RegisterUsableItem('ramp', function(source)
	TriggerClientEvent('ramp:Active', source)
end)

ESX.RegisterUsableItem('rope', function(source)
	TriggerClientEvent('rope:Active', source)
end)

RegisterNetEvent('towing:getItem', function(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)

    xPlayer.addInventoryItem(item, 1)
end)

RegisterNetEvent('towing:removeItem', function(source, item, count)
    exports.ox_inventory:RemoveItem(source, item, count)
end)