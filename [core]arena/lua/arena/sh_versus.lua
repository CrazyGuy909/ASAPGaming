CreateConVar("duel_allowtrade", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Allow trading in duels")
CreateConVar("asap_duels_enabled", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable Duels")
CreateConVar("asap_duels_onlymod", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable Duels only for mods")

asapArena.Duels = asapArena.Duels or {}
local pmeta = FindMetaTable("Player")

function pmeta:IsDueling()
    return self:GetNW2Bool("IsDueling", false)
end

asapArena.SuitWeapons = {
    [1] = "weapon_bms_gluon",
    [2] = "tfa_cso_magnumdrill_expert",
    [3] = "tfa_cso_magnumdrill_dark",
    [4] = "tfa_cso_magnumdrill_venom",
    [5] = "tfa_cso_magnumlauncher_gs18",
    [6] = "tfa_cso_dreadnova_2",
    [7] = "tfa_cso_starchaser_dark"
}

asapArena.SuitsAvailable = {
    [1] = "Hydra Suit",
    [2] = "Meltdown Suit",
    [3] = "Butterfly Suit",
    [4] = "S-8040 Suit",
    [5] = "X-3040 Suit",
    [6] = "Y-4040 Suit",
    [7] = "Psycho Suit"
}

asapArena.BlacklistWeapons = {
    tfa_cso_m24grenade = true
}

asapArena.SuitZones = {
    ["Sewers"] = {
        Spawns = {
            Vector(-1270, 4065, -375),
            Vector(735, 3950, -375),
            Vector(-350, 3592, -375)
        },
        Bounds = {
            [1] = Vector(-1488, 3327, -700),
            [2] = Vector(1097, 4240, -222)
        }
    },
    ["Dojo"] = {
        Spawns = {
            Vector(1208, -5853, -140),
            Vector(3600, -5853, -140),
            Vector(1208, -4500, -140),
            Vector(3600, -4500, -140),
        }
    },
    ["Beach"] = {
        Spawns = {
            Vector(12019, -3058, -321),
            Vector(11390, -3050, -314),
            Vector(10271, -4085, -325),
            Vector(10342, -3043, -316)
        },
        Bounds = {
            [1] = Vector(9431, -4609, -500),
            [2] = Vector(13409, -2254, -47)
        }
    },
    ["Buildings"] = {
        Spawns = {
            Vector(148, 7658, -75),
            Vector(-222, 8000, -83),
            Vector(366, 8255, -195),
            Vector(-173, 7703, 140),
            Vector(-173, 8246, 140),
        },
        Bounds = {
            [1] = Vector(-376, 7503, -191),
            [2] = Vector(509, 8400, 332)
        }
    }
}