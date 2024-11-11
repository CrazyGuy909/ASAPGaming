util.AddNetworkString("DonationRoles.NetworkPlayer")
util.AddNetworkString("DonationRoles.NetworkAll")
util.AddNetworkString("DonationRoles.RequestRoles")
util.AddNetworkString("DonationRoles.NetworkAvailable")
util.AddNetworkString("DonationRoles.SendInventory")
util.AddNetworkString("DonationRoles.SelectTitle")

function DonationRoles:NetworkPlayer(ply, tier, visual)
    net.Start("DonationRoles.NetworkPlayer")
    net.WriteEntity(ply)
    net.WriteUInt(tier, 8)
    net.WriteUInt(visual, 8)
    net.Broadcast()
end

function DonationRoles:NetworkAll(ply)
    local tbl = {}

    for i, v in pairs(player.GetAll()) do
        if (not v:IsDonator(1)) then continue end
        tbl[v] = {v.donator or 0, v.donatorVisual or 0}
    end

    net.Start("DonationRoles.NetworkAll")
    net.WriteUInt(table.Count(tbl), 8)
    for pl, rank in pairs(tbl) do
        net.WriteEntity(pl)
        net.WriteUInt(rank[1], 8)
        net.WriteUInt(rank[2], 8)
    end
    net.Send(ply)
end

net.Receive("DonationRoles.RequestRoles", function(l, ply)
    if (ply.requestDonators) then return end
    ply.requestDonators = true
    DonationRoles:NetworkAll(ply)
end)

net.Receive("DonationRoles.SelectTitle", function(l, ply)
    local isVisual = net.ReadBool()
    local rankID = net.ReadUInt(4)

    if not table.HasValue(ply.rankInventory, rankID) then
        ply:ChatPrint("<color=red>You do not own one of these ranks!</color>")
        return
    end

    ply[isVisual and "donatorVisual" or "donator"] = rankID
    DonationRoles.Database:SavePlayer(ply, ply.donator, ply.donatorVisual)
    DonationRoles:NetworkPlayer(ply, ply.donator, ply.donatorVisual)

    local count = 0
    for k, v in pairs(ents.FindByClass("asap_money_printer")) do
        if (v:Getowning_ent() == ply) then
            count = count + 1
            if count >= 3 then
                v:Remove()
            end
        end
    end
end)