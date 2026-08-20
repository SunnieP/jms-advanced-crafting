# JMS Crafting

ESX Legacy and Overextended-compatible crafting resource for FiveM.

## Requirements

- `es_extended`
- `ox_lib`
- `oxmysql`
- `ox_inventory`
- `ox_target` (recommended)

## Installation

1. Place this resource in your server resources directory.
2. Run `sql/jms_crafting.sql` against your server database.
3. Add the entries in `install/ox_inventory_items.lua` to your `ox_inventory` item definitions.
4. Build the NUI from `web` using `npm install` then `npm run build`.
5. Add `ensure jms_crafting` after ESX, oxmysql, ox_lib, ox_inventory, and ox_target in `server.cfg`.

## First recipe

The starter dataset includes the Meta Glasses recipe:

- 2x Broken Glasses
- 2x Battery
- 1x Cheap Phone Charger
- 1x Screwdriver (required but not consumed)
- Output: 1x Meta Glasses

## Development notes

This bootstrap intentionally produces a working vertical-slice scaffold. Expand it with recipe editing, portable benches, sale vendors, blueprints, audit records, and full editor actions once it is installed in the target server.
