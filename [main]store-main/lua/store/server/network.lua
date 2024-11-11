util.AddNetworkString("Store.SyncCredits")
util.AddNetworkString("Store.Misc.OnUnlock")
util.AddNetworkString("Store.PermanentWeapons")
util.AddNetworkString("Store.PermanentWeapon")
util.AddNetworkString("Store.UnlockPerm")
util.AddNetworkString("Store.SellPerm")
util.AddNetworkString("Store.SetActivePerm")
util.AddNetworkString("Store.ActivePermanentWeapons")
util.AddNetworkString("Store.SetNoActivePerm")
util.AddNetworkString("Store.PurchasePackage")
util.AddNetworkString("Store.BoughtCredits")
util.AddNetworkString("Store.OpenMenu")
util.AddNetworkString("Store.SyncOldCredits")
util.AddNetworkString("Store.TradePoints")

local function discordLog(ply, pcg, price)
    if not ply or not ply:IsPlayer() or not pcg or not price then return end

    http.Fetch("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=7B9B05A10513E74A3CD075E89EF105D3&steamids=" .. ply:SteamID64() .. "", function(body)
        body = util.JSONToTable(body)
        if not body or not body["response"] or not body["response"]["players"] or not body["response"]["players"][1] then return end
        local person = body["response"]["players"][1]
        local avi = person.avatarfull

        http.Post("http://145.239.205.161:2055/store/rank", {
            secret = "Uc%441gqfx8",
            info = util.TableToJSON({
                name = ply:Nick(),
                pkg = pcg,
                cost = price,
                img = avi,
                sid = ply:SteamID()
            })
        }, function(bod)
            print(bod)
        end, function(err)
            print("post request error:")
            print(err)
        end)
    end)
end

net.Receive("Store.Misc.OnUnlock", function(len, ply)
    local cat = net.ReadUInt(8)
    local id = net.ReadUInt(16)
    if (not Store.Credits[cat]) then return end
    if (not Store.Credits[cat].items[id]) then return end
    local tbl = Store.Credits[cat].items[id]
    if (not ply:CanAffordStoreCredits(tbl.cost)) then return end

    if (tbl.limited and os.time() > tbl.limited) then
        print("can't purchase. expired.")

        return
    end

    ply:AddStoreCredits(-tbl.cost)
    discordLog(ply, tbl.title, tbl.cost)
    tbl.onUnlock(ply, tbl, cat, id)
end)

net.Receive("Store.UnlockPerm", function(len, ply)
    local cat = net.ReadUInt(8)
    local id = net.ReadUInt(16)
    if (not Store.Weapons[cat]) then return end
    if (not Store.Weapons[cat].items[id]) then return end
    local tbl = Store.Weapons[cat].items[id]
    if (not ply:CanAffordStoreCredits(tbl.cost)) then return end

    if (tbl.limited and os.time() > tbl.limited) then
        print("can't purchase. expired.")

        return
    end

    ply:AddStoreCredits(-tbl.cost)
    ply:AddPermanentWeapon(tbl.ent)
    discordLog(ply, "Permanent " .. tbl.title, tbl.cost)
    Store.Database:SaveWeapon(ply, tbl.ent, false)
end)

net.Receive("Store.SetActivePerm", function(len, ply)
    local cat = net.ReadUInt(8)
    local id = net.ReadUInt(16)
    if (not Store.Weapons[cat]) then return end
    if (not Store.Weapons[cat].items[id]) then return end
    local tbl = Store.Weapons[cat].items[id]
    local owns = ply:GetPermanentWeapons()[tbl.ent]
    if (not owns) then return end
    ply:AddActivePermanentWeapon(tbl.ent)
    local wep = ply:Give(tbl.ent)

    if (wep and IsValid(wep) and type(tbl.ent) == "string") then
        wep.isPerm = true
    end

    Store.Database:SaveWeapon(ply, tbl.ent, true)
end)

net.Receive("Store.SetNoActivePerm", function(len, ply)
    local cat = net.ReadUInt(8)
    local id = net.ReadUInt(16)
    if (not Store.Weapons[cat]) then return end
    if (not Store.Weapons[cat].items[id]) then return end
    local tbl = Store.Weapons[cat].items[id]
    local owns = ply:GetPermanentWeapons()[tbl.ent]
    if (not owns) then return end
    ply:RemoveActivePermanentWeapon(tbl.ent)
    Store.Database:SaveWeapon(ply, tbl.ent, false)
end)


net.Receive("Store.PurchasePackage", function(len, ply)
    local rankId = net.ReadUInt(8)
    local index
    for k, v in pairs(Store.Packages) do
        if (v.rankId == rankId) then
            index = k
            break
        end
    end

    MsgN(ply," is trying to buy ", rankId, " (Slot ", index, ")")
    if (not Store.Packages[index]) then
        MsgN(ply, " tried to buy an invalid rank")
        return
    end

    if not ply.rankInventory then
        ply.rankInventory = {}
    end

    local cost = ply:GetStoreDiscount(rankId)
    if (cost == 0) then
        cost = Store.Packages[index].cost
    end
    if (not ply:CanAffordStoreCredits(cost)) then
        MsgN(ply, " cannot afford rank costing ", cost)
        return
    end

    if ((!ply.donationCanBuy and ply.donationCanBuy != index) and Store.Packages[index].limited and os.time() > Store.Packages[index].limited) then
        print("can't purchase. expired.")

        return
    end

    table.insert(ply.rankInventory, rankId)
    if (ply.donationCanBuy) then
        local query = "UPDATE users SET donator_tier=0 WHERE steam_account_id='" .. ply:AccountID() .. "';"
        asapMarket.query(query)
        ply.donationCanBuy = nil
    end

    ply:AddStoreCredits(-cost)
    Store.Database:SaveTiers(ply)
    
    local sql = [[
        UPDATE users
        SET credits = :credits,
        old_credits = :oldcredits
        WHERE steam_account_id = :aid
      ]]
    sql = sql:Replace(":aid", ply:AccountID())
    sql = sql:Replace(":credits", ply:GetStoreCredits())
    sql = sql:Replace(":oldcredits", ply._oldCredits or 0)

    ASAPDriver:MySQLQuery(sql, function()
        MsgN("Rank has been updated!")
    end)

    Store.Packages[index].onUnlock(ply, Store.Packages[index], cost)
    DonationRoles:NetworkAll(ply)
    discordLog(ply, Store.Packages[index].title, Store.Packages[index].cost)
    Store.Webhook(ply, Store.Packages[index].title, "EUR " .. cost / 100, Store.Packages[index].hasCustomJob)
    MsgN(ply, " has bought a rank!")
end)

net.Receive("Store.TradePoints", function(l, ply)
    local am = net.ReadInt(16)
    local ent = net.ReadEntity()
    local ocredit = ply._oldCredits or 0

    if (ply:GetStoreCredits() >= (am - ocredit) and am >= 600) then
        ply._tradingcredits = true
        ply:AddStoreCredits(-am)
        ply._tradingcredits = true
        ent:AddStoreCredits(am)
        DarkRP.notify(ent, 0, 10, ply:Nick() .. " sent you " .. am .. " points!")
        MsgN("[STORE] ", ply:Nick() .. " (" .. ply:SteamID64() .. ") sent ", am, " credits to ", ent:Nick() .. " (" .. ent:SteamID64() .. ")")
        hook.Run("playerGaveCredits", ply, ent, am)
    end
end)