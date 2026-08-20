exports('GetCraftingProfile', function(source, categoryId)
    return JMSProgression.GetProfile(source, categoryId)
end)

exports('HasBlueprint', function(source, blueprintId)
    return JMSBlueprints.HasBlueprint(source, blueprintId)
end)
