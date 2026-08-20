RegisterNetEvent('jms_crafting:openEditor', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'crafting:adminOpen', payload = {} })
end)
