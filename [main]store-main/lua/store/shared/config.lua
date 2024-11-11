local function attachCurrency(str)
    return "£" .. str
end

local function formatMoney(n)
    if not n then return attachCurrency("0") end
    if n >= 1e14 then return attachCurrency(tostring(n)) end
    if n <= -1e14 then return "-" .. attachCurrency(tostring(math.abs(n))) end
    local negative = n < 0
    n = tostring(math.abs(n))
    local sep = sep or ","
    local dp = string.find(n, "%.") or #n + 1

    for i = dp - 4, 1, -3 do
        n = n:sub(1, i) .. sep .. n:sub(i + 1)
    end

    return (negative and "-" or "") .. attachCurrency(n)
end

MONEY_CONTENT = [[
<font=Store.Credits.Item.Content.Title><colour=255, 255, 255>Info</colour></font>
<colour=215, 215, 215><font=Store.Credits.Item.Content.Content> - %s
]]
MONEY_CONTENT_CHEAPER = MONEY_CONTENT .. [[
<colour=46, 204, 113> - %s cheaper per credit</colour>
]]
POINTS_CONTENT = [[
<font=Store.Credits.Item.Content.Title><colour=255, 255, 255>Info</colour></font>
<colour=215, 215, 215><font=Store.Credits.Item.Content.Content> - %s ASAP Points
]]
POINTS_CONTENT_CHEAPER = POINTS_CONTENT .. [[
<colour=46, 204, 113> - %s cheaper per credit</colour>
]]
COLOR_BRONZE = Color(90, 70, 50)
COLOR_SILVER = Color(145, 145, 145)
COLOR_GOLD = Color(69, 0, 104)
COLOR_GREEN = Color(46, 204, 113)
COLOR_RED = Color(230, 58, 64)
COLOR_CUM = Color(255, 255, 255)
COLOR_BLUE = Color(41, 128, 185)
CREDITS_MONEY = 1
CREDITS_POINTS = 2
Store.StoreURL = "https://galaxium.tebex.io/"

Store.ChatCommands = {
    ["/store"] = true,
    ["!store"] = true,
    ["/shop"] = true,
    ["!shop"] = true,
    ["!donate"] = true,
    ["/donate"] = true,
    ["!pay2win"] = true,
    ["/pay2win"] = true,
    ["ligma"] = true,
    ["nigga"] = true,
    ["nigger"] = true,
    ["negro"] = true,
    ["kike"] = true
}

local MONEY_UNLOCK = function(ply, tbl)
    if SERVER then
        ply:addMoney(tbl.values[3])
        Store.Webhook(ply, tbl.title, "EUR " .. tbl.cost / 100)
    end

    return true
end

local POINTS_UNLOCK = function(ply, tbl)
    if SERVER then
        ply:GiveCredits(tbl.values[1])
        Store.Webhook(ply, tbl.title, "EUR " .. tbl.cost / 100)
    end

    return true
end

Store.Credits = {
    [CREDITS_MONEY] = {
        name = "Money",
        mat = Material("xenin/logo.png", "noclamp smooth"),
        items = {
            {
                title = "NOT AVAILABLE",
                cost = 999999,
                content = MONEY_CONTENT,
                values = {formatMoney(100000), "", 100000},
                onUnlock = MONEY_UNLOCK
            },
            {
                title = "NOT AVAILABLE",
                cost = 999999,
                content = MONEY_CONTENT,
                values = {formatMoney(100000), "", 100000},
                onUnlock = MONEY_UNLOCK
            },
            {
                title = "NOT AVAILABLE",
                cost = 999999,
                content = MONEY_CONTENT,
                values = {formatMoney(100000), "", 100000},
                onUnlock = MONEY_UNLOCK
            },
            {
                title = "NOT AVAILABLE",
                cost = 999999,
                content = MONEY_CONTENT,
                values = {formatMoney(100000), "", 100000},
                onUnlock = MONEY_UNLOCK
            },
        }
    },
    [CREDITS_POINTS] = {
        name = "ASAP Points",
        mat = Material("xenin/xp.png", "noclamp smooth"),
        items = {
            {
                title = "NOT AVAILABLE",
                cost = 999999,
                content = POINTS_CONTENT,
                values = {100},
                onUnlock = POINTS_UNLOCK
            },
            {
                title = "NOT AVAILABLE",
                cost = 999999,
                content = POINTS_CONTENT,
                values = {100},
                onUnlock = POINTS_UNLOCK
            },
            {
                title = "NOT AVAILABLE",
                cost = 999999,
                content = POINTS_CONTENT,
                values = {100},
                onUnlock = POINTS_UNLOCK
            },
            {
                title = "NOT AVAILABLE",
                cost = 999999,
                content = POINTS_CONTENT,
                values = {100},
                onUnlock = POINTS_UNLOCK
            },
        }
    }
}

Store.Weapons = {
    [1] = {
        name = "Featured",
        mat = Material("xenin/logo.png", "smooth"),
        items = {
            {
                title = "Lightsaber",
                cost = 750,
                ent = "weapon_lightsaber",
                model = "models/weapons/starwars/w_kr_hilt.mdl"
            },
            {
                title = "M4A1-S | Beast",
                cost = 1000,
                ent = "weapon_m4a1_beast",
                model = "models/cf/w_m4a1_beast.mdl"
            },
            {
                title = "Tomahawk XMAS",
                cost = 500,
                ent = "tfa_cso_tomahawk_xmas",
                model = "models/weapons/tfa_cso/w_tomahawk_xmas.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Janus7 XMAS",
                cost = 500,
                ent = "tfa_cso_janus7xmas",
                model = "models/weapons/tfa_cso/w_janus7xmas.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Chainsaw XMAS",
                cost = 500,
                ent = "tfa_cso_chainsaw_v6",
                model = "models/weapons/tfa_cso/w_chainsaw_v6.mdl",
                color = COLOR_BLUE
            },
        },
    },
    [2] = {
        name = "Rifles",
        mat = Material("xenin/logo.png", "smooth"),
        items = {
            {
                title = "AK-47",
                cost = 500,
                ent = "asap_ak47",
                model = "models/weapons/tfa_csgo/w_ak47.mdl"
            },
            {
                title = "M4A1",
                cost = 500,
                ent = "asap_m4a1",
                model = "models/weapons/tfa_csgo/w_m4a1.mdl"
            },
            {
                title = "M4A1|Cyrex",
                cost = 500,
                ent = "weapon_csgo_breakout_m4a1_silencer",
                model = "models/csgo/breakout/weapons/w_rif_m4a1_s.mdl"
            },
            {
                title = "M4A1|Beast",
                cost = 500,
                ent = "weapon_m4a1_beast",
                model = "models/cf/w_m4a1_beast.mdl"
            },
            {
                title = "M4A4",
                cost = 500,
                ent = "asap_m4a4",
                model = "models/weapons/tfa_csgo/w_m4a4.mdl"
            },
            {
                title = "M4A4|HOWL",
                cost = 750,
                ent = "m4a4_howl_original",
                model = "models/weapons/w_vin_howl.mdl"
            },
            {
                title = "Famas",
                cost = 500,
                ent = "asap_famas",
                model = "models/weapons/tfa_csgo/w_famas.mdl"
            },
            {
                title = "AUG",
                cost = 500,
                ent = "asap_aug",
                model = "models/weapons/tfa_csgo/w_aug.mdl"
            },
            {
                title = "SG556",
                cost = 500,
                ent = "asap_sg556",
                model = "models/weapons/tfa_csgo/w_sg556.mdl"
            }
        }
    },
    [3] = {
        name = "Snipers",
        mat = Material("xenin/logo.png", "smooth"),
        items = {
            {
                title = "AWP",
                cost = 600,
                ent = "asap_awp",
                model = "models/csgo/weapons/w_snip_awp.mdl",
                color = COLOR_GREEN
            },
            {
                title = "AWP|Asiimov",
                cost = 800,
                ent = "weapon_csgo_awp_asiimov",
                model = "models/csgo/weapons/w_snip_awp_asiimov.mdl",
                color = COLOR_GREEN
            },
            {
                title = "AWP|Dragon Lore",
                cost = 1000,
                ent = "weapon_csgo_awp_dragon_lore",
                model = "models/csgo/weapons/w_snip_awp_dragon_lore.mdl",
                color = COLOR_GREEN
            },
            {
                title = "AWP|Hyper Beast",
                cost = 800,
                ent = "weapon_csgo_awp_hyper_beast",
                model = "models/csgo/weapons/w_snip_awp_dragon_lore.mdl",
                color = COLOR_GREEN
            },
            {
                title = "AWP|Lighting Strike",
                cost = 800,
                ent = "weapon_csgo_awp_lighting_strike",
                model = "models/csgo/weapons/w_snip_awp_lighting_strike.mdl",
                color = COLOR_GREEN
            },
            {
                title = "AWP|Man-o'-war",
                cost = 800,
                ent = "weapon_csgo_awp_man-o-war",
                model = "models/csgo/weapons/w_snip_awp_man-o-war.mdl",
                color = COLOR_GREEN
            },
            {
                title = "SSG08",
                cost = 600,
                ent = "asap_ssg08",
                model = "models/weapons/tfa_csgo/w_scout.mdl",
                color = COLOR_GREEN
            },
            {
                title = "SSG08|Abyss",
                cost = 800,
                ent = "weapon_csgo_breakout_ssg08",
                model = "models/csgo/breakout/weapons/w_snip_ssg08.mdl",
                color = COLOR_GREEN
            },
            {
                title = "SCAR-20",
                cost = 800,
                ent = "asap_scar20",
                model = "models/weapons/tfa_csgo/w_scar20.mdl",
                color = COLOR_GREEN
            },
            {
                title = "G3SG1",
                cost = 800,
                ent = "asap_g3sg1",
                model = "models/weapons/tfa_csgo/w_g3sg1.mdl",
                color = COLOR_GREEN
            },
        }
    },
    [4] = {
        name = "Shotguns",
        mat = Material("xenin/logo.png", "smooth"),
        items = {
            {
                title = "Nova",
                cost = 700,
                ent = "asap_nova",
                model = "models/weapons/tfa_csgo/w_nova.mdl",
                color = COLOR_GREEN
            },
            {
                title = "Nova|Koi",
                cost = 900,
                ent = "weapon_csgo_breakout_nova",
                model = "models/csgo/breakout/weapons/w_shot_nova.mdl",
                color = COLOR_GREEN
            },
            {
                title = "Sawed-off",
                cost = 700,
                ent = "asap_sawedoff",
                model = "models/weapons/tfa_csgo/w_sawedoff.mdl",
                color = COLOR_GREEN
            },
            {
                title = "XM1014",
                cost = 800,
                ent = "asap_xm1014",
                model = "models/weapons/tfa_csgo/w_xm1014.mdl",
                color = COLOR_GREEN
            },
            {
                title = "MAG-7",
                cost = 700,
                ent = "asap_mag7",
                model = "models/weapons/tfa_csgo/w_mag7.mdl",
                color = COLOR_GREEN
            },
            {
                title = "Double Barrel",
                cost = 500,
                ent = "m9k_dbarrel",
                model = "models/weapons/w_double_barrel_shotgun.mdl",
                color = COLOR_GREEN
            },
        }
    },
    [5] = {
        name = "SMGs",
        mat = Material("xenin/logo.png", "smooth"),
        items = {
            {
                title = "MAC-10",
                cost = 400,
                ent = "asap_mac10",
                model = "models/weapons/tfa_csgo/w_mac10.mdl",
                color = COLOR_GREEN
            },
            {
                title = "MP7",
                cost = 500,
                ent = "asap_mp7",
                model = "models/weapons/tfa_csgo/w_mp7.mdl",
                color = COLOR_GREEN
            },
            {
                title = "MP7|Urban Hazard",
                cost = 650,
                ent = "weapon_csgo_breakout_mp7",
                model = "models/csgo/breakout/weapons/w_smg_mp7.mdl",
                color = COLOR_GREEN
            },
            {
                title = "MP9",
                cost = 400,
                ent = "asap_mp9",
                model = "models/weapons/tfa_csgo/w_mp9.mdl",
                color = COLOR_GREEN
            },
            {
                title = "P90",
                cost = 600,
                ent = "asap_p90",
                model = "models/weapons/tfa_csgo/w_p90.mdl",
                color = COLOR_GREEN
            },
            {
                title = "P90|Asiimov",
                cost = 700,
                ent = "weapon_csgo_breakout_p90",
                model = "models/csgo/breakout/weapons/w_smg_p90.mdl",
                color = COLOR_GREEN
            },
            {
                title = "PP-Bizon",
                cost = 500,
                ent = "asap_bizon",
                model = "models/weapons/tfa_csgo/w_bizon.mdl",
                color = COLOR_GREEN
            },
            {
                title = "PP-Bizon|Osiris",
                cost = 600,
                ent = "weapon_csgo_breakout_bizon",
                model = "models/csgo/breakout/weapons/w_smg_bizon.mdl",
                color = COLOR_GREEN
            },
            {
                title = "UMP45",
                cost = 500,
                ent = "asap_ump",
                model = "models/weapons/tfa_csgo/w_ump45.mdl",
                color = COLOR_GREEN
            },
            {
                title = "UMP45|Labyrinth",
                cost = 600,
                ent = "weapon_csgo_breakout_ump45",
                model = "models/csgo/breakout/weapons/w_smg_ump45.mdl",
                color = COLOR_GREEN
            },
        }
    },
    [6] = {
        name = "LMGs",
        mat = Material("xenin/logo.png", "smooth"),
        items = {
            {
                title = "Negev",
                cost = 1000,
                ent = "asap_negev",
                model = "models/weapons/tfa_csgo/w_negev.mdl",
                color = COLOR_GREEN
            },
            {
                title = "Negev|Desert-Strike",
                cost = 1500,
                ent = "weapon_csgo_breakout_negev",
                model = "models/csgo/breakout/weapons/w_mach_negev.mdl",
                color = COLOR_GREEN
            },
            {
                title = "M249",
                cost = 1000,
                ent = "asap_m249",
                model = "models/weapons/tfa_csgo/w_m249.mdl",
                color = COLOR_GREEN
            },
        }
    },
    [7] = {
        name = "Pistols",
        mat = Material("xenin/logo.png", "smooth"),
        items = {
            {
                title = "Desert Eagle",
                cost = 800,
                ent = "asap_deagle",
                model = "models/weapons/tfa_csgo/w_deagle.mdl",
                color = COLOR_RED
            },
            {
                title = "Desert Eagle|Bornbeast",
                cost = 1000,
                ent = "weapon_deagle_bornbeast",
                model = "models/cf/w_deagle_beast.mdl",
                color = COLOR_RED
            },
            {
                title = "Desert Eagle|Conspiracy",
                cost = 1000,
                ent = "weapon_csgo_breakout_deagle",
                model = "models/csgo/breakout/weapons/w_pist_deagle.mdl",
                color = COLOR_RED
            },
            {
                title = "Revolver",
                cost = 800,
                ent = "asap_revolver",
                model = "models/weapons/tfa_csgo/w_revolver.mdl",
                color = COLOR_RED
            },
            {
                title = "Five-SeveN",
                cost = 600,
                ent = "asap_fiveseven",
                model = "models/weapons/tfa_csgo/w_fiveseven.mdl",
                color = COLOR_RED
            },
            {
                title = "Five-SeveN|Fowl Play",
                cost = 800,
                ent = "weapon_csgo_breakout_fiveseven",
                model = "models/csgo/breakout/weapons/w_pist_fiveseven.mdl",
                color = COLOR_RED
            },
            {
                title = "Glock-18",
                cost = 600,
                ent = "asap_glock",
                model = "models/weapons/tfa_csgo/w_glock18.mdl",
                color = COLOR_RED
            },
            {
                title = "Glock-18|Water Elemental",
                cost = 800,
                ent = "weapon_csgo_breakout_glock",
                model = "models/csgo/breakout/weapons/w_pist_glock18.mdl",
                color = COLOR_RED
            },
            {
                title = "P2000|Ivory",
                cost = 600,
                ent = "weapon_csgo_breakout_hkp2000",
                model = "models/csgo/breakout/weapons/w_pist_hkp2000.mdl",
                color = COLOR_RED
            },
            {
                title = "P250",
                cost = 500,
                ent = "asap_p250",
                model = "models/weapons/tfa_csgo/w_p250.mdl",
                color = COLOR_RED
            },
            {
                title = "P250|Supernova",
                cost = 600,
                ent = "weapon_csgo_breakout_p250",
                model = "models/csgo/breakout/weapons/w_pist_p250.mdl",
                color = COLOR_RED
            },
            {
                title = "TEC-9",
                cost = 500,
                ent = "asap_tec9",
                model = "models/weapons/tfa_csgo/w_tec9.mdl",
                color = COLOR_RED
            },
            {
                title = "Big Glock",
                cost = 750,
                ent = "tfa_dax_big_glock",
                model = "models/weapons/daxble/w_dax_bigglock.mdl",
                color = COLOR_RED
            },
            {
                title = "USP",
                cost = 500,
                ent = "asap_usp",
                model = "models/weapons/tfa_csgo/w_usp.mdl",
                color = COLOR_RED
            },
            {
                title = "CZ75-Auto|Tigris",
                cost = 700,
                ent = "weapon_csgo_breakout_cz75a",
                model = "models/csgo/breakout/weapons/w_pist_cz_75.mdl",
                color = COLOR_RED
            }
        }
    },
    [2] = {
        name = "Unpurchaseable",
        mat = Material("xenin/logo.png", "smooth"),
        items = {
            {
                title = "Vape",
                cost = 999999,
                ent = "weapon_vape",
                model = "models/swamponions/vape.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Helium Vape",
                cost = 999999,
                ent = "weapon_vape_helium",
                model = "models/swamponions/vape.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Water Gun",
                cost = 999999,
                ent = "tfa_cso_watergun",
                model = "models/weapons/tfa_cso/w_watergun.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Californian Sharkbite",
                cost = 999999,
                ent = "weapon_sharkbite",
                model = "models/weapons/w_rif_shark.mdl",
                color = COLOR_BLUE
            },
            {
                title = "The Tiki Heartburn",
                cost = 999999,
                ent = "weapon_tikih",
                model = "models/weapons/w_smg_tikih.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Electric Crowbar",
                cost = 999999,
                ent = "tfa_cso_crowbarcraft",
                model = "models/weapons/tfa_cso/w_crowbarcraft.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Crowbar",
                cost = 999999,
                ent = "weapon_crowbar",
                model = "models/weapons/w_crowbar.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Recluse",
                cost = 999999,
                ent = "destiny_recluse",
                model = "models/recluse.mdl",
                color = COLOR_BLUE
            },
            {
                title = "P90 Lapin",
                cost = 999999,
                ent = "tfa_cso_pchan",
                model = "models/weapons/tfa_cso/c_p90lapin.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Lollipop",
                cost = 999999,
                ent = "tfa_cso2_lollipop",
                model = "models/weapons/tfa_cso2/w_lollipop.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Bowie Tiger",
                cost = 999999,
                ent = "csgo_bowie_tiger",
                model = "models/weapons/w_csgo_bowie.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Bayonet Fade",
                cost = 999999,
                ent = "csgo_bayonet_fade",
                model = "models/weapons/w_csgo_bayonet.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Jackhammer",
                cost = 999999,
                ent = "jackhammer",
                model = "models/asapgaming/jackhammer/w_jackhammer.mdl",
                color = COLOR_BLUE
            },
            {
                title = "XMAS M95",
                cost = 999999,
                ent = "tfa_cso_m95_xmas",
                model = "models/weapons/tfa_cso/w_m95xmas.mdl",
                color = COLOR_BLUE
            },
            {
                title = "XMAS MG3",
                cost = 999999,
                ent = "tfa_cso_mg3xmas",
                model = "models/weapons/tfa_cso/w_mg3_xmas.mdl",
                color = COLOR_BLUE
            },
            {
                title = "XMAS MG36",
                cost = 999999,
                ent = "tfa_cso_mg36_xmas",
                model = "models/weapons/tfa_cso/w_mg36_xmas.mdl",
                color = COLOR_BLUE
            },
            {
                title = "XMAS Winchester",
                cost = 999999,
                ent = "tfa_cso_m1887xmas",
                model = "models/weapons/tfa_cso/w_m1887xmas.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Snowball",
                cost = 999999,
                ent = "zck_snowballswep",
                model = "models/mcmodelpack/items/snowball.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Hunstman Crimson Web",
                cost = 999999,
                ent = "csgo_huntsman_crimsonwebs",
                model = "models/weapons/w_csgo_tactical.mdl",
                color = COLOR_BLUE
            },
            {
                title = "AWP-Z",
                cost = 999999,
                ent = "tfa_cso_awpz",
                model = "models/weapons/tfa_cso/w_awpz.mdl",
                color = COLOR_BLUE
            },
            {
                title = "Skull-9",
                cost = 999999,
                ent = "tfa_cso_skull9",
                model = "models/weapons/tfa_cso/w_skull_9.mdl",
                color = COLOR_BLUE
            },
        }
    }
}

Store.PackageDiscounts = {
    [1] = 1000,
    [2] = 2000,
    [3] = 3000,
    [4] = 4000,
    [5] = 5000,
    [6] = 6000,
    [7] = 7000,
    [8] = 8000,
    [9] = 9000,
    [10] = 10000
}

Store.Packages = {
    [1] = {
        title = "EGG",
        cost = 10000,
        color = COLOR_CUM,
        rankId = 11,
        uid = 1,
        limited = 1617494400 + 345600,
        contents = {
            {"Permanent EGG Rank", Color(255, 255, 255)},
            "MEME GOD/Meme/Ultra/VIP Jobs ", "Private Job (+6 Extra Weapon)", "More Turret Job Slots and TVs", "Prop Limit: 175", "£10,000,000 In-Game Money", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "Lightsaber, Vape SWEP", "Double Barrel Shotgun, Random CS:GO Knife ", "P90 Lapin, Jackhammer", "Helium Vape SWEP, Crowbar", "Lolipop", "MAX Printers: 18", "MAX Printer Racks: 2",
        },
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("EGG")
                ply:addMoney(10000000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_bowie_tiger", true, true)
                ply:AddPermanentWeapon("destiny_recluse", true, true)
                ply:AddPermanentWeapon("tfa_cso_pchan", true, true)
                ply:AddPermanentWeapon("tfa_cso2_lollipop", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("weapon_vape_helium", true, true)
                ply:AddPermanentWeapon("weapon_crowbar", true, true)
                ply:AddPermanentWeapon("jackhammer", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
            end
        end
    },
    [2] = {
        title = "Snowy",
        cost = 10000,
        color = COLOR_CUM,
        rankId = 10,
        uid = 2,
        limited = 1607126400 + 2160000,
        contents = {
            {"Permanent Snowy Rank", Color(255, 255, 255)},
            "3 Common, 3 Uncommon, 2 Rare,", "1 Ultra Rare, 1 Legendary gifts", "Christmas/MEME GOD/Meme/Ultra/VIP Jobs", "Private Job (Only 1 CJ by ranks)", "More Turret/Bitcoin job Slots", "Prop Limit: 150", "£10,000,000 In-Game Money", "⇊⇊PERMANENT WEAPONS⇊⇊", "XMAS MG36, XMAS M95", "XMAS m1887, XMAS MG3", "Snowball, Vape SWEP, Jackhammer", "Double Barrel Shotgun, Hunstman|Crimson Web", "Lightsaber, Electric Crowbar", "MAX Printers: 18", "MAX Printer Racks: 2",
        },
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("Snowy")
                ply:addMoney(10000000)
                ply:UB3AddItem(549, 3)
                ply:UB3AddItem(550, 3)
                ply:UB3AddItem(551, 2)
                ply:UB3AddItem(552, 1)
                ply:UB3AddItem(553, 1)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_huntsman_crimsonwebs", true, true)
                ply:AddPermanentWeapon("destiny_recluse", true, true)
                ply:AddPermanentWeapon("tfa_cso_mg3xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_m95_xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_mg36_xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_m1887xmas", true, true)
                ply:AddPermanentWeapon("zck_snowballswep", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("weapon_crowbar", true, true)
                ply:AddPermanentWeapon("jackhammer", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
            end
        end
    },
    [3] = {
        title = "Sp0okyy",
        cost = 10000,
        color = COLOR_GOLD,
        rankId = 9,
        uid = 3,
        limited = 0 + 1209600,
        contents = {
            {"Permanent Sp0okyy Rank", Color(255, 0, 0)},
            "MEME GOD/Meme/Ultra/VIP Jobs ", "Skeleton Job and Zombie Job", "Private Job (Only 1 CJ by ranks)", "More Turret/Bitcoin job Slots", "Prop Limit: 135", "£10,069,000 In-Game Money", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "SKULL-9 BIG BOY AXE", "AWP-Z Sniper Rifle", "Lightsaber, Vape SWEP, Jackhammer", "Double Barrel Shotgun, Random CS:GO Knife ", "Helium Vape SWEP, Electric Crowbar", "MAX Printers: 18", "MAX Printer Racks: 2",
        },
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("Sp0okyy")
                ply:addMoney(10069000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_bayonet_fade", true, true)
                ply:AddPermanentWeapon("tfa_cso_skull9", true, true)
                ply:AddPermanentWeapon("tfa_cso_awpz", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("weapon_vape_helium", true, true)
                ply:AddPermanentWeapon("tfa_cso_crowbarcraft", true, true)
                ply:AddPermanentWeapon("jackhammer", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
            end
        end
    },
    [4] = {
        title = "VERY HOT",
        cost = 20000,
        color = COLOR_GOLD,
        rankId = 8,
        uid = 4,
		limited = 0 + 1209600,
        contents = {
            {"Permanent VERY HOT Rank", Color(255, 0, 0)},
            "MEME GOD/Meme/Ultra/VIP Jobs ", "Private Job (Only 1 CJ by ranks)", "More Turret/Bitcoin job Slots", "Prop Limit: 100", "£20,000,000 In-Game Money", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "Tiki Heartburn Auto Shotgun", "Californian Sharkbite Rifle", "Lightsaber, Vape SWEP, Jackhammer", "Double Barrel Shotgun, Random CS:GO Knife ", "Helium Vape SWEP, Electric Crowbar", "A god damn Water Gun very cool", "MAX Printers: 20", "MAX Printer Racks: 2",
        },
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("VERY HOT")
                ply:addMoney(20000000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_bayonet_fade", true, true)
                ply:AddPermanentWeapon("weapon_sharkbite", true, true)
                ply:AddPermanentWeapon("tfa_cso_watergun", true, true)
                ply:AddPermanentWeapon("weapon_tikih", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("weapon_vape_helium", true, true)
                ply:AddPermanentWeapon("tfa_cso_crowbarcraft", true, true)
                ply:AddPermanentWeapon("jackhammer", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
            end
        end
    },
    [5] = {
        title = "Chungus",
        cost = 13000,
        color = COLOR_GOLD,
        rankId = 7,
		limited = 1574982630 + 2854200,
        uid = 5,
        contents = {
            {"Permanent Chungus Rank", Color(100, 0, 150)},
            "MEME GOD/Meme/Ultra/VIP Jobs ", "BIG CHUNGUS JOB", "Private Job (Only 1 CJ by ranks)", "More Turret Job Slots and TVs", "Prop Limit: 80", "£9,500,000 In-Game Money", "MONEY WILL BE RECEIVED 2 WEEKS AFTER WIPE", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "Lightsaber, Vape SWEP", "Double Barrel Shotgun, Random CS:GO Knife ", "P90 Lapin, Jackhammer", "Helium Vape SWEP, Crowbar", "Some Candy you can kill people with", "MAX Printers: 20", "MAX Printer Racks: 2",
        },
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("Chungus")
                ply:addMoney(9500000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_bowie_tiger", true, true)
                ply:AddPermanentWeapon("destiny_recluse", true, true)
                ply:AddPermanentWeapon("tfa_cso_pchan", true, true)
                ply:AddPermanentWeapon("tfa_cso2_lollipop", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("weapon_vape_helium", true, true)
                ply:AddPermanentWeapon("weapon_crowbar", true, true)
                ply:AddPermanentWeapon("jackhammer", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
            end
        end
    },
    [6] = {
        title = "Grinch",
        cost = 8000,
        color = COLOR_GOLD,
        rankId = 6,
        uid = 6,
        limited = 1574982630 + 2854200,
        contents = {
            {"Permanent Grinch Rank", Color(100, 0, 150)},
            "MEME GOD/Meme/Ultra/VIP Jobs ", "Private Job (Only 1 CJ by ranks)", "More Turret Job Slots and TVs", "Prop Limit: 75", "£8,500,000 In-Game Money ", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "Lightsaber, Vape SWEP", "Double Barrel Shotgun, Random CS:GO Knife ", "XMAS M95, Jackhammer", "Helium Vape SWEP, Crowbar, XMAS MG3", "XMAS MG36, XMAS Winchester", "MAX Printers: 18", "MAX Printer Racks: 2",
        },
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("Grinch")
                ply:addMoney(8500000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_bowie_tiger", true, true)
                ply:AddPermanentWeapon("destiny_recluse", true, true)
                ply:AddPermanentWeapon("tfa_cso_mg3xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_m95_xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_mg36_xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_m1887xmas", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("weapon_vape_helium", true, true)
                ply:AddPermanentWeapon("weapon_crowbar", true, true)
                ply:AddPermanentWeapon("jackhammer", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
            end
        end
    },
    [7] = {
        title = "Galaxy",
        cost = 10000,
        color = COLOR_GOLD,
        rankId = 5,
        uid = 7,
		limited = 1718492538 + 604800,
        contents = {
			{"Permanent Galaxy Rank", Color(255, 255, 255)},
            "Same Perks as Executive Plus", "150% total LEVEL XP boost - 25% More than Executive", "3 Printer Skins", "Prop Limit: 100", "Access to Random Item Drops", "Access to Rare Item Drops", "Access to exclusive development channel", "Exclusive Chat Tag and Scoreboard Card", "Custom Scoreboard Tag - Make Ticket", "£15,000,000 in-game money", "Custom Job - Make Ticket",
        },
		scoreboardAnim = function(ply, w, h)
            draw_pipiBar(ply, w, h)
        end,
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("Meme Legend")
                ply:addMoney(15000000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_bowie_tiger", true, true)
                ply:AddPermanentWeapon("destiny_recluse", true, true)
                ply:AddPermanentWeapon("weapon_deagle_bornbeast", true, true)
                ply:AddPermanentWeapon("weapon_m4a1_beast", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("weapon_vape_helium", true, true)
                ply:AddPermanentWeapon("weapon_crowbar", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
				ply.printerInventory = ply.printerInventory or {}
				-- List of specific printer skins to give
				local specificSkins = {
					"Garden",
					"Polys",
					"Psycho"
				}
				
				for _, skin in ipairs(specificSkins) do
					if not table.HasValue(ply.printerInventory, skin) then
						table.insert(ply.printerInventory, skin)
					end
				end
				
				net.Start("Store.Printers:Sync")
				net.WriteUInt(#ply.printerInventory, 6)

				for _, v in ipairs(ply.printerInventory) do
					net.WriteString(v)
				end

				net.WriteString(ply.printerSelected or "")
				net.Send(ply)

				ASAPDriver:MySQLQuery("UPDATE printer_skins SET printers = '" .. util.TableToJSON(ply.printerInventory) .. "' WHERE steamid = " .. ply:SteamID64(), function()
					MsgC(Color(100, 255, 0), "[PrinterStore] ", color_white, ply:Nick(), " bought printer skins!\n")
				end)
            end
        end
    },
    [8] = {
        title = "Executive",
        cost = 6500,
        color = COLOR_BLUE,
        rankId = 4,
        uid = 8,
        hasCustomJob = true,
        contents = {
            {"Permanent Executive Rank", Color(255, 215, 0)},
            "Executive/Ambassador/Ultra/VIP Jobs ", "125% More Level XP", "1 Printer Skin", "Access to random item drops", "Access to rare random item drops", "Access to exclusive development channel", "Prop Limit: 80 ", "£3,000,000 In-Game Money ", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "Lightsaber, Vape SWEP", "Double Barrel Shotgun, Random CS:GO Knife ", "Deagle|Born Beast", "M4A1-S|Beast", "Helium Vape SWEP, Crowbar", "MAX Printer racks: 6", "Max Printers: 2",
        },
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("Meme God")
                ply:addMoney(3000000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_bowie_tiger", true, true)
                ply:AddPermanentWeapon("destiny_recluse", true, true)
                ply:AddPermanentWeapon("weapon_deagle_bornbeast", true, true)
                ply:AddPermanentWeapon("weapon_m4a1_beast", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("weapon_vape_helium", true, true)
                ply:AddPermanentWeapon("weapon_crowbar", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
				ply.printerInventory = ply.printerInventory or {}
				-- List of specific printer skins to give
				local specificSkins = {
					"Fire",
				}
				
				for _, skin in ipairs(specificSkins) do
					if not table.HasValue(ply.printerInventory, skin) then
						table.insert(ply.printerInventory, skin)
					end
				end
				
				net.Start("Store.Printers:Sync")
				net.WriteUInt(#ply.printerInventory, 6)

				for _, v in ipairs(ply.printerInventory) do
					net.WriteString(v)
				end

				net.WriteString(ply.printerSelected or "")
				net.Send(ply)

				ASAPDriver:MySQLQuery("UPDATE printer_skins SET printers = '" .. util.TableToJSON(ply.printerInventory) .. "' WHERE steamid = " .. ply:SteamID64(), function()
					MsgC(Color(100, 255, 0), "[PrinterStore] ", color_white, ply:Nick(), " bought printer skins!\n")
				end)
            end
        end
    },
    [9] = {
        title = "Ambassador",
        cost = 5000,
        color = COLOR_BLUE,
        rankId = 3,
        uid = 9,
        contents = {"Permanent Ambassador Rank", "Ambassador/Ultra/VIP Jobs", "100% More Level XP", "Access to random item drops", "Access to rare random item drops", "Access to exclusive development channel", "Prop Limit: 75 ", "£2,500,000 In-Game Money", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "Lightsaber, Vape Swep", "Double Barrel Shotgun, Random CS:GO Knife", "Deagle: Born Beast", "MAX Printer Racks: 6",},
        onUnlock = function(ply)
            if SERVER then
                ply:SetDonatorByRoleName("Meme")
                ply:addMoney(2500000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_bayonet_fade", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
                ply:AddPermanentWeapon("weapon_deagle_bornbeast", true, true)
            end
        end
    },
    [10] = {
        title = "Ultra V.I.P",
        cost = 3000,
        color = COLOR_BLUE,
        rankId = 2,
        uid = 10,
        contents = {"Permanent Ultra V.I.P Rank", "Ultra/VIP jobs", "75% More Level XP", "Access to random item drops", "Prop Limit: 65", "£2,000,000 In-Game Money", "Access to exclusive development channel", "⇊ ⇊ Permanent Weapons⇊ ⇊", "Lightsaber, Vape Swep", "Double Barrel Shotgun", "MAX Printer Racks: 5",},
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("Ultra VIP")
                ply:addMoney(2000000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("weapon_vape", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
            end
        end
    },
    [11] = {
        title = "V.I.P package",
        cost = 2000,
        color = COLOR_BLUE,
        rankId = 1,
        uid = 11,
        contents = {"Permanent V.I.P Rank", "VIP Jobs", "Access to random item drops", "50% More Level XP", "Prop Limit: 55", "£1,500,000 In-Game Money", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "Lightsaber and Double Barrel Shotgun", "Access to exclusive development channel", "MAX Printers Racks: 4",},
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("VIP")
                ply:addMoney(1500000)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("m9k_dbarrel", true, true)
            end
        end
    },
    [12] = {
        title = "V.I.P",
        cost = 1000,
        color = COLOR_BLUE,
        rankId = 1,
        uid = 12,
        contents = {"Permanent V.I.P Rank", "VIP Jobs", "Access to random item drops", "50% More Level XP", "Prop Limit: 55", "1,000,000£ In-Game Money", "Access to exclusive development channel", "MAX Printers Racks: 4",},
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("VIP")
                ply:addMoney(1000000)
            end
        end
    },
    [13] = {
        title = "Custom Job",
        cost = 5000,
        color = COLOR_BLUE,
        rankId = 999,
        hasCustomJob = true,
        noDiscount = true,
        uid = 13,
        contents = {"Permanent Private Job", "5 Weapons (No OP weapons)", "Any model from Workshop(Less than 5MB)", "Name of the job", "£1,500,000 In-Game", "Salary (Max 500)", "Health and Armor (Max 100 Health and 100 Amor)", "Upon unlocking, please make a ticket in the discord.",},
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:addMoney(1500000)
            end
        end
    },
    [14] = {
        title = "Snowflake",
        cost = 20000,
        color = Color(100, 190, 255),
        rankId = 12,
        uid = 14,
        limited = 1670607710 + 2419200,
        contents = {
            {"Permanent SnowFlake", Color(100, 190, 255)},
            "3 Common, 3 Uncommon, 2 Rare", "1 Ultra Rare, 1 Legendary gifts", "Christmas/MEME GOD/Meme/Ultra/VIP Jobs", "More Turret/Bitcoin job Slots", "More Turret Job Slots and TVs", "£10,000,000 In-Game Money", "Prop Limit: 120", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "XMAS MG36, XMAS M95", "XMAS m1887, XMAS MG3", "XMAS Chainsaw, XMAS Janus", "Snowball, XMAS Tomahawk", "Lightsaber", "MAX Printers: 20", "MAX Printer Racks: 2",
        },
        scoreboardAnim = function(ply, w, h)
            draw_snowflakeBar(ply, w, h)
        end,
        onSpawn = function(ply)
            timer.Simple(0.5, function()
                net.Start("Store.SpawnEffect")
                net.WriteUInt(1, 4)
                net.WriteEntity(ply)
                net.SendPVS(ply:GetShootPos())
            end)
        end,
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("Snowflake")
                ply:addMoney(10000000)
                ply:UB3AddItem(549, 3)
                ply:UB3AddItem(550, 3)
                ply:UB3AddItem(551, 2)
                ply:UB3AddItem(552, 1)
                ply:UB3AddItem(553, 1)
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:AddPermanentWeapon("csgo_huntsman_crimsonwebs", true, true)
                ply:AddPermanentWeapon("zck_snowballswep", true, true)
                ply:AddPermanentWeapon("destiny_recluse", true, true)
                ply:AddPermanentWeapon("tfa_cso_mg3xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_m95_xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_mg36_xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_m1887xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_tomahawk_xmas", true, true)
                ply:AddPermanentWeapon("tfa_cso_chainsaw_v6", true, true)
                ply:AddPermanentWeapon("tfa_cso_janus7xmas", true, true)
            end
        end
    },
    [15] = {
        title = "Event Manager",
        cost = 20000,
        color = Color(234, 255, 0),
        rankId = 13,
        uid = 15,
        limited = 64,
        contents = {
            {"Permanent Event Manager"},
        },
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:SetDonatorByRoleName("Event Manager")
            end
        end
    },
    [16] = {
        title = "Pipis",
        cost = 8000,
        color = Color(141, 197, 72),
        rankId = 14,
        uid = 16,
        limited = 1679718395 + 2419200,
        contents = {
            {"Permanent Pipis", Color(141, 197, 72),},
            "3 Common, 3 Uncommon, 2 Rare", "Christmas/MEME GOD/Meme/Ultra/VIP Jobs", "More Turret/Bitcoin job Slots", "More Turret Job Slots and TVs", "£20,000,000 In-Game Money", "Prop Limit: 120", "All printers skins unlocked", "⇊ ⇊ Permanent Weapons⇊ ⇊ ", "Lightsaber", "A Random Cat", "Rust's Case, 2x Bloody Souvenir, Samurai Elite case", "MAX Printers: 20", "MAX Printer Racks: 2",
        },
        scoreboardAnim = function(ply, w, h)
            draw_pipiBar(ply, w, h)
        end,
        onSpawn = function(ply)
            timer.Simple(0.5, function()
                net.Start("Store.SpawnEffect")
                net.WriteUInt(2, 4)
                net.WriteEntity(ply)
                net.SendPVS(ply:GetShootPos())
            end)
        end,
        onUnlock = function(ply, tbl, cost)
            if SERVER then
                ply:AddPermanentWeapon("weapon_lightsaber", true, true)
                ply:SetDonatorByRoleName("Pipi")
                ply:addMoney(20000000)
                ply:UB3AddItem(math.random(1306, 1308), 1)
                ply:UB3AddItem(1313, 2)
                ply:UB3AddItem(1314, 1)
                ply:UB3AddItem(1310, 1)
                ply.printerInventory = ply.printerInventory or {}

                for k, v in pairs(Store.Printers.Skins) do
                    if not table.HasValue(ply.printerInventory, k) then
                        table.insert(ply.printerInventory, k)
                    end
                end

                net.Start("Store.Printers:Sync")
                net.WriteUInt(#ply.printerInventory, 6)

                for _, v in pairs(ply.printerInventory) do
                    net.WriteString(v)
                end

                net.WriteString(ply.printerSelected or "")
                net.Send(ply)

                ASAPDriver:MySQLQuery("UPDATE printer_skins SET printers = '" .. util.TableToJSON(ply.printerInventory) .. "' WHERE steamid = " .. ply:SteamID64(), function()
                    MsgC(Color(100, 255, 0), "[PrinterStore] ", color_white, ply:Nick(), " bought a printer skin!\n")
                end)
            end
        end
    },
}

if CLIENT then
    local anim = Material("asap/snowflakes")

    function draw_snowflakeBar(ply, w, h)
        surface.SetMaterial(anim)
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, w / 512, h / 64)
        draw.RoundedBox(4, 0, 0, w, h, Color(100, 175, 255, 25))
    end

    local bird, feather, leaf = Material("ui/asap/planet1"), Material("ui/asap/planet2"), Material("ui/asap/planet3")
    local max = 1

    local function looper(x, y, w, h, offset)
        return (x / max) * w + ((RealTime() + (offset or 0)) % 1) * (w / max), y * h - 16 + ((RealTime() + (offset or 0)) % 1) * h - 16
    end

    function draw_pipiBar(ply, w, h)
        max = w / 96
        surface.SetDrawColor(255, 255, 255, 100)

        for x = 1, max do
            for y = 0, 1 do
                local posx, posy = looper(x, y, w, h)
                surface.SetMaterial(bird)
                surface.DrawTexturedRect(posx - 8, posy - 8, 48, 48)
                posx, posy = looper(x, y, w, h, .33)
                surface.SetMaterial(feather)
                surface.DrawTexturedRect(posx, posy, 32, 32)
                posx, posy = looper(x, y, w, h, .66)
                surface.SetMaterial(leaf)
                surface.DrawTexturedRect(posx, posy, 32, 32)
            end
        end
    end
end