local tail = {
    [1] = "10 Suit",
    [2] = "20 Suit",
    [3] = "30 Suit",
    [4] = "40 Suit",
    [5] = "50 Ultimate Suit",
}

local mdls = {
    [1] = "_sunbreak",
    [2] = "_pacific",
    [3] = "_monarchy",
    [4] = "_luxe",
    [5] = "",
}

local runPower = .25
local baseHealth = 1750
local baseArmor = 1250
local healthIncrease = 200
local armorIncrease = 150
local baseJump = 300
local jumpIncrease = 20
local Gluongun = true
local class = "armor_raytracing"
local mdl = "models/konnie/asapgaming/destiny2/moonfang_warlock"

local function SuitHUD(ply, k)
    if not ply._duration then return end

    if (ply._duration[1] <= 0) then
        ply._duration = nil

        return
    end

    ply._duration[1] = ply._duration[1] - FrameTime()
    draw.RoundedBox(4, ScrW() / 2 - 125, ScrH() / 2 + 96, 256, 24, Color(26, 26, 26))
    draw.RoundedBox(4, ScrW() / 2 - 125 + 2, ScrH() / 2 + 100, 252 * (ply._duration[1] / ply._duration[2]), 16, Color(235, 235, 235))
    draw.SimpleText("Disguise uncovered in:", "XeninUI.TextEntry", ScrW() / 2 - 125, ScrH() / 2 + 72, color_white)
end

local function SuitAbility(ply, k)
    local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 4000, ply)

    if (tr.Entity.armorSuit) then
        local duration = 10 + 5 * k

        if SERVER then
            local rtArmor = "RayTracingArmor_" .. ply:SteamID64()
            timer.Remove(rtArmor)
            ply:SetModel(tr.Entity:GetModel())
            ply._armorHealth = math.max(tr.Entity:Health() - ply:Health(), 0)

            timer.Create("ArmorCeil" .. ply:SteamID64(), 1, math.ceil(ply._armorHealth / 100), function()
                if IsValid(ply) then
                    ply:SetHealth(ply:Health() + 100)
                end
            end)

            ply:SetArmor(tr.Entity:Armor())

            if (k > 1) then
                ply:SetRunSpeed(tr.Entity:GetRunSpeed())
                local wep = ply:Give(tr.Entity:GetActiveWeapon():GetClass())
                ply._rtWep = wep

                timer.Simple(0, function()
                    ply:SelectWeapon(tr.Entity:GetActiveWeapon():GetClass())
                end)
            end

            if (k > 3) then
                net.Start("Rescuer.Zap")
                net.WriteVector(tr.Entity:GetPos())
                net.SendPVS(tr.Entity:GetPos())

                if (ply:GetGang() ~= "") then
                    for _, v in pairs(ents.FindInSphere(ply:GetPos(), 256)) do
                        if (v:IsPlayer() and ply:GetGang() ~= v:GetGang()) then
                            tr.Entity:ScreenFade(SCREENFADE.IN, color_white, 5, .5)
                        end
                    end
                end

                tr.Entity:Freeze(true)
                tr.Entity:ScreenFade(SCREENFADE.IN, color_white, 1, .2)

                timer.Simple(k / 2, function()
                    if IsValid(tr.Entity) then
                        tr.Entity:Freeze(false)
                    end
                end)

                if (k > 4) then
                    tr.Entity:Ignite(5, 64)
                end
            end

            timer.Create(rtArmor, duration, 1, function()
                if IsValid(ply) then
                    ply:SetModel(mdl .. mdls[k] .. ".mdl")
                    ply:SetRunSpeed(600 + (k * runPower))
                    local ball = ents.Create("prop_combine_ball")
                    ball:SetPos(ply:GetPos() + Vector(0, 0, 30))
                    ball:Spawn()
                    ball:Fire("Explode", 0, 0)

                    if (k > 2) then
                        ply:SetHealth(math.max(baseHealth + healthIncrease * k, ply:Health()))
                        ply:SetArmor(math.max(baseArmor + armorIncrease * k, ply:Armor()))
                    else
                        ply:SetHealth(math.max(baseHealth, ply:Health()))
                        ply:SetArmor(math.max(baseArmor, ply:Health()))
                    end
                end
            end)
        else
            ply._duration = {duration, duration}
        end

        return true
    end

    return false
end

local function SuitRemove(ply, k)
    timer.Remove("RayTracingArmor_" .. ply:SteamID64())
    timer.Remove("ArmorCeil" .. ply:SteamID64())
end

local function SuitDescription(k)
    return ""
end

local function addSuit(k)
    Armor:Add({
        Name = "Y-40" .. (k > 1 and tail[k] or ""),
        Description = SuitDescription(k),
        Model = mdl .. mdls[k] .. ".mdl",
        Entitie = class .. "_" .. k,
        Wallhack = true,
        HUDPaint = function(ply)
            if (ply._cloneHealth) then
                ply._cloneHealth = ply._cloneHealth - FrameTime()

                if (ply._cloneHealth <= 0) then
                    ply._cloneHealth = nil

                    return
                end

                local percent = (ply._cloneHealth / 5)
                Armor:DrawHUDBar("Clone duration:", percent, 5)
            end
        end,
        Health = baseHealth + k * healthIncrease,
        Armor = baseArmor + k * armorIncrease,
        JumpPower = baseJump + k * jumpIncrease,
        Speed = 1 + (k * runPower),
        OnGive = function(ply)
            ply:SetNWString("SuitName", "")
            ply.immuneToGluon = Gluongun
        end,
        Abilities = {
            [1] = {
                Cooldown = 70 - k * 5,
                Action = function(armor, ply)
                    local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 256, ply)
                    if (not IsValid(tr.Entity) or not tr.Entity:IsPlayer()) then return false, "Target must be a target" end
                    if (not tr.Entity.armorSuit) then return false, "Your target doesn't have a suit" end
                    local timerName = ply:SteamID64() .. "_health"
                    local targetHealth = math.max(tr.Entity:GetMaxHealth() - ply:Health(), 0)
                    local maxHealth = targetHealth
                    ply:SetModel(tr.Entity:GetModel())
                    ply:SetNWString("SuitName", tr.Entity.armorSuit)
                    if CLIENT then return true end
                    ply:SetMaxHealth(tr.Entity:GetMaxHealth())
                    timer.Remove(timerName)

                    timer.Create(timerName, 1, 0, function()
                        if not IsValid(ply) then
                            timer.Remove(timerName)
                        end

                        if (targetHealth > 0) then
                            targetHealth = math.max(targetHealth - maxHealth * .05, 0)
                            ply:SetHealth(math.min(ply:Health() + maxHealth * .05, maxHealth))
                        end
                    end)
                end,
                Description = "Becomes your target's suit healing yourself until you reach target health"
            },
            [2] = {
                Cooldown = 15,
                Description = "Summons a shield",
                Action = function(armor, ply)
                    if IsValid(ply:GetNW2Entity("ShieldEntity")) then return end

                    if SERVER then
                        if (IsValid(ply._shield)) then return end
                        ply._shield = ents.Create("sent_armor_shield")
                        ply._shield:SetOwner(ply)
                        ply._shield:Spawn()
                        ply:SetNW2Entity("ShieldEntity", ply._shield)
                    end
                end
            },
            [3] = {
                Cooldown = 50 - k * 10,
                Action = function(armor, ply)
                    if CLIENT then
                        ply._cloneHealth = 5

                        return true
                    end

                    local ent = ents.Create("sent_mimicry_clone")
                    ent:SetPos(ply:GetPos())
                    ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
                    ent:SetOwner(ply)
                    ent:SetNWString("SuitName", ply:GetNWString("SuitName", "") == "" and armor.Name or ply:GetNWString("SuitName", ""))
                    ent:Spawn()
                    ent:SetArmor(armor.Name)
                    ply:SetNoDraw(true)

                    timer.Simple(5, function()
                        if IsValid(ply) then
                            ply:SetNoDraw(false)
                        end
                    end)
                end,
                Description = "Makes a dummy hologram of your suit"
            }
        },
        OnRemove = function(ply)
            ply:SetNWString("SuitName", nil)
            local timerName = ply:SteamID64() .. "_health"
            timer.Remove(timerName)
            SuitRemove(ply, k)
        end
    })
end

for k = 1, 5 do
    addSuit(k)
end