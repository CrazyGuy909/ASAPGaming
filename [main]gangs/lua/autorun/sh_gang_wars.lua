asapgangs = asapgangs or {
    gangList = {}
}

asapgangs.War = {}
asapgangs.War.MaxResourcePerPallet = 100
asapgangs.War.ZonePrice = 500000
asapgangs.War.CaptureTime = 10
asapgangs.War.Prices = {
    ["sent_gang_delivery"] = {5000, 10000, 25000},
    ["sent_gang_manufacture_table"] = {5000, 10000, 25000},
    ["sent_gang_manufacture"] = {5000, 10000, 25000},
    ["sent_gang_portal"] = {5000, 10000, 25000},
    ["sent_gang_pot"] = {5000, 10000, 25000},
}

asapgangs.War.Accessor = {
    ["sent_gang_delivery"] = "Delivery",
    ["sent_gang_manufacture_table"] = "Pieces",
    ["sent_gang_pot"] = "Weed",
}

asapgangs.War.Craftables = {
    [1] = {
        Name = "Drugs",
        Model = "models/gonzo/weedb/bag/bag.mdl",
        Difficulty = 0,
        Price = 2000,
        Info = {
            Angle = Angle(0, 0, 90),
            Scale = .8,
            Origin = Vector(6, 5, 60)
        },
        Crafts = "drugs"
    },
    [2] = {
        Name = "Weapon Parts I",
        Model = "models/weapons/w_pist_usp.mdl",
        Difficulty = 1,
        Price = 10000,
        Info = {
            Angle = Angle(-20, 0, 0),
            Scale = 1,
            Origin = Vector(6, 5, 56)
        },
        Crafts = "wp1",
        Needs = {
            [1] = 3
        },
        Minigame = 1,
    },
    [3] = {
        Name = "Metal for suits I",
        Model = "models/cw2/attachments/anpeq15.mdl",
        Difficulty = 1,
        Price = 8000,
        Info = {
            Angle = Angle(-45, 45, 0),
            Scale = 1.25,
            Origin = Vector(6, 8, 59)
        },
        Crafts = "ms1",
        Needs = {
            [1] = 3
        },
        Minigame = 2,
    },
    [4] = {
        Name = "Weapon Parts II",
        Model = "models/weapons/w_rif_m4a1_silencer.mdl",
        Difficulty = 2,
        Price = 100000,
        Info = {
            Angle = Angle(-45, 0, 0),
            Scale = .5,
            Origin = Vector(6, 5, 58)
        },
        Crafts = "wp2",
        Needs = {
            [1] = 3,
            [2] = 5
        },
        Minigame = 1,
    },
    [5] = {
        Name = "Metal for suits II",
        Model = "models/props/cs_office/projector_p6.mdl",
        Difficulty = 2,
        Price = 80000,
        Info = {
            Angle = Angle(-45, 70, 0),
            Scale = .8,
            Origin = Vector(5, 10, 57)
        },
        Crafts = "ms2",
        Needs = {
            [1] = 3,
            [3] = 5
        },
        Minigame = 2,
    },
    [6] = {
        Name = "Weapon Parts III",
        Model = "models/weapons/tfa_cso/w_heaven_scorcher_asap.mdl",
        Difficulty = 3,
        Price = 300000,
        Info = {
            Angle = Angle(-0, 80, -50),
            Scale = .7,
            Origin = Vector(6, 5, 60)
        },
        Crafts = "wp3",
        Needs = {
            [1] = 5,
            [2] = 5,
            [4] = 3,
        },
        Minigame = 1,
    },
    [7] = {
        Name = "Metal for suits III",
        Model = "models/bms/weapons/w_gaussammo.mdl",
        Difficulty = 3,
        Price = 400000,
        Info = {
            Angle = Angle(-90, 90, -10),
            Scale = .55,
            Origin = Vector(6.5, 7.5, 59)
        },
        Crafts = "ms3",
        Needs = {
            [1] = 5,
            [3] = 5,
            [5] = 3,
        },
        Minigame = 2,
    },
    [8] = {
        Name = "Ultimate Weapon Parts",
        Model = "models/weapons/tfa_cso/w_gungnira_asap.mdl",
        Difficulty = 4,
        Price = 750000,
        Info = {
            Angle = Angle(-0, 80, -50),
            Scale = .5,
            Origin = Vector(7.25, 5, 62)
        },
        Crafts = "upw",
        Needs = {
            [1] = 5,
            [2] = 10,
            [4] = 7,
            [6] = 5,
        },
        Minigame = 3,
    },
    [9] = {
        Name = "Ultimate Metal for suits",
        Model = "models/weapons/tfa_csgo/w_eq_sensorgrenade.mdl",
        Difficulty = 4,
        Price = 850000,
        Info = {
            Angle = Angle(-30, 90, 30),
            Scale = 1.1,
            Origin = Vector(6.5, 7, 60)
        },
        Crafts = "ums",
        Needs = {
            [1] = 5,
            [3] = 10,
            [5] = 7,
            [7] = 5,
        },
        Minigame = 4
    }
}

hook.Add("DarkRPFinishedLoading", "CreateGangLeader", function()
    TEAM_GANGLEADER = DarkRP.createJob("Gang Leader", {
        color = Color(255, 162, 0),
        model = "models/obama/obama.mdl",
        description = [[
            Manages bases
        ]],
        weapons = {},
        command = "gangleader3",
        max = 0,
        salary = 5000,
        admin = 0,
        vote = false,
        hasLicense = false,
        category = "The Bad",
        canDemote = true,
        customCheck = function(ply) 
            if not ply:GetGang() or ply:GetGang() == "" then
                return false
            end
            local found = false
            for k, v in pairs(asapgangs.GetMembers(ply:GetGang())) do
                if (v:Team() == TEAM_GANGLEADER) then found = true break end
            end

            return not found
        end,
        CustomCheckFailMsg = "You aren't a gang leader!",
    })
end)
