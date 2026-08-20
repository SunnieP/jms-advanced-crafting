Config = {}

Config.Debug = true
Config.Locale = 'en'
Config.AdminGroups = { admin = true, superadmin = true, developer = true }
Config.UseOxTarget = true
Config.CraftDistance = 3.0
Config.DefaultCraftDistance = 2.25
Config.MaxCraftQuantity = 10
Config.EnablePortableBenches = true
Config.PortableBenchLifetimeMinutes = 720
Config.PortableBenchMaxPerPlayer = 1
Config.PortableBenchPlacementDistance = 8.0

-- Bench types are shared between fixed (admin-placed) and portable (player-deployed) benches.
-- Both are stored in the same crafting_benches table; only is_portable and owner_identifier differ.
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

Config.DefaultBench = {
    type = 'electronics_bench',
    label = 'Public Tech Workbench',
    coords = vec3(0.0, 0.0, 0.0),
    heading = 0.0,
    model = `gr_prop_gr_bench_04b`,
    radius = 2.0,
    categories = { electronics = true, novelty = true }
}
