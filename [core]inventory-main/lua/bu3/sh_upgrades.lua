BU3.Upgradables = {}

BU3.Upgradables["6"] = {
    Materials = {
        ["6"] = 10,
    },
    Price = 50000
}

BU3.Upgradables["6"] = {
    Materials = {
        ["6"] = 10,
    },
    Price = 200000
}

BU3.Upgradables["6"] = {
    Materials = {
        ["6"] = 10,
    },
    Price = 2000000
}

BU3.Upgradables["6"] = {
    Materials = {
        ["6"] = 10,
    },
    Price = 25000000
}

function BU3:LoadUpgrades()
    timer.Simple(5, function()
        for id, v in pairs(BU3.Upgradables) do
            local data = Armor:GetByID(id)
            if not data then continue end
            v.Name = data.Name

            for item_id, item in pairs(BU3.Items.Items) do

                if (item.className == id) then
                    v.ItemID = item_id
                end
            end
        end
    end)
end

BU3.UpgradesDictionary = BU3.UpgradesDictionary or {}
function BU3:CanUpgrade(ply, suit)
    local canCraft = true
    for req, am in pairs(suit.Materials) do
        if (string.StartWith(req, "armor")) then
            if (not self.UpgradesDictionary[req]) then
                for _, item in pairs(BU3.Items.Items) do
                    if (item.className == req) then
                        self.UpgradesDictionary[req] = item
                        break
                    end
                end
            end

            if ((CLIENT and BU3.Inventory.Inventory or ply._ub3inv)[self.UpgradesDictionary[req].itemID] < am) then
                canCraft = false

                return
            end
        else
            if (not ply.miningInfo or not ply.miningInfo.minerals) then
                canCraft = false

                return
            end

            if ((ply.miningInfo.minerals[req] or 0) < am) then
                canCraft = false

                return
            end
        end
    end

    return canCraft
end

BU3:LoadUpgrades()