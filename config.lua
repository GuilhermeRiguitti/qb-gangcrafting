Config = {}
Config.Debug = true -- Set to true for detailed logging while testing

-- New structure: IllegalCraftItems for each gang (replaces old Weapons config)
Config.IllegalCraftItems = {
    -- LAVAGEM
    ['mafia'] = {
    },
    -- WEAPONS
    ['cartel'] = {
        -- Weapon parts
        {
            item = "pistol_part_3",
            label = "Empunhadura de Pistola",
            type = "weapon_part", -- Changed from "item" to "weapon_part"
            category = "weapon_part",
            requiredGradeLevel = 2,
            xpGain = 1,
            requiredItems = {
                { item = "rubber",     amount = 30 },
                { item = "steel",      amount = 15 },
                { item = "copper",     amount = 15 },
                { item = "metalscrap", amount = 10 }
            }
        },
        {
            item = "pistol_part_2",
            label = "Slide de Pistola",
            type = "weapon_part", -- Changed from "item" to "weapon_part"
            category = "weapon_part",
            requiredGradeLevel = 2,
            xpGain = 1,
            requiredItems = {
                { item = "rubber",     amount = 30 },
                { item = "steel",      amount = 15 },
                { item = "copper",     amount = 15 },
                { item = "metalscrap", amount = 10 }
            }
        },
        {
            item = "smg_part_1",
            label = "Receiver de SMG",
            type = "weapon_part", -- Changed from "item" to "weapon_part"
            category = "weapon_part",
            requiredGradeLevel = 2,
            xpGain = 1,
            requiredItems = {
                { item = "rubber",     amount = 30 },
                { item = "steel",      amount = 15 },
                { item = "copper",     amount = 15 },
                { item = "metalscrap", amount = 10 }
            }
        },
        {
            item = "smg_part_2",
            label = "Cano de SMG",
            type = "weapon_part", -- Changed from "item" to "weapon_part"
            category = "weapon_part",
            requiredGradeLevel = 2,
            xpGain = 1,
            requiredItems = {
                { item = "rubber",     amount = 30 },
                { item = "steel",      amount = 15 },
                { item = "copper",     amount = 15 },
                { item = "metalscrap", amount = 10 }
            }
        },
        {
            item = "smg_part_3",
            label = "Coronha de SMG",
            type = "weapon_part", -- Changed from "item" to "weapon_part"
            category = "weapon_part",
            requiredGradeLevel = 2,
            xpGain = 1,
            requiredItems = {
                { item = "rubber",     amount = 30 },
                { item = "steel",      amount = 15 },
                { item = "copper",     amount = 15 },
                { item = "metalscrap", amount = 10 }
            }
        },
        {
            item = "smg_part_4",
            label = "Carregador de SMG",
            type = "weapon_part", -- Changed from "item" to "weapon_part"
            category = "weapon_part",
            requiredGradeLevel = 2,
            xpGain = 1,
            requiredItems = {
                { item = "rubber",     amount = 30 },
                { item = "steel",      amount = 15 },
                { item = "copper",     amount = 15 },
                { item = "metalscrap", amount = 10 }
            }
        },
        -- Weapons
        {
            item = "weapon_smg",
            label = "SMG",
            type = "weapon",
            category = "smg",
            requiredGradeLevel = 3,
            xpGain = 10,
            requiredItems = {
                { item = "smg_part_1", amount = 1 },
                { item = "smg_part_2", amount = 1 },
                { item = "smg_part_3", amount = 1 },
                { item = "smg_part_4", amount = 1 }
            }
        },
        {
            item = "weapon_machinepistol",
            label = "Machine Pistol",
            type = "weapon",
            category = "smg",
            requiredGradeLevel = 2,
            xpGain = 9,
            requiredItems = {
                { item = "smg_part_1",    amount = 1 },
                { item = "pistol_part_2", amount = 1 },
                { item = "pistol_part_3", amount = 1 },
                { item = "copper",        amount = 10 }
            }
        },
        -- {
        --     item = "weapon_sawnoffshotgun",
        --     label = "Sawed-Off Shotgun",
        --     type = "weapon",
        --     category = "shotgun",
        --     requiredGradeLevel = 2,
        --     xpGain = 10,
        --     requiredItems = {
        --         { item = "pistol_part_1", amount = 2 },
        --         { item = "smg_part_2",    amount = 1 },
        --         { item = "metalscrap",    amount = 10 },
        --         { item = "steel",         amount = 5 }
        --     }
        -- },
        -- {
        --     item = "weapon_combatpistol",
        --     label = "Combat Pistol",
        --     type = "weapon",
        --     category = "handgun",
        --     requiredGradeLevel = 2,
        --     xpGain = 8,
        --     requiredItems = {
        --         { item = "pistol_part_1", amount = 1 },
        --         { item = "pistol_part_2", amount = 1 },
        --         { item = "pistol_part_3", amount = 1 },
        --         { item = "steel",         amount = 15 }
        --     }
        -- },
        -- {
        --     item = "weapon_pistol",
        --     label = "Pistol",
        --     type = "weapon",
        --     category = "handgun",
        --     requiredGradeLevel = 1,
        --     xpGain = 5,
        --     requiredItems = {
        --         { item = "pistol_part_1", amount = 1 },
        --         { item = "pistol_part_2", amount = 1 },
        --         { item = "pistol_part_3", amount = 1 },
        --         { item = "pistol_part_4", amount = 1 }
        --     }
        -- },
        -- {
        --     item = "weapon_pistol_mk2",
        --     label = "Pistol Mk II",
        --     type = "weapon",
        --     category = "handgun",
        --     requiredGradeLevel = 3,
        --     xpGain = 10,
        --     requiredItems = {
        --         { item = "pistol_part_1", amount = 2 },
        --         { item = "pistol_part_2", amount = 2 },
        --         { item = "pistol_part_3", amount = 1 },
        --         { item = "pistol_part_4", amount = 1 },
        --         { item = "rubber",        amount = 5 }
        --     }
        -- },
        -- {
        --     item = "weapon_snspistol",
        --     label = "SNS Pistol",
        --     type = "weapon",
        --     category = "handgun",
        --     requiredGradeLevel = 1,
        --     xpGain = 5,
        --     requiredItems = {
        --         { item = "pistol_part_1", amount = 1 },
        --         { item = "pistol_part_3", amount = 1 },
        --         { item = "steel",         amount = 10 },
        --         { item = "rubber",        amount = 5 }
        --     }
        -- },
        -- {
        --     item = "weapon_combatpistol",
        --     label = "Combat Pistol",
        --     type = "weapon",
        --     category = "handgun",
        --     requiredGradeLevel = 2,
        --     xpGain = 8,
        --     requiredItems = {
        --         { item = "pistol_part_1", amount = 1 },
        --         { item = "pistol_part_2", amount = 1 },
        --         { item = "pistol_part_3", amount = 1 },
        --         { item = "steel",         amount = 15 }
        --     }
        -- },
    },
    -- AMMOS AND TOOLS
    ['vagos'] = {
        {
            item = "pistol_ammo",
            label = "Munição de Pistola",
            type = "item", -- Explicitly set item type
            category = "ammo",
            requiredGradeLevel = 2,
            xpGain = 1,
            requiredItems = {
                { item = "metalscrap", amount = 10 },
                { item = "steel",      amount = 5 }
            }
        },
        {
            item = "smg_ammo",
            label = "Munição de SMG",
            type = "item", -- Explicitly set item type
            category = "ammo",
            requiredGradeLevel = 2,
            xpGain = 2,
            requiredItems = {
                { item = "metalscrap", amount = 15 },
                { item = "steel",      amount = 10 },
                { item = "copper",     amount = 5 }
            }
        },
        {
            item = "lockpick",
            label = "Lockpick",
            type = "item", -- Explicitly set item type
            category = "tools",
            requiredGradeLevel = 2,
            xpGain = 1,
            requiredItems = {
                { item = "metalscrap", amount = 15 },
                { item = "steel",      amount = 8 }
            }
        },
        {
            item = "advancedlockpick",
            label = "Masterpick",
            type = "item", -- Explicitly set item type
            category = "tools",
            requiredGradeLevel = 2,
            xpGain = 1,
            requiredItems = {
                { item = "metalscrap", amount = 10 },
                { item = "steel",      amount = 5 }
            }
        },
        {
            item = "handcuffs", 
            label = "Algemas",
            type = "item",  -- Explicitly set item type
            category = "tools",
            requiredGradeLevel = 2,
            xpGain = 2,
            requiredItems = {
                { item = "steel",      amount = 20 },
                { item = "metalscrap", amount = 10 }
            }
        }
    },
    -- DRUGS
    ['ballas'] = {

    },
    -- DEMANCHE
    ['lostmc'] = {
        
    },
    -- HOSPITAL ILEGAL
    ['triads'] = {
        
    }
}

-- Crafting table locations for each gang
Config.CraftingTables = {
    ['ballas'] = {
        {
            coords = vector3(142.93, -2203.22, 4.69), -- Updated location for Ballas
            heading = 320.0,
            minZ = 3.49,                              -- Expanded vertical range
            maxZ = 5.89,                              -- Expanded vertical range
            length = 2.0,                             -- Increased length
            width = 2.0                               -- Increased width
        }
    },
    ['cartel'] = {
        {
            coords = vector3(-589.39, -1618.4, 33.01), -- Specified location for Cartel
            heading = 0.0,
            minZ = 578.33,
            maxZ = 625.33,
            length = 1.0,
            width = 1.0
        }
    },
    ['vagos'] = {
        {
            coords = vector3(473.07, -1312.68, 29.21),
            heading = 50.0,
            minZ = 20.14,
            maxZ = 22.14,
            length = 1.0,
            width = 1.0
        }
    },
    ['mafia'] = {
        {
            coords = vector3(-136.02, -1609.64, 35.03),
            heading = 320.0,
            minZ = 34.03,
            maxZ = 36.03,
            length = 1.0,
            width = 1.0
        }
    },
    -- ['marabunta'] = {
    --     {
    --         coords = vector3(1286.84, -1604.47, 54.82),
    --         heading = 290.0,
    --         minZ = 53.82,
    --         maxZ = 55.82,
    --         length = 1.0,
    --         width = 1.0
    --     }
    -- },
    -- ['lostmc'] = {
    --     {
    --         coords = vector3(977.14, -95.61, 74.85),
    --         heading = 40.0,
    --         minZ = 73.85,
    --         maxZ = 75.85,
    --         length = 1.0,
    --         width = 1.0
    --     }
    -- }
}

-- Configurações de objetos para as mesas de crafting
Config.CraftingProps = {
    ['ballas'] = {
        model = "gr_prop_gr_bench_04b",      -- Mesa grande com ferramentas
        offset = vector3(0.0, -1.0, -1.0),   -- Ajuste de altura para ficar no chão
        rotation = vector3(0.0, 0.0, 180.0), -- Mesma rotação do heading
        additionalProps = {                  -- Props adicionais para decorar
            {
                model = "prop_tool_box_04",  -- Caixa de ferramentas
                offset = vector3(0.0, -1.0, -0.2),
                rotation = vector3(0.0, 0.0, 45.0)
            }
        }
    },
    ['cartel'] = {
        model = "gr_prop_gr_bench_02b", -- Mesa diferente para o cartel
        offset = vector3(0.8, 0.0, -1.0),
        rotation = vector3(0.0, 0.0, 266.0),
        -- additionalProps = {
        --     {
        --         model = "prop_tool_box_02",
        --         offset = vector3(0.5, 0.2, 0.42),
        --         rotation = vector3(0.0, 0.0, 45.0)
        --     }
        -- }
    },

}
