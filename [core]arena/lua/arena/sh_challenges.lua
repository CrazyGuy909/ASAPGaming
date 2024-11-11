local templates = {
    {40, 15, 4000},
    {50, 20, 5000},
    {70, 25, 7000},
    {80, 30, 8000},
    {400, 75, 15000}
}

local rewards = {
    {200, 210, 226, 202},
    {225, 210, 202, 200},
    {202, 200, 210, 219},
    {200, 202, 218, 210},
    {221, 200, 202, 210}
}

local blacklistedWeapons = {
    arena_fgm148javelin_c = true,
    arena_fim92stinger_c = true,
    arena_kam12 = true,
    arena_m1014 = true,
    arena_w1200 = true,
    m9k_mossberg590 = true,
    robotnik_bo1_mak = true,
    m9k_colt1911 = true,
    m9k_m3 = true,
    cw_mr96 = true,
    cw_p99 = true,
    robotnik_bo1_mak = true,
    arena_usp45 = true,
    arena_br9 = true,
    arena_fim92stinger_c = true,
    arena_fim92stinger_c = true,
    arena_fim92stinger_c = true,
    arena_rpg7_c = true
}

local blacklistedAtts = {
    am_gib = true,
    am_magnum = true,
    am_match = true,
    arena_agility = true,
    cod_fg_m203 = true
}

local function getWeighted(x)
    while x < 5 and math.random(0, 100) > 50 do
        x = x + 1
    end

    return x
end

local function getAttachments(wep)
    local tbl = {}
    return tbl
end

if SERVER then
    util.AddNetworkString("ASAP.Arena:GenerateChallenge")
end

function asapArena:GenerateChallenges(ply)
    if not ply._arenaData then
        if (not ply._arenaData) then
            ply._arenaData = {}
        end

        ply._arenaEquipment = {
            Primary = "tfa_ak74",
            Secondary = "cw_fiveseven",
            Taunt = "laugh"
        }
    end

    ply._arenaData.Challenges = {
        Daily = {},
        Week = {},
        Start = os.date("%j", os.time())
    }

    local blacklist = {}
    for k = 1, 8 do
        local slot = math.random(1, 2) == 1 and "primary" or "secondary"
        local wep = ""

        for class, _ in RandomPairs(self.weaponList[slot]) do
            if (not asapArena:CanEquipWeapon(ply, class)) then continue end
            if (blacklistedWeapons[class] or blacklist[class]) then continue end
            wep = class
            break
        end

        local id = k == 8 and 5 or getWeighted(1)
        local weight = templates[id]

        if ((((weapons.GetStored(wep) or {}).Primary or {}).NumShots or 1) > 1) then
            weight[2] = 0
        end

        if (k == 8) then
            ply._arenaData.Challenges.Week = {
                Challenge = weight,
                Data = {0, 0, 0},
                Weapon = wep,
                Reward = table.Random(rewards[id]),
                Attachments = {}
            }
        else
            blacklist[wep] = true
            ply._arenaData.Challenges.Daily[k] = {
                Challenge = weight,
                Data = {0, 0, 0},
                Weapon = wep,
                Reward = table.Random(rewards[id]),
                Attachments = getAttachments(wep)
            }
        end
    end

    if CLIENT then return end
    self.query("UPDATE arena_players SET data= '" .. util.TableToJSON(ply._arenaData) .. "' WHERE steamid = '" .. ply:SteamID64() .. "';", function() end)
    net.Start("ASAP.Arena.SyncChallenges")
    net.WriteTable(ply._arenaData.Challenges)
    net.Send(ply)
end

local function createChallenge()
    if (IsValid(LocalPlayer())) then
        asapArena:GenerateChallenges(LocalPlayer())
    else
        timer.Simple(1, function()
            createChallenge()
        end)
    end
end

hook.Add("InitPostEntity", "GenerateOwnChallenges", function()
    if CLIENT then
        createChallenge()
    end
end)

net.Receive("ASAP.Arena:GenerateChallenge", function(l, ply)
    if (ply._arenaData and ply._arenaData.Challenges) then
        local day = os.date("%j", os.time()) - (ply._arenaData.Challenges.Start or 0) + 1

        if (day > 7) then
            asapArena:GenerateChallenges(ply)

            return
        end
    end

    if (not ply._arenaData or not ply._arenaData.Challenges) then
        asapArena:GenerateChallenges(ply)
    end
end)

function asapArena:GetChallenges(ply)
    if SERVER then
        if (not ply._arenaData.Challenges) then
            self:GenerateChallenges(ply)
        elseif (ply._arenaData.Challenges.Start + 7 <= tonumber(os.date("%j", os.time()))) then
            self:GenerateChallenges(ply)
        end
    end

    return ply._arenaData.Challenges
end

local function hasAttachments(list, wep)
    local atts = table.Count(list)

    for k, v in pairs(list) do
        if (wep.AttachmentCache[v]) then
            atts = atts - 1
            if (atts <= 0) then break end
        end
    end

    return atts <= 0
end

if SERVER then
    util.AddNetworkString("ASAP.Arena.UpdateChallenge")
    util.AddNetworkString("ASAP.Arena.SyncStats")
    util.AddNetworkString("ASAP.Arena.SyncChallenges")
    util.AddNetworkString("ASAP.Arena.FinishedChallenge")
end

hook.Add("PlayerDeath", "ASAP.Arena.Challenge", function(ply, inf, att)
    if (not ply:InArena()) then return end
    if (#asapArena:GetPlayers() < 4) then return end
    if (not att:IsPlayer() or ply == att) then return end
    local challenges = asapArena:GetChallenges(att)
    local day = os.date("%j", os.time()) - challenges.Start + 1

    if (day >= 8) then
        asapArena:GenerateChallenges(ply)
    end

    local wep = att:GetActiveWeapon()
    if not IsValid(wep) then return end

    if (challenges.Daily[day] and not att._arenaData.Challenges.Daily[day].Finished and challenges.Daily[day].Weapon == wep:GetClass() and hasAttachments(challenges.Daily[day].Attachments or {}, wep)) then
        att._arenaData.Challenges.Daily[day].Data[ply:LastHitGroup() == HITGROUP_HEAD and 2 or 1] = att._arenaData.Challenges.Daily[day].Data[ply:LastHitGroup() == HITGROUP_HEAD and 2 or 1] + 1
        net.Start("ASAP.Arena.UpdateChallenge")
        net.WriteInt(day, 4)
        net.WriteInt(att._arenaData.Challenges.Daily[day].Data[1], 16)
        net.WriteInt(att._arenaData.Challenges.Daily[day].Data[2], 16)
        net.WriteInt(att._arenaData.Challenges.Daily[day].Data[3], 32)
        net.Send(att)

        if (att._arenaData.Challenges.Daily[day].Data[att:LastHitGroup() == HITGROUP_HEAD and 2 or 1] >= att._arenaData.Challenges.Daily[day].Challenge[att:LastHitGroup() == HITGROUP_HEAD and 2 or 1]) then
            att._arenaData.Challenges.Daily[day].Finished = true
            net.Start("ASAP.Arena.FinishedChallenge")
            net.WriteInt(day, 4)
            net.Send(att)
        end
    end

    if (challenges.Week and not att._arenaData.Challenges.Week.Finished and challenges.Week.Weapon == wep and hasAttachments(challenges.Week.Attachments, wep)) then
        att._arenaData.Challenges.Week.Data[ply:LastHitGroup() == HITGROUP_HEAD and 2 or 1] = att._arenaData.Challenges.Week.Data[att:LastHitGroup() == HITGROUP_HEAD and 2 or 1] + 1
        net.Start("ASAP.Arena.UpdateChallenge")
        net.WriteInt(8, 4)
        net.WriteInt(att._arenaData.Challenges.Week.Data[1], 16)
        net.WriteInt(att._arenaData.Challenges.Week.Data[2], 16)
        net.WriteInt(att._arenaData.Challenges.Week.Data[3], 32)
        net.Send(att)

        if (att._arenaData.Challenges.Week.Data[att:LastHitGroup() == HITGROUP_HEAD and 2 or 1] >= att._arenaData.Challenges.Week.Challenges[att:LastHitGroup() == HITGROUP_HEAD and 2 or 1]) then
            att._arenaData.Challenges.Week.Finished = true
            net.Start("ASAP.Arena.FinishedChallenge")
            net.WriteInt(8, 4)
            net.Send(att)
        end
    end
end)

hook.Add("EntityTakeDamage", "ASAP.Arena.Challenge", function(ent, dmg)
    if (not ent:IsPlayer() or not ent:InArena()) then return end
    local att = dmg:GetAttacker()
    if (not att:IsPlayer() or ply == att) then return end
    if (#asapArena:GetPlayers() < 4) then return end
    local challenges = asapArena:GetChallenges(att)
    local day = os.date("%j", os.time()) - challenges.Start + 1
    local wep = att:GetActiveWeapon()
    if not IsValid(wep) then return end

    if (challenges.Daily[day] and not challenges.Daily[day].Finished and challenges.Daily[day].Weapon == wep:GetClass() and hasAttachments(challenges.Daily[day].Attachments, wep)) then
        att._arenaData.Challenges.Daily[day].Data[3] = att._arenaData.Challenges.Daily[day].Data[3] + dmg:GetDamage()
        timer.Remove(att:EntIndex() .. "_updateChallenge")

        timer.Create(att:EntIndex() .. "_updateChallenge", 5, 1, function()
            if (not IsValid(att)) then return end
            net.Start("ASAP.Arena.UpdateChallenge")
            net.WriteInt(day, 4)
            net.WriteInt(att._arenaData.Challenges.Daily[day].Data[1], 16)
            net.WriteInt(att._arenaData.Challenges.Daily[day].Data[2], 16)
            net.WriteInt(att._arenaData.Challenges.Daily[day].Data[3], 32)
            net.Send(att)
        end)
    end

    if (challenges.Week and not challenges.Week.Finished and challenges.Week.Weapon == wep and hasAttachments(challenges.Week.Attachments, wep)) then
        att._arenaData.Challenges.Week.Data[3] = att._arenaData.Challenges.Week.Data[3] + dmg:GetDamage()
        timer.Remove(att:EntIndex() .. "_updateChallenge")

        timer.Create(att:EntIndex() .. "_updateChallenge", 5, 1, function()
            if (not IsValid(att)) then return end
            net.Start("ASAP.Arena.UpdateChallenge")
            net.WriteInt(day, 4)
            net.WriteInt(att._arenaData.Challenges[day].Data[1], 16)
            net.WriteInt(att._arenaData.Challenges[day].Data[2], 16)
            net.WriteInt(att._arenaData.Challenges[day].Data[3], 32)
            net.Send(att)
        end)
    end
end)

net.Receive("ASAP.Arena.UpdateChallenge", function(l)
    local day = net.ReadInt(4)
    local kills = net.ReadInt(16)
    local headshots = net.ReadInt(16)
    local damage = net.ReadInt(32)
    local ply = LocalPlayer()

    if (day < 8) then
        ply._arenaData.Challenges.Daily[day].Data = {kills, headshots, damage}
    else
        ply._arenaData.Challenges.Week.Data = {kills, headshots, damage}
    end
end)

local function initializeChallenges(data)
    if IsValid(LocalPlayer()) then
        if not LocalPlayer()._arenaData then
            LocalPlayer()._challengeCache = data

            return
        end

        LocalPlayer()._arenaData.Challenges = data

        if IsValid(asapArena.MainPanel) then
            asapArena.MainPanel:CreateChallenge("Daily")
            asapArena.MainPanel:CreateChallenge("Weekly")
        end
    else
        timer.Simple(1.2, function()
            initializeChallenges(data)
        end)
    end
end

net.Receive("ASAP.Arena.SyncChallenges", function(l)
    local challenges = net.ReadTable()
    initializeChallenges(challenges)
end)