local function prepareCredits(ent, credits, tries)
    if tries and tries < 0 then return end

    if not IsValid(ent) then
        timer.Simple(1, function()
            prepareCredits(ent, credits, (tries or 6) - 1)
        end)

        return
    end

    ent:SetStoreCredits(credits)
end

net.Receive("Store.SyncCredits", function(len)
    local ent = net.ReadEntity()
    local credits = net.ReadUInt(32)
    prepareCredits(ent, credits)
end)

net.Receive("Store.BroadcastUpdate", function()
	while (net.ReadBool() == true) do
		prepareCredits(net.ReadUInt(16), net.ReadUInt(32))
	end
end)

net.Receive("Store.PermanentWeapons", function(len)
    LocalPlayer():SetPermanentWeapons(net.ReadTable())
end)

net.Receive("Store.PermanentWeapon", function(len)
    LocalPlayer():AddPermanentWeapon(net.ReadString())
end)

net.Receive("Store.ActivePermanentWeapons", function(len)
    LocalPlayer():SetActivePermanentWeapons(net.ReadTable())
end)

net.Receive("Store.BoughtCredits", function(len, ply)
    local credits = net.ReadUInt(32)
    XeninUI:Notify("Your tokens has been updated from the database, your current tokens are now " .. credits, LocalPlayer(), 15, XeninUI.Theme.Green)
    prepareCredits(LocalPlayer():EntIndex(), credits)
end)

net.Receive("Store.OpenMenu", function(len)
    LocalPlayer():ConCommand("store")
end)