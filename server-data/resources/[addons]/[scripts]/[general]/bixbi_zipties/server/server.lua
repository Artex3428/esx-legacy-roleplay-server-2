ESX.RegisterUsableItem('zipties', function(source)
    TriggerClientEvent('bixbi_zipties:startZiptie', source)
end)

for k,v in pairs(Config.ZiptieRemovers) do
	ESX.RegisterUsableItem(k, function(source)
		local tool = Config.ZiptieRemovers[k]
		TriggerClientEvent('bixbi_zipties:startziptieremove', source, tool)

		if tool.OneTimeUse == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			xPlayer.removeInventoryItem(k, 1)
		end
	end)
end

RegisterServerEvent('bixbi_zipties:ApplyZipties')
AddEventHandler('bixbi_zipties:ApplyZipties', function(targetId)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem('zipties')

	if sourceItem.count >= 1 then
		xPlayer.removeInventoryItem('zipties', 1)
		TriggerClientEvent('bixbi_zipties:ziptie', targetId)
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, 'You do not have zipties.')
	end
end)

RegisterServerEvent('bixbi_zipties:RemoveZipties')
AddEventHandler('bixbi_zipties:RemoveZipties', function(targetId)
	TriggerClientEvent('bixbi_zipties:removeziptie', targetId)
end)