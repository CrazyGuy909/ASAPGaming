IsDonator = function(ply) return ply:IsDonator(1) endIsUltra = function(ply) return ply:IsDonator(2) end
IsMeme = function(ply) return ply:IsDonator(3) end
IsMemeGod = function(ply) return ply:IsDonator(4) end
IsMemeLegend = function(ply) return ply:IsDonator(5) end
IsGrinch = function(ply) return ply:IsDonator(6) end
IsChungus = function(ply) return ply:IsDonator(7) end
IsVeryHot = function(ply) return ply:IsDonator(8) end
IsSpooky = function(ply) return ply:IsDonator(9) end
IsSnowy = function(ply) return ply:IsDonator(10) end
IsEGG = function(ply) return ply:IsDonator(11) end
IsUser = function(ply) return (ply:GetDonator() or 0) == 0 end
local defaultSpawn = function(ply)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:SetArmor(100)
    ply:SetWalkSpeed(200)
    ply:SetRunSpeed(235)
    ply:SetJumpPower(200)
endTEAM_MINER = DarkRP.createJob( "Miner", {	color = Color( 52, 152, 219, 255 ),	model = "models/player/Eli.mdl",	description = [[You are a mine worker. Your job is to mine minerals in the darkest mine you can find on the map. Minerals can be crafted or sold for money based on their value.]],	weapons = { "pcmac_pickaxe"},	command = "miner",	max = 15,	salary = 2500,	admin = 0,	vote = false,	category = "Citizens",	hasLicense = false} )TEAM_BASEBIGBRAIN = DarkRP.createJob("Base Engineer", {    color = Color(200, 255, 0, 255),    model = {"models/player/hostage/hostage_04.mdl"},    description = [[Base Engineer is a job that is used to protect bases you can base with any other job. You can also print and do illegal stuff.]],    weapons = {"weapon_fists", "weapon_turrets"},    command = "job_baseengineer",    max = 3,    salary = 200,    admin = 0,    vote = false,    hasLicense = false,    candemote = false,    category = "The Bad",})TEAM_BASEBIGBRAINVIP = DarkRP.createJob("Base Engineer(VIP)", {    color = Color(200, 255, 0, 255),    model = {"models/player/hostage/hostage_04.mdl"},    description = [[Base Engineer is a job that is used to protect bases you can base with any other job. You can also print and do illegal stuff.]],    weapons = {"weapon_fists", "weapon_turrets"},    command = "job_baseengineervip",    max = 3,    salary = 250,    admin = 0,    vip = true,    vote = false,    hasLicense = false,    candemote = false,    category = "V.I.P",    customCheck = function(ply) return CLIENT or IsDonator(ply) end,    CustomCheckFailMsg = "This job is V.I.P only!"})
TEAM_MAYOR = DarkRP.createJob("Mayor", {
    color = Color(150, 20, 20, 255),
    model = "models/player/donald_trump.mdl",
    description = [[The Mayor of the city creates laws to govern the city.
    If you are the mayor you may create and accept warrants.
    Type /wanted <name>  to warrant a player.
    Type /lockdown initiate a lockdown of the city.
    Everyone must be inside during a lockdown.
    The cops patrol the area.
    /unlockdown to end a lockdown]],
    weapons = {"weapon_vape_american", "weapon_fists"},
    command = "mayor",
    max = 1,
    salary = 200,
    admin = 0,
    vote = true,
    hasLicense = true,
    mayor = true,
    category = "The Good",
    PlayerLoadout = defaultSpawn,
    PlayerDeath = function(ply)
        if ply:Team() == TEAM_MAYOR then
            ply:changeTeam(TEAM_CITIZEN, true)
            for k, v in pairs(player.GetAll()) do
                DarkRP.notify(v, 1, 4, "The mayor has been killed!")
            end
        end
    end,
})
TEAM_CITIZEN = DarkRP.createJob("Citizen", {
    color = Color(20, 150, 20, 255),
    model = {"models/player/group01/male_09_new.mdl", "models/player/group01/female_02_new.mdl", "models/player/Group01/Female_06.mdl", "models/player/group01/female_06_new.mdl", "models/player/group01/female_01_new.mdl", "models/player/group01/male_01_new.mdl", "models/player/group01/male_04_new.mdl", "models/player/Group01/Male_06.mdl", "models/player/group01/male_06_new.mdl", "models/player/group01/male_07_new.mdl"},
    description = [[The Citizen is the most basic level of society you can hold besides being a hobo. You have no specific role in city life.]],
    weapons = {"weapon_fists"},
    command = "job_citizen",
    max = 0,
    salary = 50,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens",
})
TEAM_RADIODJ = DarkRP.createJob("DJ", {
    color = Color(56, 145, 145, 255),
    model = {"models/konnie/asapgaming/fortnite/marshmello.mdl", "models/player/soldier_stripped.mdl"},
    description = [[A radio DJ entertains and plays music using in-game radio entity.]],
    weapons = {"weapon_fists"},
    command = "RadioDJ",
    max = 6,
    salary = 260,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = true,
    category = "Citizens",
})
TEAM_BITMINER = DarkRP.createJob("Bitcoin Miner", {
    color = Color(255, 255, 0, 255),
    model = {"models/player/magnusson_new.mdl"},
    description = [[Become a crypto currency millionaire]],
    weapons = {"weapon_fists"},
    command = "bitcoiminer",
    max = 6,
    salary = 500,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = true,
    category = "Citizens",
})
TEAM_BITMINERVIP = DarkRP.createJob("Bitcoin Miner (V.I.P)", {
    color = Color(255, 255, 0, 255),
    model = {"models/player/magnusson_new.mdl"},
    description = [[Become a crypto currency millionaire]],
    weapons = {"weapon_fists"},
    command = "bitcoinminervip",
    max = 3,
    salary = 750,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "V.I.P",
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})
TEAM_RUSSIANGANG = DarkRP.createJob("Slav", {
    color = Color(115, 115, 115, 255),
    model = {"models/half-dead/Gopniks/extra/playermodelonly.mdl"},
    description = [[The Russian Gangster has to do what the Russian Mob Boss tells them to do.
- Can mug.
- Can raid.
- Can Kidnap
- Can Print
- Can't kill your own gang members
- Cannot team with other types of gangsters.]],
    weapons = {"weapon_fists", "lockpick", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "job_russiangang",
    max = 10,
    salary = 50,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "The Bad",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply:SetArmor(25)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(235)
        ply:SetJumpPower(200)
    end
})
TEAM_DRUG = DarkRP.createJob("Drug Dealer", {
    color = Color(100, 100, 100, 255),
    model = {"models/player/soldier_stripped.mdl"},
    description = [[Sell drugs to people, try not to get arrested by police.]],
    weapons = {"weapon_fists"},
    command = "job_drugdealer",
    max = 3,
    salary = 35,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "The Bad",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply:SetArmor(25)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(235)
        ply:SetJumpPower(200)
    end
})

TEAM_AMERICANGANG = DarkRP.createJob("Gangster", {
    color = Color(115, 115, 115, 255),
    model = {
        "models/player/group03/male_09_new.mdl", 
        "models/player/group03/male_07_new.mdl", 
        "models/player/group03/male_03_new.mdl", 
        "models/player/group03/male_04_new.mdl", 
        "models/player/group03/male_02_new.mdl", 
        "models/player/group03/male_01_new.mdl", 
        "models/player/group03/female_06_new.mdl", 
        "models/player/group03/female_02_new.mdl", 
        "models/player/group03/female_01_new.mdl"
    },
    description = [[The American Gangster has to do what the American Mob Boss tells them to do!
- Can mug.
- Can raid.
- Can Kidnap
- Can Print
- Can't kill your own gang members
- Cannot team with other types of gangsters.]],
    weapons = {"weapon_fists", "lockpick", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "job_americangang",
    max = 15,
    salary = 50,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "The Bad",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply:SetArmor(25)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(235)
        ply:SetJumpPower(200)
    end
})

TEAM_AMERICANBOSS = DarkRP.createJob("Mob Boss", {
    color = Color(115, 115, 115, 255),
    model = {"models/player/gman_high_new.mdl"},
    description = [[The American Mob boss is the boss of the American Gangsters in the city.
With his power he coordinates the gangsters and forms an efficient crime organization.
He has the ability to break into houses by using a lockpick.
The Mob boss posesses the ability to unarrest you.
- Can mug.
- Can raid.
- Can kidnap
- Can Print
- Can't kill your own gang members
- Controls the Russian Mob.
- Can break people out of jail.]],
    weapons = {"weapon_fists", "unarrest_stick", "lockpick", "m9k_deagle", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "job_americanboss",
    max = 1,
    salary = 125,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = true,
    category = "The Bad",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply:SetArmor(50)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(235)
        ply:SetJumpPower(200)
    end
})

TEAM_THIEF = DarkRP.createJob("Thief", {
    color = Color(0, 0, 0, 255),
    model = {"models/player/arctic.mdl"},
    description = [[The Thief is a dirty job, one of the most hated professions in society.
- Can mug.
- Can Kidnap
- Can print
- Can raid.]],
    weapons = {"weapon_fists", "lockpick", "keypad_cracker", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "job_thief",
    max = 25,
    salary = 25,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "The Bad",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply:SetArmor(25)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(235)
        ply:SetJumpPower(200)
    end
})

TEAM_PROTHIEF = DarkRP.createJob("Pro Thief", {
    color = Color(0, 0, 0, 255),
    model = {"models/player/terroriser/brian.mdl"},
    description = [[The Thief is a dirty job, one of the most hated professions in society.
- Can mug.
- Can Kidnap
- Can print
- Can raid.]],
    weapons = {"weapon_fists", "pro_lockpick", "prokeypadcracker", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "job_prothief",
    max = 15,
    salary = 45,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "V.I.P",
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})

TEAM_BASEBIGBRAINMEME = DarkRP.createJob("Base Engineer(Ambassador)", {
    color = Color(200, 255, 0, 255),
    model = {"models/player/hostage/hostage_04.mdl"},
    description = [[Base Engineer is a job that is used to protect bases you can base with any other job. You can also print and do illegal stuff.]],
    weapons = {"weapon_fists"},
    command = "job_baseengineermeme",
    max = 3,
    salary = 250,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Ambassador",
    customCheck = function(ply) return CLIENT or IsMeme(ply) end,
    CustomCheckFailMsg = "This job is Ambassador only!"
})

TEAM_HOTEL = DarkRP.createJob("Hotel Manager", {
    color = Color(56, 145, 145, 255),
    model = {"models/player/mossman_arctic.mdl"},
    description = [[You are the Hotel Manager, make sure that the hotel is fixed up and that people pays for staying there.]],
    weapons = {"weapon_fists"},
    command = "hotel",
    max = 1,
    salary = 560,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = true,
    category = "Citizens"
})

TEAM_KERMITLOL = DarkRP.createJob("Kermit", {
    color = Color(56, 145, 145, 255),
    model = {"models/player/kermit.mdl"},
    description = [[Kermit The Frog.]],
    weapons = {"weapon_fists"},
    command = "kermitlol",
    max = 1,
    salary = 560,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens"
})

TEAM_HITMAN = DarkRP.createJob("Hitman", {
    color = Color(50, 50, 50, 255),
    model = {"models/player/hitman_absolution_47_classic.mdl"},
    description = [[The Hitman goes around and if someone has a hit, he can choose if he wants to Deny or Accept the hit! Be careful though you might get arrested.
- Can Print
- Can take hits.]],
    weapons = {"weapon_fists", "lockpick", "keypad_cracker"},
    command = "job_hitman",
    max = 4,
    salary = 100,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = true,
    category = "The Bad",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply:SetArmor(50)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(235)
        ply:SetJumpPower(200)
    end
})
TEAM_GUNM9K = DarkRP.createJob("Gun Dealer", {
    color = Color(209, 151, 0, 255),
    model = {"models/player/monk_new.mdl"},
    description = [[A Gun Dealer is the only person who can sell guns to other people.
Make sure you aren't caught selling illegal firearms to the public! You might get arrested!.]],
    weapons = {"weapon_fists"},
    command = "job_gundealerm9k",
    max = 8,
    salary = 150,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = true,
    category = "Citizens",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply:SetArmor(0)
        ply:SetWalkSpeed(165)
        ply:SetRunSpeed(210)
        ply:SetJumpPower(175)
    end
})

TEAM_HOBO = DarkRP.createJob("Hobo", {
    color = Color(158, 104, 0, 255),
    model = {"models/player/corpse1.mdl"},
    description = [[The lowest member of society. Everybody laughs at you.
You have no home.
Beg for your food and money
Sing for everyone who passes to get money
Make your own wooden home somewhere in a corner or outside someone else's door
- Can base on sidewalks.]],
    weapons = {"weapon_fists", "weapon_bugbait"},
    command = "job_hobo",
    max = 0,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens",
})
TEAM_BABY = DarkRP.createJob("Angry Baby", {
    color = Color(158, 104, 0, 255),
    model = {"models/player/dewobedil/mortal_kombat/baby_default_p.mdl"},
    description = [[Raid/Mug/Print/Base/Kidnap - YES.]],
    weapons = {"weapon_fists", "lockpick", "keypad_cracker", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "job_baby",
    max = 15,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "The Bad",
})

TEAM_HOBOKING = DarkRP.createJob("Hobo King", {
    color = Color(158, 104, 0, 255),
    model = {"models/player/zombie_soldier.mdl"},
    description = [[The lowest member of society. Everybody laughs at you.
You have no home.
Beg for your food and money
Sing for everyone who passes to get money
Make your own wooden home somewhere in a corner or outside someone else's door.
]],
    weapons = {"weapon_fists", "weapon_bugbait", "weapon_crowbar"},
    command = "job_hoboking",
    max = 1,
    salary = 10,
    admin = 0,
    vote = true,
    hasLicense = false,
    candemote = false,
    category = "Citizens",
    NeedToChangeFrom = TEAM_HOBO,
})
TEAM_GUARD = DarkRP.createJob("Personal Guard", {
    color = Color(0, 30, 189, 255),
    model = {"models/player/barney_new.mdl"},
    description = [[As the Personal Guard you can get hired by anyone with enough money, and make sure to keep that person safe.]],
    weapons = {"riot_shield"},
    command = "job_guard",
    max = 6,
    salary = 75,
    admin = 0,
    vote = true,
    hasLicense = false,
    candemote = false,
    category = "The Good",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(125)
        ply:SetHealth(125)
        ply:SetArmor(75)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end
})
TEAM_MEDIC = DarkRP.createJob("Medic", {
    color = Color(230, 0, 0, 255),
    model = "models/player/kleiner_new.mdl",
    description = [[With your medical knowledge you work to restore players to full health.
Without a medic, people cannot be healed.]],
    weapons = {"weapon_fists", "med_kit"},
    command = "job_medic",
    max = 6,
    salary = 150,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens",
    medic = false,
})
TEAM_BARTENDER = DarkRP.createJob("Bartender", {
    color = Color(98, 34, 0, 255),
    model = "models/player/hostage/hostage_01.mdl",
    description = [[Make a bar sell alcohol to people to make money.]],
    weapons = {"weapon_fists"},
    command = "job_bartender",
    max = 3,
    salary = 125,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens",
    medic = false,
})
TEAM_SWAT = DarkRP.createJob("S.W.A.T", {
    color = Color(0, 30, 189, 255),
    model = {"models/mw2guy/bz/tfbz02.mdl"},
    description = [[As a S.W.A.T member you go on Police Raids with the Chief and also makes sure that the PD is safe.]],
    weapons = {"heavy_shield", "arrest_stick", "unarrest_stick", "stunstick", "door_ram", "weaponchecker", "mac_bo2_scorp", "m9k_deagle"},
    command = "job_swat",
    max = 8,
    salary = 225,
    admin = 0,
    vote = true,
    hasLicense = false,
    candemote = true,
    category = "The Good",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(150)
        ply:SetHealth(150)
        ply:SetArmor(150)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end
})
TEAM_SWATCHIEF = DarkRP.createJob("S.W.A.T Chief", {
    color = Color(0, 30, 189, 255),
    model = {"Models/mw2guy/BZ/tfbz02.mdl"},
    description = [[As the Chief of S.W.A.T you got to make sure that everything is Okay and that everyone is safe, go around Police Raiding.]],
    weapons = {"deployable_shield", "arrest_stick", "unarrest_stick", "stunstick", "door_ram", "weaponchecker", "m9k_acr", "m9k_deagle"},
    command = "job_swatchief",
    max = 1,
    salary = 300,
    admin = 0,
    lvl = 20,
    vote = true,
    hasLicense = false,
    candemote = true,
    category = "The Good",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(150)
        ply:SetHealth(150)
        ply:SetArmor(150)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end
})

TEAM_SWATSNIPER = DarkRP.createJob("S.W.A.T Sniper", {
    color = Color(0, 30, 189, 255),
    model = {"models/codmw2/codmw2m.mdl"},
    description = [[As the S.W.A.T Sniper you are the person staying back, and has a long distance to where the Police Raids happen, so you can keep an eye of the whole situation.]],
    weapons = {"deployable_shield", "arrest_stick", "unarrest_stick", "stunstick", "door_ram", "weaponchecker", "robotnik_mw2_brt", "m9k_deagle"},
    command = "job_swatsniper",
    max = 5,
    salary = 425,
    admin = 0,
    lvl = 15,
    vote = true,
    hasLicense = false,
    candemote = true,
    category = "The Good",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(150)
        ply:SetArmor(150)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end
})

TEAM_SWATMEDIC = DarkRP.createJob("S.W.A.T Medic", {
    color = Color(0, 30, 189, 255),
    model = {"models/mw2guy/bz/tfbz02.mdl"},
    description = [[As the S.W.A.T Medic its your job to heal and make sure that the other S.W.A.T members stays alive.]],
    weapons = {"heavy_shield", "arrest_stick", "unarrest_stick", "stunstick", "door_ram", "weaponchecker", "robotnik_mw2_mp5", "m9k_deagle", "robotnik_mw2_m10", "med_kit"},
    command = "job_swatmedic",
    max = 3,
    salary = 475,
    admin = 0,
    lvl = 5,
    vote = true,
    hasLicense = false,
    candemote = true,
    category = "The Good",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(150)
        ply:SetArmor(150)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end
})

TEAM_POLICE = DarkRP.createJob("Police", {
    color = Color(3, 0, 156, 255),
    model = {"models/player/londoncop/londoncop_02.mdl", "models/player/londoncop/londoncop_01.mdl"},
    description = [[As a Police Member its your job to make sure that The Citizens stays safe, and that PD is safe.]],
    weapons = {"riot_shield", "mac_bo2_b23r", "arrest_stick", "unarrest_stick", "stunstick", "weaponchecker", "door_ram"},
    command = "job_police",
    max = 8,
    salary = 100,
    admin = 0,
    vote = true,
    hasLicense = false,
    candemote = true,
    category = "The Good",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(125)
        ply:SetHealth(125)
        ply:SetArmor(75)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end
})

TEAM_POLICECHIEF = DarkRP.createJob("Police Chief", {
    color = Color(3, 0, 156, 255),
    model = {"Models/mw2guy/BZ/tfbz01.mdl"},
    description = [[As the Police Chief its your job to make sure the Police does their job and that The Citizen stays safe.]],
    weapons = {"riot_shield", "m9k_famas", "arrest_stick", "unarrest_stick", "stunstick", "weaponchecker", "door_ram"},
    command = "job_policechief",
    max = 1,
    salary = 200,
    admin = 0,
    vote = true,
    hasLicense = false,
    candemote = true,
    category = "The Good",
    NeedToChangeFrom = TEAM_POLICE,
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(150)
        ply:SetHealth(150)
        ply:SetArmor(100)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end
})

TEAM_POLICEROBOT = DarkRP.createJob("Police Robot", {
    color = Color(0, 0, 200, 255),
    model = {"models/blagod/mass_effect/pm/cerberus/rampart_cerb_light.mdl"},
    description = [[Police Robot is one of the strongest weapons in the police. Hard to kill, but easy to get killed by. Made to protect people from criminals that are wearing powerful suits. You can't shoot people that are not wanted.]],
    weapons = {"mac_bo2_an94", "heavy_shield", "tfa_csgo_sonarbomb", "tfa_csgo_medishot", "arrest_stick", "door_ram"},
    command = "job_policerobot",
    max = 2,
    salary = 500,
    admin = 0,
    vote = true,
    hasLicense = false,
    candemote = true,
    category = "The Good",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(300)
        ply:SetHealth(300)
        ply:SetArmor(300)
        ply:SetWalkSpeed(280)
        ply:SetRunSpeed(310)
        ply:SetJumpPower(275)
    end
})

TEAM_BANK = DarkRP.createJob("Banker", {
    color = Color(0, 10, 255, 255),
    model = {"models/player/magnusson_new.mdl"},
    description = [[As the Banker you can store peoples printers and make sure they are save.]],
    weapons = {"weapon_fists"},
    command = "job_bank",
    max = 2,
    salary = 125,
    admin = 0,
    vote = true,
    hasLicense = false,
    candemote = true,
    category = "The Good"
})

TEAM_STRIPPER = DarkRP.createJob("Stripper", {
    color = Color(250, 4, 255, 255),
    model = {"models/player/p2_chell_new.mdl"},
    description = [[The Stripper is always pleasing the customer cause if they don’t they might get fired.]],
    weapons = {"weapon_fists"},
    command = "job_stripper",
    max = 5,
    salary = 225,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens"
})
TEAM_MMEMBER = DarkRP.createJob("Military Member", {
    color = Color(9, 112, 0, 255),
    model = "Models/CODMW2/CODMW2HEXE.mdl",
    description = [[The Military Member goes to war against terrorist and is fighting for the greater good!]],
    weapons = {"weapon_fists", "heavy_shield", "robotnik_mw2_m4", "robotnik_mw2_44", "arrest_stick", "unarrest_stick", "door_ram"},
    command = "mmember",
    max = 6,
    salary = 400,
    admin = 0,
    vote = false,
    hasLicense = true,
    category = "The Good",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(150)
        ply:SetHealth(150)
        ply:SetArmor(150)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end
})
TEAM_MHEAVY = DarkRP.createJob("Military Heavy", {
    color = Color(9, 112, 0, 255),
    model = "models/mw2guy/riot/riot_us.mdl",
    description = [[Military Heavy is the “Tank” of the military you are the Front Line.]],
    weapons = {"weapon_fists", "heavy_shield", "m9k_coltpython", "robotnik_mw2_brt", "mac_bo2_hamr", "robotnik_mw2_stkr", "arrest_stick", "unarrest_stick", "door_ram"},
    command = "mheavy",
    max = 2,
    salary = 700,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "V.I.P",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(200)
        ply:SetHealth(200)
        ply:SetArmor(200)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end,
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})
TEAM_MLEADER = DarkRP.createJob("Military Leader", {
    color = Color(9, 112, 0, 255),
    model = "Models/mw2guy/BZ/bzsoap.mdl",
    description = [[Military Leader is the person to tell people what to do, and will punish people if they make mistakes.]],
    weapons = {"weapon_fists", "deployable_shield", "mac_bo2_qbblsw", "m9k_deagle", "arrest_stick", "unarrest_stick", "door_ram"},
    command = "mleader",
    max = 1,
    salary = 650,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "V.I.P",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(235)
        ply:SetHealth(235)
        ply:SetArmor(235)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end,
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})
TEAM_MROBOT = DarkRP.createJob("Military Robot", {
    color = Color(255, 0, 0, 255),
    model = "models/blagod/mass_effect/pm/cerberus/rampart_cerb.mdl",
    description = [[Military Robot is one of the strongest weapons in the military. Hard to kill, but easy to get killed by. Made to protect people from criminals that are wearing powerful suits. You can't shoot people that are not wanted.]],
    weapons = {"tfa_ins2_volk", "heavy_shield", "tfa_csgo_sonarbomb", "arrest_stick", "mac_bo2_smaw", "door_ram"},
    command = "mrobot",
    max = 4,
    salary = 1000,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "V.I.P",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(400)
        ply:SetHealth(400)
        ply:SetArmor(400)
        ply:SetWalkSpeed(300)
        ply:SetRunSpeed(350)
        ply:SetJumpPower(300)
    end,
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})
TEAM_BATMAN = DarkRP.createJob("Batman", {
    color = Color(0, 0, 0, 255),
    model = "Models/player/combat_batman/combat_batman.mdl",
    description = [[PI AM BATMAN, WHERES RACHEL, Batman is a vigilante and fights to get bad people out of town, but be careful police might not always see you as a good person.]],
    weapons = {"weapon_fists"},
    command = "batman",
    max = 1,
    salary = 100,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "V.I.P",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(100)
        ply:SetHealth(100)
        ply:SetArmor(0)
        ply:SetWalkSpeed(265)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end,
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})

TEAM_VADER = DarkRP.createJob("Darth Vader", {
    color = Color(0, 0, 0, 255),
    model = "models/player/darth_vader.mdl",
    description = [[You the commander of the Dark Side, and will do anything to get your kids over if they wont, theres no other way than WAR!]],
    weapons = {"weapon_fists", "weapon_lightsaber", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "vader",
    max = 5,
    salary = 400,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "V.I.P",
    PlayerLoadout = defaultSpawn,
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})

TEAM_ASSASSIN = DarkRP.createJob("Assassin", {
    color = Color(200, 200, 200, 255),
    model = "models/player/ezio.mdl",
    description = [[You are an Assassin and can get hired to kill anyone, but you have to do it the Assassin way DON’T GET CAUGHT.]],
    weapons = {"weapon_fists", "pro_lockpick", "prokeypadcracker"},
    command = "assassin",
    max = 6,
    salary = 350,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "V.I.P",
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})

TEAM_JOKER = DarkRP.createJob("Joker", {
    color = Color(20, 255, 0, 255),
    model = "models/player/bobert/AOJoker.mdl",
    description = [[The Joker is the Top Criminal and is in a personal fight with Batman, The Joker laughs at anything!]],
    weapons = {"weapon_fists", "pro_lockpick", "prokeypadcracker", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "joker",
    max = 10,
    salary = 500,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "V.I.P",
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})

TEAM_SHEAVY = DarkRP.createJob("S.W.A.T Heavy", {
    color = Color(0, 7, 166, 255),
    model = "models/codmw2/codmw2.mdl",
    description = [[The S.W.A.T Heavy is a beefy fucker! Try to absorb damage instead of your team mates, as you have heavy duty kevlar armor.]],
    weapons = {"weapon_fists", "arrest_stick", "heavy_shield", "unarrest_stick", "stunstick", "door_ram", "weaponchecker", "robotnik_mw2_240", "robotnik_mw2_usp"},
    command = "sheavy",
    max = 1,
    salary = 500,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "V.I.P",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(120)
        ply:SetHealth(120)
        ply:SetArmor(100)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end,
    customCheck = function(ply) return CLIENT or IsDonator(ply) end,
    CustomCheckFailMsg = "This job is V.I.P only!"
})

TEAM_EXPLOSIVE = DarkRP.createJob("Explosive Dealer", {
    color = Color(55, 60, 50, 255),
    model = "models/norpo/ArkhamOrigins/Assassins/Deathstroke_ValveBiped.mdl",
    description = [[You are the most wanted Dealer in town and has to watch out for Police (Self Supply allowed)]],
    weapons = {"weapon_fists"},
    command = "explosive",
    max = 2,
    salary = 550,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ultra V.I.P",
    customCheck = function(ply) return CLIENT or IsUltra(ply) end,
    CustomCheckFailMsg = "This job is Ultra V.I.P only!"
})

TEAM_SUPERS = DarkRP.createJob("Super Soldier", {
    color = Color(0, 0, 255, 255),
    model = "models/mw2guy/riot/juggernaut.mdl",
    description = [[You are the best of all Soldiers so you have to make sure that everyone is safe DON’T FAIL THE MISSION!]],
    weapons = {"weapon_fists", "heavy_shield", "mac_bo2_warmach", "robotnik_mw2_brt", "robotnik_mw2_stkr", "mac_bo2_kard", "mac_bo2_deathmach", "arrest_stick", "unarrest_stick", "weaponchecker", "door_ram"},
    command = "supers",
    max = 2,
    salary = 500,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ultra V.I.P",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(350)
        ply:SetHealth(350)
        ply:SetArmor(350)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(255)
        ply:SetJumpPower(200)
    end,
    customCheck = function(ply) return CLIENT or IsUltra(ply) end,
    CustomCheckFailMsg = "This job is Ultra V.I.P only!"
})

TEAM_SPECIALSNIPER = DarkRP.createJob("Special Forces Sniper", {
    color = Color(5, 5, 5, 255),
    model = "models/mw2guy/diver/diver_03.mdl",
    description = [[You are the best of all Soldiers so you have to make sure that everyone is safe DON’T FAIL THE MISSION!]],
    weapons = {"weapon_fists", "deployable_shield", "arrest_stick", "m9k_svu", "unarrest_stick", "weaponchecker", "door_ram", "m9k_mp5sd"},
    command = "specialsniper",
    max = 3,
    salary = 350,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ultra V.I.P",
    PlayerLoadout = defaultSpawn,
    customCheck = function(ply) return CLIENT or IsUltra(ply) end,
    CustomCheckFailMsg = "This job is Ultra V.I.P only!"
})

TEAM_SPECIALFORCE = DarkRP.createJob("Special Forces", {
    color = Color(5, 5, 5, 255),
    model = "models/mw2guy/diver/diver_01.mdl",
    description = [[You are the best of all Soldiers so you have to make sure that everyone is safe DON’T FAIL THE MISSION!]],
    weapons = {"heavy_shield", "arrest_stick", "med_kit", "unarrest_stick", "weaponchecker", "door_ram", "m9k_mp5sd", "m9k_knife"},
    command = "specialforces",
    max = 6,
    salary = 350,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ultra V.I.P",
    PlayerLoadout = defaultSpawn,
    customCheck = function(ply) return CLIENT or IsUltra(ply) end,
    CustomCheckFailMsg = "This job is Ultra V.I.P only!"
})
TEAM_SPECIALMEDIC = DarkRP.createJob("Special Forces Medic", {
    color = Color(5, 5, 5, 255),
    model = "models/mw2guy/diver/diver_02.mdl",
    description = [[You are the best of all Soldiers so you have to make sure that everyone is safe DON’T FAIL THE MISSION!]],
    weapons = {"heavy_shield", "arrest_stick", "med_kit", "unarrest_stick", "weaponchecker", "door_ram", "m9k_mp5sd", "m9k_usp", "m9k_knife"},
    command = "specialmedic",
    max = 3,
    salary = 350,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ultra V.I.P",
    PlayerLoadout = defaultSpawn,
    customCheck = function(ply) return CLIENT or IsUltra(ply) end,
    CustomCheckFailMsg = "This job is Ultra V.I.P only!"
})
TEAM_GOAT = DarkRP.createJob("Goat", {
    color = Color(80, 80, 80, 255),
    model = "models/goatplayer/goat_player.mdl",
    description = [[Meeeeeeeeeeh, You run around being derpy and loves to ram into people!]],
    weapons = {"weapon_fists"},
    command = "goat",
    max = 0,
    salary = 0,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ultra V.I.P",
    customCheck = function(ply) return CLIENT or IsUltra(ply) end,
    CustomCheckFailMsg = "This job is Ultra V.I.P only!"
})
TEAM_LUKE = DarkRP.createJob("Luke Skywalker", {
    color = Color(10, 201, 0, 255),
    model = "models/player/luke_skywalker.mdl",
    description = [[You are the son of Darth Vader, you hate the Dark Side and will always be in war with them.]],
    weapons = {"weapon_fists", "weapon_lightsaber"},
    command = "luke",
    max = 5,
    salary = 40,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ultra V.I.P",
    customCheck = function(ply) return CLIENT or IsUltra(ply) end
})

TEAM_SMOKEITLOL = DarkRP.createJob("BigSmoke", {
    color = Color(11, 138, 0, 255),
    model = "models/bigsmoke/smoke.mdl",
    description = [[Can Raid/Mug/Base/Kidnap/Print/Mine]],
    weapons = {"weapon_fists", "m9k_uzi", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "bigsmokeboi",
    max = 3,
    salary = 460,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ambassador",
    customCheck = function(ply) return CLIENT or IsMeme(ply) end,
    CustomCheckFailMsg = "This job is Ambassador only!"
})

TEAM_PBABY = DarkRP.createJob("Pro Baby", {
    color = Color(143, 186, 0, 255),
    model = "models/player/dewobedil/mortal_kombat/baby_default_p.mdl",
    description = [[Can Raid/Mug/Base/Kidnap/Print/Mine]],
    weapons = {"weapon_fists", "pro_lockpick", "prokeypadcracker", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "probaby",
    max = 10,
    salary = 90,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ambassador",
    customCheck = function(ply) return CLIENT or IsMeme(ply) end,
    CustomCheckFailMsg = "This job is Ambassador only!"
})

TEAM_PIANIST = DarkRP.createJob("Pianist", {
    color = Color(143, 186, 0, 255),
    model = "models/player/charple.mdl",
    description = [[Play the piano lmao]],
    weapons = {"weapon_fists"},
    command = "pianist",
    max = 3,
    salary = 300,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Ambassador",
    customCheck = function(ply) return CLIENT or IsMeme(ply) end,
    CustomCheckFailMsg = "This job is Ambassador only!"
})

-----------------------------------------------------------------------------------------------------------------------------------------------------
TEAM_DATBOY = DarkRP.createJob("Dat Boy", {
    color = Color(143, 20, 0, 255),
    model = "models/datboi/datboi_reference.mdl",
    description = [[]],
    weapons = {"weapon_fists", "weapon_vape", "weapon_vape_medicinal", "weapon_vape_juicy", "weapon_vape_helium", "weapon_vape_hallucinogenic", "weapon_vape_golden", "weapon_vape_american", "weapon_vape_butterfly", "weapon_vape_custom"},
    command = "datboy",
    max = 0,
    salary = 410,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Executive",
    customCheck = function(ply) return CLIENT or IsMemeGod(ply) end,
    CustomCheckFailMsg = "This job is Executive only!"
})

TEAM_PEPELMAO = DarkRP.createJob("PEPE", {
    color = Color(143, 40, 0, 255),
    model = "models/player/burd/pepe/pepe.mdl",
    description = [[]],
    weapons = {"weapon_fists", "weapon_vape", "weapon_vape_medicinal", "weapon_vape_juicy", "weapon_vape_helium", "weapon_vape_hallucinogenic", "weapon_vape_golden", "weapon_vape_american", "weapon_vape_butterfly", "weapon_vape_custom"},
    command = "pepelmao",
    max = 0,
    salary = 200,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Executive",
    customCheck = function(ply) return CLIENT or IsMemeGod(ply) end,
    CustomCheckFailMsg = "This job is Executive only!"
})

TEAM_GODTHIEF = DarkRP.createJob("God Thief", {
    color = Color(50, 186, 52, 255),
    model = "models/player/n7legion/turian_havoc.mdl",
    description = [[]],
    weapons = {"weapon_fists", "weapon_sh_detector", "weapon_sh_detector_player", "prokeypadcracker", "pro_lockpick", "jewelry_robbery_bag", "jewelry_robbery_cellphone", "jewelry_robbery_hammer"},
    command = "godthief",
    max = 0,
    salary = 300,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Executive",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(120)
        ply:SetHealth(120)
        ply:SetArmor(120)
        ply:SetWalkSpeed(200)
        ply:SetRunSpeed(235)
        ply:SetJumpPower(200)
    end,
    customCheck = function(ply) return CLIENT or IsMemeGod(ply) end,
    CustomCheckFailMsg = "This job is Executive only!"
})
TEAM_ETHAN = DarkRP.createJob("Ethan Klein", {
    color = Color(143, 186, 100, 255),
    model = "models/playermodels/sterling/ethan_pm.mdl",
    description = [[]],
    weapons = {"weapon_fists", "weapon_vape", "weapon_vape_medicinal", "weapon_vape_juicy", "weapon_vape_helium", "weapon_vape_hallucinogenic", "weapon_vape_golden", "weapon_vape_american", "weapon_vape_butterfly", "weapon_vape_custom"},
    command = "ethankelin",
    max = 0,
    salary = 235,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Executive",
    customCheck = function(ply) return CLIENT or IsMemeGod(ply) end,
    CustomCheckFailMsg = "This job is Executive only!"
})

TEAM_VAPE = DarkRP.createJob("Vape", {
    color = Color(0, 0, 0, 255),
    model = "models/emmaemmerich/sneakingsuit/playermodel/vapepm.mdl",
    description = [[]],
    weapons = {"weapon_fists", "weapon_vape", "weapon_vape_medicinal", "weapon_vape_juicy", "weapon_vape_helium", "weapon_vape_hallucinogenic", "weapon_vape_golden", "weapon_vape_american", "weapon_vape_butterfly", "weapon_vape_custom"},
    command = "vapeplayermodel",
    max = 0,
    salary = 300,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Executive",
    customCheck = function(ply) return CLIENT or IsMemeGod(ply) end,
    CustomCheckFailMsg = "This job is Executive only!"
})
TEAM_CHUNGAC = DarkRP.createJob("Big Chungus", {
    color = Color(0, 0, 0, 255),
    model = "models/tsbb/big_chungus.mdl",
    description = [[]],
    weapons = {"weapon_fists"},
    command = "pogchung",
    max = 0,
    salary = 100,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Executive",
    customCheck = function(ply) return CLIENT or IsMemeGod(ply) end,
    CustomCheckFailMsg = "This job is Executive only!"
})
TEAM_ZOMBGSPOOK = DarkRP.createJob("Zombies", {
    color = Color(0, 0, 0, 255),
    model = "models/player/zombie_classic.mdl",
    description = [[]],
    weapons = {"weapon_fists"},
    command = "pogzombie",
    max = 0,
    salary = 0,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "SPOOKY",
    customCheck = function(ply) return CLIENT or IsSpooky(ply) end,
    CustomCheckFailMsg = "This job is SPOOKY only!"
})

TEAM_SKELETSPOOK = DarkRP.createJob("Skeleton", {
    color = Color(0, 0, 0, 255),
    model = "models/player/skeleton.mdl",
    description = [[]],
    weapons = {"weapon_fists"},
    command = "pogskeleton",
    max = 0,
    salary = 0,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "SPOOKY",
    customCheck = function(ply) return CLIENT or IsSpooky(ply) end,
    CustomCheckFailMsg = "This job is SPOOKY only!"
})

TEAM_SANTAJOBSNOWY = DarkRP.createJob("Santa", {
    color = Color(255, 0, 0, 255),
    model = "models/player/christmas/santa.mdl",
    description = [[]],
    weapons = {"weapon_fists"},
    command = "snowysanta",
    max = 0,
    salary = 0,
    admin = 0,
    vip = true,
    vote = false,
    hasLicense = false,
    category = "Christmas",
    customCheck = function(ply) return CLIENT or IsSnowy(ply) end,
    CustomCheckFailMsg = "This job is Snowy only!"
})

TEAM_STAFFONDUTY = DarkRP.createJob("STAFF ON DUTY", {
    color = Color(0, 0, 0, 255),
    model = {"models/konnie/asapgaming/fortnite/peely.mdl", "models/goose.mdl"},
    description = [[]],
    weapons = {"weapon_fists", "weapon_keypadchecker", "unarrest_stick", "weapon_lightsaber", "med_kit", "lockpick"},
    command = "staffonduty",
    max = 0,
    salary = 5000,
    admin = 0,
    custom = true,
    vote = false,
    hasLicense = true,
    category = "Other",
    customCheck = function(ply)
        return table.HasValue({"owner", "senioradmin", "superadmin", "admin", "trialmoderator", "moderator"}, ply:GetNWString("usergroup"))
    end,
    CustomCheckFailMsg = "This job is STAFF only!"
})

TEAM_ARENA = DarkRP.createJob("Playing Arena", {
    color = Color(50, 90, 0, 255),
    model = "models/player/urban.mdl",
    description = [[]],
    weapons = {},
    command = "arplaypog",
    max = 0,
    salary = 0,
    admin = 0,
    custom = true,
    vote = false,
    hasLicense = true,
    category = "Other",
    PlayerLoadout = function(ply)
        ply:SetMaxHealth(200)
        ply:SetHealth(150)
        ply:SetArmor(0)
        ply:SetWalkSpeed(150)
        ply:SetRunSpeed(235)
        ply:SetJumpPower(200)
    end,
    customCheck = function(ply)
        return table.HasValue({"owner"}, ply:GetNWString("usergroup"))
    end,
    CustomCheckFailMsg = "Arena Job!"
})
GAMEMODE.CivilProtection = {
    [TEAM_POLICE] = true,
    [TEAM_POLICECHIEF] = true,
    [TEAM_SWAT] = true,
    [TEAM_SWATCHIEF] = true,
    [TEAM_SWATSNIPER] = true,
    [TEAM_SWATMEDIC] = true,
    [TEAM_SHEAVY] = true,
    [TEAM_MMEMBER] = true,
    [TEAM_MHEAVY] = true,
    [TEAM_SUPERS] = true,
    [TEAM_MLEADER] = true,
    [TEAM_SPECIALMEDIC] = true,
    [TEAM_SPECIALFORCE] = true,
    [TEAM_SPECIALSNIPER] = true,
    [TEAM_POLICEROBOT] = true,
    [TEAM_MROBOT] = true,
}

GAMEMODE.DefaultTeam = TEAM_CITIZEN