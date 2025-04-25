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

-- Callback to sync crafting animations between players
RegisterNetEvent('qb-gangcrafting:server:SyncCraftingAnimation', function(coords)
    local src = source
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local dist = #(coords - vector3(pedCoords.x, pedCoords.y, pedCoords.z))
    
    -- Security check to prevent abuse - only sync if player is near the claimed position
    if dist > 10.0 then
        DebugPrint("Player attempted to sync animation from too far away")
        return
    end
    
    -- Broadcast animation to all nearby players (except source)
    TriggerClientEvent('qb-gangcrafting:client:SyncCraftingAnimation', -1, coords, src)
end)

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
