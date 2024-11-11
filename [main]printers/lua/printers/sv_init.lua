util.AddNetworkString("Nebula.Printers:RequestMoney")
util.AddNetworkString("Nebula.Printers:UpdateState")
util.AddNetworkString("Nebula.Printers:DoUpgrade")
util.AddNetworkString("Nebula.Printers:ToggleFans")

net.Receive("Nebula.Printers:UpdateState", function(l, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    if ply:GetEyeTrace().Entity ~= ent then
        ply:addWarning("Attempting to set state on a printer they are not near.", WARNING_MEDIUM, debug.traceback())

        return
    end

    ent:UpdateState(not ent:GetIsOn(), ply)
end)

net.Receive("Nebula.Printers:DoUpgrade", function(l, ply)
    local ent = net.ReadEntity()
    local upgrade = net.ReadUInt(3)
    if not IsValid(ent) then return end
    if ent:Getowning_ent() ~= ply then return end
    local data = NebulaPrinters.Upgrades[upgrade]

    if data then
        if not ply:canAfford(data.Price) then
            DarkRP.notify(ply, 1, 4, "You can't afford this upgrade.")

            return
        end

        if ent[data.Get](ent) >= NebulaPrinters:GetMaxUpgrade(ply, upgrade) then
            DarkRP.notify(ply, 1, 4, "You can't upgrade this printer any further.")

            return
        end

        ply:addMoney(-data.Price)
        data.func(ent)
    end
end)

net.Receive("Nebula.Printers:ToggleFans", function(l, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end

    if ply:GetEyeTrace().Entity ~= ent then
        ply:addWarning("Attempting to set state on a printer they are not near.", WARNING_MEDIUM, debug.traceback())

        return
    end

    ent:ToggleFans()
end)

net.Receive("Nebula.Printers:RequestMoney", function(l, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    if (ply:IsDueling()) then return end

    if ply:GetEyeTrace().Entity ~= ent then
        ply:addWarning("Attempting to request money on a printer they are not near.", WARNING_HIGH, debug.traceback())

        return
    end

    if ent:GetMoney() < NebulaPrinters.Config.MinimumRequired then
        DarkRP.notify(ply, 1, 4, "This printer doesn't have enough money to withdraw.")

        return
    end

    local money = ent:GetMoney()
    if ply.doubleprintermoney == true then
        money = money * 2
    end
    local xp = math.ceil(money / 2500)  -- Adjust the divisor to set the desired proportion

    ply:addMoney(money)
    ply:GobbleAddXP(xp, "Withdrawn Money")

    hook.Run("ASAPPrinters.WithdrawMoney", ply, ent, money, xp)
    DarkRP.notify(ply, 2, 5, "You have taken " .. DarkRP.formatMoney(money) .. " from the printer.")
    ent:SetMoney(0)
    ent:EmitSound("buttons/bell1.wav")

    -- Probability of obtaining upgrade kit 6
    local upgradeKitChance = 0
    if money >= 100000 and money < 1000000 then
        upgradeKitChance = 1
    elseif money >= 1000000 and money < 2500000 then
        upgradeKitChance = 4
    elseif money >= 5000000 and money < 10000000 then
        upgradeKitChance = 10
    elseif money >= 10000000 then
        upgradeKitChance = 20
    end

    if upgradeKitChance > 0 and math.random(100) <= upgradeKitChance then
        -- Player receives the upgrade kit
        ply:UB3AddItem(itemNumber, 1168)
        DarkRP.notify(ply, 2, 5, "You have obtained an upgrade kit!")
    end
end)