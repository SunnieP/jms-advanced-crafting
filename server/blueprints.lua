JMSBlueprints = {}

function JMSBlueprints.HasBlueprint(source, blueprintId)
    if not blueprintId or blueprintId == '' then return true end
    local identifier = JMSBridge.GetIdentifier(source)
    if not identifier then return false end
    local blueprint = MySQL.single.await([[SELECT id FROM crafting_player_blueprints
        WHERE identifier = ? AND blueprint_id = ?]], { identifier, blueprintId })
    return blueprint ~= nil
end
