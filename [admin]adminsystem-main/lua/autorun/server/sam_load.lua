SAM = SAM or {}

-- Include
include("sam/server/configs/sam_sql_config.lua")
include("sam/server/configs/sam_default_config.lua")
include("sam/server/sam_command_handler.lua")
include("sam/server/sam_utility.lua")
include("sam/server/sam_limitations.lua")
include("sam/server/sam_ban_utility.lua")
print(" ")
print("----------------------------------")
print("|    SAM Command Registration    |")
print("----------------------------------")
include("sam/server/commands/sam_cmds_positional.lua")
include("sam/server/commands/sam_cmds_misc.lua")
include("sam/server/commands/sam_cmds_utility.lua")
print("----------------------------------")
print(" ")

hook.Add("Initialize", "SAM.IsDarkRP", function()
    if (DarkRP) then
        print(" ")
        print("----------------------------------")
        print("|  SAM DarkRP Specific Commands  |")
        print("----------------------------------")
        include("sam/server/commands/sam_cmds_darkrp.lua")
        print("----------------------------------")
        print(" ")
    end
end)

-- AddCS
AddCSLuaFile("sam/server/configs/sam_default_config.lua")
AddCSLuaFile("sam/client/sam_general_client.lua")

-- Module Loader
local found_modules = file.Find("sam/modules/*.lua", "LUA")
if (found_modules[1]) then
    print(" ")
    print("----------------------------------")
    print("|   SAM Modules Implementation   |")
    print("----------------------------------")
    for k,v in pairs(found_modules) do
        if (string.sub(v, 1, 3) == "sh_") then
            AddCSLuaFile("sam/modules/"..v)
            include("sam/modules/"..v)
            print("Implementing: "..v)
        end
        if (string.sub(v, 1, 3) == "sv_") then
            include("sam/modules/"..v)
            print("Implementing: "..v)
        end
        if (string.sub(v, 1, 3) == "cl_") then
            AddCSLuaFile("sam/modules/"..v)
            print("Implementing: "..v)
        end
    end
    print("----------------------------------")
    print(" ")
end
