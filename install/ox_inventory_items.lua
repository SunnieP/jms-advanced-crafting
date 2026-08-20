-- Merge these entries into ox_inventory/data/items.lua.
-- Do not replace your existing item table.

['broken_glasses'] = {
    label = 'Broken Glasses',
    weight = 5,
    stack = true,
    close = true,
    description = 'Damaged smart glasses. Some components may still work.'
},

['battery'] = {
    label = 'Battery',
    weight = 10,
    stack = true,
    close = true,
    description = 'A salvaged battery cell with unknown remaining capacity.'
},

['cheap_phone_charger'] = {
    label = 'Cheap Phone Charger',
    weight = 1,
    stack = true,
    close = true,
    description = 'A low-cost charger with recoverable parts.'
},

['screwdriver'] = {
    label = 'Screwdriver',
    weight = 10,
    stack = false,
    close = true,
    description = 'A basic screwdriver used for assembly and repair.'
},

['meta_glasses'] = {
    label = 'Meta Glasses',
    weight = 20,
    stack = true,
    close = true,
    description = 'Refurbished smart glasses assembled from salvaged components.'
},
