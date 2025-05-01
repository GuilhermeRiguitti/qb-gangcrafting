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
        TriggerClientEvent('QBCore:Notify', src, "Erro no sistema de fabricação", "error")
        return
    end
    
    -- Set default amount if not provided
    item.amount = item.amount or 1
    
    -- Verify the item exists in QBCore.Shared.Items
    if not QBCore.Shared.Items[item.item] then
        DebugPrint("ERROR: Item " .. item.item .. " not found in QBCore.Shared.Items")
        TriggerClientEvent('QBCore:Notify', src, "Erro: Item não existe no sistema", "error")
        return
    end
    
    DebugPrint("Player " .. Player.PlayerData.charinfo.firstname .. " attempting to craft: " .. item.label)
    
    -- Check player gang
    local playerGang = Player.PlayerData.gang.name
    local playerGangGrade = Player.PlayerData.gang.grade.level
    DebugPrint("Player Gang: " .. playerGang .. " | Grade: " .. playerGangGrade)
    
    -- Check if player has the required gang grade for this item
    local requiredGrade = 0
    local xpGain = 0
    local canCraft = false
    
    -- Find this item's requirements in all gang configs to allow multiple gangs to craft the same item
    for gang, items in pairs(Config.IllegalCraftItems) do
        for _, craftItem in ipairs(items) do
            -- If this matches our crafting item
            if craftItem.item == item.item and craftItem.type == item.type then
                -- Check if this is the player's gang
                if gang == playerGang then
                    requiredGrade = craftItem.requiredGradeLevel
                    xpGain = craftItem.xpGain
                    canCraft = playerGangGrade >= requiredGrade
                    break
                end
            end
        end
        if canCraft then break end
    end
    
    if not canCraft then
        DebugPrint("Player grade (" .. playerGangGrade .. ") is lower than required (" .. requiredGrade .. ")")
        TriggerClientEvent('QBCore:Notify', src, "Seu cargo é muito baixo para fabricar este item", "error")
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
        TriggerClientEvent('QBCore:Notify', src, "Você não tem todos os materiais necessários", "error")
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
    
    -- Determine item amount based on type and category
    if item.type == "item" then
        if item.category == "ammo" then
            itemAmount = 10 -- Give 10 ammo per craft
        end
    elseif item.type == "weapon_part" then
        itemAmount = 1 -- Always give 1 weapon part
    end
    
    -- Add the item to player inventory
    local success = Player.Functions.AddItem(item.item, itemAmount)
    if success then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.item], "add", itemAmount)
        DebugPrint("Successfully added " .. itemAmount .. "x " .. item.item)
        
        -- Add XP/reputation
        if xpGain > 0 then
            Player.Functions.AddGangRep(xpGain)
            -- Use both notification methods for better reliability
            TriggerClientEvent('QBCore:Notify', src, "Você ganhou " .. xpGain .. " de reputação na gangue", "success")
            TriggerClientEvent('QBCore:ShowNotification', src, "Você ganhou " .. xpGain .. " de reputação na gangue")
        end
        
        -- Enhanced notifications using multiple methods to ensure visibility
        local itemLabel = QBCore.Shared.Items[item.item].label
        -- Primary notification
        TriggerClientEvent('QBCore:Notify', src, "Você fabricou: " .. itemLabel, "success", 3500)
        -- Backup notification using alternative method
        Wait(100) -- Small delay between notifications
        TriggerClientEvent('QBCore:ShowNotification', src, "Você fabricou: " .. itemLabel)
        -- Attempt to use a third notification type if available
        TriggerClientEvent('esx:showNotification', src, "Você fabricou: " .. itemLabel)
    else
        DebugPrint("ERROR: Failed to add crafted item to inventory")
        TriggerClientEvent('QBCore:Notify', src, "Falha ao fabricar item - problema no inventário", "error")
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
        TriggerClientEvent('QBCore:Notify', src, "Sua gangue tem " .. itemCount .. " itens fabricáveis", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Sua gangue não tem fabricação configurada", "error")
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
        TriggerClientEvent('QBCore:Notify', src, "Faltando: " .. table.concat(missingItems, ", "), "error")
    end
    
    cb(hasItems)
end)

-- Callback para obter informações sobre as mesas de crafting
QBCore.Functions.CreateCallback('qb-gangcrafting:server:GetCraftingTables', function(source, cb)
    cb(Config.CraftingTables)
end)

-- Comando para recriar as mesas de crafting (caso bugue)
QBCore.Commands.Add('refreshcrafting', 'Recriar mesas de crafting (Admin)', {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.permission == 'admin' then
        TriggerClientEvent('qb-gangcrafting:client:RefreshCraftingTables', -1)
        TriggerClientEvent('QBCore:Notify', src, "Mesas de crafting recarregadas para todos os jogadores", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Você não tem permissão", "error")
    end
end, 'admin')
