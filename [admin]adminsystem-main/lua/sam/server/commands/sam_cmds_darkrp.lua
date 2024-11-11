--[[
Commands in this file and order:
- SetJob
- GiveMoney
- TakeMoney
- SetMoney
--]]

-------------------- SETJOB --------------------
local function setjob(args, sender)
    local ply,job = args[1],args[2]
    local teamIndex = 0
    for k,v in pairs(team.GetAllTeams()) do
        if (string.lower(v.Name) == string.lower(job)) then
            teamIndex = k
        end
    end
    if (teamIndex == 0) then
        SAM.ShootError(sender, "No job by that name could be found!")
        return
    end
    ply:changeTeam(teamIndex, true, true)

    SAM.CommandEcho("#P has set #P to #S", {sender, ply, job}, "SetJob")
end
SAM.RegisterCommand({name = "SetJob", description = "Sets a players DarkRP job", command = "setjob", permission = "sam.setjob", func = setjob, args = {SAM.Args.ply, SAM.Args.string_restofline}, checkIfCanTarget = true})

-------------------- GIVEMONEY --------------------
local function givemoney(args, sender)
    local ply,amount = args[1],args[2]
    ply:setDarkRPVar("money", ply:getDarkRPVar("money") + amount)

    SAM.CommandEcho("#P has given #P #N DarkRP$", {sender, ply, amount}, "GiveMoney")
end
SAM.RegisterCommand({name = "GiveMoney", description = "Gives a player DarkRP money", command = "givemoney", permission = "sam.givemoney", func = givemoney, args = {SAM.Args.ply, SAM.Args.number}, checkIfCanTarget = true})

-------------------- TAKEMONEY --------------------
local function takemoney(args, sender)
    local ply,amount = args[1],args[2]
    ply:setDarkRPVar("money", ply:getDarkRPVar("money") - amount)

    SAM.CommandEcho("#P has taken #N DarkRP$ from #P", {sender, amount, ply}, "TakeMoney")
end
SAM.RegisterCommand({name = "TakeMoney", description = "Takes a players DarkRP money", command = "takemoney", permission = "sam.takemoney", func = takemoney, args = {SAM.Args.ply, SAM.Args.number}, checkIfCanTarget = true})

-------------------- FORCERPNAME --------------------
local function forcerpname(args, sender)
    local ply, name = args[1],args[2]
    ply:setDarkRPVar("rpname", name)
    ply.cannotChangeRPName = true

    SAM.CommandEcho("#P name has been changed to #N", {ply, name}, "ForceRPName")
end
SAM.RegisterCommand({name = "ForceRPName", description = "Sets a player name which cannot change", command = "forcerpname", permission = "sam.forcerpname", func = forcerpname, args = {SAM.Args.ply, SAM.Args.string}, checkIfCanTarget = true})

hook.Add("canChatCommand", "SAM_ForceRPName", function(ply, cmd)
    if (cmd == "rpname" and ply.cannotChangeRPName) then
        return false
    end
end)

-------------------- SETMONEY --------------------
local function setmoney(args, sender)
    local ply,amount = args[1],args[2]
    ply:setDarkRPVar("money", amount)

    SAM.CommandEcho("#P has set #P 's DarkRP$ to #N", {sender, ply, amount}, "SetMoney")
end
SAM.RegisterCommand({name = "SetMoney", description = "Sets a players DarkRP money", command = "setmoney", permission = "sam.setmoney", func = setmoney, args = {SAM.Args.ply, SAM.Args.number}, checkIfCanTarget = true})
