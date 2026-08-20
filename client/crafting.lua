local craftingOpen = false
local currentBenchId = nil

RegisterNetEvent('jms_crafting:openBench', function(benchId)
    if craftingOpen then return end
    local session = lib.callback.await('jms_crafting:getSession', false, benchId)
    if not session then return end
    craftingOpen = true
    currentBenchId = benchId
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'crafting:open', payload = session })
end)

RegisterNetEvent('jms_crafting:craftResult', function(result)
    SendNUIMessage({ type = 'crafting:result', payload = result })
    if result.ok then
        lib.notify({ type = 'success', description = Locale('craft_complete') })
    else
        lib.notify({ type = 'error', description = result.reason or Locale('missing_requirements') })
    end
end)

RegisterNUICallback('crafting:close', function(_, cb)
    craftingOpen = false
    currentBenchId = nil
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

RegisterNUICallback('crafting:start', function(data, cb)
    local response = lib.callback.await('jms_crafting:startCraft', false, {
        recipeId = tonumber(data.recipeId),
        benchId = currentBenchId
    })
    cb(response or { ok = false, reason = 'invalid_recipe' })
end)

RegisterNUICallback('crafting:cancel', function(_, cb)
    TriggerServerEvent('jms_crafting:cancelCraft')
    cb({ ok = true })
end)
