Locales = {
    en = {
        open_bench = 'Open crafting bench',
        craft_started = 'Crafting started',
        craft_complete = 'Craft complete',
        craft_cancelled = 'Craft cancelled',
        too_far = 'You are too far from the crafting bench.',
        missing_requirements = 'You do not meet the recipe requirements.',
        inventory_full = 'You cannot carry the result.',
        no_permission = 'You do not have permission to use this.',
        invalid_recipe = 'That recipe is unavailable.'
    }
}

function Locale(key)
    return (Locales[Config.Locale] or Locales.en)[key] or key
end
