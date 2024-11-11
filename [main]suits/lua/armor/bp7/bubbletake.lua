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

local function shieldLevel(k)
    return 20 + k * 2
end

local function shieldSize(k)
    return 76 + k * 12
end

local function SuitHUD(ply, k)
    if ply.shieldDuration and ply.shieldDuration > 0 then
        draw.RoundedBox(4, ScrW() / 2 - 125, ScrH() / 2 + 96, 256, 24, Color(26, 26, 26))
        draw.RoundedBox(4, ScrW() / 2 - 125 + 2, ScrH() / 2 + 100, 252 * (ply.shieldDuration / shieldLevel(k)), 16, Color(235, 235, 235))
        draw.SimpleText("Shield Breaking in:", "XeninUI.TextEntry", ScrW() / 2 - 125, ScrH() / 2 + 72, color_white)
    end
end

local function SuitRemove(ply, k)
    local bubbleName = "Bubble_" .. ply:SteamID64()
    hook.Remove("EntityTakeDamage", bubbleName)
    timer.Remove(bubbleName .. "_armor")
    timer.Remove(bubbleName)
end

local function SuitDescription(k)
    return ""
end

local runPower = .1
local baseHealth = 2000
local baseArmor = 2200
local healthIncrease = 100
local armorIncrease = 150
local baseJump = 350
local jumpIncrease = 10
local Gluongun = true
local class = "armor_bubblum"
local mdl = "models/konnie/asapgaming/destiny2/moonfang_titan"

local function addSuit(k)
    Armor:Add({
        Name = "X-30" .. (k > 1 and tail[k] or ""),
        Description = SuitDescription(k),
        Model = mdl .. mdls[k] .. ".mdl",
        Entitie = class .. "_" .. k,
        Wallhack = true,
        Passive = "Generates a shield that applies different effects\nYour shield will charge while you're not using it\nTo disable it, run the same ability again",
        HUDPaint = function(ply)
            local percent = ply:GetNWInt("ShieldForce", 0) / 100
            Armor:DrawHUDBar("Shield Energy:", percent, 0)
        end,
        Health = baseHealth + k * healthIncrease,
        Armor = baseArmor + k * armorIncrease,
        JumpPower = baseJump + k * jumpIncrease,
        Speed = 1.75 + runPower * k,
        OnGive = function(ply)
            ply.immuneToGluon = Gluongun

            if IsValid(ply:GetNWEntity("Shield")) then
                ply:GetNWEntity("Shield"):Remove()
            end

            local shield = ents.Create("sent_bubblum_shield")
            shield:SetPos(ply:GetPos())
            shield.healAmount = 40 + k * 5
            shield.Level = k
            shield:SetParent(ply)
            shield:SetOwner(ply)
            shield:Spawn()
            shield:SetStatus(false)
            ply:SetNWInt("ShieldForce", 0)
            ply:SetNWEntity("Shield", shield)
            local hookName = ply:SteamID64() .. "_bubblumEnergy"

            timer.Create(hookName, .5, 0, function()
                if not IsValid(ply) then
                    timer.Remove(hookName)
                end

                local inc = 5 + (k - 1)

                if IsValid(shield) and shield:GetStatus() then
                    inc = -5
                end

                ply:SetNWInt("ShieldForce", math.Clamp(ply:GetNWInt("ShieldForce") + inc, 0, 100))

                if inc < 0 and ply:GetNWInt("ShieldForce") <= 0 and shield:GetStatus() then
                    shield:SetStatus(false)

                    if shield.IsWaiting then
                        timer.Simple(1, function()
                            shield:SetParent(ply)
                            shield.IsWaiting = false
                            shield:SetPos(ply:GetPos())
                        end)
                    end
                end
            end)
        end,
        Abilities = {
            [1] = {
                Description = "Heals and decrease explosive damage",
                Cooldown = 10 - k - 1,
                Action = function(armor, ply)
                    local shield = ply:GetNWEntity("Shield", nil)
                    if not IsValid(shield) then return false, "Your shield is disabled" end

                    if shield:GetStatus() and shield:GetKind() == 1 then
                        shield:SetStatus(false)

                        return true
                    end

                    if not shield:GetStatus() and ply:GetNWInt("ShieldForce", 0) < 5 then return false, "You don't have enough shield energy" end
                    shield:EmitSound("csgo/bumpmine_land.wav")
                    shield:SetStatus(true)
                    shield:SetKind(1)

                    shield.ExplosiveReduction = .4 + k * .05

                    return true
                end
            },
            [2] = {
                Description = "Protects from bullets damage a " .. (50 + (k - 1) * 5) .. "% damage",
                Cooldown = 50 - k * 2,
                Action = function(armor, ply)
                    local shield = ply:GetNWEntity("Shield", nil)
                    if not IsValid(shield) then return false, "Your shield is disabled" end

                    if shield:GetStatus() and shield:GetKind() == 3 then
                        shield:SetStatus(false)

                        return true
                    end

                    if not shield:GetStatus() and ply:GetNWInt("ShieldForce", 0) < 5 then return false, "You don't have enough shield energy" end
                    shield:EmitSound("csgo/bumpmine_throw.wav")
                    shield:SetStatus(true)
                    shield:SetKind(2)

                    return true
                end
            },
        },
        OnRemove = function(ply)
            SuitRemove(ply, k)

            if SERVER then
                local shield = ply:GetNWEntity("Shield", nil)

                if IsValid(shield) then
                    shield:Remove()
                end

                hook.Remove("Think", ply:SteamID64() .. "_bubbleEnergy")
            end
        end
    })
end

for k = 1, 5 do
    addSuit(k)
end