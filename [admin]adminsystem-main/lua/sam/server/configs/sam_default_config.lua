--------------------[[ DO NOT TOUCH ]]--------------------
SAM.Default_Config = SAM.Default_Config or {}
SAM.Default_Config.version = "3.0" -- Do not edit me!

--------------------[[ ASAP GAMING CONFIG ]]--------------------
SAM.Default_Config.DefaultPropLimit = 45
SAM.Default_Config.DonatorLimits = {
    ["Event Manager"] = 2000,
    ["Snowflake"] = 120,
    ["EGG"] = 110,
    ["Snowy"] = 110,
    ["Sp0okyy"] = 110,
    ["Pipi"] = 120,
    ["VERY HOT"] = 100,
    ["Chungus"] = 90,
    ["Grinch"] = 75,
    ["Meme Legend"] = 100,
    ["Meme God"] = 80,
    ["Meme"] = 75,
    ["Ultra VIP"] = 65,
    ["VIP"] = 55,
}

--------------------[[ CHAT PRESENTATION SETTINGS ]]--------------------
SAM.Default_Config.prefix = "Galaxium|" -- Prefix to place before all sam commands.
SAM.Default_Config.prefixcolor = Color(255,100,100) -- The color of said prefix.

-- A command echo is the message in chat when a command is executed. Example: "SAM | Hanz has brought Hanz"
SAM.Default_Config.echoCommands = true -- Echo commands?
SAM.Default_Config.echoToAdminsOnly = true -- Only echo to ranks with adminlevel > 0?
-- The colors to output when the command echoes
SAM.Default_Config.echoStringColor = Color(100,255,100) -- What color to make string values
SAM.Default_Config.echoNumberColor = Color(100,100,255) -- What color to make integer values
SAM.Default_Config.echoTimeColor = Color(240,230,140) -- What color to make interpreted time values
SAM.Default_Config.echoDefaultColor = Color(255,255,255) -- Waht color to make the default text inbetween special values
-- Place command names in here, any command in here will not be echoed to chat.
SAM.Default_Config.hideCommandEchoes = {
	"Cloak",
	"Noclip",
	"GetIP",
	"BanIP",
}

--------------------[[ STAFF CHAT ]]--------------------
SAM.Default_Config.prefixstaff = ":bruh3:|" -- Prefix to place before staff messages
SAM.Default_Config.prefixcolorstaff = Color(0,150,255) -- The color of said prefix.
SAM.Default_Config.staffchatcolor = Color(255,255,255) -- The color of the messages.

--------------------[[ INFO TEXT ]]--------------------
SAM.Default_Config.infoText = [[Galaxium!
Steam Group: https://discord.gg/RvwksDnBHH
Store: https://discord.gg/RvwksDnBHH]]

--------------------[[ ADMIN MODE SETTINGS ]]--------------------
SAM.Default_Config.adminmodecommands = { -- Commands that require ADMINMODE to use. Use the commands Name (!help to see them)
    --"PlyPickup", -- The name for Player Pickup
    --"BindNoclip", -- The name for noclipping with the bind (E.g pressing V. THE !NOCLIP COMMAND BYPASSES THIS)
    --"SpawnUtil", -- The name for spawning with Utilities (MUST STILL BE HIGH ENOUGH ADMINLEVEL)
}

--------------------[[ BAN SETTINGS ]]--------------------
SAM.Default_Config.banmessage = [[You're BANNED!
Reason: {REASON}
Banned By: {BANNEDBY}

Ban Date: {BANDATE}
UnBan Date: {UNBANDATE}
Make an unban appeal on https://discord.gg/RvwksDnBHH]]

--------------------[[ RANK SETTINGS ]]--------------------
SAM.Default_Config.sameweighttargeting = true -- Allow ranks with the same weight to target each other?
SAM.Default_Config.defaultrank = "user" -- The default rank
SAM.Default_Config.adminleveltospawnwithutility = 1 -- What admin level+ should be spawning with Physgun and Toolgun and have the power to pickup players (Note: if a gamemode such as darkrp gives the physgun etc to them then they WILL receive it)
SAM.Default_Config.ranks = { -- Rank configuration.
    {
        name = "user", -- Name. CANNOT CONTAIN A SPACE
        weight = 1, -- Weight.
        adminlevel = 0, -- Level of Admin: 0 = user, 1 = admin, 2 = superadmin
        limitations = { -- The amount of each of these a player can spawn at one time -- If your gamemode is not Sandbox derived (e.g TTT) do not worry about this.
            props = 0,
            entities = 0,
            npcs = 0,
            vehicles = 0,
            ragdolls = 0,
            canSpawnWeps = false, -- Can the rank spawn weapons from the Q menu?
        },
        permissions = { -- Permissions, just add  a new string ("") with the permission inside, example: "sam.msg", <-- the , is important
            "sam.help",
            "sam.info",
        },
    },
    {
        name = "trialmoderator",
        weight = 2,
        adminlevel = 1,
        max_bantime = "1w",
        limitations = {
            props = 150,
            entities = 0,
            npcs = 5,
            vehicles = 0,
            ragdolls = 0,
            canSpawnWeps = false,
        },
        permissions = {
            "sam.help",
            "sam.info",
            "sam.plypickup",
            "sam.seestaffchat",
			"sam.steamid",
			"sam.freeze",
			"sam.ban",
			"sam.goto",
			"sam.send",
			"sam.bring",
			"sam.return",
			"sam.noclip",
			"sam.cloak",
			"sam.god",
		},
    },
    {
        name = "moderator",
        weight = 3,
        adminlevel = 1,
        max_bantime = "2w",
        limitations = {
            props = 250,
            entities = 5,
            npcs = 25,
            vehicles = 0,
            ragdolls = 0,
            canSpawnWeps = false,
        },
        permissions = {
            "sam.help",
            "sam.info",
            "sam.plypickup",
            "sam.seestaffchat",
			"sam.steamid",
			"sam.freeze",
			"sam.ban",
			"sam.goto",
			"sam.send",
			"sam.bring",
			"sam.return",
			"sam.noclip",
			"sam.cloak",
			"sam.god",
		},
    },
	{
        name = "junioradmin",
        weight = 4,
        adminlevel = 1,
        max_bantime = "1mo",
        limitations = {
            props = 65,
            entities = 5,
            npcs = 250,
            vehicles = 0,
            ragdolls = 0,
            canSpawnWeps = false,
        },
        permissions = {
            "sam.help",
            "sam.info",
            "sam.setjob",
            "sam.plypickup",
            "sam.seestaffchat",
			"sam.steamid",
			"sam.freeze",
			"sam.gag",
			"sam.ban",
			"sam.unban",
			"sam.goto",
			"sam.send",
			"sam.bring",
			"sam.return",
			"sam.respawn",
			"sam.noclip",
			"sam.sethealth",
			"sam.setarmor",
			"sam.cloak",
			"sam.god",
        },
    },
	{
        name = "gamemaster",
        weight = 3,
        adminlevel = 1,
        max_bantime = "1d",
        limitations = {
            props = 1000,
            entities = 1000,
            npcs = 4000,
            vehicles = 10,
            ragdolls = 40,
            canSpawnWeps = true,
        },
        permissions = {
            "sam.help",
            "sam.info",
            "sam.plypickup",
            "sam.seestaffchat",
			"sam.steamid",
			"sam.goto",
			"sam.bring",
			"sam.return",
			"sam.noclip",
			"sam.cloak",
			"sam.god",
		},
    },
    {
        name = "admin",
        weight = 5,
        adminlevel = 1,
        max_bantime = "-1",
        limitations = {
            props = 65,
            entities = 10,
            npcs = 250,
            vehicles = 0,
            ragdolls = 0,
            canSpawnWeps = false,
        },
        permissions = {
            "sam.help",
            "sam.info",
            "sam.setjob",
            "sam.plypickup",
            "sam.seestaffchat",
			"sam.steamid",
			"sam.freeze",
			"sam.gag",
			"sam.ban",
			"sam.unban",
			"sam.goto",
			"sam.send",
			"sam.bring",
			"sam.return",
			"sam.respawn",
			"sam.noclip",
			"sam.sethealth",
			"sam.setarmor",
			"sam.cloak",
			"sam.god",
        },
    },
    {
        name = "senioradmin",
        weight = 6,
        adminlevel = 1,
        max_bantime = "-1",
        limitations = {
            props = 65,
            entities = 25,
            npcs = 1000,
            vehicles = 0,
            ragdolls = 0,
            canSpawnWeps = false,
        },
        permissions = {
            "sam.help",
            "sam.info",
            "sam.setjob",
            "sam.plypickup",
            "sam.seestaffchat",
			"sam.strip",
			"sam.steamid",
			"sam.freeze",
			"sam.gag",
			"sam.ban",
			"sam.unban",
			"sam.goto",
			"sam.send",
			"sam.bring",
			"sam.return",
			"sam.respawn",
			"sam.noclip",
			"sam.sethealth",
			"sam.setarmor",
			"sam.cloak",
			"sam.god",
        },
    },
    {
        name = "superadmin",
        weight = 7,
        adminlevel = 2,
        max_bantime = "-1",
        limitations = {
            props = 1000,
            entities = 800,
            npcs = 5000,
            vehicles = 1000,
            ragdolls = 15,
            canSpawnWeps = true,
        },
        permissions = {
            "*",
        },
    },
	{
        name = "staffmanager",
        weight = 8,
        adminlevel = 2,
        max_bantime = "-1",
        limitations = {
            props = 1000,
            entities = 800,
            npcs = 4000,
            vehicles = 10,
            ragdolls = 5,
            canSpawnWeps = true,
        },
        permissions = {
            "*",
        },
    },
    {
        name = "owner",
        weight = 9999,
        adminlevel = 2,
        max_bantime = "-1",
        limitations = {
            props = 9999,
            entities = 9999,
            npcs = 9999,
            vehicles = 9999,
            ragdolls = 9999,
            canSpawnWeps = true,
        },
        permissions = {
            "*",
        },
    },
}
