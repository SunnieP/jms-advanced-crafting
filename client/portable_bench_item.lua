local deploying = false

local function deployPortableBenchItem(data, slot)
    if deploying then
        lib.notify({ description = 'Already deploying a bench.', type = 'error' })
        return
    end

    local benchType = 'portable_electronics_table'
    local typeConfig = Config.BenchTypes[benchType]
    if not typeConfig then return end

    deploying = true

    JMSPlacement.Start(typeConfig.model, function(coords, heading)
        TriggerServerEvent('jms_crafting:deployPortableBench', benchType, coords, heading, slot and slot.slot)
    end, function()
        deploying = false
        lib.notify({ description = 'Bench deployment cancelled.', type = 'inform' })
    end)
end

RegisterNetEvent('jms_crafting:deployResult', function(success, result)
    deploying = false
    if success then
        lib.notify({ description = 'Portable bench deployed.', type = 'success' })
    else
        local reasons = {
            limit_reached = 'You already have a portable bench deployed.',
            too_far = 'Placement is too far from you.',
            missing_item = 'You no longer have the bench item.',
            invalid_bench_type = 'Invalid bench type.',
            create_failed = 'Failed to create the bench.'
        }
        lib.notify({ description = reasons[result] or ('Could not deploy bench: ' .. tostring(result)), type = 'error' })
    end
end)

exports('deployPortableBenchItem', deployPortableBenchItem)
