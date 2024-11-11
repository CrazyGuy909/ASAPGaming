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

local runPower = .25
local baseHealth = 1800
local baseArmor = 1000
local healthIncrease = 250
local armorIncrease = 150
local baseJump = 300
local jumpIncrease = 25
local wallhack = false
local Gluongun = false
local class = "armor_bladesmith"
local mdl = "models/konnie/asapgaming/destiny2/bladesmith"

for level = 1, 5 do
    Armor:Add({
        Name = "BladeSmith - 40" .. (level > 1 and tail[level] or ""),
        Description = "Blades curse",
        Model = mdl .. mdls[level] .. ".mdl",
        Entitie = class .. "_" .. level,
        Wallhack = true,
        Health = baseHealth + level * healthIncrease,
        Armor = baseArmor + level * armorIncrease,
        JumpPower = baseJump + level * jumpIncrease,
        Speed = 2 + runPower * level,
        OnGive = function(ply)
            ply.immuneToGluon = Gluongun

            if IsValid(ply.Blades) then
                ply.Blades:Remove()
            end

            ply.Blades = ents.Create("sent_bladescontroller")
            ply.Blades:SetOwner(ply)
            ply.Blades:SetLevel(level)
            ply.Blades:Spawn()
            ply.Blades.defendDuration = 4 + level / 2
            ply.Blades:SetDamage(100 + level * 20)
            ply.Blades:SetColor(bladesColor[level])
            ply:SetNW2Entity("Blades", ply.Blades)
        end,
        Abilities = {
            [1] = {
                Cooldown = 20 - level * 1,
                Action = function(armor, ply)
                    if CLIENT and not IsValid(ply.Blades) and IsValid(ply:GetNW2Entity("Blades")) then
                        ply.Blades = ply:GetNW2Entity("Blades")
                    end

                    if not IsValid(ply.Blades) then return false, "Your blades got destroyed, how the fuck??" end
                    if (ply.Blades:GetState() ~= 0) then return false, "Your blades are busy, calm down!" end
                    if CLIENT then return true end
                    ply.Blades:PerformAttack()
                end,
                Description = "Your blades deal damage around you and protects from bullets for " .. (2 + level / 2) .. " seconds"
            },
            [2] = {
                Cooldown = 25 - level * 3,
                Action = function(armor, ply)
                    if CLIENT and not IsValid(ply.Blades) and IsValid(ply:GetNW2Entity("Blades")) then
                        ply.Blades = ply:GetNW2Entity("Blades")
                    end

                    if not IsValid(ply.Blades) then return false, "Your blades got destroyed, how the fuck??" end

                    if (ply.Blades:GetState() == 3) then
                        ply.Blades:DoMovement(false)
                        timer.Remove(ply:EntIndex() .. "_movement")
                        timer.Remove(ply:EntIndex() .. "_defense")

                        return true
                    end

                    if (ply.Blades:GetState() ~= 0) then return false, "Your blades are busy, calm down!" end
                    ply.Blades:DoMovement(true)

                    timer.Create(ply:EntIndex() .. "_movement", 5, 1, function()
                        if IsValid(ply) and IsValid(ply.Blades) then
                            ply.Blades:DoMovement(false)
                            ply._newCooldowns["BladeSmith - 40" .. (level > 1 and tail[level] or "")][3] = CurTime() + 25 - level * 3
                        end
                    end)

                    return 2
                end,
                Description = "You get propelled really fast towards"
            }
        },
        OnRemove = function(ply)
            SafeRemoveEntity(ply.Blades)
        end
    })
end