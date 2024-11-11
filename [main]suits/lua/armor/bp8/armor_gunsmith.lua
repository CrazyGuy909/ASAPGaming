AddCSLuaFile()

local tail = {
    [1] = "10 Suit",
    [2] = "20 Suit",
    [3] = "30 Suit",
    [4] = "40 Suit",
    [5] = "50 Ultimate Suit",
}

local mdls = {
    [1] = "_sunbreak",
    [2] = "_futurefacing",
    [3] = "_exile",
    [4] = "_competitive",
    [5] = "",
}

local bladesColor = {
    [1] = Color(255, 180, 0),
    [2] = Color(0, 192, 255),
    [3] = Color(255, 249, 92),
    [4] = color_white,
    [5] = Color(202, 52, 52)
}

local runPower = .4
local baseHealth = 2000
local baseArmor = 1100
local healthIncrease = 200
local armorIncrease = 100
local baseJump = 300
local jumpIncrease = 30
local class = "armor_gunsmith"
local mdl = "models/konnie/asapgaming/destiny2/gunsmith"

for level = 1, 5 do
    local name = "GunSmith - 20" .. (level > 1 and tail[level] or "")

    Armor:Add({
        Name = name,
        Description = "Guns with no hands",
        Model = mdl .. mdls[level] .. ".mdl",
        Entitie = class .. "_" .. level,
        Wallhack = true,
        HUDPaint = function(ply)
            if not IsValid(ply:GetNWEntity("Blades")) then return end
            local percent = (ply:GetNWEntity("Blades"):GetDamage() / 200)
            Armor:DrawHUDBar("Fury:", percent, 5)
        end,
        Armor = baseArmor + level * armorIncrease,
        Health = baseHealth + level * healthIncrease,
        JumpPower = baseJump + level * jumpIncrease,
        Speed = 1 + level * runPower,
        OnGive = function(ply)
            if IsValid(ply.GunSmith) then
                ply.GunSmith:Remove()
            end

            ply.GunSmith = ents.Create("sent_gunsmithcontroller")
            ply.GunSmith:SetOwner(ply)
            ply.GunSmith:SetParent(ply)
            ply.GunSmith:SetLocalPos(vector_origin)
            ply.GunSmith:SetLevel(level)
            ply.GunSmith:Spawn()
            ply:SetNWEntity("GunSmith", ply.GunSmith)
        end,
        Abilities = {
            [1] = {
                Cooldown = 15 - level,
                Action = function(armor, ply)
                    local gun = ply:GetNWEntity("GunSmith")
                    if not IsValid(gun) then return false, "You lost your weapons wtf?" end
                    if (gun:GetBusy()) then return false, "Your weapon must reload" end
                    gun:ShootGun({1, 2})

                    for k, v in pairs(ply._newCooldowns[name]) do
                        if (k ~= 1 and v < CurTime()) then
                            ply._newCooldowns[name][k] = CurTime() + 1
                        end
                    end

                    return true
                end,
                Description = "Poison + Firedrill"
            },
            [2] = {
                Cooldown = 15 - level,
                Description = "Gluon + Freeze",
                Action = function(armor, ply)
                    local gun = ply:GetNWEntity("GunSmith")
                    if not IsValid(gun) then return false, "You lost your weapons wtf?" end
                    if (gun:GetBusy()) then return false, "Your weapon must reload" end
                    gun:ShootGun({3, 4})

                    for k, v in pairs(ply._newCooldowns[name]) do
                        if (k ~= 2 and v < CurTime()) then
                            ply._newCooldowns[name][k] = CurTime() + 1
                        end
                    end

                    return true
                end
            },
        },
        OnRemove = function(ply)
            if IsValid(ply.GunSmith) then
                ply.GunSmith:Remove()
            end
        end
    })
end