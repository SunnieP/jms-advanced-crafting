local function isAdmin(source)
    if source == 0 then return true end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local group = xPlayer.getGroup()
    return Config.AdminGroups[group] == true
end

local function benchTypeList()
    local names = {}
    for key, cfg in pairs(Config.BenchTypes) do
        if not cfg.portable then
            names[#names + 1] = key
        end
    end
    return table.concat(names, ', ')
end

RegisterCommand('crafting', function(source, args)
    local sub = args[1]

    if sub == 'createbench' then
        if not isAdmin(source) then
            TriggerClientEvent('ox_lib:notify', source, { description = 'No permission.', type = 'error' })
            return
        end

        local benchType = args[2]
        local typeConfig = benchType and Config.BenchTypes[benchType]

        if not typeConfig or typeConfig.portable then
            TriggerClientEvent('ox_lib:notify', source, { description = 'Usage: /crafting createbench <type>. Fixed types: ' .. benchTypeList(), type = 'error' })
            return
        end

        TriggerClientEvent('jms_crafting:startAdminPlacement', source, benchType, typeConfig.model)
    elseif sub == 'removebench' then
        if not isAdmin(source) then
            TriggerClientEvent('ox_lib:notify', source, { description = 'No permission.', type = 'error' })
            return
        end

        local bench = JMSBenches.GetNearestBench(source, 5.0)
        if not bench then
            TriggerClientEvent('ox_lib:notify', source, { description = 'No bench within 5m.', type = 'error' })
            return
        end

        JMSBenches.RemoveBench(bench.id)
        TriggerClientEvent('ox_lib:notify', source, { description = 'Removed bench #' .. bench.id .. ' (' .. bench.benchType .. ').', type = 'success' })
    elseif sub == 'editbench' then
        if not isAdmin(source) then
            TriggerClientEvent('ox_lib:notify', source, { description = 'No permission.', type = 'error' })
            return
        end

        local bench = JMSBenches.GetNearestBench(source, 5.0)
        if not bench then
            TriggerClientEvent('ox_lib:notify', source, { description = 'No bench within 5m.', type = 'error' })
            return
        end

        local typeConfig = Config.BenchTypes[bench.benchType]
        TriggerClientEvent('jms_crafting:startAdminEdit', source, bench.id, bench.benchType, typeConfig and typeConfig.model)
    end
end, false)

RegisterNetEvent('jms_crafting:confirmAdminBench', function(benchType, coords, heading)
    local source = source
    if not isAdmin(source) then return end

    local typeConfig = Config.BenchTypes[benchType]
    if not typeConfig or typeConfig.portable then return end

    local benchId = JMSBenches.CreateBench(benchType, coords, heading, nil, false)
    TriggerClientEvent('ox_lib:notify', source, { description = 'Created ' .. typeConfig.label .. ' (#' .. tostring(benchId) .. ').', type = 'success' })
end)

RegisterNetEvent('jms_crafting:confirmAdminBenchEdit', function(benchId, coords, heading)
    local source = source
    if not isAdmin(source) then return end

    local bench = JMSBenches.Get(benchId)
    if not bench then return end

    JMSBenches.RemoveBench(benchId)
    local newId = JMSBenches.CreateBench(bench.benchType, coords, heading, bench.ownerIdentifier, bench.isPortable)
    TriggerClientEvent('ox_lib:notify', source, { description = 'Bench relocated (#' .. tostring(newId) .. ').', type = 'success' })
end)
