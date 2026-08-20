JMSProgression = {}

function JMSProgression.RequiredXp(level)
    local index = math.max(level - 1, 0)
    return 100 + (45 * index) + (12 * index * index)
end

function JMSProgression.CalculateLevel(xp)
    local level = 1
    while xp >= JMSProgression.RequiredXp(level + 1) do
        level += 1
    end
    return level
end

function JMSProgression.GetProfile(source, categoryId)
    local identifier = JMSBridge.GetIdentifier(source)
    if not identifier then return nil end
    local global = JMSDatabase.GetProfile(identifier)
    local category = JMSDatabase.GetCategoryProfile(identifier, categoryId)
    return { global = global, category = category }
end

function JMSProgression.AddXp(source, categoryId, globalXp, categoryXp)
    local identifier = JMSBridge.GetIdentifier(source)
    if not identifier then return nil end

    local global = JMSDatabase.GetProfile(identifier)
    local category = JMSDatabase.GetCategoryProfile(identifier, categoryId)
    local newGlobalXp = global.global_xp + globalXp
    local newCategoryXp = category.xp + categoryXp
    local newGlobalLevel = JMSProgression.CalculateLevel(newGlobalXp)
    local newCategoryLevel = JMSProgression.CalculateLevel(newCategoryXp)

    MySQL.update.await('UPDATE crafting_player_profiles SET global_xp = ?, global_level = ? WHERE identifier = ?', { newGlobalXp, newGlobalLevel, identifier })
    MySQL.update.await('UPDATE crafting_player_category_xp SET xp = ?, level = ? WHERE identifier = ? AND category_id = ?', { newCategoryXp, newCategoryLevel, identifier, categoryId })

    return {
        globalXp = newGlobalXp,
        globalLevel = newGlobalLevel,
        categoryXp = newCategoryXp,
        categoryLevel = newCategoryLevel
    }
end
