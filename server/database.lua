JMSDatabase = {}

function JMSDatabase.GetProfile(identifier)
    local profile = MySQL.single.await('SELECT * FROM crafting_player_profiles WHERE identifier = ?', { identifier })
    if profile then return profile end

    MySQL.insert.await('INSERT INTO crafting_player_profiles (identifier, global_xp, global_level) VALUES (?, 0, 1)', { identifier })
    return { identifier = identifier, global_xp = 0, global_level = 1 }
end

function JMSDatabase.GetCategoryProfile(identifier, categoryId)
    local profile = MySQL.single.await([[SELECT * FROM crafting_player_category_xp
        WHERE identifier = ? AND category_id = ?]], { identifier, categoryId })
    if profile then return profile end

    MySQL.insert.await([[INSERT INTO crafting_player_category_xp
        (identifier, category_id, xp, level) VALUES (?, ?, 0, 1)]], { identifier, categoryId })
    return { identifier = identifier, category_id = categoryId, xp = 0, level = 1 }
end

function JMSDatabase.GetRecipes()
    local recipes = MySQL.query.await('SELECT * FROM crafting_recipes WHERE enabled = 1 ORDER BY id') or {}
    for i = 1, #recipes do
        local recipe = recipes[i]
        recipe.ingredients = MySQL.query.await('SELECT * FROM crafting_recipe_ingredients WHERE recipe_id = ? ORDER BY id', { recipe.id }) or {}
        recipe.results = MySQL.query.await('SELECT * FROM crafting_recipe_results WHERE recipe_id = ? ORDER BY id', { recipe.id }) or {}
        recipe.tools = MySQL.query.await('SELECT * FROM crafting_recipe_tools WHERE recipe_id = ? ORDER BY id', { recipe.id }) or {}
    end
    return recipes
end

function JMSDatabase.GetRecipe(recipeId)
    local recipe = MySQL.single.await('SELECT * FROM crafting_recipes WHERE id = ? AND enabled = 1', { recipeId })
    if not recipe then return nil end
    recipe.ingredients = MySQL.query.await('SELECT * FROM crafting_recipe_ingredients WHERE recipe_id = ? ORDER BY id', { recipe.id }) or {}
    recipe.results = MySQL.query.await('SELECT * FROM crafting_recipe_results WHERE recipe_id = ? ORDER BY id', { recipe.id }) or {}
    recipe.tools = MySQL.query.await('SELECT * FROM crafting_recipe_tools WHERE recipe_id = ? ORDER BY id', { recipe.id }) or {}
    return recipe
end
