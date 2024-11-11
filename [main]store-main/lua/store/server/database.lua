hook.Add("DatabaseInitialized", "CreateStoreDB", function()
    ASAPDriver:MySQLQuery([[
        CREATE TABLE IF NOT EXISTS xenin_permanent_weapons (
          sid64 BIGINT(21),
          ent VARCHAR(50),
          equipped SMALLINT(1) NOT NULL DEFAULT 0,
          CONSTRAINT weapon_pk
            PRIMARY KEY (sid64, ent)
        )
    ]])
end)

function Store.Database:SaveCredits(ply, amt)
    if not IsValid(ply) then return end

    local sql = [[
        UPDATE users
        SET credits = credits + :credits,
        old_credits = :oldcredits
        WHERE steam_account_id = :aid
      ]]
    sql = sql:Replace(":aid", ply:AccountID())
    sql = sql:Replace(":credits", amt)
    sql = sql:Replace(":oldcredits", ply._oldCredits or 0)

    ASAPDriver:MySQLQuery(sql)
end

concommand.Add("save_credits", function(ply, cmd, args)
    if not args[1] or not tonumber(args[2]) then
        print("Usage: save_credits <SteamID64> <Amount>")
        return
    end

    local steamid64 = args[1]
    local amt = tonumber(args[2])

    local targetPlayer = player.GetBySteamID64(steamid64)
    if not IsValid(targetPlayer) then
        print("Player with SteamID64 " .. steamid64 .. " not found.")
        return
    end

    Store.Database:SaveCredits(targetPlayer, amt)
    print("Credits saved for player with SteamID64: " .. steamid64 .. ", Amount: " .. amt)
end)

function Store.Database:SaveTiers(ply)
    if not IsValid(ply) then return end
    ASAPDriver:MySQLUpdate("users", {
        donator_tier_inv = util.TableToJSON(ply.rankInventory),
    }, "steam_account_id=" .. ply:AccountID())
end

function Store.Database:GetCredits(ply, callback)
    if not ply then return end
    callback = callback or function() end

    ASAPDriver:MySQLSelect("users", "steam_account_id=" .. ply:AccountID(), function(result)
        local data = result[1]
        if not result[1] then
            local name = ply:Nick()
            name = string.gsub(name, "'", "''")
            name = string.gsub(name, '"', '')

            data = {
                steam_account_id = ply:AccountID(),
                credits = 0,
                old_credits = 0,
                total_credits = 0,
                slug = ply:SteamID64(),
                name = "'" .. name .. "'"
            }
            ASAPDriver:MySQLInsert("users", data, function()
                print("Created " .. ply:Nick() .. "'s rank data.")
            end)
        end

        callback(tonumber(data.credits or 0), tonumber(data.old_credits or 0))
    end)
end

function Store.Database:SaveWeapon(ply, ent, equipped)
    if not ply then return end
    local sid64 = ply:SteamID64()
    ASAPDriver:MySQLQuery("SELECT * FROM xenin_permanent_weapons WHERE sid64=" .. sid64 .. " AND ent='" .. ent .. "'", function(data)
        if (data and data[1]) then
            ASAPDriver:MySQLQuery("UPDATE xenin_permanent_weapons SET equipped=" .. (equipped and 1 or 0) .. " WHERE sid64=" .. sid64 .. " AND ent='" .. ent .. "';")
            return
        end
        ASAPDriver:MySQLQuery("INSERT INTO xenin_permanent_weapons (sid64, ent, equipped) VALUES (" .. sid64 .. ", '" .. ent .. "', " .. (equipped and 1 or 0) .. ");")
    end)
end

function Store.Database:RemoveWeapon(ply, ent)
    if not ply then return end
    local sid64 = ply:SteamID64()
    local sql = [[
	DELETE FROM xenin_permanent_weapons
	WHERE sid64 = :sid64
	  AND ent = ':ent'
  ]]
    sql = sql:Replace(":sid64", sid64)
    sql = sql:Replace(":ent", ent)
    ASAPDriver:MySQLQuery(sql)
end

function Store.Database:GetWeapons(ply, callback)
    if not ply then return end
    local sid64 = ply:SteamID64()
    ASAPDriver:MySQLSelect("xenin_permanent_weapons", "sid64=" .. sid64, function(data)
        callback(data)
    end)
end

function Store:CheckCredits(ply)
    if not ply then return end
    local credits = ply:GetStoreCredits()

    self.Database:GetCredits(ply, function(dbCredits)
        if (credits ~= dbCredits) then
            net.Start("Store.BoughtCredits")
            net.WriteUInt(dbCredits, 32)
            net.Send(ply)
            ply:SetStoreCredits(dbCredits, true)
        end
    end)
end

function Store.Database:PollPlayerCredits()
    for i, v in pairs(player.GetAll()) do
        if (not IsValid(v)) then continue end
        Store:CheckCredits(v)
    end
end

timer.Create("Store.PollCredits", 15, 0, function()
    Store.Database:PollPlayerCredits()
end)