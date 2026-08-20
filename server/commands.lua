RegisterCommand('crafting', function(source, args)
    local subcommand = args[1]
    if subcommand == 'editor' then
        if not JMSBridge.IsAdmin(source) then
            TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = Locale('no_permission') })
            return
        end
        TriggerClientEvent('jms_crafting:openEditor', source)
        return
    end

    TriggerClientEvent('jms_crafting:openBench', source, 'starter_electronics_bench')
end, false)
