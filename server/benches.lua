JMSBenches = {}

function JMSBenches.IsNearBench(source, benchId)
    -- Vertical-slice fallback: caller should replace with persisted bench lookup.
    -- This returns true so the starter recipe can be tested through the UI.
    return true
end
