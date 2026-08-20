# Meta Glasses Economy Loop

This document covers everything needed to connect the Meta Glasses recipe to your existing job, loot, and reseller systems.

```text
Detector job (ak47_prospecting) -> Broken Glasses
Dumpster loot (ox_inventory)    -> Battery
Gas station shop (existing)     -> Cheap Phone Charger
YouTool shop (existing)         -> Screwdriver
Electronics Bench (jms_crafting)-> Meta Glasses
Pawn shop (ak47_drugmanager)    -> Cash payout
```

## 1. ak47_prospecting loot table

No item rename needed on your side. `jms_crafting` now uses the exact same key your prospecting script already drops: `brokenglasses` (no underscore).

Current pool for reference:

```lua
('actioncam', 'Action Camera', 1),
('brokenglasses', 'Broken Glasses', 1),
('brokenpendrive', 'Broken Pendrive', 1),
('brokenphone', 'Broken Phone', 1),
('dianecklace', 'Dia Necklace', 1),
('gem', 'Gem', 1),
('goldchain', 'Gold Chain', 1),
('goldrolex', 'Gold Rolex', 1),
('detector', 'Detector', 1),
('rustygun', 'Rusty Gun', 1),
('rustedrod', 'Rusted Rod', 1),
('weddingring', 'Wedding Ring', 1)
```

Optional: to make Broken Glasses slightly more common than a one-in-twelve chance (since it feeds a crafting recipe), duplicate the row two or three times in the pool, for example:

```lua
('brokenglasses', 'Broken Glasses', 1),
('brokenglasses', 'Broken Glasses', 1),
('brokenglasses', 'Broken Glasses', 1),
```

## 2. ox_inventory dumpster loot

Add `battery` to the dumpster convar so it can be found while scavenging:

```lua
set inventory:dumpsterloot [
    ["mustard", 1, 1],
    ["garbage", 1, 3],
    ["money", 1, 10],
    ["burger", 1, 1],
    ["battery", 1, 2]
]
```

The third value is the relative weight. `2` makes batteries roughly twice as common as burgers -- common enough to farm, not guaranteed every dumpster.

## 3. Gas station and YouTool shops

No changes required. Both `cheap_phone_charger` and `screwdriver` already exist in their respective shops. The crafting resource only checks live inventory counts, regardless of where the item came from.

## 4. ak47_drugmanager pawn shop sell entry

Add this entry to your `ak47_drugmanager` sell items config, matching your existing schema:

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

`minamount`/`maxamount` are set to 1 because Meta Glasses are a finished, valuable item rather than a bulk commodity like a meth pouch. Adjust upward later if you want players to be able to sell more than one per transaction.

## 5. Crafted-item provenance (optional, currently disabled)

The current build does **not** enforce `metadata.crafted == true` before allowing a sale. This keeps the loop simple for a personal server. If you later want to prevent players from selling store-bought or duplicated Meta Glasses through the pawn shop, we can add a metadata check on the `ak47_drugmanager` sell hook (or a wrapper event) that rejects items missing that flag.

## Full loop test checklist

1. Use the detector job until you receive `brokenglasses` (may take multiple attempts depending on pool weighting).
2. Search dumpsters until you receive `battery` x2.
3. Buy `cheap_phone_charger` at the gas station.
4. Buy or already own `screwdriver` from YouTool.
5. Go to the Electronics Bench and run `/craft`.
6. Confirm the Meta Glasses recipe shows all four requirements met, then craft.
7. Confirm `meta_glasses` appears in your inventory and the screwdriver was **not** consumed.
8. Take the Meta Glasses to your player-owned pawn shop and sell through `ak47_drugmanager`.
9. Confirm the cash payout lands between $300 and $750.
