util.AddNetworkString("Upgrades.Craft")


net.Receive("Upgrades.Craft", function(l, ply)
    local id = net.ReadString()
    local suit = BU3.Upgradables[id]

    if (suit and not suit.ItemID) then
        BU3:LoadUpgrades()
    end

    local canCraft = BU3:CanUpgrade(ply, suit)
    if (canCraft) then
        local sentMineral = false
        for k, v in pairs(suit.Materials) do
            if string.StartWith(k, "armor") then
                ply:UB3RemoveItem(BU3.UpgradesDictionary[k].itemID, 1)
            else
                ply.miningInfo.minerals[k] = ply.miningInfo.minerals[k] - v
                sentMineral = true
            end
        end
        if sentMineral then
            ply:sendMiningInfo()
            ply:saveMiningInfo()
        end
        ply:addMoney(-suit.Price)
        ply:UB3AddItem(suit.ItemID, 1)
    end
end)