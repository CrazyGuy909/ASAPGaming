--[[
Commands in this file and order:
- GetSteamID
- SetArmor
- SetHealth
- Noclip
- Respawn
- Cloak
- Uncloak
- God
- Ungod
- Slay
- Strip
- Scale
- Speed
- Give
- GiveAmmo
- Model
- Unmodel
- Help
- Info
--]]
-------------------- GETSTEAMID --------------------
local function getsteamid(args, sender)
    local ply = args[1]
    if (sender:IsValid()) then
        sender:ChatPrint(ply:SteamID())
    else
        print(ply:SteamID())
    end
end
SAM.RegisterCommand({name = "GetSteamID", description = "Gets a SteamID from a name", command = "steamid", permission = "sam.steamid", func = getsteamid, args = {SAM.Args.ply}, checkIfCanTarget = false})

-------------------- SETARMOR --------------------
local function setarmor(args, sender)
    local plys,value = args[1],args[2]
    for k,v in pairs(plys) do
        v:SetArmor(value)
    end

    SAM.CommandEcho("#P has set armor to #N for #MP", {sender, value, plys}, "SetArmor")
end
SAM.RegisterCommand({name = "SetArmor", description = "Sets a players armor", command = "setarmor", permission = "sam.setarmor", func = setarmor, args = {SAM.Args.multi_ply, SAM.Args.number}, checkIfCanTarget = true})

-------------------- SETHEALTH --------------------
local function sethealth(args, sender)
    local plys,value = args[1],args[2]
    for k,v in pairs(plys) do
        v:SetHealth(value)
    end

    SAM.CommandEcho("#P has set health to #N for #MP", {sender, value, plys}, "SetHealth")
end
SAM.RegisterCommand({name = "SetHealth", description = "Sets a players health", command = "sethealth", permission = "sam.sethealth", func = sethealth, args = {SAM.Args.multi_ply, SAM.Args.number}, checkIfCanTarget = true})

-------------------- NOCLIP --------------------
local function noclip(args, sender)
    local ply = args[1]
    if (ply.sam_allowed_to_noclip) then
        ply.sam_allowed_to_noclip = nil
        SAM.CommandEcho("#P has disabled noclip for #P", {sender, ply}, "Noclip")
    else
        ply.sam_allowed_to_noclip = true
        SAM.CommandEcho("#P has enabled noclip for #P", {sender, ply}, "Noclip")
    end
end
SAM.RegisterCommand({name = "Noclip", description = "Noclips a player", command = "noclip", permission = "sam.noclip", func = noclip, args = {SAM.Args.ply}, checkIfCanTarget = true})

-------------------- RESPAWN --------------------
local function respawn(args, sender)
    local plys = args[1]
    for k,v in pairs(plys) do
        v:Spawn()
    end
    SAM.CommandEcho("#P has respawned #MP", {sender, plys}, "Respawn")
end
SAM.RegisterCommand({name = "Respawn", description = "Respawns a player", command = "respawn", permission = "sam.respawn", func = respawn, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

-------------------- CLOAK --------------------
hook.Add("PlayerSwitchWeapon", "SAM.InvisWeapon", function(ply, old, new)
    if (ply.sam_invis == true) then
    	new:SetRenderMode(RENDERMODE_TRANSALPHA)
    	new:Fire("alpha", 0, 0)
    	new:SetMaterial("models/effects/vol_light001")
    else
        new:SetRenderMode(RENDERMODE_NORMAL)
        new:Fire("alpha", 255, 0)
        new:SetMaterial("")
    end
end)

local function cloak(args, sender)
    local plys = args[1]
    for k,v in pairs(plys) do
        v:DrawShadow(false)
    	v:SetMaterial("models/effects/vol_light001")
    	v:SetRenderMode(RENDERMODE_TRANSALPHA)
    	v:Fire("alpha", 0, 0)
    	v.sam_invis = true
    	if (IsValid(v:GetActiveWeapon())) then
    		v:GetActiveWeapon():SetRenderMode(RENDERMODE_TRANSALPHA)
    		v:GetActiveWeapon():Fire("alpha", 0, 0)
    		v:GetActiveWeapon():SetMaterial("models/effects/vol_light001")
    	end
    end

    SAM.CommandEcho("#P has cloaked #MP", {sender, plys}, "Cloak")
end
SAM.RegisterCommand({name = "Cloak", description = "Makes a player invisible", command = "cloak", permission = "sam.cloak", func = cloak, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

-------------------- UNCLOAK --------------------
local function uncloak(args, sender)
    local plys = args[1]
    for k,v in pairs(plys) do
        v:DrawShadow(true)
        v:SetMaterial("")
        v:SetRenderMode(RENDERMODE_NORMAL)
        v:Fire("alpha", 255, 0)
        v.sam_invis = nil
        if (IsValid(v:GetActiveWeapon())) then
            v:GetActiveWeapon():SetRenderMode(RENDERMODE_NORMAL)
            v:GetActiveWeapon():Fire("alpha", 255, 0)
            v:GetActiveWeapon():SetMaterial("")
        end
    end

    SAM.CommandEcho("#P has uncloaked #MP", {sender, plys}, "Uncloak")
end
SAM.RegisterCommand({name = "Uncloak", description = "Makes a player visible again", command = "uncloak", permission = "sam.cloak", func = uncloak, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

-------------------- GOD --------------------
local function god(args, sender)
    local plys = args[1]
    for k,v in pairs(plys) do
        v:GodEnable()
    end

    SAM.CommandEcho("#P has godded #MP", {sender, plys}, "God")
end
SAM.RegisterCommand({name = "God", description = "Gives a player Godmode", command = "god", permission = "sam.god", func = god, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

-------------------- UNGOD --------------------
local function ungod(args, sender)
    local plys = args[1]
    for k,v in pairs(plys) do
        v:GodDisable()
    end

    SAM.CommandEcho("#P has ungodded #MP", {sender, plys}, "Ungod")
end
SAM.RegisterCommand({name = "Ungod", description = "Removes a players Godmode", command = "ungod", permission = "sam.god", func = ungod, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

-------------------- SLAY --------------------
local function slay(args, sender)
    local plys = args[1]
    for k,v in pairs(plys) do
        v:Kill()
    end

    SAM.CommandEcho("#P has slayed #MP", {sender, plys}, "Slay")
end
SAM.RegisterCommand({name = "Slay", description = "Kills a player", command = "slay", permission = "sam.slay", func = slay, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

-------------------- STRIP --------------------
local function strip(args, sender)
    local plys = args[1]
    for k,v in pairs(plys) do
        v:StripWeapons()
    end

    SAM.CommandEcho("#P has stripped #MP", {sender, plys}, "Strip")
end
SAM.RegisterCommand({name = "Strip", description = "Strips a player", command = "strip", permission = "sam.strip", func = strip, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

-------------------- SCALE --------------------
local function scale(args, sender)
    local plys,value = args[1],args[2]
    for k,v in pairs(plys) do
        v:SetModelScale(value, 1)
    end

    SAM.CommandEcho("#P has scaled #MP to #N", {sender, plys, value}, "Scale")
end
SAM.RegisterCommand({name = "Scale", description = "Scales a player", command = "scale", permission = "sam.scale", func = scale, args = {SAM.Args.multi_ply, SAM.Args.number}, checkIfCanTarget = true})

-------------------- SPEED --------------------
local function speed(args, sender)
    local plys,value = args[1],args[2]
    for k,v in pairs(plys) do
        v:SetRunSpeed(value)
    end

    SAM.CommandEcho("#P has set run speed to #N for #MP", {sender, value, plys}, "Speed")
end
SAM.RegisterCommand({name = "Speed", description = "Sets a players speed", command = "speed", permission = "sam.speed", func = speed, args = {SAM.Args.multi_ply, SAM.Args.number}, checkIfCanTarget = true})

-------------------- GIVE --------------------
local function give(args, sender)
    local plys,value = args[1],args[2]
    for k,v in pairs(plys) do
        if (v:Alive()) then
            v:Give(value)
        end
    end

    SAM.CommandEcho("#P has given #S to #MP", {sender, value, plys}, "Give")
end
SAM.RegisterCommand({name = "Give", description = "Gives a player the supplied weapon", command = "give", permission = "sam.give", func = give, args = {SAM.Args.multi_ply, SAM.Args.string_restofline}, checkIfCanTarget = true})


-------------------- GIVEAMMO --------------------
local function giveammo(args, sender)
    local plys,value = args[1],args[2]
    for k,v in pairs(plys) do
        if (v:Alive() and IsValid(v:GetActiveWeapon())) then
            v:GiveAmmo(value, v:GetActiveWeapon():GetPrimaryAmmoType(), true)
        end
    end

    SAM.CommandEcho("#P has given #N ammo to #MP", {sender, value, plys}, "GiveAmmo")
end
SAM.RegisterCommand({name = "GiveAmmo", description = "Gives a player ammo", command = "giveammo", permission = "sam.giveammo", func = giveammo, args = {SAM.Args.multi_ply, SAM.Args.number}, checkIfCanTarget = true})

-------------------- MODEL --------------------
local function model(args, sender)
    local plys,value = args[1],args[2]
    for k,v in pairs(plys) do
        if (v:Alive()) then
            v.factory_model = v:GetModel()
            v:SetModel(value)
        end
    end

    SAM.CommandEcho("#P has set #MP model to #S", {sender, plys, value}, "Model")
end
SAM.RegisterCommand({name = "Model", description = "Sets a player model", command = "model", permission = "sam.model", func = model, args = {SAM.Args.multi_ply, SAM.Args.string_restofline}, checkIfCanTarget = true})

-------------------- RESETMODEL --------------------
local function unmodel(args, sender)
    local plys = args[1]
    for k,v in pairs(plys) do
        if (v:Alive()) then
            if (v.factory_model) then
                v:SetModel(v.factory_model)
                v.factory_model = nil
            end
        end
    end

    SAM.CommandEcho("#P has reset #MP model", {sender, plys}, "Unmodel")
end
SAM.RegisterCommand({name = "Unmodel", description = "Resets a players model", command = "unmodel", permission = "sam.model", func = unmodel, args = {SAM.Args.multi_ply}, checkIfCanTarget = true})

-------------------- HELP --------------------
local function help(args, sender)
    local toPrint = {}
    for k,v in pairs(SAM.Commands) do
        if (SAM.HasPermission(sender, v.permission)) then
            local argstring = "!"..v.command
            for k,v in pairs(v.args) do
                if v == SAM.Args.ply then argstring = argstring .. " <player>" end
                if v == SAM.Args.number then argstring = argstring .. " <number>" end
                if v == SAM.Args.time then argstring = argstring .. " <time>" end
                if v == SAM.Args.string then argstring = argstring .. " <string>" end
                if v == SAM.Args.string_restofline then argstring = argstring .. " <string_restofline>" end
                if v == SAM.Args.multi_ply then argstring = argstring .. " <multi_ply>" end
                if v == SAM.Args.sql_ply then argstring = argstring .. " <steamid_name>" end
            end
            local totalstring = v.name.." | "..v.description.." | "..argstring
            table.insert(toPrint, totalstring)
        end
    end
    if (sender:IsValid()) then
        sender:ChatPrint("View console for help details!")
        sender:PrintMessage(2, "---------- SAM HELP ----------")
        for k,v in pairs(toPrint) do
            sender:PrintMessage(2, v)
        end
        sender:PrintMessage(2, "------------------------------")
    else
        print("---------- SAM HELP ----------")
        for k,v in pairs(toPrint) do
            print(v)
        end
        print("------------------------------")
    end
end
SAM.RegisterCommand({name = "Help", description = "Prints all commands", command = "help", permission = "sam.help", func = help, args = {}, checkIfCanTarget = false})

-------------------- INFO --------------------
local function info(args, sender)
    if (sender:IsValid()) then
        sender:ChatPrint(SAM.Default_Config.infoText)
    else
        print(SAM.Default_Config.infoText)
    end
end
SAM.RegisterCommand({name = "Info", description = "Prints server info", command = "info", permission = "sam.info", func = info, args = {}, checkIfCanTarget = false})
