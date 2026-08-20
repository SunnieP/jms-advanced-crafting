RegisterCommand('craft', function()
    TriggerEvent('jms_crafting:openBench', 'starter_electronics_bench')
end, false)

RegisterNetEvent('jms_crafting:openBench', function(benchId)
    TriggerEvent('jms_crafting:openBench', benchId)
end)
