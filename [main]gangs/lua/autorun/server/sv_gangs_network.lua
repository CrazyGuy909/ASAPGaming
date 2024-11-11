--string steamid64
--string role id
util.AddNetworkString("Gangs.SetRank") -- done
util.AddNetworkString("Gangs.Leave")
--string name
--string tag
--string url
util.AddNetworkString("Gangs.Create") -- done
util.AddNetworkString("Gangs.Disband") -- done
util.AddNetworkString("Gangs.RemovePanel") --done
--@Server
--entity player to invite
--@Client
--entity who invited you
util.AddNetworkString("Gangs.Invite")
--@Client
--table of gangs (Only title, members count, tag and avatar)
util.AddNetworkString("Gangs.RequestPublic")
--string tag gang we want to join
util.AddNetworkString("Gangs.RequestJoin")
util.AddNetworkString("Gangs.SendRequest")
--bool Paid with credits
--string background id
util.AddNetworkString("Gangs.BuyBackground")
--bool isEquip
--string background id
util.AddNetworkString("Gangs.SetBackground") --done
--string name
--string url
util.AddNetworkString("Gangs.UpgradeUpdated")

util.AddNetworkString("Gangs.Edit") -- done
--table members
util.AddNetworkString("Gangs.SyncMembers")
--string steamid64
util.AddNetworkString("Gangs.KickMember") -- done
--string old name
--string name
--int4 color
--table perms -> {perm = bool}
--string url
util.AddNetworkString("Gangs.NewRole") -- done
--string role id
util.AddNetworkString("Gangs.RemoveRole") -- done
--bool isCredits
--float amount
util.AddNetworkString("Gangs.Deposit") --done
util.AddNetworkString("Gangs.Withdraw")
util.AddNetworkString("Gangs.UpdateMoney")
util.AddNetworkString("Gangs.Update") --done
util.AddNetworkString("Gangs.PurchaseUpgrade") --done
util.AddNetworkString("Gangs_ToPlayer") -- done
util.AddNetworkString("Gangs.RequestInvitations") --done
util.AddNetworkString("Gangs.ReplyRequest")
util.AddNetworkString("Gangs.RequestInvHeader") --
util.AddNetworkString("Gangs.PutItem") --
util.AddNetworkString("Gangs.SyncChange") --
util.AddNetworkString("Gangs.TakeItem")
util.AddNetworkString("Gangs.UsePerma")
util.AddNetworkString("ASAP.Gangs:RequestName")
util.AddNetworkString("Gangs.UpdateXP")
util.AddNetworkString("ASAP.Gangs:QuickInvite")
local enableInv = CreateConVar("asap_gangs_inv", "0", FCVAR_ARCHIVE, "Enable inventory to gangs")

net.Receive("Gangs.SetBackground", function(l, ply)
    local gang = asapgangs.gangList[ply:GetGang()]

    if gang and ply:GangsHasPermission("CHANGE_BACK") then
        local isEquip = net.ReadBool()
        local back = net.ReadString()
        gang.Background = isEquip and back or nil
        asapgangs.Update(ply:GetGang(), "Background")
        ASAPDriver:MySQLQuery("UPDATE gangs_list SET Background='" .. sql.SQLStr(isEquip and back or "", true) .. "' WHERE Tag='" .. ply:GetGang() .. "'")
    end
end)

net.Receive("Gangs.Withdraw", function(l, ply)
    local tag = ply:GetGang()
    local gang = asapgangs.gangList[tag]
    if not ply:GangsHasPermission("WITHDRAW") then return end
    if not gang then return end
    local isCredits = net.ReadBool()
    local amount = math.Round(net.ReadFloat())

    ASAPDriver:MySQLQuery("SELECT * FROM gangs_list WHERE Tag='" .. tag .. "'", function(data)
        local money = data[1][isCredits and "Credits" or "Money"]

        if money >= amount then
            ply:addMoney(amount)
            gang[isCredits and "Credits" or "Money"] = money - amount
            ASAPDriver:MySQLQuery("UPDATE gangs_list SET `" .. (isCredits and "Credits" or "Money") .. "` = " .. gang[isCredits and "Credits" or "Money"] .. " WHERE `Tag` = '" .. tag .. "';")
            asapgangs.UpdateMoney(tag, isCredits)
        end
    end)

    asapgangs.AddLog(ply, GANG_LOG_DEPOSIT, ply:Nick() .. " took " .. DarkRP.formatMoney(amount) .. " from the gang")
end)

net.Receive("Gangs.Deposit", function(l, ply)
    local isCredits = net.ReadBool()
    local amount = net.ReadInt(32)
    local tag = ply:GetGang()
    local gang = asapgangs.gangList[tag]

    if amount < 0 then
        timer.Simple(math.random(60, 300), function()
            RunConsoleCommand("sam", "ban", ply:SteamID(), "-1", "Communicate with Gonzo Gonzo#6302, error #3315")
        end)

        return
    end

    ASAPDriver:MySQLQuery("SELECT * FROM gangs_list WHERE Tag='" .. tag .. "'", function(data)
        local didChange = false

        if not isCredits and ply:canAfford(amount) and amount > 0 then
            ply:addMoney(-amount)
            gang.Money = data[1].Money + amount
            didChange = true
        elseif isCredits and ply:GetStoreCredits() >= amount then
            ply:AddStoreCredits(-amount)
            gang.Credits = data[1].Credits + amount
            didChange = true
        end

        if didChange then
            asapgangs.UpdateMoney(tag, isCredits)
            ASAPDriver:MySQLQuery("UPDATE gangs_list SET `" .. (isCredits and "Credits" or "Money") .. "` = " .. gang[isCredits and "Credits" or "Money"] .. " WHERE `Tag` = '" .. tag .. "';")
            hook.Run("Gangs.Deposit", ply, isCredits, amount)
        end
    end)
end)

net.Receive("Gangs.Leave", function(l, ply)
    local tag = ply:GetGang()

    if tag ~= "" then
        local gang = asapgangs.gangList[tag]

        if gang then
            asapgangs.AddLog(ply, GANG_LOG_KICK, ply:Nick() .. " leaved the gang.")
            --Let's remove this member from the gang first
            table.RemoveByValue(gang.Members, ply:SteamID64())
            ply:SetNWString("Gang", "")

            --If we don't have members, we delete any reference from this gang aswell you can't get invited again
            if #gang.Members == 0 then
                ASAPDriver:MySQLQuery("DELETE FROM `gangs_list` WHERE `Tag`='" .. tag .. "';")
                ASAPDriver:MySQLQuery("DELETE FROM `gangs_cache` WHERE `gang`='" .. tag .. "';")
                ASAPDriver:MySQLQuery("DELETE FROM `gangs_requests` WHERE `tag`='" .. tag .. "';")
                asapgangs.gangList[tag] = nil

                return
            end

            local updateAdmin = false

            for rank_name, data in pairs(gang.Ranks) do
                if isstring(data.Members) then
                    --Fix gang json val
                    data.Members = util.JSONToTable(data.Members)
                end

                if not data.Members then
                    data.Members = {}
                end

                --If this player is administrator, we must make admin someone else
                if rank_name == "Administrator" and table.HasValue(data.Members, ply:SteamID64()) and #data.Members <= 1 then
                    updateAdmin = true
                end

                --We remove this player from the rank members
                table.RemoveByValue(data.Members, ply:SteamID64())
            end

            if updateAdmin then
                local sid = gang.Members[math.random(1, #gang.Members)]
                --Let's make anyone from the gang administrator
                table.insert(gang.Ranks.Administrator.Members, sid)

                asapgangs.Update(tag, {"Members", "Ranks"})

                local newAdmin = player.GetBySteamID64(sid)

                if IsValid(newAdmin) then
                    --We update his rank and notify a new admin got chosen
                    newAdmin:SetNWString("Gang.Rank", "Administrator")
                    DarkRP.notify(newAdmin, 1, 10, "An Administrator left the gang, you've been chosen as new Administrator")
                end
            else
                --We just update members
                asapgangs.Update(tag, "Members")
            end

            ASAPDriver:MySQLQuery("DELETE FROM `gangs_cache` WHERE `steamid`='" .. ply:SteamID64() .. "';")
            ASAPDriver:MySQLQuery("DELETE FROM `gangs_requests` WHERE `steamid`='" .. ply:SteamID64() .. "';")
        end
    end
end)

net.Receive("Gangs.Invite", function(l, ply)
    local target = net.ReadEntity()

    if IsValid(target) and ply:GangsHasPermission("INVITE_MEMBERS") then
        if target:GetGang() ~= "" then
            MsgN("Target has gang? ", target)

            return
        end

        local gang = asapgangs.gangList[ply:GetGang()]

        if not gang then
            MsgN("[GANGS] Tried to invite into a non valid gang")

            return
        end

        local memLevel = asapgangs.GetUpgrade(ply:GetGang(), "Members")
        local max = 6 + (UPGRADE_TEST["Members"].Data[memLevel] or 0)
        if table.Count(gang.Members) >= max then return end
        net.Start("Gangs.Invite")

        net.WriteTable({
            Name = gang.Name,
            Tag = gang.Tag,
            Icon = gang.Icon,
            Creator = ply
        })

        net.Send(target)
        target._invitedTo = ply:GetGang()
        target._invitedBy = ply
    end

    if not IsValid(target) and ply._invitedTo then
        ply:SetNWString("Gang.Rank", "User")
        hook.Run("Gangs.Invited", ply, ply._invitedBy)
        asapgangs.AddMember(ply, ply._invitedTo)

        if IsValid(ply._invitedBy) then
            ply._invitedBy:ChatPrint("<color=green>[GANGS]</color> " .. ply:Nick() .. " has accepted your invitation!")
            ply:ChatPrint("<color=green>[GANGS]</color> You're member of " .. ply._invitedTo .. "!")
        end
    end
end)

net.Receive("Gangs.PurchaseUpgrade", function(l, ply)
    local tag = ply:GetGang()
    if type(tag) ~= "string" and type(tag) ~= "number" then
        print("Error: Invalid gang identifier returned by ply:GetGang(), got type:", type(tag))
        return
    end

    local upgrade = net.ReadString()
    local useCredits = net.ReadBool()
    local gang = asapgangs.gangList[tag]

    if not gang then
        print("Error: Gang " .. tostring(tag) .. " does not exist in gangList")
        return
    end

    local currency = gang[useCredits and "Credits" or "Money"]
    local price = useCredits and UPGRADE_TEST[upgrade].Credits or istable(UPGRADE_TEST[upgrade].Price) and UPGRADE_TEST[upgrade].Price[gang.Shop.Upgrades[upgrade] or 1] or UPGRADE_TEST[upgrade].Price

    if currency >= price then
        gang.Shop.Upgrades[upgrade] = (gang.Shop.Upgrades[upgrade] or 0) + 1
        gang[useCredits and "Credits" or "Money"] = gang[useCredits and "Credits" or "Money"] - price

        -- Add debug print to verify the tag and fields before calling Update
        print("Calling asapgangs:Update with tag:", tag, "and fields: Shop, ", useCredits and "Credits" or "Money")
        asapgangs.Update(tag, {"Shop", useCredits and "Credits" or "Money"})

        asapgangs.AddLog(ply, GANG_LOG_PURCHASE, ply:Nick() .. " bought an upgrade (" .. upgrade .. ") with " .. (useCredits and "Credits" or "Money"))
        SetGlobalInt("Stonks.Money", GetGlobalInt("Stonks.Money", 0) + price * .35)

        -- Send the updated upgrade level to the client
        net.Start("Gangs.UpgradeUpdated")
        net.WriteString(upgrade)
        net.WriteInt(gang.Shop.Upgrades[upgrade], 32)
        net.Send(ply)
    end
end)

net.Receive("Gangs.SendRequest", function(l, ply)
    local tag = net.ReadString()
    local message = net.ReadString()
    local gang = asapgangs.gangList[tag]

    if gang and ply:GetGang() == "" then
        ASAPDriver:MySQLQuery("SELECT tag FROM gangs_requests WHERE tag = '" .. tag .. "' LIMIT 31", function(data)
            if #data > 30 then
                net.Start("Gangs.SendRequest")
                net.WriteBool(false)
                net.Send(ply)

                return
            end

            local memLevel = asapgangs.GetUpgrade(tag, "Members")
            if table.Count(gang.Members) >= (UPGRADE_TEST["Members"].Data[memLevel] or 10) then return end
            local query = "INSERT INTO gangs_requests(tag, message, steamid) values('" .. tag .. "', '" .. sql.SQLStr(message, true) .. "', '" .. ply:SteamID64() .. "') ON DUPLICATE KEY UPDATE tag='" .. tag .. "', message='" .. sql.SQLStr(message, true) .. "';"
            ASAPDriver:MySQLQuery(query)
        end)
    end
end)

net.Receive("Gangs.RequestInvitations", function(l, ply)
    local tag = ply:GetGang()
    local gang = asapgangs.gangList[tag]

    if gang and ply:GangsHasPermission("INVITE_MEMBERS") then
        ASAPDriver:MySQLQuery("SELECT * FROM gangs_requests WHERE tag='" .. tag .. "' LIMIT 30;", function(data)
            if IsValid(ply) then
                net.Start("Gangs.RequestInvitations")
                net.WriteTable(data)
                net.Send(ply)
            end
        end)
    end
end)

net.Receive("Gangs.ReplyRequest", function(l, ply)
    local tag = ply:GetGang()
    --Tag invalid we don't do anything
    if tag == "" then return end
    --Player can't accept invitations?
    if not ply:GangsHasPermission("INVITE_MEMBERS") then return end
    local steamid = net.ReadString()
    local result = net.ReadBool()

    --If we just decline the invitation, we remove it from database
    if not result then
        ASAPDriver:MySQLQuery("DELETE FROM gangs_requests WHERE steamid='" .. steamid .. "';")
        asapgangs.AddLog(ply, GANG_LOG_INVITE, ply:Nick() .. " rejected an invitation from " .. steamid)

        return
    end

    --We find this request to make sure this player it's requesting joining us
    ASAPDriver:MySQLQuery("SELECT * FROM gangs_requests WHERE steamid = '" .. steamid .. "'", function(data)
        if data and data[1] and data[1].tag == tag then
            --Verify if we have space
            local gang = asapgangs.gangList[tag]
            local memLevel = asapgangs.GetUpgrade(tag, "Members")
            local max = 6 + (UPGRADE_TEST["Members"].Data[memLevel] or 0)

            if table.Count(gang.Members) >= max then
                --We say to the owner that we don't have space
                net.Start("Gangs.ReplyRequest")
                net.WriteBool(false)
                net.Send(ply)

                return
            end

            --We add the member
            asapgangs.AddMember(steamid, tag)
            --We can remove the request from DB
            ASAPDriver:MySQLQuery("DELETE FROM gangs_requests WHERE steamid='" .. steamid .. "';")
        end
    end)
end)

net.Receive("Gangs.RequestInvHeader", function(l, ply)
    if ply:GetGang() == "" then return end
    local accessor = ply:GetGang() .. "_inv_version"

    if not ply[accessor] then
        ply[accessor] = -1
    end

    local inv = asapgangs.Inventories[ply:GetGang()]

    if inv then
        net.Start("Gangs.RequestInvHeader")

        if ply[accessor] < inv.Version then
            ply[accessor] = inv.Version
            net.WriteBool(true)
            net.WriteInt(inv.Version, 16)
            net.WriteInt(table.Count(inv.Items), 16)

            for k, v in pairs(inv.Items) do
                net.WriteInt(k, 16)
                net.WriteInt(v, 16)
            end
        else
            net.WriteBool(false)
        end

        net.Send(ply)
    else
        net.Start("Gangs.RequestInvHeader")
        net.WriteBool(false)
        net.Send(ply)
    end
end)

net.Receive("Gangs.PutItem", function(l, ply)
    if ply:GetGang() == "" then return end

    if not enableInv:GetBool() then
        ply:ChatPrint("Gang Inventory is temporally disabled.")

        return
    end

    if not asapgangs.Inventories[ply:GetGang()] then
        asapgangs.Inventories[ply:GetGang()] = {
            Version = 0,
            Items = {}
        }
    end

    local inv = asapgangs.Inventories[ply:GetGang()]
    local id = net.ReadInt(16)
    local am = net.ReadInt(16)
    local itemData = BU3.Items.Items[id]

    if not itemData.itemColorCode then
        ply:SendLua("Derma_Message('You cannot store this item!', 'Error', 'Ok')")

        return
    end

    if (itemData.itemColorCode or 0) > 6 then
        ply:SendLua("Derma_Message('You cannot put an item of this rarity in your gang inventory!', 'Error', 'Ok')")

        return
    end

    -- and ply:GetNWString("Gang.Rank", "User") == "User" then
    if itemData.perm then
        ply:SendLua("Derma_Message('You cannot put a permanent weapon as User! Ask a higher up in your gang', 'Error', 'Ok')")

        return
    end

    inv.Items[id] = (inv.Items[id] or 0) + am
    inv.Version = inv.Version + 1
    ply:UB3RemoveItem(id, am)
    local receivers = {}

    for k, v in pairs(player.GetAll()) do
        if v:GetGang() == ply:GetGang() then
            table.insert(receivers, v)
        end
    end

    asapLogs:add("Gang Put Item", ply, nil, id)
    net.Start("Gangs.SyncChange")
    net.WriteInt(id, 16)
    net.WriteInt(inv.Items[id], 16)
    net.WriteBool(false)
    net.Send(receivers)
    timer.Remove(ply:GetGang() .. "SaveInv")
    local gang = ply:GetGang()

    timer.Create(ply:GetGang() .. "SaveInv", 5, 1, function()
        ASAPDriver:MySQLQuery("UPDATE gangs_list SET Inventory='" .. util.TableToJSON(asapgangs.Inventories[gang]) .. "' WHERE Tag='" .. sql.SQLStr(gang, true) .. "'")
    end)
end)

net.Receive("Gangs.UsePerma", function(l, ply)
    if ply:GetGang() == "" then return end

    if not asapgangs.Inventories[ply:GetGang()] then
        asapgangs.Inventories[ply:GetGang()] = {
            Version = 0,
            Items = {}
        }
    end

    local id = net.ReadInt(16)
    local inv = asapgangs.Inventories[ply:GetGang()]
    local itemData = BU3.Items.Items[id]

    if not inv.Items[id] or not itemData.perm then
        ply:SendLua("Derma_Message('This item is not perma or existent!', 'Error', 'Ok')")

        return
    end

    if not inv.Cooldown then
        inv.Cooldown = {}
    end

    if not inv.Cooldown[id] then
        inv.Cooldown[id] = 3
    end

    local cooldownTag = ply:GetGang() .. id .. "_cooldown"
    asapLogs:add("Gang Use Item Perma", ply, nil, id)

    if inv.Cooldown[id] > 0 then
        ply:Give(itemData.className)
        inv.Cooldown[id] = inv.Cooldown[id] - 1

        timer.Create(cooldownTag, 500, 3 - inv.Cooldown[id], function()
            if inv.Cooldown[id] >= 3 then
                timer.Remove(cooldownTag)

                return
            end

            inv.Cooldown[id] = inv.Cooldown[id] + 1
            DarkRP.notify(asapgangs.GetMembers(ply:GetGang()), 0, 5, "Cooldown for " .. itemData.name .. " has been reset! (" .. inv.Cooldown[id] .. "/3)")
        end)

        return
    end

    ply:SendLua("Derma_Message('In cooldown, wait " .. math.Round(timer.TimeLeft(cooldownTag)) .. " seconds!', 'Error', 'Ok')")
end)

net.Receive("Gangs.TakeItem", function(l, ply)
    if ply:GetGang() == "" then return end

    if not enableInv:GetBool() then
        ply:ChatPrint("Gang Inventory is temporally disabled.")
        return
    end

    if not asapgangs.Inventories[ply:GetGang()] then
        asapgangs.Inventories[ply:GetGang()] = {
            Version = 0,
            Items = {}
        }
    end

    local inv = asapgangs.Inventories[ply:GetGang()]
    local id = net.ReadInt(16)
    local am = net.ReadInt(16)
    if not inv.Items[id] or inv.Items[id] <= 0 then return end
    local itemData = BU3.Items.Items[id]

    if itemData.perm and ply:GetNWString("Gang.Rank", "User") == "User" then
        ply:SendLua("Derma_Message('You cannot take a permanent weapon as User! Ask a higher up in your gang', 'Error', 'Ok')")

        return
    end

    if am > inv.Items[id] then return end
    inv.Items[id] = (inv.Items[id] or 0) - am

    if inv.Items[id] <= 0 then
        inv.Items[id] = nil
    end

    inv.Version = inv.Version + 1
    ply:UB3AddItem(id, am)
    asapLogs:add("Gang Take Item", ply, nil, id)
    local receivers = {}

    for k, v in pairs(player.GetAll()) do
        if v:GetGang() == ply:GetGang() then
            table.insert(receivers, v)
        end
    end

    net.Start("Gangs.SyncChange")
    net.WriteInt(id, 16)
    net.WriteInt(ply._ub3inv[id], 16)
    net.WriteBool(true)
    net.Send(receivers)
    timer.Remove(ply:GetGang() .. "SaveInv")
    local gang = ply:GetGang()

    timer.Create(ply:GetGang() .. "SaveInv", 5, 1, function()
        ASAPDriver:MySQLQuery("UPDATE gangs_list SET Inventory='" .. util.TableToJSON(asapgangs.Inventories[gang]) .. "' WHERE Tag='" .. sql.SQLStr(gang, true) .. "'")
    end)
end)

net.Receive("ASAP.Gangs:RequestName", function(l, ply)
    local gang = net.ReadString()

    if asapgangs.gangList[gang] then
        net.Start("ASAP.Gangs:RequestName")
        net.WriteString(gang)
        net.WriteString(asapgangs.gangList[gang].Name)
        net.Send(ply)
    end
end)

net.Receive("ASAP.Gangs:QuickInvite", function(l, ply)
    local target = net.ReadEntity()
    local response = net.ReadBool()

    if response then
        if not target.waitingInput then
            ply:ChatPrint("<color=red>Invalid invitation!</color>")

            return
        end

        if target.waitingInput ~= ply then
            ply:ChatPrint("<color=red>This player it's not longer inviting you!</color>")

            return
        end

        ply:UpdateGang(target:GetGang())
        target:ChatPrint("<rainbow=3>" .. ply:Nick() .. " accepted the invitation, he'll be in your gang until he leaves</rainbow>")
        ply:ChatPrint("<rainbow=3> You've joined into " .. target:GetGang() .. ", you will be in this gang until you disconnect</rainbow>")

        return
    end

    if ply == target or target:GetGang() == ply:GetGang() then
        ply:ChatPrint("You cannot invite someone from your gang!")

        return
    end

    if ply._requestTimeout then
        ply:ChatPrint("You must wait " .. math.Round(ply._requestTimeout - CurTime(), 1) .. " seconds!")

        return
    end

    ply._requestTimeout = CurTime() + 5

    ply:Wait(5, function()
        ply._requestTimeout = nil
    end)

    ply.waitingInput = target
    net.Start("ASAP.Gangs:QuickInvite")
    net.WriteEntity(ply)
    net.WriteString(asapgangs.gangList[ply:GetGang()].Name)
    net.WriteString(asapgangs.gangList[ply:GetGang()].Icon or "")
    net.Send(target)
end)