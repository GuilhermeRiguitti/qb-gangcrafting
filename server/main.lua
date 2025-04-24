local QBCore = exports['qb-core']:GetCoreObject()

-- Debug function with enhanced visibility
local function DebugPrint(message)
    if Config.Debug then
        print("^3[qb-gangcrafting:server] ^7" .. message)
    end
end

-- Handle crafting request from client
RegisterNetEvent('qb-gangcrafting:server:CraftItem', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then 
        DebugPrint("Player not found: " .. src)
        return 
    end
    
    -- Enable debug temporarily to diagnose the issue
    DebugPrint("Craft request received from player " .. src)
    DebugPrint("Item data: " .. json.encode(item))
    
    -- Security verification for the item - MODIFIED: removed amount check
    if not item or not item.item or not item.type then
        DebugPrint("Invalid item data received from client")
        TriggerClientEvent('QBCore:Notify', src, "Error in crafting system", "error")
        return
    end
    
    -- Set default amount if not provided
    item.amount = item.amount or 1
    
    -- Verify the item exists in QBCore.Shared.Items
    if not QBCore.Shared.Items[item.item] then
        DebugPrint("ERROR: Item " .. item.item .. " not found in QBCore.Shared.Items")
        TriggerClientEvent('QBCore:Notify', src, "Error: Item doesn't exist in system", "error")
        return
    end
    
    DebugPrint("Player " .. Player.PlayerData.charinfo.firstname .. " attempting to craft: " .. item.label)
    
    -- Check player gang
    local playerGang = Player.PlayerData.gang.name
    local playerGangGrade = Player.PlayerData.gang.grade.level
    DebugPrint("Player Gang: " .. playerGang .. " | Grade: " .. playerGangGrade)
    
    local configGang = nil
    
    -- Find which gang this item belongs to
    for gang, _ in pairs(Config.Weapons) do
        for _, craftItem in ipairs(Config.Weapons[gang]) do
            if craftItem.item == item.item and craftItem.type == item.type then
                configGang = gang
                DebugPrint("Found matching item in gang: " .. gang)
                break
            end
        end
        if configGang then break end
    end
    
    -- Security checks
    if not configGang then
        DebugPrint("Item does not belong to any configured gang")
        TriggerClientEvent('QBCore:Notify', src, "This item cannot be crafted", "error")
        return
    end
    
    if configGang ~= playerGang then
        DebugPrint("Player gang (" .. playerGang .. ") does not match item gang (" .. configGang .. ")")
        TriggerClientEvent('QBCore:Notify', src, "You are not authorized to craft this item", "error")
        return
    end
    
    -- Check if player has the required gang grade
    local requiredGrade = 0
    local xpGain = 0
    
    for _, craftItem in ipairs(Config.Weapons[playerGang]) do
        if craftItem.item == item.item and craftItem.type == item.type then
            requiredGrade = craftItem.requiredGradeLevel
            xpGain = craftItem.xpGain
            break
        end
    end
    
    if playerGangGrade < requiredGrade then
        DebugPrint("Player grade (" .. playerGangGrade .. ") is lower than required (" .. requiredGrade .. ")")
        TriggerClientEvent('QBCore:Notify', src, "Your rank is too low to craft this item", "error")
        return
    end
    
    -- Check if player has all required materials
    local hasAllItems = true
    DebugPrint("Checking required materials:")
    for _, reqItem in ipairs(item.requiredItems) do
        local playerItem = Player.Functions.GetItemByName(reqItem.item)
        local playerAmount = playerItem and playerItem.amount or 0
        DebugPrint("Required: " .. reqItem.item .. " x" .. reqItem.amount .. " | Player has: " .. playerAmount)
        
        if not playerItem or playerItem.amount < reqItem.amount then
            hasAllItems = false
            DebugPrint("Player missing item: " .. reqItem.item .. " (has: " .. playerAmount .. ", needs: " .. reqItem.amount .. ")")
            break
        end
    end
    
    if not hasAllItems then
        TriggerClientEvent('QBCore:Notify', src, "You don't have all the required materials", "error")
        return
    end
    
    -- Remove required materials
    DebugPrint("Removing required materials:")
    for _, reqItem in ipairs(item.requiredItems) do
        Player.Functions.RemoveItem(reqItem.item, reqItem.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[reqItem.item], "remove", reqItem.amount)
        DebugPrint("Removed " .. reqItem.amount .. "x " .. reqItem.item)
    end
    
    -- Give crafted item
    DebugPrint("Giving crafted item: " .. item.item)
    local itemAmount = 1
    if item.type == "item" then
        -- For ammo or other stackable items, give a reasonable amount
        if string.find(item.item, "ammo") then
            itemAmount = 10 -- Give 10 ammo per craft
        end
    end
    
    -- Add the item to player inventory
    local success = Player.Functions.AddItem(item.item, itemAmount)
    if success then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.item], "add", itemAmount)
        DebugPrint("Successfully added " .. itemAmount .. "x " .. item.item)
        
        -- Add XP/reputation
        if xpGain > 0 then
            Player.Functions.AddGangRep(xpGain)
            TriggerClientEvent('QBCore:Notify', src, "You gained " .. xpGain .. " gang reputation", "success")
        end
        
        TriggerClientEvent('QBCore:Notify', src, "You crafted: " .. QBCore.Shared.Items[item.item].label, "success")
    else
        DebugPrint("ERROR: Failed to add crafted item to inventory")
        TriggerClientEvent('QBCore:Notify', src, "Failed to craft item - inventory issue", "error")
        -- Try to return the materials since crafting failed
        for _, reqItem in ipairs(item.requiredItems) do
            Player.Functions.AddItem(reqItem.item, reqItem.amount)
        end
    end
end)

-- Add crafting items to QB-Core shared items
Citizen.CreateThread(function()
    Citizen.Wait(1000) -- Wait for QB-Core to be fully loaded
    
    -- Define crafting materials and parts if they don't exist yet
    local newItems = {
        -- Weapon parts
        ['pistol_part_1'] = {['name'] = 'pistol_part_1', ['label'] = 'Pistol Frame', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'pistol_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'A frame for a pistol'},
        ['pistol_part_2'] = {['name'] = 'pistol_part_2', ['label'] = 'Pistol Slide', ['weight'] = 700, ['type'] = 'item', ['image'] = 'pistol_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'A slide for a pistol'},
        ['pistol_part_3'] = {['name'] = 'pistol_part_3', ['label'] = 'Pistol Grip', ['weight'] = 500, ['type'] = 'item', ['image'] = 'pistol_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'A grip for a pistol'},
        ['pistol_part_4'] = {['name'] = 'pistol_part_4', ['label'] = 'Pistol Trigger', ['weight'] = 300, ['type'] = 'item', ['image'] = 'pistol_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'A trigger for a pistol'},
        
        ['smg_part_1'] = {['name'] = 'smg_part_1', ['label'] = 'SMG Receiver', ['weight'] = 1500, ['type'] = 'item', ['image'] = 'smg_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'A receiver for an SMG'},
        ['smg_part_2'] = {['name'] = 'smg_part_2', ['label'] = 'SMG Barrel', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'smg_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'A barrel for an SMG'},
        ['smg_part_3'] = {['name'] = 'smg_part_3', ['label'] = 'SMG Stock', ['weight'] = 1200, ['type'] = 'item', ['image'] = 'smg_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'A stock for an SMG'},
        ['smg_part_4'] = {['name'] = 'smg_part_4', ['label'] = 'SMG Magazine', ['weight'] = 800, ['type'] = 'item', ['image'] = 'smg_part.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'A magazine for an SMG'},
    }
    
    -- Add items to QBCore.Shared.Items
    print("^3[qb-gangcrafting] ^7Adding crafting items to shared items")
    for itemName, itemData in pairs(newItems) do
        -- Only add if the item doesn't already exist
        if not QBCore.Shared.Items[itemName] then
            QBCore.Functions.AddItem(itemName, itemData)
            print("^3[qb-gangcrafting] ^2Added crafting item: ^7" .. itemName)
        else
            print("^3[qb-gangcrafting] ^7Item already exists: " .. itemName)
        end
    end
    
    -- Verify that all required crafting items exist
    local missingItems = {}
    
    -- Check all gang weapons items
    for gang, weapons in pairs(Config.Weapons) do
        for _, weapon in ipairs(weapons) do
            if not QBCore.Shared.Items[weapon.item] then
                table.insert(missingItems, weapon.item)
            end
            
            -- Also check required items
            if weapon.requiredItems then
                for _, reqItem in ipairs(weapon.requiredItems) do
                    if not QBCore.Shared.Items[reqItem.item] then
                        table.insert(missingItems, reqItem.item)
                    end
                end
            end
        end
    end
    
    if #missingItems > 0 then
        print("^3[qb-gangcrafting] ^1WARNING: The following items are missing from QBCore.Shared.Items:^7")
        for _, item in ipairs(missingItems) do
            print("^1- " .. item .. "^7")
        end
        print("^3[qb-gangcrafting] ^1Crafting script may not function correctly!^7")
    else
        print("^3[qb-gangcrafting] ^2All required items exist in QBCore.Shared.Items^7")
    end
end)

-- Command to check if gang crafting items exist
QBCore.Commands.Add('checkgangitems', 'Check if gang crafting items exist', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.name == "admin" or Player.PlayerData.citizenid == "admin" then
        -- Loop through all gang weapons in the config
        for gang, weapons in pairs(Config.Weapons) do
            for _, item in ipairs(weapons) do
                local exists = QBCore.Shared.Items[item.item] ~= nil
                local message = "Item '" .. item.item .. "' for gang '" .. gang .. "': "
                if exists then
                    message = message .. "^2EXISTS^7"
                else
                    message = message .. "^1MISSING^7"
                end
                TriggerClientEvent('chat:addMessage', src, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(33, 33, 33, 0.8); border-radius: 3px;">{0}</div>',
                    args = {message}
                })
            end
        end
        
        -- Also check required materials
        TriggerClientEvent('chat:addMessage', src, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(33, 33, 33, 0.8); border-radius: 3px;"><b>Checking crafting materials:</b></div>',
            args = {}
        })
        
        -- Create a table of all unique materials needed
        local materials = {}
        for gang, weapons in pairs(Config.Weapons) do
            for _, item in ipairs(weapons) do
                if item.requiredItems then
                    for _, reqItem in ipairs(item.requiredItems) do
                        materials[reqItem.item] = true
                    end
                end
            end
        end
        
        for material, _ in pairs(materials) do
            local exists = QBCore.Shared.Items[material] ~= nil
            local message = "Material '" .. material .. "': "
            if exists then
                message = message .. "^2EXISTS^7"
            else
                message = message .. "^1MISSING^7"
            end
            TriggerClientEvent('chat:addMessage', src, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(33, 33, 33, 0.8); border-radius: 3px;">{0}</div>',
                args = {message}
            })
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have permission to use this command", "error")
    end
end, "admin")

-- Command to check gang database tables
QBCore.Commands.Add('checkgangdb', 'Check gang database tables', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.job.name == "admin" or Player.PlayerData.citizenid == "admin" then
        MySQL.Async.fetchAll('SHOW TABLES LIKE "gang_%"', {}, function(result)
            if result and #result > 0 then
                TriggerClientEvent('chat:addMessage', src, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(33, 33, 33, 0.8); border-radius: 3px;"><b>Gang Database Tables:</b></div>',
                    args = {}
                })
                
                for i = 1, #result do
                    TriggerClientEvent('chat:addMessage', src, {
                        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(33, 33, 33, 0.8); border-radius: 3px;">{0}</div>',
                        args = {result[i]['Tables_in_qbcoreframework_3f0a97 (gang_%)'] or "Unknown table"}
                    })
                end
            else
                TriggerClientEvent('chat:addMessage', src, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(33, 33, 33, 0.8); border-radius: 3px;"><b>No gang tables found in database</b></div>',
                    args = {}
                })
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have permission to use this command", "error")
    end
end, "admin")

-- Command to check player's gang information
RegisterCommand('myganginfo', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local gangInfo = string.format("Gang: %s | Grade: %s (Level %d)", 
        Player.PlayerData.gang.name, 
        Player.PlayerData.gang.label, 
        Player.PlayerData.gang.grade.level
    )
    
    TriggerClientEvent('QBCore:Notify', src, gangInfo, "primary", 10000)
    
    -- Check if the player's gang has crafting configured
    if Config.Weapons[Player.PlayerData.gang.name] then
        local itemCount = #Config.Weapons[Player.PlayerData.gang.name]
        TriggerClientEvent('QBCore:Notify', src, "Your gang has " .. itemCount .. " craftable items", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Your gang doesn't have crafting configured", "error")
    end
end)

-- Utility command to find resource paths
RegisterCommand('findresource', function(source, args)
    if args[1] then
        local resourcePath = GetResourcePath(args[1])
        if resourcePath and resourcePath ~= "" then
            print("^2Resource found: ^7" .. args[1])
            print("^3Path: ^7" .. resourcePath)
        else
            print("^1Resource not found: ^7" .. args[1])
        end
    else
        print("^3Usage: ^7/findresource [resource_name]")
    end
end, true)

-- Callback to check if player has all required items
QBCore.Functions.CreateCallback('QBCore:HasItem', function(source, cb, items)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasItems = false
    local missingItems = {}
    
    if not Player then return cb(false) end
    
    -- If we're checking multiple items
    if type(items) == 'table' then
        local hasAll = true
        for _, item in ipairs(items) do
            local playerItem = Player.Functions.GetItemByName(item.item)
            if not playerItem or playerItem.amount < item.amount then
                hasAll = false
                table.insert(missingItems, QBCore.Shared.Items[item.item].label .. " (" .. (playerItem and playerItem.amount or 0) .. "/" .. item.amount .. ")")
            end
        end
        
        hasItems = hasAll
    else -- If we're checking a single item
        local item = Player.Functions.GetItemByName(items)
        hasItems = item and item.amount > 0
    end
    
    if not hasItems and #missingItems > 0 then
        TriggerClientEvent('QBCore:Notify', src, "Missing: " .. table.concat(missingItems, ", "), "error")
    end
    
    cb(hasItems)
end)
