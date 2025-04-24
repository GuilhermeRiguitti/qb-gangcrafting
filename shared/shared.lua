-- This file will register all crafting materials with QB-Core

local QBCore = exports['qb-core']:GetCoreObject()

-- Only add/register the shotgun parts that were missing
local craftingItems = {
    -- Add Portuguese labels for consistency with your server
    ['shotgun_part_1'] = {['name'] = 'shotgun_part_1', ['label'] = 'Receptor de Espingarda', ['weight'] = 1800, ['type'] = 'item', ['image'] = 'shotgun_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Um receptor para uma espingarda'},
    ['shotgun_part_2'] = {['name'] = 'shotgun_part_2', ['label'] = 'Cano de Espingarda', ['weight'] = 1400, ['type'] = 'item', ['image'] = 'shotgun_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Um cano para uma espingarda'},
}

-- Add all crafting items to QBCore.Shared.Items
for name, item in pairs(craftingItems) do
    if not QBCore.Shared.Items[name] then
        QBCore.Shared.Items[name] = item
        print("^3[qb-gangcrafting] ^2Added item to shared items: ^7" .. name)
    end
end
