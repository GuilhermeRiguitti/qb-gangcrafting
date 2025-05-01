local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local PlayerGang = {}
local craftingZones = {}
local craftingObjects = {}

-- Debug function for client side
local function DebugPrint(message)
    if Config.Debug then
        print("^3[qb-gangcrafting:client] ^7" .. message)
    end
end

-- Função para criar mesa de crafting
function CreateCraftingTable(gang, location)
    if not Config.CraftingProps[gang] then return end
    
    local propConfig = Config.CraftingProps[gang]
    local propHash = GetHashKey(propConfig.model)
    
    -- Carregar o modelo
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        Wait(10)
    end
    
    -- Criar o objeto principal (mesa)
    local coords = vector3(
        location.coords.x + propConfig.offset.x,
        location.coords.y + propConfig.offset.y,
        location.coords.z + propConfig.offset.z
    )
    
    local mainObject = CreateObject(propHash, coords.x, coords.y, coords.z, false, false, false)
    SetEntityRotation(mainObject, propConfig.rotation.x, propConfig.rotation.y, propConfig.rotation.z, 2, true)
    FreezeEntityPosition(mainObject, true)
    SetEntityAsMissionEntity(mainObject, true, true)
    
    local objectData = {
        mainObject = mainObject,
        additionalObjects = {}
    }
    
    -- Criar props adicionais se existirem
    if propConfig.additionalProps then
        for _, prop in ipairs(propConfig.additionalProps) do
            RequestModel(GetHashKey(prop.model))
            while not HasModelLoaded(GetHashKey(prop.model)) do
                Wait(10)
            end
            
            local propCoords = vector3(
                location.coords.x + prop.offset.x,
                location.coords.y + prop.offset.y,
                location.coords.z + prop.offset.z
            )
            
            local object = CreateObject(GetHashKey(prop.model), propCoords.x, propCoords.y, propCoords.z, false, false, false)
            SetEntityRotation(object, prop.rotation.x, prop.rotation.y, prop.rotation.z, 2, true)
            FreezeEntityPosition(object, true)
            SetEntityAsMissionEntity(object, true, true)
            
            table.insert(objectData.additionalObjects, object)
        end
    end
    
    DebugPrint("Criada mesa de crafting para gang " .. gang)
    return objectData
end

-- Função para remover mesa de crafting
function RemoveCraftingTable(objectData)
    if not objectData then return end
    
    if DoesEntityExist(objectData.mainObject) then
        DeleteObject(objectData.mainObject)
    end
    
    for _, object in ipairs(objectData.additionalObjects) do
        if DoesEntityExist(object) then
            DeleteObject(object)
        end
    end
    
    DebugPrint("Removida mesa de crafting")
end

-- Initialize player data
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerGang = PlayerData.gang
    DebugPrint("Player loaded, Gang: " .. PlayerGang.name)
    
    -- Clear any existing objects first
    CleanupCraftingObjects()
    
    -- Setup physical objects for all gangs (visual only)
    SetupAllCraftingObjects()
    
    -- Then setup interaction zones only for player's gang
    SetupCraftingZones()
end)

-- Update player data when gang changes
RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    PlayerGang = gang
    DebugPrint("Gang updated to: " .. PlayerGang.name)
    
    -- Remove existing crafting zones (not objects)
    for _, zone in pairs(craftingZones) do
        exports['qb-target']:RemoveZone(zone)
    end
    craftingZones = {}
    
    -- Setup new crafting zones for player's gang only
    SetupCraftingZones()
end)

-- Function to cleanup all crafting objects
function CleanupCraftingObjects()
    for zoneName, objectData in pairs(craftingObjects) do
        RemoveCraftingTable(objectData)
    end
    craftingObjects = {}
end

-- Function to setup all physical crafting objects for all gangs
function SetupAllCraftingObjects()
    -- Create objects for all gang locations
    for gang, locations in pairs(Config.CraftingTables) do
        for i, location in ipairs(locations) do
            local zoneName = "gangCrafting_" .. gang .. "_" .. i
            DebugPrint("Creating physical objects for: " .. zoneName)
            
            if Config.CraftingProps[gang] then
                local tableObject = CreateCraftingTable(gang, location)
                if tableObject then
                    craftingObjects[zoneName] = tableObject
                end
            end
        end
    end
    DebugPrint("Created physical objects for all gang crafting tables")
end

-- Function to set up interaction zones ONLY for player's gang
function SetupCraftingZones()
    if not PlayerGang or PlayerGang.name == 'none' then 
        DebugPrint("Player has no gang, not setting up crafting zones")
        return 
    end
    
    -- Check if the gang has crafting locations
    if not Config.CraftingTables[PlayerGang.name] then
        DebugPrint("No crafting tables configured for gang: " .. PlayerGang.name)
        return
    end
    
    DebugPrint("Setting up interaction zones for gang: " .. PlayerGang.name)
    
    -- Create interaction zones only for player's gang locations
    for i, location in ipairs(Config.CraftingTables[PlayerGang.name]) do
        local zoneName = "gangCrafting_" .. PlayerGang.name .. "_" .. i
        DebugPrint("Creating interaction zone: " .. zoneName)
        
        -- Increase the size of the interaction zone but make it invisible
        exports['qb-target']:AddBoxZone(zoneName, location.coords, location.length or 1.5, location.width or 1.5, {
            name = zoneName,
            heading = location.heading or 0.0,
            debugPoly = false, -- Turn off debug polygon
            minZ = location.minZ or (location.coords.z - 1.0),
            maxZ = location.maxZ or (location.coords.z + 1.0),
        }, {
            options = {
                {
                    type = "client",
                    event = "qb-gangcrafting:client:OpenCraftingMenu",
                    icon = "fas fa-tools",
                    label = "Gang Crafting",
                    gang = PlayerGang.name,
                }
            },
            distance = 3.0  -- Increased interaction distance
        })
        
        -- Only add text without marker - this is gang-specific
        CreateThread(function()
            local coords = location.coords
            local keyPressed = false
            
            while true do
                local sleep = 1500
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(pos - coords)
                
                if dist < 10.0 then
                    sleep = 0
                    
                    if dist < 3.0 then
                        -- Only show text for gang members
                        DrawText3Ds(coords.x, coords.y, coords.z + 0.5, "[E]")
                        
                        -- Direct key press interaction
                        if IsControlJustPressed(0, 38) and not keyPressed then -- 38 is E key
                            keyPressed = true
                            DebugPrint("E key pressed at crafting location")
                            TriggerEvent("qb-gangcrafting:client:OpenCraftingMenu")
                            Wait(1000) -- Prevent spamming
                            keyPressed = false
                        end
                    end
                end
                
                Wait(sleep)
            end
        end)
        
        table.insert(craftingZones, zoneName)
    end
    
    DebugPrint("Set up " .. #craftingZones .. " crafting zones")
end

-- 3D Text drawing function
function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Function to get available crafting items for player's gang
local function GetGangCraftItems()
    if not PlayerGang or not Config.IllegalCraftItems[PlayerGang.name] then return {} end
    
    local gangGrade = PlayerGang.grade.level
    local availableItems = {
        weapons = {},
        items = {},
        parts = {}  -- New category for weapon parts
    }
    
    DebugPrint("Getting craft items for gang: " .. PlayerGang.name .. " with grade: " .. gangGrade)
    
    for _, craftItem in ipairs(Config.IllegalCraftItems[PlayerGang.name]) do
        DebugPrint("Checking item: " .. craftItem.item .. " of type: " .. (craftItem.type or "unknown"))
        
        if gangGrade >= craftItem.requiredGradeLevel then
            if craftItem.type == "weapon" then
                table.insert(availableItems.weapons, craftItem)
                DebugPrint("Added weapon: " .. craftItem.item)
            elseif craftItem.type == "weapon_part" then
                -- Add to weapon parts category
                table.insert(availableItems.parts, craftItem)
                DebugPrint("Added weapon part: " .. craftItem.item)
            elseif craftItem.type == "item" then
                table.insert(availableItems.items, craftItem)
                DebugPrint("Added item: " .. craftItem.item)
            end
        end
    end
    
    DebugPrint("Found " .. #availableItems.weapons .. " weapons, " .. 
               #availableItems.items .. " items, and " .. 
               #availableItems.parts .. " weapon parts")
    
    return availableItems
end

-- Global variable to track current crafting tab
local currentCraftingTab = "weapons"

-- Event for opening the crafting menu
RegisterNetEvent('qb-gangcrafting:client:OpenCraftingMenu', function()
    local craftItems = GetGangCraftItems()
    
    -- Count available items in each category
    local weaponsCount = #craftItems.weapons
    local itemsCount = #craftItems.items
    local partsCount = #craftItems.parts
    
    -- Check if there are any items available at all
    if weaponsCount == 0 and itemsCount == 0 and partsCount == 0 then
        QBCore.Functions.Notify("Nenhum item disponível para o seu cargo na gangue", "error")
        return
    end
    
    -- Create menu with tabs
    local menuItems = {}
    
    -- Tab buttons at the top
    table.insert(menuItems, {
        header = "Menu de Fabricação Ilegal",
        txt = "Selecione uma categoria para fabricar",
        isMenuHeader = true
    })
    
    -- Only add weapon tab if there are weapons available
    if weaponsCount > 0 then
        table.insert(menuItems, {
            header = "Armas",
            txt = weaponsCount .. " itens disponíveis",
            icon = "fas fa-gun",
            params = {
                event = "qb-gangcrafting:client:ShowTab",
                args = {
                    tab = "weapons"
                }
            }
        })
    end
    
    -- Only add illegal items tab if there are items available
    if itemsCount > 0 then
        table.insert(menuItems, {
            header = "Itens Ilegais",
            txt = itemsCount .. " itens disponíveis",
            icon = "fas fa-boxes-stacked",
            params = {
                event = "qb-gangcrafting:client:ShowTab",
                args = {
                    tab = "items"
                }
            }
        })
    end
    
    -- Only add weapon parts tab if there are parts available
    if partsCount > 0 then
        table.insert(menuItems, {
            header = "Peças de Armas",
            txt = partsCount .. " itens disponíveis",
            icon = "fas fa-wrench",
            params = {
                event = "qb-gangcrafting:client:ShowTab",
                args = {
                    tab = "parts"
                }
            }
        })
    end
    
    -- Add a close button
    table.insert(menuItems, {
        header = "Fechar Menu",
        txt = "",
        icon = "fas fa-times",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    })
    
    exports['qb-menu']:openMenu(menuItems)
end)

-- Event to show specific tab content (weapons, items or parts)
RegisterNetEvent('qb-gangcrafting:client:ShowTab', function(data)
    local craftItems = GetGangCraftItems()
    local tab = data.tab
    currentCraftingTab = tab
    
    local menuItems = {}
    
    -- Header with back button
    table.insert(menuItems, {
        header = "← Voltar ao Menu Principal",
        txt = "",
        icon = "fas fa-arrow-left",
        params = {
            event = "qb-gangcrafting:client:OpenCraftingMenu"
        }
    })
    
    -- Title for the current tab
    local tabTitle = "Fabricação"
    if tab == "weapons" then
        tabTitle = "Fabricação de Armas"
    elseif tab == "items" then
        tabTitle = "Fabricação de Itens Ilegais"
    elseif tab == "parts" then
        tabTitle = "Fabricação de Peças de Armas"
    end
    
    table.insert(menuItems, {
        header = tabTitle,
        txt = "Selecione um item para ver os requisitos",
        isMenuHeader = true
    })
    
    -- List items based on selected tab
    local tabItems = {}
    if tab == "weapons" then
        tabItems = craftItems.weapons
    elseif tab == "items" then
        tabItems = craftItems.items
    elseif tab == "parts" then
        tabItems = craftItems.parts
    end
    
    -- Check if there are items in this tab
    if tabItems and #tabItems > 0 then
        for _, craftItem in ipairs(tabItems) do
            local itemInfo = QBCore.Shared.Items[craftItem.item]
            if itemInfo then
                local icon = "fas fa-box"
                if tab == "weapons" then 
                    icon = "fas fa-gun"
                elseif tab == "parts" then
                    icon = "fas fa-wrench"
                elseif craftItem.category == "ammo" then
                    icon = "fas fa-bullseye"
                elseif craftItem.category == "tools" then
                    icon = "fas fa-tools"
                end
                
                table.insert(menuItems, {
                    header = itemInfo.label,
                    txt = "Level necessário: " .. craftItem.requiredGradeLevel .. " | XP Gain: " .. craftItem.xpGain,
                    icon = icon,
                    params = {
                        event = "qb-gangcrafting:client:ShowCraftingRequirements",
                        args = {
                            item = craftItem
                        }
                    }
                })
            else
                DebugPrint("Warning: Item info not found for " .. craftItem.item)
            end
        end
    else
        -- No items available in this category (this should not normally happen, since we only show tabs with items)
        table.insert(menuItems, {
            header = "Nenhum item disponível",
            txt = "Seu cargo na gangue não tem acesso a estes itens",
            isMenuHeader = true
        })
    end
    
    -- Add close button
    table.insert(menuItems, {
        header = "Fechar Menu",
        txt = "",
        icon = "fas fa-times",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    })
    
    exports['qb-menu']:openMenu(menuItems)
end)

-- Event for showing crafting requirements
RegisterNetEvent('qb-gangcrafting:client:ShowCraftingRequirements', function(data)
    local item = data.item
    local requiredItems = {}
    
    -- Menu header
    table.insert(requiredItems, {
        header = "← Voltar",
        txt = "Retornar à lista de itens",
        icon = "fas fa-arrow-left",
        params = {
            event = "qb-gangcrafting:client:ShowTab",
            args = {
                tab = currentCraftingTab
            }
        }
    })
    
    -- Item header
    local itemInfo = QBCore.Shared.Items[item.item]
    table.insert(requiredItems, {
        header = "Fabricar: " .. itemInfo.label,
        txt = itemInfo.description or "Sem descrição disponível",
        isMenuHeader = true
    })
    
    -- Required items list
    for _, reqItem in ipairs(item.requiredItems) do
        local reqItemInfo = QBCore.Shared.Items[reqItem.item]
        if reqItemInfo then
            table.insert(requiredItems, {
                header = "Necessário: " .. reqItemInfo.label .. " x" .. reqItem.amount,
                txt = reqItemInfo.description or "Sem descrição disponível",
                icon = "fas fa-tools",
                isMenuHeader = true
            })
        else
            QBCore.Functions.Notify("Erro: Item não encontrado no banco de dados", "error")
            return
        end
    end
    
    -- Add craft button
    table.insert(requiredItems, {
        header = "Fabricar " .. QBCore.Shared.Items[item.item].label,
        txt = "Iniciar fabricação deste item",
        icon = "fas fa-hammer",
        params = {
            event = "qb-gangcrafting:client:CraftItem",
            args = {
                item = item
            }
        }
    })
    
    exports['qb-menu']:openMenu(requiredItems)
end)

-- Event for crafting an item
RegisterNetEvent('qb-gangcrafting:client:CraftItem', function(data)
    local item = data.item
    local itemName = QBCore.Shared.Items[item.item].label
    
    -- Add amount field to prevent server validation error
    item.amount = item.amount or 1
    
    -- Check if player has required items
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
        if hasItem then
            -- Enhanced crafting animation with prop and effects
            local ped = PlayerPedId()
            local animDict = "amb@prop_human_parking_meter@female@idle_a"
            local anim = "idle_a_female"
            local craftingProp = nil
            local craftingSound = nil
            local particleEffect = nil
            
            -- Load animation dictionary
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Wait(10)
            end
            
            -- Different animations and props based on item type
            if item.type == "weapon" then
                -- Create a weapon crafting prop
                craftingProp = CreateObject(GetHashKey("prop_tool_box_04"), 0, 0, 0, true, true, true)
                AttachEntityToEntity(craftingProp, ped, GetPedBoneIndex(ped, 28422), 0.0, -0.18, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                
                -- Start the crafting sound (gun assembly)
                craftingSound = GetSoundId()
                PlaySoundFromEntity(craftingSound, "Drill", ped, "DLC_HEIST_FLEECA_SOUNDSET", false, 0)
            else
                -- Different prop for non-weapon items
                local propModel = "prop_tool_box_02"
                
                -- Special props for certain categories
                if item.category == "ammo" then
                    propModel = "prop_box_ammo03a"
                elseif item.category == "tools" then
                    propModel = "prop_tool_box_02"
                end
                
                craftingProp = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                AttachEntityToEntity(craftingProp, ped, GetPedBoneIndex(ped, 28422), 0.0, -0.18, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                
                -- General crafting sound
                craftingSound = GetSoundId()
                PlaySoundFromEntity(craftingSound, "Drill", ped, "DLC_HEIST_FLEECA_SOUNDSET", false, 0)
            end
            
            -- Add particle effects for visual enhancement
            RequestNamedPtfxAsset("core")
            while not HasNamedPtfxAssetLoaded("core") do
                Wait(10)
            end
            UseParticleFxAssetNextCall("core")
            SetPtfxAssetNextCall("core")
            
            -- Sparks particle effect
            particleEffect = StartParticleFxLoopedOnEntity("ent_amb_welding", ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, false, false, false)
            
            -- Start animation
            TaskPlayAnim(ped, animDict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
            
            QBCore.Functions.Progressbar("craft_item", "Fabricando " .. itemName, 5000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                -- Stop the animation and effects
                StopAnimTask(ped, animDict, anim, 1.0)
                DeleteObject(craftingProp)
                
                if craftingSound then
                    StopSound(craftingSound)
                    ReleaseSoundId(craftingSound)
                end
                
                if particleEffect then
                    StopParticleFxLooped(particleEffect, 0)
                end
                
                -- Client-side notification before server event
                QBCore.Functions.Notify("Fabricação concluída!", "success", 3500)
                
                -- Trigger server event to complete crafting
                TriggerServerEvent('qb-gangcrafting:server:CraftItem', item)
                
             
                
                -- Register a delayed notification as a fail-safe
                SetTimeout(500, function()
                    QBCore.Functions.Notify("Item adicionado ao inventário: " .. itemName, "success", 3500)
                end)
                
                -- After crafting, return to the appropriate tab menu
                Wait(500)
                TriggerEvent('qb-gangcrafting:client:ShowTab', {tab = currentCraftingTab})
                
            end, function() -- Cancel
                -- Clean up if canceled
                StopAnimTask(ped, animDict, anim, 1.0)
                
                if craftingProp then
                    DeleteObject(craftingProp)
                end
                
                if craftingSound then
                    StopSound(craftingSound)
                    ReleaseSoundId(craftingSound)
                end
                
                if particleEffect then
                    StopParticleFxLooped(particleEffect, 0)
                end
                
                QBCore.Functions.Notify("Fabricação cancelada", "error")
            end)
        else
            QBCore.Functions.Notify("Você não tem todos os materiais necessários", "error", 3500)
        end
    end, item.requiredItems)
end)

-- Add blips for crafting locations if debug mode is on
-- Modificado para não criar blips visuais
Citizen.CreateThread(function()
    if Config.Debug then
        -- Debug no console apenas, sem criar blips visuais
        for gang, locations in pairs(Config.CraftingTables) do
            for i, location in ipairs(locations) do
                DebugPrint("Crafting location for " .. gang .. " #" .. i .. " at " .. json.encode(location.coords))
            end
        end
    end
end)

-- Initialize crafting objects when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(1000) -- Wait for QBCore to be available
        PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.gang then
            PlayerGang = PlayerData.gang
            DebugPrint("Resource started, Gang: " .. PlayerGang.name)
            
            -- Setup physical objects for everyone first
            SetupAllCraftingObjects()
            
            -- Then setup interaction for the player's gang only
            SetupCraftingZones()
        end
    end
end)

-- Garantir a limpeza dos objetos quando o recurso for parado
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CleanupCraftingObjects()
    end
end)

-- Evento para recriar as mesas
RegisterNetEvent('qb-gangcrafting:client:RefreshCraftingTables', function()
    -- Clean up all existing objects
    CleanupCraftingObjects()
    
    -- Recreate all objects for all gangs
    SetupAllCraftingObjects()
    
    -- Recreate interaction zones for player's gang
    for _, zone in pairs(craftingZones) do
        exports['qb-target']:RemoveZone(zone)
    end
    craftingZones = {}
    SetupCraftingZones()
    
    QBCore.Functions.Notify("Mesas de crafting recarregadas", "success")
end)
