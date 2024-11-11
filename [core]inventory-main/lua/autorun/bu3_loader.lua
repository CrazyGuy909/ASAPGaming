--The global table that stores everything
BU3 = {}

if SERVER then
    AddCSLuaFile("bu3_config.lua")
    util.AddNetworkString("BU3.RequestUpdate")
end

include("bu3_config.lua")
--Load all of the files
local files, folders = file.Find("bu3/*.lua", "LUA")

for _, v in pairs(files) do
    if string.sub(v, 1, 3) == "cl_" then
        if CLIENT then
            include("bu3/" .. v)
        else
            AddCSLuaFile("bu3/" .. v)
        end
    elseif string.sub(v, 1, 3) == "sh_" then
        if CLIENT then
            include("bu3/" .. v)
            print("Loaded " .. v)
        else
            AddCSLuaFile("bu3/" .. v)
            include("bu3/" .. v)
        end
    elseif string.sub(v, 1, 3) == "sv_" then
        include("bu3/" .. v)
    end
end

--Add CSLua file to all the pages
local files, folders = file.Find("bu3/pages/*.lua", "LUA")

for _, v in pairs(files) do
    if SERVER then
        AddCSLuaFile("bu3/pages/" .. v)
    end
end

MsgC(Color(100, 200, 255), "FINISHED LOADING BLUES UNBOXING 3\n")

if SERVER then
    util.AddNetworkString("BU3:OpenGUI")
    net.Receive("BU3.RequestUpdate", function(l, ply)
    end)
end