JMSCrafting = {}
local activeCrafts = {}

local function hasItems(source, entries)
    for i = 1, #entries do
        local entry = entries[i]
        if (exports.ox_inventory:Search(source, 'count', entry.item_name) or 0) < entry.amount then
            return false, entry.item_name
        end
    end
    return true
end

local function canCarryResults(source, results)
    for i = 1, #results do
        local result = results[i]
        if not exports.ox_inventory:CanCarryItem(source, result.item_name, result.amount) then
            return false, result.item_name
        end
    end
    return true
end

local function meetsGenderRestriction(source, recipe)
    if not recipe.gender_restriction or recipe.gender_restriction == '' then return true end
    local sex = JMSBridge.GetSex(source)
    if not sex then return false end
    return sex == string.lower(recipe.gender_restriction)
end

local function buildRecipePayload(source, recipe)
    local profile = JMSProgression.GetProfile(source, recipe.category_id)
    local ingredients = {}
    local tools = {}
    for i = 1, #recipe.ingredients do
        local entry = recipe.ingredients[i]
        ingredients[#ingredients + 1] = {
            item = entry.item_name,
            amount = entry.amount,
            owned = exports.ox_inventory:Search(source, 'count', entry.item_name) or 0,
            consume = true
        }
    end
    for i = 1, #recipe.tools do
        local entry = recipe.tools[i]
        tools[#tools + 1] = {
            item = entry.item_name,
            amount = entry.amount,
            owned = exports.ox_inventory:Search(source, 'count', entry.item_name) or 0,
            consume = false
        }
    end
    return {
        id = recipe.id,
        slug = recipe.slug,
        label = recipe.label,
        description = recipe.description,
        category = recipe.category_id,
        craftTime = recipe.craft_time_ms,
        globalXp = recipe.global_xp,
        categoryXp = recipe.category_xp,
        requiredGlobalLevel = recipe.required_global_level,
        requiredCategoryLevel = recipe.required_category_level,
        blueprintId = recipe.blueprint_id,
        genderRestriction = recipe.gender_restriction,
        genderAllowed = meetsGenderRestriction(source, recipe),
        ingredients = ingredients,
        tools = tools,
        results = recipe.results,
        player = profile
    }
end

lib.callback.register('jms_crafting:getSession', function(source, benchId)
    local recipes = JMSDatabase.GetRecipes()
    local payload = {}
    for i = 1, #recipes do
        payload[#payload + 1] = buildRecipePayload(source, recipes[i])
    end
    return { benchId = benchId, recipes = payload }
end)

lib.callback.register('jms_crafting:startCraft', function(source, data)
    if activeCrafts[source] then return { ok = false, reason = 'already_crafting' } end
    if type(data) ~= 'table' or type(data.recipeId) ~= 'number' then return { ok = false, reason = 'invalid_recipe' } end

    local recipe = JMSDatabase.GetRecipe(data.recipeId)
    if not recipe then return { ok = false, reason = 'invalid_recipe' } end
    if not JMSBenches.IsNearBench(source, data.benchId) then return { ok = false, reason = 'too_far' } end

    if not meetsGenderRestriction(source, recipe) then return { ok = false, reason = 'gender_restricted' } end

    local profile = JMSProgression.GetProfile(source, recipe.category_id)
    if profile.global.global_level < recipe.required_global_level then return { ok = false, reason = 'global_level' } end
    if profile.category.level < recipe.required_category_level then return { ok = false, reason = 'category_level' } end
    if not JMSBlueprints.HasBlueprint(source, recipe.blueprint_id) then return { ok = false, reason = 'blueprint' } end

    local toolOk = hasItems(source, recipe.tools)
    if not toolOk then return { ok = false, reason = 'missing_tool' } end
    local materialOk = hasItems(source, recipe.ingredients)
    if not materialOk then return { ok = false, reason = 'missing_materials' } end
    local carryOk = canCarryResults(source, recipe.results)
    if not carryOk then return { ok = false, reason = 'inventory_full' } end

    activeCrafts[source] = { recipeId = recipe.id, benchId = data.benchId, startedAt = os.time() }
    SetTimeout(recipe.craft_time_ms, function()
        local craft = activeCrafts[source]
        if not craft or craft.recipeId ~= recipe.id then return end
        activeCrafts[source] = nil

        if not JMSBenches.IsNearBench(source, craft.benchId) then
            TriggerClientEvent('jms_crafting:craftResult', source, { ok = false, reason = 'too_far' })
            return
        end

        local materialsStillPresent = hasItems(source, recipe.ingredients)
        local carryStillValid = canCarryResults(source, recipe.results)
        if not materialsStillPresent or not carryStillValid then
            TriggerClientEvent('jms_crafting:craftResult', source, { ok = false, reason = 'requirements_changed' })
            return
        end

        for i = 1, #recipe.ingredients do
            local ingredient = recipe.ingredients[i]
            exports.ox_inventory:RemoveItem(source, ingredient.item_name, ingredient.amount)
        end

        for i = 1, #recipe.results do
            local result = recipe.results[i]
            local metadata = {
                crafted = true,
                craftedAt = os.time(),
                craftedBy = JMSBridge.GetIdentifier(source),
                recipeId = recipe.slug,
                condition = 100
            }
            exports.ox_inventory:AddItem(source, result.item_name, result.amount, metadata)
        end

        local levels = JMSProgression.AddXp(source, recipe.category_id, recipe.global_xp, recipe.category_xp)
        TriggerClientEvent('jms_crafting:craftResult', source, { ok = true, recipeId = recipe.id, levels = levels })
    end)

    return { ok = true, duration = recipe.craft_time_ms }
end)

RegisterNetEvent('jms_crafting:cancelCraft', function()
    activeCrafts[source] = nil
end)

AddEventHandler('playerDropped', function()
    activeCrafts[source] = nil
end)
