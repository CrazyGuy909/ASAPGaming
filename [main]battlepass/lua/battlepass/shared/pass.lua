BATTLEPASS.Pass = BATTLEPASS.Pass or {}
BATTLEPASS.Config = {}
BATTLEPASS.Config.SeasonTitle = "Galaxium BP Season 1"
BATTLEPASS.Config.PassPrice = 1000
BATTLEPASS.Config.TierPrice = 100

BATTLEPASS.Config.ChatCommands = {
    ["!battlepass"] = true,
    ["/battlepass"] = true,
    ["!bp"] = true,
    ["/bp"] = true,
    ["/pass"] = true,
    ["!pass"] = true
}

BATTLEPASS.ChallengesTable = {
    ["RP"] = {
        BATTLEPASS:CreateChallenge("vault_assault", 3, 5),
        BATTLEPASS:CreateChallenge("arrest_wanted", 5, 5),
        BATTLEPASS:CreateChallenge("breaking_meth", 500000, 5),
        BATTLEPASS:CreateChallenge("turret_killer", 5, 3),
        BATTLEPASS:CreateChallenge("turret_anarch", 5, 3),
        BATTLEPASS:CreateChallenge("printer_killer", 3, 3),
        BATTLEPASS:CreateChallenge("capture_cp", 2, 4),
        BATTLEPASS:CreateChallenge("capture_killer", 10, 5),
        BATTLEPASS:CreateChallenge("suit_ripper", 2, 3, 2),
        BATTLEPASS:CreateChallenge("suit_gift", 3, 3),
        BATTLEPASS:CreateChallenge("hitman_sucess", 5, 3),
        BATTLEPASS:CreateChallenge("hitman_fail", 3, 5)
    },
    ["Gangs"] = {
        BATTLEPASS:CreateChallenge("ultimate_metal", 2, 3, 1.5),
        BATTLEPASS:CreateChallenge("ultimate_weapons", 2, 3, 1.5),
        BATTLEPASS:CreateChallenge("counterfit_money", 50000, 5, 1.5),
        BATTLEPASS:CreateChallenge("trouble_makers", 1, 4, 1.5),
        BATTLEPASS:CreateChallenge("nerd_stompers", 1, 4, 1.5),
    },
    ["Printer"] = {
        BATTLEPASS:CreateChallenge("printer_money", 250000, 3, 1.8),
        BATTLEPASS:CreateChallenge("bitminer_1", 25, 3, 1.5),
        BATTLEPASS:CreateChallenge("teamtrees", 30, 3, 1.5)
    },
    ["Trash"] = {
        BATTLEPASS:CreateChallenge("team_trash", 2000, 3, 1.5),
        BATTLEPASS:CreateChallenge("trash_1", 10, 2, 1.5),
        BATTLEPASS:CreateChallenge("trash_2", 8, 2, 1.5),
        BATTLEPASS:CreateChallenge("trash_3", 6, 2, 1.5),
        BATTLEPASS:CreateChallenge("trash_4", 4, 2, 1.5),
        BATTLEPASS:CreateChallenge("trash_5", 3, 2, 1.5),
        BATTLEPASS:CreateChallenge("trash_6", 2, 2, 1.5),
        BATTLEPASS:CreateChallenge("trash_7", 2, 2, 1.5),
    },
    ["Arena"] = {
        BATTLEPASS:CreateChallenge("royal_crate", 1, 5, 1),
        BATTLEPASS:CreateChallenge("arena_suit", 1, 5, 1),
        BATTLEPASS:CreateChallenge("john_wick", 30, 3, 2),
        BATTLEPASS:CreateChallenge("arena_viking", 1, 4, 1),
        BATTLEPASS:CreateChallenge("xp_farmer", 1, 3),
        BATTLEPASS:CreateChallenge("damage_dealer", 1000, 3, 2.5),
        BATTLEPASS:CreateChallenge("not_your_crate", 3, 3, 2)
    },
    ["Crafting"] = {},
    --Crafting challenges
    ["Duels"] = {
        BATTLEPASS:CreateChallenge("duels_1", 5, 3),
        BATTLEPASS:CreateChallenge("duels_3", 500000, 3)
    },
    ["Coinflips"] = {
        BATTLEPASS:CreateChallenge("coinflips_1", 3, 3, 2),
        BATTLEPASS:CreateChallenge("coinflips_2", 300000, 5, 2),
        BATTLEPASS:CreateChallenge("coinflips_3", 1, 5, 2)
    },
    ["Events"] = {
        BATTLEPASS:CreateChallenge("bp8_cratepick_1", 3, 2, 2),
        BATTLEPASS:CreateChallenge("bp8_cratepick_2", 3, 2, 2),
        BATTLEPASS:CreateChallenge("darkzone_1", 1, 10, 2),
        BATTLEPASS:CreateChallenge("darkzone_2", 5, 10, 2)
    },
    ["Mining"] = {},
    --Mining challenges
    ["Unbox"] = {
        BATTLEPASS:CreateChallenge("unbox_wookie", 1, 3, 2),
        BATTLEPASS:CreateChallenge("unbox_addict", 10, 5, 2),
        BATTLEPASS:CreateChallenge("unbox_red", 10, 5, 2),
        BATTLEPASS:CreateChallenge("unbox_bastard", 1, 5, 2),
        BATTLEPASS:CreateChallenge("unbox_holy", 1, 3, 3),
        BATTLEPASS:CreateChallenge("unbox_ultvip", 1, 5, 3),
        BATTLEPASS:CreateChallenge("unbox_mysticpog", 5, 3, 2),
        BATTLEPASS:CreateChallenge("unbox_weeebs", 5, 2, 3)
    },
}

BATTLEPASS.TokenStore = {
    ["Exclusive Cases"] = {
        Progression = 5,
        Items = {
            {
                item = 1217,
                price = 500,
                max = 6
            },
        }
    },
    ["Explosive Weapons"] = {
        Progression = 15,
        Items = {
            {
                item = 236,
                price = 100,
                max = 5,
            },
            {
                item = 258,
                price = 100,
                max = 5,
            },
            {
                item = 259,
                price = 100,
                max = 5,
            },
            {
                item = 260,
                price = 100,
                max = 5,
            },
            {
                item = 261,
                price = 100,
                max = 5,
            },
        }
    },
    ["Weapons"] = {
        Progression = 0,
        Items = {
            {
                item = 161,
                price = 25,
            },
            {
                item = 220,
                price = 55,
            },
            {
                item = 221,
                price = 100,
            },
            {
                item = 238,
                price = 100,
            },
            {
                item = 263,
                price = 75,
            },
            {
                item = 264,
                price = 80,
            },
            {
                item = 293,
                price = 150,
            },
            {
                item = 292,
                price = 200,
                max = 10
            }
        }
    },
    ["Bows"] = {
        Progression = 20,
        Items = {
            {
                item = 291,
                price = 125,
            },
            {
                item = 321,
                price = 100,
            },
            {
                item = 342,
                price = 100,
            },
            {
                item = 343,
                price = 100,
            },
            {
                item = 638,
                price = 125,
                max = 5,
            },
        }
    },
    ["Cases"] = {
        Progression = 10,
        Items = {
            {
                item = 162,
                price = 100,
            },
            {
                item = 187,
                price = 130,
            },
            {
                item = 311,
                price = 150,
            },
            {
                item = 385,
                price = 150,
            },
            {
                item = 552,
                price = 175,
                max = 3,
            },
            {
                item = 1278,
                price = 200,
            },
            {
                item = 493,
                price = 200,
            },
            {
                item = 528,
                price = 225,
            },
            {
                item = 554,
                price = 250,
            },
            {
                item = 672,
                price = 250,
                max = 10,
            },
            {
                item = 1128,
                price = 400,
                max = 5,
            },
            {
                item = 1220,
                price = 200,
            },
            {
                item = 1072,
                price = 200,
            },
            {
                item = 1296,
                max = 1,
                price = 400
            }
        },
    },
    ["Legendary Crates"] = {
        Progression = 200,
        Items = {
            {
                item = 553,
                max = 1,
                price = 2000
            },
            {
                item = 351,
                max = 1,
                price = 2000
            }
        }
    },
    ["Dart Pistols"] = {
        Progression = 15,
        Items = {
            {
                item = 1173,
                price = 200,
            },
            {
                item = 1191,
                price = 100
            },
            {
                item = 1198,
                price = 150,
            },
        }
    },
    ["Royal Suits"] = {
        Progression = 25,
        Items = {
            {
                item = 355,
                price = 325,
                max = 10,
            },
            {
                item = 356,
                price = 350,
                max = 10,
            },
            {
                item = 357,
                price = 325,
                max = 10,
            }
        }
    },
    ["Utility Suits"] = {
        Progression = 25,
        Items = {
            {
                item = 557,
                price = 250,
            },
            {
                item = 1063,
                price = 250,
            },
            {
                item = 1226,
                price = 250,
                max = 5,
            },
            {
                item = 1227,
                price = 300,
                max = 4,
            },
            {
                item = 1228,
                price = 350,
                max = 3,
            },
            {
                item = 1229,
                price = 400,
                max = 2,
            },
        }
    },
    ["Prototype Suits"] = {
        Progression = 40,
        Items = {
            {
                item = 562,
                price = 250,
            },
            {
                item = 563,
                price = 250,
            },
            {
                item = 564,
                price = 250,
            },
            {
                item = 565,
                price = 250,
            },
            {
                item = 567,
                price = 250,
            }
        }
    },
    ["Rare Suits"] = {
        Progression = 75,
        Items = {
            {
                item = 1145,
                price = 500,
                max = 2
            },
            {
                item = 1153,
                price = 500,
                max = 2
            },
        }
    },
    ["Badass Collection"] = {
        Progression = 100,
        Items = {
            {
                item = 629,
                price = 250,
                max = 5
            },
            {
                item = 642,
                price = 250,
                max = 5
            },
            {
                item = 643,
                price = 250,
                max = 5
            },
            {
                item = 1109,
                price = 400,
                max = 5
            },
            {
                item = 1183,
                price = 400,
                max = 5
            },
        }
    }
}

hook.Run("Battlepass.RegisteredChallenges")
BATTLEPASS:AddPass("battlepass_11", {
    name = "Battle Pass 1",
    ends = "Next century",
    newplayer = {
        1211, 1092, 858, 659, 630, 600, 1063, 1063, 1064, 1064, 1066
    },
    rewards = {
        [1] = 292,
        [2] = 1085,
        [3] = 169,
        [4] = 690,
        [5] = 630,
        [6] = 615,
        [7] = 1102,
        [8] = 603,
        [9] = 292,
        [10] = 293,
        [11] = 695,
        [12] = 324,
        [13] = 269,
        [14] = 449,
        [15] = 292,
        [16] = 307,
        [17] = 292,
        [18] = 293,
        [19] = 1079,
        [20] = 293,
        [21] = 324,
        [22] = 162,
        [23] = 169,
        [24] = 293,
        [25] = 292,
        [26] = 440,
        [27] = 379,
        [28] = 293,
        [29] = 292,
        [30] = 1109,
        [31] = 293,
        [32] = 475,
        [33] = 1063,
        [34] = 208,
        [35] = 292,
        [36] = 293,
        [37] = 657,
        [38] = 434,
        [39] = 292,
        [40] = 293,
        [41] = 567,
        [42] = 243,
        [43] = 208,
        [44] = 431,
        [45] = 1180,
        [46] = 292,
        [47] = 1078,
        [48] = 275,
        [49] = 208,
        [50] = 1188,
        [51] = 293,
        [52] = 169,
        [53] = 585,
        [54] = 1191,
        [55] = 1181,
        [56] = 433,
        [57] = 274,
        [58] = 1063,
        [59] = 292,
        [60] = 293,
        [61] = 357,
        [62] = 1220,
        [63] = 268,
        [64] = 292,
        [65] = 292,
        [66] = 243,
        [67] = 356,
        [68] = 293,
        [69] = 324,
        [70] = 293,
        [71] = 1063,
        [72] = 657,
        [73] = 273,
        [74] = 292,
        [75] = 293,
        [76] = 208,
        [77] = 294,
        [78] = 1173,
        [79] = 301,
        [80] = 292,
        [81] = 657,
        [82] = 1100,
        [83] = 293,
        [84] = 379,
        [85] = 293,
        [86] = 436,
        [87] = 1078,
        [88] = 620,
        [89] = 208,
        [90] = 400,
        [91] = 292,
        [92] = 418,
        [93] = 268,
        [94] = 378,
        [95] = 293,
        [96] = 1102,
        [97] = 1072,
        [98] = 445,
        [99] = 1072,
        [100] = 292,
        [101] = 292,
        [102] = 1092,
        [103] = 301,
        [104] = 324,
        [105] = 292,
        [106] = 583,
        [107] = 1063,
        [108] = 219,
        [109] = 293,
        [110] = 292,
        [111] = 1100,
        [112] = 1127,
        [113] = 1078,
        [114] = 293,
        [115] = 1128,
        [116] = 324,
        [117] = 1070,
        [118] = 1072,
        [119] = 301,
        [120] = 292,
        [121] = 1102,
        [122] = 1079,
        [123] = 379,
        [124] = 293,
        [125] = 1140,
        [126] = 615,
        [127] = 620,
        [128] = 618,
        [129] = 1079,
        [130] = 292,
        [131] = 519,
        [132] = 1132,
        [133] = 292,
        [134] = 293,
        [135] = 293,
        [136] = 1078,
        [137] = 219,
        [138] = 292,
        [139] = 583,
        [140] = 292,
        [141] = 1155,
        [142] = 1079,
        [143] = 519,
        [144] = 620,
        [145] = 1180,
        [146] = 208,
        [147] = 585,
        [148] = 275,
        [149] = 292,
        [150] = 293,
        [151] = 307,
        [152] = 554,
        [153] = 379,
        [154] = 293,
        [155] = 1183,
        [156] = 896,
        [157] = 519,
        [158] = 585,
        [159] = 1147,
        [160] = 293,
        [161] = 275,
        [162] = 293,
        [163] = 1078,
        [164] = 208,
        [165] = 292,
        [166] = 269,
        [167] = 1106,
        [168] = 275,
        [169] = 657,
        [170] = 292,
        [171] = 1100,
        [172] = 311,
        [173] = 169,
        [174] = 1191,
        [175] = 293,
        [176] = 169,
        [177] = 307,
        [178] = 379,
        [179] = 657,
        [180] = 1188,
        [181] = 292,
        [182] = 1226,
        [183] = 1229,
        [184] = 275,
        [185] = 293,
        [186] = 292,
        [187] = 620,
        [188] = 1072,
        [189] = 169,
        [190] = 292,
        [191] = 1218,
        [192] = 452,
        [193] = 1182,
        [194] = 292,
        [195] = 293,
        [196] = 260,
        [197] = 1191,
        [198] = 292,
        [199] = 1068,
        [200] = 855,
    },
    tiers = 200,
    claimable = BATTLEPASS.TokenStore,
    challenges = BATTLEPASS.ChallengesTable
})
