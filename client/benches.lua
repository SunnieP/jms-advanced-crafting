local spawnedBenches = {}
local playerIdentifier = nil

local function getBenchTypeConfig(benchType)
    return Config.BenchTypes[benchType]
end

local function spawnBench(bench)
    if spawnedBenches[bench.id] then return end

    local typeConfig = getBenchTypeConfig(bench.benchType)
    if not typeConfig then return end

    lib.requestModel(typeConfig.model)

    local obj = CreateObject(typeConfig.model, bench.coords.x, bench.coords.y, bench.coords.z, false, false, false)
    SetEntityHeading(obj, bench.heading or 0.0)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)

    spawnedBenches[bench.id] = { entity = obj, data = bench }

    if Config.UseOxTarget then
        exports.ox_target:addLocalEntity(obj, {
            {
                name = 'jms_crafting:use_' .. bench.id,
                icon = 'fa-solid fa-screwdriver-wrench',
                label = 'Use ' .. typeConfig.label,
                onSelect = function()
                    TriggerEvent('jms_crafting:openBench', bench.id)
                end
            },
            {
                name = 'jms_crafting:pack_' .. bench.id,
                icon = 'fa-solid fa-box',
                label = 'Pack Up Bench',
                canInteract = function()
                    if not bench.isPortable then return false end
                    return bench.ownerIdentifier == playerIdentifier or JMSAdmin and JMSAdmin.IsAdmin
                end,
                onSelect = function()
                    TriggerServerEvent('jms_crafting:pickupPortableBench', bench.id)
                end
            }
        })
    end
end

local function despawnBench(benchId)
    local entry = spawnedBenches[benchId]
    if not entry then return end

    if Config.UseOxTarget then
        exports.ox_target:removeLocalEntity(entry.entity, { 'jms_crafting:use_' .. benchId, 'jms_crafting:pack_' .. benchId })
    end

    DeleteEntity(entry.entity)
    spawnedBenches[benchId] = nil
end

local function syncBenches()
    local benches = lib.callback.await('jms_crafting:getActiveBenches', false)
    if not benches then return end

    local activeIds = {}
    for _, bench in ipairs(benches) do
        activeIds[bench.id] = true
        spawnBench(bench)
    end

    for benchId in pairs(spawnedBenches) do
        if not activeIds[benchId] then
            despawnBench(benchId)
        end
    end
end

RegisterNetEvent('jms_crafting:benchCreated', function(bench)
    spawnBench(bench)
end)

RegisterNetEvent('jms_crafting:benchRemoved', function(benchId)
    despawnBench(benchId)
end)

RegisterNetEvent('jms_crafting:setPlayerIdentifier', function(identifier)
    playerIdentifier = identifier
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Wait(1000)
    syncBenches()
    TriggerServerEvent('jms_crafting:requestIdentifier')
end)

RegisterNetEvent('jms_crafting:openBench', function(benchId)
    TriggerEvent('jms_crafting:client:openCraftingMenu', benchId)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for benchId in pairs(spawnedBenches) do
        despawnBench(benchId)
    end
end)
