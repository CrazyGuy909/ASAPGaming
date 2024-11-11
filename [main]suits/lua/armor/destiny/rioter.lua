AddCSLuaFile()

Armor:Add({
    Name = "Anti-Riot Suit",
    Description = "Charges on a direction hitting everyone in his way",
    Model = "models/player/kleiner.mdl",
    Entitie = "armor_simulator",
    HUDPaint = function(ply)
        local shield = ply:GetNW2Entity("ShieldEntity")

        return not IsValid(shield)
    end,
    Health = 1500,
    Armor = 2000,
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(s, ply)
                if IsValid(ply:GetNW2Entity("ShieldEntity")) then return end

                if SERVER then
                    if (IsValid(ply._shield)) then return end
                    ply._shield = ents.Create("sent_armor_charge")
                    ply._shield:SetOwner(ply)
                    ply._shield:Spawn()
                    ply._shield:Setup(ply)
                    ply:SetNW2Entity("ShieldEntity", ply._shield)
                end

                return false
            end
        }
    },
    OnRemove = function(ply)
        if SERVER and IsValid(ply._shield) then
            ply._shield:Remove()
        end
    end
})