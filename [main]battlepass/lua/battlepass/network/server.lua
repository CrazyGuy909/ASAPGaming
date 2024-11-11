util.AddNetworkString("BATTLEPASS.TotalSync")
util.AddNetworkString("BATTLEPASS.SyncChallengeProgress")
util.AddNetworkString("BATTLEPASS.BuyPass")
util.AddNetworkString("BATTLEPASS.BuyTier")
util.AddNetworkString("BATTLEPASS.AddTier")
util.AddNetworkString("BATTLEPASS.ClaimItem")
util.AddNetworkString("BATTLEPASS.BuyStore")
util.AddNetworkString("BattlePass.OpenMenu")
util.AddNetworkString("BATTLEPASS.SyncProgress")
util.AddNetworkString("BATTLEPASS.SetProgress")
util.AddNetworkString("BATTLEPASS.RequestClaim")

function BATTLEPASS:AcquireBP(ply, isfree)
    local canBuy = BATTLEPASS:CanBuyPass(ply)
    if not canBuy then return end
    Store.Webhook(ply, "Battle Pass", "EUR 10")
    ply:AddStoreCredits(not isfree and -BATTLEPASS.Config.PassPrice or 0)

    for k = 1, ply:getLevel() do
        if (k % 5 == 0 and ply.bpStage > k) then continue end
        local item = BATTLEPASS.Pass.rewards[k]
        item.func(ply, item)
    end

    BATTLEPASS:SetOwned(ply, true)
end

function BATTLEPASS:GiveRewardTiers(ply, from, to)
    for k = from, to do
        local item = BATTLEPASS.Pass.rewards[k]
        item.func(ply, item)
    end
end

net.Receive("BATTLEPASS.BuyPass", function(len, ply)
    BATTLEPASS:AcquireBP(ply)
end)

net.Receive("BATTLEPASS.BuyTier", function(len, ply)
    local amt = net.ReadUInt(10)
    if not amt or amt <= 0 then return end

    local canBuy = BATTLEPASS:CanBuyTiers(ply, amt)
    if not canBuy then return end

    local currentTier = ply.BattlePass.Owned.tier
    if currentTier + amt > BATTLEPASS.Pass.tiers then return end

    local totalPrice = BATTLEPASS.Config.TierPrice * amt
    if ply:GetStoreCredits() < totalPrice then return end

    ply:AddStoreCredits(-totalPrice)
    
    -- Increment the player's level
    local currentLevel = ply:getDarkRPVar("level") or 0
    local newLevel = currentLevel + 1
    ply:setDarkRPVar("level", newLevel)

    BATTLEPASS:AddTier(ply, amt)
end)

net.Receive("BATTLEPASS.ClaimItem", function(len, ply)
    BATTLEPASS:ClaimItem(ply)
end)

net.Receive("BATTLEPASS.RequestClaim", function(l, ply)
    if not ply.canClaimBPReward then return end

    for k, v in pairs(BATTLEPASS.Pass.newplayer) do
        ply:UB3AddItem(v, 1)
    end
    ply.canClaimBPReward = nil
    ply:SendLua("canClaimBPReward = nil")
    BATTLEPASS.Database:SavePlayer(ply)

end)

concommand.Add("asap_unlockbp", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsUserGroup("owner") then
        ply:ChatPrint("Only for CandyApple, scrubs")
    end

    local steamid = args[1]
    local target = player.GetBySteamID(steamid)

    if not target then
        MsgN("No target, online players only")

        return
    end

    target:ChatPrint("<rainbow=4>Congratulations, you've acquired battlepass!</rainbow>")
    target:SendLua("BATTLEPASS:SetOwned(LocalPlayer(), true)")
    BATTLEPASS:SetOwned(target, true)
end)

net.Receive("BATTLEPASS.BuyStore", function(l, ply)
    local category = net.ReadString()
    local slot = net.ReadUInt(7)
    local tokens = ply.bpTokens or 0
    local storeCategory = BATTLEPASS.TokenStore[category]

    if not storeCategory then
        MsgN("[BP] No store category")

        return
    end

    if not storeCategory.Items[slot] then
        MsgN("[BP] No store slot")
        PrintTable(storeCategory)

        return
    end

    if ply:getLevel(true) + 1 < storeCategory.Progression then
        MsgN(ply:getLevel(true), " ", storeCategory.Progression)
        MsgN("[BP] Tier level too below")

        return
    end

    local item = storeCategory.Items[slot]

    if tokens < item.price then
        ply:ChatPrint("You don't have enough tokens to buy this item!")

        return
    end

    if item.max then
        ply.bpClaimed = ply.bpClaimed or {}

        if (ply.bpClaimed[item.item] or 0) >= item.max then
            ply:ChatPrint("You've already claimed this item the maximum amount of times!")

            return
        end

        ply.bpClaimed[item.item] = (ply.bpClaimed[item.item] or 0) + 1
    end

    ply:UB3AddItem(item.item, 1)
    ply.bpTokens = tokens - item.price
    local name = BU3.Items.Items[item.item].name
    ply:ChatPrint("<color=orange>[BP]</color>You've bought <rainbow=3>" .. name .. "</rainbow> for <color=green>" .. item.price .. "</color> tokens!")
    net.Start("BATTLEPASS.BuyStore")
    net.WriteUInt(ply.bpTokens, 16)
    net.WriteUInt(item.item, 24)
    net.WriteUInt(ply.bpClaimed[item.item] or 0, 8)
    net.Send(ply)
    BATTLEPASS.Database:SavePlayer(ply)
end)

concommand.Add("transfer_shit_to_money_db", function(ply)
    if IsValid(ply) then return end
    local conn = MySQLite
    local steamIds = {}
    local query = "SELECT * FROM batm_personal_accounts"
    local moneyQuery = "UPDATE darkrp_player SET wallet = wallet + :wallet WHERE uid = :uid"
    local startTime = os.time() + 3

    conn.query(query, function(result)
        print("Found " .. #result .. " results")

        timer.Simple(3, function()
            for i, v in pairs(result) do
                local money = tonumber(util.JSONToTable(v.accountinfo).balance)
                local sid = tostring(v.steamid)
                print("[" .. sid .. "] Retrieving money")
                steamIds[sid] = (steamIds[sid] or 0) + money
            end

            for i, v in pairs(steamIds) do
                print("[" .. i .. "] Adding money " .. DarkRP.formatMoney(v))
                local str = moneyQuery:Replace(":uid", i)
                str = str:Replace(":wallet", v)
                --conn.query(str)
            end

            print("Took " .. math.Round(os.time() - startTime, 4) .. " seconds")
        end)
    end)
end)