asapArena.weaponList = {}

asapArena.weaponList.primary = {
    tfa_cso_ak47 = {
        Kills = 1,
        Headshots = 1,
        Damage = 100,
        ID = 1
    },
    tfa_cso_ak_long = {
        Kills = 5,
        Headshots = 1,
        Damage = 2500,
        ID = 2
    },
    tfa_cso_blaster = {
        Kills = 30,
        Headshots = 10,
        Damage = 5000,
        ID = 3
    },
    tfa_cso_arx160_master = {
        Kills = 45,
        Headshots = 15,
        Damage = 7500,
        ID = 4
    },
    tfa_cso_arx160_expert = {
        Kills = 60,
        Headshots = 10,
        Damage = 11500,
        ID = 5
    },
    tfa_cso_gilboa = {
        Kills = 50,
        Headshots = 5,
        Damage = 5000,
        ID = 6
    },
    tfa_cso_l85a2 = {
        Kills = 40,
        Headshots = 5,
        Damage = 8000,
        ID = 7
    },
    tfa_cso_stg44_master = {
        Kills = 60,
        Headshots = 10,
        Damage = 10000,
        ID = 8
    },
    tfa_cso_vulcanus5 = {
        Kills = 70,
        Headshots = 20,
        Damage = 8000,
        ID = 9
    },
    tfa_cso_dualkriss = {
        Kills = 20,
        Headshots = 5,
        Damage = 3000,
        ID = 10
    },
    tfa_cso_xm1014 = {
        Kills = 25,
        Headshots = 2,
        Damage = 1500,
        ID = 11
    },
    tfa_cso_usas12 = {
        Kills = 50,
        Headshots = 5,
        Damage = 6000,
        ID = 12
    },
    tfa_cso_tbarrel = {
        Kills = 20,
        Headshots = 1,
        Damage = 1000,
        ID = 13
    },
    tfa_cso_as50 = {
        Kills = 60,
        Headshots = 20,
        Damage = 10000,
        ID = 14
    },
    tfa_cso_pkm = {
        Kills = 75,
        Headshots = 20,
        Damage = 15000,
        ID = 15
    },
    tfa_cso_hk121 = {
        Kills = 30,
        Headshots = 30,
        Damage = 5000,
        ID = 16
    },
    tfa_cso_m777 = {
        Kills = 50,
        Headshots = 20,
        Damage = 6000,
        ID = 17
    },
    tfa_cso_as50g = {
        Kills = 20,
        Headshots = 10,
        Damage = 8000,
        ID = 18
    },
    tfa_cso_crossbowex_v6 = {
        Kills = 20,
        Headshots = 1,
        Damage = 8000,
        ID = 19
    },
    tfa_cso_scout = {
        Kills = 40,
        Headshots = 10,
        Damage = 15000,
        ID = 20
    }
}

asapArena.weaponList.secondary = {
    tfa_cso_glock = {
        Kills = 1,
        Headshots = 1,
        Damage = 100,
        ID = 1
    },
    tfa_cso_deagle = {
        Kills = 10,
        Headshots = 3,
        Damage = 1000,
        ID = 2
    },
    tfa_cso_python = {
        Kills = 40,
        Headshots = 10,
        Damage = 10000,
        ID = 3
    },
    tfa_cso_fiveseven = {
        Kills = 25,
        Headshots = 5,
        Damage = 5000,
        ID = 4
    },
    tfa_cso_p228_v2 = {
        Kills = 40,
        Headshots = 10,
        Damage = 5000,
        ID = 5
    },
    tfa_cso_usp = {
        Kills = 20,
        Headshots = 5,
        Damage = 5000,
        ID = 6
    },
    tfa_cso_mac10_v2 = {
        Kills = 30,
        Headshots = 15,
        Damage = 1000,
        ID = 7
    },
    tfa_cso_mauser_c96 = {
        Kills = 10,
        Headshots = 1,
        Damage = 800,
        ID = 8
    },
    tfa_cso_kingcobra = {
        Kills = 50,
        Headshots = 25,
        Damage = 5000,
        ID = 9
    },
    tfa_cso_tmpdragon = {
        Kills = 250,
        Headshots = 50,
        Damage = 50000,
        ID = 10
    },
    tfa_cso_mp7a1 = {
        Kills = 40,
        Headshots = 1,
        Damage = 10000,
        ID = 11
    },
    tfa_cso_rpg7 = {
        Kills = 15,
        Headshots = 1,
        Damage = 5000,
        ID = 12
    }
}

asapArena.weaponList.melee = {"tfa_cso_crowbar 1", "tfa_cso_sealknife 5", "tfa_cso_coldsteelblade 10", "tfa_cso_dualnata 10", "tfa_cso_kujang 15", "tfa_cso_katana 15", "tfa_cso_butterflyknife 20", "tfa_cso_drillgun 20"}
asapArena.weaponList.misc = {"weapon_medkit 5", "tfa_cso_fragnade 7", "tfa_cso_sfgrenade 15", "tfa_cso_thunderstorm 20", "swep_coldstar 30"}

local function addWeapons(tbl, slot, isChallenge)
    local last

    if (isChallenge) then
        for k, v in SortedPairsByMemberValue(tbl, "ID") do
            if (isChallenge) then
                local wepTable = weapons.GetStored(k)

                if (wepTable) then
                    local data = {
                        Name = wepTable.PrintName,
                        Model = wepTable.UseHands and wepTable.ViewModel or wepTable.WorldModel,
                        Level = v.ID,
                        Slot = slot
                    }

                    if (last) then
                        data.Challenge = {
                            Class = last,
                            Data = v
                        }
                    end

                    asapArena:AddWeapon(k, data)
                end

                last = k
            end
        end
    else
        for k, v in pairs(tbl) do
            local class = string.Explode(" ", v, false)[1]
            local level = string.Explode(" ", v, false)[2]
            local wepTable = weapons.GetStored(class)

            if (wepTable) then
                asapArena:AddWeapon(class, {
                    Name = wepTable.PrintName,
                    Model = wepTable.UseHands and wepTable.ViewModel or wepTable.WorldModel,
                    Level = tonumber(level or 1),
                    Slot = slot
                })
            end
        end
    end
end

function asapArena:GetWeaponStats(ply, str)
    if (not ply._arenaData) then
        ply._arenaData = {}
    end
    if not ply._arenaData.Weapons then
        return {0, 0, 0, {1, 0}}
    end
    return ply._arenaData.Weapons[str] or {0, 0, 0, {1, 0}}
end

function asapArena:LevelFormula(level)
    return math.Round(300 + (50 * level))
end

function asapArena:GetWeaponLevel(ply, str)
    if not ply._arenaData then
        ply._arenaData = {}
    end
    if not ply._arenaData.Weapons then
        ply._arenaData.Weapons = {[str] = {0, 0, 0, {1, 0}}}
    end
    return ((self:GetWeaponStats(ply, str) or {})[4] or {1, 0})[1] or 1
end

function asapArena:GetWeaponXP(ply, str)
    if not ply._arenaData then
        ply._arenaData = {}
    end
    if not ply._arenaData.Weapons then
        ply._arenaData.Weapons = {[str] = {0, 0, 0, {1, 0}}}
    end
    return ((self:GetWeaponStats(ply, str) or {})[4] or {1, 0})[2] or 0
end

if SERVER then
    util.AddNetworkString("ASAP.Arena:SyncXP")
    util.AddNetworkString("ASAP.Arena:LevelUp")

    function asapArena:GiveWeaponXP(ply, str, am)
        --if (#self:GetPlayers() < 4) then return end
        if not ply._arenaData.Weapons then
            ply._arenaData.Weapons = {}
        end
        if (not ply._arenaData.Weapons[str]) then
            ply._arenaData.Weapons[str] = {0, 0, 0, {1, 0}}
        elseif (not ply._arenaData.Weapons[str][4]) then
            ply._arenaData.Weapons[str][4] = {1, 0}
        end

        if (ply._arenaData.Weapons[str][4][1] == 100) then
            am = 0
        end

        ply._arenaData.Weapons[str][4][2] = ply._arenaData.Weapons[str][4][2] + am

        if (ply._arenaData.Weapons[str][4][2] >= self:LevelFormula(ply._arenaData.Weapons[str][4][1] + 1)) then
            ply._arenaData.Weapons[str][4][1] = ply._arenaData.Weapons[str][4][1] + 1
            if (ply._arenaData.Weapons[str][4][1] == 100) then
                ply._arenaData.Weapons[str][4] = {100, 0}
            end
            self:GiveWeaponXP(ply, str, 0)
            timer.Simple(3, function()
                if IsValid(ply) then
                    net.Start("ASAP.Arena:LevelUp")
                    net.WriteEntity(ply)
                    net.WriteString(str)
                    net.WriteInt(ply._arenaData.Weapons[str][4][1], 8)
                    net.Send(self:GetPlayers())
                end
            end)
        end

        net.Start("ASAP.Arena:SyncXP")
        net.WriteString(str)
        net.WriteInt(ply._arenaData.Weapons[str][4][1], 8)
        net.WriteInt(ply._arenaData.Weapons[str][4][2], 32)
        net.Send(ply)
    end

    function asapArena:SetWeaponXP(ply, str, am)
        local nextLevel = self:LevelFormula(ply._arenaData.Weapons[str][4][1] + 1)
        ply._arenaData.Weapons[str][4][2] = am
        ply._arenaData.Weapons[str][4][1] = 1

        if (ply._arenaData.Weapons[str][4][2] >= nextLevel) then
            self:GiveWeaponXP(ply, str, 0)
        end

        net.Start("ASAP.Arena:SyncXP")
        net.WriteString(str)
        net.WriteInt(ply._arenaData.Weapons[str][4][1], 8)
        net.WriteInt(ply._arenaData.Weapons[str][4][2], 32)
        net.Send(ply)
    end
else
    net.Receive("ASAP.Arena:SyncXP", function(l)
        local str = net.ReadString()
        local level = net.ReadInt(8)
        local xp = net.ReadInt(32)

        if (not LocalPlayer()._arenaData.Weapons[str]) then
            LocalPlayer()._arenaData.Weapons[str] = {0, 0, 0, {level, xp}}
        end

        LocalPlayer()._arenaData.Weapons[str][4] = {level, xp}
        
        
    end)
end

function asapArena:CanEquipWeapon(ply, str)
    if (ply._arenaData) then
        local wep = self.Weapons[str]
        --No weapon
        if (not wep) then return false, self:GetWeaponStats(ply, str) or {0, 0, 0}, {Kills = 0, Headshots = 0, Damage = 0} end
        --Is first starter
        if (wep.Level == 0) then return true, self:GetWeaponStats(ply, str), {Kills = 0, Headshots = 0, Damage = 0} end
        --No challenge? We meet the min level?
        if (not wep.Challenge and wep.Level <= ply:GetArenaLevel()) then return true, self:GetWeaponStats(ply, str), {Kills = 0, Headshots = 0, Damage = 0} end
        local challenge = wep.Challenge.Data
        if not ply._arenaData.Weapons then return false, self:GetWeaponStats(ply, str), challenge end
        local data = ply._arenaData.Weapons[wep.Challenge.Class]
        --Challenge and we didn't even touch the weapon
        if (not data) then return false, {0, 0, 0}, challenge end
        --We meet all conditions

        return data[1] >= challenge.Kills and data[2] >= challenge.Headshots and data[3] >= challenge.Damage, data, challenge
    end
end

function asapArena:GetAttachmentEquippedArena(ply, strWeapon, iSlot)
    if (not ply._arenaData) then return false end

    if (not ply._arenaData.Attachments) then
        ply._arenaData.Attachments = {}

        return false
    end

    if (not ply._arenaData.Attachments[strWeapon] or not ply._arenaData.Attachments[strWeapon].equipped) then return false end

    return ply._arenaData.Attachments[strWeapon].equipped[iSlot]
end

function asapArena:CanAttachmentArena(ply, strWeapon, strAttachment)
    local stats = self:GetWeaponStats(ply, strWeapon) or {0, 0, 0}
    local challenge = (self.Attachments[strAttachment] or {}).Challenge or {Kills = 0, Headshots = 0, Damage = 0}
    return stats[1] >= challenge.Kills and stats[2] >= challenge.Headshots and stats[3] >= challenge.Damage
end

addWeapons(asapArena.weaponList.primary, "Primary", true)
addWeapons(asapArena.weaponList.secondary, "Secondary", true)
addWeapons(asapArena.weaponList.melee, "Melee")
addWeapons(asapArena.weaponList.misc, "Misc")

if SERVER then
    util.AddNetworkString("ASAP.Arena:EquipAttachment")
    concommand.Add("arena_addkills", function(ply)
        if (ply:IsAdmin()) then
            asapArena:GiveWeaponXP(ply, ply:GetActiveWeapon():GetClass(), 50)
            if (not ply._arenaData.Weapons) then
                ply._arenaData.Weapons = {}
            end
            if (not ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()]) then
                ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()] = {0, 0, 0, {1, 0}}
            end
            ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()][1] = ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()][1] + 25
            ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()][2] = ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()][2] + 25
            ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()][3] = ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()][3] + 500
            net.Start("ASAP.Arena:SyncWeapon")
            net.WriteInt(1, 16)
            net.WriteString(ply:GetActiveWeapon():GetClass())
            net.WriteInt(ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()][1], 32)
            net.WriteInt(ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()][2], 32)
            net.WriteInt(ply._arenaData.Weapons[ply:GetActiveWeapon():GetClass()][3], 32)
            net.Send(ply)
        end
    end)
end

net.Receive("ASAP.Arena:EquipAttachment", function(len, pPlayer)
    local strWeapon = net.ReadString()
    local strAttachment = net.ReadString()
    local iSlot = net.ReadInt(8)
    local bIsAttach = net.ReadBool()

    if (asapArena:CanAttachmentArena(pPlayer, strWeapon, strAttachment)) then
        if (not pPlayer._arenaData.Attachments) then
            pPlayer._arenaData.Attachments = {}
        end
        if not pPlayer._arenaData.Attachments[strWeapon] then
            pPlayer._arenaData.Attachments[strWeapon] = {equipped = {}}
        end

        pPlayer._arenaData.Attachments[strWeapon].equipped[iSlot] = strAttachment

        if (pPlayer:HasWeapon(strWeapon)) then
            if (bIsAttach) then
                pPlayer:GetWeapon(strWeapon):Attach(strAttachment)
            else
                pPlayer:GetWeapon(strWeapon):Detach(strAttachment)
            end
        end
    end
end)