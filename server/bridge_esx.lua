local ESX = exports.es_extended:getSharedObject()

JMSBridge = {}

function JMSBridge.GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function JMSBridge.GetIdentifier(source)
    local xPlayer = JMSBridge.GetPlayer(source)
    return xPlayer and xPlayer.identifier or nil
end

function JMSBridge.GetJob(source)
    local xPlayer = JMSBridge.GetPlayer(source)
    return xPlayer and xPlayer.job or nil
end

function JMSBridge.IsAdmin(source)
    if source == 0 then return true end
    local xPlayer = JMSBridge.GetPlayer(source)
    if not xPlayer then return false end
    local group = xPlayer.getGroup and xPlayer.getGroup() or 'user'
    return Config.AdminGroups[group] == true
end
