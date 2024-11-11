util.AddNetworkString("Store.BroadcastUpdate")
util.AddNetworkString("Store.SpawnEffect")

function Store:PlayerInitialSpawn(ply)
    timer.Simple(3, function()
        timer.Simple(10, function()
            net.Start("Store.BroadcastUpdate")

            for k, v in pairs(player.GetAll()) do
                net.WriteBool(true)
                net.WriteUInt(v:EntIndex(), 16)
                net.WriteUInt(v:GetStoreCredits(), 32)
            end

            net.WriteBool(false)
            net.Send(ply)
        end)

        self.Database:GetCredits(ply, function(credits, oldcredits)
            if not IsValid(ply) then return end
            ply:SetStoreCredits(credits, true)

            timer.Simple(3, function()
                if not IsValid(ply) then return end

                if oldcredits > 0 then
                    ply._oldCredits = oldcredits
                    net.Start("Store.SyncOldCredits")
                    net.WriteInt(ply._oldCredits, 32)
                    net.Send(ply)
                end

                net.Start("Store.SyncCredits")
                net.WriteEntity(ply)
                net.WriteUInt(credits, 32)
                net.Broadcast()
            end)
        end)

        self.Database:GetWeapons(ply, function(tbl)
            if not IsValid(ply) then return end
            local wepTbl = {}
            local equippedTbl = {}

            for i, v in pairs(tbl) do
                wepTbl[v.ent] = true

                if tonumber(v.equipped) == 1 then
                    equippedTbl[v.ent] = true

                    if type(v.ent) == "string" then
                        local wep = ply:Give(v.ent)

                        if wep and IsValid(wep) then
                            wep.isPerm = true
                        end
                    end
                end
            end

            timer.Simple(3, function()
                if not IsValid(ply) then return end
                ply:SetPermanentWeapons(wepTbl)
                ply:SetActivePermanentWeapons(equippedTbl)
            end)
        end)
    end)
end

hook.Add("PlayerInitialSpawn", "Store", function(ply)
    Store:PlayerInitialSpawn(ply)
end)

hook.Add("OnPlayerChangedTeam", "Store.SaveJob", function(ply, bef, aft)
    if not ply._defaultTeam and RPExtraTeams[aft].category == "Private Jobs" then
        ply:SetPData("Default.Class", aft)
        ply._defaultTeam = aft
    end
end)

function Store.Webhook(ply, packageName, cost, ping)
    local sid64 = ply:SteamID64()
    local time = os.date("%Y/%m/%d - %H:%M:%S", os.time())
    local content = [[
**]] .. time .. [[**  

Package: ]] .. packageName .. [[ (cost: ]] .. cost .. [[) 
SteamID64: ]] .. sid64 .. [[ 
SteamID: ]] .. ply:SteamID() .. [[ 
Name at time of purchase: ]] .. ply:Nick() .. [[ 
Steam Profile: https://steamcommunity.com/profiles/]] .. sid64

    if ping then
        content = content .. [[

<@!634050386508120064>
]]
    end

    http.Post("https://discord.com/api/webhooks/1226983078015012954/wcG2UpDXKCQ9fTHi37axbUFruzNNhEhNhvHIhbMjGm5nPLgsQQamF4rKy4oyhi4DssIu", {
        content = content
    })
end

hook.Add("PlayerSay", "Store.PlayerSay", function(ply, text)
    for i, v in pairs(Store.ChatCommands) do
        if text:find(i) then
            net.Start("Store.OpenMenu")
            net.Send(ply)
            break
        end
    end
end)

concommand.Add("store_addcredits", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsUserGroup("owner") then
        ply:ChatPrint("Only for CandyApple, scrubs")
    end

    local steamid = args[1]:Replace("'", "")
    local amt = args[2]
    file.Append("donation_hystory.txt", util.DateStamp() .. "Starting donation: " .. (steamid or 0) .. " " .. (amt or 0) .. "\n")

    if not steamid then
        MsgN("You need to provide a SteamID")
        file.Append("donation_hystory.txt", "Not valid steamid! " .. cmd .. "\n")

        return
    end

    if not amt then
        MsgN("You need to provide an amount")
        file.Append("donation_hystory.txt", "Not valid amount! " .. cmd .. "\n")

        return
    end

    local target = player.GetBySteamID(steamid) or player.GetBySteamID64(steamid)

    if not IsValid(target) then
        file.Append("donation_hystory.txt", "Not valid player present! " .. cmd .. "\n")
        MsgN("No target, online players only")

        return
    end

    target:AddStoreCredits(tonumber(amt))
    target:ChatPrint("<rainbow=2>You've been given " .. amt .. " tokens!!</rainbow>")
    file.Append("donation_hystory.txt", "Successfully bought tokens!\n")
    net.Start("Store.SyncCredits")
    net.WriteUInt(target:GetStoreCredits(), 32)
    net.Send(target)
    ASAPDriver:MySQLQuery("UPDATE users SET total_credits=total_credits + " .. amt .. " WHERE steam_Account_id=" .. ply:AccountID())
end)

concommand.Add("store_purchaserank", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsUserGroup("owner") then
        ply:ChatPrint("Only for CandyApple, scrubs")
    end

    local steamid = args[1]
    local id = tonumber(args[2] or 0)

    if not steamid then
        MsgN("You need to provide a SteamID")

        return
    end

    if not id or not Store.Packages[id] then
        MsgN("You need to provide a valid package id")

        return
    end

    local target = player.GetBySteamID(steamid)

    if not target then
        MsgN("No target, online players only")

        return
    end

    Store.Packages[id].onUnlock(target)
    target:ChatPrint("<rainbow=3>You've been given rank " .. Store.Packages[id].title .. ", enjoy!!</rainbow>")
end)

local cacheRanks = {}

hook.Add("OnSpawnSelected", "Store.PlayerSpawn", function(ply)
    local target = ply.donatorVisual or ply.donator
    if target == 0 then return end

    if not cacheRanks[target] then
        for k, v in pairs(Store.Packages) do
            if v.rankId == target then
                cacheRanks[target] = v
                break
            end
        end
    end

    if cacheRanks[target] and cacheRanks[target].onSpawn then
        cacheRanks[target].onSpawn(ply)
    end
end)