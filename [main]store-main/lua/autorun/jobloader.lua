if true then return end

jobLists = {}

local defaultSpawn = function(ply)
    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:SetArmor(100)
    ply:SetWalkSpeed(200)
    ply:SetRunSpeed(235)
    ply:SetJumpPower(200)
end

local function CreateJob(name, clr, model, weapons, id, sid)
    local tm_name = "TEAM_" .. string.upper(id)
    local slot = 1

    local const_id = tm_name .. slot

    local ignores = 30
    if (RPExtraTeams) then
        while (_G[const_id] and RPExtraTeams[_G[const_id]].model == model and ignores > 0) do
            slot = slot + 1
            const_id = tm_name .. slot
            ignores = ignores - 1
        end
    end

    jobLists[const_id] = {
        color = clr,
        name = name,
        model = model,
        description = [[Private Job for ]] .. name,
        weapons = weapons,
        command = "team_" .. const_id,
        max = 1,
        salary = 420,
        admin = 0,
        vote = false,
        hasLicense = false,
        candemote = false,
        category = "Private Jobs",
        PlayerLoadout = defaultSpawn,
        customCheck = function(ply) return ply:SteamID() == sid end,
        CustomCheckFailMsg = "You're not allowed to use this job",
    }
end

hook.Add("loadCustomDarkRPItems", "ASAP.LoadCustoms2", function()
    for k, v in pairs(jobLists) do
        _G[k] = DarkRP.createJob(v.name, v)
    end
end)

CreateJob("Worm",
    Color(179, 82, 82),
    "models/player/bbud/earthworm.mdl",
    {
        "pro_lockpick",
        "keypad_cracker"
    },
    "worm",
    "STEAM_0:0:64739530"
)
