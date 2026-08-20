# Fixed + Portable Bench System

Both bench types share one table (`crafting_benches`), one spawn/despawn pipeline (`client/benches.lua`), one placement UI (`client/placement.lua`), and one category-access gate (`JMSBenches.CanUseCategory`). Only the creation path differs.

## Bench types

Defined in `shared/config.lua`:

```lua
Config.BenchTypes = {
    electronics_bench = {
        label = 'Electronics Bench',
        model = `gr_prop_gr_bench_04b`,
        categories = { electronics = true, novelty = true },
        portable = false
    },
    portable_electronics_table = {
        label = 'Portable Electronics Table',
        model = `bkr_prop_weed_table_01b`,
        categories = { electronics = true, novelty = true },
        portable = true,
        item = 'portable_electronics_bench'
    }
}
```

Add more fixed or portable bench types by adding entries here -- no other file needs to know the difference, since both flow through the same `JMSBenches.CreateBench(benchType, coords, heading, ownerIdentifier, isPortable)`.

## Fixed benches (admin-placed, permanent)

| Command | Effect |
|---|---|
| `/crafting createbench <type>` | Starts ghost placement for a fixed bench type. Admin-only. |
| `/crafting removebench` | Removes the nearest bench within 5m. Admin-only. |
| `/crafting editbench` | Relocates the nearest bench within 5m via the same placement UI. Admin-only. |

Placement controls: move your camera to aim, **Q** rotates left, **G** rotates right, **E** confirms, **Backspace** cancels.

Admin permission is controlled by `Config.AdminGroups` in `shared/config.lua` (checks the player's ESX group).

## Portable benches (player-deployed, expirable)

Players deploy a portable bench by using the `portable_electronics_bench` item, which routes through the same placement UI, then:

- Server validates the player is within `Config.PortableBenchPlacementDistance` (default 8m) of the placement point.
- Server enforces `Config.PortableBenchMaxPerPlayer` (default 1) so a player can't spam multiple benches.
- The item is consumed via `ox_inventory:RemoveItem` only after all checks pass.
- If `Config.PortableBenchLifetimeMinutes` is set (default 720 = 12 hours), the bench auto-removes itself after that time.
- Owners (matched by ESX identifier) or admins can use the **Pack Up Bench** `ox_target` option to remove it early and get the item back.

## One manual merge step required

Add this item definition to `install/ox_inventory_items.lua` (merge it in with your other items, don't overwrite the file):

```lua
['portable_electronics_bench'] = {
    label = 'Portable Electronics Table',
    weight = 4000,
    stack = false,
    close = true,
    description = 'A foldable electronics workbench. Deploy it anywhere within reach.',
    client = {
        export = 'jms-advanced-crafting.deployPortableBenchItem'
    }
},
```

Give it to players however you like (shop, crafting, admin give) -- no other registration is needed, the export is already wired up in `client/portable_bench_item.lua`.

## No SQL migration needed

`crafting_benches` already has every column this system uses: `bench_type`, `coords` (JSON), `heading`, `owner_identifier`, `is_portable`, `enabled`. If your table predates these columns, add them:

```sql
ALTER TABLE crafting_benches
    ADD COLUMN IF NOT EXISTS bench_type VARCHAR(64) NOT NULL DEFAULT 'electronics_bench',
    ADD COLUMN IF NOT EXISTS owner_identifier VARCHAR(64) NULL,
    ADD COLUMN IF NOT EXISTS is_portable TINYINT(1) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS enabled TINYINT(1) NOT NULL DEFAULT 1;
```

## Full test checklist

1. Pull the latest resource, merge the item definition above, restart the resource.
2. As admin: `/crafting createbench electronics_bench`, place it, confirm it persists after `/restart jms-advanced-crafting`.
3. As admin: `/crafting editbench` near that bench, relocate it, confirm the new position persists.
4. As admin: `/crafting removebench` near it, confirm it's gone from all clients immediately (no restart needed).
5. Give yourself `portable_electronics_bench`, use it, place it, confirm the item is consumed only on success.
6. Try deploying a second one while the first is still out -- confirm it's blocked with "You already have a portable bench deployed."
7. Use **Pack Up Bench** on your portable bench -- confirm the item returns to your inventory and the bench disappears.
8. Log in as a second character, walk up to someone else's portable bench, confirm **Pack Up Bench** does not appear for you (not owner, not admin).
9. Open the crafting UI at both bench types and confirm Meta Glasses, Female Rose, and any other electronics/novelty recipes are all available at both.
