asapArena.Perks = {{}, {}, {}}

asapArena.Perks[1].Speed = {
    Name = "Sanic",
    Description = "+10% Run Speed",
    Level = 3,
    OnEquip = function(ply)
        if (not ply._preArenaSpeed) then
            ply._preArenaSpeed = ply:GetRunSpeed()
            ply:SetRunSpeed(ply._preArenaSpeed + ply._preArenaSpeed * .1)
        end
    end,
    OnUnequip = function(ply)
        ply:SetRunSpeed(ply._preArenaSpeed or ply:GetRunSpeed() * .9)
        ply._preArenaSpeed = nil
    end
}

asapArena.Perks[1].Mags = {
    Name = "Lots of boolets",
    Description = "Get 2 mags instead one per kill",
    Level = 5,
    OnEquip = function(ply)
        local hookName = ply:SteamID64() .. "_magPerk"

        hook.Add("PlayerDeath", hookName, function(ent, inf, att)
            if not IsValid(ply) then
                hook.Remove("PlayerDeath", hookName)

                return
            end

            if (att == ply) then
                local wep = att:GetActiveWeapon()
                if (IsValid(wep) and wep.GetMaxClip1) then
                    ply:GiveAmmo(wep:GetMaxClip1(), wep:GetPrimaryAmmoType())
                end
            end
        end)
    end,
    OnUnequip = function(ply)
        local hookName = ply:SteamID64() .. "_magPerk"
        hook.Remove("PlayerDeath", hookName)
    end
}

asapArena.Perks[1].Ninja = {
    Name = "Ninja Steps",
    Description = "Your footsteps doesn't make sound",
    Level = 35,
    OnEquip = function(ply)
        ply._arenaFoosteps = true
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaFoosteps")
        net.WriteBool(true)
        net.WriteBool(true)
        net.WriteEntity(ply)
        net.Send(asapArena:GetPlayers())
    end,
    OnUnequip = function(ply)
        ply._arenaFoosteps = false
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaFoosteps")
        net.WriteBool(false)
        net.WriteBool(true)
        net.WriteEntity(ply)
        net.Send(asapArena:GetPlayers())
    end
}

hook.Add("PlayerFootstep", "ASAP.Arena.FP", function(ent, dmg)
    if (not ent:InArena()) then return end
    if (ent._arenaFoosteps) then return true end
end)

asapArena.Perks[2].Healer = {
    Name = "Stronk",
    Description = "Get 35HP per kill instead 25HP",
    Level = 13,
    OnEquip = function(ply)
        local hookName = ply:SteamID64() .. "_healer"

        hook.Add("PlayerDeath", hookName, function(ent, inf, att)
            if not IsValid(ply) then
                hook.Remove("PlayerDeath", hookName)

                return
            end

            if (att == ply) then
                ply:SetHealth(ply:Health() + 10)
            end
        end)
    end,
    OnUnequip = function(ply)
        local hookName = ply:SteamID64() .. "_healer"
        hook.Remove("PlayerDeath", hookName)
    end
}

asapArena.Perks[2].Armored = {
    Name = "Armored",
    Description = "Get 35 Armor per kill instead 25 Armor",
    Level = 9,
    OnEquip = function(ply)
        local hookName = ply:SteamID64() .. "_armor"

        hook.Add("PlayerDeath", hookName, function(ent, inf, att)
            if not IsValid(ply) then
                hook.Remove("PlayerDeath", hookName)

                return
            end

            if (att == ply) then
                ply:SetArmor(ply:Armor() + 10)
            end
        end)
    end,
    OnUnequip = function(ply)
        local hookName = ply:SteamID64() .. "_armor"
        hook.Remove("PlayerDeath", hookName)
    end
}

asapArena.Perks[2].NoRadar = {
    Name = "Ghost",
    Description = "You won't show up on the radar",
    Level = 18,
    OnEquip = function(ply)
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaRadar")
        net.WriteBool(true)
        net.WriteBool(true)
        net.WriteEntity(ply)
        net.Send(asapArena:GetPlayers())
    end,
    OnUnequip = function(ply)
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaRadar")
        net.WriteBool(false)
        net.WriteBool(true)
        net.WriteEntity(ply)
        net.Send(asapArena:GetPlayers())
    end
}

asapArena.Perks[2].DoublePrim = {
    Name = "One Man Army",
    Description = "You can carry 2 primary weapons",
    Level = 15,
    OnEquip = function(ply)
        ply._arenaPrimary = true
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaPrimary")
        net.WriteBool(true)
        net.Send(ply)
    end,
    OnUnequip = function(ply)
        ply._arenaPrimary = false
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaPrimary")
        net.WriteBool(true)
        net.Send(ply)
    end
}

asapArena.Perks[2].DoubleSec = {
    Name = "Small one man army",
    Description = "You can carry 2 secondary weapons",
    Level = 20,
    OnEquip = function(ply)
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaSecondary")
        net.WriteBool(true)
        net.Send(ply)
    end,
    OnUnequip = function(ply)
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaSecondary")
        net.WriteBool(true)
        net.Send(ply)
    end
}

asapArena.Perks[3].Killstreak = {
    Name = "Old Combat Dog",
    Description = "Killstreaks requires 1 less kill to activate",
    Level = 22,
    OnEquip = function(ply)
        ply._arenaDog = true
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaDog")
        net.WriteBool(true)
        net.Send(ply)
    end,
    OnUnequip = function(ply)
        ply._arenaDog = false
        net.Start("ASAP.Arena:Perk")
        net.WriteString("_arenaDog")
        net.WriteBool(false)
        net.Send(ply)
    end
}

asapArena.Perks[3].FallDMG = {
    Name = "Titanium Legs",
    Description = "You don't take fall damage",
    Level = 1,
    OnEquip = function(ply)
        ply._titaniumLegs = true
    end,
    OnUnequip = function(ply)
        ply._titaniumLegs = false
    end
}

asapArena.Perks[3].Helicopter = {
    Name = "Pilot(COMING SOON)",
    Description = "Fulfill your dream of become a helicopter",
    Level = 30,
    OnEquip = function(ply)
        ply._canFlyHelicopter = true
    end,
    OnUnequip = function(ply)
        ply._canFlyHelicopter = false
    end
}

if SERVER then
    util.AddNetworkString("ASAP.Arena:SelectPerk")

    net.Receive("ASAP.Arena:SelectPerk", function(l, ply)
        local level = ply:GetArenaLevel()
        local slot = net.ReadInt(3)
        local id = net.ReadString()
        if not asapArena.Perks[slot][id] then return end

        if (level >= asapArena.Perks[slot][id].Level) then
            if not ply._arenaEquipment.Perks then
                ply._arenaEquipment.Perks = {}
            elseif (ply._arenaEquipment.Perks[slot]) then
                asapArena.Perks[slot][ply._arenaEquipment.Perks[slot]].OnUnequip(ply)
            end

            ply._arenaEquipment.Perks[slot] = id
            asapArena.Perks[slot][id].OnEquip(ply)
        end
    end)
end