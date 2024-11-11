require("mysqloo")
asapgangs.gangList = (asapgangs.gangList or {}) -- So we don't get stupid ass errors
asapgangs.Inventories = (asapgangs.Inventories or {})
local isLan = GetConVar("sv_lan")

function asapgangs.query(qry, callback)
    ASAPDriver:MySQLQuery(qry, callback)
    return q
end

function asapgangs.AddMember(ply, tag)
    local steamid = isstring(ply) and ply or ply:SteamID64()

    if (asapgangs.gangList[tag] and not table.HasValue(asapgangs.gangList[tag].Members, steamid)) then
        ASAPDriver:MySQLQuery("INSERT INTO gangs_cache(steamid, gang) values('" .. steamid .. "', '" .. tag .. "') ON DUPLICATE KEY UPDATE gang='" .. tag .. "';")
        table.insert(asapgangs.gangList[tag].Members, steamid)

        --If player it's an object, we update it
        if (IsValid(player.GetBySteamID64(steamid))) then
            player.GetBySteamID64(steamid):UpdateGang(tag)
        end

        asapgangs.Update(tag, "Members")
        asapgangs.AddLog(ply, GANG_LOG_INVITE, (isstring(ply) and steamid or ply:Nick()) .. " It is now part of the gang")
    end
end

function asapgangs.Create(ply, name, tag, url, money)

    tag = tag:sub(1, 5)
    tag = tag:Replace("'", "")
    tag = tag:Replace('"', "")
    name = name:sub(1, 64)
    name = name:Replace("'", "")
    name = name:Replace('"', "")

    if (not ply:canAfford(GANG_PRICE)) then
        DarkRP.notify(ply, 1, 4, "You can't afford to get a gang")

        return
    end

    if (ply:GetGang() ~= "") then
        DarkRP.notify(ply, 1, 4, "You must leave your gang first")

        return
    end

    local members = {ply:SteamID64()}

    members = util.TableToJSON(members)

    local ranks = {
        ["Administrator"] = {
            Color = 2,
            Avatar = "https://i.imgur.com/g2BtspW.png",
            Permissions = {
                EDIT_ROLES = true,
                DISBAND_GANG = true,
                INVITE_MEMBERS = true,
                GANG_INFO = true,
                KICK_MEMBERS = true,
                PURCHASE = true,
                WITHDRAW = true,
                VIEW_ACTIVITY = true,
                CHANGE_BACK = true
            },
            Members = {tostring(ply:SteamID64())}
        }
    }

    ranks = util.TableToJSON(ranks)

    -- To prevent any issues later on (with NULL)
    local shop = util.TableToJSON({
        Backgrounds = {},
        Upgrades = {}
    })

    ASAPDriver:MySQLQuery("SELECT * FROM gangs_list WHERE Name='" .. name .. "' OR Tag = '" .. tag .. "';", function(data)
        if (data and data[1]) then
            ply:SendLua([[Derma_Message("There's already a gang with that name/tag", "Error", "Ok")]])

            return
        end

        ASAPDriver:MySQLQuery("INSERT INTO gangs_list(Name, Tag, Icon, Members, Ranks, Shop, Money) VALUES('" .. sql.SQLStr(name, true) .. "', '" .. sql.SQLStr(tag, true) .. "', '" .. sql.SQLStr(url, true) .. "', '" .. sql.SQLStr(members, true) .. "', '" .. sql.SQLStr(ranks, true) .. "', '" .. sql.SQLStr(shop, true) .. "', " .. (money or 0) .. ")", function(q)
            asapgangs.gangList[tag] = {
                Name = name,
                Tag = tag,
                Money = money or 0,
                Icon = url,
                Members = members,
                Ranks = util.JSONToTable(ranks),
                Shop = {
                    Backgrounds = {},
                    Upgrades = {}
                }
            }

            ply:SetNWString("Gang.Rank", "Administrator")
            ply:UpdateGang(tag)
            ply:addMoney(-GANG_PRICE)
        end)
        ASAPDriver:MySQLQuery("INSERT INTO gangs_cache(steamid, gang) values('" .. ply:SteamID64() .. "', '" .. tag .. "') ON DUPLICATE KEY UPDATE gang='" .. tag .. "';")
        hook.Run("Gangs.Created", ply, tag)
    end)
end

asapgangs.Players = asapgangs.Players or {}

function asapgangs.GetPlayers(tag)
    for k, v in pairs(asapgangs.Players[tag] or {}) do
        if (not IsValid(v)) then table.remove(asapgangs.Players[tag], k) end
    end
    return asapgangs.Players[tag] or {}
end

function asapgangs.FetchGangs(tag, callback)
    ASAPDriver:MySQLQuery("SELECT * FROM gangs_list WHERE Tag = '" .. sql.SQLStr(tag, true) .. "';", function(data)
        PrintTable(data)
        if data and data[1] then
            local v = data[1]
            v.Ranks = util.JSONToTable(v.Ranks)
            v.Members = util.JSONToTable(v.Members)
            v.Shop = util.JSONToTable(v.Shop)
            v.MMR = v.mmr or 0
            v.Inventory = util.JSONToTable(v.Inventory or "[]")
            v.Division = v.division or 0
            asapgangs.gangList[tag] = v
            asapgangs.Inventories[tag] = v.Inventory

            for a, rankData in pairs(v.Ranks) do
                for id, member in pairs(rankData.Members) do
                    local ply = player.GetBySteamID64(member)

                    if IsValid(ply) then
                        ply:SetNWString("Gang.Rank", a)
                    end
                end
            end

            if (callback) then
                callback(v)
            end
        else
            asapgangs.gangList = {}
        end
    end)
end

function asapgangs.GangUpdated(gang)
    for k, v in pairs(asapgangs.gangList) do
        if (isstring(v.Members)) then
            v.Members = util.JSONToTable(v.Members)
        end

        if gang == v.Name then
            for u, member in pairs(v.Members) do
                local person = player.GetBySteamID64(member)
                if not IsValid(person) then continue end
                person:UpdateGang()
            end
        end
    end
end

function asapgangs.RolesUpdated(_tbl)
    local tbl = table.Copy(_tbl) -- don't fuck with the stuff we using

    for k, v in pairs(asapgangs.gangList) do
        if v.Name == _tbl.Name then
            asapgangs.gangList[k].Ranks = _tbl.Ranks
            break
        end
    end

    asapgangs.GangUpdated(_tbl.Name)

    for k, v in pairs(tbl.Ranks) do
        for u, i in pairs(v.Members) do
            if (not table.HasValue(tbl.Ranks[k].Members, i)) then
                table.insert(tbl.Ranks[k].Members, i)
                local ply = player.GetBySteamID64(i)

                if IsValid(ply) then
                    ply:SetNWString("Gang.Rank", k)
                end
            end
        end
    end

    local ranks = util.TableToJSON(tbl.Ranks)
    ASAPDriver:MySQLQuery("UPDATE gangs_list SET Ranks='" .. sql.SQLStr(ranks, true) .. "' WHERE Name='" .. sql.SQLStr(tbl.Name, true) .. "'")
end

function asapgangs.Update(tag, field)
    local update = {}

    for k, v in pairs(isstring(field) and {field} or field) do
        update[v] = asapgangs.gangList[tag][v]
    end

    --"UPDATE `asap_players`.`gangs_list` SET `Tag`='6786', `Icon`='68468Dog-Diarrhea-47066074.jpg', `Members`='[\"786561198044940228\"]' WHERE `Tag`='4222';"
    local query = "UPDATE `gangs_list` SET "
    local max = table.Count(update)
    local i = 1

    for k, v in pairs(update) do
        query = query .. "`" .. k .. "`" .. " = " .. (istable(v) and ("'" .. SQLStr(util.TableToJSON(v), true) .. "'") or (isnumber(v) and v or "'" .. v .. "'")) .. (i < max and "," or " WHERE `Tag`= '" .. tag .. "';")
        i = i + 1
    end

    ASAPDriver:MySQLQuery(query)
    local receivers = {}

    for k, v in pairs(player.GetAll()) do
        if (v:GetGang() == tag) then
            table.insert(receivers, v)
        end
    end

    net.Start("Gangs.Update")
    net.WriteTable(update)
    net.Send(receivers)
end

function asapgangs.UpdateMoney(tag, isCredits)
    local gang = asapgangs.gangList[tag]
    if (not gang) then return end
    local receivers = {}

    for k, v in pairs(player.GetAll()) do
        if (v:GetGang() == tag) then
            table.insert(receivers, v)
        end
    end

    net.Start("Gangs.UpdateMoney")
    net.WriteBool(isCredits)
    net.WriteFloat(gang[isCredits and "Credits" or "Money"])
    net.Send(receivers)
end

function asapgangs.AddXP(tag, am)
    local gang = asapgangs.gangList[tag]
    if (not gang) then return end

    gang.Experience = (gang.Experience or 1) + am
    local receivers = {}

    for k, v in pairs(player.GetAll()) do
        if (v:GetGang() == tag) then
            table.insert(receivers, v)
        end
    end

    timer.Create("SaveGangXP" .. tag, 5, 1, function()
        ASAPDriver:MySQLQuery("UPDATE gangs_list SET Experience=" .. gang.Experience .. " WHERE Tag='" .. tag .. "'")
    end)

    net.Start("Gangs.UpdateXP")
    net.WriteUInt(gang.Experience, 32)
    net.Send(receivers)
end

function asapgangs.DepositMoney(ply, isCredits, amount)
    local tag = ply:GetGang()

    if (asapgangs.gangList[tag]) then
        asapgangs.gangList[tag][isCredits and "Credits" or "Money"] = (asapgangs.gangList[tag][isCredits and "Credits" or "Money"] or 0) + amount
        asapgangs.Update(tag, isCredits and "Credits" or "Money")
        ASAPDriver:MySQLQuery("UPDATE gangs_list SET `" .. (isCredits and "Credits" or "Money") .. "` = " .. asapgangs.gangList[tag][isCredits and "Credits" or "Money"] .. " WHERE `Tag` = '" .. tag .. "';")
    end

    hook.Run("Gangs.Deposit", ply, isCredits, amount)
    asapgangs.AddLog(ply, GANG_LOG_DEPOSIT, ply:Nick() .. " deposited " .. DarkRP.formatMoney(amount) .. "(" .. (isCredits and "Credits" or "Money") .. ")")
end

hook.Add("DatabaseInitialized", "GangQueries", function()
    ASAPDriver:MySQLQuery("CREATE TABLE IF NOT EXISTS gangs_list(Name VARCHAR(255) PRIMARY KEY, Tag VARCHAR(5) NOT NULL, Icon TEXT, Background VARCHAR(100), Members LONGTEXT, Money INT DEFAULT 0, Credits INT DEFAULT 0, Level INT DEFAULT 0, Ranks LONGTEXT, Experience INT DEFAULT 0, Shop LONGTEXT)")
    ASAPDriver:MySQLQuery("CREATE TABLE IF NOT EXISTS gangs_cache(steamid VARCHAR(32) PRIMARY KEY,gang VARCHAR(8) NOT NULL);")
    ASAPDriver:MySQLQuery("CREATE TABLE IF NOT EXISTS gangs_requests(tag VARCHAR(6), message TEXT, steamid VARCHAR(18) PRIMARY KEY, UNIQUE KEY(steamid))")
    ASAPDriver:MySQLQuery("CREATE TABLE IF NOT EXISTS gangs_log(id INT NOT NULL AUTO_INCREMENT, kind INT NOT NULL, tag VARCHAR(6), data TEXT, steamid VARCHAR(18) PRIMARY KEY, UNIQUE KEY(id))")
end)

hook.Add("PlayerInitialSpawn", "gangs_playerInit", function(ply) end) --ply:SetNWString("Gang.Rank", "User") --ply:UpdateGang()

net.Receive("Gangs.Create", function(_, ply)
    if (ply:GetGang() ~= "") then
        ply:UpdateGang(ply:GetGang())

        return
    end

    local name = net.ReadString()
    local tag = net.ReadString()
    local url = net.ReadString()
    if (#tag > 6 or #tag < 3 or string.find(tag, "[%c%p']")) then return end
    asapgangs.Create(ply, name, tag, url)
end)

net.Receive("Gangs.Disband", function(_, ply)
    --Can this player remove the gang?
    if (ply:GangsHasPermission("DISBAND_GANG")) then
        local gang = ply:GetGang()
        if (not asapgangs.gangList[gang]) then return end
        --We remove the gang from database
        ASAPDriver:MySQLQuery("DELETE FROM `gangs_list` WHERE `Tag`='" .. gang .. "';")
        ASAPDriver:MySQLQuery("DELETE FROM `gangs_log` WHERE `tag`='" .. gang .. "';")

        if isstring(asapgangs.gangList[gang].Members) then
            asapgangs.gangList[gang].Members = util.JSONToTable(asapgangs.gangList[gang].Members)
        end

        for _, sid in pairs(asapgangs.gangList[gang].Members) do
            --We clean this steamid from our cache
            ASAPDriver:MySQLQuery("DELETE FROM `gangs_cache` WHERE `steamid`='" .. sid .. "';")
            local newply = player.GetBySteamID64(sid)

            --if some player it's online, we took them off from the gang
            if (IsValid(newply)) then
                newply:SetNWString("Gang", "")
                newply:SetNWString("Gang.Role", "")
                net.Start("Gangs.RemovePanel")
                net.Send(newply)
            end
        end

        hook.Run("Gangs.Disband", ply, gang)
        asapgangs.gangList[gang] = nil
    end
end)

net.Receive("Gangs.RequestPublic", function(l, ply)
    local gangs = {}
    local i = 0

    for k, v in RandomPairs(player.GetAll()) do
        if (i > 10) then break end

        if (v:GetGang() ~= "" and not gangs[v:GetGang()]) then
            for id, gang in pairs(asapgangs.gangList) do
                if (gang.Tag == v:GetGang()) then
                    local memLevel = asapgangs.GetUpgrade(gang.Tag, "Members")

                    if (isstring(asapgangs.gangList[gang.Tag].Members)) then
                        asapgangs.gangList[gang.Tag].Members = util.JSONToTable(asapgangs.gangList[gang.Tag].Members)
                    end

                    if (table.Count(asapgangs.gangList[gang.Tag].Members) >= (UPGRADE_TEST["Members"].Data[memLevel] or 10)) then continue end

                    gangs[v:GetGang()] = {
                        Members = #gang.Members,
                        Avatar = gang.Icon,
                        Tag = gang.Tag,
                        Name = gang.Name
                    }

                    i = i + 1
                    break
                end
            end
        end
    end

    net.Start("Gangs.RequestPublic")
    net.WriteTable(gangs)
    net.Send(ply)
end)

net.Receive("Gangs.Edit", function(_, ply)
    if not ply:GangsHasPermission("GANG_INFO") then return end
    local name = net.ReadString()
    local url_escaped = net.ReadString()
    if not name or not url_escaped then return end
    local gang = ply:FindGang()
    if not gang then return end
    local url = url_escaped

    if (string.find(url, "imgur", 1, true) and (string.EndsWith(url, ".png") or string.EndsWith(url, ".jpg" or string.EndsWith(url, ".jpeg")))) then
        url = url_escaped
    else
        return
    end

    local qry = ASAPDriver:MySQLQuery("UPDATE gangs_list SET Name='" .. sql.SQLStr(name, true) .. "', Icon='" .. sql.SQLStr(url or gang.Icon, true) .. "' WHERE Name='" .. gang.Name .. "'")

    for k, v in pairs(asapgangs.gangList) do
        if v.Name == gang.Name then
            asapgangs.gangList[k].Name = name

            if (url) then
                asapgangs.gangList[k].Icon = url
            end

            break
        end
    end

    hook.Run("Gangs.Rename", ply, name, url_escaped)
    asapgangs.GangUpdated(name)
    asapgangs.AddLog(ply, GANG_LOG_ROLE, ply:Nick() .. " edited the gang information")
end)

net.Receive("Gangs.NewRole", function(_, ply)
    local gang = ply:FindGang()
    if not gang then return end

    if not ply:GangsHasPermission("EDIT_ROLES") then
        MsgC(Color(255, 0, 0) ,"[Gang]", color_white, ply:Nick(), ":", ply:SteamID64(), " NO EDIT PERMISSION\n")
        
        return
    end
    
    local name = net.ReadString()
    local col = net.ReadInt(4)
    local perms = net.ReadTable()
    local url = net.ReadString()
    local old = net.ReadString()
    
    if name == "New role" and old == "New role" then
        MsgC(Color(255, 0, 0) ,"[Gang]", color_white, ply:Nick(), ":", ply:SteamID64(), " NEW ROLE IS NOT VALID\n")

        return
    end

    if old and gang.Ranks[old] then
        if old ~= name then
            gang.Ranks[name] = table.Copy(gang.Ranks[old])
            gang.Ranks[old] = nil
        end

        gang.Ranks[name].Color = col
        gang.Ranks[name].Permissions = perms
        gang.Ranks[name].Avatar = url
    else
        gang.Ranks[name] = {
            Avatar = url,
            Color = col,
            Members = {},
            Permissions = perms
        }
    end

    asapgangs.RolesUpdated(gang)
    asapgangs.AddLog(ply, GANG_LOG_ROLE, ply:Nick() .. " created a new role " .. name)
end)

net.Receive("Gangs.SetRank", function(_, ply)
    local gang = ply:FindGang()
    if not gang then return end
    if not ply:GangsHasPermission("EDIT_ROLES") then return end
    local sid = net.ReadString()
    local role = net.ReadString()

    for k, v in pairs(gang.Ranks) do
        local isInRank = table.HasValue(v.Members, sid)
        if k == role and isInRank then return end

        if isInRank then
            table.RemoveByValue(gang.Ranks[k].Members, sid)
            local ply = player.GetBySteamID64(sid)

            if IsValid(ply) then
                ply:SetNWString("Gang.Rank", "")
            end
        end

        if k == role then
            table.insert(gang.Ranks[k].Members, sid)
            local ply = player.GetBySteamID64(sid)

            if IsValid(ply) then
                ply:SetNWString("Gang.Rank", k)
            end
        end

        hook.Run("Gangs.SetRole", ply, sid, tag, role)
        asapgangs.RolesUpdated(gang)
    end

    asapgangs.AddLog(ply, GANG_LOG_ROLE, ply:Nick() .. " set rank " .. role .. " to " .. sid)
end)

net.Receive("Gangs.RemoveRole", function(_, ply)
    local gang = ply:FindGang()
    if not gang then return end
    if not ply:GangsHasPermission("EDIT_ROLES") then return end
    local role = net.ReadString()

    for k, v in pairs(gang.Ranks) do
        if k == role then
            gang.Ranks[k] = nil
            asapgangs.RolesUpdated(gang)
        end
    end

    asapgangs.AddLog(ply, GANG_LOG_ROLE, ply:Nick() .. " removed the role " .. role)
end)

net.Receive("Gangs.KickMember", function(_, ply)
    local gang = ply:FindGang()
    if not gang then return end
    if not ply:GangsHasPermission("KICK_MEMBERS") then return end
    if ply:GetNWString("Gang.Rank", "User") == "User" then return end
    local isSid = net.ReadBool()
    local sid = isSid and net.ReadString() or net.ReadEntity()
    local kicked = isSid and player.GetBySteamID64(sid) or sid

    if IsValid(kicked) then
        kicked:SetNWString("Gang", "")
        kicked:SetNWString("Gang.Rank", "")
        net.Start("Gangs.KickMember")
        net.WriteEntity(ply)
        net.WriteString(ply:GetGang())
        net.Send(kicked)
    end

    if not isSid then
        hook.Run("Gangs.Kick", ply, sid)
        return
    end

    if not table.HasValue(gang.Members, sid) then return end
    table.RemoveByValue(gang.Members, sid)

    for k, v in pairs(gang.Ranks) do
        table.RemoveByValue(v.Members, sid)
    end

    hook.Run("Gangs.Kick", ply, sid)

    asapgangs.Update(ply:GetGang(), {"Members", "Ranks"})

    ASAPDriver:MySQLQuery("DELETE FROM `gangs_cache` WHERE `steamid`='" .. sid .. "';")
    ASAPDriver:MySQLQuery("DELETE FROM `gangs_requests` WHERE `steamid`='" .. sid .. "';")
    asapgangs.AddLog(ply, GANG_LOG_KICK, ply:Nick() .. " kicked to " .. (IsValid(kicked) and kicked:Nick() or sid))
end)

--asapgangs.RolesUpdated(gang)
--local members = util.TableToJSON(gang.Members)
--asapgangs.query("UPDATE gangs_list SET Members='" .. sql.SQLStr(members, true) .. "' WHERE Name='" .. gang.Name .. "'")
net.Receive("Gangs.BuyBackground", function(_, ply)
    local gang = ply:FindGang()
    if not gang then return end
    if not ply:GangsHasPermission("CHANGE_BACK") then return end
    local isToken = net.ReadBool()
    local bg = net.ReadString()
    if not asapgangs.backgrounds[bg] then return end
    if (table.HasValue(gang.Shop.Backgrounds, bg)) then return end
    local bgN = bg
    bg = asapgangs.backgrounds[bg]

    if isToken then
        if gang.Credits < bg.Credits then return end
        gang.Credits = gang.Credits - bg.Credits

        asapgangs.Update(ply:GetGang(), {"Shop", "Credits", "Background"})

        asapgangs.AddLog(ply, GANG_LOG_PURCHASE, ply:Nick() .. " purchased " .. bgN .. " background with credits")
    else
        if gang.Money < bg.Price then return end
        gang.Background = bgN
        gang.Money = gang.Money - bg.Price

        asapgangs.Update(ply:GetGang(), {"Shop", "Money", "Background"})

        asapgangs.AddLog(ply, GANG_LOG_PURCHASE, ply:Nick() .. " purchased " .. bgN .. " background with money")
    end

    table.insert(gang.Shop.Backgrounds, bgN)
    local shop = util.TableToJSON(gang.Shop)
    ASAPDriver:MySQLQuery("UPDATE gangs_list SET Shop='" .. sql.SQLStr(shop, true) .. "', Background='" .. sql.SQLStr(bgN, true) .. "' WHERE Name='" .. gang.Name .. "'")
end)

concommand.Add("cl3_gangs", function(ply)
    PrintTable(asapgangs.gangList)
end)

concommand.Add("asap_setgang", function(ply, cmd, args)
    if IsValid(ply) then return end
    ASAPDriver:MySQLQuery("INSERT INTO gangs_cache(steamid, gang) values('" .. args[2] .. "', '" .. args[1] .. "') ON DUPLICATE KEY UPDATE gang='" .. args[1] .. "';", function()
        MsgN("[Gangs] Gang updated!")
    end)
end)
