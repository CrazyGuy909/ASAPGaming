local function banReasonFormatter(steamid, bandate, unbandate, bannedby, reason)
    local msg = SAM.Default_Config.banmessage
    msg = string.gsub(msg, "{REASON}", tostring(reason))

    if player.GetBySteamID(tostring(bannedby)) then
        bannedby = tostring(player.GetBySteamID(tostring(bannedby)):Name()) .. " (" .. tostring(bannedby) .. ")"
    end

    msg = string.gsub(msg, "{BANNEDBY}", tostring(bannedby))
    msg = string.gsub(msg, "{BANDATE}", tostring(os.date("%H:%M:%S - %d/%m/%Y", bandate)))

    if unbandate == -1 or unbandate == "-1" then
        msg = string.gsub(msg, "{UNBANDATE}", tostring("Never"))
    else
        msg = string.gsub(msg, "{UNBANDATE}", tostring(os.date("%H:%M:%S - %d/%m/%Y", unbandate)))
    end

    return msg
end

function SAM.AddBan(steamid, sender, length, reason)
    local bannedBy = ""

    if sender:IsValid() then
        bannedBy = sender:SteamID()
    else
        bannedBy = "CONSOLE"
    end

    local banTime = os.time()

    SAM.Query("SELECT * FROM " .. SAM.SQLPlayerTableName .. " WHERE steamid = '" .. steamid .. "'", function(data)
        if data[1] then
            if IsValid(sender) then
                local plyRankTable = SAM.GetRankTable(sender:GetUserGroup())
                local targetRankTable = SAM.GetRankTable(data[1].usergroup)

                if SAM.Default_Config.sameweighttargeting then
                    if targetRankTable.weight > plyRankTable.weight then
                        SAM.ShootError(sender, "You cannot ban this person, their rank is higher than yours!")

                        return
                    end
                else
                    if targetRankTable.weight >= plyRankTable.weight then
                        SAM.ShootError(sender, "You cannot ban this person, their rank is higher or equal to yours!")

                        return
                    end
                end
            end

            SAM.Query("SELECT * FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. steamid .. "' AND unbandate >= " .. os.time(), function(datapd)
                local allow_overwrite = false

                if datapd[1] then
                    if SAM.HasPermission(sender, "sam.unban") then
                        allow_overwrite = true
                    end
                else
                    allow_overwrite = true
                end

                if allow_overwrite == true then
                    SAM.Query("DELETE FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. steamid .. "'", function(datap)
                        local unbanDate = -1

                        if length ~= -1 and length ~= "-1" then
                            unbanDate = os.time() + length
                        end

                        if player.GetBySteamID(steamid) then
                            player.GetBySteamID(steamid):Kick(banReasonFormatter(steamid, os.time(), unbanDate, bannedBy, reason))
                        end

                        SAM.Query("INSERT INTO " .. SAM.SQLBanTableName .. " VALUES ('" .. steamid .. "'," .. banTime .. "," .. unbanDate .. ",'" .. bannedBy .. "','" .. reason .. "')")
                    end)
                else
                    SAM.ShootError(sender, "This person is already banned and your rank cannot overwrite bans!")
                end
            end)
        else
            SAM.ShootError(sender, "This person doesn't have data in the player DB, inserting anyways.")
            SAM.Query("DELETE FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. steamid .. "'", function(datap)
                local unbanDate = -1

                if length ~= -1 and length ~= "-1" then
                    unbanDate = os.time() + length
                end

                if player.GetBySteamID(steamid) then
                    player.GetBySteamID(steamid):Kick(banReasonFormatter(steamid, os.time(), unbanDate, bannedBy, reason))
                end

                SAM.Query("INSERT INTO " .. SAM.SQLBanTableName .. " VALUES ('" .. steamid .. "'," .. banTime .. "," .. unbanDate .. ",'" .. bannedBy .. "','" .. reason .. "')")
            end)
        end
    end)
end

function SAM.AddIPBan(ipa, sender, length, reason)
    local bannedBy = ""

    if sender:IsValid() then
        bannedBy = sender:SteamID()
    else
        bannedBy = "CONSOLE"
    end

    local banTime = os.time()

    SAM.Query("DELETE FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. ipa .. "'", function(datap)
        local unbanDate = -1

        if length ~= -1 and length ~= "-1" then
            unbanDate = os.time() + length
        end

        for k, v in pairs(player.GetAll()) do
            if v:IPAddress() == ipa then
                v:Kick(banReasonFormatter(ipa, os.time(), unbanDate, bannedBy, reason))
            end
        end

        SAM.Query("INSERT INTO " .. SAM.SQLBanTableName .. " VALUES ('" .. ipa .. "'," .. banTime .. "," .. unbanDate .. ",'" .. bannedBy .. "','" .. reason .. "')")
    end)
end

function SAM.RemoveBan(steamid)
    SAM.Query("SELECT * FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. steamid .. "'", function(data)
        if data[1] then
            SAM.Query("DELETE FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. steamid .. "'")
        end
    end)
end

local playerCount = -1
gameevent.Listen("player_connect_client")

hook.Add("player_connect_client", "asap_pushplayers", function(data)
    if playerCount == -1 then
        playerCount = player.GetCount()
    end

    playerCount = playerCount + 1
end)

gameevent.Listen("player_disconnect")

hook.Add("player_disconnect", "asap_pushplayers", function(data)
    if playerCount == -1 then
        playerCount = player.GetCount()
    end

    playerCount = playerCount - 1
end)

local visible = 120

local allowed = {
    superadmin = true,
    management = true,
    owner = true,
    dev = true,
    admin = true,
}

local cacheGroup = {}

hook.Add("CheckPassword", "SAM.EnforceBan", function(steamid64, ipa)
    local steamid = util.SteamIDFrom64(steamid64)

    if player.GetCount() >= visible then
        if not cacheGroup[steamid] then
            SAM.Query("SELECT usergroup FROM " .. SAM.SQLPlayerTableName .. " WHERE steamid = '" .. steamid .. "'", function(data)
                if not data[1] or not allowed[data[1].usergroup] then
                    cacheGroup[steamid] = not data[1] and "user" or data[1].usergroup
                    game.KickID(steamid, "Server is full!")
                end
            end)
        elseif not allowed[cacheGroup[steamid]] then
            game.KickID(steamid, "Server is full!")
        end
    end

    SAM.Query("SELECT * FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. steamid .. "'", function(data)
        if data[1] then
            if os.time() > tonumber(data[1].unbandate) and tonumber(data[1].unbandate) ~= -1 then
                SAM.Query("DELETE FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. steamid .. "'")
            else
                local reason = banReasonFormatter(data[1].steamid, data[1].bandate, data[1].unbandate, data[1].bannedby, data[1].reason)
                game.KickID(steamid, reason)
            end
        end
    end)

    SAM.Query("SELECT * FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. ipa .. "'", function(data)
        if data[1] then
            if os.time() > tonumber(data[1].unbandate) and tonumber(data[1].unbandate) ~= -1 then
                SAM.Query("DELETE FROM " .. SAM.SQLBanTableName .. " WHERE steamid = '" .. ipa .. "'")
            else
                local reason = banReasonFormatter(data[1].steamid, data[1].bandate, data[1].unbandate, data[1].bannedby, data[1].reason)
                game.KickID(steamid, reason)
            end
        end
    end)
end)