asapgangs = asapgangs or {
    gangList = {}
}

GANG_PRICE = 25000000

GANG_COLORS = {
    Color(230,230,230),
    Color(38, 147, 224),
    Color(159, 102, 185),
    Color(29, 184, 112),
    Color(245, 89, 54),
    Color(242, 131, 22),
    Color(4, 172, 158),
    Color(48, 71, 95)
}

GANG_PERMISSIONS = {
    EDIT_ROLES = "Edit Roles",
    DISBAND_GANG = "Disband Gang",
    GANG_INFO = "Change gang Info",
    INVITE_MEMBERS = "Invite members",
    KICK_MEMBERS = "Kick members",
    PURCHASE = "Purchase",
    WITHDRAW = "Withdraw from bank",
    VIEW_ACTIVITY = "View activity score",
    CHANGE_BACK = "Change background"
}

GANG_LOG_ALL = 0
GANG_LOG_INVITE = 1
GANG_LOG_KICK = 2
GANG_LOG_PURCHASE = 3
GANG_LOG_DEPOSIT = 4
GANG_LOG_ROLE = 5

UPGRADE_TEST = {
    ["XP"] = {
        Name = "XP Bonus",
        Data = {5, 10, 15, 20 ,25},
        Levels = 5,
        Credits = 150,
        Price = 25000000,
        Icon = "ui/gangs/xp"
    },
    ["Salary"] = {
        Name = "Salary Boost",
        Data = {2, 5, 10, 15, 20},
        Levels = 5,
        Credits = 200,
        Price = 15000000,
        Icon = "ui/gangs/currency"
    },
    ["Members"] = {
        Name = "Member limit",
        Levels = 5,
        Credits = 500,
        Data = {2, 4, 6, 8, 10},
        Price = 10000000,
        Icon = "ui/gangs/users"
    },
    ["Armor"] = {
        Name = "Extra Armor",
        Levels = 4,
        Credits = 500,
        Data = {25, 50, 75, 100},
        Price = {1000000, 2000000, 3000000, 4000000, 10000000},
        Icon = "ui/gangs/upgrades/armor"
    },
    ["Damage"] = {
        Name = "Extra Damage",
        Levels = 5,
        Credits = 500,
        Data = {2, 4, 6, 8, 10},
        Price = {150000, 3000000, 3800000, 5500000, 7900000},
        Icon = "ui/gangs/upgrades/damage",
        Buff = true
    },
    ["Shield"] = {
        Name = "Bullet Resistance",
        Levels = 5,
        Credits = 500,
        Data = {2, 4, 6, 8, 10},
        Price = {1000000, 2500000, 3800000, 4500000, 7500000},
        Icon = "ui/gangs/upgrades/shield",
        Buff = true
    },
    ["Halo"] = {
        Name = "Halo",
        Levels = 1,
        Credits = 1200,
        Data = {-1},
        Price = 10000000,
        Icon = "ui/gangs/upgrades/halo",
        Buff = true,
        onUpgrade = function()
            if IsValid(halo_option) then
                halo_option:SetVisible(true)
            end
        end
    },
    ["NoTDM"] = {
        Name = "No team Damage",
        Levels = 1,
        Credits = 800,
        Data = {-1},
        Price = 8000000,
        Icon = "ui/gangs/upgrades/notdm"
    },
    ["Prop"] = {
        Name = "Extra Props",
        Levels = 1,
        Credits = 2500,
        Data = {5},
        Price = -1,
        Icon = "ui/gangs/upgrades/prop"
    },
    ["Thompson"] = {
        Name = "Perma Thompson",
        Levels = 1,
        Credits = 1000,
        Data = {-1},
        Price = 10000000,
        Icon = "ui/gangs/upgrades/thompson"
    }
}

asapgangs.backgrounds = {
    ["flares"] = {
        URL = "http://beyond.org.sg/wp-content/uploads/2018/02/Tasteful-Bokeh-Spotlight-city.jpg",
        Name = "Flares",
        Credits = 500,
        Price = 25000000
    },
    ["banana"] = {
        URL = "https://cdn.imprvimg.com/wp-content/uploads/2018/06/powerpoint-backgrounds-1-874x540.jpg",
        Name = "Banana",
        Credits = 750,
        Price = 55000000
    },
    ["anime"] = {
        URL = "https://i.pinimg.com/originals/3c/7a/fc/3c7afc1b68c0f8cc367dd9d0f1f383de.jpg",
        Name = "Weeb",
        Credits = 1000,
        Price = 70000000
    }
}