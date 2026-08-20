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

-- Returns 'm' or 'f' based on the users.sex column, or nil if unavailable.
function JMSBridge.GetSex(source)
    local identifier = JMSBridge.GetIdentifier(source)
    if not identifier then return nil end

    local row = MySQL.single.await('SELECT sex FROM users WHERE identifier = ?', { identifier })
    if not row or not row.sex then return nil end

    return string.lower(row.sex)
end
