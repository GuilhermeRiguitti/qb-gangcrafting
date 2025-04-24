Config = {}
Config.Debug = true -- Set to true for detailed logging while testing

-- Weapon crafting configuration for each gang
Config.Weapons = {
    ['ballas'] = {
        {
            item = "weapon_pistol", -- Make sure this matches the exact item name in QBCore.Shared.Items
            label = "Pistol",
            type = "weapon",
            requiredGradeLevel = 1,
            xpGain = 5,
            requiredItems = {
                {item = "pistol_part_1", amount = 1},
                {item = "pistol_part_2", amount = 1},
                {item = "pistol_part_3", amount = 1},
                {item = "pistol_part_4", amount = 1}
            }
        },
        {
            item = "weapon_pistol_mk2",
            label = "Pistol Mk II",
            type = "weapon",
            requiredGradeLevel = 3,
            xpGain = 10,
            requiredItems = {
                {item = "pistol_part_1", amount = 2},
                {item = "pistol_part_2", amount = 2},
                {item = "pistol_part_3", amount = 1},
                {item = "pistol_part_4", amount = 1},
                {item = "rubber", amount = 5}
            }
        }
    },
    ['vagos'] = {
        {
            item = "weapon_snspistol",
            label = "SNS Pistol",
            type = "weapon",
            requiredGradeLevel = 1,
            xpGain = 5,
            requiredItems = {
                {item = "pistol_part_1", amount = 1},
                {item = "pistol_part_3", amount = 1},
                {item = "steel", amount = 10},
                {item = "rubber", amount = 5}
            }
        }
    },
    ['cartel'] = {
        {
            item = "weapon_smg",
            label = "SMG",
            type = "weapon", 
            requiredGradeLevel = 3,
            xpGain = 10,
            requiredItems = {
                {item = "smg_part_1", amount = 1},
                {item = "smg_part_2", amount = 1},
                {item = "smg_part_3", amount = 1},
                {item = "smg_part_4", amount = 1}
            }
        }
    },
    ['families'] = {
        {
            item = "weapon_combatpistol",
            label = "Combat Pistol",
            type = "weapon",
            requiredGradeLevel = 2,
            xpGain = 8,
            requiredItems = {
                {item = "pistol_part_1", amount = 1},
                {item = "pistol_part_2", amount = 1},
                {item = "pistol_part_3", amount = 1},
                {item = "steel", amount = 15}
            }
        }
    },
    ['marabunta'] = {
        {
            item = "weapon_machinepistol",
            label = "Machine Pistol",
            type = "weapon",
            requiredGradeLevel = 2,
            xpGain = 9,
            requiredItems = {
                {item = "smg_part_1", amount = 1},
                {item = "pistol_part_2", amount = 1},
                {item = "pistol_part_3", amount = 1},
                {item = "copper", amount = 10}
            }
        }
    },
    ['lostmc'] = {
        {
            item = "weapon_sawnoffshotgun",
            label = "Sawed-Off Shotgun",
            type = "weapon",
            requiredGradeLevel = 2,
            xpGain = 10,
            requiredItems = {
                {item = "pistol_part_1", amount = 2}, -- Changed from shotgun_part_1
                {item = "smg_part_2", amount = 1},    -- Changed from shotgun_part_2
                {item = "metalscrap", amount = 10},   -- Changed from wood
                {item = "steel", amount = 5}
            }
        }
    }
}

-- Crafting table locations for each gang
Config.CraftingTables = {
    ['ballas'] = {
        {
            coords = vector3(101.23, -1981.13, 20.76), -- Specified location for Ballas
            heading = 320.0,
            minZ = 19.76,
            maxZ = 21.76,
            length = 1.0,
            width = 1.0
        }
    },
    ['cartel'] = {
        {
            coords = vector3(1451.32, 1135.47, 114.33), -- Specified location for Cartel
            heading = 0.0,
            minZ = 113.33,
            maxZ = 115.33,
            length = 1.0,
            width = 1.0
        }
    },
    ['vagos'] = {
        {
            coords = vector3(334.42, -2039.48, 21.14),
            heading = 50.0,
            minZ = 20.14,
            maxZ = 22.14,
            length = 1.0,
            width = 1.0
        }
    },
    ['families'] = {
        {
            coords = vector3(-136.02, -1609.64, 35.03),
            heading = 320.0,
            minZ = 34.03,
            maxZ = 36.03,
            length = 1.0,
            width = 1.0
        }
    },
    ['marabunta'] = {
        {
            coords = vector3(1286.84, -1604.47, 54.82),
            heading = 290.0,
            minZ = 53.82,
            maxZ = 55.82,
            length = 1.0,
            width = 1.0
        }
    },
    ['lostmc'] = {
        {
            coords = vector3(977.14, -95.61, 74.85),
            heading = 40.0,
            minZ = 73.85,
            maxZ = 75.85,
            length = 1.0,
            width = 1.0
        }
    }
}
