AddCSLuaFile()

if SERVER then
    util.AddNetworkString("ASAP.Suits:SetCooldowns")
end

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
local baseHealth = 1900
local baseArmor = 1200
local healthIncrease = 150
local armorIncrease = 100
local baseJump = 300
local jumpIncrease = 30
local class = "armor_bulletsmith"
local mdl = "models/konnie/asapgaming/destiny2/bulletsmith"

for level = 1, 5 do
    Armor:Add({
        Name = "Masterly - 30" .. (level > 1 and tail[level] or ""),
        Description = "Masterly",
        Model = mdl .. mdls[level] .. ".mdl",
        Entitie = class .. "_" .. level,
        Armor = baseArmor + level * armorIncrease,
        Health = baseHealth + level * healthIncrease,
        JumpPower = baseJump + level * jumpIncrease,
        Speed = 1 + level * runPower,
        HUDPaint = function(ply)
            netrunner_VisionUI(ply)
        end,
        OnGiveClient = function(ply)
            hook.Add("PostDrawTranslucentRenderables", "NetRunnerUI", function()
                netrunner_Vision(ply)
            end)
        end,
        Abilities = {
            [1] = {
                Cooldown = 30 - level * 3,
                Description = "You confuse people that are in your view for " .. (4 + level) .. " seconds",
                Action = function(armor, ply)
                    ply:EmitSound("weapons/jetgun_off.wav")
                    local eff = EffectData()
                    eff:SetOrigin(ply:GetPos())
                    eff:SetAngles(ply:EyeAngles())
                    eff:SetFlags(2)
                    util.Effect("eff_netsteal", eff, true, true)

                    for _, v in pairs(ents.FindInCone(ply:GetShootPos(), ply:GetAimVector(), 1000, .707)) do
                        if (not v:IsPlayer()) then continue end
                        if (v:GetGang() ~= "" and ply:GetGang() == v:GetGang()) then continue end
                        v:CreateWeed(4 + level, true)
                    end

                    return true
                end
            },
            [2] = {
                Cooldown = 30,
                Action = function(armor, ply)
                    local hookName = ply:EntIndex() .. "_bulletShield"
                    ply:SetNWBool("ShieldEnabled", true)

                    hook.Add("EntityFireBullets", hookName, function(ent, data)
                        if not IsValid(ply) then
                            hook.Remove("EntityFireBullets", hookName)

                            return
                        end

                        local b = netrunner_Shield(ply, ent, data)
                        if b then return false end
                    end)

                    ply:Wait(4 + level * .5, function()
                        hook.Remove("EntityFireBullets", hookName)

                        if IsValid(ply) then
                            ply:SetNWBool("ShieldEnabled", false)
                            ply:EmitSound("weapons/shatter.wav")
                        end
                    end)

                    if SERVER then
                        ply:EmitSound("weapons/pap_shot.wav")
                    end

                    return true
                end,
                Description = "Deploy a shield that will protect you from incoming bullets"
            }
        },
        OnRemove = function(ply)
            ply:SetNWBool("ShieldEnabled", false)

            if CLIENT then
                hook.Remove("PostDrawTranslucentRenderables", "NetRunnerUI")
            end
        end,
        OnRemoveClient = function()
            hook.Remove("PostDrawTranslucentRenderables", "NetRunnerUI")
        end
    })
end

net.Receive("ASAP.Suits:SetCooldowns", function()
    local wait = net.ReadUInt(6)
    local suitCooldown = LocalPlayer()._newCooldowns[LocalPlayer().armorSuit]
    if not suitCooldown then return end

    for i = 1, 4 do
        local cooldown = suitCooldown[i]
        if not cooldown or (cooldown - CurTime()) > 15 then continue end
        LocalPlayer()._newCooldowns[LocalPlayer().armorSuit][i] = CurTime() + wait
    end
end)