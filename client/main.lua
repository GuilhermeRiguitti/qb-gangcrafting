local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local PlayerGang = {}
local craftingZones = {}

-- Debug function for client side
local function DebugPrint(message)
    if Config.Debug then
        print("^3[qb-gangcrafting:client] ^7" .. message)
    end
end

-- Initialize player data
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerGang = PlayerData.gang
    DebugPrint("Player loaded, Gang: " .. PlayerGang.name)
    SetupCraftingZones()
end)

-- Update player data when gang changes
RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    PlayerGang = gang
    DebugPrint("Gang updated to: " .. PlayerGang.name)
    
    -- Remove existing crafting zones
    for _, zone in pairs(craftingZones) do
        exports['qb-target']:RemoveZone(zone)
    end
    craftingZones = {}
    
    -- Setup new crafting zones
    SetupCraftingZones()
end)

-- Function to set up all crafting zones based on player's gang
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
    
    DebugPrint("Setting up crafting zones for gang: " .. PlayerGang.name)
    
    -- Create a target zone for each crafting table
    for i, location in ipairs(Config.CraftingTables[PlayerGang.name]) do
        local zoneName = "gangCrafting_" .. PlayerGang.name .. "_" .. i
        DebugPrint("Creating zone: " .. zoneName .. " at " .. json.encode(location.coords))
        
        exports['qb-target']:AddBoxZone(zoneName, location.coords, location.length or 1.0, location.width or 1.0, {
            name = zoneName,
            heading = location.heading or 0.0,
            debugPoly = Config.Debug,
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
            distance = 2.0
        })
        
        -- Also add a 3D marker and text to make it more visible
        CreateThread(function()
            local coords = location.coords
            while true do
                local inRange = false
                local pos = GetEntityCoords(PlayerPedId())
                local dist = #(pos - coords)
                
                if dist < 10.0 then
                    inRange = true
                    DrawMarker(2, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.2, 210, 50, 9, 255, false, false, false, true, false, false, false)
                    
                    if dist < 3.0 then
                        DrawText3Ds(coords.x, coords.y, coords.z + 0.3, "[E] Gang Crafting")
                    end
                end
                
                if not inRange then
                    Wait(1500)
                else
                    Wait(0)
                end
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

-- Function to get available weapons for player's gang
local function GetGangWeapons()
    if not PlayerGang or not Config.Weapons[PlayerGang.name] then return {} end
    
    local gangGrade = PlayerGang.grade.level
    local availableWeapons = {}
    
    for _, weapon in ipairs(Config.Weapons[PlayerGang.name]) do
        if gangGrade >= weapon.requiredGradeLevel then
            table.insert(availableWeapons, weapon)
        end
    end
    
    return availableWeapons
end

-- Event for opening the crafting menu
RegisterNetEvent('qb-gangcrafting:client:OpenCraftingMenu', function()
    local weapons = GetGangWeapons()
    
    if #weapons == 0 then
        QBCore.Functions.Notify("No weapons available for your gang rank", "error")
        return
    end
    
    local menuItems = {}
    for _, weapon in ipairs(weapons) do
        local itemInfo = QBCore.Shared.Items[weapon.item]
        if itemInfo then
            table.insert(menuItems, {
                header = itemInfo.label,
                txt = "Required Gang Rank: " .. weapon.requiredGradeLevel .. " | XP Gain: " .. weapon.xpGain,
                icon = "fas fa-" .. (weapon.type == "weapon" and "gun" or "box"),
                params = {
                    event = "qb-gangcrafting:client:ShowCraftingRequirements",
                    args = {
                        item = weapon
                    }
                }
            })
        end
    end
    
    if #menuItems == 0 then
        QBCore.Functions.Notify("No craftable items available", "error")
        return
    end
    
    -- Add a close button
    table.insert(menuItems, {
        header = "Close Menu",
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
    
    for _, reqItem in ipairs(item.requiredItems) do
        local itemInfo = QBCore.Shared.Items[reqItem.item]
        if itemInfo then
            table.insert(requiredItems, {
                header = "Required: " .. itemInfo.label .. " x" .. reqItem.amount,
                txt = itemInfo.description or "No description available",
                icon = "fas fa-tools",
                isMenuHeader = true
            })
        else
            QBCore.Functions.Notify("Error: Item not found in database", "error")
            return
        end
    end
    
    -- Add craft button
    table.insert(requiredItems, {
        header = "Craft " .. QBCore.Shared.Items[item.item].label,
        txt = "Start crafting this item",
        icon = "fas fa-hammer",
        params = {
            event = "qb-gangcrafting:client:CraftItem",
            args = {
                item = item
            }
        }
    })
    
    -- Add back button
    table.insert(requiredItems, {
        header = "Go Back",
        txt = "Return to main menu",
        icon = "fas fa-arrow-left",
        params = {
            event = "qb-gangcrafting:client:OpenCraftingMenu"
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
            local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
            local anim = "machinic_loop_mechandplayer"
            local craftingProp = nil
            local craftingSound = nil
            local particleEffect = nil
            
            -- Load animation dictionary
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Wait(10)
            end
            
            -- Animation and crafting logic with enhanced effects
            if item.type == "weapon" then
                -- Create a weapon crafting prop
                craftingProp = CreateObject(GetHashKey("prop_tool_box_04"), 0, 0, 0, true, true, true)
                AttachEntityToEntity(craftingProp, ped, GetPedBoneIndex(ped, 28422), 0.0, -0.18, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                
                -- Start the crafting sound (gun assembly)
                craftingSound = GetSoundId()
                PlaySoundFromEntity(craftingSound, "Drill", ped, "DLC_HEIST_FLEECA_SOUNDSET", false, 0)
            else
                -- Different prop for non-weapon items
                craftingProp = CreateObject(GetHashKey("prop_tool_box_02"), 0, 0, 0, true, true, true)
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
                
                -- Success notification and explosion effect for completion
                if item.type == "weapon" then
                    -- Small smoke puff for weapon completion
                    UseParticleFxAssetNextCall("core")
                    StartParticleFxNonLoopedAtCoord("ent_sht_steam", GetEntityCoords(ped), 0.0, 0.0, 0.0, 0.5, false, false, false)
                    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                end
                
                TriggerServerEvent('qb-gangcrafting:server:CraftItem', item)
                QBCore.Functions.Notify("Finished crafting " .. itemName, "success")
                
                -- Add a cool 'finishing touch' animation
                RequestAnimDict("anim@mp_player_intuppergolf")
                while not HasAnimDictLoaded("anim@mp_player_intuppergolf") do
                    Wait(10)
                end
                TaskPlayAnim(ped, "anim@mp_player_intuppergolf", "idle_a", 8.0, -8.0, 2000, 0, false, false, false)
                Wait(2000)
                ClearPedTasks(ped)
                
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
                
                QBCore.Functions.Notify("Cancelled crafting", "error")
            end)
        else
            QBCore.Functions.Notify("You don't have all required materials", "error")
        end
    end, item.requiredItems)
end)

-- Add blips for crafting locations if debug mode is on
Citizen.CreateThread(function()
    if Config.Debug then
        for gang, locations in pairs(Config.CraftingTables) do
            for i, location in ipairs(locations) do
                DebugPrint("Creating blip for " .. gang .. " crafting location " .. i)
                local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
                SetBlipSprite(blip, 566)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 0.7)
                SetBlipColour(blip, 1)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(gang .. " Crafting #" .. i)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end)

-- Initialize crafting zones when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(1000) -- Wait for QBCore to be available
        PlayerData = QBCore.Functions.GetPlayerData()
        if PlayerData and PlayerData.gang then
            PlayerGang = PlayerData.gang
            DebugPrint("Resource started, Gang: " .. PlayerGang.name)
            SetupCraftingZones()
        end
    end
end)
