JMSBenches = {}
local benches = {}

local function loadBenches()
    local rows = MySQL.query.await('SELECT * FROM crafting_benches WHERE enabled = 1') or {}
    for i = 1, #rows do
        local row = rows[i]
        local ok, coords = pcall(json.decode, row.coords)
        if ok and coords then
            benches[row.id] = {
                id = row.id,
                benchType = row.bench_type,
                coords = vector3(coords.x, coords.y, coords.z),
                heading = row.heading or 0.0,
                ownerIdentifier = row.owner_identifier,
                isPortable = row.is_portable == 1
            }
        end
    end
end

CreateThread(loadBenches)

function JMSBenches.GetAll()
    local list = {}
    for _, bench in pairs(benches) do
        list[#list + 1] = bench
    end
    return list
end

function JMSBenches.Get(benchId)
    return benches[benchId]
end

function JMSBenches.CountOwnedPortable(identifier)
    local count = 0
    for _, bench in pairs(benches) do
        if bench.isPortable and bench.ownerIdentifier == identifier then
            count += 1
        end
    end
    return count
end

function JMSBenches.CreateBench(benchType, coords, heading, ownerIdentifier, isPortable)
    local typeConfig = Config.BenchTypes[benchType]
    if not typeConfig then return nil, 'invalid_bench_type' end

    local id = MySQL.insert.await([[INSERT INTO crafting_benches
        (bench_type, coords, heading, owner_identifier, is_portable, enabled)
        VALUES (?, ?, ?, ?, ?, 1)]], {
        benchType,
        json.encode({ x = coords.x, y = coords.y, z = coords.z }),
        heading,
        ownerIdentifier,
        isPortable and 1 or 0
    })

    benches[id] = {
        id = id,
        benchType = benchType,
        coords = coords,
        heading = heading,
        ownerIdentifier = ownerIdentifier,
        isPortable = isPortable
    }

    TriggerClientEvent('jms_crafting:benchCreated', -1, benches[id])
    return id
end

function JMSBenches.RemoveBench(benchId)
    local bench = benches[benchId]
    if not bench then return false end

    MySQL.update.await('UPDATE crafting_benches SET enabled = 0 WHERE id = ?', { benchId })
    benches[benchId] = nil
    TriggerClientEvent('jms_crafting:benchRemoved', -1, benchId)
    return true
end

function JMSBenches.CanUseCategory(benchId, categoryId)
    local bench = benches[benchId]
    if not bench then return false end

    local typeConfig = Config.BenchTypes[bench.benchType]
    if not typeConfig then return false end

    return typeConfig.categories[categoryId] == true
end

function JMSBenches.IsNearBench(source, benchId)
    local bench = benches[benchId]
    if not bench then return false end

    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end

    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - bench.coords)

    return distance <= (Config.CraftDistance or 3.0)
end

function JMSBenches.GetNearestBench(source, maxDistance)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return nil end

    local playerCoords = GetEntityCoords(ped)
    local nearestBench = nil
    local nearestDistance = maxDistance or 5.0

    for _, bench in pairs(benches) do
        local distance = #(playerCoords - bench.coords)
        if distance <= nearestDistance then
            nearestBench = bench
            nearestDistance = distance
        end
    end

    return nearestBench
end

lib.callback.register('jms_crafting:getActiveBenches', function(source)
    return JMSBenches.GetAll()
end)
