util.AddNetworkString("SAM.ShootError")
util.AddNetworkString("SAM.CommandEcho")

-- SQL Shit
if SAM.SQLInitialized == nil or SAM.SQLInitialized == false then
    if SAM.SQLConfig.usesql == true then
        SAM.SQLPlayerTableName = "sam_players_" .. string.lower(SAM.SQLConfig.serveridentifier)
        SAM.SQLBanTableName = "sam_banned_" .. string.lower(SAM.SQLConfig.serveridentifier)
        require("mysqloo")
        local db = mysqloo.connect(SAM.SQLConfig.host, SAM.SQLConfig.user, SAM.SQLConfig.pass, SAM.SQLConfig.name, SAM.SQLConfig.port)

        function db:onConnected()
            print("SAM (SQL) >> Connected to database!")
        end

        function db:onConnectionFailed(err)
            print("SAM (SQL) >> Connection to database failed!")
            print("SAM (SQL Error) >> ", err)
        end

        db:connect()

        function SAM.Query(sql, callback)
            local q = db:query(sql)

            function q:onSuccess(data)
                if callback then
                    callback(data)
                end
            end

            function q:onError(err)
                print("SAM (SQL Error) >> Query Errored, error:", err, " || sql: ", sql)
            end

            q:start()
        end

        SAM.Query("CREATE TABLE IF NOT EXISTS " .. SAM.SQLPlayerTableName .. " (steamid VARCHAR(255), knownby VARCHAR(255), usergroup VARCHAR(255), expire INT)", function()
            print("SAM (SQL) >> Loaded " .. SAM.SQLPlayerTableName .. " table!")
        end)

        SAM.Query("CREATE TABLE IF NOT EXISTS " .. SAM.SQLBanTableName .. " (steamid VARCHAR(255), bandate INT, unbandate INT, bannedby VARCHAR(255), reason VARCHAR(255))", function()
            print("SAM (SQL) >> Loaded " .. SAM.SQLBanTableName .. " table!")
        end)
    else
        SAM.SQLPlayerTableName = "sam_players"
        SAM.SQLBanTableName = "sam_banned"

        function SAM.Query(sqle, callfback)
            local data = sql.Query(sqle) or {}

            if callfback then
                if data then
                    callfback(data)
                end
            end
        end

        SAM.Query("CREATE TABLE IF NOT EXISTS sam_players (steamid VARCHAR(255), knownby VARCHAR(255), usergroup VARCHAR(255), expire INT)", function()
            print("SAM (SQL) >> Loaded sam_players table!")
        end)

        SAM.Query("CREATE TABLE IF NOT EXISTS sam_banned (steamid VARCHAR(255), bandate INT, unbandate INT, bannedby VARCHAR(255), reason VARCHAR(255))", function()
            print("SAM (SQL) >> Loaded sam_banned table!")
        end)
    end

    SAM.SQLInitialized = true
end

-- Time value interpreter // Returns seconds
local timeOperators = {
    y = 31622400,
    mo = 2635200,
    w = 604800,
    d = 86400,
    h = 3600,
    m = 60,
    s = 1,
}

function SAM.TimeInterpreter(time)
    if time == "-1" or time == -1 then return -1 end
    local seconds = 0

    for num, type in string.gmatch(time, "(%d+)([ymwdhs][o]?)") do
        seconds = seconds + tonumber(num) * (timeOperators[type] or 0)
    end

    return seconds
end

-- Format seconds into YMWDHS
function SAM.TimeFormatter(seconds)
    if tostring(seconds) == "-1" then return "permanent" end
    strLen = ""
    local years = math.floor(seconds / timeOperators.y)
    seconds = seconds - (years * timeOperators.y)
    local months = math.floor(seconds / timeOperators.mo)
    seconds = seconds - (months * timeOperators.mo)
    local days = math.floor(seconds / timeOperators.d)
    seconds = seconds - (days * timeOperators.d)
    local hours = math.floor(seconds / timeOperators.h)
    seconds = seconds - (hours * timeOperators.h)
    local mins = math.floor(seconds / timeOperators.m)
    seconds = seconds - (mins * timeOperators.m)

    if years >= 1 then
        strLen = strLen .. years .. "y"
    end

    if months >= 1 then
        strLen = strLen .. months .. "mo"
    end

    if days >= 1 then
        strLen = strLen .. days .. "d"
    end

    if hours >= 1 then
        strLen = strLen .. hours .. "h"
    end

    if mins >= 1 then
        strLen = strLen .. mins .. "m"
    end

    if seconds >= 1 then
        strLen = strLen .. seconds .. "s"
    end

    return strLen
end

-- Error Handler
function SAM.ShootError(ply, err)
    if not ply:IsValid() then
        print("SAM.Error: " .. err)
    else
        net.Start("SAM.ShootError")
        net.WriteString(err)
        net.Send(ply)
    end
end

-- Command Echo Handler
function SAM.CommandEcho(echo, args, commandIdentifier)
    local args = args or {}

    for k, v in pairs(args) do
        if istable(v) then
            if #v > 10 then
                args[k] = #v .. " people"
                echo = string.gsub(echo, "#MP", "#S")
            end
        end
    end

    if SAM.Default_Config.echoCommands == true then
        -- Print to players
        local dontShow = false

        if commandIdentifier and SAM.Default_Config.hideCommandEchoes then
            if table.HasValue(SAM.Default_Config.hideCommandEchoes, commandIdentifier) then
                dontShow = true
            end
        end

        if dontShow ~= true then
            if SAM.Default_Config.echoToAdminsOnly == true then
                local sendTo = {}

                for k, v in pairs(player.GetAll()) do
                    if v:IsSuperAdmin() then
                        table.insert(sendTo, v)
                    end
                end

                net.Start("SAM.CommandEcho")
                net.WriteString(echo)
                net.WriteTable(args)
                net.Send(sendTo)
            else
                net.Start("SAM.CommandEcho")
                net.WriteString(echo)
                net.WriteTable(args)
                net.Broadcast()
            end
        end
    end

    -- Print to CONSOLE
    if not args[1] then
        MsgC(SAM.Default_Config.prefixcolor, SAM.Default_Config.prefix, echo)
        print("")
    else
        local outputTable = {SAM.Default_Config.prefixcolor, SAM.Default_Config.prefix}

        local arc = 1

        for k, v in pairs(string.Split(echo, " ")) do
            if v == "#P" then
                if args[arc]:IsValid() then
                    table.insert(outputTable, Color(255, 218, 94))
                    table.insert(outputTable, args[arc]:Name() .. "(" .. args[arc]:SteamID() .. ") ")
                    arc = arc + 1
                else
                    table.insert(outputTable, Color(255, 218, 94))
                    table.insert(outputTable, "CONSOLE ")
                    arc = arc + 1
                end
            elseif v == "#N" then
                table.insert(outputTable, SAM.Default_Config.echoNumberColor)
                table.insert(outputTable, args[arc] .. " ")
                arc = arc + 1
            elseif v == "#S" then
                table.insert(outputTable, SAM.Default_Config.echoStringColor)
                table.insert(outputTable, args[arc] .. " ")
                arc = arc + 1
            elseif v == "#T" then
                table.insert(outputTable, SAM.Default_Config.echoTimeColor)
                table.insert(outputTable, args[arc] .. " ")
                arc = arc + 1
            elseif v == "#MP" then
                for k, v in pairs(args[arc]) do
                    if k == 1 then
                        table.insert(outputTable, Color(255, 218, 94))
                        table.insert(outputTable, v:Name() .. "(" .. v:SteamID() .. ")")
                    else
                        table.insert(outputTable, Color(255, 255, 255))
                        table.insert(outputTable, ",")
                        table.insert(outputTable, Color(255, 218, 94))
                        table.insert(outputTable, v:Name() .. "(" .. v:SteamID() .. ")")
                    end
                end

                table.insert(outputTable, Color(255, 255, 255))
                table.insert(outputTable, " ")
                arc = arc + 1
            else
                table.insert(outputTable, SAM.Default_Config.echoDefaultColor)
                table.insert(outputTable, v .. " ")
            end
        end

        MsgC(unpack(outputTable))
        print("")
    end
end

-- Player searcher
function SAM.FindPlayer(name, typef)
    if typef == "all" then
        local toFind = string.Split(name, ",")
        local found = {}

        for l, w in pairs(toFind) do
            for k, v in pairs(player.GetAll()) do
                if (string.find(string.lower(v:Name()), string.lower(w), 1, true) ~= nil) or (string.lower(w) == string.lower(v:SteamID())) then
                    table.insert(found, v)
                    break
                end
            end
        end

        return found
    elseif typef == "single" then
        for k, v in pairs(player.GetAll()) do
            if (string.find(string.lower(v:Name()), string.lower(name), 1, true) ~= nil) or (string.lower(name) == string.lower(v:SteamID())) then return v end
        end
    end
end

-- Permission system
function SAM.HasPermission(ply, permission)
    if not ply:IsValid() then return true end

    for k, v in pairs(SAM.Default_Config.ranks) do
        if v.name == ply:GetUserGroup() then
            if table.HasValue(v.permissions, permission) or table.HasValue(v.permissions, "*") then return true end
        end
    end

    return false
end

-- Can Target system
function SAM.CanTarget(ply, target)
    if not ply:IsValid() then return true end
    local plyweight = 0
    local targetweight = 0

    for k, v in pairs(SAM.Default_Config.ranks) do
        if v.name == ply:GetUserGroup() then
            plyweight = v.weight
        end

        if v.name == target:GetUserGroup() then
            targetweight = v.weight
        end
    end

    if plyweight > targetweight then return true end

    if plyweight == targetweight then
        if SAM.Default_Config.sameweighttargeting == true then return true end
    end

    return false
end

-- Get Rank Table
function SAM.GetRankTable(rankname)
    local rankTable = nil

    for k, v in pairs(SAM.Default_Config.ranks) do
        if string.lower(v.name) == string.lower(rankname) then
            rankTable = v
        end
    end

    return rankTable
end

-- IsAdmin and IsSuperAdmin
local pmeta = FindMetaTable("Player")

function pmeta:IsAdmin()
    for k, v in pairs(SAM.Default_Config.ranks) do
        if v.name == self:GetUserGroup() then
            if v.adminlevel == 1 or v.adminlevel == 2 then return true end
        end
    end

    return false
end

function pmeta:IsSuperAdmin()
    for k, v in pairs(SAM.Default_Config.ranks) do
        if v.name == self:GetUserGroup() then
            if v.adminlevel == 2 then return true end
        end
    end

    return false
end

-- Player Initialize
hook.Add("PlayerInitialSpawn", "SAM.PlayerInit", function(ply)
    SAM.Query("SELECT * FROM " .. SAM.SQLPlayerTableName .. " WHERE steamid = '" .. ply:SteamID() .. "'", function(data)
        if not data[1] then
            local name = ply:Name()
            name = string.gsub(name, "\"", "")
            name = string.gsub(name, "\'", "")
            name = string.gsub(name, ";", "")
            SAM.Query("INSERT INTO " .. SAM.SQLPlayerTableName .. " VALUES ('" .. ply:SteamID() .. "','" .. name .. "','" .. SAM.Default_Config.defaultrank .. "',-1)")
            ply:SetUserGroup(SAM.Default_Config.defaultrank)
        else
            if data[1].expire then
                if os.time() >= tonumber(data[1].expire) and tonumber(data[1].expire) ~= -1 then
                    SAM.Query("UPDATE " .. SAM.SQLPlayerTableName .. " SET usergroup='" .. SAM.Default_Config.defaultrank .. "',expire=-1 WHERE steamid='" .. ply:SteamID() .. "'")
                    ply:SetUserGroup(SAM.Default_Config.defaultrank)
                else
                    ply:SetUserGroup(data[1].usergroup)
                end
            end
        end
    end)
end)

-- Player Unloading
hook.Add("PlayerDisconnected", "SAM.PlayerDeInit", function(ply)
    local name = ply:Name()
    local sid = ply:SteamID()
    name = string.gsub(name, "\"", "")
    name = string.gsub(name, "\'", "")
    name = string.gsub(name, ";", "")

    SAM.Query("SELECT * FROM " .. SAM.SQLPlayerTableName .. " WHERE steamid = '" .. sid .. "'", function(data)
        if data[1] then
            SAM.Query("UPDATE " .. SAM.SQLPlayerTableName .. " SET knownby = '" .. name .. "' WHERE steamid='" .. sid .. "'")
        end
    end)
end)

-- Noclip Management
hook.Add("PlayerNoClip", "SAM.ManageNoclip", function(ply, desiredState)
    if desiredState == true then
        if ply.sam_allowed_to_noclip then return true end

        if SAM.HasPermission(ply, "sam.noclip") then
            if table.HasValue(SAM.Default_Config.adminmodecommands, "BindNoclip") then
                if ply.sam_adminmode then return true end
            else
                return true
            end
        end
    else
        return true
    end

    return false
end)

-- Give Utilities
hook.Add("PlayerSpawn", "SAM.UtilManagement", function(ply)
    if SAM.GetRankTable(ply:GetUserGroup()).adminlevel > SAM.Default_Config.adminleveltospawnwithutility then
        if table.HasValue(SAM.Default_Config.adminmodecommands, "SpawnUtil") then
            if not ply.sam_adminmode then return end
        end

        ply:Give("weapon_physgun")
        ply:Give("gmod_tool")
    end

    ply.factory_model = nil
end)

hook.Add("PhysgunPickup", "SAM.PlayerPickup", function(ply, ent)
    if ent:GetClass():lower() == "player" and SAM.HasPermission(ply, "sam.plypickup") and SAM.CanTarget(ply, ent) then
        if table.HasValue(SAM.Default_Config.adminmodecommands, "PlyPickup") and not ply.sam_adminmode then return end
        ent.sam_ispickedup = true
        ent:Freeze(false)
        ent:GodEnable()

        return true
    end
end)

hook.Add("PhysgunDrop", "SAM.PlayerDrop", function(ply, ent)
    if ent:GetClass():lower() == "player" then
        ent.sam_ispickedup = nil
        ent:GodDisable()

        if ply:KeyDown(IN_ATTACK2) then
            ent:Freeze(true)
        end
    end
end)

-- Position Grids
-- Thanks to random guy from GMOD Dev Hub
function SAM.CalculatePosGrid()
    local calcdGrid = {}
    local vectorGrid = {}
    local column, row

    for i = 1, 6 do
        row = i

        for column = 1 - i, i do
            table.insert(calcdGrid, {column, row})
        end

        column = i

        for row = i - 1, -i, -1 do
            table.insert(calcdGrid, {column, row})
        end

        row = -i

        for column = i - 1, -i, -1 do
            table.insert(calcdGrid, {column, row})
        end

        column = -i

        for row = 1 - i, i do
            table.insert(calcdGrid, {column, row})
        end
    end

    for k, v in pairs(calcdGrid) do
        table.insert(vectorGrid, Vector(v[1] * 50, v[2] * 50, 0))
    end

    return vectorGrid
end

-- Staff Chat
util.AddNetworkString("SAM.SendStaffMessage")

hook.Add("PlayerSay", "SAM.ParseStaffChat", function(ply, text, tChat)
    if tChat then return end
    if string.sub(text, 1, 1) == "@" then
        if not SAM.HasPermission(ply, "sam.seestaffchat") then
            SAM.ShootError(ply, "You cannot send/receive staff messages!")

            return ""
        end

        local message = string.gsub(text, "@", "", 1)

        for i = 1, 12 do
            message = string.gsub(message, "  ", " ")
        end

        if string.sub(message, 1, 1) == " " then
            message = string.gsub(message, " ", "", 1)
        end

        if message == "" or message == " " then
            SAM.ShootError(ply, "You must supply a message to send to staff chat!")

            return ""
        end

        local canSeeSC = {}

        for k, v in pairs(player.GetAll()) do
            if SAM.HasPermission(v, "sam.seestaffchat") then
                table.insert(canSeeSC, v)
            end
        end

        if canSeeSC[1] then
            net.Start("SAM.SendStaffMessage")
            net.WriteEntity(ply)
            net.WriteString(message)
            net.Send(canSeeSC)
        end

        return ""
    end
end)

local valid = {
    senioradmin = true,
    superadmin = true,
    admin = true,
    owner = true
}