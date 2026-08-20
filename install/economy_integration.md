# Crafting Economy Loops

This document covers everything needed to connect the Meta Glasses and Female Rose recipes to your existing job, loot, and reseller systems.

## Meta Glasses

```text
Detector job (ak47_prospecting) -> Broken Glasses
Dumpster loot (ox_inventory)    -> Battery
Gas station shop (existing)     -> Cheap Phone Charger
YouTool shop (existing)         -> Screwdriver
Electronics Bench (jms_crafting)-> Meta Glasses
Pawn shop (ak47_drugmanager)    -> Cash payout ($300-$750)
```

### 1. ak47_prospecting loot table

No item rename needed. `jms_crafting` uses the exact key your prospecting script already drops: `brokenglasses` (no underscore).

Optional: duplicate the row two or three times in the pool to raise its drop weight, since it now feeds a crafting recipe:

```lua
('brokenglasses', 'Broken Glasses', 1),
('brokenglasses', 'Broken Glasses', 1),
('brokenglasses', 'Broken Glasses', 1),
```

### 2. ox_inventory dumpster loot

Add `battery` to the dumpster convar:

```lua
set inventory:dumpsterloot [
    ["mustard", 1, 1],
    ["garbage", 1, 3],
    ["money", 1, 10],
    ["burger", 1, 1],
    ["battery", 1, 2]
]
```

### 3. Gas station and YouTool shops

No changes required. `cheap_phone_charger` and `screwdriver` already exist in their respective shops.

### 4. ak47_drugmanager sell entry

```lua
["meta_glasses"] = {
    name = "meta_glasses",
    label = "Meta Glasses",
    minamount = 1,
    maxamount = 1,
    minprice = 300,
    maxprice = 750,
},
```

## Female Rose

```text
Trash job / Mining         -> Rubber (x10 per craft)
Dumpster loot (ox_inventory)-> Battery (x2 per craft)
Gas station shop (existing)-> Cheap Phone Charger (x1 per craft)
Electronics Bench (jms_crafting) -> Female Rose
Pawn shop (ak47_drugmanager)     -> Cash payout ($300-$750)
```

Female Rose shares its `battery` and `cheap_phone_charger` sourcing with Meta Glasses, so no additional setup is needed for those two. The only new sourcing requirement is `rubber`.

### 1. Rubber sourcing (trash job / mining)

Add `rubber` as a possible reward/drop in whichever trash job and mining script you're running. This resource does not control those loot tables directly -- add the item to each script's own reward or loot pool configuration using the item key `rubber`.

### 2. ak47_drugmanager sell entry

```lua
["female_rose"] = {
    name = "female_rose",
    label = "Female Rose",
    minamount = 1,
    maxamount = 1,
    minprice = 300,
    maxprice = 750,
},
```

### 3. Gender restriction

Female Rose is restricted to characters with `sex = 'f'` on the `users` table. This is enforced server-side in `server/crafting.lua` via `JMSBridge.GetSex(source)`, which queries:

```sql
SELECT sex FROM users WHERE identifier = ?
```

Behavior:

- The recipe is visible in the crafting UI regardless of gender, but is marked as unavailable (`genderAllowed = false`) for characters whose `sex` column is not `'f'`.
- The server rejects `startCraft` for a mismatched gender with reason `gender_restricted`, even if a player attempts to bypass the UI lock.
- If the `sex` column is null or missing for a player, the recipe is treated as unavailable (fails closed, not open).

No other recipes are gender-restricted by default. To add a gender restriction to a future recipe, set the `gender_restriction` column on `crafting_recipes` to `'m'` or `'f'`, or leave it `NULL` for no restriction.

## Full loop test checklist

### Meta Glasses

1. Use the detector job until you receive `brokenglasses`.
2. Search dumpsters until you receive `battery` x2.
3. Buy `cheap_phone_charger` at the gas station.
4. Buy or already own `screwdriver` from YouTool.
5. Go to the Electronics Bench and run `/craft`.
6. Confirm the Meta Glasses recipe shows all requirements met, then craft.
7. Confirm `meta_glasses` appears in inventory and the screwdriver was **not** consumed.
8. Sell through `ak47_drugmanager` and confirm payout lands between $300-$750.

### Female Rose

1. Confirm the crafting character has `sex = 'f'` on the `users` table.
2. Farm `rubber` x10 via trash job or mining.
3. Farm `battery` x2 via dumpster.
4. Buy `cheap_phone_charger` at the gas station.
5. Go to the Electronics Bench and run `/craft`.
6. Confirm the Female Rose recipe shows as available for a female character.
7. Log in as (or switch to) a male character and confirm the recipe shows as unavailable/blocked.
8. Craft as the female character, confirm `female_rose` appears in inventory.
9. Sell through `ak47_drugmanager` and confirm payout lands between $300-$750.
