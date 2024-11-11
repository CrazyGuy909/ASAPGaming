function DonationRoles.Database:SavePlayer(ply, tier, visual, saveInv)
    ASAPDriver:MySQLUpdate("users", {
        donator_tier = tier == 0 and "NULL" or tier,
        donator_visual = visual == 0 and "NULL" or visual,
        donator_tier_inv = util.TableToJSON(ply.rankInventory)
    }, "steam_account_id = " .. ply:AccountID(), function()
        print("Saved " .. ply:Nick() .. "'s rank data.")
    end)
end

function DonationRoles.Database:GetPlayer(ply, callback)
    if not IsValid(ply) then return end

    ASAPDriver:MySQLSelect("users", "steam_account_id=" .. ply:AccountID(), function(result)
        local tier, visual = 0, 0
        ply.rankInventory = {}

        local data = result[1]
        if not data then

            local name = ply:Nick()
            name = string.gsub(name, "'", "''")
            name = string.gsub(name, '"', '')

            data = {
                steam_account_id = ply:AccountID(),
                donator_tier_inv = util.TableToJSON(ply.rankInventory),
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

        if (not data.donator_tier_inv or data.donator_tier_inv == "[]") and data.donator_tier then
            tier = tonumber(data.donator_tier:sub(6))
            ply.rankInventory = {tier}
            ASAPDriver:MySQLUpdate("users", {
                donator_tier_inv = util.TableToJSON(ply.rankInventory)
            }, "steam_account_id = " .. ply:AccountID(), function()
                print("Updated " .. ply:Nick() .. "'s rank data.")
            end)
        end

        if data.donator_tier_inv then
            ply.rankInventory = util.JSONToTable(data.donator_tier_inv or "[]")
            net.Start("DonationRoles.SendInventory" )
            net.WriteUInt(#ply.rankInventory, 4)

            for k, v in pairs(ply.rankInventory) do
                net.WriteUInt(v, 4)
            end

            net.Send(ply)
        end

        if data.donator_tier then
            tier = tonumber(data.donator_tier)
            visual = tier
        end

        if data.donator_visual then
            visual = tonumber(data.donator_visual)
        end

        callback(tier, visual, newData)
    end)
end