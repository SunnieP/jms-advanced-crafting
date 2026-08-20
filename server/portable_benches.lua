JMSPortableBenches = {}

local function getIdentifier(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    return xPlayer.identifier
end

RegisterNetEvent('jms_crafting:requestIdentifier', function()
    local source = source
    local identifier = getIdentifier(source)
    if identifier then
        TriggerClientEvent('jms_crafting:setPlayerIdentifier', source, identifier)
    end
end)

--- Deploys a portable bench from an inventory item. Consumes the item on success.
function JMSPortableBenches.Deploy(source, benchType, coords, heading, slot)
    local identifier = getIdentifier(source)
    if not identifier then return false, 'no_player' end

    local typeConfig = Config.BenchTypes[benchType]
    if not typeConfig or not typeConfig.portable then
        return false, 'invalid_bench_type'
    end

    if Config.PortableBenchMaxPerPlayer and JMSBenches.CountOwnedPortable(identifier) >= Config.PortableBenchMaxPerPlayer then
        return false, 'limit_reached'
    end

    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - coords)
    if distance > (Config.PortableBenchPlacementDistance or 8.0) then
        return false, 'too_far'
    end

    local itemCount = exports.ox_inventory:GetItemCount(source, typeConfig.item)
    if itemCount < 1 then
        return false, 'missing_item'
    end

    local removed = exports.ox_inventory:RemoveItem(source, typeConfig.item, 1, nil, slot)
    if not removed then
        return false, 'remove_failed'
    end

    local benchId = JMSBenches.CreateBench(benchType, coords, heading, identifier, true)
    if not benchId then
        exports.ox_inventory:AddItem(source, typeConfig.item, 1)
        return false, 'create_failed'
    end

    if Config.PortableBenchLifetimeMinutes and Config.PortableBenchLifetimeMinutes > 0 then
        SetTimeout(Config.PortableBenchLifetimeMinutes * 60 * 1000, function()
            if JMSBenches.Get(benchId) then
                JMSBenches.RemoveBench(benchId)
            end
        end)
    end

    return true, benchId
end

--- Removes a portable bench and returns the deploy item to the requesting player.
function JMSPortableBenches.Pickup(source, benchId)
    local bench = JMSBenches.Get(benchId)
    if not bench then return false, 'not_found' end

    if not bench.isPortable then
        return false, 'not_portable'
    end

    local identifier = getIdentifier(source)
    local isOwner = identifier and bench.ownerIdentifier == identifier
    local isAdmin = JMSAdmin and JMSAdmin.IsAdmin(source)

    if not isOwner and not isAdmin then
        return false, 'not_owner'
    end

    if not JMSBenches.IsNearBench(source, benchId) then
        return false, 'too_far'
    end

    local typeConfig = Config.BenchTypes[bench.benchType]
    if typeConfig and typeConfig.item then
        exports.ox_inventory:AddItem(source, typeConfig.item, 1)
    end

    JMSBenches.RemoveBench(benchId)
    return true
end

RegisterNetEvent('jms_crafting:deployPortableBench', function(benchType, coords, heading, slot)
    local source = source
    local success, result = JMSPortableBenches.Deploy(source, benchType, coords, heading, slot)
    if not success then
        TriggerClientEvent('jms_crafting:deployResult', source, false, result)
    else
        TriggerClientEvent('jms_crafting:deployResult', source, true, result)
    end
end)

RegisterNetEvent('jms_crafting:pickupPortableBench', function(benchId)
    local source = source
    local success, reason = JMSPortableBenches.Pickup(source, benchId)
    if not success then
        TriggerClientEvent('ox_lib:notify', source, { description = 'Could not pack up bench: ' .. tostring(reason), type = 'error' })
    else
        TriggerClientEvent('ox_lib:notify', source, { description = 'Bench packed up.', type = 'success' })
    end
end)
