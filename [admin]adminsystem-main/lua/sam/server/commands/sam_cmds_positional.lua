--[[
Commands in this file and order:
- Goto
- Send
- Bring
- BringPos
- Return
--]]
-------------------- GOTO --------------------
local function gotof(args, sender)
    local ply = args[1]
    if not (sender:IsValid()) then
        SAM.ShootError(sender, "You cannot goto players as console!")
        return
    end
    sender.sam_prevpos = sender:GetPos()
    sender:SetPos(ply:GetPos()+Vector(100,0,0))

    SAM.CommandEcho("#P teleported to #P", {sender, ply}, "Goto")
end
SAM.RegisterCommand({name = "Goto", description = "Sends you to another player", command = "goto", permission = "sam.goto", func = gotof, args = {SAM.Args.ply}, checkIfCanTarget = true})

local function send(args, sender)
    local plys,dest = args[1],args[2]
    local posgrid = SAM.CalculatePosGrid(dest:GetPos(), #plys)
    for k,v in pairs(plys) do
        v.sam_prevpos = v:GetPos()
        v:SetPos(dest:GetPos()+posgrid[k])
    end

    SAM.CommandEcho("#P sent #MP to #P", {sender, plys, dest}, "Send")
end
SAM.RegisterCommand({name = "Send", description = "Sends a player to another", command = "send", permission = "sam.send", func = send, args = {SAM.Args.multi_ply, SAM.Args.ply}, checkIfCanTarget = true})

local function bring(args, sender)
    local plys = args[1]
    if not (sender:IsValid()) then
        SAM.ShootError(sender, "You cannot bring players as console!")
        return
    end
    local posgrid = SAM.CalculatePosGrid()
    for k,v in pairs(plys) do
        v.sam_prevpos = v:GetPos()
        v:SetPos(sender:GetPos()+posgrid[k])
    end

    SAM.CommandEcho("#P brought #MP", {sender, plys}, "Bring")
end
SAM.RegisterCommand({name = "Bring", description = "Brings a player to you", command = "bring", permission = "sam.bring", func = bring, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

local function bringp(args, sender)
    local plys = args[1]
    if not (sender:IsValid()) then
        SAM.ShootError(sender, "You cannot bring players as console!")
        return
    end
    for k,v in pairs(plys) do
        v.sam_prevpos = v:GetPos()
        v:SetPos(sender:GetEyeTrace().HitPos)
    end

    SAM.CommandEcho("#P brought #MP", {sender, plys}, "BringPos")
end
SAM.RegisterCommand({name = "BringPos", description = "Brings a player to where you are looking", command = "bringp", permission = "sam.bring", func = bringp, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

local function returnply(args, sender)
    local plys = args[1]
    local co = 0
    for k,ply in pairs(plys) do
        if (ply.sam_prevpos) then
            ply:SetPos(ply.sam_prevpos)
            ply.sam_prevpos = nil
            co = co + 1
        else
            SAM.ShootError(sender, ply:Name().." has no return point, skipping")
        end
    end
    if (co > 0) then
        SAM.CommandEcho("#P returned #MP", {sender, plys}, "Return")
    else
        SAM.ShootError(sender, "No one given had a return point!")
    end
end
SAM.RegisterCommand({name = "Return", description = "Returns a player to their previous position", command = "return", permission = "sam.return", func = returnply, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})
