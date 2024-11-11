include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
SWEP.Base = "weapon_base"
util.AddNetworkString("BU3:RequestEquipment")
util.AddNetworkString("BU3:RequestPickup")

function SWEP:PrimaryAttack()
    if self:GetOwner():InArena() or self:GetOwner():IsDueling() then
        self:Remove()
        return
    end

    local tr = util.TraceLine({
        start = self:GetOwner():EyePos(),
        endpos = self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 128,
        filter = self:GetOwner()
    })

    local ent = tr.Entity
    if not IsValid(ent) then return end
    /*
    if ent:GetClass() == "spawned_shipment" then
        local class = CustomShipments[ent:Getcontents()].entity
        local amount = ent:Getcount()
        local item = BU3.Dictionary[class]

        if not item then
            for k, v in pairs(BU3.Items.Items) do
                if class == v.className then
                    item = v.itemID
                    break
                end
            end
        end

        if item and not ent.IsTook then
            ent.IsTook = true
            self:GetOwner():UB3AddItem(item, amount)
            self:GetOwner():EmitSound("items/ammocrate_open.wav")
            ent:Remove()
            if (asapLogs.add) then
                asapLogs:add("Item Pickup", self:GetOwner(), nil, item)
            end
        end

        return
    end
    */

    if not (ent:IsWeapon() or string.StartWith(ent:GetClass(), "armor")) and ent:GetClass() ~= "spawned_weapon" then return end
    local isWeapon = ent:IsWeapon() or string.StartWith(ent:GetClass(), "armor")
    local item = isWeapon and BU3.Dictionary[ent:GetClass()] or BU3.Dictionary[ent.GetWeaponClass and ent:GetWeaponClass() or ent:GetClass()]
    local amount = isWeapon and 1 or ent:Getamount() or 1

    if not item then
        local ownClass = isWeapon and ent:GetClass() or ent:GetWeaponClass()

        for k, v in pairs(BU3.Items.Items) do
            if ownClass == v.className then
                item = v.itemID
                break
            end
        end
    end

    if item and not ent.IsTook and not ent.CannotPickup then
        ent.IsTook = true
        if (ent.IsTainted) then
            hook.Run("OnSuitStole", ply, "", ent)
        end
        self:GetOwner():UB3AddItem(item, amount)
        self:GetOwner():EmitSound("items/ammocrate_open.wav")
        DarkRP.notify(self:GetOwner(), 0, 4, "You've picked up <defc=red>" .. BU3.Items.Items[item].name)
        ent:Remove()
    end
end

function SWEP:SecondaryAttack()
    if self:GetOwner():InArena() or self:GetOwner():IsDueling() then
        self:Remove()
    end
    return
end

net.Receive("BU3:RequestEquipment", function(l, ply)
    if ply.lastAsk and ply.lastAsk > CurTime() then
        net.Start("BU3:RequestEquipment")
        net.Send(ply)

        return
    end

    ply.lastAsk = CurTime() + 2
    local sendTable = {}
    net.Start("BU3:RequestEquipment")

    for k, v in pairs(ply:GetWeapons()) do
        if v.ItemID then
            local canDrop = hook.Call("canDropWeapon", GAMEMODE, ply, v)
            if not canDrop then continue end
            sendTable[v.ItemID] = v
        end
    end

    net.WriteUInt(table.Count(sendTable), 8)

    for id, ent in pairs(sendTable) do
        net.WriteEntity(ent)
        net.WriteUInt(ent.ItemID or 0, 16)
    end

    net.Send(ply)
end)

net.Receive("BU3:RequestPickup", function(l, ply)
    local canPickup, reason = hook.Run("CanPickupInventory", ply)

    if canPickup == false then
        DarkRP.notify(ply, 2, 5, reason or "You cannot pickup any item right now")

        return
    end

    local isWeapon = net.ReadBool()

    if ply.battleTag and ply.battleTag > CurTime() then
        DarkRP.notify(ply, 0, 5, "You have to wait " .. math.Round(ply.battleTag - CurTime()) .. " seconds to pickup this")

        return
    end

    if ply:GetMoveType() == MOVETYPE_NONE or ply:HasGodMode() then
        DarkRP.notify(ply, 1, 5, "You cannot holster anything now")

        return
    end

    if not isWeapon then
        local ent = net.ReadEntity()
        local canDrop = hook.Call("canDropWeapon", GAMEMODE, ply, ent)
        if not canDrop then return end

        if IsValid(ent) and ent:GetOwner() == ply and (ent.ItemID or ent.armorEquipped) then
            local id = ent.ItemID

            http.Post(asapMarket.API .. "/eq/take", {
                id = ply:SteamID64(),
                take = ent:GetClass()
            })

            ply:StripWeapon(ent:GetClass())
            ply:UB3AddItem(id, 1)
        end
    else
        local id = net.ReadUInt(16)
        local armor = Armor:Get(ply.armorEquipped)
        local suit = BU3.Items.Items[id].className == armor.Entitie
        
        if (suit) then
            DarkRP.notify(ply, 1, 5, "Your suit will be sent to your inventory in 5 seconds!")
            net.Start("ASAP.Suits:ShowDropSuit")
            net.WriteUInt(5, 4)
            net.Send(ply)

            ply:Wait(5, function()
                if not IsValid(ply) or not ply.armorEquipped then return end
                armor = Armor:Get(ply.armorEquipped)
                suit = BU3.Items.Items[id].className == armor.Entitie
                if IsValid(ply) and suit then
                    if ply:GetMoveType() == MOVETYPE_NONE or ply:HasGodMode() then
                        DarkRP.notify(ply, 1, 5, "You cannot holster anything now")

                        return
                    end

                    http.Post(asapMarket.API .. "/eq/take", {
                        id = ply:SteamID64(),
                        take = "1"
                    })

                    ply:removeArmorSuit()
                    ply.armorEquipped = nil
                    ply:UB3AddItem(id, 1)
                end
            end)
        end
    end
end)