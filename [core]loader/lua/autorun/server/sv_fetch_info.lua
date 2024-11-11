util.AddNetworkString("ASAP.Updater")
util.AddNetworkString("ASAP.ShouldUpdate")
ASAP_ASK = ASAP_ASK or {}
ASAP_ASK.Data = util.JSONToTable(file.Read("restart_collect.txt") or "[]")
if not asapMarket then
    asapMarket = {}
end

asapMarket.API = "http://45.62.160.35:2052"

function LoadPlayerData(ply, data)
    MsgC(Color(255, 255, 0), "[LOADER]", color_white, "Preparing user " .. ply:Nick() .. "-" .. ply:SteamID(), "\n")
	
    if not data then
        ErrorNoHalt("Failed to load player data for player " .. ply:Nick() .. "-" .. ply:SteamID() .. ": Data is nil\n")
        return
	else
		PrintTable(data)
    end
	
    if (data.arena) then
        local body = util.JSONToTable(data.arena.Data or "[]")
        local equip = util.JSONToTable(data.arena.Equipment or "[]")
        ply._arenaXP = body.Experience
        ply._arenaLevel = data.arena.Level
        ply._arenaScore = data.arena.ArenaScore
        ply._arenaData = body
        ply._arenaEquipment = equip
        ply:SetNWString("ArenaTaunt", ply._arenaEquipment.Taunt or "laugh")
    else
        asapArena:CreatePlayer(ply, true)
    end

    if (data.unbox) then
        local inventory = util.JSONToTable(data.unbox.inventoryData)

        if not inventory then
            ply._ub3inv = {}
        else
            ply._ub3inv = inventory
        end

        ply._permaWeapons = util.JSONToTable(ply:GetPData("Unbox.PermaWeapons", "[]"))

        timer.Simple(5, function()
            if not IsValid(ply) then return end

            for k, v in pairs(ply._permaWeapons or {}) do
                if (not ply._ub3inv[k]) then
                    ply._permaWeapons[k] = nil
                else
                    ply:BU3UseItem(k, 1)
                end
            end
        end)

        net.Start("BU3:EquipPerma")
        net.WriteTable(ply._permaWeapons or {})
        net.Send(ply)
        ply.loadedInventory = true
    else
        ply.loadedInventory = true
        ply._ub3inv = {}
        ply._permaWeapons = {}
    end

    if (data.marketplace) then
        ply._marketedItems = {}

        for k, v in pairs(data.marketplace) do
            table.insert(ply._marketedItems, {
                Price = v.price,
                ID = v.item,
                Date = v.date,
                ItemID = v.item_id,
                Status = v.status or 0
            })
        end
    end

    if (data.gangs) then
        local tag = data.gangs.Tag

        if (not asapgangs.gangList[tag]) then
            local gang = {}
            gang.Ranks = util.JSONToTable(data.gangs.Ranks or "{}")
            gang.Members = util.JSONToTable(data.gangs.Members or "{}")
            gang.Shop = util.JSONToTable(data.gangs.Shop or "{}")
            gang.MMR = data.gangs.mmr or 0
            gang.Name = data.gangs.Name or tag
            gang.Inventory = util.JSONToTable(data.gangs.Inventory or "[]")
            gang.Division = data.gangs.division or 0
            gang.Money = data.gangs.Money or 0
            gang.Credits = data.gangs.Credits or 0
            gang.Level = data.gangs.Level or 0
            gang.Experience = data.gangs.Experience or 0
            asapgangs.gangList[tag] = gang

            for a, rankData in pairs(gang.Ranks) do
                for id, member in pairs(rankData.Members) do
                    local ply = player.GetBySteamID64(member)

                    if IsValid(ply) then
                        ply:SetNWString("Gang.Rank", a)
                    end
                end
            end
        end

        ply:SetNWString("Gang", tag)
        ply:InitGangRank()
    end

    local lastSave = ASAP_ASK.Data[ply:SteamID()]

    if (lastSave) then
        ply:SendLua("if IsValid(SPAWN) then SPAWN:Remove() end")
        ply:SetPos(lastSave.Pos)
        ply:SetAngles(lastSave.Ang)
        ply:changeTeam(lastSave.Team, true, true)
        ply:SetHealth(lastSave.Health)
        ply:SetArmor(lastSave.Armor)

        for k, v in pairs(lastSave.Entities) do
            local ent = ents.Create(v.Class)
            ent:SetPos(v.Pos)
            ent:SetAngles(v.Ang)

            if ent.Setowning_ent then
                ent:Setowning_ent(ply)
            end

            ent.SID = ply.SID
            ent:Spawn()
        end

        ASAP_ASK.Data[ply:SteamID()] = nil
        hook.Run("PlayerSetModel", ply)
        file.Write("restart_collect.txt", util.TableToJSON(ASAP_ASK.Data))
    end

    if (data.darkrp) then
        ply:setDarkRPVar("money", data.darkrp.wallet)
        ply:setDarkRPVar("rpname", data.darkrp.rpname or ply:Nick())
        ply.DarkRPUnInitialized = nil
    else
        local info = hook.Run("onPlayerFirstJoined", ply, nil) or {
            rpname = ply:Nick(),
            wallet = 750000,
            salary = 75
        }

        DarkRP.createPlayerData(ply, info.rpname, info.wallet, info.salary)
        ply:setDarkRPVar("money", info.wallet or 500000)
        ply:setDarkRPVar("rpname", info.rpname or ply:Nick())
        ply:setDarkRPVar("wallet", info.salary or 45)
        ply.DarkRPUnInitialized = nil
    end

    ply.gobblegumscooldown = {}
	
    if (data.gobblegums and data.gobblegums[1] and data.gobblegums[1].accountinfo) then
		print("VALID GOBBLEGOBBLE")
        local gobble = util.JSONToTable(data.gobblegums[1].accountinfo or "[]")
        local convertedData = {}
        if (gobble) then
			print("VALIDGOB")
            convertedData.gobblegums = isstring(gobble.owned_gobblegums) and util.JSONToTable(gobble.owned_gobblegums) or gobble.owned_gobblegums or {}
            convertedData.gobblegumabilties = isstring(gobble.owned_abilities) and util.JSONToTable(gobble.owned_abilities) or gobble.owned_abilities or {}
            convertedData.gobblegumspentonslots = gobble.spent_on_slots or 0
            convertedData.asap_level = gobble.asap_level or 1
            convertedData.asap_xp = gobble.asap_xp or 0
            convertedData.asap_xpToNextLevel = gobble.asap_xpToNextLevel or 100
            convertedData.gobblegumcredits = gobble.gobblegumcredits or 1500
            ply:SetNW2Int("Prestiges", gobble.prestiges or ply:GetPData("Prestiges", 0))

            ply.gobblegums = convertedData.gobblegums or {}
            --Thi is the number of credits the user had
            ply.gobblegumcredits = tonumber(convertedData.gobblegumcredits or 1500)
            --This is a table that stores the ability id, as well as true if its unlocked
            ply.gobblegumabilties = convertedData.gobblegumabilties or {}
            ply.gobblegumspentonslots = tonumber(convertedData.gobblegumspentonslots or 0)
            ply.asap_level = tonumber(convertedData.asap_level) or 1
            ply.asap_xp = tonumber(convertedData.asap_xp) or 0
            ply.asap_xpToNextLevel = tonumber(convertedData.asap_xpToNextLevel) or 100

            --Now loop through each ability they own and load it
            for k, v in pairs(ply.gobblegumabilties) do
                ASAP_GOBBLEGUMS.Abilities[k].OnSpawn(ply)
            end
        else
            ply.gEmpty = false
            ply.gobblegums = {}
            --Thi is the number of credits the user had
            ply.gobblegumcredits = 1500
            ply.gobblegumabilties = {}
            ply.gobblegumspentonslots = 0
            ply.asap_level = 1
            ply.asap_xp = 0
            ply.asap_xpToNextLevel = 100
        end
    else
        ply.gEmpty = false
        ply.gobblegums = {}
        --Thi is the number of credits the user had
        ply.gobblegumcredits = 1500
        ply.gobblegumabilties = {}
        ply.gobblegumspentonslots = 0
        ply.asap_level = 1
        ply.asap_xp = 0
        ply.asap_xpToNextLevel = 100
    end

    ply:NetworkOwnedGobblegums()
    ply:NetworkGobblegumAbilities()
    ply:NetworkGobblegumSlots()
    ply:SetNW2Int("GB.Level", ply.asap_level)
    --Now network the new XP and the new Level if they changed
    net.Start("ASAPGGOBBLEGUMS:NetworkXPLevel")
    net.WriteUInt(ply.asap_xp or 0, 32)
    net.WriteUInt(ply.asap_level or 1, 32)
    net.WriteUInt(ply.asap_xpToNextLevel or 100, 32)
    net.Send(ply)
    --Network credits
    net.Start("ASAPGGOBBLEGUMS:Credits")
    net.WriteUInt(ply.gobblegumcredits or 1500, 32)
    net.Send(ply)

    ply.CanSave = true
    hook.Run("OnPlayerLoad", ply)
end

hook.Add("PlayerSay", "ASAP.DiscordBot", function(ply, text)
    if (text == "!trivia") then
        asapRedis.Client:Send({"HGETALL", "d:rewards_" .. ply:SteamID64()}, function(s, data)
            if (data) then
                local found = false
                for i = 0, table.Count(data) - 1, 2 do
                    local k, v = data[i], tonumber(data[i + 1])
                    if (k == "trivia" and tonumber(v) > 0) then
                        ply:UB3AddItem(1220, tonumber(v))
                        DarkRP.notify(ply, 1, 5, "You got " .. tonumber(v) .. " wookie's crates")
                        asapRedis.Client:Send({"HSET", "d:rewards_" .. ply:SteamID64(), "trivia", 0})
                        asapRedis.Client:Commit()
                    end
                end
            end
        end)
        asapRedis.Client:Commit()
    elseif (string.StartWith(text, "!verify") and (ply.discordTest or 0) < CurTime()) then
        local exp = string.Explode(" ", text, false)
        local user = table.concat(exp, " ", 2)
        if (string.find(user, "#", 1, false)) then
            asapRedis.Client:Send({"HSET", "verifyList", user, ply:SteamID64()})
            asapRedis.Client:Commit()
            DarkRP.notify(ply, 1, 5, "Return to discord and let the bot know you are verified")
            ply.discordTest = CurTime() + 60
            return ""
        else
            DarkRP.notify(ply, 1, 5, "Your discord account name is wrong, try something like Gonzo#6302 (Please don't)")
        end
    elseif ((ply.discordTest or 0) > CurTime()) then
        DarkRP.notify(ply, 1, 5, "You need to wait " .. math.Round(ply.discordTest - CurTime(), 1) .. " seconds to run !verify again")
    end
end)
util.AddNetworkString("ASAP.Load:Request")

net.Receive("ASAP.Load:Request", function(l, ply)
    if (ply.last_request and ply.last_request > CurTime()) then end --DarkRP.notify(ply, 1, 5, "You must wait " .. (ply.last_request - CurTime()) .. " seconds to run this command again") --return
    ply:restorePlayerData()
    ply.last_request = CurTime() + 60

    http.Fetch(asapMarket.API .. "/user?id=" .. ply:SteamID64(), function(body)
        local data = util.JSONToTable(body)
        LoadPlayerData(ply, data)
    end)
end)

concommand.Add("asap_requestload", function(ply, cmd, args)
    if (ply.last_request and ply.last_request > CurTime()) then
        DarkRP.notify(ply, 1, 5, "You must wait " .. (ply.last_request - CurTime()) .. " seconds to run this command again")

        return
    end

    ply.last_request = CurTime() + 60

    http.Fetch(asapMarket.API .. "/user?id=" .. ply:SteamID64(), function(body)
        local data = util.JSONToTable(body)
        LoadPlayerData(ply, data)
    end)

    net.Start("ASAP.Load:Request")
    net.SendToServer()
end)

function test_load(ply)
    http.Fetch(asapMarket.API .. "/user?id=" .. ply:SteamID64(), function(body)
        local data = util.JSONToTable(body)
        PrintTable(data)
        LoadPlayerData(ply, data)
    end)
end

local persistFileList = {}

function asapLoadStart(ply)
    http.Fetch(asapMarket.API .. "/user?id=" .. ply:SteamID64(), function(body)
        local data = util.JSONToTable(body)
        LoadPlayerData(ply, data)
    end)
end
hook.Add("PlayerInitialSpawn", "ASAP.InfoLoader", function(ply)
    timer.Simple(0, function()
        asapLoadStart(ply)
        for k, _ in pairs(persistFileList) do
            RunConsoleCommand("lua_updateclient", k, ply:SteamID64())
        end
    
        if (ASAP_ASK.Reason) then
            net.Start("ASAP.ShouldUpdate")
            net.WriteString(ASAP_ASK.Reason)
            net.Send(ply)
        end
    end)
end)

local function RequestEntities(ply)
    local data = {}

    for k, v in pairs(ents.GetAll()) do
        if (v.SID and v.SID == ply:SteamID64()) then
            table.insert(data, {
                Pos = v:GetPos(),
                Ang = v:GetAngles(),
                Class = v:GetClass()
            })
        end
    end

    return data
end

local function CreateAskUpdate(reason, b)
    ASAP_ASK.Reason = reason
    ASAP_ASK.Voters = {}

    ASAP_ASK.Votes = {b and 1 or 0, 0}

    local voteTime = b and 5 or 120
    file.Delete("restart_collect.txt")
    timer.Remove("ASK_UPDATE")
    timer.Remove("RESTART_TIMER")
    SetGlobalInt("UpdateSchelude", CurTime() + voteTime)
    SetGlobalInt("UpdateVote_Yes", 0)
    SetGlobalInt("UpdateVote_No", 0)

    timer.Create("ASK_UPDATE", voteTime, 1, function()
        if (not ASAP_ASK.Reason) then return end
        local shouldRestart = ASAP_ASK.Votes[1] > ASAP_ASK.Votes[2]

        if (shouldRestart) then
            ASAP_ASK.Data = {}

            for k, v in pairs(player.GetAll()) do
                ASAP_ASK.Data[v:SteamID()] = {
                    Pos = v:GetPos(),
                    Ang = v:GetAngles(),
                    Team = v:Team(),
                    Health = v:Health(),
                    Armor = v:Armor(),
                    Entities = RequestEntities(v)
                }
            end

            file.Write("restart_collect.txt", util.TableToJSON(ASAP_ASK.Data))
            BroadcastLua("if IsValid(VOTER) then VOTER:Remove() end")
            local minutes = 2
            DarkRP.notifyAll(3, 10, "Your stuff has been saved, server will restart in " .. minutes .. " minutes!")

            timer.Create("RESTART_TIMER", 60, minutes, function()
                minutes = minutes - 1
                DarkRP.notifyAll(3, 10, "Server will restart in " .. minutes .. " minutes!")

                if (minutes <= 0) then
                    timer.Remove("RESTART_TIMER")

                    timer.Simple(10, function()
                        RunConsoleCommand("changelevel", game.GetMap())
                    end)
                end
            end)
        else
            ASAP_ASK.Reason = nil
            DarkRP.notifyAll(3, 10, "The server restart has been declined, votation: " .. ASAP_ASK.Votes[1] .. " - " .. ASAP_ASK.Votes[2])
            ASAP_ASK.Votes = nil
        end
    end)

    if not b then
        net.Start("ASAP.ShouldUpdate")
        net.WriteString(reason)
        net.Broadcast()
    end
end

net.Receive("ASAP.ShouldUpdate", function(l, ply)
    if (not ASAP_ASK.Reason or ASAP_ASK.Voters[ply]) then return end
    local yes = net.ReadBool()
    ASAP_ASK.Voters[ply] = true
    ASAP_ASK.Votes[yes and 1 or 2] = (ASAP_ASK.Votes[yes and 1 or 2] or 0) + 1
    SetGlobalInt("UpdateVote_" .. (yes and "Yes" or "No"), ASAP_ASK.Votes[yes and 1 or 2])
end)

concommand.Add("lua_cancelupdate", function(ply, cmd, args)
    if (IsValid(ply)) then return end
    BroadcastLua("if IsValid(VOTER) then VOTER:Remove() end")
    file.Delete("restart_collect.txt")
    timer.Remove("ASK_UPDATE")
    timer.Remove("RESTART_TIMER")
    ASAP_ASK.Reason = nil
    DarkRP.notifyAll(3, 10, "The server restart has been declined, votation: " .. ASAP_ASK.Votes[1] .. " - " .. ASAP_ASK.Votes[2])
end)

concommand.Add("lua_forceupdate", function(ply)
    if (IsValid(ply)) then return end
    CreateAskUpdate("HELLO", true)
end)

concommand.Add("lua_askupdate", function(ply, cmd, args)
    if (IsValid(ply)) then return end
    local reason = table.concat(args, " ")
    CreateAskUpdate(reason)
end)

concommand.Add("lua_persistclient", function(ply, cmd, args)
    if IsValid(ply) then return end
    local path = args[1]
    local shouldSkip = args[2] ~= nil

    if (persistFileList[path]) then
        persistFileList[path] = nil
        MsgN("File: " .. path .. " has been removed from download cache")
    else
        persistFileList[path] = true
        MsgN("File: " .. path .. " has been added for download")

        if (not shouldSkip) then
            MsgN("Updating file: " .. path)
            RunConsoleCommand("lua_updateclient", path)
        end
    end
end)

concommand.Add("lua_updateclient", function(ply, cmd, args)
    if IsValid(ply) then return end
    local path = args[1]
    local kind = args[2] or "0"

    if (file.Exists(path, "LUA")) then
        local data = util.Compress(file.Read(path, "LUA"))
        net.Start("ASAP.Updater")
        net.WriteUInt(tonumber(kind), 4)
        net.WriteData(data, #data)

        if (kind == "0") then
            net.Broadcast()
        elseif (IsValid(player.GetBySteamID64(kind))) then
            net.Send(player.GetBySteamID64(kind))
        end
    else
        MsgN("File ", path, " doesn't exists!")
    end
end)