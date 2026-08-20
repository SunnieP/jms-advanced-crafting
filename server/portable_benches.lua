JMSPortableBenches = {}

function JMSPortableBenches.Create(source, benchType, coords, heading)
    if not Config.EnablePortableBenches then return false, 'disabled' end
    local identifier = JMSBridge.GetIdentifier(source)
    if not identifier then return false, 'player_missing' end
    local id = MySQL.insert.await([[INSERT INTO crafting_benches
        (bench_type, coords, heading, owner_identifier, is_portable, enabled)
        VALUES (?, ?, ?, ?, 1, 1)]], { benchType, json.encode(coords), heading, identifier })
    return id
end
