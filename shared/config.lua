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

Config.DefaultBench = {
    type = 'public_tech_workbench',
    label = 'Public Tech Workbench',
    coords = vec3(0.0, 0.0, 0.0),
    heading = 0.0,
    model = `gr_prop_gr_bench_04b`,
    radius = 2.0,
    categories = { electronics = true }
}
