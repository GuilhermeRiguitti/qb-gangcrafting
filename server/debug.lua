local QBCore = exports['qb-core']:GetCoreObject()

-- Comando de verificação do sistema
QBCore.Commands.Add('checkcrafting', 'Verificar sistema de crafting (Admin)', {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or Player.PlayerData.permission ~= 'admin' then
        TriggerClientEvent('QBCore:Notify', src, "Apenas admins podem usar este comando", "error")
        return
    end
    
    -- Verificar pasta de locale
    local localeFolder = 'locale'
    local localesFolder = 'locales'
    local localePath = GetResourcePath(GetCurrentResourceName()) .. '/' .. localeFolder
    local localesPath = GetResourcePath(GetCurrentResourceName()) .. '/' .. localesFolder
    
    local localeExists = DoesPathExist(localePath)
    local localesExists = DoesPathExist(localesPath)
    
    TriggerClientEvent('QBCore:Notify', src, "Pasta 'locale' existe: " .. tostring(localeExists), "primary")
    TriggerClientEvent('QBCore:Notify', src, "Pasta 'locales' existe: " .. tostring(localesExists), "primary")
    
    -- Verificar registro de armas
    local weaponPistol = QBCore.Shared.Items["weapon_pistol"]
    local pistolPart1 = QBCore.Shared.Items["pistol_part_1"]
    
    TriggerClientEvent('QBCore:Notify', src, "Arma 'weapon_pistol' registrada: " .. tostring(weaponPistol ~= nil), "primary")
    TriggerClientEvent('QBCore:Notify', src, "Item 'pistol_part_1' registrado: " .. tostring(pistolPart1 ~= nil), "primary")
    
    -- Verificar função do Player
    local canAddWeapon = Player.Functions.CanCarryItem("weapon_pistol", 1)
    
    TriggerClientEvent('QBCore:Notify', src, "Pode carregar weapon_pistol: " .. tostring(canAddWeapon), "primary")
    
    -- Registro de console
    print("=== DIAGNÓSTICO DE CRAFTING ===")
    print("Resource path: " .. GetResourcePath(GetCurrentResourceName()))
    print("Pasta 'locale' existe: " .. tostring(localeExists))
    print("Pasta 'locales' existe: " .. tostring(localesExists))
    print("Arma 'weapon_pistol' registrada: " .. tostring(weaponPistol ~= nil))
    print("Item 'pistol_part_1' registrado: " .. tostring(pistolPart1 ~= nil))
    print("Player pode carregar weapon_pistol: " .. tostring(canAddWeapon))
    print("===============================")
end, 'admin')

-- Adicionar ao fxmanifest.lua:
-- server_scripts {
--     'server/main.lua',
--     'server/debug.lua'
-- }
