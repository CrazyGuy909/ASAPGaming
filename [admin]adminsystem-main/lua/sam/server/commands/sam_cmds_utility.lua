--[[
Commands in this file and order:
- IP
- StopSound
- SetUser
- Freeze
- Unfreeze
- Kick
- ClearRagdolls
- ClearDecals
- ClearCorpses
- AdminMode
- Gag
- Ungag
- Jail
- Unjail
- Ban
- Unban
- findents
- removemodel
- removeclass
--]]
-------------------- IP --------------------
local function ip(args, sender)
    local ply = args[1]

    if sender:IsValid() then
        sender:ChatPrint(ply:IPAddress())
    else
        print(ply:IPAddress())
    end
end

SAM.RegisterCommand({
    name = "GetIP",
    description = "Gets a players IP",
    command = "ip",
    permission = "sam.ip",
    func = ip,
    args = {SAM.Args.ply},
    checkIfCanTarget = true
})

-------------------- STOPSOUND --------------------
local function stopsound(args, sender)
    for k, v in pairs(player.GetAll()) do
        v:ConCommand("stopsound")
    end
end

SAM.RegisterCommand({
    name = "StopSound",
    description = "Stops sound for everyone",
    command = "stopsound",
    permission = "sam.stopsound",
    func = stopsound,
    args = {},
    checkIfCanTarget = false
})

-------------------- SETUSER --------------------
local function setuser(args, sender)
    local steamid, rank, expire = args[1], args[2], args[3]
    local rankTable = SAM.GetRankTable(rank)

    if rankTable then
        if expire >= 86400 or expire == -1 then
            local correctPower = false

            if not sender:IsValid() then
                correctPower = true
            else
                local senderTable = SAM.GetRankTable(sender:GetUserGroup())

                if senderTable then
                    if senderTable.weight >= rankTable.weight then
                        correctPower = true
                    end
                end
            end

            if correctPower == true then
                SAM.Query("SELECT * FROM " .. SAM.SQLPlayerTableName .. " WHERE steamid = '" .. steamid .. "'", function(data)
                    if data[1] then
                        local expTime = os.time()

                        if expire == -1 then
                            expTime = -1
                        else
                            expTime = os.time() + expire
                        end

                        SAM.Query("UPDATE " .. SAM.SQLPlayerTableName .. " SET usergroup='" .. rankTable.name .. "',expire=" .. expTime .. " WHERE steamid='" .. string.upper(steamid) .. "'")

                        if player.GetBySteamID(steamid) then
                            player.GetBySteamID(steamid):SetUserGroup(rankTable.name)
                        end

                        local strLen = SAM.TimeFormatter(expire)

                        SAM.CommandEcho("#P has set #S to #S for #T", {sender, steamid, rank, strLen}, "SetUser")
                    else
                        SAM.ShootError(sender, "No player on record with that steamid!")

                        return
                    end
                end)
            else
                SAM.ShootError(sender, "You cannot target this rank")

                return
            end
        else
            SAM.ShootError(sender, "Ranks must be assigned for longer than a day!")

            return
        end
    else
        SAM.ShootError(sender, "You have not supplied a valid rank name!")

        return
    end
end

SAM.RegisterCommand({
    name = "SetUser",
    description = "Sets a players usergroup",
    command = "setuser",
    permission = "sam.setuser",
    func = setuser,
    args = {SAM.Args.sql_ply, SAM.Args.string, SAM.Args.time},
    checkIfCanTarget = true
})

-------------------- FREEZE --------------------
local function pfreeze(args, sender)
    local plys = args[1]

    for k, v in pairs(plys) do
        v:Freeze(true)
    end

    SAM.CommandEcho("#P has frozen #MP", {sender, plys}, "Freeze")
end

SAM.RegisterCommand({
    name = "Freeze",
    description = "Freezes a player",
    command = "freeze",
    permission = "sam.freeze",
    func = pfreeze,
    args = {SAM.Args.multi_ply},
    checkIfCanTarget = true
})

-------------------- UNFREEZE --------------------
local function unpfreeze(args, sender)
    local plys = args[1]

    for k, v in pairs(plys) do
        v:Freeze(false)
    end

    SAM.CommandEcho("#P has unfrozen #MP", {sender, plys}, "Unfreeze")
end

SAM.RegisterCommand({
    name = "Unfreeze",
    description = "UnFreezes a player",
    command = "unfreeze",
    permission = "sam.freeze",
    func = unpfreeze,
    args = {SAM.Args.multi_ply},
    checkIfCanTarget = true
})

-------------------- KICK --------------------
local function kickp(args, sender)
    local plys, reason = args[1], args[2]

    for k, v in pairs(plys) do
        v:Kick(reason)
    end

    SAM.CommandEcho("#P has kicked #MP for #S", {sender, plys, reason}, "Kick")
end

SAM.RegisterCommand({
    name = "Kick",
    description = "Kicks a player",
    command = "kick",
    permission = "sam.kick",
    func = kickp,
    args = {SAM.Args.multi_ply, SAM.Args.string_restofline},
    checkIfCanTarget = true
})

-------------------- CLEARRAGDOLLS --------------------
local function cragdolls(args, sender)
    for k, v in pairs(ents.GetAll()) do
        if v:GetClass() == "prop_ragdoll" or v:GetClass() == "hl2mp_ragdoll" then
            v:Remove()
        end
    end

    SAM.CommandEcho("#P has cleared all ragdolls", {sender}, "ClearRagdolls")
end

SAM.RegisterCommand({
    name = "ClearRagdolls",
    description = "Clears all ragdolls",
    command = "clearragdolls",
    permission = "sam.clearragdolls",
    func = cragdolls,
    args = {},
    checkIfCanTarget = false
})

-------------------- CLEARDECALS --------------------
util.AddNetworkString("SAM.RemoveAllDecalsNM")

local function cdecals(args, sender)
    net.Start("SAM.RemoveAllDecalsNM")
    net.Broadcast()

    SAM.CommandEcho("#P has cleared all decals", {sender}, "ClearDecals")
end

SAM.RegisterCommand({
    name = "ClearDecals",
    description = "Clears all decals",
    command = "cleardecals",
    permission = "sam.cleardecals",
    func = cdecals,
    args = {},
    checkIfCanTarget = false
})

-------------------- CLEARCORPSES --------------------
util.AddNetworkString("SAM.ClientRemoveRagdolls")

local function ccorpses(args, sender)
    for k, v in pairs(player.GetAll()) do
        if v:GetRagdollEntity() ~= nil and v:GetRagdollEntity() ~= NULL then
            v:GetRagdollEntity():Remove()
        end
    end

    net.Start("SAM.ClientRemoveRagdolls")
    net.Broadcast()

    SAM.CommandEcho("#P has cleared all corpses", {sender}, "ClearCorpses")
end

SAM.RegisterCommand({
    name = "ClearCorpses",
    description = "Clears all corpses",
    command = "clearcorpses",
    permission = "sam.clearcorpses",
    func = ccorpses,
    args = {},
    checkIfCanTarget = false
})

-------------------- ADMINMODE --------------------
local function adminmode(args, sender)
    if sender.sam_adminmode then
        sender.sam_adminmode = nil
        sender:SetNWBool("sam_adminmode", false)

        SAM.CommandEcho("#P has left adminmode", {sender}, "AdminMode")
    else
        sender.sam_adminmode = true
        sender:SetNWBool("sam_adminmode", true)

        SAM.CommandEcho("#P has entered adminmode", {sender}, "AdminMode")
    end
end

SAM.RegisterCommand({
    name = "AdminMode",
    description = "Toggles admin mode",
    command = "adminmode",
    permission = "sam.adminmode",
    func = adminmode,
    args = {},
    checkIfCanTarget = false
})

--[[-------------------------------------------------------------------------
Discord log function
---------------------------------------------------------------------------]]
local function discordLog(admin, sid, ban, reason, len)
    if not admin or not admin:IsPlayer() or not sid then return end
    local oSid = sid
    sid = util.SteamIDTo64(sid)

    http.Fetch("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=7B9B05A10513E74A3CD075E89EF105D3&steamids=" .. sid, function(body)
        body = util.JSONToTable(body)
        local person = body.response.players[1]

        local info = {
            ban = ban and "banned" or "unbanned",
            adminUser = admin:Nick(),
            adminSid = admin:SteamID(),
            banUser = person.personaname,
            banUserSid = oSid,
            banUserProfile = person.profileurl,
            banUserAvatar = person.avatarfull,
        }

        if ban then
            info.banLength = len
            info.banReason = reason or "None"
        end

        http.Post("http://145.239.205.161:3030/hooks/asap/staff", info, nil, nil, {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "53CrT96HTMsnxRd",
        })
    end)
end

-------------------- BAN --------------------
local function banp(args, sender)
    local steamid, length, reason = args[1], args[2], args[3]

    if IsValid(sender) then
        local plyRankTable = SAM.GetRankTable(sender:GetUserGroup())

        if plyRankTable.max_bantime then
            if length > SAM.TimeInterpreter(plyRankTable.max_bantime) and tostring(plyRankTable.max_bantime) ~= "-1" then
                SAM.ShootError(sender, "You cannot ban over your max ban time of: " .. tostring(plyRankTable.max_bantime))

                return
            end

            if tostring(length) == "-1" and tostring(plyRankTable.max_bantime) ~= "-1" then
                SAM.ShootError(sender, "You cannot ban over your max ban time of: " .. tostring(plyRankTable.max_bantime))

                return
            end
        end
    end

    SAM.AddBan(steamid, sender, length, reason)
    local strLen = SAM.TimeFormatter(length)

    discordLog(sender, steamid, true, reason, strLen)

    if player.GetBySteamID(steamid) then
        steamid = player.GetBySteamID(steamid)

        SAM.CommandEcho("#P has banned #P for #T with reason: #S", {sender, steamid, strLen, reason}, "Ban")
    else
        SAM.CommandEcho("#P has banned #S for #T with reason: #S", {sender, steamid, strLen, reason}, "Ban")
    end
end

SAM.RegisterCommand({
    name = "Ban",
    description = "Bans a player from the server",
    command = "ban",
    permission = "sam.ban",
    func = banp,
    args = {SAM.Args.sql_ply, SAM.Args.time, SAM.Args.string_restofline},
    checkIfCanTarget = true
})

-------------------- IPBAN --------------------
local function banip(args, sender)
    local ipa, length, reason = args[1], args[2], args[3]
    local plyRankTable = SAM.GetRankTable(sender:GetUserGroup())

    if plyRankTable.max_bantime then
        if length > SAM.TimeInterpreter(plyRankTable.max_bantime) and tostring(plyRankTable.max_bantime) ~= "-1" then
            SAM.ShootError(sender, "You cannot ban over your max ban time of: " .. tostring(plyRankTable.max_bantime))

            return
        end

        if tostring(length) == "-1" and tostring(plyRankTable.max_bantime) ~= "-1" then
            SAM.ShootError(sender, "You cannot ban over your max ban time of: " .. tostring(plyRankTable.max_bantime))

            return
        end
    end

    SAM.AddIPBan(ipa, sender, length, reason)
    local strLen = SAM.TimeFormatter(length)

    SAM.CommandEcho("#P has IP banned #S for #T with reason: #S", {sender, ipa, strLen, reason}, "BanIP")
end

SAM.RegisterCommand({
    name = "BanIP",
    description = "Bans a specific IP from the server",
    command = "banip",
    permission = "sam.banip",
    func = banip,
    args = {SAM.Args.string, SAM.Args.time, SAM.Args.string_restofline},
    checkIfCanTarget = true
})

-------------------- UNBAN --------------------
local function unbanp(args, sender)
    local steamid = args[1]
    SAM.RemoveBan(steamid)

    SAM.CommandEcho("#P has unbanned #S", {sender, steamid}, "Unban")

    discordLog(sender, steamid, false)
end

SAM.RegisterCommand({
    name = "Unban",
    description = "UnBans a player from the server",
    command = "unban",
    permission = "sam.ban",
    func = unbanp,
    args = {SAM.Args.string},
    checkIfCanTarget = true
})

-------------------- SetGang --------------------
local function setgang(args, sender)
    local ply, gang = args[1], args[2]
    if not IsValid(ply) then return end
    asapgangs.AddMember(ply, gang)
end

SAM.RegisterCommand({
    name = "Set Gang",
    description = "Sets the gang of a player",
    command = "setgang",
    permission = "sam.kick",
    func = setgang,
    args = {SAM.Args.ply, SAM.Args.string},
    checkIfCanTarget = true
})

-------------------- RealGang --------------------
local function realrank(args, sender)
    local ply = args[1]
    if not IsValid(ply) then return end
    sender:ChatPrint("<color=green>Real rank: " .. ply:GetDonatorByRoleName() .. "</color>")
end

SAM.RegisterCommand({
    name = "Real rank",
    description = "Gets the rank of a player",
    command = "realrank",
    permission = "sam.kick",
    func = realrank,
    args = {SAM.Args.ply},
    checkIfCanTarget = true
})

-------------------- RDM Tag --------------------
local function nodamage(args, sender)
    local ply, length = args[1], args[2]
    local strLen = SAM.TimeFormatter(length)
    ply.doNotDamage = true
    MsgN("Applied no damage to " .. ply:Nick())
    SAM.CommandEcho("#P got his damage reverted for #T", {ply, strLen}, "NoDamage")

end

local noloop = false
hook.Add("EntityTakeDamage", "NoDamagePunishment", function(ply, dmg)
    local att = dmg:GetAttacker()
    if (noloop) then return end
    if (not ply:IsPlayer() or not att:IsPlayer() or ply == att) then return end
    if att.doNotDamage then
        noloop = true
        att:TakeDamageInfo(dmg)
        noloop = false
        return true
    end
end)

SAM.RegisterCommand({
    name = "Anti RDM",
    description = "Causes a player to not deal any damage",
    command = "antirdm",
    permission = "sam.ban",
    func = nodamage,
    args = {SAM.Args.ply, SAM.Args.time},
    checkIfCanTarget = true
})

SAM.RegisterCommand({
    name = "Remove anti RDM",
    description = "Causes a player to not deal any damage",
    command = "removeantirdm",
    permission = "sam.ban",
    func = function(args, sender)
        local ply = args[1]
        if not IsValid(ply) then return end
        SAM.CommandEcho("#P got his antirdm removed", {ply}, "NoDamage")
        ply.doNotDamage = false
        ply:SetAntiRDM(false)
    end,
    args = {SAM.Args.ply}
})
-------------------- Rewards --------------------
local function givereward(args, sender)
    local ply = args[1]
    local typ = args[2]
    if not IsValid(ply) or not typ then return end
    asapRewards:ProcessRewards(ply, typ)
end

SAM.RegisterCommand({
    name = "Proccess Reward",
    description = "Players will receive the reward they did",
    command = "givereward",
    permission = "sam.ban",
    func = givereward,
    args = {SAM.Args.ply, SAM.Args.number},
    checkIfCanTarget = true
})

local ignore = {
    env_sprite = true,
    predicted_viewmodel = true,
    prop_door_rotating = true
}

local function findents(args, sender)
    local radius = tonumber(args[1] or 300)
    sender:ChatPrint("<color=green>Entities around you:</color>")

    for k, v in pairs(ents.FindInSphere(sender:GetPos(), radius)) do
        if ignore[v:GetClass()] or v:IsWeapon() then continue end
        sender:ChatPrint(v:EntIndex() .. " - " .. v:GetClass())
    end
end

SAM.RegisterCommand({
    name = "Find Ents",
    description = "Find entities around the player",
    command = "findents",
    permission = "sam.ban",
    func = findents,
    args = {SAM.Args.number},
})

local function removemodels(args, sender)
    local model = args[1]
    if IsValid(sender) then
        sender:ChatPrint("<color=green>Removing entities with model: </color> " .. model)
    else
        MsgN("Removing entities with model: " .. class)
    end

    for k, v in pairs(ents.FindByModel(model)) do
        SafeRemoveEntity(v)
    end
end

SAM.RegisterCommand({
    name = "Remove Ents",
    description = "Remove entities with the supplied model",
    command = "removemodels",
    permission = "sam.ban",
    func = removemodels,
    args = {SAM.Args.string},
})

local function removeclass(args, sender)
    local class = args[1]
    if IsValid(sender) then
        sender:ChatPrint("<color=green>Removing entities with class: </color>" .. class)
    else
        MsgN("Removing entities with class: " .. class)
    end

    for k, v in pairs(ents.FindByClass(class)) do
        SafeRemoveEntity(v)
    end
end

SAM.RegisterCommand({
    name = "Remove Class",
    description = "Remove entities with the supplied class",
    command = "removeclass",
    permission = "sam.ban",
    func = removeclass,
    args = {SAM.Args.string},
})