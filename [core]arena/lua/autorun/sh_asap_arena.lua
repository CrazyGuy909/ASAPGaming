game.AddParticles("particles/gb5_fireball.pcf")
PrecacheParticleSystem("thermo_fireball_explosion")
asapArena = asapArena or {}
AddCSLuaFile("arena/sh_config.lua")
include("arena/sh_config.lua")
previousGamemodeID = nil
AddCSLuaFile("arena/sh_versus.lua")
include("arena/sh_versus.lua")
if SERVER then
    util.AddNetworkString("ASAP.Arena.SetGamemode")
end

function asapArena:AddWeapon(id, data)
    if (self.Weapons == nil) then
        self.Weapons = {}
    end

    self.Weapons[id] = data
end

function asapArena:GetPlayers(b)
    local list = {}
    for k,v in pairs(player.GetAll()) do
        if (IsValid(v) and v:InArena()) then
            if (b and v:GetViewEntity() != v) then continue end
            table.insert(list, v)
        end
    end
    return list
end


function asapArena:Run(x, id, ...)
    self.ActiveGamemode = self.Gamemodes[id or GetGlobalString("ActiveGamemode", "deathmatch")]
    if (not self.ActiveGamemode) then
        include("arena/sh_gamemodes.lua")
        MsgN("[Arena] GAMEMODE NOT ACTIVE?")
        return
    end
    if (not x) then return end
    if (not self.ActiveGamemode[x]) then
        //self.Gamemodes.deathmatch[x](self.Gamemodes.deathmatch, unpack({...}))
        return
    end
    return self.ActiveGamemode[x](self.ActiveGamemode, unpack({...}))
end

concommand.Add("reload_gamemodes", function(ply)
    if IsValid(ply) then return end

    for k,v in pairs(player.GetAll()) do
        v:LeaveArena()
    end

    MsgN("Looking for Gamemodes")
    PrintTable(asapArena.Gamemodes)
    MsgN("Reloading gamemodes again")
    include("arena/sh_gamemodes.lua")
end)

if CLIENT then
    local previousGamemodeID = nil  -- Variable to store the previous gamemodeID
    local notificationSentForGamemode = {} -- Table to track if a notification has been sent for each gamemode

    net.Receive("ASAP.Arena.SetGamemode", function()
        local gamemodeID = net.ReadString()
        asapArena:SetGamemode(gamemodeID)

        -- Check if the gamemodeID has changed or if it's the first time receiving it
        if gamemodeID ~= previousGamemodeID then
            -- Reset notificationSent since gamemodeID has changed
            notificationSentForGamemode[gamemodeID] = false
        end

        -- Update the previousGamemodeID with the current gamemodeID
        previousGamemodeID = gamemodeID

        if (asapArena.Gamemodes[gamemodeID] and asapArena.Gamemodes[gamemodeID].Icon) then
            -- Send a message to the server to handle sending the Discord message if notification hasn't been sent yet
            if not notificationSentForGamemode[gamemodeID] then
                net.Start("SendDiscordMessage")
                net.WriteString(gamemodeID) -- Pass gamemodeID to the server
                net.SendToServer()

                notificationSentForGamemode[gamemodeID] = true -- Set flag to true after sending the notification
            end
        end
    end)
end

if SERVER then
    util.AddNetworkString("SendDiscordMessage") -- Define the network string serverside
end


local ignore = {
    sh_weapons = true,
    sh_config = true,
    sh_versus = true
}

AddCSLuaFile("arena/sh_weapons.lua")
include("arena/sh_weapons.lua")

timer.Simple(3, function()
    if (not asapArena.Weapons) then
        AddCSLuaFile("arena/sh_weapons.lua")
        include("arena/sh_weapons.lua")
    end
end)

MsgC(Color(255, 255, 0), "[[\tInitializing arena\t]]\n")
local files, _ = file.Find("arena/*.lua", "LUA", "nameasc")
table.sort(files, function(a, b)
    return string.sub(a, 4) < string.sub(b, 4)
end)
for k, v in pairs(files) do
    local fileName = string.sub(v, 4, #v - 4)
    if (ignore[fileName]) then continue end
    if (v == "sh_weapons.lua") then continue end
    if (string.StartWith(v,"sh_")) then
        AddCSLuaFile("arena/" .. v)
        include("arena/" .. v)
    elseif (string.StartWith(v,"cl_")) then
        AddCSLuaFile("arena/" .. v)
        if CLIENT then
            include("arena/" .. v)
            MsgN("--[ loading " .. fileName .. " ]")
        end
        continue
    elseif (SERVER and string.StartWith(v,"sv_")) then
        include("arena/" .. v)
    end
    MsgN("--[ loading " .. fileName .. " ]")
end
MsgC(Color(255, 255, 0), "[[\tArena Loaded\t]]\n\n")
