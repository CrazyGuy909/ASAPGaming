net.Receive("DonationRoles.NetworkAvailable", function()
    donationAllowedRank = net.ReadUInt(4)
end)

donationInventory = donationInventory or {}

net.Receive("DonationRoles.SendInventory", function()
    donationInventory = {}
    for k = 1, net.ReadUInt(4) do
        table.insert(donationInventory, net.ReadUInt(4))
    end
end)

net.Receive("DonationRoles.NetworkPlayer", function(len)
    local ply = net.ReadEntity()
    local donator = net.ReadUInt(8)
    local donatorVisual = net.ReadUInt(8)

    if (IsValid(ply)) then
        ply:SetDonator(donator, donatorVisual)
    end
end)

local waitingPlayers = {}

net.Receive("DonationRoles.NetworkAll", function(len)
    local count = net.ReadUInt(8)

    for i = 1, count do
        local pl = net.ReadUInt(16)
        local donator, visual = net.ReadUInt(8), net.ReadUInt(8)
        local entity = Entity(pl)
        if IsValid(entity) and entity:IsPlayer() then
            if entity.SetDonator then
                entity:SetDonator(donator, visual)
			end
        else
            waitingPlayers[pl] = {donator, visual}
        end
    end
end)

hook.Add("OnEntityCreated", "ASAP.RelayDonators", function(ent)
    if (ent:IsPlayer() and waitingPlayers[ent]) then
        timer.Simple(0, function()
            ent:SetDonator(waitingPlayers[ent][1], waitingPlayers[ent][2])
            waitingPlayers[ent] = nil
        end)
    end
end)

hook.Add("OnSelectSpawn", "ASAP.RequestDonations", function()
    timer.Simple(5, function()
        net.Start("DonationRoles.RequestRoles")
        net.SendToServer()
    end)
end)