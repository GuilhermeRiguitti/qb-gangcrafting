-- This file will register any missing crafting materials with QB-Core

local QBCore = exports['qb-core']:GetCoreObject()

-- Only register items that might be missing - removed custom items that aren't in QB-Core items.lua
local craftingItems = {
    -- Only add the shotgun parts if they're not already in QBCore.Shared.Items
    ['shotgun_part_1'] = not QBCore.Shared.Items['shotgun_part_1'] and {['name'] = 'shotgun_part_1', ['label'] = 'Receptor de Espingarda', ['weight'] = 1800, ['type'] = 'item', ['image'] = 'shotgun_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Um receptor para uma espingarda'} or nil,
    ['shotgun_part_2'] = not QBCore.Shared.Items['shotgun_part_2'] and {['name'] = 'shotgun_part_2', ['label'] = 'Cano de Espingarda', ['weight'] = 1400, ['type'] = 'item', ['image'] = 'shotgun_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Um cano para uma espingarda'} or nil,
}

-- Add only missing items to QBCore.Shared.Items
for name, item in pairs(craftingItems) do
    if item and not QBCore.Shared.Items[name] then
        QBCore.Shared.Items[name] = item
        print("^3[qb-gangcrafting] ^2Added missing item to shared items: ^7" .. name)
    end
end

-- Check for debug purposes - list all required items to ensure they exist in QB-Core
if Config.Debug then
    print("^3[qb-gangcrafting] ^7Checking availability of required crafting items:")
    
    -- Create a list of all items used in the crafting config
    local requiredItems = {}
    for gangName, gangItems in pairs(Config.IllegalCraftItems) do
        for _, craftItem in ipairs(gangItems) do
            -- Add the craftable item itself
            requiredItems[craftItem.item] = true
            
            -- Add all required materials
            if craftItem.requiredItems then
                for _, reqItem in ipairs(craftItem.requiredItems) do
                    requiredItems[reqItem.item] = true
                end
            end
        end
    end
    
    -- Check each required item against QB-Core
    local missingItems = {}
    for itemName, _ in pairs(requiredItems) do
        if QBCore.Shared.Items[itemName] then
            print("^2✓ " .. itemName .. " is available^7")
        else
            print("^1✗ " .. itemName .. " is NOT available in QB-Core^7")
            table.insert(missingItems, itemName)
        end
    end
    
    -- Display warning if any items are missing
    if #missingItems > 0 then
        print("^1[WARNING] ^7The following items are required but not available in QB-Core. They will not appear in the crafting menu: ")
        for _, itemName in ipairs(missingItems) do
            print("^1- " .. itemName .. "^7")
        end
    end
end
